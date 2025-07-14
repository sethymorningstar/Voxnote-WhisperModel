#!/data/data/com.termux/files/usr/bin/bash

# 💬 Script to automatically embed subtitles into videos
# Requirements: ffmpeg installed, storage permission already granted

# 🧚 Function to normalize names (ignores accents, spaces, etc.)
normalize() {
  echo "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | iconv -f utf8 -t ascii//TRANSLIT 2>/dev/null \
    | tr ' ' '_' \
    | tr -cd '[:alnum:]_-'
}

VIDEO_DIR="/sdcard/VOXNOTE/Manual Transcription"
LEGEND_DIR="/sdcard/VOXNOTE/Subtitles"
OUTPUT_DIR="/sdcard/VOXNOTE/FinalizedSubtitles"

mkdir -p "$OUTPUT_DIR"

clear
echo "🎬 Searching for available videos..."
echo

# 📋 Create video list and show as numbered menu
videos=()
i=1
for video in "$VIDEO_DIR"/*.{mp4,webm,mov,flv,mkv,avi}; do
  [ -f "$video" ] || continue
  videos+=("$video")
  echo "$i) $(basename "$video")"
  i=$((i+1))
done

if [ ${#videos[@]} -eq 0 ]; then
  echo "❌ No videos found in $VIDEO_DIR"
  exit 1
fi

echo
read -p "Choose the number of the video you want to subtitle: " escolha

# Basic validation
if ! [[ "$escolha" =~ ^[0-9]+$ ]] || [ "$escolha" -lt 1 ] || [ "$escolha" -gt "${#videos[@]}" ]; then
  echo "❌ Invalid choice!"
  bash "$HOME/VOXNOTE/scripts/legendar.sh"
  exit 1
fi

video="${videos[$((escolha-1))]}"
video_base=$(basename "$video")
video_name="${video_base%.*}"
video_norm=$(normalize "$video_name")

# 🔍 Look for matching subtitle
found=0
for legenda in "$LEGEND_DIR"/*.{srt,ass,vtt}; do
  [ -f "$legenda" ] || continue
  legenda_base=$(basename "$legenda")
  legenda_name="${legenda_base%.*}"
  legenda_name=$(echo "$legenda_name" | sed 's/^voxnote_//')
  legenda_norm=$(normalize "$legenda_name")

  if [ "$video_norm" = "$legenda_norm" ]; then
    echo "✅ Match found: '$video_base' + '$legenda_base'"

    output_file="$OUTPUT_DIR/${video_name}_SUBBED.mp4"

    # 🚧 Fixed: need to escape subtitle path!
    ffmpeg -i "$video" -vf "subtitles='$(echo "$legenda" | sed "s/:/\\\\:/g")'" -c:a copy "$output_file"

    if [ $? -eq 0 ]; then
      echo "🎉 Subtitle successfully embedded into: $output_file"
    else
      echo "❌ Failed to embed subtitle into: $video_base"
    fi

    found=1
    break
  fi
done

if [ "$found" -eq 0 ]; then
  echo "😢 No matching subtitle found for: $video_base"
fi

echo -e "\n✨ Done. Check the folder: $OUTPUT_DIR"
echo
echo "1) 📄 Subtitle more videos!"
echo "2) 🔁 Return to main menu"
echo "3) ❌ Exit"
read -p "What do you want to do next? " escolha

case "$escolha" in
  1)
    bash "$HOME/VOXNOTE/scripts/legendar.sh"
    ;;
  2)
    bash "$HOME/VOXNOTE/start.sh"
    ;;
  *)
    echo "👋 See you next time, subtitle-star ✨"
    ;;
  exit 1
esac
