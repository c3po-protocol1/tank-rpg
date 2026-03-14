class_name BattleController
extends Node2D

## Controls a single battle stage. Spawns terrain, player, enemies. Manages victory/defeat.

var terrain: TerrainSystem
var player: PlayerTank
var enemies: Array[EnemyTank] = []
var camera: Camera2D
var hud: CanvasLayer
var damage_number_container: Node2D

var stage_config: Dictionary = {}
var battle_active: bool = false
var stage_xp_earned: int = 0
var stage_enemies_killed: int = 0


func _ready() -> void:
	stage_config = StageManager.load_stage_config()
	_setup_background()
	_setup_parallax_clouds()
	_setup_terrain()
	_setup_camera()
	_spawn_player()
	_spawn_enemies()
	_setup_hud()
	_setup_damage_numbers()

	StageManager.all_enemies_defeated.connect(_on_stage_cleared)
	StageManager.enemy_killed.connect(_on_enemy_killed)

	# Fade in
	_fade_transition(true)
	battle_active = true


func _exit_tree() -> void:
	# Disconnect from autoload signals to prevent stale connections
	if StageManager.all_enemies_defeated.is_connected(_on_stage_cleared):
		StageManager.all_enemies_defeated.disconnect(_on_stage_cleared)
	if StageManager.enemy_killed.is_connected(_on_enemy_killed):
		StageManager.enemy_killed.disconnect(_on_enemy_killed)


func _setup_background() -> void:
	# Brown gradient background
	var bg_layer := CanvasLayer.new()
	bg_layer.layer = -10
	add_child(bg_layer)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.32, 0.25, 0.2)
	bg_layer.add_child(bg)

	# Sky gradient at top
	var sky := ColorRect.new()
	sky.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sky.custom_minimum_size.y = 350
	sky.color = Color(0.52, 0.45, 0.36)
	bg_layer.add_child(sky)


func _setup_parallax_clouds() -> void:
	# Simple parallax clouds (muted tan)
	var cloud_layer := CanvasLayer.new()
	cloud_layer.layer = -5
	cloud_layer.follow_viewport_enabled = true
	add_child(cloud_layer)

	var cloud_container := Control.new()
	cloud_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	cloud_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cloud_layer.add_child(cloud_container)

	for i in range(5):
		var cloud := Polygon2D.new()
		var pts: PackedVector2Array = []
		var cloud_w := randf_range(60.0, 120.0)
		var cloud_h := randf_range(20.0, 40.0)
		# Ellipse-ish shape
		for j in range(12):
			var angle := j * TAU / 12.0
			pts.append(Vector2(cos(angle) * cloud_w, sin(angle) * cloud_h))
		cloud.polygon = pts
		cloud.color = Color(0.58, 0.52, 0.44, 0.3)
		cloud.position = Vector2(randf_range(-100, 1400), randf_range(30, 200))
		cloud_container.add_child(cloud)

		# Slow drift animation
		var tween := cloud.create_tween().set_loops()
		var drift := randf_range(50.0, 120.0)
		var duration := randf_range(15.0, 30.0)
		tween.tween_property(cloud, "position:x", cloud.position.x + drift, duration)
		tween.tween_property(cloud, "position:x", cloud.position.x, duration)


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

	var surface_y := terrain.get_surface_y_at(200.0)
	player.position.y = surface_y

	player.tank_destroyed.connect(_on_player_destroyed)

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

		# Entry animation with staggered delay
		enemy.setup_entry(spawn_x, i * 0.4)


func _setup_damage_numbers() -> void:
	damage_number_container = Node2D.new()
	damage_number_container.name = "DamageNumbers"
	add_child(damage_number_container)

	# Connect damage signals from all tanks
	_connect_damage_signal(player)
	for enemy in enemies:
		_connect_damage_signal(enemy)


func _connect_damage_signal(tank: TankBase) -> void:
	if tank:
		tank.damage_dealt.connect(func(amount: float, pos: Vector2):
			_spawn_damage_number(amount, pos)
		)


func _spawn_damage_number(amount: float, world_pos: Vector2) -> void:
	var label := Label.new()
	label.text = "%d" % int(amount)
	label.add_theme_font_size_override("font_size", 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Color based on damage amount
	if amount >= 30:
		label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.15))
		label.add_theme_font_size_override("font_size", 26)
	elif amount >= 15:
		label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2))
	else:
		label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))

	label.global_position = world_pos + Vector2(randf_range(-15, 15), 0)
	add_child(label)

	var tween := label.create_tween()
	tween.tween_property(label, "global_position:y", label.global_position.y - 50.0, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)


func _on_enemy_killed(_enemy: Node2D, xp: int) -> void:
	stage_xp_earned += xp
	stage_enemies_killed += 1


func _on_player_destroyed(_tank: TankBase) -> void:
	battle_active = false
	await get_tree().create_timer(1.5).timeout
	_show_game_over()


