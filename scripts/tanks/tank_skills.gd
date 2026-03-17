class_name TankSkills
extends RefCounted

## Static helper for tank skill execution. Called by TankBase.use_skill().


## Execute skill based on tank class.
static func execute(tank: TankBase) -> void:
	var skill_cost := get_skill_cost(tank.tank_class)
	if not tank.use_sp(float(skill_cost)):
		return
	tank.skill_cooldown = 2.0

	match tank.tank_class:
		TankClasses.ClassType.BASIC:
			_power_shot(tank)
		TankClasses.ClassType.DEALER:
			_rapid_fire(tank)
		TankClasses.ClassType.TANKER:
			_shield(tank)
		TankClasses.ClassType.SUPPORT:
			_repair(tank)
		TankClasses.ClassType.ARTILLERY:
			_barrage(tank)
		TankClasses.ClassType.SCOUT:
			_dash(tank)


## Get skill name for HUD display.
static func get_skill_name(tank_class: TankClasses.ClassType) -> String:
	match tank_class:
		TankClasses.ClassType.BASIC: return "Power Shot"
		TankClasses.ClassType.DEALER: return "Rapid Fire"
		TankClasses.ClassType.TANKER: return "Shield"
		TankClasses.ClassType.SUPPORT: return "Repair"
		TankClasses.ClassType.ARTILLERY: return "Barrage"
		TankClasses.ClassType.SCOUT: return "Dash"
	return "Skill"


## Get SP cost for skill.
static func get_skill_cost(tank_class: TankClasses.ClassType) -> int:
	match tank_class:
		TankClasses.ClassType.BASIC: return 20
		TankClasses.ClassType.DEALER: return 30
		TankClasses.ClassType.TANKER: return 25
		TankClasses.ClassType.SUPPORT: return 35
		TankClasses.ClassType.ARTILLERY: return 40
		TankClasses.ClassType.SCOUT: return 15
	return 20


## Power Shot: 2x damage single shot.
static func _power_shot(tank: TankBase) -> void:
	tank._fire_projectile(2.0, 0.0, 0.0)
	TankEffects.show_muzzle_flash(tank)


## Rapid Fire: 3 quick shots.
static func _rapid_fire(tank: TankBase) -> void:
	for i in range(3):
		var offset := randf_range(-3.0, 3.0)
		tank._fire_projectile(0.8, 0.0, offset)
	TankEffects.show_muzzle_flash(tank)


## Shield: 50% damage reduction for 5 seconds.
static func _shield(tank: TankBase) -> void:
	tank.shield_active = true
	tank.shield_reduction = 0.5
	tank.shield_timer = 5.0
	TankEffects.show_shield_visual(tank)


## Repair: heal 30% of max HP.
static func _repair(tank: TankBase) -> void:
	var heal_amount := tank.max_hp * 0.3
	tank.heal(heal_amount)
	TankEffects.show_heal_visual(tank)


## Barrage: 3 shots raining from above.
static func _barrage(tank: TankBase) -> void:
	var base_angle := tank.barrel_angle
	for i in range(3):
		var spread := (i - 1) * 8.0
		var power_mult := 1.0 + (i * 0.15)
		tank.barrel_angle = base_angle - 20.0 + spread
		tank._fire_projectile(0.7, 0.0, 0.0)
	tank.barrel_angle = base_angle
	TankEffects.show_muzzle_flash(tank)


## Dash: teleport forward/backward, invincible during dash.
static func _dash(tank: TankBase) -> void:
	tank.dash_active = true
	var dash_dir := 1.0 if tank.facing_right else -1.0
	var dash_distance := 150.0

	var tween := tank.create_tween()
	tween.tween_property(tank, "position:x", tank.position.x + dash_dir * dash_distance, 0.2)
	tween.tween_callback(func(): tank.dash_active = false)

	TankEffects.show_dash_visual(tank)
