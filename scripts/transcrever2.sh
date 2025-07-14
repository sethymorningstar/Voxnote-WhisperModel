#!/data/data/com.termux/files/usr/bin/bash

AUDIO_DIR="/sdcard/VOXNOTE/Manual Transcription"
SCRIPT_DIR=$(dirname "$(realpath "$0")")
OUTPUT_DIR="/sdcard/VOXNOTE/Subtitles"
MODEL_CONF="$HOME/VOXNOTE/models/model.conf"
MODEL_FILE="$HOME/VOXNOTE/models/$(cat "$MODEL_CONF" 2>/dev/null)"
mkdir -p "$OUPUT_DIR"
if [ ! -f "$MODEL_FILE" ]; then
  echo "❌ Model was not found in: $MODEL_FILE"
  echo "Run install.sh again and choose a valid model."
  exit 1
fi
echo -e "\n📁 Files available in the folder:"
audios=()
i=1
for file in "$AUDIO_DIR"/*.{mp3,wav,mp4,flv,mkv,avi,mov,webm}; do
  [ -f "$file" ] || continue
  audios+=("$file")
  echo "$i) $(basename "$file")"
  i=$((i+1))
done

if [ ${#audios[@]} -eq 0 ]; then
  echo "❌ No audio/video files found!"
  exit 1
fi

echo
read -p "Enter the number of the file: " escolha

if ! [[ "$escolha" =~ ^[0-9]+$ ]] || [ "$escolha" -lt 1 ] || [ "$escolha" -gt "${#audios[@]}" ]; then
  echo "❌ Invalid choice!"
  bash "$HOME/VOXNOTE/scripts/transcrever2.sh"
  exit 1
fi

FILE_PATH="${audios[$((escolha-1))]}"
FILE_NAME=$(basename "$FILE_PATH")

sanitize_filename() {
  name="${1%.*}"
  echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_-'
}

SAFE_NAME=$(sanitize_filename "$FILE_NAME")
EXT="${FILE_NAME##*.}"
AUDIO_OUT="$OUTPUT_DIR/temp_audio.wav"
OUTPUT_BASENAME="voxnote_${SAFE_NAME}"
FINAL_OUTPUT="$OUTPUT_DIR/${OUTPUT_BASENAME}.txt"

if [[ "$EXT" =~ ^(mp4|flv|mkv|avi|mov|webm)$ ]]; then
  echo "🎥 It's a video! Extracting audio..."
  ffmpeg -i "$FILE_PATH" -vn -acodec pcm_s16le -ar 16000 -ac 1 "$AUDIO_OUT"
  INPUT_AUDIO="$AUDIO_OUT"
else
  echo "🎧 It's an audio file!"
  INPUT_AUDIO="$FILE_PATH"
fi

echo "🔮 Transcribing..."
$SCRIPT_DIR/../build/bin/whisper-cli "$INPUT_AUDIO" -m "$MODEL_FILE" -l auto -of "$OUTPUT_DIR/${OUTPUT_BASENAME}" -otxt -osrt -fp --suppress-thold 2

if [ ! -f "$FINAL_OUTPUT" ]; then
  echo "❌ Transcription failed!"
  [ -f "$AUDIO_OUT" ] && rm "$AUDIO_OUT"
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
Title: ${SAFE_NAME}
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

if [[ "$salvar_legenda" == [sSyY] ]]; then
  echo -e "\n📤 Choose the subtitle formats to save:"
  echo -e "1. .srt"
  echo -e "2. .vtt"
  echo -e "3. .ass"
  echo -e "4. .txt"
  echo -e "5. All of the above"
  read -p "Enter the numbers separated by space (e.g.: 1 4): " FORMATS_SELECTED

  for FORMAT in $FORMATS_SELECTED; do
    case $FORMAT in
      1)
        echo "💾 .srt is already saved!"
        ;;
      2)
        generate_vtt
        ;;
      3)
        generate_ass
        ;;
      4)
        echo "📝 .txt file is already saved!"
        ;;
      5)
        generate_vtt
        generate_ass
        ;;
      *)
        echo "⚠️  Invalid option: $FORMAT"
        ;;
    esac
  done
fi

echo "------------------------------------------------------------"
cat "$FINAL_OUTPUT"
echo "------------------------------------------------------------"

if command -v termux-clipboard-set &>/dev/null; then
  termux-clipboard-set "$(cat "$FINAL_OUTPUT")"
  echo "📋 Copied to clipboard!"
fi

if command -v termux-notification &>/dev/null; then
  PREVIEW="$(head -n 1 "$FINAL_OUTPUT")"
  termux-notification --title "💬 Transcription ready!" --content "$PREVIEW..."
fi

if command -v termux-vibrate &>/dev/null; then
  termux-vibrate -d 1000
fi

echo -e "\n🧹 Cleaning up temporary files..."
[ -f "$AUDIO_OUT" ] && rm "$AUDIO_OUT"

echo "✨ All done! Transcription completed successfully."
bash "$HOME/VOXNOTE/start.sh"
