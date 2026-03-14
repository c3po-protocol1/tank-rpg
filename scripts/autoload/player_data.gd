extends Node

## Persistent player data: level, XP, stats, class, upgrades, and save/load.

signal xp_gained(amount: int)
signal level_up(new_level: int)
signal stat_points_available(points: int)
signal class_changed(new_class: TankClasses.ClassType)

const SAVE_PATH := "user://save_data.json"

var tank_class: TankClasses.ClassType = TankClasses.ClassType.BASIC
var level: int = 1
var xp: int = 0
var stat_points: int = 0

var bonus_stats: Dictionary = {
	"hp": 0.0, "atk": 0.0, "def": 0.0, "spd": 0.0,
	"rld": 0.0, "rng": 0.0, "sp": 0.0,
}

var current_hp: float = 0.0
var current_sp: float = 0.0


func reset() -> void:
	tank_class = TankClasses.ClassType.BASIC
	level = 1
	xp = 0
	stat_points = 0
	bonus_stats = { "hp": 0.0, "atk": 0.0, "def": 0.0, "spd": 0.0, "rld": 0.0, "rng": 0.0, "sp": 0.0 }
	current_hp = get_stat("hp")
	current_sp = get_stat("sp")


func get_stat(stat: String) -> float:
	var base := TankClasses.get_stat_at_level(tank_class, stat, level)
	return base + bonus_stats.get(stat, 0.0)


func get_max_hp() -> float:
	return get_stat("hp")


func get_max_sp() -> float:
	return get_stat("sp")


func add_xp(amount: int) -> void:
	xp += amount
	xp_gained.emit(amount)
	_check_level_up()


func _check_level_up() -> void:
	var xp_needed := UpgradeTree.xp_for_level(level)
	while xp >= xp_needed:
		xp -= xp_needed
		level += 1
		stat_points += UpgradeTree.STAT_POINTS_PER_LEVEL
		level_up.emit(level)
		stat_points_available.emit(stat_points)
		xp_needed = UpgradeTree.xp_for_level(level)


func spend_stat_point(stat: String) -> bool:
	var cost: int = UpgradeTree.STAT_COSTS.get(stat, 1)
	if stat_points < cost:
		return false
	stat_points -= cost
	bonus_stats[stat] += UpgradeTree.STAT_INCREMENTS.get(stat, 0.0)
	return true


func change_class(new_class: TankClasses.ClassType) -> bool:
	var available := TankClasses.get_available_evolutions(tank_class)
	if new_class not in available:
		return false
	if not TankClasses.can_evolve(tank_class, level):
		return false
	tank_class = new_class
	class_changed.emit(new_class)
	return true


func heal_full() -> void:
	current_hp = get_max_hp()
	current_sp = get_max_sp()


func xp_to_next_level() -> int:
	return UpgradeTree.xp_for_level(level)


func xp_progress() -> float:
	var needed := xp_to_next_level()
	if needed <= 0:
		return 1.0
	return float(xp) / float(needed)


# --- SAVE / LOAD ---

func save_game() -> void:
	var data := {
		"tank_class": tank_class,
		"level": level,
		"xp": xp,
		"stat_points": stat_points,
		"bonus_stats": bonus_stats.duplicate(),
		"current_stage": StageManager.current_stage,
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		return false

	var data: Dictionary = json.data
	if not data is Dictionary:
		return false

	tank_class = int(data.get("tank_class", 0)) as TankClasses.ClassType
	level = int(data.get("level", 1))
	xp = int(data.get("xp", 0))
	stat_points = int(data.get("stat_points", 0))
	StageManager.current_stage = int(data.get("current_stage", 1))

	var saved_bonus: Dictionary = data.get("bonus_stats", {})
	for key in bonus_stats:
		bonus_stats[key] = float(saved_bonus.get(key, 0.0))

	current_hp = get_max_hp()
	current_sp = get_max_sp()
	return true


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
