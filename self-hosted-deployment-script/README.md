# Self-Hosted Deployment Script

One-shot installer that provisions Multica on a single Debian VM with Docker Compose, Nginx, and a Let's Encrypt TLS certificate.

## What it does

1. Installs system packages (Docker, Nginx, Certbot, Git, OpenSSL, dnsutils).
2. Verifies that the supplied domain's DNS A record points at this VM.
3. Clones (or updates) the Multica repository into `/opt/multica`.
4. Generates `/opt/multica/.env` with secure random `JWT_SECRET` and `POSTGRES_PASSWORD`. Existing values are preserved across reruns; the previous file is backed up.
5. Builds and starts the `docker-compose.selfhost.yml` stack and waits for `/health` to pass.
6. Issues a TLS certificate via `certbot --nginx` and installs the production Nginx vhost (HTTP → HTTPS, WebSocket upgrade on `/ws`, API/auth/uploads proxied to the backend, everything else to the frontend).

## Prerequisites

- Fresh Debian VM with a public IPv4 address.
- DNS A record for your domain pointing to that IP. If you use Cloudflare, set the record to **DNS-only** (grey cloud) for the initial certificate issuance.
- Resend account and API key for outbound email (login codes).
- Inbound TCP `80` and `443` open.

## Usage

Run as root or with `sudo`. Pass only the bare hostname — no scheme, no path.

```bash
# Interactive: script will prompt for the Resend API key
sudo bash deploy-vm.sh multica.example.com

# Non-interactive
sudo bash deploy-vm.sh multica.example.com re_your_resend_key onboarding@resend.dev
```

The third argument is the `RESEND_FROM_EMAIL` (defaults to `onboarding@resend.dev`). It is also used as the contact email for the Let's Encrypt registration.

### Environment overrides

| Variable             | Default                                             | Purpose                                       |
| -------------------- | --------------------------------------------------- | --------------------------------------------- |
| `MULTICA_REPO_URL`   | `https://github.com/multica-ai/multica.git`         | Repo to clone/update.                         |
| `MULTICA_APP_DIR`    | `/opt/multica`                                      | Install location.                             |
| `RESEND_API_KEY`     | _(required)_                                        | Picked up if not passed as the 2nd argument.  |
| `RESEND_FROM_EMAIL`  | `onboarding@resend.dev`                             | Used for sender + Let's Encrypt registration. |

## After it finishes

- App: `https://<your-domain>`
- Health: `curl https://<your-domain>/health`
- Logs: `cd /opt/multica && sudo docker compose -f docker-compose.selfhost.yml logs -f`
- Update: `cd /opt/multica && git pull && sudo docker compose -f docker-compose.selfhost.yml up -d --build`
- DB backup: `cd /opt/multica && sudo docker compose -f docker-compose.selfhost.yml exec postgres pg_dump -U multica multica > backup.sql`

## Troubleshooting

- **"DNS is not ready"** — the A record either doesn't exist yet or doesn't point at this VM (often caused by Cloudflare proxy mode). Fix the record, wait for propagation, rerun.
- **Certbot fails** — confirm port 80 is reachable from the public internet and that no other process is bound to it.
- **Backend never goes healthy** — inspect with `sudo docker compose -f /opt/multica/docker-compose.selfhost.yml logs -f backend`.
- **Rerunning the script** — safe. It is idempotent: secrets are preserved, the repo is fast-forwarded, containers are rebuilt, Nginx is reloaded.

## Notes

- Only Debian is supported (the script hard-fails on other distros).
- Uploads are stored in a local Docker volume by default. Set the S3/CloudFront vars in `.env` and restart if you want object storage.
- Google OAuth is disabled by default; fill the `GOOGLE_*` vars in `.env` to enable it.
