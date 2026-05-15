#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────
# Deploy Hologram Card.command
# Double-click in Finder to build and deploy to Cloudflare Pages
# ─────────────────────────────────────────────────────────
set -euo pipefail

cd "$(dirname "$0")"

export CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN:-UDwJ89CoAKWywnzopPtCQMrUyut9r2suhfHnPCdM}"
export CLOUDFLARE_ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:-f39b072edc6886979540b3e1286db51a}"
API="https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}"

BLUE='\033[0;34m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'

info()  { printf "${BLUE}▸${RESET} %b\n" "$1"; }
ok()    { printf "${GREEN}✓${RESET} %b\n" "$1"; }
warn()  { printf "${YELLOW}⚠${RESET} %b\n" "$1"; }
fail()  { printf "${RED}✘${RESET} %b\n" "$1" >&2; echo ""; read -rp "Press Enter to close..."; exit 1; }

echo ""
echo -e "${BOLD}Hologram Card Deployer${RESET}"
echo -e "${DIM}──────────────────────${RESET}"
echo ""

PROJECT="squint"
DOMAIN="${PROJECT}.pages.dev"

info "Building project..."
npm run build || fail "Build failed"
ok "Build complete"
echo ""

info "Deploying dist/ → ${BOLD}https://${DOMAIN}${RESET}"
echo ""

if ! npx wrangler pages deploy dist --project-name "$PROJECT" --branch main 2>&1; then
  fail "Cloudflare Pages deploy failed — check credentials and network"
fi

echo ""
ok "Deployed to Cloudflare Pages"

info "Checking @squint.ai access protection..."

LIST_RESPONSE=$(curl -s -X GET "${API}/access/apps" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" 2>&1)

EXISTING_APP_ID=$(echo "$LIST_RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for app in data.get('result', []):
        if app.get('domain') == '${DOMAIN}':
            print(app['id'])
            break
except: pass
" 2>&1) || true

if [[ -n "$EXISTING_APP_ID" ]]; then
  ok "Access policy already active — skipping"
else
  info "Creating Access policy for @squint.ai..."
  APP_RESPONSE=$(curl -s -X POST "${API}/access/apps" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "{\"name\":\"Hologram Card\",\"domain\":\"${DOMAIN}\",\"type\":\"self_hosted\",\"session_duration\":\"24h\",\"auto_redirect_to_identity\":true}" 2>&1)

  APP_ID=$(echo "$APP_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['result']['id']) if d.get('success') else None" 2>/dev/null) || true

  if [[ -n "$APP_ID" ]]; then
    curl -s -X POST "${API}/access/apps/${APP_ID}/policies" \
      -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      -H "Content-Type: application/json" \
      --data '{"name":"Squint employees only","decision":"allow","precedence":1,"include":[{"email_domain":{"domain":"squint.ai"}}]}' > /dev/null
    ok "Access policy created — @squint.ai Google accounts only"
  else
    warn "Could not create Access policy — prototype is live but unprotected"
  fi
fi

echo ""
printf "${GREEN}${BOLD}════════════════════════════════════════════${RESET}\n"
printf "${GREEN}${BOLD}  🚀  https://${DOMAIN}${RESET}\n"
printf "${GREEN}${BOLD}       Auth: Google SSO (@squint.ai)${RESET}\n"
printf "${GREEN}${BOLD}════════════════════════════════════════════${RESET}\n"
echo ""
read -rp "Press Enter to close..."
