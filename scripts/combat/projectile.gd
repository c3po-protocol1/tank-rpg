class_name Projectile
extends Area2D

## Physics-based projectile with arc trajectory. Creates craters on terrain impact.

var initial_velocity: Vector2 = Vector2.ZERO
var damage: float = 10.0
var owner_tank: TankBase = null
var explosion_radius: float = 25.0

const GRAVITY := 980.0
const MAX_LIFETIME := 5.0

var _velocity: Vector2 = Vector2.ZERO
var _lifetime: float = 0.0
var _trail_points: PackedVector2Array = []


func _ready() -> void:
	_velocity = initial_velocity
	collision_layer = 4   # projectiles layer
	collision_mask = 1 | 2  # terrain + tanks

	# Visual: small circle
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
	visual.color = Color(0.85, 0.55, 0.15)
	add_child(visual)

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	_velocity.y += GRAVITY * delta
	position += _velocity * delta

	# Rotate to face velocity direction
	rotation = _velocity.angle()

	_lifetime += delta
	if _lifetime >= MAX_LIFETIME:
		queue_free()

	# Off screen check
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
	# Handle terrain areas if used
	if area.is_in_group("terrain"):
		_create_crater(area)
		_explode()


func _create_crater(terrain_node: Node2D) -> void:
	# Signal the terrain system to create a crater
	if terrain_node.has_method("create_crater"):
		terrain_node.create_crater(global_position, explosion_radius)


func _explode() -> void:
	# Spawn explosion effect
	var explosion := _create_explosion_effect()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	queue_free()


func _create_explosion_effect() -> Node2D:
	var effect := Node2D.new()

	# Expanding circle
	var circle := Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(16):
		var angle := i * TAU / 16.0
		points.append(Vector2(cos(angle), sin(angle)) * explosion_radius)
	circle.polygon = points
	circle.color = Color(0.9, 0.5, 0.1, 0.8)
	effect.add_child(circle)

	# Animate and remove
	var tween := effect.create_tween()
	tween.tween_property(circle, "scale", Vector2(1.5, 1.5), 0.3)
	tween.parallel().tween_property(circle, "color:a", 0.0, 0.3)
	tween.tween_callback(effect.queue_free)

	return effect
