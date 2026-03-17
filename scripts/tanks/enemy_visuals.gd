class_name EnemyVisuals
extends RefCounted

## Builds visual representation for enemy tanks based on type.

static func setup(tank: EnemyTank) -> void:
	var enemy_data := StageData.ENEMY_DATA.get(tank.enemy_type, {})
	var color: Color = enemy_data.get("color", Color(0.45, 0.4, 0.35))
	facing_right = false

	tank.body_node = Node2D.new()
	tank.add_child(tank.body_node)

	var body_scale := 1.0
	if tank.enemy_type == StageData.EnemyType.BOSS:
		body_scale = 1.4
		color = color.lightened(0.1)
	elif tank.enemy_type == StageData.EnemyType.SUB_BOSS:
		body_scale = 1.15

	# Rounded body using Polygon2D
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-26, -4), Vector2(-22, -18), Vector2(-10, -22),
		Vector2(10, -22), Vector2(22, -18), Vector2(26, -4),
		Vector2(28, 0), Vector2(-28, 0)
	])
	body.color = color
	tank.body_node.add_child(body)

	# Turret
	var turret := Polygon2D.new()
	turret.polygon = PackedVector2Array([
		Vector2(-10, -22), Vector2(-8, -36), Vector2(-2, -38),
		Vector2(8, -38), Vector2(12, -36), Vector2(14, -22)
	])
	turret.color = color.darkened(0.15)
	tank.body_node.add_child(turret)

	# Boss crown indicator
	if tank.enemy_type == StageData.EnemyType.BOSS:
		var crown := Polygon2D.new()
		crown.polygon = PackedVector2Array([
			Vector2(-8, -38), Vector2(-6, -48), Vector2(-2, -42),
			Vector2(2, -48), Vector2(6, -42), Vector2(8, -48), Vector2(10, -38)
		])
		crown.color = Color(0.9, 0.7, 0.2)
		tank.body_node.add_child(crown)

	# Barrel (faces left)
	tank.barrel_node = Node2D.new()
	tank.barrel_node.position = Vector2(-4, -30)
	tank.body_node.add_child(tank.barrel_node)

	var barrel_len := 32.0
	if tank.enemy_type == StageData.EnemyType.BOSS:
		barrel_len = 40.0

	var barrel_rect := Polygon2D.new()
	barrel_rect.polygon = PackedVector2Array([
		Vector2(0, -2.5), Vector2(-barrel_len, -2), Vector2(-barrel_len, 2), Vector2(0, 2.5)
	])
	barrel_rect.color = color.darkened(0.3)
	tank.barrel_node.add_child(barrel_rect)

	tank.barrel_tip = Marker2D.new()
	tank.barrel_tip.position = Vector2(-barrel_len - 3, 0)
	tank.barrel_node.add_child(barrel_tip)

	# Tracks
	var track_w := 60.0 * body_scale
	var tracks := Polygon2D.new()
	tracks.polygon = PackedVector2Array([
		Vector2(-track_w / 2, 0), Vector2(track_w / 2, 0),
		Vector2(track_w / 2, 7), Vector2(-track_w / 2, 7)
	])
	tracks.color = color.darkened(0.4)
	tank.body_node.add_child(tracks)

	for i in range(4):
		var wheel := _create_wheel(5.5, color.darkened(0.5))
		wheel.position = Vector2(-20 + i * 14, 3)
		tank.body_node.add_child(wheel)

	barrel_node.rotation_degrees = -(180.0 + barrel_angle)

	# Scale for boss/sub-boss
	if body_scale != 1.0:
		body_node.scale = Vector2(body_scale, body_scale)


static func _create_wheel(radius: float, color: Color) -> Polygon2D:
	var wheel := Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(12):
		var a := i * TAU / 12.0
		points.append(Vector2(cos(a), sin(a)) * radius)
	wheel.polygon = points
	wheel.color = color
	return wheel


