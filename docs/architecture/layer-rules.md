# Architecture Layer Rules

## Dependency Direction (ONE-WAY ONLY)

```
data/ → scripts/autoload/ → scripts/systems/ → scripts/tanks/ + scripts/combat/ → scenes/ → ui/
```

### Layer Definitions

| Layer | Directory | Can Import | Cannot Import |
|-------|-----------|------------|---------------|
| **Data** | `data/` | Nothing (zero deps) | Everything else |
| **Autoload** | `scripts/autoload/` | `data/` | systems, tanks, combat, scenes, ui |
| **Systems** | `scripts/systems/` | `data/`, autoloads (via singleton) | tanks, combat, scenes, ui |
| **Entities** | `scripts/tanks/`, `scripts/combat/` | `data/`, autoloads, systems | scenes, ui |
| **Scenes** | `scenes/` | Wires any script above | ui (should not directly depend) |
| **UI** | `ui/`, HUD scripts | Everything above | — |

### Rules

1. **Data layer has ZERO imports.** It defines enums, constants, static functions. That's it.
2. **Autoloads reference data only.** They are global singletons (GameManager, PlayerData, StageManager, SfxManager).
3. **Systems reference data + autoloads.** Terrain, battle controller, upgrade screen logic.
4. **Entities reference data + autoloads + systems.** Tanks, projectiles — game objects.
5. **Scenes wire everything together** via `.tscn` files. They attach scripts to nodes.
6. **UI can read from anywhere** but should not contain game logic.

### Violation = Error

If a linter or review finds a backwards dependency:
```
ERROR: data/tank_classes.gd imports from scripts/autoload/player_data.gd
FIX: Data layer must have zero imports. Move the needed function to data/ or pass it as a parameter.
```

Agent: if you see this error, restructure immediately. Do not workaround.
