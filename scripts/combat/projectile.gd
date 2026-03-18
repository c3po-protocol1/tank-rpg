class_name Projectile
extends Area2D

## Physics-based projectile with arc trajectory. Creates craters on terrain impact.

var initial_velocity: Vector2 = Vector2.ZERO
var damage: float = 10.0
var owner_tank: TankBase = null
var explosion_radius: float = 25.0
var bullet_color: Color = Color(0.85, 0.55, 0.15)

const GRAVITY := 980.0
const MAX_LIFETIME := 5.0

var _velocity: Vector2 = Vector2.ZERO
var _lifetime: float = 0.0


func _ready() -> void:
	_velocity = initial_velocity
	collision_layer = 4
	collision_mask = 1 | 2

	var shape := CircleShape2D.new()
	shape.radius = 4.0
	var coll := CollisionShape2D.new()
	coll.shape = shape
	add_child(coll)

	var visual := Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(8):
		var angle := i * TAU / 8.0
		points.append(Vector2(cos(angle), sin(angle)) * 4.0)
	visual.polygon = points
	visual.color = bullet_color
	add_child(visual)

	# Trail effect
	var trail := Line2D.new()
	trail.name = "Trail"
	trail.width = 2.0
	trail.default_color = Color(0.8, 0.5, 0.15, 0.5)
	trail.z_index = -1
	add_child(trail)

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	_velocity.y += GRAVITY * delta
	position += _velocity * delta
	rotation = _velocity.angle()

	# Update trail
	var trail := get_node_or_null("Trail") as Line2D
	if trail:
		trail.add_point(Vector2.ZERO)
		if trail.get_point_count() > 10:
			trail.remove_point(0)

	_lifetime += delta
	if _lifetime >= MAX_LIFETIME:
		queue_free()

	if position.y > 2000 or position.x < -500 or position.x > 3000:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body == owner_tank:
		return

	if body is TankBase:
		body.take_damage(damage, owner_tank)
		_explode()
	elif body.is_in_group("terrain"):
		_create_crater(body)
		_explode()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("terrain"):
		_create_crater(area)
		_explode()


func _create_crater(terrain_node: Node2D) -> void:
	if terrain_node.has_method("create_crater"):
		terrain_node.create_crater(global_position, explosion_radius)


func _explode() -> void:
	var explosion := _create_explosion_effect()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position

	# Screen shake for big explosions
	if explosion_radius >= 35.0:
		_trigger_screen_shake(explosion_radius * 0.15)

	if is_inside_tree() and get_node_or_null("/root/SfxManager"):
		SfxManager.play_explosion()
	queue_free()


func _create_explosion_effect() -> Node2D:
	var effect := Node2D.new()

	# Outer blast
	var outer := Polygon2D.new()
	var pts_outer: PackedVector2Array = []
	for i in range(16):
		var angle := i * TAU / 16.0
		var r := explosion_radius * randf_range(0.8, 1.2)
		pts_outer.append(Vector2(cos(angle), sin(angle)) * r)
	outer.polygon = pts_outer
	outer.color = Color(0.9, 0.4, 0.05, 0.7)
	effect.add_child(outer)

	# Inner core (brighter)
	var inner := Polygon2D.new()
	var pts_inner: PackedVector2Array = []
	for i in range(10):
		var angle := i * TAU / 10.0
		pts_inner.append(Vector2(cos(angle), sin(angle)) * explosion_radius * 0.5)
	inner.polygon = pts_inner
	inner.color = Color(1.0, 0.8, 0.3, 0.9)
	effect.add_child(inner)

	# Sparks
	for i in range(6):
		var spark := Polygon2D.new()
		var sp: PackedVector2Array = []
		for j in range(4):
			var angle := j * TAU / 4.0
			sp.append(Vector2(cos(angle), sin(angle)) * 3.0)
		spark.polygon = sp
		spark.color = Color(1.0, 0.6, 0.1, 0.9)
		var spark_dir := Vector2.from_angle(randf() * TAU)
		spark.position = spark_dir * randf_range(5.0, explosion_radius * 0.5)
		effect.add_child(spark)

		var stween := spark.create_tween()
		stween.tween_property(spark, "position", spark.position + spark_dir * randf_range(15.0, 30.0), 0.3)
		stween.parallel().tween_property(spark, "modulate:a", 0.0, 0.3)
		stween.tween_callback(spark.queue_free)

	# Animate and remove
	var tween := effect.create_tween()
	tween.tween_property(outer, "scale", Vector2(1.6, 1.6), 0.35)
	tween.parallel().tween_property(outer, "color:a", 0.0, 0.35)
	tween.parallel().tween_property(inner, "scale", Vector2(1.3, 1.3), 0.25)
	tween.parallel().tween_property(inner, "color:a", 0.0, 0.25)
	tween.tween_callback(effect.queue_free)

	return effect


func _trigger_screen_shake(intensity: float) -> void:
	var camera := get_viewport().get_camera_2d()
	if not camera:
		return
	var original_offset := camera.offset
	var tween := camera.create_tween()
	for i in range(4):
		var shake := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(camera, "offset", original_offset + shake, 0.05)
	tween.tween_property(camera, "offset", original_offset, 0.05)
