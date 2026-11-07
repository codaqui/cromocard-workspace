---
paths:
  - "docs/Diagramas/**"
  - "**/*.puml"
  - "**/*.c4"
---

# Diagramas (PlantUML e LikeC4)

- PlantUML: exporte em **SVG, não PNG** (o servidor público corta PNG em 4096px). Atualize o `.svg` junto
  com o `.puml`.
- Nas legendas `.puml`, escreva `|` como `&#124;`.
- C4 usa `!include` do C4-PlantUML via GitHub raw.
- Cobertura atual: o diagrama de casos de uso (`.puml`) e o de atividades (LikeC4) vão até CCD107. Caso de uso
  novo ou alterado muda também o diagrama de casos de uso e a `dynamic view` dele no diagrama de atividades.
- C4: Web e BackOffice são um único SPA (ADR-038) e não há aplicativo mobile (ADR-058). No nível 3 e no diagrama
  de atividades o BackOffice aparece como elemento à parte (`backofficeApp`) só para separar os fluxos do admin.
- Para gerar o `.svg` sem enviar o diagrama a um servidor externo:
  `docker run --rm -i plantuml/plantuml -tsvg -pipe < arquivo.puml > arquivo.svg`
- O DER não usa PlantUML: é DBML no dbdiagram.io, com o print `.png` ao lado de cada `.dbml` (`docs/Diagramas/DER/README.md`).
- LikeC4: cada pasta com `.c4` é um projeto próprio (`likec4.config.json`): `diagrama-classes` e
  `diagrama-atividades`. Sem isso o LikeC4 junta todos os `.c4` de `docs/` num modelo só e acusa elementos duplicados. Valide cada projeto, com o layout:
  `npx likec4 validate -p <projeto> docs/` (versão 1.59 ou mais nova; `npx likec4 validate --no-layout docs/`
  confere os dois de uma vez, sem o layout).
- O LikeC4 não aceita relação de um elemento com ele mesmo (`a -> a`): descreva o autorrelacionamento nas
  `observacoes` da classe.
