# CLAUDE.md — Tank RPG

2D side-scrolling tank RPG. Godot 4.6+ (GDScript). Mobile (iOS/Android).

## Where to Find Things

| Need | Location |
|------|----------|
| How to install & run | `README.md` |
| Game design & gameplay | `docs/design/game-design-document.md` |
| Combat mechanics | `docs/design/combat-system.md` |
| Progression & XP | `docs/design/progression-system.md` |
| UI/UX & controls | `docs/design/ui-ux-spec.md` |
| Layer dependency rules | `docs/architecture/layer-rules.md` |
| File/folder structure | `docs/architecture/domain-map.md` |
| Code style & principles | `docs/architecture/golden-principles.md` |
| Roadmap & milestones | `docs/plans/roadmap.md` |
| Decision log | `docs/plans/decision-log.md` |
| Quality grades | `docs/quality/grades.md` |
| Pre-merge checklist | `docs/quality/checklist.md` |
| Tech debt | `docs/tech-debt/tracker.md` |
| Color palette | `data/colors.gd` |

## Before Every Commit

```bash
bash scripts/ci/validate.sh
```

Runs: file sizes, class_names, layer deps, Godot import, 30 automated tests.
**Must pass. No exceptions.**
