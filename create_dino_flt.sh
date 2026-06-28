#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# create_dino_flt.sh
# Plantilla para crear y pushear un proyecto Flutter + Flame
# desde cero usando la consola.
#
# Uso:
#   chmod +x create_dino_flt.sh
#   ./create_dino_flt.sh
#
# Requisitos:
#   - git, curl, flutter, python3
#   - Token GitHub con permisos repo (GITHUB_TOKEN)
# ============================================================

# ─── CONFIGURACIÓN ───────────────────────────────────────────
GITHUB_USER="siliconvalleyar-oss"
REPO_NAME="dino_flt"
REPO_DESC="Dino Run - Chrome Dino-style endless runner built with Flutter & Flame Engine"
BRANCH="main"

# ─── 1. Crear proyecto Flutter ──────────────────────────────
echo "=== Creando proyecto Flutter ==="
flutter create --project-name "$REPO_NAME" "$REPO_NAME"
cd "$REPO_NAME"

# ─── 2. Agregar dependencias ────────────────────────────────
echo "=== Agregando dependencias ==="
flutter pub add flame
flutter pub add flame_audio

# (opcional) flutter pub add shared_preferences

# ─── 3. Generar sonidos con Python ──────────────────────────
echo "=== Generando assets de audio ==="
mkdir -p assets/audio

python3 <<- 'PYEOF'
import wave, struct, math, random, os
SR = 44100
def wav(name, samples):
    os.makedirs('assets/audio', exist_ok=True)
    with wave.open(f'assets/audio/{name}', 'w') as wf:
        wf.setnchannels(1); wf.setsampwidth(2); wf.setframerate(SR)
        for s in samples:
            wf.writeframes(struct.pack('<h', int(max(-32767, min(32767, s)))))
# Jump
n = int(SR * 0.15)
wav('jump.wav', [math.sin(2*math.pi*(400+(i/SR)/0.15*800)*(i/SR))*(1-(i/SR)*0.5)*0.4*32767 for i in range(n)])
# Death
n = int(SR * 0.5)
wav('death.wav', [(math.sin(2*math.pi*(600-(i/SR)*500)*(i/SR))*0.4+random.uniform(-1,1)*0.15)*(1-(i/SR)*0.8)*32767 for i in range(n)])
# Score
n = int(SR * 0.1)
wav('score.wav', [(math.sin(2*math.pi*880*(i/SR))*0.5+math.sin(2*math.pi*1320*(i/SR))*0.3)*(1-i/n)*0.4*32767 for i in range(n)])
# Milestone
n = int(SR * 0.35); nl = n // 4
wav('milestone.wav', [math.sin(2*math.pi*[523,659,784,1047][i//nl]*(i%nl/SR))*0.35*(1-(i%nl/nl)*0.6)*32767 for i in range(n)])
PYEOF

# ─── 4. Actualizar pubspec.yaml (assets) ────────────────────
echo "=== Actualizando pubspec.yaml ==="
if grep -q "^flutter:" pubspec.yaml; then
  sed -i '/^flutter:/a\  assets:\n    - assets/images/dino/\n    - assets/audio/' pubspec.yaml
fi

# ─── 5. Inicializar Git ─────────────────────────────────────
echo "=== Inicializando Git ==="
git init
git checkout -b "$BRANCH"
git add -A
git commit -m "feat: initial $REPO_NAME project"

# ─── 6. Crear repositorio en GitHub ─────────────────────────
echo "=== Creando repositorio remoto ==="
if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "ERROR: GITHUB_TOKEN no está definida."
  echo "       Exporta tu token: export GITHUB_TOKEN='ghp_...'"
  exit 1
fi

RESP=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d "$(cat <<-JSON
    {"name":"$REPO_NAME","description":"$REPO_DESC","private":false}
JSON
  )" "https://api.github.com/user/repos")

REPO_URL=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('html_url','ERROR'))")
echo "Repositorio: $REPO_URL"

# ─── 7. Pushear ─────────────────────────────────────────────
echo "=== Pusheando ==="
git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
git push -u origin "$BRANCH"

echo ""
echo "✔ Proyecto $REPO_NAME creado y pusheado exitosamente."
echo "  $REPO_URL"
