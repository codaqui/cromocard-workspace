# CCD105 — Duplicar Carta

- **Status:** Planejada
- **Fase:** Escopo Adicional
- **User story:** #609 `CCD105-Duplicar Carta` · responsável Lucas Oliveira Lima · Sprint 06
- **Caso de uso:** [105-duplicar-carta.md](../../docs/Casos-De-Uso/105-duplicar-carta.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero criar uma carta a partir de outra já cadastrada para não digitar de novo os dados em comum.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `105`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | A ação "Duplicar" abre o formulário de carta preenchido com os dados da carta de origem, sem numeração, código e imagens | Ação | `105`, FP 1–2 |
| R3 | O formulário valida como num cadastro novo | Regra | `105`, FP 3–5 |
| R4 | A carta nova é gravada e registrada em `audit_logs` | Regra | `105`, FP 6 |
| R5 | Numeração já usada no álbum responde erro | Regra | `105`, FA 1–2; DBML `cards (album_id, number)` |
| R6 | Cancelar não cria a carta | Ação | `105`, FA 3–4 |
| R7 | Indicadores: total de álbuns, álbuns licenciados e pendentes de revisão | Campo | EA-061-01 |
| R8 | Código da carta (único) e etiquetas de variante | Campo | EA-061-02; ADR-053, item 5 |
| R9 | Filtro por edição/ano e chips dos filtros ativos com "Limpar todos os filtros" | Campo | EA-061-03 |
| R10 | Seleção de várias cartas, com a ação em lote decidida em L3 | Ação | EA-061-04 |

## Critérios de aceite

- **CA1** (R2) — **Dado** uma carta cadastrada, **quando** o admin clica em "Duplicar", **então** o formulário abre com franquia, álbum, raridade e idioma, sem numeração e imagens.
- **CA2** (R3, R4) — **Dado** o formulário duplicado com nova numeração e imagens, **quando** o admin confirma, **então** a carta nova é criada e o log registra.
- **CA3** (R5) — **Dado** o formulário duplicado com a mesma numeração no mesmo álbum, **quando** o admin confirma, **então** a API responde `409` e nada é criado.
- **CA4** (R7) — **Dado** álbuns ativos e solicitações de álbum pendentes, **quando** o admin abre o catálogo, **então** vê o total, os licenciados e os pendentes.
- **CA5** (R8) — **Dado** um código já usado, **quando** o admin cadastra outra carta com ele, **então** a API responde `409` no campo `code`.
- **CA6** (R9) — **Dado** filtros de franquia e edição aplicados, **quando** o admin clica em "Limpar todos os filtros", **então** a lista volta sem filtros.
- **CA7** (R10) — **Dado** cinco cartas selecionadas, **quando** o admin exclui em lote com motivo, **então** as cinco recebem `deleted_at` e o log registra cada uma.
- **CA8** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `cards` | `code`, `variants` | colunas novas (ADR-053) |
| `albums` | `status`, `year` | MVP |
| `catalog_requests` | `type = ALBUM`, `status` | pendentes de revisão |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Catálogo | [208-2895](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=208-2895) | R2, R7–R10 | ⚠️ Divergente |

- "População base" e "Preço médio ref." são da CCD097.
- O frame está cortado à direita no Figma.

## Fora do escopo

- População e preço médio — CCD097.
- Importação em lote por CSV — CCD061.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Duplicar no backend ou só no frontend? (proposta: só no frontend, abrindo o formulário de criar; sem rota nova) | Só no frontend, abrindo o formulário de criar; sem rota nova | plano.md, Decisões técnicas |
| L2 | "Álbuns licenciados" e "pendentes de revisão" (proposta: licenciado = álbum `ACTIVE`; pendente = solicitação de álbum `PENDING`) | Licenciado = álbum `ACTIVE`; pendente = solicitação de álbum `PENDING` | `escopo-adicional.md`, EA-061-01 |
| L3 | Ação em lote sobre a seleção, que o Figma não desenha (proposta: excluir em lote, com motivo) | Excluir em lote, com motivo | `escopo-adicional.md`, EA-061-04 |
| L4 | Código gerado ou digitado? (proposta: digitado, opcional e único) | Digitado, opcional e único | `escopo-adicional.md`, EA-061-02 |
