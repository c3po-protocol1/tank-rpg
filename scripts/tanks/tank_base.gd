class_name TankBase
extends CharacterBody2D

## Base class for all tanks (player and enemy). Handles movement, aiming, firing, and HP.

signal hp_changed(current: float, max_hp: float)
signal sp_changed(current: float, max_sp: float)
signal tank_destroyed(tank: TankBase)
signal shot_fired(projectile: Node2D)

@export var tank_class: TankClasses.ClassType = TankClasses.ClassType.BASIC
@export var tank_level: int = 1

# Stats (computed from class + level + bonuses)
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
var barrel_angle: float = -45.0  # Degrees, negative = up
var can_fire: bool = true
var is_alive: bool = true
var facing_right: bool = true

# Nodes (set up in _ready or by subclass)
var body_node: Node2D
var barrel_node: Node2D
var barrel_tip: Marker2D

# Projectile scene
var projectile_scene: PackedScene = preload("res://scenes/projectiles/projectile.tscn")

const GRAVITY := 980.0
const BARREL_MIN_ANGLE := -80.0  # Almost straight up
const BARREL_MAX_ANGLE := 10.0    # Slightly below horizontal


func _ready() -> void:
	_init_stats()
	_setup_visuals()
	add_to_group("tanks")


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
	# Subclasses should override to build their visual representation
	pass


func move_horizontal(direction: float, delta: float) -> void:
	if not is_alive:
		return
	velocity.x = direction * spd
	if direction > 0:
		facing_right = true
	elif direction < 0:
		facing_right = false
	move_and_slide()


func aim(angle_delta: float, delta: float) -> void:
	if not is_alive:
		return
	barrel_angle = clampf(barrel_angle + angle_delta * delta * 60.0, BARREL_MIN_ANGLE, BARREL_MAX_ANGLE)
	if barrel_node:
		var actual_angle := barrel_angle if facing_right else -(180.0 + barrel_angle)
		barrel_node.rotation_degrees = actual_angle


func fire() -> void:
	if not is_alive or not can_fire:
		return

	can_fire = false
	var projectile := projectile_scene.instantiate() as Node2D
	var spawn_pos: Vector2
	if barrel_tip:
		spawn_pos = barrel_tip.global_position
	else:
		var direction := 1.0 if facing_right else -1.0
		spawn_pos = global_position + Vector2(direction * 40.0, -25.0)

	projectile.global_position = spawn_pos
	projectile.damage = atk
	projectile.owner_tank = self

	# Calculate launch velocity based on barrel angle and range
	var fire_angle: float
	if facing_right:
		fire_angle = deg_to_rad(barrel_angle)
	else:
		fire_angle = deg_to_rad(180.0 - barrel_angle)

	var launch_speed := rng * 1.5
	projectile.initial_velocity = Vector2(
		cos(fire_angle) * launch_speed,
		sin(fire_angle) * launch_speed
	)

	get_tree().current_scene.add_child(projectile)
	shot_fired.emit(projectile)

	# Reload timer
	var timer := get_tree().create_timer(rld)
	timer.timeout.connect(func(): can_fire = true)


func take_damage(raw_damage: float, _attacker: TankBase = null) -> float:
	if not is_alive:
		return 0.0
	# Damage formula: raw_damage * (100 / (100 + def))
	var actual_damage := raw_damage * (100.0 / (100.0 + def))
	actual_damage = maxf(1.0, actual_damage)  # Minimum 1 damage
	current_hp -= actual_damage
	hp_changed.emit(current_hp, max_hp)

	if current_hp <= 0.0:
		current_hp = 0.0
		_die()

	return actual_damage


func heal(amount: float) -> void:
	if not is_alive:
		return
	current_hp = minf(current_hp + amount, max_hp)
	hp_changed.emit(current_hp, max_hp)


func use_sp(amount: float) -> bool:
	if current_sp < amount:
		return false
	current_sp -= amount
	sp_changed.emit(current_sp, max_sp)
	return true


func _die() -> void:
	is_alive = false
	tank_destroyed.emit(self)
	# Play death animation then queue_free
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
