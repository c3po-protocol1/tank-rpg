class_name PlayerTank
extends TankBase

## Player-controlled tank with touch/keyboard input and class-specific visuals.

const AIM_SPEED := 2.0

# Touch control state
var touch_move_direction: float = 0.0
var touch_aim_direction: float = 0.0

# Wheel animation
var wheel_nodes: Array[Polygon2D] = []
var wheel_rotation: float = 0.0


func _ready() -> void:
	tank_class = PlayerData.tank_class
	tank_level = PlayerData.level
	super._ready()
	_apply_player_bonuses()
	add_to_group("player")

	# Sync HP/SP with PlayerData
	current_hp = PlayerData.current_hp if PlayerData.current_hp > 0 else max_hp
	current_sp = PlayerData.current_sp if PlayerData.current_sp > 0 else max_sp
	PlayerData.current_hp = current_hp
	PlayerData.current_sp = current_sp


func _apply_player_bonuses() -> void:
	max_hp = PlayerData.get_stat("hp")
	atk = PlayerData.get_stat("atk")
	def = PlayerData.get_stat("def")
	spd = PlayerData.get_stat("spd")
	rld = PlayerData.get_stat("rld")
	rng = PlayerData.get_stat("rng")
	max_sp = PlayerData.get_stat("sp")


func _setup_visuals() -> void:
	var class_data := TankClasses.get_class_data(tank_class)
	var color: Color = class_data.get("color", Color(0.55, 0.45, 0.35))

	body_node = Node2D.new()
	add_child(body_node)

	match tank_class:
		TankClasses.ClassType.DEALER:
			_build_dealer_visual(color)
		TankClasses.ClassType.TANKER:
			_build_tanker_visual(color)
		TankClasses.ClassType.SUPPORT:
			_build_support_visual(color)
		TankClasses.ClassType.ARTILLERY:
			_build_artillery_visual(color)
		TankClasses.ClassType.SCOUT:
			_build_scout_visual(color)
		_:
			_build_basic_visual(color)

	barrel_node.rotation_degrees = barrel_angle


func _build_basic_visual(color: Color) -> void:
	# Standard medium tank with rounded body
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-28, -5), Vector2(-25, -20), Vector2(-15, -24),
		Vector2(15, -24), Vector2(25, -20), Vector2(28, -5),
		Vector2(30, 0), Vector2(-30, 0)
	])
	body.color = color
	body_node.add_child(body)

	# Turret
	var turret := Polygon2D.new()
	turret.polygon = PackedVector2Array([
		Vector2(-12, -24), Vector2(-10, -40), Vector2(-4, -42),
		Vector2(10, -42), Vector2(14, -40), Vector2(16, -24)
	])
	turret.color = color.darkened(0.15)
	body_node.add_child(turret)

	_build_barrel(color, Vector2(8, -33), Vector2(35, 6), Vector2(38, 0))
	_build_tracks_and_wheels(color, 64, 4, -22, 15)


func _build_dealer_visual(color: Color) -> void:
	# Sleek body, long barrel
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-30, -3), Vector2(-26, -18), Vector2(-10, -22),
		Vector2(18, -22), Vector2(28, -16), Vector2(32, -3),
		Vector2(32, 0), Vector2(-30, 0)
	])
	body.color = color
	body_node.add_child(body)

	var turret := Polygon2D.new()
	turret.polygon = PackedVector2Array([
		Vector2(-8, -22), Vector2(-5, -38), Vector2(2, -40),
		Vector2(12, -40), Vector2(16, -36), Vector2(18, -22)
	])
	turret.color = color.darkened(0.15)
	body_node.add_child(turret)

	_build_barrel(color, Vector2(8, -33), Vector2(45, 5), Vector2(48, 0))
	_build_tracks_and_wheels(color, 66, 4, -24, 16)


