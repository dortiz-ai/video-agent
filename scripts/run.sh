#!/usr/bin/env bash
# Ejecuta el pipeline de video sin intervención humana usando Claude Code en modo headless.
# Uso: scripts/run.sh briefs/<slug>.yaml            (un brief)
#      scripts/run.sh briefs/*.yaml                 (lote)
# Requiere: Claude Code CLI instalado y ANTHROPIC_API_KEY (o sesión iniciada).
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -eq 0 ]; then echo "Uso: $0 briefs/<slug>.yaml [...]" >&2; exit 1; fi

for brief in "$@"; do
  echo ">> Procesando $brief"
  claude -p "/produce $brief" \
    --permission-mode acceptEdits \
    --allowedTools "Read,Write,Edit,Glob,Grep,Skill" \
    --output-format text \
    | tee "logs/$(basename "$brief" .yaml).log"
done
