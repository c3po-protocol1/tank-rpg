class_name PlayerVisuals
extends RefCounted

## Builds visual representation for player tanks. One function per class.


## Main entry: setup visuals based on tank class.
static func setup(tank: PlayerTank) -> void:
	var class_data := TankClasses.get_class_data(tank.tank_class)
	var color: Color = class_data.get("color", Colors.TANK_BASIC)

	tank.body_node = Node2D.new()
	tank.add_child(tank.body_node)

	match tank.tank_class:
		TankClasses.ClassType.BASIC:
			_basic(tank, color)
		TankClasses.ClassType.DEALER:
			_dealer(tank, color)
		TankClasses.ClassType.TANKER:
			_tanker(tank, color)
		TankClasses.ClassType.SUPPORT:
			_support(tank, color)
		TankClasses.ClassType.ARTILLERY:
			_artillery(tank, color)
		TankClasses.ClassType.SCOUT:
			_scout(tank, color)

	tank.barrel_node.rotation_degrees = tank.barrel_angle


static func _basic(tank: PlayerTank, color: Color) -> void:
	var body := ColorRect.new()
	body.size = Vector2(60, 24)
	body.position = Vector2(-30, -24)
	body.color = color
	tank.body_node.add_child(body)
	var turret := ColorRect.new()
	turret.size = Vector2(30, 18)
	turret.position = Vector2(-8, -42)
	turret.color = color.darkened(0.15)
	tank.body_node.add_child(turret)
	_barrel(tank, color, Vector2(8, -33), Vector2(35, 6), Vector2(38, 0))
	_tracks(tank, color, 64.0, 4, -22.0, 15.0)


static func _dealer(tank: PlayerTank, color: Color) -> void:
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-32, 0), Vector2(-28, -20), Vector2(28, -20), Vector2(32, 0)])
	body.color = color
	tank.body_node.add_child(body)
	var turret := Polygon2D.new()
	turret.polygon = PackedVector2Array([
		Vector2(-12, -20), Vector2(-8, -36), Vector2(14, -36), Vector2(18, -20)])
	turret.color = color.darkened(0.15)
	tank.body_node.add_child(turret)
	_barrel(tank, color, Vector2(10, -28), Vector2(45, 5), Vector2(48, 0))
	_tracks(tank, color, 60.0, 4, -22.0, 14.0)


static func _tanker(tank: PlayerTank, color: Color) -> void:
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-38, 0), Vector2(-35, -26), Vector2(35, -26), Vector2(38, 0)])
	body.color = color
	tank.body_node.add_child(body)
	# Armor plates
	for plate_x in [-25.0, 0.0, 25.0]:
		var plate := ColorRect.new()
		plate.size = Vector2(14, 28)
		plate.position = Vector2(plate_x - 7, -27)
		plate.color = color.darkened(0.1)
		tank.body_node.add_child(plate)
	var turret := Polygon2D.new()
	turret.polygon = PackedVector2Array([
		Vector2(-16, -26), Vector2(-12, -44), Vector2(12, -44), Vector2(16, -26)])
	turret.color = color.darkened(0.2)
	tank.body_node.add_child(turret)
	_barrel(tank, color, Vector2(6, -35), Vector2(32, 8), Vector2(36, 0))
	_tracks(tank, color, 72.0, 5, -30.0, 14.0)


static func _support(tank: PlayerTank, color: Color) -> void:
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-30, 0), Vector2(-26, -22), Vector2(26, -22), Vector2(30, 0)])
	body.color = color
	tank.body_node.add_child(body)
	var turret := ColorRect.new()
	turret.size = Vector2(26, 16)
	turret.position = Vector2(-8, -38)
	turret.color = color.darkened(0.15)
	tank.body_node.add_child(turret)
	# Antenna
	var antenna := ColorRect.new()
	antenna.size = Vector2(2, 18)
	antenna.position = Vector2(4, -56)
	antenna.color = color.darkened(0.3)
	tank.body_node.add_child(antenna)
	# Cross
	var cross_h := ColorRect.new()
	cross_h.size = Vector2(10, 3)
	cross_h.position = Vector2(0, -60)
	cross_h.color = Colors.HEAL_GREEN
	tank.body_node.add_child(cross_h)
	var cross_v := ColorRect.new()
	cross_v.size = Vector2(3, 10)
	cross_v.position = Vector2(3.5, -63.5)
	cross_v.color = Colors.HEAL_GREEN
	tank.body_node.add_child(cross_v)
	_barrel(tank, color, Vector2(6, -30), Vector2(30, 5), Vector2(34, 0))
	_tracks(tank, color, 58.0, 4, -20.0, 13.0)


static func _artillery(tank: PlayerTank, color: Color) -> void:
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-36, 0), Vector2(-30, -20), Vector2(30, -20), Vector2(36, 0)])
	body.color = color
	tank.body_node.add_child(body)
	var turret := ColorRect.new()
	turret.size = Vector2(22, 16)
	turret.position = Vector2(-6, -36)
	turret.color = color.darkened(0.15)
	tank.body_node.add_child(turret)
	_barrel(tank, color, Vector2(5, -28), Vector2(52, 5), Vector2(55, 0))
	_tracks(tank, color, 68.0, 5, -28.0, 13.0)


static func _scout(tank: PlayerTank, color: Color) -> void:
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-24, 0), Vector2(-20, -16), Vector2(22, -16), Vector2(26, 0)])
	body.color = color
	tank.body_node.add_child(body)
	var turret := Polygon2D.new()
	turret.polygon = PackedVector2Array([
		Vector2(-8, -16), Vector2(-5, -28), Vector2(10, -28), Vector2(13, -16)])
	turret.color = color.darkened(0.15)
	tank.body_node.add_child(turret)
	_barrel(tank, color, Vector2(6, -22), Vector2(28, 4), Vector2(32, 0))
	_tracks(tank, color, 48.0, 3, -16.0, 14.0)


## Build barrel + tip marker.
static func _barrel(tank: PlayerTank, color: Color, pivot: Vector2, bsize: Vector2, tip_pos: Vector2) -> void:
	tank.barrel_node = Node2D.new()
	tank.barrel_node.position = pivot
	tank.body_node.add_child(tank.barrel_node)
	var rect := ColorRect.new()
	rect.size = bsize
	rect.position = Vector2(0, -bsize.y / 2.0)
	rect.color = color.darkened(0.3)
	tank.barrel_node.add_child(rect)
	tank.barrel_tip = Marker2D.new()
	tank.barrel_tip.position = tip_pos
	tank.barrel_node.add_child(tank.barrel_tip)


## Build tracks + wheels.
static func _tracks(tank: PlayerTank, color: Color, track_w: float, wheel_count: int, start_x: float, spacing: float) -> void:
	var tracks := ColorRect.new()
	tracks.size = Vector2(track_w, 8)
	tracks.position = Vector2(-track_w / 2.0, 0)
	tracks.color = color.darkened(0.4)
	tank.body_node.add_child(tracks)
	for i in range(wheel_count):
		var wheel := _wheel(6.0, color.darkened(0.5))
		wheel.position = Vector2(start_x + i * spacing, 4)
		tank.body_node.add_child(wheel)


static func _wheel(radius: float, color: Color) -> Polygon2D:
	var w := Polygon2D.new()
	var pts: PackedVector2Array = []
	for i in range(12):
		var angle := i * TAU / 12.0
		pts.append(Vector2(cos(angle), sin(angle)) * radius)
	w.polygon = pts
	w.color = color
	return w
