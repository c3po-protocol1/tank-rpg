class_name HudControls
extends RefCounted

## Builds and manages touch control buttons for the HUD.

static func build(root: Control, hud: HUD) -> void:
	# Left side: movement
	var left_panel := VBoxContainer.new()
	left_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	left_panel.position = Vector2(20, -180)
	left_panel.add_theme_constant_override("separation", 5)
	root.add_child(left_panel)

	var move_row := HBoxContainer.new()
	move_row.add_theme_constant_override("separation", 10)

	left_btn = create_button("<", Vector2(70, 70))
	left_btn.button_down.connect(func(): _on_move_btn(hud, -1.0))
	left_btn.button_up.connect(func(): _on_move_btn(hud, 0.0))
	move_row.add_child(left_btn)

	right_btn = create_button(">", Vector2(70, 70))
	right_btn.button_down.connect(func(): _on_move_btn(hud, 1.0))
	right_btn.button_up.connect(func(): _on_move_btn(hud, 0.0))
	move_row.add_child(right_btn)
	left_panel.add_child(move_row)

	# Right side: aim + fire + skill
	var right_panel := VBoxContainer.new()
	right_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	right_panel.position = Vector2(-200, -280)
	right_panel.add_theme_constant_override("separation", 5)
	root.add_child(right_panel)

	aim_up_btn = create_button("^", Vector2(70, 50))
	aim_up_btn.button_down.connect(func(): _on_aim_btn(hud, -1.0))
	aim_up_btn.button_up.connect(func(): _on_aim_btn(hud, 0.0))
	right_panel.add_child(aim_up_btn)

	aim_down_btn = create_button("v", Vector2(70, 50))
	aim_down_btn.button_down.connect(func(): _on_aim_btn(hud, 1.0))
	aim_down_btn.button_up.connect(func(): _on_aim_btn(hud, 0.0))
	right_panel.add_child(aim_down_btn)

	# Fire button
	fire_btn = create_button("FIRE", Vector2(120, 70))
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

	hud.skill_btn = Button.new()
	hud.skill_btn.text = "SKILL"
	hud.skill_btn.custom_minimum_size = Vector2(120, 55)
	hud.skill_btn.add_theme_font_size_override("font_size", 16)
	var skill_style := StyleBoxFlat.new()
	skill_style.bg_color = Color(0.2, 0.4, 0.55)
	skill_style.corner_radius_top_left = 8
	skill_style.corner_radius_top_right = 8
	skill_style.corner_radius_bottom_left = 8
	skill_style.corner_radius_bottom_right = 8
	hud.skill_btn.add_theme_stylebox_override("normal", skill_style)
	var skill_pressed_style := StyleBoxFlat.new()
	skill_pressed_style.bg_color = Color(0.3, 0.5, 0.65)
	skill_pressed_style.corner_radius_top_left = 8
	skill_pressed_style.corner_radius_top_right = 8
	skill_pressed_style.corner_radius_bottom_left = 8
	skill_pressed_style.corner_radius_bottom_right = 8
	hud.skill_btn.add_theme_stylebox_override("pressed", skill_pressed_style)
	var skill_disabled_style := StyleBoxFlat.new()
	skill_disabled_style.bg_color = Color(0.2, 0.25, 0.3, 0.5)
	skill_disabled_style.corner_radius_top_left = 8
	skill_disabled_style.corner_radius_top_right = 8
	skill_disabled_style.corner_radius_bottom_left = 8
	skill_disabled_style.corner_radius_bottom_right = 8
	hud.skill_btn.add_theme_stylebox_override("disabled", skill_disabled_style)
	hud.skill_btn.pressed.connect(_on_skill_pressed)
	skill_container.add_child(hud.skill_btn)

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


static func update_skill_button(hud: HUD) -> void:
	if hud.player_ref and hud.skill_btn:
		hud.skill_btn.text = hud.player_ref.get_skill_name()
		hud.skill_btn.tooltip_text = "%s (Cost: %d SP)" % [hud.player_ref.get_skill_name(), hud.player_ref.get_skill_cost()]


static func create_button(text: String, min_size: Vector2) -> Button:
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


static func _on_move_btn(hud, hud: HUD, direction: float) -> void:
	if hud.player_ref:
		hud.player_ref.set_touch_move(direction)


static func _on_aim_btn(hud, hud: HUD, direction: float) -> void:
	if hud.player_ref:
		hud.player_ref.set_touch_aim(direction)


static func _on_fire_pressed(hud: HUD) -> void:
	if hud.player_ref:
		hud.player_ref.touch_fire()


static func _on_skill_pressed(hud: HUD) -> void:
	if hud.player_ref:
		hud.player_ref.touch_skill()
		SfxManager.play_button_click()


