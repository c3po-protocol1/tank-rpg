class_name BulletTypes
extends RefCounted

## Bullet type definitions per tank class.

enum BulletType {
	STANDARD,
	HEAVY,
}

## Bullet data: gauge_speed controls how fast the power gauge oscillates.
## Higher = harder to aim accurately.
const BULLET_DATA: Dictionary = {
	BulletType.STANDARD: {
		"name": "Standard",
		"damage_mult": 1.0,
		"gauge_speed": 1.0,
		"radius": 20.0,
		"color": Color(0.85, 0.55, 0.15),
	},
	BulletType.HEAVY: {
		"name": "Heavy",
		"damage_mult": 1.8,
		"gauge_speed": 2.5,
		"radius": 35.0,
		"color": Color(0.7, 0.3, 0.1),
	},
}


## Get available bullet types for a tank class.
static func get_bullet_types(tank_class: TankClasses.ClassType) -> Array:
	match tank_class:
		TankClasses.ClassType.BASIC:
			return [BulletType.STANDARD, BulletType.HEAVY]
		TankClasses.ClassType.DEALER:
			return [BulletType.STANDARD, BulletType.HEAVY]
		TankClasses.ClassType.TANKER:
			return [BulletType.STANDARD, BulletType.HEAVY]
		TankClasses.ClassType.SUPPORT:
			return [BulletType.STANDARD, BulletType.HEAVY]
		TankClasses.ClassType.ARTILLERY:
			return [BulletType.STANDARD, BulletType.HEAVY]
		TankClasses.ClassType.SCOUT:
			return [BulletType.STANDARD, BulletType.HEAVY]
	return [BulletType.STANDARD]


## Get bullet data dict.
static func get_data(bullet_type: BulletType) -> Dictionary:
	return BULLET_DATA.get(bullet_type, BULLET_DATA[BulletType.STANDARD])
