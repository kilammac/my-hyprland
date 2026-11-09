#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
run_dir=$(mktemp -d /tmp/cassette-check.XXXXXX)
trap 'rm -rf -- "$run_dir"' EXIT
mkdir -p "$run_dir/bin" /tmp/cassette-test-audio
export XDG_RUNTIME_DIR="$run_dir"
export XDG_STATE_HOME="$run_dir/state"
export QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=basic QT_QUICK_CONTROLS_STYLE=Basic QT_QUICK_BACKEND=software
ffmpeg -v error -f lavfi -i 'sine=frequency=440:duration=4' -metadata title='Bande de test' -metadata artist='Arch Test' -y '/tmp/cassette-test-audio/01 été.wav'
ffmpeg -v error -f lavfi -i 'sine=frequency=880:duration=4' -y '/tmp/cassette-test-audio/02.wav'
timeout 20s qs -p TestEngine.qml --no-color 2>&1 | tee "$run_dir/engine.log"
rg -q 'PASS: folder' "$run_dir/engine.log"
# Deterministic Cava substitute: checks stdin configuration on both launches.
cat > "$run_dir/bin/cava" <<'MOCK'
#!/usr/bin/env python3
import sys,time
config=sys.stdin.read()
if '[input]' not in config: sys.exit(1)
print('25;75;',flush=True)
time.sleep(3)
MOCK
chmod +x "$run_dir/bin/cava"
PATH="$run_dir/bin:$PATH" timeout 5s qs -p TestMeters.qml --no-color 2>&1 | tee "$run_dir/meters.log"
rg -q 'METERS PASS' "$run_dir/meters.log"
timeout 5s qs -p TestYoutube.qml --no-color 2>&1 | tee "$run_dir/youtube.log"
rg -q 'YOUTUBE PASS' "$run_dir/youtube.log"
timeout 5s qs -p TestHistory.qml --no-color 2>&1 | tee "$run_dir/history.log"
rg -q 'HISTORY PASS' "$run_dir/history.log"
CASSETTE_HISTORY_RELOAD=1 timeout 5s qs -p TestHistory.qml --no-color 2>&1 | tee "$run_dir/history-reload.log"
rg -q 'HISTORY RELOAD PASS' "$run_dir/history-reload.log"
timeout 5s qs -p TestVisual.qml --no-color 2>&1 | tee "$run_dir/visual.log"
rg -q 'VISUAL PASS' "$run_dir/visual.log"
/usr/lib/qt6/bin/qmllint --import disable --unresolved-type disable -I /usr/lib/qt6/qml DeckEngine.qml DeckController.qml YoutubeEngine.qml YoutubeHistory.qml MeterFeed.qml DeckWindow.qml Reel.qml Cassette.qml VuMeter.qml DeckButton.qml DeckSlider.qml
