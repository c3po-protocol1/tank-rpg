class_name EnemyTank
extends TankBase

## AI-controlled enemy tank. Aims at player and fires periodically.

@export var enemy_type: StageData.EnemyType = StageData.EnemyType.GRUNT

var player_ref: TankBase = null
var ai_fire_timer: float = 0.0
var ai_aim_timer: float = 0.0
var ai_move_timer: float = 0.0
var ai_move_direction: float = 0.0

# AI tuning
var aim_accuracy: float = 0.8    # 1.0 = perfect aim
var fire_delay_min: float = 2.0
var fire_delay_max: float = 4.0
var move_chance: float = 0.3


func _ready() -> void:
	super._ready()
	_apply_enemy_scaling()
	_setup_ai_params()
	add_to_group("enemies")
	StageManager.register_enemy()
	ai_fire_timer = randf_range(1.0, fire_delay_max)


func _apply_enemy_scaling() -> void:
	var enemy_data := StageData.ENEMY_DATA.get(enemy_type, {})
	var multiplier: float = enemy_data.get("stat_multiplier", 1.0)
	var scale_factor := StageManager.get_difficulty_scale()

	max_hp *= multiplier * scale_factor
	current_hp = max_hp
	atk *= multiplier * scale_factor
	def *= multiplier * scale_factor
	spd *= multiplier
	rng *= multiplier


func _setup_ai_params() -> void:
	match enemy_type:
		StageData.EnemyType.GRUNT:
			aim_accuracy = 0.6
			fire_delay_min = 2.5
			fire_delay_max = 4.5
		StageData.EnemyType.HEAVY:
			aim_accuracy = 0.5
			fire_delay_min = 3.0
			fire_delay_max = 5.0
			move_chance = 0.1
		StageData.EnemyType.SNIPER:
			aim_accuracy = 0.85
			fire_delay_min = 3.5
			fire_delay_max = 5.5
			move_chance = 0.15
		StageData.EnemyType.SPEEDSTER:
			aim_accuracy = 0.5
			fire_delay_min = 1.5
			fire_delay_max = 3.0
			move_chance = 0.6
		StageData.EnemyType.SUB_BOSS:
			aim_accuracy = 0.75
			fire_delay_min = 2.0
			fire_delay_max = 3.5
			move_chance = 0.3
		StageData.EnemyType.BOSS:
			aim_accuracy = 0.85
			fire_delay_min = 1.5
			fire_delay_max = 2.5
			move_chance = 0.4


func _setup_visuals() -> void:
	var enemy_data := StageData.ENEMY_DATA.get(enemy_type, {})
	var color: Color = enemy_data.get("color", Color(0.45, 0.4, 0.35))
	facing_right = false  # Enemies face left by default

	body_node = Node2D.new()
	add_child(body_node)

	# Tank body
	var body_rect := ColorRect.new()
	body_rect.size = Vector2(56, 22)
	body_rect.position = Vector2(-28, -22)
	body_rect.color = color
	body_node.add_child(body_rect)

	# Turret
	var turret := ColorRect.new()
	turret.size = Vector2(26, 16)
	turret.position = Vector2(-12, -38)
	turret.color = color.darkened(0.15)
	body_node.add_child(turret)

	# Barrel
	barrel_node = Node2D.new()
	barrel_node.position = Vector2(-4, -30)
	body_node.add_child(barrel_node)

	var barrel_rect := ColorRect.new()
	barrel_rect.size = Vector2(32, 5)
	barrel_rect.position = Vector2(-32, -2.5)
	barrel_rect.color = color.darkened(0.3)
	barrel_node.add_child(barrel_rect)

	barrel_tip = Marker2D.new()
	barrel_tip.position = Vector2(-35, 0)
	barrel_node.add_child(barrel_tip)

	# Tracks
	var tracks := ColorRect.new()
	tracks.size = Vector2(60, 7)
	tracks.position = Vector2(-30, 0)
	tracks.color = color.darkened(0.4)
	body_node.add_child(tracks)

	# Wheels
	for i in range(4):
		var wheel := _create_wheel(5.5, color.darkened(0.5))
		wheel.position = Vector2(-20 + i * 14, 3)
		body_node.add_child(wheel)

	# Set barrel to face left
	barrel_node.rotation_degrees = -(180.0 + barrel_angle)


func _create_wheel(radius: float, color: Color) -> Polygon2D:
	var wheel := Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(12):
		var a := i * TAU / 12.0
		points.append(Vector2(cos(a), sin(a)) * radius)
	wheel.polygon = points
	wheel.color = color
	return wheel


func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	_find_player()

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	# AI movement
	ai_move_timer -= delta
	if ai_move_timer <= 0.0:
		ai_move_timer = randf_range(1.0, 3.0)
		if randf() < move_chance:
			ai_move_direction = [-1.0, 0.0, 1.0].pick_random()
		else:
			ai_move_direction = 0.0
	move_horizontal(ai_move_direction, delta)

	# AI aiming
	if player_ref and player_ref.is_alive:
		_aim_at_player(delta)

	# AI firing
	ai_fire_timer -= delta
	if ai_fire_timer <= 0.0 and player_ref and player_ref.is_alive:
		fire()
		ai_fire_timer = randf_range(fire_delay_min, fire_delay_max)


func _find_player() -> void:
	if player_ref and is_instance_valid(player_ref):
		return
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]


func _aim_at_player(delta: float) -> void:
	if not player_ref:
		return

	var to_player := player_ref.global_position - global_position
	var distance := to_player.length()

	# Simple ballistic aiming: calculate angle needed
	var target_angle := _calculate_firing_angle(to_player, distance)

	# Add inaccuracy
	target_angle += randf_range(-15.0, 15.0) * (1.0 - aim_accuracy)

	# Smoothly adjust barrel
	var angle_diff := target_angle - barrel_angle
	var adjust := sign(angle_diff) * minf(abs(angle_diff), 1.5) * delta * 60.0
	barrel_angle = clampf(barrel_angle + adjust, BARREL_MIN_ANGLE, BARREL_MAX_ANGLE)

	if barrel_node:
		var actual_angle := -(180.0 + barrel_angle) if not facing_right else barrel_angle
		barrel_node.rotation_degrees = actual_angle


func _calculate_firing_angle(to_target: Vector2, distance: float) -> float:
	# Simplified ballistic calculation
	var launch_speed := rng * 1.5
	var dx := abs(to_target.x)
	var dy := to_target.y

	# Use projectile motion formula
	var v2 := launch_speed * launch_speed
	var g := GRAVITY

	var discriminant := v2 * v2 - g * (g * dx * dx + 2.0 * dy * v2)
	if discriminant < 0:
		return -45.0  # Default angle if can't reach

	var angle := atan((v2 - sqrt(discriminant)) / (g * dx))
	return rad_to_deg(-angle)  # Negative because up is negative


func _die() -> void:
	super._die()
	StageManager.on_enemy_killed(self, enemy_type)
