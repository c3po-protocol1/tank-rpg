#!/bin/bash
# Tank RPG — Structure Verification
# Checks that required files and directories exist

set -e
cd "$(dirname "$0")/../.."

echo "📁 Structure Check"
echo "==================="

ERRORS=0

# Required files
for f in CLAUDE.md project.godot export_presets.cfg \
         data/tank_classes.gd data/stage_data.gd data/upgrade_tree.gd data/colors.gd \
         scripts/autoload/game_manager.gd scripts/autoload/player_data.gd \
         scripts/autoload/stage_manager.gd scripts/autoload/sfx_manager.gd \
         docs/design/game-design-document.md docs/architecture/layer-rules.md \
         docs/architecture/golden-principles.md; do
    if [ ! -f "$f" ]; then
        echo "  ❌ Missing: $f"
        ERRORS=$((ERRORS + 1))
    fi
done

# Required directories
for d in data scripts/autoload scripts/systems scripts/tanks scripts/combat \
         scenes docs/design docs/architecture docs/plans docs/quality docs/tech-debt; do
    if [ ! -d "$d" ]; then
        echo "  ❌ Missing dir: $d"
        ERRORS=$((ERRORS + 1))
    fi
done

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo "❌ $ERRORS missing items"
    exit 1
else
    echo "  ✅ All required files and directories present"
    exit 0
fi
