# video-agent — Upper

Base de conocimiento de **Upper** para que un agente (Buzz, Claude Code u otro) genere,
sin intervención humana, todo el material de preproducción de un video para Higgsfield:
hooks, guion, shotlist, prompts de imagen (Banana Pro / Soul Cinema / GPT-2) y prompts de video (Seedance).

## Flujo

```
brief.yaml ──► (voz Upper) ──► hook-generator ──► video-script-generator ──► shotlist
                                                              │
                         banana-pro-director-30 ◄─────────────┤  (assets: face lock, outfit, sheets, plates)
                         cinema-worldbuilder-pro-20 ◄─────────┘  (prompts Seedance por toma)
                                         │
                                         ▼
                           outputs/<slug>/  + manifest.json
```

## Estructura

```
AGENTS.md                      instrucciones del agente (pipeline + MODO AUTÓNOMO) — empezar aquí
skills/                        conocimiento: voz de Upper + 4 skills de imagen/video
CLAUDE.md                      solo importa AGENTS.md (para Claude Code)
.claude/skills -> ../skills    enlace para que Claude Code cargue las skills
.claude/commands/produce.md    comando /produce <brief> (Claude Code)
briefs/schema.md               campos del brief
briefs/examples/               brief de ejemplo
scripts/run.sh                 ejecución headless (uno o varios briefs)
outputs/                       resultados por brief
```

## Para el agente de Buzz

Conectar este repo y darle como instrucción: *"Lee `AGENTS.md` y ejecuta el pipeline en MODO AUTÓNOMO para `briefs/<slug>.yaml`"*.
Todo el conocimiento está en Markdown plano; no depende de Claude.

## Uso con Claude Code

Interactivo, dentro del repo:

```bash
claude
```

y luego `/produce briefs/examples/upper-reel-compras-usa.yaml`.

Automatizado (cron, CI, otro agente):

```bash
ANTHROPIC_API_KEY=... scripts/run.sh briefs/*.yaml
```

## Qué queda manual

El conector de Higgsfield disponible en Claude **no genera medios** (solo lista modelos,
muestra generaciones e importa clips). Por eso el agente entrega los prompts y el
`manifest.json`; la generación en Higgsfield se hace pegando los prompts, o conectando
un script propio a la API de Higgsfield que lea `manifest.json`.

## Notas

- `hook-generator` y `video-script-generator`: se corrigió solo el frontmatter (sobraba un `---`).
  Las demás skills están sin cambios.
- `upper-ux-writer` es la skill de push/CRM de Upper; aquí se usa como guía de voz de marca.
- Las skills originales piden confirmaciones al usuario; `AGENTS.md` define cómo el brief
  las responde en modo autónomo.
