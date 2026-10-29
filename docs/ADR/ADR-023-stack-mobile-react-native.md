# ADR-023 — Stack do aplicativo mobile: React Native

- **Status:** Aceito (validado pelo PO em 29/10/2026, na revisão da issue #2)
- **Data:** 2026-09-29
- **Decisores:** Equipe CromoCard

## Contexto

O C4 Nível 2 define o **Aplicativo Mobile** com a stack React Native, entregando "as mesmas
funcionalidades da web, otimizado para uso mobile" (`docs/Diagramas/Diagramas-C4/02-containers.puml`).
Consome a mesma API REST que a Web e o BackOffice.

## Decisão

Construir o aplicativo mobile (iOS/Android) com React Native, como app nativo instalável, e não
como PWA ou apps nativos separados por plataforma.

## Alternativas consideradas

- **PWA único** cobrindo mobile e web sem app nativo instalável.
- **Flutter** (Dart) como framework multiplataforma alternativo.
- **Apps nativos separados** (Swift/Kotlin) por plataforma.

## Consequências

**Positivas**
- Reaproveita o conhecimento de React da equipe (mesma linguagem/paradigma da Web).
- Um único codebase cobre iOS e Android, reduzindo esforço frente a apps nativos separados.

**Negativas / riscos**
- Mantém uma segunda codebase de UI (React Native não compartilha componentes visuais com o
  React Web), exigindo esforço de paridade funcional entre os dois.
- Curva de aprendizado adicional da equipe com o ecossistema React Native (build nativo,
  bibliotecas específicas de mobile, publicação nas lojas).

## Referências

- `docs/Diagramas/Diagramas-C4/02-containers.puml`
- `CLAUDE.md` (tabela de containers)
