class_name TankFireSystem
extends RefCounted

## Handles projectile creation and launching. Avoids cyclic reference with TankBase.

static func fire_projectile(tank: Node, damage_mult: float = 1.0, radius: float = 20.0, angle_offset: float = 0.0, power: float = 0.5) -> void:
	var tip: Marker2D = tank.get("barrel_tip")
	if tip == null:
		return
	var scene: PackedScene = tank.get("projectile_scene")
	var proj: Node2D = scene.instantiate()
	proj.global_position = tip.global_position
	var b_angle: float = tank.get("barrel_angle")
	var fire_angle := deg_to_rad(b_angle + angle_offset)
	var direction := 1.0 if tank.get("facing_right") else -1.0
	var rng_val: float = tank.get("rng")
	var power_factor: float = 0.3 + power * 0.7
	var speed: float = rng_val * 2.0 * power_factor
	var vel := Vector2(cos(fire_angle) * speed * direction, sin(fire_angle) * speed)
	proj.set("initial_velocity", vel)
	proj.set("damage", tank.get("atk") * damage_mult)
	proj.set("explosion_radius", radius)
	proj.set("owner_tank", tank)
	var cur_bullet = tank.get("current_bullet")
	var bullet_data: Dictionary = BulletTypes.get_data(cur_bullet)
	proj.set("bullet_color", bullet_data.get("color", Color(0.85, 0.55, 0.15)))
	tank.get_tree().current_scene.add_child(proj)
	tank.shot_fired.emit(proj)
