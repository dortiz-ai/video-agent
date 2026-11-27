# Esquema del brief

Un brief es un YAML en `briefs/<slug>.yaml`. Campos:

| Campo | Oblig. | Descripción |
|---|---|---|
| `slug` | sí | identificador, kebab-case; nombra la carpeta de salida |
| `brand` | sí | marca o cliente |
| `objective` | sí | qué debe lograr el video (awareness, matrícula, leads…) |
| `audience` | sí | a quién va dirigido |
| `platform` | sí | `reels`, `tiktok`, `youtube-shorts`, `youtube`, `ads`… |
| `aspect_ratio` | sí | `9:16`, `16:9`, `1:1`, `4:5` |
| `runtime_seconds` | sí | duración total objetivo |
| `language` | no | idioma de hook y guion (default `es`) |
| `key_message` | sí | mensaje principal |
| `cta` | sí | llamada a la acción |
| `mode` | no | modo cinema preferido `M1`–`M5`; si falta, el agente elige por toma |
| `characters` | no | lista; cada uno con `name`, `status` (`built` / `needs_developing` / `extra`), `description`, `references` |
| `locations` | no | lista de lugares con `description` y `references` opcionales |
| `references` | no | rutas a imágenes en `briefs/assets/<slug>/` (máx. 9 por toma en Seedance) |
| `generate` | no | `auto` = tras la preproducción pide autorización de créditos y genera en Higgsfield; `prompts_only` = solo entrega prompts (default `auto`) |
| `video_resolution` | no | `480p`, `720p` (default), `1080p`, `4k` — sobrescribe `config/higgsfield.yaml` |
| `image_tool` | no | `banana-pro` (default), `gpt-2`, `soul-cinema` |
| `constraints` | no | do's/don'ts de marca, cosas a evitar |

Responde aquí lo que las skills preguntarían en modo conversacional:
- **¿Personajes recurrentes y están construidos?** → `characters[].status`
- **Modelo para face lock** → `image_tool`
- **Duración / modo** → `runtime_seconds`, `mode`
