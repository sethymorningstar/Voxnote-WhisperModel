# 🌌 VOXNOTE - INTELLIGENT, OFFLINE & STYLISH TRANSCRIPTION 🌌

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  
🔊 **What is VoxNote?**  
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  
**VoxNote** is a collection of bash scripts optimized for **Termux** (Android) that transcribes audio/video **100% offline** using **Whisper.cpp**.  
You can download YouTube videos, select local files, and automatically export transcriptions in `.srt`, `.vtt`, `.ass`, and `.txt` formats — ready for editing, subtitles or research.

Perfect for content creators, editors, journalists, researchers, or anyone curious enough to capture the world’s sounds into words. 🎙️

---Torrent videos file type are not supported yet, but you can also try the .mkv format.

📦 **Project Structure**  
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  
📁 `/VOXNOTE`  
├── `start.sh` — Main entry interface with friendly menu  
├── `install.sh` — Auto-installer for setting up everything in place  
├── `/scripts/`  
│   ├── `transcrever.sh` — Downloads from YouTube and transcribes audio  
│   ├── `transcrever2.sh` — Transcribes local audio/video files from `Transcrição Manual` folder  
│   └── `legendar.sh` — Hardcodes `.srt` subtitles into videos using ffmpeg  
├── `/build/bin/` — Precompiled `whisper-cli` for ARM64  
├── `/models/` — Whisper models (e.g., `ggml-small.bin`)  
├── `/libs/` — Necessary shared libraries 

---

⚙️ **Requirements**  
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  
✔ Updated Termux  
✔ Storage permission granted  
✔ Essential tools installed:  
- `ffmpeg`  
- `yt-dlp`  
- `whisper.cpp` (already included)  
- `termux-api` *(optional, for clipboard and notifications)*

---

🚀 **How to Install**  
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  
> Automatic setup with just 5 commands:

```bash
termux-setup-storage
pkg install unzip -y
unzip /sdcard/Download/VOXNOTE-EN-US.zip
cd VOXNOTE-EN-US
chmod +x install.sh
bash install.sh

What install.sh does:
✅ Installs all necessary dependencies
✅ Places all files in the correct directories
✅ Sets up permissions and environment
✅ Adds a home screen shortcut using Termux:Widget (if available)


---

🎮 How to Use
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Launch the main menu with:

bash $HOME/VOXNOTE/start.sh

DO NOT run these scripts directly:

transcrever.sh → Downloads from YouTube, extracts audio, transcribes automatically

transcrever2.sh → Lists local files from Manual Subtitles and transcribes

legendar.sh → Combines .srt subtitles with .mp4 videos using ffmpeg (and videos/subtitles with different format)



---

📑 Supported Output Formats
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ .txt — Plain transcript, no timestamps
✅ .srt — Standard subtitle format for YouTube Captions, players, and editors
✅ .vtt — Web-friendly subtitle format
✅ .ass — Advanced subtitle format with styling and effects

All formats can be selected and saved after transcription. 🎯


---

🌍 Supported Languages
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Portuguese (pt)

English (en)

Spanish (es)

French (fr)

Or let the magic happen with -l auto (default)



---

📲 Extra Features (optional)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔧 Termux:API

Automatically copies transcript to clipboard

Sends native Android notifications when done

Optional phone vibration as feedback


🧩 Termux:Widget

Add script shortcuts to your Android home screen

Launch VoxNote with a single tap


📥 Safe download links:

🔗 Termux:API → https://f-droid.org/packages/com.termux.api/

🔗 Termux:Widget → https://f-droid.org/packages/com.termux.widget/



---

🧠 Smart Features
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ Visual menu with emoji feedback and previews
✨ Detects audio in videos and local files
✨ Automated installation and user-friendly structure
✨ Fully offline operation (after downloading from YouTube, if needed)
✨ Compatible subtitles for editors and platforms
✨ Clean, timestamped, and styled output
✨ Resilient error handling and clear UX
✨ Designed for practicality with a stylish terminal vibe 💅


---

👤 Author: @Shiki
🔧 Tech Support & Dark Magic: Lamie 😶‍🌫

> VoxNote isn’t just a script.
It’s a tool of power, clarity, and control.
Use it wisely — and may your voice echo through the bytes of time. ⏳
Sounds silly? maybe. But it's true.
��

