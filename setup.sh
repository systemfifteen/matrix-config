#!/usr/bin/env bash
# setup.sh — prvotné nastavenie Matrix servera
# Spustiť raz pred prvým "docker compose up -d"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Matrix / Element setup ==="

# Kontrola .env
if [ ! -f .env ]; then
  echo "CHYBA: .env neexistuje. Skopíruj .env.example → .env a vyplň hodnoty."
  exit 1
fi
set -a; source .env; set +a

# Kontrola povinných premenných
for var in POSTGRES_PASSWORD MACAROON_SECRET_KEY FORM_SECRET REGISTRATION_SHARED_SECRET; do
  if [ -z "${!var:-}" ]; then
    echo "CHYBA: $var nie je nastavené v .env"
    exit 1
  fi
done

# Generovanie homeserver.actual.yaml zo šablóny
echo "Generujem homeserver.actual.yaml..."
envsubst < homeserver.yaml > homeserver.actual.yaml
echo "  → homeserver.actual.yaml vytvorený"

# Stiahnutie images
echo "Sťahujem Docker images..."
docker compose pull

echo ""
echo "Hotovo. Spusti:"
echo "  docker compose up -d"
echo ""
echo "Po štarte vytvor admin účet:"
echo "  docker exec -it synapse register_new_matrix_user -c /data/homeserver.yaml -a http://localhost:8008"
