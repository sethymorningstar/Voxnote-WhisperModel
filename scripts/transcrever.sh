#!/data/data/com.termux/files/usr/bin/bash

# Updated script for transcription with real subtitles (SRT, VTT, ASS)

# Ask for the video link if not passed as argument
if [ -z "$1" ]; then
  read -p "❔ What's the video link? " VIDEO_URL
  VIDEO_URL=$(echo "$VIDEO_URL" | tr -d '\r')
else
  VIDEO_URL="$1"
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")
AUDIO_FILE="audio_temp.wav"
OUTPUT_DIR="/sdcard/VOXNOTE/Subtitles"
MODEL_CONF="$HOME/VOXNOTE/models/model.conf"
MODEL_FILE="$HOME/VOXNOTE/models/$(cat "$MODEL_CONF" 2>/dev/null)"

if [ ! -f "$MODEL_FILE" ]; then
  echo "❌ Model was not found in: $MODEL_FILE"
  echo "Run install.sh again and choose a valid model"
  exit 1
fi


mkdir -p "$OUTPUT_DIR"

sanitize_filename() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_-'
}

echo -e "\n🎥 Fetching video title..."
VIDEO_TITLE=$(yt-dlp --get-title "$VIDEO_URL" --age-limit 99 --no-check-certificate --force-ipv4 --ignore-errors)
SAFE_TITLE=$(sanitize_filename "$VIDEO_TITLE")
OUTPUT_BASENAME="voxnote_${SAFE_TITLE}"

echo -e "✅ Title detected: $VIDEO_TITLE"
echo -e "📁 Base filename: ${OUTPUT_BASENAME}"

echo "🔮 Downloading audio from video..."
yt-dlp -x --audio-format wav --embed-metadata --restrict-filenames --no-playlist --age-limit 99 --no-check-certificate --force-ipv4 --ignore-errors -o "$AUDIO_FILE" "$VIDEO_URL"
if [ $? -ne 0 ]; then
  echo "❌ Error downloading audio."
  exit 1
fi

export LD_LIBRARY_PATH="$SCRIPT_DIR/libs:$LD_LIBRARY_PATH"

echo "🎧 Audio downloaded! Transcribing with whisper.cpp..."
$HOME/VOXNOTE/build/bin/whisper-cli "$AUDIO_FILE" -m "$MODEL_FILE" -l auto \
  -of "$OUTPUT_DIR/${OUTPUT_BASENAME}" -osrt -otxt -fp --suppress-thold 2

# Check if .srt was created
if [ ! -f "$OUTPUT_DIR/${OUTPUT_BASENAME}.srt" ]; then
  echo "❌ Transcription failed! No .srt was generated!"
  rm -f "$AUDIO_FILE"
  exit 1
fi

read -p "❔ SAVE AS SUBTITLE FILE? (Y/N): " salvar_legenda

generate_vtt() {
  echo "WEBVTT" > "$OUTPUT_DIR/${OUTPUT_BASENAME}.vtt"
  awk 'BEGIN{i=1}/-->/{print ""; print i++; print; next}{print}' "$OUTPUT_DIR/${OUTPUT_BASENAME}.srt" \
    | sed 's/,/./g' >> "$OUTPUT_DIR/${OUTPUT_BASENAME}.vtt"
}

generate_ass() {
  cat <<EOF > "$OUTPUT_DIR/${OUTPUT_BASENAME}.ass"
[Script Info]
Title: ${VIDEO_TITLE}
ScriptType: v4.00+
Collisions: Normal
PlayDepth: 0
Timer: 100.0000

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Arial,20,&H00FFFFFF,&H000000FF,&H00000000,&H64000000,-1,0,0,0,100,100,0,0,1,2,1,2,10,10,10,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
EOF

  awk 'BEGIN{FS="-->|\\n"; RS=""; ORS=""}
  {
    split($1, i, "\n")
    split($2, t, "\n")
    start = i[2]
    end = t[1]
    gsub(",", ".", start)
    gsub(",", ".", end)
    text = ""
    for (j=2; j<=length(t); j++) {
      text = text t[j] " "
    }
    printf("Dialogue: 0,%s,%s,Default,,0,0,0,,%s\n", start, end, text)
  }' "$OUTPUT_DIR/${OUTPUT_BASENAME}.srt" >> "$OUTPUT_DIR/${OUTPUT_BASENAME}.ass"
}

if [[ "$salvar_legenda" == [sS] || "$salvar_legenda" == [yY] ]]; then
  echo -e "\n📤 Choose subtitle formats to save:"
  echo -e "1. .srt"
  echo -e "2. .vtt"
  echo -e "3. .ass"
  echo -e "4. .txt"
  echo -e "5. All of the above"
  read -p "Enter the numbers separated by space (e.g. 1 4): " FORMATS_SELECTED

  for FORMAT in $FORMATS_SELECTED; do
    case $FORMAT in
      1) echo "💾 .srt already generated!" ;;
      2) echo "💾 Generating .vtt"; generate_vtt ;;
      3) echo "💾 Generating .ass"; generate_ass ;;
      4) echo "💾 .txt is already saved!" ;;
      5)
        echo "💾 Generating all formats!"
        generate_vtt
        generate_ass
        ;;
      *) echo "⚠️  Invalid option: $FORMAT" ;;
    esac
  done
fi

echo "------------------------------------------------------------"
head -n 10 "$OUTPUT_DIR/${OUTPUT_BASENAME}.srt"
echo "------------------------------------------------------------"

if command -v termux-clipboard-set &>/dev/null; then
  termux-clipboard-set "$(cat "$OUTPUT_DIR/${OUTPUT_BASENAME}.txt")"
  echo "📋 Copied to clipboard!"
fi

if command -v termux-notification &>/dev/null; then
  PREVIEW="$(head -n 1 "$OUTPUT_DIR/${OUTPUT_BASENAME}.txt")"
  termux-notification --title "💬 Transcription ready!" --content "$PREVIEW..."
fi

if command -v termux-vibrate &>/dev/null; then
  termux-vibrate -d 1000
fi

echo -e "\n🧹 Cleaning temporary files..."
rm -f "$AUDIO_FILE"

echo "✨ All done, subtitle successfully generated!"
bash "$HOME/VOXNOTE/start.sh"
