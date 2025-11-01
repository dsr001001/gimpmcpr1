## GPT Guy Signal Auto-Responder

This repository automates a lightweight Signal conversation loop. Incoming messages are collected with `signal-cli`, stored on disk, and a Python orchestrator uses Google Gemini to draft the next reply before handing it back to `signal-cli` for delivery.

### How It Works

1. `message_receive.sh` listens for new Signal messages and appends them—including a timestamp converted to IST—to `read.txt`.
2. `combined.txt` aggregates the most recent conversation context plus any persona notes.
3. `test_pattern_1800.py` reads `combined.txt`, asks a Gemini model to craft a response, writes the reply to `outbox.txt`, triggers `send_signal_simple.sh`, and then clears the outbox.
4. `send_signal_simple.sh` sends the message via `signal-cli` and logs the attempt to `sent.txt`.

### Prerequisites

- Signal Desktop account already linked to `signal-cli` (this project assumes the CLI can send/receive using the configured phone numbers).
- Python 3.10+
- Packages: `python-dotenv`, `google-generativeai`
- A Google AI Studio API key with access to the `gemini-2.5-flash-lite` model.

### Setup

1. Create a `.env` file and set `API_KEY=<your Google API key>`.
2. Install dependencies:
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install python-dotenv google-generativeai
   ```
3. Verify `signal-cli` is on `PATH` and authenticated for the sender number referenced in the scripts.

### Running The Loop

- **Receive**: run `./message_receive.sh` in a background session or cron to keep `read.txt` up to date.
- **Reply**: execute `python test_pattern_1800.py` to have Gemini craft and send the next response.

All outgoing messages are logged in `sent.txt` while `outbox.txt` stays empty between runs.

### Notes & Caveats

- Treat the text files in the repo (`read.txt`, `combined.txt`, etc.) as transient state; consider moving them to a data directory if you extend the project.
- The scripts are opinionated toward a single contact; adapt the phone numbers if you plan to generalize.
- Always review auto-generated messages before sending in production contexts.