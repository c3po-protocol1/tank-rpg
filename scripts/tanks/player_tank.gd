class_name PlayerTank
extends TankBase

## Player-controlled tank with keyboard/touch input.

const AIM_SPEED := 2.0

var touch_move_direction: float = 0.0
var touch_aim_direction: float = 0.0


func _ready() -> void:
	tank_class = PlayerData.tank_class
	tank_level = PlayerData.level
	super._ready()
	_apply_player_bonuses()
	add_to_group("player")
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
	PlayerVisuals.setup(self)


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	var move_dir := Input.get_axis("move_left", "move_right")
	if touch_move_direction != 0.0:
		move_dir = touch_move_direction
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
	move_horizontal(move_dir, delta)
	var aim_dir := Input.get_axis("aim_up", "aim_down")
	if touch_aim_direction != 0.0:
		aim_dir = touch_aim_direction
	if aim_dir != 0.0:
		aim(aim_dir * AIM_SPEED, delta)
	# Fire: F key (press once = charge, press again = shoot)
	if Input.is_action_just_pressed("fire"):
		fire_press()
	# Switch bullet: D key
	if Input.is_action_just_pressed("switch_bullet"):
		switch_bullet()
	# Skill: S key
	if Input.is_action_just_pressed("use_skill"):
		use_skill()


func _process(_delta: float) -> void:
	PlayerData.current_hp = current_hp
	PlayerData.current_sp = current_sp


func set_touch_move(direction: float) -> void:
	touch_move_direction = direction

func set_touch_aim(direction: float) -> void:
	touch_aim_direction = direction

func touch_fire() -> void:
	fire_press()

func touch_switch() -> void:
	switch_bullet()

func touch_skill() -> void:
	use_skill()
