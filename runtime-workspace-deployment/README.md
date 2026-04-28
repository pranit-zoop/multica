# Multica Claude Daemon — Docker Setup

Two Docker containers each running a Multica Claude daemon. Both watch **all workspaces** (innovation + mymotor) and compete to claim tasks, giving 2 parallel runners per workspace.

| Container | Device Name |
|---|---|
| `multica-claude-runner-1` | docker-runner-1 |
| `multica-claude-runner-2` | docker-runner-2 |

> **How task claiming works:** The daemon is designed to watch all workspaces a token has access to. When a task comes in, whichever runner claims it first executes it — no duplicate execution.

## Prerequisites

- Docker Desktop (running)

## Setup

**1. Build and start**

```bash
docker compose up --build -d
```

**2. Authenticate Claude (one-time)**

Claude uses OAuth — no API key needed. Log in once and the credentials are shared across both containers via the `claude-auth` volume:

```bash
docker exec -it multica-claude-runner-1 claude auth login
```

Follow the browser URL printed in the terminal.

**3. Verify both runners are connected**

```bash
docker compose logs -f
```

Both should show `watching workspace` lines for innovation and mymotor.

## Common commands

```bash
# Start
docker compose up -d

# Stop
docker compose down

# Tail logs for a specific runner
docker compose logs -f claude-runner-1

# Rebuild after config changes
docker compose up --build -d
```

## Architecture

```
docker-compose.yml
├── claude-runner-1  ──► multica daemon → innovation + mymotor workspaces
└── claude-runner-2  ──► multica daemon → innovation + mymotor workspaces
        │                      │
        └──────────────────────┘
             shared claude-auth volume (~/.claude)
             OAuth credentials used by both runners
```

Each runner has its own isolated workspace volume for cloned repos and task outputs.

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | Installs Claude Code + multica v0.2.15 on `node:20-slim` |
| `entrypoint.sh` | Generates multica config from env vars, seeds Claude settings, starts daemon |
| `claude-settings.json` | Claude settings (`model: sonnet`, bypass permission prompts) |
| `.env` | Multica token and config — **do not commit** |
