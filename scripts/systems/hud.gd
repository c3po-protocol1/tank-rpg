class_name HUD
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
var power_gauge_bar: ProgressBar
var bullet_label: Label
func _ready() -> void:
	layer = 5
	_build_ui()
func setup(player: PlayerTank) -> void:
	player_ref = player
	if player_ref:
		player_ref.hp_changed.connect(_on_hp_changed)
		player_ref.sp_changed.connect(_on_sp_changed)
		player_ref.power_gauge_changed.connect(_on_power_gauge_changed)
		player_ref.bullet_type_changed.connect(_on_bullet_changed)
		HudControls.update_bullet(self)
		_update_hp_display()
		_update_sp_display()
		HudControls.update_skill_button(self)
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
	HudControls.build(root, self)
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

func _on_power_gauge_changed(value: float) -> void:
	HudControls.update_gauge(self, value)
func _on_bullet_changed(_bt: int) -> void:
	HudControls.update_bullet(self)
