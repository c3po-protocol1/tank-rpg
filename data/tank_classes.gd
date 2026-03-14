class_name TankClasses
extends RefCounted

## All tank class definitions with base stats and evolution tree.

enum ClassType {
	BASIC,
	DEALER,
	TANKER,
	SUPPORT,
	ARTILLERY,
	SCOUT,
	# Advanced classes (tier 2)
	DESTROYER,
	FORTRESS,
	MEDIC,
	HOWITZER,
	RECON,
}

# Base stats: hp, atk, def, spd, rld, rng, sp
const CLASS_DATA: Dictionary = {
	ClassType.BASIC: {
		"name": "Basic Tank",
		"description": "A standard tank. Jack of all trades.",
		"base_stats": { "hp": 100, "atk": 15, "def": 10, "spd": 80, "rld": 1.5, "rng": 300, "sp": 50 },
		"stat_growth": { "hp": 10, "atk": 2, "def": 1, "spd": 3, "rld": -0.02, "rng": 5, "sp": 5 },
		"skills": ["basic_shot"],
		"color": Color(0.55, 0.45, 0.35),  # Brown
		"unlock_level": 1,
	},
	ClassType.DEALER: {
		"name": "Dealer",
		"description": "High attack, fast reload. Glass cannon.",
		"base_stats": { "hp": 80, "atk": 25, "def": 6, "spd": 90, "rld": 0.8, "rng": 280, "sp": 60 },
		"stat_growth": { "hp": 6, "atk": 4, "def": 1, "spd": 3, "rld": -0.03, "rng": 5, "sp": 5 },
		"skills": ["rapid_fire", "piercing_shot"],
		"color": Color(0.7, 0.3, 0.2),  # Reddish brown
		"unlock_level": 10,
	},
	ClassType.TANKER: {
		"name": "Tanker",
		"description": "High HP and DEF. The frontline wall.",
		"base_stats": { "hp": 160, "atk": 12, "def": 20, "spd": 55, "rld": 2.0, "rng": 250, "sp": 40 },
		"stat_growth": { "hp": 18, "atk": 1, "def": 3, "spd": 1, "rld": -0.01, "rng": 3, "sp": 3 },
		"skills": ["shield", "fortify"],
		"color": Color(0.4, 0.45, 0.35),  # Olive
		"unlock_level": 10,
	},
	ClassType.SUPPORT: {
		"name": "Support",
		"description": "Heals and buffs allies. Future-ready.",
		"base_stats": { "hp": 90, "atk": 10, "def": 12, "spd": 70, "rld": 1.8, "rng": 260, "sp": 100 },
		"stat_growth": { "hp": 8, "atk": 1, "def": 2, "spd": 2, "rld": -0.01, "rng": 5, "sp": 10 },
		"skills": ["repair", "buff_attack"],
		"color": Color(0.4, 0.5, 0.4),  # Greenish
		"unlock_level": 10,
	},
	ClassType.ARTILLERY: {
		"name": "Artillery",
		"description": "Long range, high arc. Devastating but slow.",
		"base_stats": { "hp": 70, "atk": 30, "def": 5, "spd": 40, "rld": 3.0, "rng": 500, "sp": 50 },
		"stat_growth": { "hp": 5, "atk": 5, "def": 1, "spd": 1, "rld": -0.02, "rng": 15, "sp": 5 },
		"skills": ["barrage", "smoke_screen"],
		"color": Color(0.5, 0.4, 0.3),  # Dark tan
		"unlock_level": 10,
	},
	ClassType.SCOUT: {
		"name": "Scout",
		"description": "Fast and evasive. Hit and run tactics.",
		"base_stats": { "hp": 65, "atk": 14, "def": 7, "spd": 140, "rld": 1.2, "rng": 220, "sp": 70 },
		"stat_growth": { "hp": 5, "atk": 2, "def": 1, "spd": 8, "rld": -0.02, "rng": 3, "sp": 7 },
		"skills": ["dash", "mark_target"],
		"color": Color(0.6, 0.55, 0.4),  # Light khaki
		"unlock_level": 10,
	},
}

# Evolution tree: class -> available evolutions
const EVOLUTION_TREE: Dictionary = {
	ClassType.BASIC: [ClassType.DEALER, ClassType.TANKER, ClassType.SUPPORT, ClassType.ARTILLERY, ClassType.SCOUT],
	ClassType.DEALER: [ClassType.DESTROYER],
	ClassType.TANKER: [ClassType.FORTRESS],
	ClassType.SUPPORT: [ClassType.MEDIC],
	ClassType.ARTILLERY: [ClassType.HOWITZER],
	ClassType.SCOUT: [ClassType.RECON],
}

# Level thresholds for class changes
const CLASS_CHANGE_LEVELS: Array[int] = [10, 25, 50]

static func get_class_data(class_type: ClassType) -> Dictionary:
	return CLASS_DATA.get(class_type, CLASS_DATA[ClassType.BASIC])

static func get_base_stat(class_type: ClassType, stat: String) -> float:
	var data := get_class_data(class_type)
	return data["base_stats"].get(stat, 0.0)

static func get_stat_at_level(class_type: ClassType, stat: String, level: int) -> float:
	var data := get_class_data(class_type)
	var base: float = data["base_stats"].get(stat, 0.0)
	var growth: float = data["stat_growth"].get(stat, 0.0)
	return base + growth * (level - 1)

static func get_available_evolutions(class_type: ClassType) -> Array:
	return EVOLUTION_TREE.get(class_type, [])

static func can_evolve(class_type: ClassType, level: int) -> bool:
	if not EVOLUTION_TREE.has(class_type):
		return false
	for threshold in CLASS_CHANGE_LEVELS:
		if level == threshold:
			return true
	return false
