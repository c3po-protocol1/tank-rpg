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

	hud.left_btn = create_button("<", Vector2(70, 70))
	hud.left_btn.button_down.connect(func() -> void: _on_move_btn(hud, -1.0))
	hud.left_btn.button_up.connect(func() -> void: _on_move_btn(hud, 0.0))
	move_row.add_child(hud.left_btn)

	hud.right_btn = create_button(">", Vector2(70, 70))
	hud.right_btn.button_down.connect(func() -> void: _on_move_btn(hud, 1.0))
	hud.right_btn.button_up.connect(func() -> void: _on_move_btn(hud, 0.0))
	move_row.add_child(hud.right_btn)
	left_panel.add_child(move_row)

	# Right side: aim + fire + skill
	var right_panel := VBoxContainer.new()
	right_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	right_panel.position = Vector2(-200, -280)
	right_panel.add_theme_constant_override("separation", 5)
	root.add_child(right_panel)

	hud.aim_up_btn = create_button("^", Vector2(70, 50))
	hud.aim_up_btn.button_down.connect(func() -> void: _on_aim_btn(hud, -1.0))
	hud.aim_up_btn.button_up.connect(func() -> void: _on_aim_btn(hud, 0.0))
	right_panel.add_child(hud.aim_up_btn)

	hud.aim_down_btn = create_button("v", Vector2(70, 50))
	hud.aim_down_btn.button_down.connect(func() -> void: _on_aim_btn(hud, 1.0))
	hud.aim_down_btn.button_up.connect(func() -> void: _on_aim_btn(hud, 0.0))
	right_panel.add_child(hud.aim_down_btn)

	# Fire button
	hud.fire_btn = create_button("FIRE", Vector2(120, 70))
	hud.fire_btn.add_theme_font_size_override("font_size", 20)
	var fire_style := StyleBoxFlat.new()
	fire_style.bg_color = Color(0.7, 0.25, 0.15)
	fire_style.corner_radius_top_left = 8
	fire_style.corner_radius_top_right = 8
	fire_style.corner_radius_bottom_left = 8
	fire_style.corner_radius_bottom_right = 8
	hud.fire_btn.add_theme_stylebox_override("normal", fire_style)
	hud.fire_btn.pressed.connect(func() -> void: _on_fire_pressed(hud))
	right_panel.add_child(hud.fire_btn)

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
	hud.skill_btn.pressed.connect(func() -> void: _on_skill_pressed(hud))
	skill_container.add_child(hud.skill_btn)

	# Cooldown overlay label
	hud.skill_cooldown_label = Label.new()
	hud.skill_cooldown_label.text = ""
	hud.skill_cooldown_label.visible = false
	hud.skill_cooldown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.skill_cooldown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud.skill_cooldown_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.skill_cooldown_label.add_theme_font_size_override("font_size", 18)
	hud.skill_cooldown_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	skill_container.add_child(hud.skill_cooldown_label)


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


static func _on_move_btn(hud: HUD, direction: float) -> void:
	if hud.player_ref:
		hud.player_ref.set_touch_move(direction)


static func _on_aim_btn(hud: HUD, direction: float) -> void:
	if hud.player_ref:
		hud.player_ref.set_touch_aim(direction)


static func _on_fire_pressed(hud: HUD) -> void:
	if hud.player_ref:
		hud.player_ref.touch_fire()


static func _on_skill_pressed(hud: HUD) -> void:
	if hud.player_ref:
		hud.player_ref.touch_skill()
		SfxManager.play_button_click()
