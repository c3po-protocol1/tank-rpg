class_name PlayerTank
extends TankBase

## Player-controlled tank with touch/keyboard input.

const AIM_SPEED := 2.0  # Degrees per frame at 60fps

# Touch control state
var touch_move_direction: float = 0.0
var touch_aim_direction: float = 0.0


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

	# Tank body
	body_node = Node2D.new()
	add_child(body_node)

	var body_rect := ColorRect.new()
	body_rect.size = Vector2(60, 24)
	body_rect.position = Vector2(-30, -24)
	body_rect.color = color
	body_node.add_child(body_rect)

	# Turret
	var turret := ColorRect.new()
	turret.size = Vector2(30, 18)
	turret.position = Vector2(-8, -42)
	turret.color = color.darkened(0.15)
	body_node.add_child(turret)

	# Barrel
	barrel_node = Node2D.new()
	barrel_node.position = Vector2(8, -33)
	body_node.add_child(barrel_node)

	var barrel_rect := ColorRect.new()
	barrel_rect.size = Vector2(35, 6)
	barrel_rect.position = Vector2(0, -3)
	barrel_rect.color = color.darkened(0.3)
	barrel_node.add_child(barrel_rect)

	# Barrel tip marker
	barrel_tip = Marker2D.new()
	barrel_tip.position = Vector2(38, 0)
	barrel_node.add_child(barrel_tip)

	# Tracks
	var tracks := ColorRect.new()
	tracks.size = Vector2(64, 8)
	tracks.position = Vector2(-32, 0)
	tracks.color = color.darkened(0.4)
	body_node.add_child(tracks)

	# Wheels (circles via polygons)
	for i in range(4):
		var wheel := _create_wheel(6.0, color.darkened(0.5))
		wheel.position = Vector2(-22 + i * 15, 4)
		body_node.add_child(wheel)

	barrel_node.rotation_degrees = barrel_angle


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
	# Touch input overrides keyboard
	if touch_move_direction != 0.0:
		move_dir = touch_move_direction

	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	move_horizontal(move_dir, delta)

	# Aiming
	var aim_dir := Input.get_axis("aim_up", "aim_down")
	if touch_aim_direction != 0.0:
		aim_dir = touch_aim_direction
	if aim_dir != 0.0:
		aim(aim_dir * AIM_SPEED, delta)

	# Fire with keyboard
	if Input.is_action_just_pressed("fire"):
		fire()


func _process(_delta: float) -> void:
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
