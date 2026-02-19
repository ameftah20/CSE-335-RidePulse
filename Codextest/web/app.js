const messagesEl = document.getElementById("messages");
const formEl = document.getElementById("composer");
const inputEl = document.getElementById("input");
const sendBtnEl = document.getElementById("sendBtn");
const statusEl = document.getElementById("status");
const clearBtnEl = document.getElementById("clearBtn");
const appNameEl = document.getElementById("appName");
const modelChipEl = document.getElementById("modelChip");

const STORAGE_KEY = "pulsemind_chat_history_v1";
let history = loadHistory();
let isBusy = false;

function loadHistory() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return parsed.filter(
      (m) =>
        m &&
        typeof m === "object" &&
        typeof m.role === "string" &&
        typeof m.content === "string",
    );
  } catch (_) {
    return [];
  }
}

function saveHistory() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(history));
}

function setStatus(text) {
  statusEl.textContent = text;
}

function appendBubble(role, content) {
  const bubble = document.createElement("div");
  bubble.className = `bubble ${role}`;
  bubble.textContent = content;
  messagesEl.appendChild(bubble);
  messagesEl.scrollTop = messagesEl.scrollHeight;
}

function renderHistory() {
  messagesEl.innerHTML = "";
  if (!history.length) {
    appendBubble(
      "system",
      "Welcome. This is your private AI app. Ask a question to start.",
    );
    return;
  }
  for (const msg of history) {
    if (msg.role === "system") continue;
    appendBubble(msg.role, msg.content);
  }
}

async function loadAppMeta() {
  try {
    const resp = await fetch("/api/health");
    const data = await resp.json();
    if (data.appName) {
      appNameEl.textContent = data.appName;
      document.title = data.appName;
    }
    if (data.model) {
      modelChipEl.textContent = `model: ${data.model}`;
    }
  } catch (_) {
    setStatus("Backend unavailable.");
  }
}

async function sendMessage(text) {
  history.push({ role: "user", content: text });
  saveHistory();
  appendBubble("user", text);

  setStatus("Thinking...");
  isBusy = true;
  sendBtnEl.disabled = true;

  try {
    const resp = await fetch("/api/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ history }),
    });
    const data = await resp.json();
    if (!resp.ok) {
      throw new Error(data.error || "Unknown backend error.");
    }
    const reply = String(data.reply || "").trim();
    if (!reply) throw new Error("Model returned an empty reply.");

    history.push({ role: "assistant", content: reply });
    saveHistory();
    appendBubble("assistant", reply);
    setStatus("Ready");
  } catch (err) {
    appendBubble("system", `Error: ${err.message}`);
    setStatus("Error");
  } finally {
    isBusy = false;
    sendBtnEl.disabled = false;
    inputEl.focus();
  }
}

formEl.addEventListener("submit", async (event) => {
  event.preventDefault();
  if (isBusy) return;
  const text = inputEl.value.trim();
  if (!text) return;
  inputEl.value = "";
  await sendMessage(text);
});

inputEl.addEventListener("keydown", (event) => {
  if (event.key === "Enter" && !event.shiftKey) {
    event.preventDefault();
    formEl.requestSubmit();
  }
});

clearBtnEl.addEventListener("click", () => {
  history = [];
  saveHistory();
  renderHistory();
  setStatus("Cleared");
});

renderHistory();
loadAppMeta();
