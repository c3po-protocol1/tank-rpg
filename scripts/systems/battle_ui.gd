class_name BattleUI
extends RefCounted

## Static helper for battle screen overlays (victory, game over, transitions).

static func show_stage_clear(scene: Node, stage: int, xp: int, enemies_killed: int) -> void:
	GameManager.complete_stage()

	var canvas := CanvasLayer.new()
	canvas.layer = 10
	scene.add_child(canvas)

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
	title.text = "STAGE %d CLEAR!" % stage
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.5))
	vbox.add_child(title)

	# Stats summary
	var stats_text := "Enemies Defeated: %d\nXP Earned: %d\nLevel: %d" % [enemies_killed, xp, PlayerData.level]
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

	var next_btn := create_styled_button("Next Stage", Color(0.35, 0.5, 0.3))
	next_btn.pressed.connect(func() -> void:
		BattleUI.fade_transition(scene, false)
		await scene.get_tree().create_timer(0.4).timeout
		GameManager.advance_to_next_stage()
	)
	button_row.add_child(next_btn)

	var upgrade_btn := create_styled_button("Upgrade", Color(0.5, 0.4, 0.25))
	upgrade_btn.pressed.connect(func() -> void:
		BattleUI.fade_transition(scene, false)
		await scene.get_tree().create_timer(0.4).timeout
		GameManager.open_upgrade_screen()
	)
	button_row.add_child(upgrade_btn)

static func show_game_over(scene: Node, stage: int, enemies_killed: int) -> void:
	GameManager.trigger_game_over()

	var canvas := CanvasLayer.new()
	canvas.layer = 10
	scene.add_child(canvas)

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
	stats.text = "Stage: %d | Level: %d\nEnemies Defeated: %d" % [stage, PlayerData.level, enemies_killed]
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

	var retry_btn := create_styled_button("Retry Stage", Color(0.5, 0.35, 0.2))
	retry_btn.pressed.connect(func() -> void:
		PlayerData.heal_full()
		BattleUI.fade_transition(scene, false)
		await scene.get_tree().create_timer(0.4).timeout
		GameManager.start_stage(stage)
	)
	button_col.add_child(retry_btn)

	var menu_btn := create_styled_button("Main Menu", Color(0.35, 0.3, 0.25))
	menu_btn.pressed.connect(func() -> void:
		BattleUI.fade_transition(scene, false)
		await scene.get_tree().create_timer(0.4).timeout
		GameManager.return_to_menu()
	)
	button_col.add_child(menu_btn)

static func create_styled_button(text: String, color: Color) -> Button:
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
	btn.pressed.connect(func() -> void: SfxManager.play_button_click())
	return btn

static func fade_transition(scene: Node, fade_in: bool) -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 20
	scene.add_child(canvas)

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
