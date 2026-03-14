extends Node

## Manages stage progression, enemy spawning, and stage completion tracking.

signal all_enemies_defeated
signal enemy_spawned(enemy: Node2D)
signal enemy_killed(enemy: Node2D, xp: int)

var current_stage: int = 1
var enemies_alive: int = 0
var stage_config: Dictionary = {}


func load_stage_config() -> Dictionary:
	stage_config = StageData.get_stage_config(current_stage)
	return stage_config


func register_enemy() -> void:
	enemies_alive += 1


func on_enemy_killed(enemy: Node2D, enemy_type: StageData.EnemyType) -> void:
	enemies_alive -= 1
	var xp_reward := StageData.get_xp_for_enemy(enemy_type, current_stage)
	PlayerData.add_xp(xp_reward)
	enemy_killed.emit(enemy, xp_reward)

	if enemies_alive <= 0:
		all_enemies_defeated.emit()


func get_difficulty_scale() -> float:
	return stage_config.get("difficulty_scale", 1.0)


func is_boss_stage() -> bool:
	return current_stage % 10 == 0


func is_sub_boss_stage() -> bool:
	return current_stage % 5 == 0 and not is_boss_stage()


func reset_stage() -> void:
	enemies_alive = 0
	stage_config = {}
