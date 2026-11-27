# Agente de Contenido Visual de Upper — Instrucciones

Este repo es la base de conocimiento de **Upper** (courier internacional, Ecuador) para generar
**contenido de imagen y video** con IA. Convierte un **brief** (YAML en `briefs/`) en un paquete
de producción listo para ejecutar en Higgsfield: Banana Pro / Soul Cinema / GPT-2 para imágenes
y Seedance para video.

Este archivo es la fuente principal de instrucciones y vale para cualquier agente (Buzz,
Claude Code u otro). Lee primero este archivo y luego las skills que indica cada etapa.

## Conocimiento (`skills/`)

Cada skill es un `SKILL.md` autocontenido: léelo **completo** antes de usarlo y respeta sus
reglas marcadas como "LOCKED".

| Etapa | Archivo | Para qué |
|---|---|---|
| Voz de marca | `skills/upper-ux-writer/SKILL.md` | Tono de Upper: joven, directo, cómplice, con energía; reglas que no se negocian |
| 1. Hook | `skills/hook-generator/SKILL.md` | 3–5 hooks; se elige uno |
| 2. Guion | `skills/video-script-generator/SKILL.md` | Guion con hook, secciones y CTA |
| 3. Imágenes | `skills/banana-pro-director-30/SKILL.md` | Prompts de face lock, outfit, character sheet y scene plates |
| 4. Video | `skills/cinema-worldbuilder-pro-20/SKILL.md` | Prompts de Seedance por toma (Frame Map, Subject Lock, Movement, Last Frame…) |

`upper-ux-writer` está escrita para push y CRM. Aquí se usa **solo como guía de tono y de reglas
de marca** para hooks, guion y textos en pantalla, no para su formato `Título / Texto`.

## MODO AUTÓNOMO (siempre que no haya un humano en la conversación)

Las skills fueron escritas para uso conversacional y piden confirmaciones. En modo autónomo:

1. **El brief responde las preguntas.** La "Session Opener — Character Gate" y la
   "Pre-Prompt Confirmation Rule" se responden con los campos del brief
   (`characters`, `references`, `mode`, `runtime_seconds`, `image_tool`…).
2. **No esperes confirmación.** Escribe el resumen pre-prompt en
   `outputs/<slug>/00_preflight.md` y continúa.
3. **Si falta un dato imprescindible** (p. ej. un personaje `built` sin imagen de referencia),
   no lo inventes: regístralo en `outputs/<slug>/BLOCKERS.md`, produce lo que sí puedas y
   termina con estado `blocked`.
4. **Herramienta de imagen:** usa `image_tool` del brief; si no viene, el default de la skill (Banana Pro).

## Pipeline

Para un brief `briefs/<slug>.yaml`, crea `outputs/<slug>/` con:

```
00_preflight.md        resumen pre-prompt (lo que antes se confirmaba con el usuario)
01_hooks.md            hooks candidatos + el elegido y por qué
02_script.md           guion completo, con tiempos por sección y textos en pantalla
03_shotlist.md         tabla: toma, duración, modo cinema (M1–M5), personajes, refs
04_image_prompts.md    un bloque de código por asset (Banana Pro Director)
05_video_prompts.md    entrega en 3 partes por toma (Cinema Worldbuilder): refs numeradas, título, bloque de código
manifest.json          resumen legible por máquina (ver abajo)
BLOCKERS.md            solo si algo falta
```

`manifest.json`:

```json
{
  "slug": "...",
  "status": "ready | blocked",
  "brand": "Upper",
  "runtime_seconds": 0,
  "image_assets": [{"id": "char_face_lock", "tool": "banana-pro", "aspect": "3:4", "prompt_file": "04_image_prompts.md#char_face_lock"}],
  "shots": [{"id": "shot_01", "seconds": 5, "mode": "M1", "references": ["char_face_lock"], "prompt_file": "05_video_prompts.md#shot_01"}]
}
```

Orden de ejecución en Higgsfield: primero los assets de `image_assets` (los personajes y
locaciones quedan como referencias) y después cada toma de `shots`, adjuntando las referencias
en el orden indicado.

## Reglas generales

- Hooks, guion y textos en pantalla en español de Ecuador (o el `language` del brief), con la voz de Upper.
- Prompts de imagen y Seedance siempre en **inglés** (regla "OUTPUT LANGUAGE (LOCKED)" de las skills).
- Seedance: máximo 9 imágenes de referencia por toma; audio solo diegético (sin música ni letras).
- No prometas tiempos, precios ni promociones que no estén en el brief.
- Nunca sobrescribas un `outputs/<slug>/` existente: crea `outputs/<slug>-v2/`, `-v3/`…
