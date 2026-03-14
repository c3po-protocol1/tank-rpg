# Tank RPG - Indie Mobile Game

A 2D side-scrolling tank RPG built with Godot 4. Kill enemy tanks, gain XP, upgrade stats, and evolve through class trees.

## Game Overview

- **Genre**: 2D Side-scrolling Tank RPG
- **Platform**: iOS + Android (Godot 4 mobile export)
- **Art Style**: Cartoon/comic, brown/muted color palette

## How to Play

- **Move**: Left/Right buttons (touch) or A/D keys
- **Aim**: Up/Down buttons (touch) or W/S keys
- **Fire**: FIRE button (touch) or Spacebar
- Projectiles follow physics arcs and create craters in terrain
- Destroy all enemies to clear a stage

## Game Flow

1. Start with a Basic Tank
2. Clear stages by destroying all enemy tanks
3. Gain XP from kills → Level up → Get stat points
4. Spend stat points on HP, ATK, DEF, SPD, RLD, RNG, SP
5. At level 10/25/50: unlock class changes (Dealer, Tanker, Support, Artillery, Scout)
6. Sub-boss every 5 stages, Boss every 10 stages

## Project Structure

```
tank-rpg/
├── project.godot          # Godot 4 project config (mobile-ready)
├── export_presets.cfg     # Android + iOS export presets
├── icon.svg               # App icon
├── scenes/
│   ├── main.tscn          # Entry scene (main menu)
│   ├── main_menu.tscn     # Main menu scene
│   ├── battle.tscn        # Battle stage scene
│   ├── projectiles/
│   │   └── projectile.tscn
│   └── ui/
│       ├── hud.tscn       # Battle HUD
│       └── upgrade_screen.tscn
├── scripts/
│   ├── autoload/
│   │   ├── game_manager.gd   # Game state, scene transitions
│   │   ├── player_data.gd    # Persistent player stats, XP, level
│   │   └── stage_manager.gd  # Stage progression, enemy tracking
│   ├── tanks/
│   │   ├── tank_base.gd      # Base class: movement, aiming, firing, HP
│   │   ├── player_tank.gd    # Player input (touch + keyboard)
│   │   └── enemy_tank.gd     # AI: aim at player, fire, move
│   ├── combat/
│   │   └── projectile.gd     # Physics arc, damage, explosions
│   └── systems/
│       ├── battle_controller.gd  # Stage setup, spawning, win/lose
│       ├── terrain_system.gd     # Destructible polygon terrain
│       ├── hud.gd                # HP/SP bars, touch controls
│       ├── upgrade_screen.gd     # Stat allocation, class change
│       └── main_menu.gd          # Title screen
├── data/
│   ├── tank_classes.gd    # Class definitions, base stats, evolution tree
│   ├── stage_data.gd      # Stage configs, enemy types, terrain presets
│   └── upgrade_tree.gd    # XP/level formulas, skill definitions
├── assets/
│   ├── sprites/
│   ├── fonts/
│   └── audio/
└── ui/
    ├── components/
    └── screens/
```

## Core Systems

### Tank Classes (RPG-style)
| Class | Role | Strengths |
|-------|------|-----------|
| Basic | Starter | Balanced stats |
| Dealer | DPS | High ATK, fast reload |
| Tanker | Tank | High HP, high DEF |
| Support | Healer | Repair, buffs, high SP |
| Artillery | Range | Long range, high damage |
| Scout | Speed | Fast movement, evasive |

### Stats
- **HP** - Health Points
- **ATK** - Attack Power (damage per shot)
- **DEF** - Defense (damage reduction: `damage * 100/(100+DEF)`)
- **SPD** - Movement Speed
- **RLD** - Reload Speed (seconds between shots)
- **RNG** - Range (projectile launch speed)
- **SP** - Skill Points (mana for abilities)

### Combat
- Physics-based projectile arcs
- Destructible terrain (polygon craters on impact)
- ATK vs DEF damage formula
- Enemy AI with configurable accuracy, fire rate, movement

### Progression
- XP from kills (scales with stage)
- 3 stat points per level
- Class evolution at levels 10, 25, 50
- Difficulty scaling: +15% per stage

## Tech Stack

- **Engine**: Godot 4.2+
- **Language**: GDScript 2.0
- **Rendering**: Mobile renderer (ETC2/ASTC)
- **Input**: Touch + keyboard (emulate_touch_from_mouse enabled)

## Development

Open in Godot 4.2+ and press F5 to run. Uses placeholder graphics (ColorRect, Polygon2D shapes).
