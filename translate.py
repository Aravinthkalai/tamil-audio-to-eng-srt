import datetime
import os
import sys
from faster_whisper import WhisperModel
from tqdm import tqdm

AUDIO_FILE = "input.mp3"
OUTPUT_SRT = "english_subtitles.srt"

def format_time(seconds):
    td = datetime.timedelta(seconds=seconds)
    total_seconds = int(td.total_seconds())
    hours, remainder = divmod(total_seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    milliseconds = int((td.total_seconds() - total_seconds) * 1000)
    return f"{hours:02}:{minutes:02}:{seconds:02},{milliseconds:03}"

def print_header():
    print("====================================================")
    print("   TAMIL/TANGLISH TO ENGLISH AI SUBTITLE CREATOR    ")
    print("                 [ DYNAMIC MULTI-TIER ]             ")
    print("====================================================\n")

def main():
    print_header()
    
    # 1. Enforce the hardcoded file name tracking parameter
    if not os.path.exists(AUDIO_FILE):
        print(f"❌ Error: Cannot find '{AUDIO_FILE}' in this folder!")
        print("\n💡 HOW TO FIX THIS:")
        print(f"1. Make sure your audio or video file is inside this exact folder.")
        print(f"2. Rename your file to exactly: {AUDIO_FILE}")
        print("3. Restart this program.")
        input("\nPress Enter to exit...")
        return

    # 2. Dynamic Performance Tier Choice Menu Interface
    print("Select the AI Performance Tier you want to run:")
    print(" [1] LOW Tier    (Small Model  - Fast CPU Speed / Basic Precision)")
    print(" [2] MEDIUM Tier (Medium Model - Balanced CPU Speed / High Precision)")
    print(" [3] HIGH Tier   (Large-v3     - Heavy CPU Load  / Maximum Precision)")
    
    choice = input("\nEnter your choice (1, 2, or 3): ").strip()
    
    print("\n🤖 Initializing AI Model environment layers...")
    try:
        if choice == '1':
            print("  ↳ Loading 'SMALL' model profile layers... (Fast CPU Configuration)")
            model = WhisperModel("small", device="cpu", compute_type="int8")
        elif choice == '2':
            print("  ↳ Loading 'MEDIUM' model profile layers... (Balanced Configuration)")
            model = WhisperModel("medium", device="cpu", compute_type="int8")
        elif choice == '3':
            print("  ↳ Loading 'LARGE-V3' model profile layers... (Maximum Precision Profile)")
            print("⚠️ Notice: High tier demands substantial CPU cycles and longer runtime windows.")
            model = WhisperModel("large-v3", device="cpu", compute_type="float32")
        else:
            print("❌ Invalid selection option choice input variable! Defaulting to Medium Tier.")
            model = WhisperModel("medium", device="cpu", compute_type="int8")
    except Exception as e:
        print(f"\n❌ Core Initialization Error: {e}")
        print("If this is the first boot, verify your internet router connection to allow file mapping fetches.")
        input("\nPress Enter to close engine...")
        return

    # 3. Running Translation Loop Pipeline
    print(f"\n🎬 Target verified! Scanning target timeline properties...")
    segments, info = model.transcribe(AUDIO_FILE, language="ta", task="translate", beam_size=5)
    
    total_duration = info.duration
    print(f"📊 Track Length Detected: {format_time(total_duration)}")
    print("⏳ Processing track timelines...")

    # Dynamic progress bar logic mapping parameters
    pbar = tqdm(total=total_duration, unit="s", desc="  ↳ Translation Status", bar_format="{desc}: {percentage:3.0f}%|{bar}| {elapsed}<{remaining}")
    last_position = 0.0

    with open(OUTPUT_SRT, "w", encoding="utf-8") as f:
        for index, segment in enumerate(segments, start=1):
            start = format_time(segment.start)
            end = format_time(segment.end)
            f.write(f"{index}\n{start} --> {end}\n{segment.text.strip()}\n\n")
            
            elapsed_chunk = segment.end - last_position
            if elapsed_chunk > 0:
                pbar.update(elapsed_chunk)
                last_position = segment.end

    if last_position < total_duration:
        pbar.update(total_duration - last_position)
    pbar.close()
                
    print(f"\n🎉 SUCCESS! Your English subtitles are saved as: {OUTPUT_SRT}")
    input("\nPress Enter to exit...")

if __name__ == "__main__":
    main()
