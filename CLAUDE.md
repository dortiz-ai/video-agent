# Agente de Producción de Video — Instrucciones

Este repo convierte un **brief** (archivo YAML en `briefs/`) en un paquete de producción de video
listo para ejecutar en Higgsfield (Banana Pro / Soul Cinema / GPT-2 para imágenes, Seedance para video).

## Skills disponibles (`.claude/skills/`)

| Etapa | Skill | Qué produce |
|---|---|---|
| 1. Hook | `hook-generator` | 3–5 hooks; se elige uno |
| 2. Guion | `video-script-generator` | Guion con hook, secciones, CTA |
| 3. Assets de imagen | `banana-pro-director-30` | Prompts de face lock, outfit, character sheet, scene plates |
| 4. Video | `cinema-worldbuilder-pro-20` | Prompts Seedance por toma (Frame Map, Subject Lock, Movement, Last Frame…) |

Lee el `SKILL.md` completo de cada skill antes de usarla y respeta sus reglas "LOCKED".

## MODO AUTÓNOMO (obligatorio cuando se ejecuta con `/produce` o `scripts/run.sh`)

Las skills fueron escritas para uso conversacional y piden confirmaciones. En modo autónomo
**no hay humano**, así que:

1. **El brief responde las preguntas.** La "Session Opener — Character Gate" y la
   "Pre-Prompt Confirmation Rule" se responden con los campos del brief
   (`characters`, `references`, `mode`, `runtime_seconds`, etc.).
2. **No esperes confirmación.** En lugar de preguntar, escribe el resumen pre-prompt en
   `outputs/<slug>/00_preflight.md` y continúa.
3. **Si falta un dato imprescindible** (p. ej. un personaje "built" sin imagen de referencia),
   no inventes: regístralo en `outputs/<slug>/BLOCKERS.md`, sigue con lo que sí puedas
   producir y termina con estado `blocked`.
4. **Herramientas de Higgsfield (selección de modelos):** deja la elección indicada en el brief;
   si no la indica, usa los defaults de cada skill (Banana Pro para imagen).

## Pipeline

Para un brief `briefs/<slug>.yaml`, crea `outputs/<slug>/` con:

```
00_preflight.md        resumen pre-prompt (lo que antes se confirmaba con el usuario)
01_hooks.md            hooks candidatos + el elegido y por qué
02_script.md           guion completo, con tiempos por sección
03_shotlist.md         tabla: toma, duración, modo cinema (M1–M5), personajes, refs
04_image_prompts.md    un bloque de código por asset (Banana Pro Director)
05_video_prompts.md    entrega en 3 partes por toma (Cinema Worldbuilder): refs numeradas, título, bloque de código
manifest.json          resumen máquina-legible (ver abajo)
BLOCKERS.md            solo si algo falta
```

`manifest.json`:

```json
{
  "slug": "...",
  "status": "ready | blocked",
  "brand": "...",
  "runtime_seconds": 0,
  "image_assets": [{"id": "char_face_lock", "tool": "banana-pro", "aspect": "3:4", "prompt_file": "04_image_prompts.md#char_face_lock"}],
  "shots": [{"id": "shot_01", "seconds": 5, "mode": "M1", "references": ["char_face_lock"], "prompt_file": "05_video_prompts.md#shot_01"}]
}
```

## Reglas generales

- Hooks y guion en el idioma del brief (`language`, por defecto `es`). Los prompts de imagen y
  Seedance siempre en **inglés** (regla "OUTPUT LANGUAGE (LOCKED)" de la skill).
- Seedance: máximo 9 imágenes de referencia por toma; audio solo diegético (sin música ni letras).
- Si el brief nombra una marca con skill propia (CLUB 79, DISTRINA, CCSA, etc.) y existe en
  `.claude/skills/`, úsala para el tono del hook y guion.
- Nunca sobrescribas un `outputs/<slug>/` existente: crea `outputs/<slug>-v2/`, `-v3/`…