func _build_tanker_visual(color: Color) -> void:
	# Wide, bulky, thick armor
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-35, -5), Vector2(-32, -22), Vector2(-20, -28),
		Vector2(20, -28), Vector2(32, -22), Vector2(35, -5),
		Vector2(36, 0), Vector2(-36, 0)
	])
	body.color = color
	body_node.add_child(body)

	# Armor plates
	var plate := Polygon2D.new()
	plate.polygon = PackedVector2Array([
		Vector2(-36, -2), Vector2(-38, -18), Vector2(-32, -22), Vector2(-32, -2)
	])
	plate.color = color.darkened(0.1)
	body_node.add_child(plate)

	var plate2 := Polygon2D.new()
	plate2.polygon = PackedVector2Array([
		Vector2(32, -2), Vector2(32, -22), Vector2(38, -18), Vector2(36, -2)
	])
	plate2.color = color.darkened(0.1)
	body_node.add_child(plate2)

	var turret := Polygon2D.new()
	turret.polygon = PackedVector2Array([
		Vector2(-14, -28), Vector2(-12, -44), Vector2(-4, -46),
		Vector2(10, -46), Vector2(16, -44), Vector2(18, -28)
	])
	turret.color = color.darkened(0.15)
	body_node.add_child(turret)

	_build_barrel(color, Vector2(8, -37), Vector2(32, 7), Vector2(35, 0))
	_build_tracks_and_wheels(color, 74, 5, -28, 14)


func _build_support_visual(color: Color) -> void:
	# Standard body with antenna/dish and cross
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-26, -5), Vector2(-23, -20), Vector2(-12, -24),
		Vector2(12, -24), Vector2(23, -20), Vector2(26, -5),
		Vector2(28, 0), Vector2(-28, 0)
	])
	body.color = color
	body_node.add_child(body)

	var turret := Polygon2D.new()
	turret.polygon = PackedVector2Array([
		Vector2(-10, -24), Vector2(-8, -38), Vector2(-2, -40),
		Vector2(8, -40), Vector2(12, -38), Vector2(14, -24)
	])
	turret.color = color.darkened(0.15)
	body_node.add_child(turret)

	# Antenna
	var antenna := Line2D.new()
	antenna.add_point(Vector2(0, -40))
	antenna.add_point(Vector2(0, -56))
	antenna.width = 2.0
	antenna.default_color = color.darkened(0.3)
	body_node.add_child(antenna)

	# Dish/circle on top
	var dish := Polygon2D.new()
	var pts: PackedVector2Array = []
	for i in range(8):
		var angle := i * TAU / 8.0
		pts.append(Vector2(cos(angle), sin(angle)) * 5.0)
	dish.polygon = pts
	dish.color = Color(0.8, 0.8, 0.8)
	dish.position = Vector2(0, -56)
	body_node.add_child(dish)

	# Cross symbol
	var cross := Polygon2D.new()
	cross.polygon = PackedVector2Array([
		Vector2(-1.5, -5), Vector2(1.5, -5), Vector2(1.5, -1.5),
		Vector2(5, -1.5), Vector2(5, 1.5), Vector2(1.5, 1.5),
		Vector2(1.5, 5), Vector2(-1.5, 5), Vector2(-1.5, 1.5),
		Vector2(-5, 1.5), Vector2(-5, -1.5), Vector2(-1.5, -1.5)
	])
	cross.color = Color(0.9, 0.2, 0.2)
	cross.position = Vector2(0, -32)
	body_node.add_child(cross)

	_build_barrel(color, Vector2(8, -33), Vector2(30, 5), Vector2(33, 0))
	_build_tracks_and_wheels(color, 58, 4, -20, 14)


func _build_artillery_visual(color: Color) -> void:
	# Wide base, very long barrel angled high
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-34, -5), Vector2(-30, -18), Vector2(-16, -22),
		Vector2(16, -22), Vector2(30, -18), Vector2(34, -5),
		Vector2(36, 0), Vector2(-36, 0)
	])
	body.color = color
	body_node.add_child(body)

	var turret := Polygon2D.new()
	turret.polygon = PackedVector2Array([
		Vector2(-8, -22), Vector2(-6, -36), Vector2(0, -38),
		Vector2(10, -38), Vector2(14, -36), Vector2(16, -22)
	])
	turret.color = color.darkened(0.15)
	body_node.add_child(turret)

	_build_barrel(color, Vector2(6, -32), Vector2(50, 6), Vector2(53, 0))
	_build_tracks_and_wheels(color, 72, 5, -26, 14)


