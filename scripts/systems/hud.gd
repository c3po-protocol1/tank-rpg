extends CanvasLayer

## Battle HUD: HP bar, SP bar, skill button, touch controls, stage info.

var player_ref: PlayerTank = null

# UI references
var hp_bar: ProgressBar
var sp_bar: ProgressBar
var hp_label: Label
var sp_label: Label
var stage_label: Label
var xp_bar: ProgressBar
var level_label: Label
var skill_btn: Button
var skill_cooldown_label: Label

# Touch buttons
var left_btn: Button
var right_btn: Button
var aim_up_btn: Button
var aim_down_btn: Button
var fire_btn: Button


func _ready() -> void:
	layer = 5
	_build_ui()


func setup(player: PlayerTank) -> void:
	player_ref = player
	if player_ref:
		player_ref.hp_changed.connect(_on_hp_changed)
		player_ref.sp_changed.connect(_on_sp_changed)
		_update_hp_display()
		_update_sp_display()
		_update_skill_button()
	PlayerData.xp_gained.connect(func(_amount): _update_xp_display())
	PlayerData.level_up.connect(func(_lvl):
		_update_level_display()
		SfxManager.play_level_up()
	)
	_update_stage_display()
	_update_level_display()
	_update_xp_display()


func _process(_delta: float) -> void:
	if player_ref and is_instance_valid(player_ref) and skill_btn:
		var on_cd := player_ref.skill_cooldown > 0.0
		var has_sp := player_ref.current_sp >= player_ref.get_skill_cost()
		skill_btn.disabled = on_cd or not has_sp
		if on_cd:
			skill_cooldown_label.text = "%.1f" % player_ref.skill_cooldown
			skill_cooldown_label.visible = true
		else:
			skill_cooldown_label.visible = false


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_build_top_bar(root)
	_build_touch_controls(root)


func _build_top_bar(root: Control) -> void:
	var top_panel := PanelContainer.new()
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.custom_minimum_size.y = 80
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.08, 0.8)
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	top_panel.add_theme_stylebox_override("panel", style)
	root.add_child(top_panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	top_panel.add_child(hbox)

	# HP Bar
	var hp_container := VBoxContainer.new()
	hp_container.custom_minimum_size.x = 200

	hp_label = Label.new()
	hp_label.text = "HP: 100/100"
	hp_label.add_theme_font_size_override("font_size", 14)
	hp_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	hp_container.add_child(hp_label)

	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(200, 16)
	hp_bar.max_value = 100
	hp_bar.value = 100
	hp_bar.show_percentage = false
	var hp_fill := StyleBoxFlat.new()
	hp_fill.bg_color = Color(0.45, 0.55, 0.25)  # Olive green
	hp_fill.corner_radius_top_left = 3
	hp_fill.corner_radius_top_right = 3
	hp_fill.corner_radius_bottom_left = 3
	hp_fill.corner_radius_bottom_right = 3
	hp_bar.add_theme_stylebox_override("fill", hp_fill)
	var hp_bg := StyleBoxFlat.new()
	hp_bg.bg_color = Color(0.5, 0.15, 0.1)
	hp_bg.corner_radius_top_left = 3
	hp_bg.corner_radius_top_right = 3
	hp_bg.corner_radius_bottom_left = 3
	hp_bg.corner_radius_bottom_right = 3
	hp_bar.add_theme_stylebox_override("background", hp_bg)
	hp_container.add_child(hp_bar)
	hbox.add_child(hp_container)

	# SP Bar
	var sp_container := VBoxContainer.new()
	sp_container.custom_minimum_size.x = 150

	sp_label = Label.new()
	sp_label.text = "SP: 50/50"
	sp_label.add_theme_font_size_override("font_size", 14)
	sp_label.add_theme_color_override("font_color", Color(0.5, 0.7, 0.8))
	sp_container.add_child(sp_label)

	sp_bar = ProgressBar.new()
	sp_bar.custom_minimum_size = Vector2(150, 16)
	sp_bar.max_value = 50
	sp_bar.value = 50
	sp_bar.show_percentage = false
	var sp_fill := StyleBoxFlat.new()
	sp_fill.bg_color = Color(0.25, 0.45, 0.55)  # Muted teal
	sp_fill.corner_radius_top_left = 3
	sp_fill.corner_radius_top_right = 3
	sp_fill.corner_radius_bottom_left = 3
	sp_fill.corner_radius_bottom_right = 3
	sp_bar.add_theme_stylebox_override("fill", sp_fill)
	var sp_bg := StyleBoxFlat.new()
	sp_bg.bg_color = Color(0.15, 0.2, 0.25)
	sp_bg.corner_radius_top_left = 3
	sp_bg.corner_radius_top_right = 3
	sp_bg.corner_radius_bottom_left = 3
	sp_bg.corner_radius_bottom_right = 3
	sp_bar.add_theme_stylebox_override("background", sp_bg)
	sp_container.add_child(sp_bar)
	hbox.add_child(sp_container)

	# Stage & Level info
	var info_container := VBoxContainer.new()

	stage_label = Label.new()
	stage_label.text = "Stage 1"
	stage_label.add_theme_font_size_override("font_size", 18)
	stage_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.6))
	info_container.add_child(stage_label)

	var level_row := HBoxContainer.new()
	level_label = Label.new()
	level_label.text = "Lv.1"
	level_label.add_theme_font_size_override("font_size", 14)
	level_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	level_row.add_child(level_label)

	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size = Vector2(100, 10)
	xp_bar.max_value = 100
	xp_bar.value = 0
	xp_bar.show_percentage = false
	var xp_fill := StyleBoxFlat.new()
	xp_fill.bg_color = Color(0.7, 0.6, 0.2)
	xp_fill.corner_radius_top_left = 2
	xp_fill.corner_radius_top_right = 2
	xp_fill.corner_radius_bottom_left = 2
	xp_fill.corner_radius_bottom_right = 2
	xp_bar.add_theme_stylebox_override("fill", xp_fill)
	level_row.add_child(xp_bar)
	info_container.add_child(level_row)
	hbox.add_child(info_container)


