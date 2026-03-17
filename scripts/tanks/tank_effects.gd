class_name TankEffects
extends RefCounted

## Static helper for tank visual effects (muzzle flash, shield, heal, death).


## Show muzzle flash at barrel tip.
static func show_muzzle_flash(tank: TankBase) -> void:
	if not is_instance_valid(tank) or tank.barrel_tip == null:
		return
	var flash := Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(8):
		var angle := i * TAU / 8.0
		points.append(Vector2(cos(angle), sin(angle)) * 10.0)
	flash.polygon = points
	flash.color = Colors.MUZZLE_FLASH
	flash.global_position = tank.barrel_tip.global_position
	tank.get_tree().current_scene.add_child(flash)

	var tween := flash.create_tween()
	tween.tween_property(flash, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(flash.queue_free)


## Show shield bubble around tank.
static func show_shield_visual(tank: TankBase) -> void:
	var shield := Polygon2D.new()
	shield.name = "ShieldVisual"
	var points: PackedVector2Array = []
	for i in range(16):
		var angle := i * TAU / 16.0
		points.append(Vector2(cos(angle), sin(angle)) * 45.0)
	shield.polygon = points
	shield.color = Colors.SHIELD_BLUE
	shield.position = Vector2(0, -20)
	tank.add_child(shield)

	var tween := shield.create_tween().set_loops()
	tween.tween_property(shield, "modulate:a", 0.15, 0.5)
	tween.tween_property(shield, "modulate:a", 0.4, 0.5)


## Remove shield visual from tank.
static func remove_shield_visual(tank: TankBase) -> void:
	var shield := tank.get_node_or_null("ShieldVisual")
	if shield:
		shield.queue_free()


## Show healing crosses floating up.
static func show_heal_visual(tank: TankBase) -> void:
	for i in range(3):
		var cross := Label.new()
		cross.text = "+"
		cross.add_theme_font_size_override("font_size", 24)
		cross.add_theme_color_override("font_color", Colors.HEAL_GREEN)
		cross.position = tank.position + Vector2(randf_range(-20, 20), -40)
		tank.get_tree().current_scene.add_child(cross)

		var tween := cross.create_tween()
		tween.tween_property(cross, "position:y", cross.position.y - 40.0, 0.8)
		tween.parallel().tween_property(cross, "modulate:a", 0.0, 0.8)
		tween.tween_callback(cross.queue_free)


## Show dash trail effect.
static func show_dash_visual(tank: TankBase) -> void:
	var trail := Polygon2D.new()
	var points: PackedVector2Array = [
		Vector2(-30, -10), Vector2(30, -10),
		Vector2(30, 10), Vector2(-30, 10)
	]
	trail.polygon = points
	trail.color = Color(Colors.TANK_BASIC.r, Colors.TANK_BASIC.g, Colors.TANK_BASIC.b, 0.4)
	trail.global_position = tank.global_position + Vector2(0, -15)
	tank.get_tree().current_scene.add_child(trail)

	var tween := trail.create_tween()
	tween.tween_property(trail, "modulate:a", 0.0, 0.3)
	tween.tween_callback(trail.queue_free)


## Death explosion — multiple bursts.
static func spawn_death_explosion(tank: TankBase) -> void:
	var scene := tank.get_tree().current_scene
	if not is_instance_valid(scene):
		return
	for i in range(4):
		var burst := Polygon2D.new()
		var points: PackedVector2Array = []
		var radius := randf_range(8.0, 18.0)
		for j in range(8):
			var angle := j * TAU / 8.0
			points.append(Vector2(cos(angle), sin(angle)) * radius)
		burst.polygon = points
		burst.color = Colors.EXPLOSION_OUTER if i % 2 == 0 else Colors.EXPLOSION_INNER
		burst.global_position = tank.global_position + Vector2(
			randf_range(-20, 20), randf_range(-30, 10))
		scene.add_child(burst)

		var tween := burst.create_tween()
		tween.tween_property(burst, "scale", Vector2(2.0, 2.0), 0.3)
		tween.parallel().tween_property(burst, "modulate:a", 0.0, 0.3)
		tween.tween_callback(burst.queue_free)


## Floating damage number.
static func show_damage_number(tank: TankBase, amount: float) -> void:
	var label := Label.new()
	label.text = str(int(amount))
	label.add_theme_font_size_override("font_size", 18)
	var color := Colors.DAMAGE_NUMBER
	if amount > 30:
		color = Colors.EXPLOSION_OUTER
	label.add_theme_color_override("font_color", color)
	label.position = tank.global_position + Vector2(randf_range(-15, 15), -50)
	tank.get_tree().current_scene.add_child(label)

	var tween := label.create_tween()
	tween.tween_property(label, "position:y", label.position.y - 30.0, 0.6)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)
