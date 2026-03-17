#!/bin/bash
# Tank RPG — Screenshot Capture via Peekaboo
# Captures the Godot editor or running game window
# Usage: bash scripts/ci/screenshot.sh [output_path]

set -e
cd "$(dirname "$0")/../.."

OUTPUT="${1:-screenshots/latest.png}"
mkdir -p "$(dirname "$OUTPUT")"

echo "📸 Tank RPG Screenshot Capture"
echo "================================"

if ! command -v peekaboo &>/dev/null; then
    echo "❌ peekaboo not installed. Run: brew install steipete/tap/peekaboo"
    exit 1
fi

# Try to find Godot window
GODOT_WINDOW=$(peekaboo list windows --json 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for w in data:
        title = w.get('title', '') or w.get('name', '')
        app = w.get('app', '') or w.get('ownerName', '')
        if 'godot' in title.lower() or 'godot' in app.lower() or 'tank' in title.lower():
            print(w.get('id', w.get('windowNumber', '')))
            break
except:
    pass
" 2>/dev/null || echo "")

if [ -n "$GODOT_WINDOW" ]; then
    echo "Found Godot window: $GODOT_WINDOW"
    peekaboo image --window "$GODOT_WINDOW" --output "$OUTPUT" 2>/dev/null || \
    peekaboo image --output "$OUTPUT"
else
    echo "⚠️  No Godot window found. Capturing full screen."
    peekaboo image --output "$OUTPUT"
fi

if [ -f "$OUTPUT" ]; then
    echo "✅ Screenshot saved: $OUTPUT"
    echo "   Size: $(wc -c < "$OUTPUT") bytes"
else
    echo "❌ Screenshot failed"
    exit 1
fi
