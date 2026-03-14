class_name TankBase
extends CharacterBody2D

## Base class for all tanks (player and enemy). Handles movement, aiming, firing, HP, and skills.

signal hp_changed(current: float, max_hp: float)
signal sp_changed(current: float, max_sp: float)
signal tank_destroyed(tank: TankBase)
signal shot_fired(projectile: Node2D)
signal damage_dealt(amount: float, pos: Vector2)

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

# Skill state
var skill_cooldown: float = 0.0
var shield_active: bool = false
var shield_reduction: float = 0.0
var shield_timer: float = 0.0
var dash_active: bool = false
var sp_regen_rate: float = 1.0  # SP per second

# Nodes (set up in _ready or by subclass)
var body_node: Node2D
var barrel_node: Node2D
var barrel_tip: Marker2D

# Projectile scene
var projectile_scene: PackedScene = preload("res://scenes/projectiles/projectile.tscn")

const GRAVITY := 980.0
const BARREL_MIN_ANGLE := -80.0
const BARREL_MAX_ANGLE := 10.0


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
	pass


func _process(delta: float) -> void:
	# SP regeneration
	if is_alive and current_sp < max_sp:
		current_sp = minf(current_sp + sp_regen_rate * delta, max_sp)
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
			_remove_shield_visual()


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
	_show_muzzle_flash()
	SfxManager.play_cannon_fire()

	var timer := get_tree().create_timer(rld)
	timer.timeout.connect(func(): can_fire = true)


func take_damage(raw_damage: float, _attacker: TankBase = null) -> float:
	if not is_alive:
		return 0.0
	if dash_active:
		return 0.0

	var effective_damage := raw_damage
	if shield_active:
		effective_damage *= (1.0 - shield_reduction)

	var actual_damage := effective_damage * (100.0 / (100.0 + def))
	actual_damage = maxf(1.0, actual_damage)
	current_hp -= actual_damage
	hp_changed.emit(current_hp, max_hp)
	damage_dealt.emit(actual_damage, global_position + Vector2(randf_range(-10, 10), -40))
	SfxManager.play_hit()

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


# --- SKILLS ---

func use_skill() -> void:
	if not is_alive or skill_cooldown > 0.0:
		return
	match tank_class:
		TankClasses.ClassType.BASIC:
			_skill_power_shot()
		TankClasses.ClassType.DEALER:
			_skill_rapid_fire()
		TankClasses.ClassType.TANKER:
			_skill_shield()
		TankClasses.ClassType.SUPPORT:
			_skill_repair()
		TankClasses.ClassType.ARTILLERY:
			_skill_barrage()
		TankClasses.ClassType.SCOUT:
			_skill_dash()
		_:
			_skill_power_shot()


func get_skill_name() -> String:
	match tank_class:
		TankClasses.ClassType.BASIC: return "Power Shot"
		TankClasses.ClassType.DEALER: return "Rapid Fire"
		TankClasses.ClassType.TANKER: return "Shield"
		TankClasses.ClassType.SUPPORT: return "Repair"
		TankClasses.ClassType.ARTILLERY: return "Barrage"
		TankClasses.ClassType.SCOUT: return "Dash"
		_: return "Power Shot"


func get_skill_cost() -> int:
	match tank_class:
		TankClasses.ClassType.BASIC: return 20
		TankClasses.ClassType.DEALER: return 30
		TankClasses.ClassType.TANKER: return 25
		TankClasses.ClassType.SUPPORT: return 35
		TankClasses.ClassType.ARTILLERY: return 40
		TankClasses.ClassType.SCOUT: return 15
		_: return 20


func _fire_projectile(damage_mult: float = 1.0, radius_override: float = 0.0, angle_offset: float = 0.0) -> void:
	var projectile := projectile_scene.instantiate() as Node2D
	var spawn_pos: Vector2 = barrel_tip.global_position if barrel_tip else global_position + Vector2((1.0 if facing_right else -1.0) * 40.0, -25.0)
	projectile.global_position = spawn_pos
	projectile.damage = atk * damage_mult
	projectile.owner_tank = self
	if radius_override > 0.0:
		projectile.explosion_radius = radius_override

	var fire_angle: float = deg_to_rad(barrel_angle) if facing_right else deg_to_rad(180.0 - barrel_angle)
	fire_angle += deg_to_rad(angle_offset)
	var launch_speed := rng * 1.5
	projectile.initial_velocity = Vector2(cos(fire_angle) * launch_speed, sin(fire_angle) * launch_speed)

	get_tree().current_scene.add_child(projectile)
	shot_fired.emit(projectile)
	_show_muzzle_flash()


func _skill_power_shot() -> void:
	if not use_sp(20.0):
		return
	skill_cooldown = 5.0
	SfxManager.play_skill_use()
	if not can_fire:
		return
	can_fire = false
	_fire_projectile(2.0, 40.0)
	var timer := get_tree().create_timer(rld)
	timer.timeout.connect(func(): can_fire = true)


func _skill_rapid_fire() -> void:
	if not use_sp(30.0):
		return
	skill_cooldown = 8.0
	SfxManager.play_skill_use()
	for i in range(3):
		await get_tree().create_timer(0.15).timeout
		if not is_alive:
			return
		_fire_projectile(1.0, 0.0, randf_range(-3.0, 3.0))


func _skill_shield() -> void:
	if not use_sp(25.0):
		return
	skill_cooldown = 12.0
	SfxManager.play_shield()
	shield_active = true
	shield_reduction = 0.5
	shield_timer = 5.0
	_show_shield_visual()


