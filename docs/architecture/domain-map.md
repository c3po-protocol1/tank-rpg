# Domain Map

## Directory → Responsibility

```
tank-rpg/
├── CLAUDE.md                  # Agent entry point (this harness)
├── project.godot              # Godot project config
├── export_presets.cfg         # iOS + Android export
│
├── data/                      # Pure data. No imports.
│   ├── tank_classes.gd        # Class definitions, stats, evolution tree
│   ├── stage_data.gd          # Stage configs, enemy types, terrain
│   ├── upgrade_tree.gd        # XP formulas, skill definitions, costs
│   └── colors.gd              # Brown palette color constants
│
├── scripts/
│   ├── autoload/              # Global singletons (registered in project.godot)
│   │   ├── game_manager.gd    # Game state machine, scene transitions
│   │   ├── player_data.gd     # Player stats, XP, level, save/load
│   │   ├── stage_manager.gd   # Enemy tracking, stage progression
│   │   └── sfx_manager.gd     # Procedural sound effects
│   │
│   ├── systems/               # Game systems (non-entity)
│   │   ├── terrain_system.gd  # Destructible terrain, polygon generation
│   │   ├── battle_controller.gd # Stage orchestrator
│   │   ├── hud.gd             # HUD display logic
│   │   ├── upgrade_screen.gd  # Upgrade UI logic
│   │   └── main_menu.gd       # Main menu logic
│   │
│   ├── tanks/                 # Tank entities
│   │   ├── tank_base.gd       # Base class (movement, aim, fire, HP)
│   │   ├── player_tank.gd     # Player controls, skill usage
│   │   └── enemy_tank.gd      # AI behavior, enemy types
│   │
│   └── combat/                # Combat entities
│       └── projectile.gd      # Physics arc, explosion, crater
│
├── scenes/                    # Godot scene files (.tscn)
│   ├── main.tscn
│   ├── main_menu.tscn
│   ├── battle.tscn
│   ├── ui/
│   │   ├── hud.tscn
│   │   └── upgrade_screen.tscn
│   └── projectiles/
│       └── projectile.tscn
│
├── docs/                      # Knowledge base (see CLAUDE.md)
└── scripts/ci/                # Validation scripts
```
