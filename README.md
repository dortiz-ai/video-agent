# video-agent

Paquete de skills + instrucciones para que un agente (Claude Code / Claude Agent SDK) genere,
sin intervención humana, todo el material de preproducción de un video para Higgsfield:
hooks, guion, shotlist, prompts de imagen (Banana Pro / Soul Cinema / GPT-2) y prompts de video (Seedance).

## Flujo

```
brief.yaml ──► hook-generator ──► video-script-generator ──► shotlist
                                                              │
                         banana-pro-director-30 ◄─────────────┤  (assets: face lock, outfit, sheets, plates)
                         cinema-worldbuilder-pro-20 ◄─────────┘  (prompts Seedance por toma)
                                         │
                                         ▼
                           outputs/<slug>/  + manifest.json
```

## Estructura

```
CLAUDE.md                      instrucciones del agente (pipeline + MODO AUTÓNOMO)
.claude/skills/                las 4 skills de video, tal como estaban en Claude
.claude/commands/produce.md    comando /produce <brief>
briefs/schema.md               campos del brief
briefs/examples/               brief de ejemplo
scripts/run.sh                 ejecución headless (uno o varios briefs)
outputs/                       resultados por brief
```

## Uso

Interactivo, dentro del repo:

```bash
claude
```

y luego `/produce briefs/examples/ejemplo-reel-barberia.yaml`.

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
  Las otras dos skills están sin cambios.
- Las skills originales piden confirmaciones al usuario; `CLAUDE.md` define cómo el brief
  las responde en modo autónomo.
