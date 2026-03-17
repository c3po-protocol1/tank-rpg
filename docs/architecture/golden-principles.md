# Golden Principles

These rules are non-negotiable. Every PR, every file, every function.

## Code Style

1. **`class_name` on every script** — makes classes globally addressable
2. **Type everything** — `var x: int`, `func foo(a: String) -> void:`
3. **`snake_case`** for files, variables, functions. **`PascalCase`** for class names
4. **Max 200 lines per `.gd` file** — split if larger. No exceptions.
5. **No magic numbers** — use named constants or `data/` files
6. **`##` doc comments** on every public function and exported variable
7. **Signals over direct references** — decouple nodes via signals

## Game-Specific

8. **Brown palette only** — use `data/colors.gd` for all colors
9. **Touch-first** — every button/interactive ≥ 44×44px
10. **All balance data in `data/`** — never hardcode HP, ATK, XP formulas in entity scripts
11. **Stateless data layer** — `data/` has only `static func` and `const`. No `var`. No side effects.

## Architecture

12. **One-way dependencies** — see `docs/architecture/layer-rules.md`
13. **Autoloads are singletons** — access via name (GameManager, PlayerData, etc.)
14. **Scenes are wiring only** — `.tscn` files attach scripts, set properties. No logic in scenes.
15. **One class per file** — no inner classes unless truly private

## Process

16. **Run validation before commit** — `bash scripts/ci/validate.sh`
17. **Commit messages** — `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`
18. **Screenshot verify** — for any visual change, capture with Peekaboo and verify

## When In Doubt

- Read the relevant doc in `docs/`
- If no doc exists, create one before coding
- If a principle conflicts with Godot best practice, follow Godot — but document why
