#!/usr/bin/env python3
"""
generate_and_send.py
Reads combined.txt → generates reply via Gemini → writes to outbox.txt →
runs send_signal_simple.sh to send → clears outbox.txt.
"""
import os
import subprocess
from dotenv import load_dotenv
import google.generativeai as genai


# === CONFIG ===
COMBINED_PATH = "combined.txt"
OUTBOX_PATH = "outbox.txt"
SEND_SCRIPT = "./send_signal_simple.sh"
MODEL_NAME = "gemini-2.5-flash-lite"

# === SETUP ===
load_dotenv()
genai.configure(api_key=os.getenv("API_KEY"))
model = genai.GenerativeModel(MODEL_NAME)


# === FUNCTIONS ===
def read_combined(path: str) -> str:
    if not os.path.exists(path):
        raise FileNotFoundError(f"{path} not found.")
    with open(path, "r", encoding="utf-8") as f:
        return f.read().strip()
def build_prompt(combined_text: str) -> str:
    return f"""You are an assistant generating a single chat reply.
Read the context below and produce ONLY the message that should be sent next.
Do not include quotes, commentary, or formatting.
Context:
{combined_text}
Now produce the message to send (only the message):"""
def write_outbox(message: str):
    with open(OUTBOX_PATH, "w", encoding="utf-8") as f:
        f.write(message)
def clear_outbox():
    with open(OUTBOX_PATH, "w", encoding="utf-8") as f:
        f.write("")
def send_message():
    """Run external shell script that handles sending + adding to sent.txt."""
    try:
        result = subprocess.run([SEND_SCRIPT], capture_output=True, text=True, check=True)
        print(result.stdout.strip())
    except subprocess.CalledProcessError as e:
        print(f"Error sending message: {e.stderr.strip()}")


# === MAIN ===
def main():
    combined = read_combined(COMBINED_PATH)
    prompt = build_prompt(combined)
    print("Generating response via Gemini...")
    response = model.generate_content(prompt)
    message = (response.text or "").strip()
    if not message:
        print("No message generated — skipping send.")
        return
    write_outbox(message)
    print(f"Message written to {OUTBOX_PATH} ({len(message)} chars).")
    print("Sending message via send_signal_simple.sh...")
    send_message()
    print("Clearing outbox...")
    clear_outbox()
    print("Done.")
if __name__ == "__main__":
    main()
 
