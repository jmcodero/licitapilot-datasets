#!/usr/bin/env bash
#
# Actualiza los datasets abiertos de LicitaPilot desde producción (PLACSP) y
# los publica en GitHub (+ opcionalmente Hugging Face y el dominio).
#
# Uso:
#   ./update.sh                 # regenera, commitea y pushea a GitHub
#   HF_TOKEN=hf_xxx ./update.sh  # además re-sube a Hugging Face
#
# Requisitos: acceso SSH al VPS (clave id_ed25519-2), git con credencial de
# GitHub en el llavero, y python3 con huggingface_hub (solo si usas HF_TOKEN).
#
set -euo pipefail

# --- Configuración ---
SSH_KEY="$HOME/.ssh/id_ed25519-2"
SERVER="root@95.217.184.177"
REPO_DIR="$HOME/dev/licitapilot-datasets"
APP_DATOS="$HOME/dev/tenderradarai/frontend/public/datos"   # copia para el dominio (requiere deploy aparte)
HF_REPO="jcordero/licitapilot"
TODAY="$(date +%Y-%m-%d)"
RAW="$(mktemp)"; ERR="$(mktemp)"
trap 'rm -f "$RAW" "$ERR"' EXIT

echo "==> [1/5] Extrayendo datos de producción (PLACSP)..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SERVER" \
  'cd /opt/licitapilot && docker compose -f docker-compose.prod.yml exec -T backend python -' \
  > "$RAW" 2> "$ERR" <<'PYREMOTE'
from app.database import SessionLocal
from app.public.stats import division_index
from app.public.market import market_index
from app.public.routes import public_provincias
from starlette.responses import Response
import json
db = SessionLocal()
out = {
    "baja": division_index(db),          # baja media por CPV
    "cpv":  market_index(db),            # nº contratos + volumen por CPV
    "prov": public_provincias(Response(), db),  # nº contratos + importe por provincia
}
print(json.dumps(out, ensure_ascii=False, default=str))
db.close()
PYREMOTE

echo "==> [2/5] Construyendo CSV/JSON (fecha de corte $TODAY)..."
REPO_DIR="$REPO_DIR" TODAY="$TODAY" python3 - "$RAW" <<'PYBUILD'
import json, os, sys, csv
raw = sys.argv[1]
repo = os.environ["REPO_DIR"]; today = os.environ["TODAY"]
try:
    d = json.load(open(raw, encoding="utf-8"))
except Exception as e:
    sys.exit(f"ERROR: no se pudo parsear la salida de producción: {e}")
baja, cpv, prov = d["baja"], d["cpv"], d["prov"]
assert len(baja) and len(cpv) and len(prov), "alguna consulta devolvió 0 filas"

def write(folder, filename, header, rows, jrows, dataset_id):
    dd = f"{repo}/{folder}"; os.makedirs(dd, exist_ok=True)
    with open(f"{dd}/{filename}.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f); w.writerow(header)
        for r in rows: w.writerow(r)
    json.dump({"dataset": dataset_id, "fuente": "PLACSP", "licencia": "CC-BY-4.0",
               "fecha_corte": today, "filas": jrows},
              open(f"{dd}/{filename}.json", "w", encoding="utf-8"),
              ensure_ascii=False, indent=2)

# 1) Baja media por CPV
b = sorted(baja, key=lambda r: (r.get("count") or 0), reverse=True)
write("baja-temeraria-por-cpv", "baja-media-por-cpv",
      ["cpv_division","nombre","num_contratos","baja_media_pct"],
      [[r["code"], r["name"], r.get("count") or 0, r.get("mean_baja_pct")] for r in b],
      [{"cpv_division": r["code"], "nombre": r["name"], "num_contratos": r.get("count") or 0,
        "baja_media_pct": r.get("mean_baja_pct")} for r in b],
      "baja-media-contratacion-publica-por-cpv")

# 2) Contratación por sector CPV (volumen)
c = sorted(cpv, key=lambda r: (r.get("volume") or 0), reverse=True)
write("contratacion-por-sector-cpv", "contratacion-por-sector-cpv",
      ["cpv_division","sector","num_contratos","importe_total_eur"],
      [[r["code"], r["sector"], r.get("total") or 0, round(r.get("volume") or 0, 2)] for r in c],
      [{"cpv_division": r["code"], "sector": r["sector"], "num_contratos": r.get("total") or 0,
        "importe_total_eur": round(r.get("volume") or 0, 2)} for r in c],
      "contratacion-publica-por-sector-cpv")

# 3) Contratación por provincia
p = sorted(prov, key=lambda r: (r.get("budget") or 0), reverse=True)
write("contratacion-por-provincia", "contratacion-por-provincia",
      ["provincia","comunidad","codigo_ine","num_contratos","importe_total_eur"],
      [[r["name"], r.get("comunidad") or "", r.get("code") or "", r.get("total") or 0, round(r.get("budget") or 0, 2)] for r in p],
      [{"provincia": r["name"], "comunidad": r.get("comunidad") or "", "codigo_ine": r.get("code") or "",
        "num_contratos": r.get("total") or 0, "importe_total_eur": round(r.get("budget") or 0, 2)} for r in p],
      "contratacion-publica-por-provincia")

print(f"    baja: {len(b)} filas · sector CPV: {len(c)} · provincia: {len(p)}")
PYBUILD

echo "==> [3/5] Actualizando fecha de corte en las fichas (README)..."
# macOS sed
find "$REPO_DIR" -name README.md -exec \
  sed -i '' -E "s/(Fecha de corte:\*\* )[0-9]{4}-[0-9]{2}-[0-9]{2}/\1$TODAY/g" {} +

echo "==> [4/5] Commit + push a GitHub..."
cd "$REPO_DIR"
if git status --porcelain | grep -q .; then
  git add -A
  git -c user.email="betic0@gmail.com" -c user.name="LicitaPilot" \
      commit -q -m "Actualiza datasets desde PLACSP ($TODAY)"
  GIT_TERMINAL_PROMPT=0 git push -q origin main && echo "    push OK"
else
  echo "    Sin cambios en los datos; no se commitea."
fi

# Copia para el dominio (el deploy del frontend es aparte)
if [ -d "$(dirname "$APP_DATOS")" ]; then
  mkdir -p "$APP_DATOS"
  cp "$REPO_DIR"/*/*.csv "$REPO_DIR"/*/*.json "$APP_DATOS"/ 2>/dev/null || true
  echo "    Copiado a public/datos (recuerda: el dominio requiere re-deploy del frontend)."
fi

echo "==> [5/5] Hugging Face..."
if [ -n "${HF_TOKEN:-}" ]; then
  HF_TOKEN="$HF_TOKEN" HF_REPO="$HF_REPO" REPO_DIR="$REPO_DIR" TODAY="$TODAY" python3 - <<'PYHF'
import os
from huggingface_hub import HfApi
api = HfApi(token=os.environ["HF_TOKEN"])
api.upload_folder(repo_id=os.environ["HF_REPO"], repo_type="dataset",
                  folder_path=os.environ["REPO_DIR"], ignore_patterns=[".git*"],
                  token=os.environ["HF_TOKEN"],
                  commit_message=f'Actualiza datasets desde PLACSP ({os.environ["TODAY"]})')
print("    Hugging Face actualizado.")
PYHF
else
  echo "    (omitido) Exporta HF_TOKEN=hf_xxx (write) para re-subir a Hugging Face."
fi

echo "==> Listo. Datasets actualizados a $TODAY."
