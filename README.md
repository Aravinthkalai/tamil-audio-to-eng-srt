# Project 1: Tamil/Tanglish to English Subtitle Creator (Subtitles Only)

This is a local, offline workflow tool that automatically translates **Tamil or Tanglish** audio and video tracks directly into high-precision English subtitle configurations (`.srt`) without rendering any audio voiceovers.

---

## 🛠️ System Prerequisites

Before running the command lines below, ensure your Windows 10 machine has the following tools installed:
1. **Python 3.10+**: Make sure to check the box **"Add python.exe to PATH"** during installation.
2. **FFmpeg**: System audio format handler wrapper.

---

## 💻 1. Clear Package Dependencies & Install Environment

Open your Windows **Command Prompt (`cmd`)**, navigate to your working project directory, and run the following commands sequentially to clear your environment dependencies and install the production framework modules:

```cmd
:: 1. Navigate to your project folder
cd %USERPROFILE%\Desktop\TamilAI_SRT

:: 2. Upgrade pip to ensure the latest package wheel wrappers can compile smoothly
python.exe -m pip install --upgrade pip

:: 3. Install core AI transcription engines, matrix processors, and media packers
pip install faster-whisper numpy pyinstaller
```

---

## 🏗️ 2. Compile into a Standalone Executable (`.exe`)

Once your main application script file (`app.py`) is locked down in your workspace directory, run the compiler command to bundle all packages together:

```cmd
:: Compile script into a standalone one-file execution bundle inside the 'dist' directory
pyinstaller --onefile translate.py
```
*Note: This building process can take between 1 and 2 minutes as it packs the system binary files together.*

---

## 🚀 3. How to Use the Generated Executable File

After the compilation layout hits a successful verification status update, you can find the final output file inside a newly built subdirectory named **`dist`**.

### **📌 Hardcoded File Naming Rule:**
The application looks for a specific file name inside your folder. You **must** rename your file to exactly **`input.mp3`** for the tool to work (Note: It also processes videos if you rename them to `input.mp3`, but changing the file extension to match `.mp3` is mandatory).

### **Step-by-Step Usage Guide:**
1. Navigate into the **`TamilAI_SRT\dist`** folder and copy out the compiled **`app.exe`**.
2. **Drop it anywhere:** Paste `app.exe` into *any* folder on your machine or external drive.
3. **Add your media target:** Place your Tamil audio track or video clip inside that **exact same folder** right next to `app.exe`.
4. **Rename the file:** Rename your track to exactly **`input.mp3`**.
5. **Launch the engine:** Double-click `app.exe`. The interface will pop up, verify the file, and automatically begin translating.
6. **Output:** Once finished, a new file named **`english_subtitles.srt`** will be generated in the folder.

---

## ⚠️ Important Production Performance Notices

* **One-Time Model Storage Fetch:** The very first time `app.exe` runs on a computer, it will securely download the high-accuracy **`medium` Whisper model framework (~1.5 GB)** straight to the target system's local user cache registry files (`%USERPROFILE%\.cache\huggingface\hub`). **Internet is mandatory for this first startup step only.** 
* **100% Offline Portability:** Once that initial data fetch completes successfully, you can pull your internet connection line completely out. All future translation loops, sub-segment calculations, and text generation cycles will execute **100% locally and completely offline.**
