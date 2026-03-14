class_name StageData
extends RefCounted

## Stage configuration data. Defines enemy counts, types, and terrain for each stage.

const TERRAIN_PRESETS: Dictionary = {
	"flat": {
		"hills": 0,
		"roughness": 0.0,
	},
	"gentle_hills": {
		"hills": 3,
		"roughness": 0.3,
	},
	"hilly": {
		"hills": 5,
		"roughness": 0.5,
	},
	"mountainous": {
		"hills": 7,
		"roughness": 0.8,
	},
}

# Enemy types map to TankClasses.ClassType for their stats
enum EnemyType {
	GRUNT,       # Basic tank
	HEAVY,       # Tanker-like
	SNIPER,      # Artillery-like
	SPEEDSTER,   # Scout-like
	SUB_BOSS,
	BOSS,
}

const ENEMY_DATA: Dictionary = {
	EnemyType.GRUNT: {
		"name": "Grunt",
		"stat_multiplier": 0.8,
		"xp_value": 10,
		"color": Color(0.45, 0.4, 0.35),
	},
	EnemyType.HEAVY: {
		"name": "Heavy",
		"stat_multiplier": 1.0,
		"xp_value": 20,
		"color": Color(0.35, 0.4, 0.3),
	},
	EnemyType.SNIPER: {
		"name": "Sniper",
		"stat_multiplier": 0.9,
		"xp_value": 15,
		"color": Color(0.5, 0.35, 0.3),
	},
	EnemyType.SPEEDSTER: {
		"name": "Speedster",
		"stat_multiplier": 0.7,
		"xp_value": 12,
		"color": Color(0.55, 0.5, 0.35),
	},
	EnemyType.SUB_BOSS: {
		"name": "Sub-Boss",
		"stat_multiplier": 1.8,
		"xp_value": 50,
		"color": Color(0.6, 0.3, 0.2),
	},
	EnemyType.BOSS: {
		"name": "Boss",
		"stat_multiplier": 3.0,
		"xp_value": 100,
		"color": Color(0.7, 0.25, 0.15),
	},
}

static func get_stage_config(stage_number: int) -> Dictionary:
	var config := {
		"stage_number": stage_number,
		"enemies": _generate_enemies(stage_number),
		"terrain": _get_terrain_preset(stage_number),
		"difficulty_scale": 1.0 + (stage_number - 1) * 0.15,
	}
	return config

static func _generate_enemies(stage: int) -> Array[Dictionary]:
	var enemies: Array[Dictionary] = []

	# Boss every 10 stages
	if stage % 10 == 0:
		enemies.append({
			"type": EnemyType.BOSS,
			"level": stage,
		})
		# Add some grunts alongside boss
		for i in range(mini(stage / 5, 3)):
			enemies.append({ "type": EnemyType.GRUNT, "level": stage - 2 })
		return enemies

	# Sub-boss every 5 stages
	if stage % 5 == 0:
		enemies.append({
			"type": EnemyType.SUB_BOSS,
			"level": stage,
		})
		for i in range(mini(stage / 5, 2)):
			enemies.append({ "type": EnemyType.GRUNT, "level": stage - 1 })
		return enemies

	# Normal stages: scale enemy count with stage number
	var enemy_count := mini(1 + stage / 3, 6)
	for i in range(enemy_count):
		var type := _pick_enemy_type(stage, i)
		enemies.append({
			"type": type,
			"level": maxi(1, stage - randi() % 3),
		})

	return enemies

static func _pick_enemy_type(stage: int, index: int) -> EnemyType:
	if stage < 5:
		return EnemyType.GRUNT
	if stage < 10:
		if index == 0 and stage >= 7:
			return EnemyType.HEAVY
		return EnemyType.GRUNT
	# After stage 10, mix enemy types
	var roll := randf()
	if roll < 0.4:
		return EnemyType.GRUNT
	elif roll < 0.6:
		return EnemyType.HEAVY
	elif roll < 0.8:
		return EnemyType.SNIPER
	else:
		return EnemyType.SPEEDSTER

static func _get_terrain_preset(stage: int) -> String:
	if stage <= 3:
		return "flat"
	elif stage <= 7:
		return "gentle_hills"
	elif stage <= 15:
		return "hilly"
	else:
		return "mountainous"

static func get_xp_for_enemy(enemy_type: EnemyType, stage: int) -> int:
	var base_xp: int = ENEMY_DATA[enemy_type]["xp_value"]
	return int(base_xp * (1.0 + stage * 0.1))
