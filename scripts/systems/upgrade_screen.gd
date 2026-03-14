extends Control

## Between-stage upgrade screen with visual polish. Spend stat points and change class.

var stat_labels: Dictionary = {}
var stat_buttons: Dictionary = {}
var points_label: Label


func _ready() -> void:
	_build_ui()
	_refresh()


func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0.16, 0.13, 0.11)
	add_child(bg)

	# Decorative header bar
	var header := ColorRect.new()
	header.set_anchors_preset(PRESET_TOP_WIDE)
	header.custom_minimum_size.y = 4
	header.color = Color(0.6, 0.5, 0.3)
	add_child(header)

	var main_panel := PanelContainer.new()
	main_panel.set_anchors_preset(PRESET_FULL_RECT)
	main_panel.set_anchor_and_offset(SIDE_LEFT, 0.08, 0)
	main_panel.set_anchor_and_offset(SIDE_RIGHT, 0.92, 0)
	main_panel.set_anchor_and_offset(SIDE_TOP, 0.03, 0)
	main_panel.set_anchor_and_offset(SIDE_BOTTOM, 0.97, 0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.14, 0.12, 0.1, 0.9)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	panel_style.border_color = Color(0.5, 0.4, 0.3, 0.5)
	panel_style.set_border_width_all(1)
	panel_style.content_margin_left = 20
	panel_style.content_margin_right = 20
	panel_style.content_margin_top = 10
	panel_style.content_margin_bottom = 10
	main_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(main_panel)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 8)
	main_panel.add_child(main_vbox)

	# Title
	var title := Label.new()
	title.text = "UPGRADE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.6))
	main_vbox.add_child(title)

	# Class and level info
	var class_data := TankClasses.get_class_data(PlayerData.tank_class)
	var info_label := Label.new()
	info_label.text = "%s - Level %d" % [class_data["name"], PlayerData.level]
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.add_theme_font_size_override("font_size", 20)
	info_label.add_theme_color_override("font_color", Color(0.8, 0.7, 0.55))
	main_vbox.add_child(info_label)

	# Stat points
	points_label = Label.new()
	points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	points_label.add_theme_font_size_override("font_size", 22)
	points_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
	main_vbox.add_child(points_label)

	# Stat upgrade rows
	var stats_container := VBoxContainer.new()
	stats_container.add_theme_constant_override("separation", 6)
	main_vbox.add_child(stats_container)

	var stat_names := {
		"hp": "HP (Health)",
		"atk": "ATK (Attack)",
		"def": "DEF (Defense)",
		"spd": "SPD (Speed)",
		"rld": "RLD (Reload)",
		"rng": "RNG (Range)",
		"sp": "SP (Skill Points)",
	}

	for stat_key in stat_names:
		var row := _create_stat_row(stat_key, stat_names[stat_key])
		stats_container.add_child(row)

	# Bottom buttons
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	main_vbox.add_child(btn_row)

	if TankClasses.can_evolve(PlayerData.tank_class, PlayerData.level):
		var class_btn := _create_styled_button("Change Class", Color(0.5, 0.35, 0.5))
		class_btn.pressed.connect(_show_class_select)
		btn_row.add_child(class_btn)

	var continue_btn := _create_styled_button("Continue", Color(0.35, 0.5, 0.3))
	continue_btn.pressed.connect(func():
		SfxManager.play_button_click()
		GameManager.advance_to_next_stage()
	)
	btn_row.add_child(continue_btn)


func _create_stat_row(stat_key: String, display_name: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var name_label := Label.new()
	name_label.text = display_name
	name_label.custom_minimum_size.x = 180
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(0.8, 0.7, 0.6))
	row.add_child(name_label)

	var value_label := Label.new()
	value_label.custom_minimum_size.x = 80
	value_label.add_theme_font_size_override("font_size", 16)
	value_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	row.add_child(value_label)
	stat_labels[stat_key] = value_label

	var cost := UpgradeTree.STAT_COSTS.get(stat_key, 1)
	var upgrade_btn := Button.new()
	upgrade_btn.text = "+ (%d)" % cost
	upgrade_btn.custom_minimum_size = Vector2(60, 35)
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.4, 0.35, 0.25)
	btn_style.corner_radius_top_left = 4
	btn_style.corner_radius_top_right = 4
	btn_style.corner_radius_bottom_left = 4
	btn_style.corner_radius_bottom_right = 4
	upgrade_btn.add_theme_stylebox_override("normal", btn_style)
	upgrade_btn.pressed.connect(func(): _upgrade_stat(stat_key))
	row.add_child(upgrade_btn)
	stat_buttons[stat_key] = upgrade_btn

	return row


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
	return btn


func _upgrade_stat(stat: String) -> void:
	if PlayerData.spend_stat_point(stat):
		SfxManager.play_button_click()
		_refresh()


func _refresh() -> void:
	points_label.text = "Stat Points: %d" % PlayerData.stat_points

	for stat_key in stat_labels:
		var value := PlayerData.get_stat(stat_key)
		if stat_key == "rld":
			stat_labels[stat_key].text = "%.2fs" % value
		else:
			stat_labels[stat_key].text = "%d" % int(value)

		# Disable buttons if not enough points
		var cost := UpgradeTree.STAT_COSTS.get(stat_key, 1)
		if stat_buttons.has(stat_key):
			stat_buttons[stat_key].disabled = PlayerData.stat_points < cost


func _show_class_select() -> void:
	var evolutions := TankClasses.get_available_evolutions(PlayerData.tank_class)
	if evolutions.is_empty():
		return

	var popup := PanelContainer.new()
	popup.set_anchors_preset(PRESET_CENTER)
	popup.custom_minimum_size = Vector2(420, 320)
	popup.position -= popup.custom_minimum_size / 2
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.15, 0.12)
	style.border_color = Color(0.6, 0.5, 0.35)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	popup.add_theme_stylebox_override("panel", style)
	add_child(popup)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	popup.add_child(vbox)

	var title := Label.new()
	title.text = "Choose Class"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.6))
	vbox.add_child(title)

	for evo in evolutions:
		var class_data := TankClasses.get_class_data(evo)
		var btn := _create_styled_button("%s" % class_data["name"], class_data.get("color", Color(0.5, 0.4, 0.3)))
		btn.custom_minimum_size = Vector2(380, 45)
		btn.tooltip_text = class_data["description"]

		# Add description label
		var row := VBoxContainer.new()
		row.add_child(btn)
		var desc := Label.new()
		desc.text = "  %s" % class_data["description"]
		desc.add_theme_font_size_override("font_size", 13)
		desc.add_theme_color_override("font_color", Color(0.7, 0.6, 0.5))
		row.add_child(desc)

		btn.pressed.connect(func():
			PlayerData.change_class(evo)
			popup.queue_free()
			for child in get_children():
				child.queue_free()
			_build_ui()
			_refresh()
		)
		vbox.add_child(row)

	var cancel_btn := _create_styled_button("Cancel", Color(0.35, 0.3, 0.25))
	cancel_btn.custom_minimum_size = Vector2(120, 40)
	cancel_btn.pressed.connect(func(): popup.queue_free())
	vbox.add_child(cancel_btn)