func _build_touch_controls(root: Control) -> void:
	# Left side: movement
	var left_panel := VBoxContainer.new()
	left_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	left_panel.position = Vector2(20, -180)
	left_panel.add_theme_constant_override("separation", 5)
	root.add_child(left_panel)

	var move_row := HBoxContainer.new()
	move_row.add_theme_constant_override("separation", 10)

	left_btn = _create_touch_button("<", Vector2(70, 70))
	left_btn.button_down.connect(func(): _on_move_btn(-1.0))
	left_btn.button_up.connect(func(): _on_move_btn(0.0))
	move_row.add_child(left_btn)

	right_btn = _create_touch_button(">", Vector2(70, 70))
	right_btn.button_down.connect(func(): _on_move_btn(1.0))
	right_btn.button_up.connect(func(): _on_move_btn(0.0))
	move_row.add_child(right_btn)
	left_panel.add_child(move_row)

	# Right side: aim + fire + skill
	var right_panel := VBoxContainer.new()
	right_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	right_panel.position = Vector2(-200, -280)
	right_panel.add_theme_constant_override("separation", 5)
	root.add_child(right_panel)

	aim_up_btn = _create_touch_button("^", Vector2(70, 50))
	aim_up_btn.button_down.connect(func(): _on_aim_btn(-1.0))
	aim_up_btn.button_up.connect(func(): _on_aim_btn(0.0))
	right_panel.add_child(aim_up_btn)

	aim_down_btn = _create_touch_button("v", Vector2(70, 50))
	aim_down_btn.button_down.connect(func(): _on_aim_btn(1.0))
	aim_down_btn.button_up.connect(func(): _on_aim_btn(0.0))
	right_panel.add_child(aim_down_btn)

	# Fire button
	fire_btn = _create_touch_button("FIRE", Vector2(120, 70))
	fire_btn.add_theme_font_size_override("font_size", 20)
	var fire_style := StyleBoxFlat.new()
	fire_style.bg_color = Color(0.7, 0.25, 0.15)
	fire_style.corner_radius_top_left = 8
	fire_style.corner_radius_top_right = 8
	fire_style.corner_radius_bottom_left = 8
	fire_style.corner_radius_bottom_right = 8
	fire_btn.add_theme_stylebox_override("normal", fire_style)
	fire_btn.pressed.connect(_on_fire_pressed)
	right_panel.add_child(fire_btn)

	# Skill button (next to fire)
	var skill_container := Control.new()
	skill_container.custom_minimum_size = Vector2(120, 55)
	right_panel.add_child(skill_container)

	skill_btn = Button.new()
	skill_btn.text = "SKILL"
	skill_btn.custom_minimum_size = Vector2(120, 55)
	skill_btn.add_theme_font_size_override("font_size", 16)
	var skill_style := StyleBoxFlat.new()
	skill_style.bg_color = Color(0.2, 0.4, 0.55)
	skill_style.corner_radius_top_left = 8
	skill_style.corner_radius_top_right = 8
	skill_style.corner_radius_bottom_left = 8
	skill_style.corner_radius_bottom_right = 8
	skill_btn.add_theme_stylebox_override("normal", skill_style)
	var skill_pressed_style := StyleBoxFlat.new()
	skill_pressed_style.bg_color = Color(0.3, 0.5, 0.65)
	skill_pressed_style.corner_radius_top_left = 8
	skill_pressed_style.corner_radius_top_right = 8
	skill_pressed_style.corner_radius_bottom_left = 8
	skill_pressed_style.corner_radius_bottom_right = 8
	skill_btn.add_theme_stylebox_override("pressed", skill_pressed_style)
	var skill_disabled_style := StyleBoxFlat.new()
	skill_disabled_style.bg_color = Color(0.2, 0.25, 0.3, 0.5)
	skill_disabled_style.corner_radius_top_left = 8
	skill_disabled_style.corner_radius_top_right = 8
	skill_disabled_style.corner_radius_bottom_left = 8
	skill_disabled_style.corner_radius_bottom_right = 8
	skill_btn.add_theme_stylebox_override("disabled", skill_disabled_style)
	skill_btn.pressed.connect(_on_skill_pressed)
	skill_container.add_child(skill_btn)

	# Cooldown overlay label
	skill_cooldown_label = Label.new()
	skill_cooldown_label.text = ""
	skill_cooldown_label.visible = false
	skill_cooldown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skill_cooldown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	skill_cooldown_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	skill_cooldown_label.add_theme_font_size_override("font_size", 18)
	skill_cooldown_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	skill_container.add_child(skill_cooldown_label)


