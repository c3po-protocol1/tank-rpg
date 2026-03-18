# Tank RPG — Project Summary

> Last updated: 2026-03-18
> Repo: https://github.com/c3po-protocol1/tank-rpg
> Location: /Users/c-3po/Projects/tank-rpg
> Engine: Godot 4.6.1 (GDScript)
> Stats: 27 files, 3,655 lines, 16 commits

---

## What Is This?

A 2D side-scrolling tank RPG for iOS/Android. Cartoon style, brown/muted tones.
- Stage-based: kill enemies → earn XP → upgrade → next stage
- 6 tank classes with evolution tree
- Sub-boss every 5 stages, Boss every 10
- Destructible terrain (craters from projectile hits)
- Power gauge firing system (press F to charge, press again to fire)
- 2 bullet types per class (Standard + Heavy)

---

## What Was Built (Phases)

### Phase 1 — Core Systems ✅
- Godot 4 project structure
- Tank base class (CharacterBody2D) with stats (HP, ATK, DEF, SPD, RLD, RNG, SP)
- Player tank with input, Enemy tank with AI
- Projectile with physics arc + gravity
- Destructible terrain (Polygon2D with crater subtraction)
- Stage manager, XP/level system, class evolution tree
- 6 tank classes: Basic, Dealer, Tanker, Support, Artillery, Scout

### Phase 2 — Playable Game ✅
- 6 class skills (Power Shot, Rapid Fire, Shield, Repair, Barrage, Dash)
- Save/Load system (JSON, auto-save after stage clear)
- Visual polish (polygon tank shapes, explosions, damage numbers, screen shake)
- Procedural SFX manager
- Boss system with visual indicators
- Full game loop: Menu → Battle → Victory → Upgrade → Next Stage

### Phase 3 — Harness Environment ✅ (OpenAI-style)
- CLAUDE.md (31 lines, index only — points to docs/)
- docs/design/ — game design doc, combat system, progression, UI/UX
- docs/architecture/ — layer rules, domain map, golden principles
- docs/plans/ — roadmap, decision log
- docs/quality/ — grades, pre-merge checklist
- docs/tech-debt/ — tracker
- data/colors.gd — brown palette constants
- scripts/ci/validate.sh — file sizes, class_names, layer deps, Godot import, tests
- scripts/ci/test_runner.gd — 30 automated headless tests
- scripts/ci/structure.sh — required files check
- scripts/ci/screenshot.sh — Peekaboo visual capture

### Phase 4 — Combat Mechanics (partial) ⚠️
- Power gauge: press F to start charging, press F again to fire
  - Gauge oscillates 0→1→0→1... (like Worms/artillery games)
  - Power = range only (30% to 100% of max speed)
- 2 bullet types: Standard (normal gauge) + Heavy (1.8x damage, 2.5x faster gauge)
- Bullet switch: D key
- Controls changed: arrows=move/aim, F=fire, D=switch, S=skill

---

## Known Issues (when we left off)

1. **Power gauge may not be visible/working in HUD** — needs testing
2. **F key firing** — code is correct but needs in-game verification
3. **Heavy bullet gauge speed** — tuning needed
4. **Collision callbacks** — fixed with call_deferred but needs testing
5. **File splitting** — caused many issues; all fixed now but some static helpers use `Node` type instead of `TankBase` to avoid cyclic references

---

## Architecture

### Layer Rules (one-way dependency)
```
data/ → scripts/autoload/ → scripts/systems/ → scripts/tanks/ + scripts/combat/ → scenes/
```

### Key Files

| File | Purpose |
|------|---------|
| CLAUDE.md | Agent entry point (index to docs) |
| README.md | Setup guide (install, run, test) |
| project.godot | Godot config, input map, autoloads |
| data/tank_classes.gd | 6 tank class definitions + stats |
| data/stage_data.gd | Stage generation, enemy types |
| data/upgrade_tree.gd | XP formulas, skill definitions |
| data/bullet_types.gd | Standard + Heavy bullet specs |
| data/colors.gd | Brown palette constants |
| scripts/tanks/tank_base.gd | Core tank: move, aim, fire, HP, power gauge |
| scripts/tanks/player_tank.gd | Player input handling |
| scripts/tanks/enemy_tank.gd | AI behavior |
| scripts/systems/battle_controller.gd | Stage orchestrator |
| scripts/systems/hud.gd | HUD display |
| scripts/ci/test_runner.gd | 30 automated tests |
| scripts/ci/validate.sh | Full validation suite |

### Autoloads (registered in project.godot)
- GameManager — game state machine, scene transitions
- PlayerData — player stats, XP, save/load
- StageManager — enemy tracking, stage progression
- SfxManager — procedural sound effects

---

## Controls

| Action | Key | Touch |
|--------|-----|-------|
| Move | ← → | L/R buttons |
| Aim | ↑ ↓ | Up/Down buttons |
| Fire (charge/shoot) | F (press twice) | FIRE button |
| Switch bullet | D | D button |
| Special skill | S | SKILL button |

---

## How to Run

```bash
# Install Godot
brew install --cask godot

# Run game
cd /Users/c-3po/Projects/tank-rpg
godot --path .

# Run tests
bash scripts/ci/validate.sh

# Run in editor
godot --editor --path .
```

---

## What to Do Next

1. **Fix & verify power gauge** — make sure F key charging works visually
2. **Tune bullet types** — balance damage/gauge speed
3. **Test full game loop** — play through multiple stages
4. **More enemy types** — tier 2/3 class evolutions
5. **Sound & music** — replace procedural SFX with real audio
6. **Mobile build** — test on actual iOS/Android device
7. **Terrain variety** — snow, desert, urban backgrounds
8. **Tutorial** — onboarding for new players
