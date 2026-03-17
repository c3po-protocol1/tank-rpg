#!/bin/bash
# Tank RPG — Harness Validation Script
# Run: bash scripts/ci/validate.sh

set -e
cd "$(dirname "$0")/../.."

ERRORS=0
WARNINGS=0

echo "🔍 Tank RPG Harness Validation"
echo "================================"

# 1. File size check (max 200 lines)
echo ""
echo "📏 Checking file sizes (max 200 lines)..."
while IFS= read -r f; do
    lines=$(wc -l < "$f")
    if [ "$lines" -gt 200 ]; then
        echo "  ❌ $f: $lines lines (max 200)"
        ERRORS=$((ERRORS + 1))
    fi
done < <(find . -name "*.gd" -not -path "./.godot/*" -not -path "./.git/*")

# 2. class_name check
echo ""
echo "🏷️  Checking class_name declarations..."
while IFS= read -r f; do
    if ! grep -q "^class_name " "$f"; then
        echo "  ❌ $f: missing class_name"
        ERRORS=$((ERRORS + 1))
    fi
done < <(find . -name "*.gd" -not -path "./.godot/*" -not -path "./.git/*" -not -path "*/autoload/*")

# 3. Layer dependency check (data/ must not import from scripts/)
echo ""
echo "🏗️  Checking layer dependencies..."
while IFS= read -r f; do
    if grep -qE "^(const|var).*preload\(|^(const|var).*load\(" "$f"; then
        echo "  ❌ $f: data layer must not use preload/load"
        ERRORS=$((ERRORS + 1))
    fi
    if grep -qE "GameManager|PlayerData|StageManager|SfxManager" "$f"; then
        echo "  ❌ $f: data layer must not reference autoloads"
        ERRORS=$((ERRORS + 1))
    fi
done < <(find ./data -name "*.gd" 2>/dev/null)

# 4. Magic number check (basic — looks for bare numbers in combat formulas)
echo ""
echo "🔢 Checking for obvious magic numbers..."
while IFS= read -r f; do
    # Skip data files (they're supposed to have numbers)
    [[ "$f" == ./data/* ]] && continue
    count=$(grep -cE "= [0-9]{2,}\." "$f" 2>/dev/null || true); count=${count:-0}
    if [ "$count" -gt 5 ]; then
        echo "  ⚠️  $f: $count potential magic numbers (review recommended)"
        WARNINGS=$((WARNINGS + 1))
    fi
done < <(find . -name "*.gd" -not -path "./.godot/*" -not -path "./.git/*")

# 5. Godot project import check
echo ""
echo "🎮 Checking Godot project import..."
if command -v godot &>/dev/null; then
    output=$(timeout 15 godot --headless --path . --import 2>&1)
    if echo "$output" | grep -qi "error"; then
        echo "  ❌ Godot import errors found"
        echo "$output" | grep -i "error" | head -5
        ERRORS=$((ERRORS + 1))
    else
        echo "  ✅ Godot project imports clean"
    fi
else
    echo "  ⚠️  godot not in PATH, skipping import check"
    WARNINGS=$((WARNINGS + 1))
fi

# Summary
echo ""
echo "================================"
if [ $ERRORS -gt 0 ]; then
    echo "❌ FAILED: $ERRORS errors, $WARNINGS warnings"
    exit 1
else
    echo "✅ PASSED: 0 errors, $WARNINGS warnings"
    exit 0
fi
