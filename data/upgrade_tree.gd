class_name UpgradeTree
extends RefCounted

## Manages class evolution tree, stat upgrades, and skill unlocks.

# XP required for each level: base + level * scale
const BASE_XP_PER_LEVEL := 50
const XP_SCALE_PER_LEVEL := 25

# How many stat points you get per level up
const STAT_POINTS_PER_LEVEL := 3

# Stat upgrade costs (how many points per +1 upgrade)
const STAT_COSTS: Dictionary = {
	"hp": 1,    # +10 HP per point
	"atk": 1,   # +2 ATK per point
	"def": 1,   # +2 DEF per point
	"spd": 1,   # +5 SPD per point
	"rld": 2,   # -0.05s reload per point
	"rng": 1,   # +10 range per point
	"sp": 1,    # +5 SP per point
}

# How much each stat point gives
const STAT_INCREMENTS: Dictionary = {
	"hp": 10.0,
	"atk": 2.0,
	"def": 2.0,
	"spd": 5.0,
	"rld": -0.05,
	"rng": 10.0,
	"sp": 5.0,
}

# Skill definitions
const SKILLS: Dictionary = {
	"basic_shot": {
		"name": "Basic Shot",
		"description": "Standard projectile.",
		"sp_cost": 0,
		"cooldown": 0.0,
		"unlock_level": 1,
	},
	"rapid_fire": {
		"name": "Rapid Fire",
		"description": "Fire 3 shots in quick succession.",
		"sp_cost": 20,
		"cooldown": 8.0,
		"unlock_level": 10,
	},
	"piercing_shot": {
		"name": "Piercing Shot",
		"description": "A powerful shot that ignores 50% DEF.",
		"sp_cost": 15,
		"cooldown": 6.0,
		"unlock_level": 15,
	},
	"shield": {
		"name": "Shield",
		"description": "Reduce incoming damage by 70% for 3 seconds.",
		"sp_cost": 25,
		"cooldown": 12.0,
		"unlock_level": 10,
	},
	"fortify": {
		"name": "Fortify",
		"description": "Cannot move but gain +100% DEF for 5 seconds.",
		"sp_cost": 30,
		"cooldown": 15.0,
		"unlock_level": 20,
	},
	"repair": {
		"name": "Repair",
		"description": "Restore 30% of max HP.",
		"sp_cost": 35,
		"cooldown": 10.0,
		"unlock_level": 10,
	},
	"buff_attack": {
		"name": "Attack Boost",
		"description": "Increase ATK by 50% for 5 seconds.",
		"sp_cost": 20,
		"cooldown": 12.0,
		"unlock_level": 15,
	},
	"barrage": {
		"name": "Barrage",
		"description": "Fire 5 shots in a spread pattern.",
		"sp_cost": 40,
		"cooldown": 15.0,
		"unlock_level": 10,
	},
	"smoke_screen": {
		"name": "Smoke Screen",
		"description": "Enemy accuracy reduced for 4 seconds.",
		"sp_cost": 15,
		"cooldown": 10.0,
		"unlock_level": 15,
	},
	"dash": {
		"name": "Dash",
		"description": "Quick burst of speed, invulnerable during dash.",
		"sp_cost": 15,
		"cooldown": 5.0,
		"unlock_level": 10,
	},
	"mark_target": {
		"name": "Mark Target",
		"description": "Marked enemy takes 30% more damage for 5 seconds.",
		"sp_cost": 20,
		"cooldown": 8.0,
		"unlock_level": 15,
	},
}

static func xp_for_level(level: int) -> int:
	return BASE_XP_PER_LEVEL + level * XP_SCALE_PER_LEVEL

static func total_xp_for_level(level: int) -> int:
	var total := 0
	for i in range(1, level):
		total += xp_for_level(i)
	return total

static func get_skill_data(skill_id: String) -> Dictionary:
	return SKILLS.get(skill_id, {})
