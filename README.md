# Tank RPG — 2D Side-Scrolling Tank RPG

인디 모바일 탱크 RPG. 스테이지를 클리어하고, 경험치를 얻고, 탱크를 업그레이드하세요.

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Engine | Godot 4.6+ |
| Language | GDScript 2.0 |
| Platform | iOS, Android |
| Art Style | Cartoon, brown/muted tones |

## Development Setup

### 1. Install Godot 4

**macOS (Homebrew):**
```bash
brew install --cask godot
```

**macOS (manual):**
- Download from https://godotengine.org/download
- Move `Godot.app` to `/Applications/`

**Verify:**
```bash
godot --version
# Should output: 4.6.x.stable...
```

### 2. Clone & Open

```bash
git clone https://github.com/c3po-protocol1/tank-rpg.git
cd tank-rpg
```

**Open in Godot Editor:**
```bash
godot --editor --path .
```

Or: Open Godot → Import → select `project.godot`

### 3. Run the Game

**From Godot Editor:**
- Press `F5` (or ▶️ Play button)

**From terminal:**
```bash
godot --path .
```

**Headless (CI/testing):**
```bash
godot --headless --path . --quit-after 5
```

### 4. Run Tests

```bash
# Full validation (file sizes, structure, tests)
bash scripts/ci/validate.sh

# Tests only (30 automated tests)
godot --headless --path . --script scripts/ci/test_runner.gd

# Structure check
bash scripts/ci/structure.sh

# Screenshot capture (requires Peekaboo on macOS)
bash scripts/ci/screenshot.sh
```

### 5. Controls

| Action | Keyboard | Touch |
|--------|----------|-------|
| Move | A / D | L / R buttons |
| Aim | W / S | Up / Down buttons |
| Fire | Space | FIRE button |
| Skill | E | SKILL button |

## Project Structure

```
tank-rpg/
├── CLAUDE.md              # Agent index (for Claude Code)
├── README.md              # This file
├── project.godot          # Godot project config
├── data/                  # Game data (stats, stages, colors)
├── scripts/
│   ├── autoload/          # Global singletons
│   ├── systems/           # Game systems (battle, HUD, terrain)
│   ├── tanks/             # Tank entities (player, enemy, base)
│   ├── combat/            # Projectiles
│   └── ci/                # Test runner, validation scripts
├── scenes/                # Godot scene files (.tscn)
└── docs/                  # Design docs, architecture, plans
```

## Gameplay

- **Stage-based**: Clear enemies → XP → upgrade → next stage
- **6 tank classes**: Basic, Dealer, Tanker, Support, Artillery, Scout
- **Boss fights**: Sub-boss every 5 stages, Boss every 10
- **Skills**: Each class has a unique ability (costs SP)
- **Destructible terrain**: Projectiles create craters

## Mobile Export

Export presets for iOS and Android are in `export_presets.cfg`.

```bash
# Android
godot --headless --path . --export-release Android

# iOS
godot --headless --path . --export-release iOS
```

## License

Private project.
