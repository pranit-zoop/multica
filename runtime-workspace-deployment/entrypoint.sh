#!/bin/sh
set -e

cat > /home/agent/.multica/config.json <<EOF
{
  "server_url": "${MULTICA_SERVER_URL}",
  "app_url": "${MULTICA_APP_URL}",
  "workspace_id": "${MULTICA_WORKSPACE_ID}",
  "token": "${MULTICA_TOKEN}"
}
EOF

if [ ! -f /home/agent/.claude/settings.json ]; then
  cp /claude-settings.json /home/agent/.claude/settings.json
fi

exec multica daemon start --foreground