func _on_stage_cleared() -> void:
	battle_active = false
	SfxManager.play_stage_clear()
	await get_tree().create_timer(1.0).timeout
	_show_stage_clear()


func _show_stage_clear() -> void:
	var cleared_stage := StageManager.current_stage
	GameManager.complete_stage()

	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	canvas.add_child(overlay)

	# Fade in overlay
	var fade := overlay.create_tween()
	fade.tween_property(overlay, "color:a", 0.6, 0.3)

	# Content panel
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(450, 350)
	panel.position -= panel.custom_minimum_size / 2
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.18, 0.15, 0.12, 0.95)
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.border_color = Color(0.6, 0.5, 0.3)
	panel_style.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel", panel_style)
	overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "STAGE %d CLEAR!" % cleared_stage
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.5))
	vbox.add_child(title)

	# Stats summary
	var stats_text := "Enemies Defeated: %d\nXP Earned: %d\nLevel: %d" % [stage_enemies_killed, stage_xp_earned, PlayerData.level]
	var stats := Label.new()
	stats.text = stats_text
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 18)
	stats.add_theme_color_override("font_color", Color(0.8, 0.7, 0.55))
	vbox.add_child(stats)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 10
	vbox.add_child(spacer)

	# Buttons
	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 20)
	vbox.add_child(button_row)

	var next_btn := _create_styled_button("Next Stage", Color(0.35, 0.5, 0.3))
	next_btn.pressed.connect(func():
		_fade_transition(false)
		await get_tree().create_timer(0.4).timeout
		GameManager.advance_to_next_stage()
	)
	button_row.add_child(next_btn)

	var upgrade_btn := _create_styled_button("Upgrade", Color(0.5, 0.4, 0.25))
	upgrade_btn.pressed.connect(func():
		_fade_transition(false)
		await get_tree().create_timer(0.4).timeout
		GameManager.open_upgrade_screen()
	)
	button_row.add_child(upgrade_btn)


func _show_game_over() -> void:
	GameManager.trigger_game_over()

	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.1, 0.03, 0.03, 0.0)
	canvas.add_child(overlay)

	var fade := overlay.create_tween()
	fade.tween_property(overlay, "color:a", 0.75, 0.3)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(420, 320)
	panel.position -= panel.custom_minimum_size / 2
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.08, 0.08, 0.95)
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.border_color = Color(0.6, 0.2, 0.15)
	panel_style.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel", panel_style)
	overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "GAME OVER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.9, 0.25, 0.15))
	vbox.add_child(title)

	var stats := Label.new()
	stats.text = "Stage: %d | Level: %d\nEnemies Defeated: %d" % [StageManager.current_stage, PlayerData.level, stage_enemies_killed]
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 16)
	stats.add_theme_color_override("font_color", Color(0.7, 0.55, 0.5))
	vbox.add_child(stats)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 15
	vbox.add_child(spacer)

	var button_col := VBoxContainer.new()
	button_col.alignment = BoxContainer.ALIGNMENT_CENTER
	button_col.add_theme_constant_override("separation", 10)
	vbox.add_child(button_col)

	var retry_btn := _create_styled_button("Retry Stage", Color(0.5, 0.35, 0.2))
	retry_btn.pressed.connect(func():
		PlayerData.heal_full()
		_fade_transition(false)
		await get_tree().create_timer(0.4).timeout
		GameManager.start_stage(StageManager.current_stage)
	)
	button_col.add_child(retry_btn)

	var menu_btn := _create_styled_button("Main Menu", Color(0.35, 0.3, 0.25))
	menu_btn.pressed.connect(func():
		_fade_transition(false)
		await get_tree().create_timer(0.4).timeout
		GameManager.return_to_menu()
	)
	button_col.add_child(menu_btn)


func _create_styled_button(text: String, color: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(180, 50)
	btn.add_theme_font_size_override("font_size", 18)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	var hover := StyleBoxFlat.new()
	hover.bg_color = color.lightened(0.15)
	hover.corner_radius_top_left = 8
	hover.corner_radius_top_right = 8
	hover.corner_radius_bottom_left = 8
	hover.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("hover", hover)
	btn.pressed.connect(func(): SfxManager.play_button_click())
	return btn


func _fade_transition(fade_in: bool) -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 20
	add_child(canvas)

	var fade_rect := ColorRect.new()
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(fade_rect)

	if fade_in:
		fade_rect.color = Color(0.0, 0.0, 0.0, 1.0)
		var tween := fade_rect.create_tween()
		tween.tween_property(fade_rect, "color:a", 0.0, 0.4)
		tween.tween_callback(canvas.queue_free)
	else:
		fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
		var tween := fade_rect.create_tween()
		tween.tween_property(fade_rect, "color:a", 1.0, 0.4)


func _setup_hud() -> void:
	hud = preload("res://scenes/ui/hud.tscn").instantiate()
	add_child(hud)
	if hud.has_method("setup"):
		hud.setup(player)
