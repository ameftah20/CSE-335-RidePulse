# My Own AI App

This project is a local, self-hosted AI chat app you can brand as your own.

## What You Get
- A custom web UI (`/web`) with persistent local chat history.
- A Python backend (`app.py`) that calls an OpenAI-compatible API.
- Branding via environment variables (`APP_NAME`, `APP_SYSTEM_PROMPT`).

## Quick Start
1. Set environment variables (you can copy from `.env.example`):
   - `OPENAI_API_KEY`
   - Optional: `APP_NAME`, `APP_SYSTEM_PROMPT`, `OPENAI_MODEL`, `OPENAI_BASE_URL`, `PORT`
2. Start the app:
   ```bash
   cd /Users/ameftah/RidePulseApp/Codextest
   python3 app.py
   ```
3. Open:
   - `http://localhost:8080` (or your custom `PORT`)

## Example (zsh)
```bash
export OPENAI_API_KEY="sk-..."
export APP_NAME="Amef AI"
export APP_SYSTEM_PROMPT="You are Amef AI. Give practical answers."
export OPENAI_MODEL="gpt-4o-mini"
python3 /Users/ameftah/RidePulseApp/Codextest/app.py
```

## Files
- `app.py`: HTTP server + API proxy to model provider.
- `web/index.html`: App layout.
- `web/styles.css`: UI styling.
- `web/app.js`: Client chat logic.
- `.env.example`: Configuration template.

## Notes
- The backend keeps no server-side DB; browser localStorage stores chat history.
- Do not expose this server publicly without adding auth and rate limits.