func _build_scout_visual(color: Color) -> void:
	# Small, low profile
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-22, -3), Vector2(-18, -14), Vector2(-8, -17),
		Vector2(12, -17), Vector2(20, -14), Vector2(24, -3),
		Vector2(24, 0), Vector2(-22, 0)
	])
	body.color = color
	body_node.add_child(body)

	var turret := Polygon2D.new()
	turret.polygon = PackedVector2Array([
		Vector2(-6, -17), Vector2(-4, -28), Vector2(0, -30),
		Vector2(8, -30), Vector2(10, -28), Vector2(12, -17)
	])
	turret.color = color.darkened(0.15)
	body_node.add_child(turret)

	_build_barrel(color, Vector2(6, -24), Vector2(28, 4), Vector2(31, 0))
	_build_tracks_and_wheels(color, 48, 3, -16, 12)


func _build_barrel(color: Color, pivot: Vector2, size: Vector2, tip_pos: Vector2) -> void:
	barrel_node = Node2D.new()
	barrel_node.position = pivot
	body_node.add_child(barrel_node)

	var barrel_rect := Polygon2D.new()
	barrel_rect.polygon = PackedVector2Array([
		Vector2(0, -size.y / 2), Vector2(size.x, -size.y / 2 + 1),
		Vector2(size.x, size.y / 2 - 1), Vector2(0, size.y / 2)
	])
	barrel_rect.color = color.darkened(0.3)
	barrel_node.add_child(barrel_rect)

	barrel_tip = Marker2D.new()
	barrel_tip.position = tip_pos
	barrel_node.add_child(barrel_tip)


func _build_tracks_and_wheels(color: Color, track_w: float, wheel_count: int, start_x: float, spacing: float) -> void:
	var tracks := Polygon2D.new()
	var hw := track_w / 2.0
	tracks.polygon = PackedVector2Array([
		Vector2(-hw, 0), Vector2(hw, 0), Vector2(hw, 8), Vector2(-hw, 8)
	])
	tracks.color = color.darkened(0.4)
	body_node.add_child(tracks)

	wheel_nodes.clear()
	for i in range(wheel_count):
		var wheel := _create_wheel(6.0, color.darkened(0.5))
		wheel.position = Vector2(start_x + i * spacing, 4)
		body_node.add_child(wheel)
		wheel_nodes.append(wheel)


func _create_wheel(radius: float, color: Color) -> Polygon2D:
	var wheel := Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(12):
		var angle := i * TAU / 12.0
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	wheel.polygon = points
	wheel.color = color
	return wheel


func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	# Keyboard input
	var move_dir := Input.get_axis("move_left", "move_right")
	if touch_move_direction != 0.0:
		move_dir = touch_move_direction

	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	move_horizontal(move_dir, delta)

	# Animate wheels
	if abs(move_dir) > 0.01:
		wheel_rotation += move_dir * delta * 5.0
		for wheel in wheel_nodes:
			wheel.rotation = wheel_rotation

	# Aiming
	var aim_dir := Input.get_axis("aim_up", "aim_down")
	if touch_aim_direction != 0.0:
		aim_dir = touch_aim_direction
	if aim_dir != 0.0:
		aim(aim_dir * AIM_SPEED, delta)

	# Fire with keyboard
	if Input.is_action_just_pressed("fire"):
		fire()

	# Skill with keyboard
	if Input.is_action_just_pressed("use_skill"):
		use_skill()


func _process(delta: float) -> void:
	super._process(delta)
	# Sync HP/SP back to PlayerData
	PlayerData.current_hp = current_hp
	PlayerData.current_sp = current_sp


# Touch control interface (called by HUD buttons)
func set_touch_move(direction: float) -> void:
	touch_move_direction = direction

func set_touch_aim(direction: float) -> void:
	touch_aim_direction = direction

func touch_fire() -> void:
	fire()

func touch_skill() -> void:
	use_skill()
