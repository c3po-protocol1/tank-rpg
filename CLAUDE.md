# CLAUDE.md — Tank RPG Harness

You are working on **Tank RPG**, a 2D side-scrolling tank RPG built in Godot 4.6+ (GDScript).
This file is your entry point. Read it first. Follow it always.

## Quick Start

```
Engine: Godot 4.6+ (GDScript 2.0)
Platform: iOS + Android (mobile-first)
Art: Cartoon style, brown/muted tones
```

## Documentation Map

| What | Where |
|------|-------|
| Game design (gameplay, classes, stages) | `docs/design/game-design-document.md` |
| Combat system (damage, projectiles, physics) | `docs/design/combat-system.md` |
| Progression (XP, levels, class evolution) | `docs/design/progression-system.md` |
| UI/UX spec (touch controls, screen flow) | `docs/design/ui-ux-spec.md` |
| Layer rules (dependency direction) | `docs/architecture/layer-rules.md` |
| Domain map (what goes where) | `docs/architecture/domain-map.md` |
| Golden principles (style, patterns) | `docs/architecture/golden-principles.md` |
| Roadmap & milestones | `docs/plans/roadmap.md` |
| Decision log | `docs/plans/decision-log.md` |
| Quality grades | `docs/quality/grades.md` |
| Pre-merge checklist | `docs/quality/checklist.md` |
| Tech debt tracker | `docs/tech-debt/tracker.md` |

## Architecture — Layer Rules (MANDATORY)

One-way dependency only. Never import backwards.

```
Data → Systems → Entities → Scenes → UI

data/                 # ZERO imports. Pure data definitions.
scripts/autoload/     # Import data/ only. Global singletons.
scripts/systems/      # Import data/ + autoload/.
scripts/tanks/        # Import data/ + autoload/ + systems/.
scripts/combat/       # Import data/ + autoload/ + systems/.
scenes/               # Can wire anything above.
ui/                   # Can wire anything above.
```

**If you violate this, stop and restructure.**

## Golden Principles

1. `class_name` on every script
2. Type everything: `var x: int`, `func foo() -> void`
3. Signals over direct references between nodes
4. Max 200 lines per file — split if larger
5. No magic numbers — use constants or `data/` files
6. Every public function gets a `##` doc comment
7. Colors: use `data/colors.gd` constants (brown palette only)
8. Touch-first: every interactive element min 44×44px
9. All game balance data in `data/` — never hardcode stats
10. `snake_case` for files, variables, functions. `PascalCase` for class names.

## Validation

Before finishing any task, run:
```bash
# Structure check
bash scripts/ci/validate.sh

# Visual check (captures screenshot of running game)
bash scripts/ci/screenshot.sh
```

If validation fails, fix the issues before committing.

## Testing

```bash
# Run Godot headless import check
godot --headless --path . --import

# Run game for 5 seconds and capture
godot --headless --path . --quit-after 5
```

## File Size Rule

If any `.gd` file exceeds 200 lines, split it. No exceptions. This keeps agent context windows efficient and code reviewable.

## Commit Style

```
feat: description     # new feature
fix: description      # bug fix  
refactor: description # restructure
docs: description     # documentation
chore: description    # tooling, CI
```