func _update_skill_button() -> void:
	if player_ref and skill_btn:
		skill_btn.text = player_ref.get_skill_name()
		skill_btn.tooltip_text = "%s (Cost: %d SP)" % [player_ref.get_skill_name(), player_ref.get_skill_cost()]


func _create_touch_button(text: String, min_size: Vector2) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = min_size
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.25, 0.2, 0.8)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", style)
	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.5, 0.4, 0.3, 0.9)
	pressed_style.corner_radius_top_left = 6
	pressed_style.corner_radius_top_right = 6
	pressed_style.corner_radius_bottom_left = 6
	pressed_style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("pressed", pressed_style)
	return btn


func _on_move_btn(direction: float) -> void:
	if player_ref:
		player_ref.set_touch_move(direction)


func _on_aim_btn(direction: float) -> void:
	if player_ref:
		player_ref.set_touch_aim(direction)


func _on_fire_pressed() -> void:
	if player_ref:
		player_ref.touch_fire()


func _on_skill_pressed() -> void:
	if player_ref:
		player_ref.touch_skill()
		SfxManager.play_button_click()


func _on_hp_changed(_current: float, _max_val: float) -> void:
	_update_hp_display()


func _on_sp_changed(_current: float, _max_val: float) -> void:
	_update_sp_display()


func _update_hp_display() -> void:
	if not player_ref:
		return
	hp_bar.max_value = player_ref.max_hp
	hp_bar.value = player_ref.current_hp
	hp_label.text = "HP: %d/%d" % [int(player_ref.current_hp), int(player_ref.max_hp)]

	# Color gradient: green when full, red when low
	var ratio := player_ref.current_hp / player_ref.max_hp
	var fill_style := hp_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if fill_style:
		fill_style.bg_color = Color(0.6 * (1.0 - ratio) + 0.15, 0.55 * ratio, 0.1)


func _update_sp_display() -> void:
	if not player_ref:
		return
	sp_bar.max_value = player_ref.max_sp
	sp_bar.value = player_ref.current_sp
	sp_label.text = "SP: %d/%d" % [int(player_ref.current_sp), int(player_ref.max_sp)]


func _update_stage_display() -> void:
	stage_label.text = "Stage %d" % StageManager.current_stage


func _update_level_display() -> void:
	level_label.text = "Lv.%d" % PlayerData.level


func _update_xp_display() -> void:
	xp_bar.max_value = PlayerData.xp_to_next_level()
	xp_bar.value = PlayerData.xp
