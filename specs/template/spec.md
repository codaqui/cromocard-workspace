# CCDnnn — <Nome do caso de uso>

- **Status:** Rascunho
- **Fase:** MVP | Futuro | Futuro Marketplace | Escopo Adicional
- **User story:** #<id> `CCDnnn - <Nome>` <!-- ou: não encontrada no board -->
- **Caso de uso:** [NN-<nome>.md](../../docs/Casos-De-Uso/NN-<nome>.md)
- **Atores:** <…> · **Pré-condições:** <…>
- **Data:** AAAA-MM-DD · **Autor:** <nome>
- **Aprovação:** — <!-- AAAA-MM-DD, <quem> (PO) -->

## Objetivo

> <narrativa da user story, copiada de `docs/Casos-De-Uso/user-stories.md`>

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | <uma frase verificável> | Ação | `NN-<nome>.md`, FP 1 |

Tipos: Tela · Campo · Ação · Regra · Permissão · Mensagem · Estado.

## Critérios de aceite

- **CA1** (R1, R2) — **Dado** <contexto>, **quando** <ação>, **então** <resultado observável>.

<!-- Um critério para o fluxo principal, um para cada fluxo alternativo e os de permissão e de estado (vazio, erro, carregando). -->

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `<tabela>` | `<coluna>`, `<enum>` | <regra do DBML: obrigatória, única, default> |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| <nome do frame> | [<node-id>](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=<node-id>) | R1, R3 | ✅ Bate · ❌ Não bate |

- **Onde o Figma está errado** (vale a documentação): <tela> — "<elemento>": mostra <X>; a documentação pede <Y> (R<n>).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R<n> <requisito>.

## Fora do escopo

- <elemento ou comportamento> — pertence a <CCDnnn | fase Futuro> | não está na documentação.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | <o que a documentação não diz> | pendente | — |

<!-- Spec com lacuna pendente não é aprovada. Regra de negócio decidida vai para o caso de uso; decisão técnica, para um ADR. -->
