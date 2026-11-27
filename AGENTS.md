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
| 6. Generación | `config/higgsfield.yaml` | Modelos, parámetros y créditos para enviar a Higgsfield |

`upper-ux-writer` está escrita para push y CRM. Aquí se usa **solo como guía de tono y de reglas
de marca** para hooks, guion y textos en pantalla, no para su formato `Título / Texto`.

## MODO AUTÓNOMO (siempre que no haya un humano en la conversación)

Las skills fueron escritas para uso conversacional y piden confirmaciones. En modo autónomo:

La preproducción (etapas 0–5) corre de principio a fin sin preguntar nada. La **única** pausa
del pipeline es la autorización de créditos antes de generar en Higgsfield (etapa 6).

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
06_generation_plan.md  plan de generación y créditos (etapa 6)
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
  "shots": [{"id": "shot_01", "seconds": 5, "mode": "M1", "references": ["char_face_lock"], "prompt_file": "05_video_prompts.md#shot_01"}],
  "generation_plan": {"approved": false, "balance_before": 0, "estimated_credits": 0,
                      "items": [{"id": "shot_01", "model_id": "seedance_2_0", "params": {"duration": 5, "resolution": "720p", "aspect_ratio": "9:16"}, "estimated_credits": null}]},
  "results": [{"id": "shot_01", "job_id": "...", "url": "...", "credits_charged": 0, "status": "done | failed"}]
}
```

## Etapa 6 — Generación en Higgsfield (con una sola autorización)

Se ejecuta cuando el brief tiene `generate: auto` (o el usuario pide generar). Con
`generate: prompts_only` el pipeline termina en la etapa 5.

**6.1 Plan de generación.** Con `config/higgsfield.yaml`, arma `06_generation_plan.md` y el
bloque `generation_plan` de `manifest.json`: por cada asset y cada toma, el `model_id`,
los parámetros (resolución, duración, aspect ratio), la cantidad de generaciones y los
créditos estimados. Consulta el saldo del workspace (herramienta de balance de Higgsfield).

**6.2 Pedido de autorización (único mensaje, único momento en que se pregunta algo).**
Envía exactamente esto y espera respuesta:

```
🎬 Listo para generar en Higgsfield — <slug>
Modelos:
- Imagen: <model_id> × <n> generaciones (<resolución>)
- Video: <model_id> × <n> tomas, <s> s en total (<resolución>)
Consumo estimado: <total> créditos   (saldo actual: <saldo> créditos)
¿Autorizas? Responde "sí", o indica qué cambiar (modelo, resolución, número de tomas).
```

- El consumo se expresa en **créditos de Higgsfield** (no en tokens del modelo de lenguaje).
- Si algún precio está en `null` en la configuración, escribe "precio desconocido para <model_id>"
  en esa línea y da el total solo de lo conocido. Nunca inventes precios.
- Si el saldo no alcanza (`total × balance_safety_factor > saldo`), dilo en el mismo mensaje.

**6.3 Ejecución (sin más preguntas).** Con el "sí", envía todo directamente a Higgsfield:
1. Primero los `image_assets`, en orden; cada imagen generada queda como referencia.
2. Después cada toma de `shots`, con sus referencias en el orden del manifest
   (`@image1`…`@image9` del prompt = orden de las referencias adjuntas).
3. Registra en `manifest.json` → `results`: `job_id`, URL del resultado, créditos cobrados y estado.
4. Al terminar, informa: lo generado (con enlaces), créditos consumidos vs. estimados y saldo final.

**6.4 Qué requiere una nueva autorización (mismo formato de 6.2):**
- Cambiar de modelo o subir la resolución o la duración.
- Cualquier regeneración o variante que no estaba en el plan aprobado.
- Si el gasto real va a superar el total aprobado.

Lo que **no** requiere autorización: reintentar un job que falló sin cobrar créditos (una vez).

**6.5 Si no hay herramienta para generar.** Si el agente no tiene una herramienta de Higgsfield
que genere medios, no se detiene en el pipeline: entrega los prompts y el manifest, y avisa en una
línea que la generación debe hacerse a mano en Higgsfield.

## Reglas generales

- Hooks, guion y textos en pantalla en español de Ecuador (o el `language` del brief), con la voz de Upper.
- Prompts de imagen y Seedance siempre en **inglés** (regla "OUTPUT LANGUAGE (LOCKED)" de las skills).
- Seedance: máximo 9 imágenes de referencia por toma; audio solo diegético (sin música ni letras).
- No prometas tiempos, precios ni promociones que no estén en el brief.
- Nunca sobrescribas un `outputs/<slug>/` existente: crea `outputs/<slug>-v2/`, `-v3/`…
