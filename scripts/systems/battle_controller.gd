class_name BattleController
extends Node2D

## Controls a single battle stage. Spawns terrain, player, enemies, and manages victory/defeat.

var terrain: TerrainSystem
var player: PlayerTank
var enemies: Array[EnemyTank] = []
var camera: Camera2D
var hud: CanvasLayer

var stage_config: Dictionary = {}
var battle_active: bool = false


func _ready() -> void:
	stage_config = StageManager.load_stage_config()
	_setup_background()
	_setup_terrain()
	_setup_camera()
	_spawn_player()
	_spawn_enemies()
	_setup_hud()

	StageManager.all_enemies_defeated.connect(_on_stage_cleared)
	battle_active = true


func _setup_background() -> void:
	# Blurry brownish background gradient
	var bg := ColorRect.new()
	bg.z_index = -10
	bg.size = Vector2(3000, 1500)
	bg.position = Vector2(-500, -500)
	bg.color = Color(0.35, 0.28, 0.22)
	add_child(bg)

	# Sky gradient (lighter brown at top)
	var sky := ColorRect.new()
	sky.z_index = -9
	sky.size = Vector2(3000, 400)
	sky.position = Vector2(-500, -500)
	sky.color = Color(0.55, 0.48, 0.38)
	add_child(sky)


func _setup_terrain() -> void:
	terrain = TerrainSystem.new()
	terrain.position = Vector2.ZERO
	add_child(terrain)
	var preset: String = stage_config.get("terrain", "gentle_hills")
	terrain.generate_terrain(preset)


func _setup_camera() -> void:
	camera = Camera2D.new()
	camera.zoom = Vector2(1.0, 1.0)
	camera.limit_left = -100
	camera.limit_right = 2600
	camera.limit_top = -200
	camera.limit_bottom = 800
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	add_child(camera)


func _spawn_player() -> void:
	player = PlayerTank.new()
	player.position = Vector2(200, 0)
	add_child(player)

	# Place on terrain surface
	var surface_y := terrain.get_surface_y_at(200.0)
	player.position.y = surface_y

	player.tank_destroyed.connect(_on_player_destroyed)

	# Camera follows player
	camera.reparent(player)
	camera.position = Vector2(100, -80)


func _spawn_enemies() -> void:
	var enemy_configs: Array = stage_config.get("enemies", [])
	var spawn_start_x := 800.0
	var spawn_spacing := 200.0

	for i in range(enemy_configs.size()):
		var config: Dictionary = enemy_configs[i]
		var enemy := EnemyTank.new()
		enemy.enemy_type = config.get("type", StageData.EnemyType.GRUNT)
		enemy.tank_level = config.get("level", 1)

		var spawn_x := spawn_start_x + i * spawn_spacing
		var surface_y := terrain.get_surface_y_at(spawn_x)
		enemy.position = Vector2(spawn_x, surface_y)

		add_child(enemy)
		enemies.append(enemy)


func _on_player_destroyed(_tank: TankBase) -> void:
	battle_active = false
	# Show game over after brief delay
	await get_tree().create_timer(1.5).timeout
	_show_game_over()


func _on_stage_cleared() -> void:
	battle_active = false
	# Brief delay then show results
	await get_tree().create_timer(1.0).timeout
	_show_stage_clear()


func _show_stage_clear() -> void:
	GameManager.complete_stage()
	# Show stage clear UI overlay
	var overlay := ColorRect.new()
	overlay.size = get_viewport().get_visible_rect().size
	overlay.color = Color(0.0, 0.0, 0.0, 0.5)

	var label := Label.new()
	label.text = "STAGE %d CLEAR!" % StageManager.current_stage
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.6))
	label.size = overlay.size
	overlay.add_child(label)

	# Buttons
	var button_container := HBoxContainer.new()
	button_container.position = Vector2(overlay.size.x / 2 - 200, overlay.size.y / 2 + 60)
	button_container.add_theme_constant_override("separation", 20)
	overlay.add_child(button_container)

	var next_btn := Button.new()
	next_btn.text = "Next Stage"
	next_btn.custom_minimum_size = Vector2(180, 50)
	next_btn.pressed.connect(func(): GameManager.advance_to_next_stage())
	button_container.add_child(next_btn)

	var upgrade_btn := Button.new()
	upgrade_btn.text = "Upgrade"
	upgrade_btn.custom_minimum_size = Vector2(180, 50)
	upgrade_btn.pressed.connect(func(): GameManager.open_upgrade_screen())
	button_container.add_child(upgrade_btn)

	var canvas := CanvasLayer.new()
	canvas.layer = 10
	canvas.add_child(overlay)
	add_child(canvas)


func _show_game_over() -> void:
	GameManager.trigger_game_over()
	var overlay := ColorRect.new()
	overlay.size = get_viewport().get_visible_rect().size
	overlay.color = Color(0.15, 0.05, 0.05, 0.7)

	var label := Label.new()
	label.text = "GAME OVER"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 56)
	label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.2))
	label.size = overlay.size
	overlay.add_child(label)

	var retry_btn := Button.new()
	retry_btn.text = "Retry Stage"
	retry_btn.custom_minimum_size = Vector2(200, 50)
	retry_btn.position = Vector2(overlay.size.x / 2 - 100, overlay.size.y / 2 + 60)
	retry_btn.pressed.connect(func():
		PlayerData.heal_full()
		GameManager.start_stage(StageManager.current_stage)
	)
	overlay.add_child(retry_btn)

	var menu_btn := Button.new()
	menu_btn.text = "Main Menu"
	menu_btn.custom_minimum_size = Vector2(200, 50)
	menu_btn.position = Vector2(overlay.size.x / 2 - 100, overlay.size.y / 2 + 130)
	menu_btn.pressed.connect(func(): GameManager.return_to_menu())
	overlay.add_child(menu_btn)

	var canvas := CanvasLayer.new()
	canvas.layer = 10
	canvas.add_child(overlay)
	add_child(canvas)


func _setup_hud() -> void:
	hud = preload("res://scenes/ui/hud.tscn").instantiate()
	add_child(hud)
	# Connect HUD to player
	if hud.has_method("setup"):
		hud.setup(player)