func _skill_repair() -> void:
	if not use_sp(35.0):
		return
	skill_cooldown = 10.0
	SfxManager.play_heal()
	heal(max_hp * 0.3)
	_show_heal_visual()


func _skill_barrage() -> void:
	if not use_sp(40.0):
		return
	skill_cooldown = 15.0
	SfxManager.play_skill_use()
	for i in range(3):
		await get_tree().create_timer(0.25).timeout
		if not is_alive:
			return
		var projectile := projectile_scene.instantiate() as Node2D
		projectile.global_position = global_position + Vector2(0, -100)
		projectile.damage = atk * 1.2
		projectile.owner_tank = self
		projectile.explosion_radius = 35.0
		var direction := 1.0 if facing_right else -1.0
		var launch_speed := rng * 1.2
		projectile.initial_velocity = Vector2(direction * launch_speed * 0.7 + randf_range(-30.0, 30.0), -launch_speed * 0.8)
		get_tree().current_scene.add_child(projectile)
		shot_fired.emit(projectile)


func _skill_dash() -> void:
	if not use_sp(15.0):
		return
	skill_cooldown = 5.0
	SfxManager.play_dash()
	dash_active = true
	var direction := 1.0 if facing_right else -1.0
	modulate.a = 0.4
	var tween := create_tween()
	tween.tween_property(self, "global_position:x", global_position.x + direction * 200.0, 0.2)
	tween.tween_callback(func():
		dash_active = false
		modulate.a = 1.0
	)


# --- VISUAL EFFECTS ---

func _show_muzzle_flash() -> void:
	if not barrel_tip:
		return
	var flash := Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(8):
		var angle := i * TAU / 8.0
		points.append(Vector2(cos(angle), sin(angle)) * 10.0)
	flash.polygon = points
	flash.color = Color(1.0, 0.7, 0.2, 0.9)
	flash.global_position = barrel_tip.global_position
	get_tree().current_scene.add_child(flash)

	var tween := flash.create_tween()
	tween.tween_property(flash, "scale", Vector2(0.1, 0.1), 0.1)
	tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.1)
	tween.tween_callback(flash.queue_free)


func _show_shield_visual() -> void:
	var shield_vfx := Polygon2D.new()
	shield_vfx.name = "ShieldVisual"
	var points: PackedVector2Array = []
	for i in range(20):
		var angle := i * TAU / 20.0
		points.append(Vector2(cos(angle), sin(angle)) * 45.0)
	shield_vfx.polygon = points
	shield_vfx.color = Color(0.3, 0.6, 0.9, 0.25)
	shield_vfx.position = Vector2(0, -15)
	add_child(shield_vfx)

	var tween := shield_vfx.create_tween().set_loops()
	tween.tween_property(shield_vfx, "color:a", 0.1, 0.5)
	tween.tween_property(shield_vfx, "color:a", 0.3, 0.5)


func _remove_shield_visual() -> void:
	var shield := get_node_or_null("ShieldVisual")
	if shield:
		shield.queue_free()


func _show_heal_visual() -> void:
	for i in range(5):
		var particle := Polygon2D.new()
		var pts: PackedVector2Array = []
		pts.append(Vector2(-2, -6)); pts.append(Vector2(2, -6))
		pts.append(Vector2(2, -2)); pts.append(Vector2(6, -2))
		pts.append(Vector2(6, 2)); pts.append(Vector2(2, 2))
		pts.append(Vector2(2, 6)); pts.append(Vector2(-2, 6))
		pts.append(Vector2(-2, 2)); pts.append(Vector2(-6, 2))
		pts.append(Vector2(-6, -2)); pts.append(Vector2(-2, -2))
		particle.polygon = pts
		particle.color = Color(0.3, 0.9, 0.3, 0.8)
		particle.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-10, -30))
		get_tree().current_scene.add_child(particle)

		var tween := particle.create_tween()
		tween.tween_property(particle, "global_position:y", particle.global_position.y - 40.0, 0.8)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.8)
		tween.tween_callback(particle.queue_free)


func _die() -> void:
	is_alive = false
	tank_destroyed.emit(self)
	SfxManager.play_explosion()
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.15)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	tween.tween_property(self, "scale", Vector2(0.3, 0.3), 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		_spawn_death_explosion()
		queue_free()
	)


func _spawn_death_explosion() -> void:
	if not is_inside_tree():
		return
	for i in range(4):
		var explosion := Node2D.new()
		var circle := Polygon2D.new()
		var pts: PackedVector2Array = []
		var radius := randf_range(15.0, 30.0)
		for j in range(12):
			var angle := j * TAU / 12.0
			pts.append(Vector2(cos(angle), sin(angle)) * radius)
		circle.polygon = pts
		circle.color = [Color(0.9, 0.4, 0.1, 0.9), Color(0.95, 0.6, 0.1, 0.9), Color(0.8, 0.2, 0.05, 0.9)].pick_random()
		explosion.add_child(circle)
		explosion.global_position = global_position + Vector2(randf_range(-15, 15), randf_range(-25, 5))
		get_tree().current_scene.add_child(explosion)

		var tween := explosion.create_tween()
		tween.tween_property(circle, "scale", Vector2(2.0, 2.0), 0.4)
		tween.parallel().tween_property(circle, "color:a", 0.0, 0.4)
		tween.tween_callback(explosion.queue_free)
