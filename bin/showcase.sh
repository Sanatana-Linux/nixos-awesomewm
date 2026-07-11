#!/usr/bin/env bash
# showcase.sh — Record AwesomeWM showcase GIFs using giph
#
# Usage:
#   ./bin/showcase.sh <notification-text> <duration-seconds>
#
# Records the whole screen after a 3-second countdown.
# Sends a desktop notification when recording starts.
# Output: .github/assets/showcase/<slug>.gif (1.6× speed, 30 FPS)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

notification="${1:-}"
duration="${2:-}"

if [[ -z "$notification" || -z "$duration" ]]; then
	echo "Usage: $0 <notification-text> <duration-seconds>"
	echo "Example: ./bin/showcase.sh 'Volume: 75%' 10"
	exit 1
fi

# Derive filename slug from notification text
slug="$(echo "$notification" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g; s/^-//; s/-$//')"

out_dir="$PROJECT_DIR/.github/assets/showcase"
tmp_dir="$(mktemp -d /tmp/showcase-XXXXXX)"
cleanup() { rm -rf "$tmp_dir"; }
trap cleanup EXIT

mkdir -p "$out_dir"

raw="$tmp_dir/raw.mp4"
sped="$tmp_dir/sped.mp4"
palette="$tmp_dir/palette.png"

# Countdown
echo "Recording '$slug' in 3 seconds — $duration s"
for i in 3 2 1; do sleep 1; done

# Record with giph
giph -d 0 -t "$duration" -f 30 "$raw" &
sleep 0.5
notify-send -t 4000 "Showcase" "$notification" 2>/dev/null || true
wait

# Speed up 1.6×
ffmpeg -y -hide_banner -loglevel warning -i "$raw" \
	-filter:v "setpts=PTS/1.6" -an "$sped"

# Convert to GIF
ffmpeg -y -hide_banner -loglevel warning -i "$sped" \
	-vf "fps=30,palettegen=stats_mode=diff" \
	-frames:v 1 -update 1 "$palette"

ffmpeg -y -hide_banner -loglevel warning -i "$sped" -i "$palette" \
	-lavfi "fps=30 [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=5" \
	"$out_dir/$slug.gif"

# Optimize
gifsicle -O3 --colors=192 "$out_dir/$slug.gif" -o "$tmp_dir/opt.gif"
mv "$tmp_dir/opt.gif" "$out_dir/$slug.gif"

echo "Done: $out_dir/$slug.gif ($(du -h "$out_dir/$slug.gif" | cut -f1))"
