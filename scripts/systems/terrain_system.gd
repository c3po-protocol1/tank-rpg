class_name TerrainSystem
extends StaticBody2D

## Destructible terrain using polygon-based ground. Craters are carved on projectile impact.

var terrain_polygon: PackedVector2Array = []
var terrain_width: float = 2500.0
var terrain_base_y: float = 500.0
var polygon_node: Polygon2D
var collision_polygon: CollisionPolygon2D

# Terrain generation params
var hill_count: int = 3
var roughness: float = 0.3
var hill_amplitude: float = 80.0


func _ready() -> void:
	collision_layer = 1  # terrain layer
	collision_mask = 0
	add_to_group("terrain")
	generate_terrain()


func generate_terrain(preset: String = "gentle_hills") -> void:
	var config := StageData.TERRAIN_PRESETS.get(preset, StageData.TERRAIN_PRESETS["flat"])
	hill_count = config.get("hills", 3)
	roughness = config.get("roughness", 0.3)

	_build_terrain_polygon()
	_update_visuals()


func _build_terrain_polygon() -> void:
	terrain_polygon.clear()
	var segments := 100

	# Bottom-left corner (deep underground)
	terrain_polygon.append(Vector2(0, terrain_base_y + 200))

	# Surface points from left to right
	for i in range(segments + 1):
		var x := (float(i) / segments) * terrain_width
		var y := _calculate_surface_height(x)
		terrain_polygon.append(Vector2(x, y))

	# Bottom-right corner
	terrain_polygon.append(Vector2(terrain_width, terrain_base_y + 200))


func _calculate_surface_height(x: float) -> float:
	var y := terrain_base_y

	# Add hills using sine waves
	for i in range(hill_count):
		var frequency := (i + 1) * 0.003 * (1.0 + roughness)
		var amplitude := hill_amplitude * (1.0 / (i + 1)) * roughness
		var phase := i * 1.7  # Offset each wave
		y -= sin(x * frequency + phase) * amplitude

	return y


func _update_visuals() -> void:
	# Remove old nodes
	if polygon_node:
		polygon_node.queue_free()
	if collision_polygon:
		collision_polygon.queue_free()

	# Draw terrain polygon
	polygon_node = Polygon2D.new()
	polygon_node.polygon = terrain_polygon
	polygon_node.color = Color(0.42, 0.35, 0.27)  # Brown earth
	add_child(polygon_node)

	# Collision
	collision_polygon = CollisionPolygon2D.new()
	collision_polygon.polygon = terrain_polygon
	add_child(collision_polygon)

	# Add grass/surface line
	_add_surface_decoration()


func _add_surface_decoration() -> void:
	# A slightly darker line on the surface
	var surface_line := Line2D.new()
	surface_line.width = 4.0
	surface_line.default_color = Color(0.35, 0.42, 0.25)  # Olive green grass

	# Extract surface points (skip first and last which are underground corners)
	for i in range(1, terrain_polygon.size() - 1):
		surface_line.add_point(terrain_polygon[i])

	add_child(surface_line)


func create_crater(impact_pos: Vector2, radius: float) -> void:
	# Convert to local coordinates
	var local_pos := to_local(impact_pos)

	# Modify the polygon to create a crater
	var new_polygon: PackedVector2Array = []
	var inserted_crater := false

	for i in range(terrain_polygon.size()):
		var point := terrain_polygon[i]

		# Check if this point is near the crater
		var dist_x := abs(point.x - local_pos.x)
		if dist_x < radius * 1.5 and i > 0 and i < terrain_polygon.size() - 1:
			if not inserted_crater:
				inserted_crater = true
				# Insert crater points
				var crater_segments := 8
				for j in range(crater_segments + 1):
					var t := float(j) / crater_segments
					var cx := local_pos.x - radius + t * radius * 2.0
					var crater_depth := radius * 0.6 * sin(t * PI)
					var surface_y := _calculate_surface_height(cx)
					new_polygon.append(Vector2(cx, surface_y + crater_depth))
		else:
			new_polygon.append(point)

	terrain_polygon = new_polygon
	_update_visuals()


func get_surface_y_at(x: float) -> float:
	# Find the surface height at a given x position
	for i in range(1, terrain_polygon.size() - 2):
		var p1 := terrain_polygon[i]
		var p2 := terrain_polygon[i + 1]
		if x >= p1.x and x <= p2.x:
			var t := (x - p1.x) / (p2.x - p1.x)
			return lerpf(p1.y, p2.y, t)
	return terrain_base_y
