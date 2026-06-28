#!/usr/bin/env bash
set -euo pipefail

# ─── build_and_install.sh ────────────────────────────────────
# Compila el APK release, lo copia a APK/ y lo instala en el
# dispositivo conectado vía ADB.
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Compilando APK release ==="
flutter build apk --release

echo "=== Copiando a APK/ ==="
mkdir -p APK
cp build/app/outputs/flutter-apk/app-release.apk APK/dino_flt.apk

echo "=== Instalando en dispositivo ==="
adb install -r APK/dino_flt.apk

echo "✔ Hecho. APK en APK/dino_flt.apk"
