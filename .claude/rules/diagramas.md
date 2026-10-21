---
paths:
  - "docs/Diagramas/**"
  - "docs/Diagrama-de-Classe/**"
  - "**/*.puml"
  - "**/*.c4"
---

# Diagramas (PlantUML e LikeC4)

- PlantUML: exporte em **SVG, não PNG** (o servidor público corta PNG em 4096px). Atualize o `.svg` junto
  com o `.puml`.
- Diagramas DER 02 e 03 usam `left to right direction` — mantenha.
- Nas legendas `.puml`, escreva `|` como `&#124;`.
- C4 usa `!include` do C4-PlantUML via GitHub raw.
- Cobertura atual: o diagrama de casos de uso (`.puml`) vai até CCD046; o de atividades (LikeC4) até CCD066.
- O C4 nível 2 (`02-containers.puml`) ainda mostra Aplicação Web e Painel BackOffice separados; na
  implementação eles são um único SPA (ADR-038).
