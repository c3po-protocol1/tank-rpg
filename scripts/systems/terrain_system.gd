class_name TerrainSystem
extends StaticBody2D

## Destructible terrain with visual polish. Brown gradient ground with craters.

var terrain_polygon: PackedVector2Array = []
var terrain_width: float = 2500.0
var terrain_base_y: float = 500.0
var polygon_node: Polygon2D
var collision_polygon: CollisionPolygon2D
var surface_line: Line2D
var crater_marks: Node2D

# Terrain generation params
var hill_count: int = 3
var roughness: float = 0.3
var hill_amplitude: float = 80.0


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	add_to_group("terrain")
	generate_terrain()


func generate_terrain(preset: String = "gentle_hills") -> void:
	var config : Variant = StageData.TERRAIN_PRESETS.get(preset, StageData.TERRAIN_PRESETS["flat"])
	hill_count = config.get("hills", 3)
	roughness = config.get("roughness", 0.3)
	_build_terrain_polygon()
	_update_visuals()


func _build_terrain_polygon() -> void:
	terrain_polygon.clear()
	var segments := 100

	terrain_polygon.append(Vector2(0, terrain_base_y + 200))

	for i in range(segments + 1):
		var x := (float(i) / segments) * terrain_width
		var y := _calculate_surface_height(x)
		terrain_polygon.append(Vector2(x, y))

	terrain_polygon.append(Vector2(terrain_width, terrain_base_y + 200))


func _calculate_surface_height(x: float) -> float:
	var y := terrain_base_y
	for i in range(hill_count):
		var frequency := (i + 1) * 0.003 * (1.0 + roughness)
		var amplitude := hill_amplitude * (1.0 / (i + 1)) * roughness
		var phase := i * 1.7
		y -= sin(x * frequency + phase) * amplitude
	return y


func _update_visuals() -> void:
	if polygon_node:
		polygon_node.queue_free()
	if collision_polygon:
		collision_polygon.queue_free()
	if surface_line:
		surface_line.queue_free()

	# Main terrain body (dark brown)
	polygon_node = Polygon2D.new()
	polygon_node.polygon = terrain_polygon
	polygon_node.color = Color(0.38, 0.3, 0.22)
	add_child(polygon_node)

	# Surface layer (lighter brown stripe on top)
	var surface_poly := Polygon2D.new()
	var surface_pts: PackedVector2Array = []
	for i in range(1, terrain_polygon.size() - 1):
		surface_pts.append(terrain_polygon[i])
	# Add offset points going back for thickness
	for i in range(terrain_polygon.size() - 2, 0, -1):
		surface_pts.append(terrain_polygon[i] + Vector2(0, 12))
	surface_poly.polygon = surface_pts
	surface_poly.color = Color(0.48, 0.4, 0.3)
	add_child(surface_poly)

	# Collision
	collision_polygon = CollisionPolygon2D.new()
	collision_polygon.polygon = terrain_polygon
	add_child(collision_polygon)

	# Grass line
	_add_surface_decoration()

	# Crater marks container
	if not crater_marks:
		crater_marks = Node2D.new()
		crater_marks.name = "CraterMarks"
		add_child(crater_marks)


func _add_surface_decoration() -> void:
	surface_line = Line2D.new()
	surface_line.width = 3.0
	surface_line.default_color = Color(0.35, 0.42, 0.25)

	for i in range(1, terrain_polygon.size() - 1):
		surface_line.add_point(terrain_polygon[i])

	add_child(surface_line)


func create_crater(impact_pos: Vector2, radius: float) -> void:
	var local_pos := to_local(impact_pos)

	# Add dark crater mark
	var mark := Polygon2D.new()
	var pts: PackedVector2Array = []
	for i in range(10):
		var angle := i * TAU / 10.0
		var r := radius * randf_range(0.6, 1.0)
		pts.append(Vector2(cos(angle), sin(angle)) * r)
	mark.polygon = pts
	mark.color = Color(0.25, 0.2, 0.15, 0.7)
	mark.position = local_pos
	if crater_marks:
		crater_marks.add_child(mark)

	var new_polygon: PackedVector2Array = []
	var inserted_crater := false

	for i in range(terrain_polygon.size()):
		var point := terrain_polygon[i]
		var dist_x := abs(point.x - local_pos.x)
		if dist_x < radius * 1.5 and i > 0 and i < terrain_polygon.size() - 1:
			if not inserted_crater:
				inserted_crater = true
				var crater_segments := 8
				for j in range(crater_segments + 1):
					var t := float(j) / crater_segments
					var cx := local_pos.x - radius + t * radius * 2.0
					var crater_depth := radius * 0.6 * sin(t * PI)
					var sy := _calculate_surface_height(cx)
					new_polygon.append(Vector2(cx, sy + crater_depth))
		else:
			new_polygon.append(point)

	terrain_polygon = new_polygon
	_update_visuals()


func get_surface_y_at(x: float) -> float:
	for i in range(1, terrain_polygon.size() - 2):
		var p1 := terrain_polygon[i]
		var p2 := terrain_polygon[i + 1]
		if x >= p1.x and x <= p2.x:
			var t := (x - p1.x) / (p2.x - p1.x)
			return lerpf(p1.y, p2.y, t)
	return terrain_base_y
