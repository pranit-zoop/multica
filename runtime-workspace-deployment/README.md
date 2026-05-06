# Multica Agent Daemon — Docker Setup

Docker setup for a Multica daemon runner with Claude Code, Codex CLI, and OpenCode CLI installed. The daemon auto-detects available CLIs on `PATH` and registers a runtime for each authenticated tool.

| Container | Device Name |
|---|---|
| `multica-claude-mymotor` | docker-mymotor |

> **How task claiming works:** If you run multiple daemon containers for the same workspace, whichever runner claims a task first executes it — no duplicate execution.

## Prerequisites

- Docker Desktop (running)

## Setup

**1. Build and start**

```bash
docker compose up --build -d
```

**2. Authenticate agent CLIs (one-time)**

Claude uses OAuth — no API key needed. Log in once and the credentials persist in the `claude-auth-mymotor` volume:

```bash
docker exec -it multica-claude-mymotor claude auth login
```

Follow the browser URL printed in the terminal.

Codex credentials persist in the `codex-auth-mymotor` volume:

```bash
docker exec -it multica-claude-mymotor codex login
```

OpenCode credentials persist in the `opencode-config-mymotor` and `opencode-data-mymotor` volumes:

```bash
docker exec -it multica-claude-mymotor opencode auth login
```

**3. Verify the runner is connected**

```bash
docker compose logs -f
```

Logs should show daemon startup and runtime registration for each authenticated CLI.

## Common commands

```bash
# Start
docker compose up -d

# Stop
docker compose down

# Tail logs
docker compose logs -f claude-mymotor

# Rebuild after config changes
docker compose up --build -d
```

## Architecture

```
docker-compose.yml
└── claude-mymotor ──► multica daemon → configured workspace
        ├── Claude Code credentials (~/.claude)
        ├── Codex credentials (~/.codex)
        └── OpenCode credentials (~/.config/opencode, ~/.local/share/opencode)
```

The runner has an isolated workspace volume for cloned repos and task outputs.

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | Installs Claude Code, Codex CLI, OpenCode CLI, and multica v0.2.15 on `node:20-slim` |
| `entrypoint.sh` | Generates multica config from env vars, seeds Claude settings, starts daemon |
| `claude-settings.json` | Claude settings (`model: sonnet`, bypass permission prompts) |
| `.env` | Multica token and config — **do not commit** |
