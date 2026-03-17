class_name TestRunner
extends SceneTree

## Headless test runner. Validates game systems without visual display.
## Run: godot --headless --path . --script scripts/ci/test_runner.gd

var tests_passed: int = 0
var tests_failed: int = 0
var errors: Array[String] = []

func _init() -> void:
	print("🧪 Tank RPG — Automated Test Suite")
	print("====================================")

	_test_data_layer()
	_test_tank_creation()
	_test_enemy_creation()
	_test_projectile_creation()
	_test_terrain_creation()
	_test_player_data()
	_test_stage_manager()
	_test_battle_scene_loads()
	_test_main_menu_loads()
	_test_upgrade_screen_loads()

	print("")
	print("====================================")
	if tests_failed > 0:
		print("❌ FAILED: %d passed, %d failed" % [tests_passed, tests_failed])
		for e in errors:
			print("  → %s" % e)
		quit(1)
	else:
		print("✅ ALL PASSED: %d tests" % tests_passed)
		quit(0)


func _assert(condition: bool, test_name: String) -> void:
	if condition:
		tests_passed += 1
		print("  ✅ %s" % test_name)
	else:
		tests_failed += 1
		errors.append(test_name)
		print("  ❌ %s" % test_name)


func _test_data_layer() -> void:
	print("")
	print("📚 Data Layer")

	# TankClasses
	var basic := TankClasses.get_class_data(TankClasses.ClassType.BASIC)
	_assert(basic.size() > 0, "TankClasses.get_class_data returns data")
	_assert(basic.has("base_stats"), "Basic class has base_stats")

	var hp := TankClasses.get_stat_at_level(TankClasses.ClassType.BASIC, "hp", 1)
	_assert(hp > 0, "Basic HP at level 1 > 0 (got %d)" % int(hp))

	var hp10 := TankClasses.get_stat_at_level(TankClasses.ClassType.BASIC, "hp", 10)
	_assert(hp10 > hp, "HP grows with level (lv1=%d, lv10=%d)" % [int(hp), int(hp10)])

	# StageData
	var config := StageData.get_stage_config(1)
	_assert(config.has("enemies"), "Stage 1 config has enemies")
	_assert(config["enemies"].size() >= 1, "Stage 1 has at least 1 enemy")

	var config10 := StageData.get_stage_config(10)
	_assert(config10["enemies"].size() > config["enemies"].size(),
		"Stage 10 has more enemies than stage 1")

	# UpgradeTree
	var xp := UpgradeTree.xp_for_level(1)
	_assert(xp > 0, "XP for level 1 > 0 (got %d)" % xp)

	# Colors
	_assert(Colors.TANK_BASIC != Color.BLACK, "Colors.TANK_BASIC is defined")
	_assert(Colors.BG_DARK != Color.BLACK, "Colors.BG_DARK is defined")


func _test_tank_creation() -> void:
	print("")
	print("🔫 TankBase")

	# Test TankBase directly (avoids PlayerData autoload dependency)
	var tank: TankBase = TankBase.new()
	_assert(tank != null, "TankBase instantiates")
	_assert(tank is CharacterBody2D, "TankBase is CharacterBody2D")
	root.add_child(tank)
	# In --script mode, _ready may not fire. Call manually if needed.
	if tank.get_child_count() == 0:
		tank._ready()

	# Check collision shape exists
	var has_collision := false
	for child in tank.get_children():
		if child is CollisionShape2D:
			has_collision = true
			var shape: Shape2D = (child as CollisionShape2D).shape
			_assert(shape != null, "CollisionShape2D has shape assigned")
			_assert(shape is RectangleShape2D, "Shape is RectangleShape2D")
			break
	_assert(has_collision, "TankBase has CollisionShape2D (CRITICAL)")

	# Check stats initialized
	_assert(tank.max_hp > 0, "TankBase max_hp > 0 (got %d)" % int(tank.max_hp))
	_assert(tank.atk > 0, "TankBase atk > 0")
	_assert(tank.is_alive, "TankBase is_alive = true")
	_assert(tank.collision_layer == 2, "Tank collision_layer = 2")
	_assert(tank.collision_mask == 1, "Tank collision_mask = 1 (terrain)")

	tank.queue_free()


func _test_enemy_creation() -> void:
	print("")
	print("👾 Enemy Tank")

	var enemy: EnemyTank = EnemyTank.new()
	root.add_child(enemy)

	var has_collision := false
	for child in enemy.get_children():
		if child is CollisionShape2D:
			has_collision = true
			break
	_assert(has_collision, "EnemyTank has CollisionShape2D")
	_assert(enemy.max_hp > 0, "EnemyTank max_hp > 0")

	enemy.queue_free()


func _test_projectile_creation() -> void:
	print("")
	print("💥 Projectile")

	var scene := load("res://scenes/projectiles/projectile.tscn")
	_assert(scene != null, "Projectile scene loads")

	var proj: Node = scene.instantiate()
	_assert(proj != null, "Projectile instantiates")
	_assert(proj is Area2D, "Projectile is Area2D")

	proj.queue_free()


func _test_terrain_creation() -> void:
	print("")
	print("🏔️ Terrain")

	var terrain: TerrainSystem = TerrainSystem.new()
	root.add_child(terrain)
	terrain.generate("flat")

	_assert(terrain.get_child_count() > 0, "Terrain has children after generate")

	var surface_y := terrain.get_surface_y_at(200.0)
	_assert(surface_y != 0.0, "get_surface_y_at returns non-zero")

	terrain.queue_free()


func _test_player_data() -> void:
	print("")
	print("📊 PlayerData")

	var pd_script := load("res://scripts/autoload/player_data.gd")
	_assert(pd_script != null, "player_data.gd loads")


func _test_stage_manager() -> void:
	print("")
	print("🎯 StageManager")

	var sm_script := load("res://scripts/autoload/stage_manager.gd")
	_assert(sm_script != null, "stage_manager.gd loads")


func _test_battle_scene_loads() -> void:
	print("")
	print("🎬 Scene Loading")

	var battle := load("res://scenes/battle.tscn")
	_assert(battle != null, "battle.tscn loads")

	var menu := load("res://scenes/main_menu.tscn")
	_assert(menu != null, "main_menu.tscn loads")


func _test_main_menu_loads() -> void:
	var main := load("res://scenes/main.tscn")
	_assert(main != null, "main.tscn loads")


func _test_upgrade_screen_loads() -> void:
	var upgrade := load("res://scenes/ui/upgrade_screen.tscn")
	_assert(upgrade != null, "upgrade_screen.tscn loads")

	var hud := load("res://scenes/ui/hud.tscn")
	_assert(hud != null, "hud.tscn loads")
