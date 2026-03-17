class_name TankBase
extends CharacterBody2D

## Base class for all tanks. Core: movement, aiming, firing, HP/SP, damage.

signal hp_changed(current: float, max_hp: float)
signal sp_changed(current: float, max_sp: float)
signal tank_destroyed(tank: TankBase)
signal shot_fired(projectile: Node2D)
signal damage_dealt(amount: float, pos: Vector2)

@export var tank_class: TankClasses.ClassType = TankClasses.ClassType.BASIC
@export var tank_level: int = 1

# Stats
var max_hp: float = 100.0
var current_hp: float = 100.0
var atk: float = 15.0
var def: float = 10.0
var spd: float = 80.0
var rld: float = 1.5
var rng: float = 300.0
var max_sp: float = 50.0
var current_sp: float = 50.0

# Combat state
var barrel_angle: float = -45.0
var can_fire: bool = true
var is_alive: bool = true
var facing_right: bool = true

# Skill state
var skill_cooldown: float = 0.0
var shield_active: bool = false
var shield_reduction: float = 0.0
var shield_timer: float = 0.0
var dash_active: bool = false
var sp_regen_rate: float = 1.0

# Nodes
var body_node: Node2D
var barrel_node: Node2D
var barrel_tip: Marker2D

var projectile_scene: PackedScene = preload("res://scenes/projectiles/projectile.tscn")

const GRAVITY := 980.0
const BARREL_MIN_ANGLE := -80.0
const BARREL_MAX_ANGLE := 10.0

func _ready() -> void:
	_init_stats()
	_setup_collision()
	_setup_visuals()
	add_to_group("tanks")

## Add collision shape so CharacterBody2D works with physics.
func _setup_collision() -> void:
	collision_layer = 2  # tanks on layer 2
	collision_mask = 1   # collide with terrain (layer 1)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(50, 30)
	shape.shape = rect
	shape.position = Vector2(0, -15)
	add_child(shape)

func _init_stats() -> void:
	max_hp = TankClasses.get_stat_at_level(tank_class, "hp", tank_level)
	current_hp = max_hp
	atk = TankClasses.get_stat_at_level(tank_class, "atk", tank_level)
	def = TankClasses.get_stat_at_level(tank_class, "def", tank_level)
	spd = TankClasses.get_stat_at_level(tank_class, "spd", tank_level)
	rld = TankClasses.get_stat_at_level(tank_class, "rld", tank_level)
	rng = TankClasses.get_stat_at_level(tank_class, "rng", tank_level)
	max_sp = TankClasses.get_stat_at_level(tank_class, "sp", tank_level)
	current_sp = max_sp

func _setup_visuals() -> void:
	pass

func _process(delta: float) -> void:
	if not is_alive:
		return
	# SP regen
	if current_sp < max_sp:
		current_sp = min(current_sp + sp_regen_rate * delta, max_sp)
		sp_changed.emit(current_sp, max_sp)
	# Skill cooldown
	if skill_cooldown > 0.0:
		skill_cooldown -= delta
	# Shield timer
	if shield_active:
		shield_timer -= delta
		if shield_timer <= 0.0:
			shield_active = false
			shield_reduction = 0.0
			TankEffects.remove_shield_visual(self)

## Move tank horizontally.
func move_horizontal(direction: float, _delta: float) -> void:
	if not is_alive:
		return
	velocity.x = direction * spd
	if direction > 0:
		facing_right = true
	elif direction < 0:
		facing_right = false
	move_and_slide()

## Adjust barrel angle.
func aim(angle_delta: float, _delta: float) -> void:
	if not is_alive:
		return
	barrel_angle = clamp(barrel_angle + angle_delta, BARREL_MIN_ANGLE, BARREL_MAX_ANGLE)
	if barrel_node:
		barrel_node.rotation_degrees = barrel_angle

## Fire a projectile.
func fire() -> void:
	if not is_alive or not can_fire:
		return
	_fire_projectile()
	TankEffects.show_muzzle_flash(self)
	can_fire = false
	var timer := get_tree().create_timer(rld)
	timer.timeout.connect(func(): can_fire = true)

## Fire projectile with optional modifiers (used by skills).
func _fire_projectile(damage_mult: float = 1.0, _radius_override: float = 0.0, angle_offset: float = 0.0) -> void:
	if barrel_tip == null:
		return
	var proj: Node2D = projectile_scene.instantiate()
	proj.global_position = barrel_tip.global_position
	var fire_angle := deg_to_rad(barrel_angle + angle_offset)
	var direction := 1.0 if facing_right else -1.0
	var speed := rng * 2.0
	proj.set("velocity", Vector2(cos(fire_angle) * speed * direction, sin(fire_angle) * speed))
	proj.set("damage", atk * damage_mult)
	proj.set("owner_tank", self)
	get_tree().current_scene.add_child(proj)
	shot_fired.emit(proj)

## Apply damage to this tank.
func take_damage(raw_damage: float, _attacker: TankBase = null) -> float:
	if not is_alive or dash_active:
		return 0.0
	var effective_damage := raw_damage * (100.0 / (100.0 + def))
	if shield_active:
		effective_damage *= (1.0 - shield_reduction)
	current_hp -= effective_damage
	hp_changed.emit(current_hp, max_hp)
	TankEffects.show_damage_number(self, effective_damage)
	if current_hp <= 0.0:
		current_hp = 0.0
		_die()
	return effective_damage

## Heal this tank.
func heal(amount: float) -> void:
	current_hp = min(current_hp + amount, max_hp)
	hp_changed.emit(current_hp, max_hp)

## Spend SP. Returns true if successful.
func use_sp(amount: float) -> bool:
	if current_sp < amount:
		return false
	current_sp -= amount
	sp_changed.emit(current_sp, max_sp)
	return true

## Use class skill (delegates to TankSkills).
func use_skill() -> void:
	if skill_cooldown > 0.0:
		return
	TankSkills.execute(self)

## Get skill display name.
func get_skill_name() -> String:
	return TankSkills.get_skill_name(tank_class)

## Get skill SP cost.
func get_skill_cost() -> int:
	return TankSkills.get_skill_cost(tank_class)

## Handle death.
func _die() -> void:
	is_alive = false
	tank_destroyed.emit(self)
	TankEffects.spawn_death_explosion(self)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.3)
	tween.tween_callback(queue_free)

