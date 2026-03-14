extends Control

## Between-stage upgrade screen. Spend stat points and change class.

var stat_labels: Dictionary = {}
var points_label: Label


func _ready() -> void:
	_build_ui()
	_refresh()


func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0.18, 0.14, 0.12)
	add_child(bg)

	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_preset(PRESET_FULL_RECT)
	main_vbox.set_anchor_and_offset(SIDE_LEFT, 0.1, 0)
	main_vbox.set_anchor_and_offset(SIDE_RIGHT, 0.9, 0)
	main_vbox.set_anchor_and_offset(SIDE_TOP, 0.05, 0)
	main_vbox.set_anchor_and_offset(SIDE_BOTTOM, 0.95, 0)
	main_vbox.add_theme_constant_override("separation", 10)
	add_child(main_vbox)

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

	# Stat points available
	points_label = Label.new()
	points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	points_label.add_theme_font_size_override("font_size", 22)
	points_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
	main_vbox.add_child(points_label)

	# Stat upgrade rows
	var stats_container := VBoxContainer.new()
	stats_container.add_theme_constant_override("separation", 8)
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

	# Class change button (if available)
	if TankClasses.can_evolve(PlayerData.tank_class, PlayerData.level):
		var class_btn := Button.new()
		class_btn.text = "Change Class"
		class_btn.custom_minimum_size = Vector2(180, 50)
		class_btn.pressed.connect(_show_class_select)
		btn_row.add_child(class_btn)

	var continue_btn := Button.new()
	continue_btn.text = "Continue"
	continue_btn.custom_minimum_size = Vector2(180, 50)
	continue_btn.pressed.connect(func(): GameManager.advance_to_next_stage())
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

	var upgrade_btn := Button.new()
	upgrade_btn.text = "+"
	upgrade_btn.custom_minimum_size = Vector2(40, 40)
	upgrade_btn.pressed.connect(func(): _upgrade_stat(stat_key))
	row.add_child(upgrade_btn)

	return row


func _upgrade_stat(stat: String) -> void:
	if PlayerData.spend_stat_point(stat):
		_refresh()


func _refresh() -> void:
	points_label.text = "Stat Points: %d" % PlayerData.stat_points

	for stat_key in stat_labels:
		var value := PlayerData.get_stat(stat_key)
		if stat_key == "rld":
			stat_labels[stat_key].text = "%.2fs" % value
		else:
			stat_labels[stat_key].text = "%d" % int(value)


func _show_class_select() -> void:
	var evolutions := TankClasses.get_available_evolutions(PlayerData.tank_class)
	if evolutions.is_empty():
		return

	var popup := PanelContainer.new()
	popup.set_anchors_preset(PRESET_CENTER)
	popup.custom_minimum_size = Vector2(400, 300)
	popup.position -= popup.custom_minimum_size / 2
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.16, 0.13)
	style.border_color = Color(0.6, 0.5, 0.35)
	style.set_border_width_all(2)
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
		var btn := Button.new()
		btn.text = "%s - %s" % [class_data["name"], class_data["description"]]
		btn.custom_minimum_size.y = 50
		btn.pressed.connect(func():
			PlayerData.change_class(evo)
			popup.queue_free()
			# Rebuild the screen
			for child in get_children():
				child.queue_free()
			_build_ui()
			_refresh()
		)
		vbox.add_child(btn)

	var cancel_btn := Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(func(): popup.queue_free())
	vbox.add_child(cancel_btn)
