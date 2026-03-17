class_name ClassSelectUI
extends RefCounted

## Class evolution selection popup UI.


static func show(parent: Control) -> void:
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
	parent.add_child(popup)

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
			parent._refresh()
		)
		vbox.add_child(row)

	var cancel_btn := _create_styled_button("Cancel", Color(0.35, 0.3, 0.25))
	cancel_btn.custom_minimum_size = Vector2(120, 40)
	cancel_btn.pressed.connect(func(): popup.queue_free())
	vbox.add_child(cancel_btn)
