class_name TankBase
extends CharacterBody2D

## Base class for all tanks. Core: movement, aiming, firing, HP/SP, damage.

signal hp_changed(current: float, max_hp: float)
signal sp_changed(current: float, max_sp: float)
signal tank_destroyed(tank: TankBase)
signal shot_fired(projectile: Node2D)
signal damage_dealt(amount: float, pos: Vector2)
signal power_gauge_changed(value: float)
signal bullet_type_changed(bullet_type: BulletTypes.BulletType)

@export var tank_class: TankClasses.ClassType = TankClasses.ClassType.BASIC
@export var tank_level: int = 1
var max_hp: float = 100.0
var current_hp: float = 100.0
var atk: float = 15.0
var def: float = 10.0
var spd: float = 80.0
var rld: float = 1.5
var rng: float = 300.0
var max_sp: float = 50.0
var current_sp: float = 50.0
var barrel_angle: float = -45.0
var can_fire: bool = true
var is_alive: bool = true
var facing_right: bool = true
# Bullet system
var current_bullet: BulletTypes.BulletType = BulletTypes.BulletType.STANDARD
var available_bullets: Array = []
# Power gauge (oscillates 0→1→0→1... press fire to start, press again to shoot)
var charging: bool = false
var power_gauge: float = 0.0
var gauge_direction: float = 1.0
# Skill state
var skill_cooldown: float = 0.0
var shield_active: bool = false
var shield_reduction: float = 0.0
var shield_timer: float = 0.0
var dash_active: bool = false
var sp_regen_rate: float = 1.0
var body_node: Node2D
var barrel_node: Node2D
var barrel_tip: Marker2D
var projectile_scene: PackedScene = preload("res://scenes/projectiles/projectile.tscn")
const GRAVITY := 980.0
const BARREL_MIN_ANGLE := -80.0
const BARREL_MAX_ANGLE := 10.0
const GAUGE_BASE_SPEED := 1.5
func _ready() -> void:
	_init_stats()
	_setup_collision()
	_setup_visuals()
	available_bullets = BulletTypes.get_bullet_types(tank_class)
	current_bullet = available_bullets[0]
	add_to_group("tanks")
func _setup_collision() -> void:
	collision_layer = 2
	collision_mask = 1
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
	if current_sp < max_sp:
		current_sp = min(current_sp + sp_regen_rate * delta, max_sp)
		sp_changed.emit(current_sp, max_sp)
	if skill_cooldown > 0.0:
		skill_cooldown -= delta
	if shield_active:
		shield_timer -= delta
		if shield_timer <= 0.0:
			shield_active = false
			shield_reduction = 0.0
			TankEffects.remove_shield_visual(self)
	# Power gauge oscillation
	if charging:
		var bullet_data: Dictionary = BulletTypes.get_data(current_bullet)
		var speed: float = GAUGE_BASE_SPEED * bullet_data.get("gauge_speed", 1.0)
		power_gauge += gauge_direction * speed * delta
		if power_gauge >= 1.0:
			power_gauge = 1.0
			gauge_direction = -1.0
		elif power_gauge <= 0.0:
			power_gauge = 0.0
			gauge_direction = 1.0
		power_gauge_changed.emit(power_gauge)

func move_horizontal(direction: float, _delta: float) -> void:
	if not is_alive:
		return
	velocity.x = direction * spd
	if direction > 0:
		facing_right = true
	elif direction < 0:
		facing_right = false
	move_and_slide()

func aim(angle_delta: float, _delta: float) -> void:
	if not is_alive:
		return
	barrel_angle = clamp(barrel_angle + angle_delta, BARREL_MIN_ANGLE, BARREL_MAX_ANGLE)
	if barrel_node:
		barrel_node.rotation_degrees = barrel_angle

func fire() -> void:
	if not is_alive or not can_fire: return
	_fire_projectile(1.0, 20.0, 0.0, 0.6)
	TankEffects.show_muzzle_flash(self)
	can_fire = false
	get_tree().create_timer(rld).timeout.connect(func(): can_fire = true)
func fire_press() -> void:
	if not is_alive or not can_fire:
		return
	if not charging:
		charging = true
		power_gauge = 0.0
		gauge_direction = 1.0
	else:
		_shoot_with_power(power_gauge)
		charging = false
		power_gauge = 0.0

func _shoot_with_power(power: float) -> void:
	var bullet_data: Dictionary = BulletTypes.get_data(current_bullet)
	var dmg_mult: float = bullet_data.get("damage_mult", 1.0)
	var radius: float = bullet_data.get("radius", 20.0)
	_fire_projectile(dmg_mult, radius, 0.0, power)
	TankEffects.show_muzzle_flash(self)
	can_fire = false
	power_gauge_changed.emit(0.0)
	get_tree().create_timer(rld).timeout.connect(func(): can_fire = true)

func switch_bullet() -> void:
	if available_bullets.size() <= 1:
		return
	var idx: int = available_bullets.find(current_bullet)
	idx = (idx + 1) % available_bullets.size()
	current_bullet = available_bullets[idx]
	bullet_type_changed.emit(current_bullet)

func _fire_projectile(damage_mult: float = 1.0, radius: float = 20.0, angle_offset: float = 0.0, power: float = 0.5) -> void:
	TankFireSystem.fire_projectile(self, damage_mult, radius, angle_offset, power)

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
func heal(amount: float) -> void:
	current_hp = min(current_hp + amount, max_hp)
	hp_changed.emit(current_hp, max_hp)

func use_sp(amount: float) -> bool:
	if current_sp < amount:
		return false
	current_sp -= amount
	sp_changed.emit(current_sp, max_sp)
	return true

func use_skill() -> void:
	if skill_cooldown > 0.0:
		return
	TankSkills.execute(self)

func get_skill_name() -> String: return TankSkills.get_skill_name(tank_class)
func get_skill_cost() -> int: return TankSkills.get_skill_cost(tank_class)
func _die() -> void:
	is_alive = false
	tank_destroyed.emit(self)
	TankEffects.spawn_death_explosion(self)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.3)
	tween.tween_callback(queue_free)
