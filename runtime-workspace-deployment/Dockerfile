FROM node:20-slim

RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Install multica (auto-detects arm64/amd64)
ARG TARGETARCH=amd64
RUN MULTICA_VERSION=0.2.15 && \
    curl -fsSL "https://github.com/multica-ai/multica/releases/download/v${MULTICA_VERSION}/multica-cli-${MULTICA_VERSION}-linux-${TARGETARCH}.tar.gz" \
    | tar -xz -C /usr/local/bin multica && \
    chmod +x /usr/local/bin/multica

# Create non-root user (claude refuses to run as root with bypassPermissions)
RUN useradd -m -s /bin/sh agent
RUN mkdir -p /home/agent/.multica /home/agent/.claude /home/agent/multica_workspaces && \
    chown -R agent:agent /home/agent

COPY claude-settings.json /claude-settings.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER agent
WORKDIR /home/agent

ENTRYPOINT ["/entrypoint.sh"]
