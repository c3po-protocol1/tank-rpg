class_name MainMenu
extends Control

## Main menu with Start Game, Continue, and New Game confirmation.

var center_vbox: VBoxContainer
var confirm_popup: PanelContainer = null


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0.2, 0.16, 0.13)
	add_child(bg)

	# Decorative ground
	var ground := ColorRect.new()
	ground.set_anchors_preset(PRESET_BOTTOM_WIDE)
	ground.custom_minimum_size.y = 120
	ground.color = Color(0.35, 0.28, 0.22)
	add_child(ground)

	var ground_line := ColorRect.new()
	ground_line.set_anchors_preset(PRESET_BOTTOM_WIDE)
	ground_line.custom_minimum_size.y = 4
	ground_line.offset_top = -120
	ground_line.color = Color(0.35, 0.42, 0.25)
	add_child(ground_line)

	center_vbox = VBoxContainer.new()
	center_vbox.set_anchors_preset(PRESET_CENTER)
	center_vbox.custom_minimum_size = Vector2(400, 380)
	center_vbox.position -= center_vbox.custom_minimum_size / 2
	center_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center_vbox.add_theme_constant_override("separation", 15)
	add_child(center_vbox)

	# Title
	var title := Label.new()
	title.text = "TANK RPG"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(0.9, 0.75, 0.5))
	center_vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Side-Scrolling Tank Combat"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.6, 0.45))
	center_vbox.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 25
	center_vbox.add_child(spacer)

	# Continue button (only if save exists)
	if PlayerData.has_save():
		var continue_btn := _create_menu_button("CONTINUE", Color(0.35, 0.5, 0.3))
		continue_btn.pressed.connect(_on_continue_pressed)
		center_vbox.add_child(continue_btn)

	# New Game / Start button
	if PlayerData.has_save():
		var new_btn := _create_menu_button("NEW GAME", Color(0.5, 0.35, 0.2))
		new_btn.pressed.connect(_on_new_game_pressed)
		center_vbox.add_child(new_btn)
	else:
		var start_btn := _create_menu_button("START GAME", Color(0.5, 0.35, 0.2))
		start_btn.pressed.connect(_on_start_pressed)
		center_vbox.add_child(start_btn)

	# Credits
	var credits := Label.new()
	credits.text = "A Godot 4 Indie Game"
	credits.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits.add_theme_font_size_override("font_size", 12)
	credits.add_theme_color_override("font_color", Color(0.5, 0.4, 0.35))
	center_vbox.add_child(credits)


func _create_menu_button(text: String, color: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(250, 55)
	btn.add_theme_font_size_override("font_size", 22)
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


func _on_start_pressed() -> void:
	SfxManager.play_button_click()
	GameManager.start_game()


func _on_continue_pressed() -> void:
	SfxManager.play_button_click()
	GameManager.continue_game()


func _on_new_game_pressed() -> void:
	SfxManager.play_button_click()
	_show_new_game_confirm()


func _show_new_game_confirm() -> void:
	if confirm_popup:
		confirm_popup.queue_free()

	confirm_popup = PanelContainer.new()
	confirm_popup.set_anchors_preset(PRESET_CENTER)
	confirm_popup.custom_minimum_size = Vector2(380, 180)
	confirm_popup.position -= confirm_popup.custom_minimum_size / 2
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.14, 0.12, 0.98)
	style.border_color = Color(0.7, 0.4, 0.2)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	confirm_popup.add_theme_stylebox_override("panel", style)
	add_child(confirm_popup)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 15)
	confirm_popup.add_child(vbox)

	var msg := Label.new()
	msg.text = "Start a new game?\nExisting save will be deleted."
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 18)
	msg.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	vbox.add_child(msg)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)

	var yes_btn := _create_menu_button("Yes", Color(0.6, 0.3, 0.2))
	yes_btn.custom_minimum_size = Vector2(100, 40)
	yes_btn.add_theme_font_size_override("font_size", 16)
	yes_btn.pressed.connect(func():
		PlayerData.delete_save()
		confirm_popup.queue_free()
		GameManager.start_game()
	)
	btn_row.add_child(yes_btn)

	var no_btn := _create_menu_button("No", Color(0.35, 0.35, 0.3))
	no_btn.custom_minimum_size = Vector2(100, 40)
	no_btn.add_theme_font_size_override("font_size", 16)
	no_btn.pressed.connect(func(): confirm_popup.queue_free())
	btn_row.add_child(no_btn)
