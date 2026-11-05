# ADR-026 — Estrutura multi-repositório (documentação separada das aplicações)

- **Status:** Aceito (validado pelo PO em 29/10/2026, na revisão da issue #2)
- **Data:** 2026-09-29
- **Decisores:** Equipe CromoCard

## Contexto

O `CLAUDE.md` descreve a pasta `apps/` como "não versionado neste repo — cada app é um repo git
próprio": `Backend-CromoCard` e `CromoCard-Frontend`, cada um em seu repositório no GitHub. Este
repositório (`CROMOCARD-WORKSPACE`) guarda apenas documentação e artefatos de arquitetura
(casos de uso, C4, DER, board), unidos localmente por um workspace do VS Code
(`CromoCardWorks.code-workspace`).

## Decisão

Manter repositórios Git separados por responsabilidade: um repositório de documentação/artefatos
(este), um repositório para o backend e um para o frontend web — sem monorepo único.

Este repositório (workspace) é usado para o **SDD (Spec-Driven Development)** e a documentação
do backend e do frontend: as especificações e a documentação ficam aqui, e o código fica no
repositório de cada aplicação.

## Alternativas consideradas

- **Monorepo único** contendo backend, frontend(s) e documentação no mesmo repositório Git.
- **Um repositório por pessoa/squad**, em vez de por aplicação.

## Consequências

**Positivas**
- Histórico de commits e pipelines de CI/CD isolados por aplicação.
- Times/pessoas podem trabalhar e versionar cada app de forma independente, sem acoplar releases.

**Negativas / riscos**
- Coordenação de contrato de API entre frontend e backend é manual (sem checagem automática entre
  repositórios).
- Risco de os artefatos de arquitetura (C4, DER) ficarem desatualizados em relação ao código real
  dos apps, caso não haja processo definido de sincronização entre este repositório e
  `Backend-CromoCard`/`CromoCard-Frontend`.
- Hoje ambos os repositórios de aplicação estão vazios (só README) — a decisão vale para quando o
  código começar a existir.

## Referências

- `CLAUDE.md` (seção "Estrutura do repositório")
