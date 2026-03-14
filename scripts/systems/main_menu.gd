extends Control

## Main menu screen with start game button.


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0.22, 0.17, 0.14)
	add_child(bg)

	var center := VBoxContainer.new()
	center.set_anchors_preset(PRESET_CENTER)
	center.custom_minimum_size = Vector2(400, 300)
	center.position -= center.custom_minimum_size / 2
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 20)
	add_child(center)

	# Title
	var title := Label.new()
	title.text = "TANK RPG"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(0.9, 0.75, 0.5))
	center.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Side-Scrolling Tank Combat"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.6, 0.45))
	center.add_child(subtitle)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 30
	center.add_child(spacer)

	# Start button
	var start_btn := Button.new()
	start_btn.text = "START GAME"
	start_btn.custom_minimum_size = Vector2(250, 60)
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.5, 0.35, 0.2)
	btn_style.corner_radius_top_left = 8
	btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_left = 8
	btn_style.corner_radius_bottom_right = 8
	start_btn.add_theme_stylebox_override("normal", btn_style)
	start_btn.add_theme_font_size_override("font_size", 24)
	start_btn.pressed.connect(_on_start_pressed)
	center.add_child(start_btn)

	# Credits
	var credits := Label.new()
	credits.text = "A Godot 4 Indie Game"
	credits.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits.add_theme_font_size_override("font_size", 12)
	credits.add_theme_color_override("font_color", Color(0.5, 0.4, 0.35))
	center.add_child(credits)


func _on_start_pressed() -> void:
	GameManager.start_game()
