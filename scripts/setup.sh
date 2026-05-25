#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# setup.sh — Setup automat proiect nou (Supabase + Vercel)
#
# Usage:
#   ./scripts/setup.sh <project-name>
#   ./scripts/setup.sh <project-name> <db-password>
#
# Necesită (o singură dată, înainte de prima rulare):
#   npm install -g supabase vercel
#   supabase login
#   vercel login
#
# Pe Windows: rulează în Git Bash (nu PowerShell)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

PROJECT_NAME="${1:?Utilizare: ./scripts/setup.sh <project-name> [db-password]}"
DB_PASS="${2:-$(node -e "console.log(require('crypto').randomBytes(16).toString('hex'))")}"
REGION="eu-central-1"   # schimbă dacă clientul e în altă regiune

# ── Culori ────────────────────────────────────────────────────────────────────
G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; R='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${B}▶${NC} $1"; }
ok()   { echo -e "${G}✓${NC} $1"; }
warn() { echo -e "${Y}⚠${NC}  $1"; }
fail() { echo -e "${R}✗${NC} $1"; exit 1; }
hr()   { echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# ── JSON helper via Node (nu necesită jq) ─────────────────────────────────────
json() {
  node -e "
    let d = '';
    process.stdin.resume();
    process.stdin.on('data', c => d += c);
    process.stdin.on('end', () => {
      try { const r = ($1); console.log(r ?? ''); }
      catch (e) { console.error('JSON parse error:', e.message); process.exit(1); }
    });
  "
}

# ── Verificare prerequisite ───────────────────────────────────────────────────
command -v supabase >/dev/null || fail "supabase CLI lipsește → npm install -g supabase"
command -v vercel   >/dev/null || fail "vercel CLI lipsește   → npm install -g vercel"
command -v node     >/dev/null || fail "node.js lipsește"

[ -f "supabase/schema.sql" ] || fail "supabase/schema.sql nu există. Rulează din rădăcina proiectului."

hr
echo -e "${B}  Setup: ${PROJECT_NAME}${NC}"
hr
echo ""

# ── 1. Autentificare Supabase ─────────────────────────────────────────────────
log "Verificare autentificare Supabase..."
if ! supabase projects list >/dev/null 2>&1; then
  warn "Autentificare necesară. Se deschide browserul..."
  supabase login
fi
ok "Autentificat Supabase"

# ── 2. Org ID ─────────────────────────────────────────────────────────────────
log "Preiau org ID..."
ORG_ID=$(supabase orgs list --output-format json | json "JSON.parse(d)[0].id")
[ -z "$ORG_ID" ] && fail "Nu s-a găsit niciun org Supabase."
ok "Org: ${ORG_ID}"

# ── 3. Creare proiect Supabase ────────────────────────────────────────────────
log "Creare proiect Supabase \"${PROJECT_NAME}\" (${REGION})..."
PROJECT_JSON=$(supabase projects create "$PROJECT_NAME" \
  --org-id      "$ORG_ID"   \
  --db-password "$DB_PASS"  \
  --region      "$REGION"   \
  --output-format json)
PROJECT_REF=$(echo "$PROJECT_JSON" | json "JSON.parse(d).id")
SUPABASE_URL="https://${PROJECT_REF}.supabase.co"
[ -z "$PROJECT_REF" ] && fail "Creare proiect eșuată."
ok "Proiect creat: ${PROJECT_REF}"

# ── 4. Aștept ca proiectul să fie activ ──────────────────────────────────────
log "Aștept proiectul să pornească (max ~90s)..."
READY=0
for i in $(seq 1 18); do
  STATUS=$(supabase projects list --output-format json | \
    json "JSON.parse(d).find(p => p.id === '${PROJECT_REF}')?.status ?? 'UNKNOWN'")
  if [ "$STATUS" = "ACTIVE_HEALTHY" ]; then
    READY=1
    ok "Proiect activ (după $((i * 5))s)"
    break
  fi
  printf "."
  sleep 5
done
[ $READY -eq 0 ] && warn "Proiectul nu răspunde după 90s — continuăm, poate merge oricum"
echo ""

# ── 5. Link proiect local ─────────────────────────────────────────────────────
log "Link proiect local..."
supabase link --project-ref "$PROJECT_REF" --password "$DB_PASS" --yes
ok "Linked la ${PROJECT_REF}"

# ── 6. Aplică schema SQL ──────────────────────────────────────────────────────
log "Aplică schema în baza de date..."
supabase db query --linked --file supabase/schema.sql
ok "Schema aplicată"

# ── 7. Preiau cheile API ──────────────────────────────────────────────────────
log "Preiau cheile API..."
KEYS=$(supabase projects api-keys --project-ref "$PROJECT_REF" --output-format json)
ANON_KEY=$(echo "$KEYS"    | json "JSON.parse(d).find(k => k.name === 'anon').api_key")
SERVICE_KEY=$(echo "$KEYS" | json "JSON.parse(d).find(k => k.name === 'service_role').api_key")
[ -z "$ANON_KEY" ] && fail "Nu am putut prelua anon key."
ok "Chei preluate"

# ── 8. Scriu .env.local ───────────────────────────────────────────────────────
log "Scriu .env.local..."
cat > .env.local << ENVEOF
NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL}
NEXT_PUBLIC_SUPABASE_ANON_KEY=${ANON_KEY}
SUPABASE_SERVICE_ROLE_KEY=${SERVICE_KEY}
RESEND_API_KEY=
ADMIN_EMAIL=
ENVEOF
ok ".env.local creat"

# ── 9. Setez env vars în Vercel ───────────────────────────────────────────────
log "Setez env vars în Vercel (production)..."
printf '%s' "$SUPABASE_URL"  | vercel env add NEXT_PUBLIC_SUPABASE_URL    production --yes
printf '%s' "$ANON_KEY"      | vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production --yes
printf '%s' "$SERVICE_KEY"   | vercel env add SUPABASE_SERVICE_ROLE_KEY   production --yes
ok "Env vars setate"

# ── 10. Deploy ────────────────────────────────────────────────────────────────
log "Deploy pe Vercel production..."
vercel --prod --yes
ok "Deploiat!"

# ── Sumar final ───────────────────────────────────────────────────────────────
echo ""
hr
echo -e "${G}  ✓ Gata! Site-ul e live.${NC}"
hr
echo ""
echo -e "  Supabase  →  https://supabase.com/dashboard/project/${PROJECT_REF}"
echo ""
echo -e "${Y}  Salvează parola DB în 1Password (nu mai apare nicăieri după asta):${NC}"
echo -e "${Y}  DB Password: ${DB_PASS}${NC}"
echo ""
echo "  Next steps:"
echo "  1. Creează user admin: Supabase → Authentication → Users → Add user"
echo "  2. Completează RESEND_API_KEY + ADMIN_EMAIL în .env.local și Vercel"
echo "  3. Editează lib/config.ts cu datele clientului"
echo "  4. vercel --prod  (redeploy după ce ai completat config.ts)"
echo ""
