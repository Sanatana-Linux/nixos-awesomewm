#!/usr/bin/env bash
# ┏━┓┳  o┏┓┓┏━┓┳ ┳┳  ┏━┓┏━┓┳┏ 
# ┃ ┳┃  ┃ ┃ ┃  ┃━┫┃  ┃ ┃┃  ┣┻┓
# ┇━┛┇━┛┇ ┇ ┗━┛┇ ┻┇━┛┛━┛┗━┛┇ ┛
#
# author: xero <x@xero.nu>
# modified to use a static wallpaper and glitch per-monitor

WALLPAPER="$HOME/.config/awesome/themes/yerba_buena/wallpaper/wallpaper.png"
TMPDIR="/tmp"
BASEIMG="$TMPDIR/lock_base.png"
FINALIMG="$TMPDIR/lock_final.png"

# Get total screen size (bounding box of all monitors)
TOTAL_WIDTH=$(xrandr | grep ' connected' | awk '{print $3}' | sed 's/+.*//' | awk -F 'x' '{print $1}' | sort -nr | head -n1)
TOTAL_HEIGHT=$(xrandr | grep ' connected' | awk '{print $3}' | sed 's/.*x//' | sort -nr | head -n1)

# Scale wallpaper to cover the entire screen setup
magick "$WALLPAPER" -resize "${TOTAL_WIDTH}x${TOTAL_HEIGHT}^" -gravity center -extent "${TOTAL_WIDTH}x${TOTAL_HEIGHT}" "$BASEIMG"

# Start with a clean composite canvas
cp "$BASEIMG" "$FINALIMG"

# Function to apply datamosh glitch to a file
function datamosh() {
    local file="$1"
    fileSize=$(wc -c < "$file")
    headerSize=1000
    skip=$(shuf -i "$headerSize"-"$fileSize" -n 1)
    count=$(shuf -i 1-10 -n 1)
    byteStr=""
    for i in $(seq 1 $count); do
        byteStr=$byteStr'\x'$(shuf -i 0-255 -n 1)
    done
    printf $byteStr | dd of="$file" bs=1 seek=$skip count=$count conv=notrunc >/dev/null 2>&1
}

# Loop through each monitor, crop its section, glitch it, then composite it back
while read LINE; do
    if [[ "$LINE" =~ ([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+) ]]; then
        W=${BASH_REMATCH[1]}
        H=${BASH_REMATCH[2]}
        X=${BASH_REMATCH[3]}
        Y=${BASH_REMATCH[4]}
        MON_IMG="$TMPDIR/lock_${X}_${Y}.png"
        MON_JPG="$TMPDIR/lock_${X}_${Y}.jpg"

        # Crop the wallpaper for this monitor
        magick "$BASEIMG" -crop "${W}x${H}+${X}+${Y}" "$MON_IMG"

        # Convert to JPG for glitching
        magick "$MON_IMG" "$MON_JPG"

        # Apply multiple glitching steps
        steps=$(shuf -i 40-70 -n 1)
        for i in $(seq 1 $steps); do datamosh "$MON_JPG"; done

        # Convert back to PNG
        magick "$MON_JPG" "$MON_IMG"
        rm "$MON_JPG"

        # Composite glitched image back into the final canvas
        magick "$FINALIMG" "$MON_IMG" -geometry +${X}+${Y} -composite "$FINALIMG"
    fi
done <<<"$(xrandr | grep ' connected')"

# Lock screen with the final multi-monitor glitched image
i3lock -f -n -i "$FINALIMG" &>/dev/null

