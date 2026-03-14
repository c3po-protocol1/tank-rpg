extends Node

## Global game manager. Handles game state, scene transitions, and core game loop.

signal game_state_changed(new_state: GameState)
signal stage_started(stage_number: int)
signal stage_completed(stage_number: int)
signal game_over

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	STAGE_CLEAR,
	UPGRADE,
	GAME_OVER,
}

var current_state: GameState = GameState.MENU:
	set(value):
		current_state = value
		game_state_changed.emit(value)

var is_playing: bool:
	get: return current_state == GameState.PLAYING


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func start_game() -> void:
	PlayerData.reset()
	StageManager.current_stage = 1
	current_state = GameState.PLAYING
	_load_battle_scene()


func start_stage(stage_number: int) -> void:
	StageManager.current_stage = stage_number
	current_state = GameState.PLAYING
	_load_battle_scene()
	stage_started.emit(stage_number)


func complete_stage() -> void:
	current_state = GameState.STAGE_CLEAR
	stage_completed.emit(StageManager.current_stage)


func advance_to_next_stage() -> void:
	StageManager.current_stage += 1
	current_state = GameState.PLAYING
	_load_battle_scene()


func open_upgrade_screen() -> void:
	current_state = GameState.UPGRADE
	get_tree().change_scene_to_file("res://scenes/ui/upgrade_screen.tscn")


func trigger_game_over() -> void:
	current_state = GameState.GAME_OVER
	game_over.emit()


func return_to_menu() -> void:
	current_state = GameState.MENU
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true


func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false


func _load_battle_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/battle.tscn")
