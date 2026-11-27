---
description: Ejecuta el pipeline completo de video (hook → guion → shotlist → prompts de imagen → prompts Seedance) a partir de un brief
argument-hint: briefs/<slug>.yaml
---

Ejecuta el pipeline definido en `CLAUDE.md` en **MODO AUTÓNOMO** para el brief: $ARGUMENTS

1. Lee el brief y valídalo contra `briefs/schema.md`. Si falta un campo obligatorio, escribe `BLOCKERS.md` y detente.
2. Lee completas las skills `hook-generator`, `video-script-generator`, `banana-pro-director-30` y `cinema-worldbuilder-pro-20` en `.claude/skills/`.
3. Produce cada archivo de `outputs/<slug>/` en orden (00 → 05 + `manifest.json`).
4. Antes de terminar, corre el "PRE-DELIVERY PASS (Silent QA)" de cinema-worldbuilder sobre cada toma y corrige lo que falle.
5. Termina imprimiendo una sola línea: `STATUS=<ready|blocked> OUTPUT=outputs/<slug>/`.
