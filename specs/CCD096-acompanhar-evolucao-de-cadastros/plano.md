# Plano — CCD096 Acompanhar Evolução de Cadastros

- **Spec:** [spec.md](spec.md) — feito sobre a spec em Rascunho (pedido do PO em 2026-10-22), com as propostas das lacunas
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

O domínio `admin/dashboard` (CCD058) ganha a consulta da evolução agrupada por período e o resumo ganha meta, variação, divisão por papel e novas cartas. O frontend acrescenta o gráfico e atualiza os cards.

## Dependências

- CCD058 (dashboard e `PeriodFilter`).
- CCD094 (lojistas certificados).
- CCD066 (tela de Configurações, para a meta — L1).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `global_settings` | — (seed) | chave `dashboard.monthly_signup_goal` | R8 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/admin/dashboard/signups-evolution` | `period`, `from?`, `to?` | `200` `{ data: { bucket, points: [{ at, collectors, sellers }], totals } }` | `400` | R2, R4, R6 |
| `GET /api/v1/admin/dashboard` (CCD058) | mesmo filtro | acrescenta `monthlyGoal`, `goalPercent`, `variations`, `usersByRole`, `newCardsThisWeek` | — | R3, R7–R11 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `dashboard.repository.ts` | agrupamento por hora, dia ou mês no horário de Brasília | R2, R4 |
| `dashboard.service.ts` + `.spec.ts` | meta, variação, divisão por papel e novas cartas | R3, R7–R11 |
| `dashboard.routes.ts` · `.swagger.ts` | rota da evolução | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/dashboard/` (api, queries, types) | evolução e campos novos | R2, R3 |
| `components/SignupsEvolutionChart/` | gráfico SVG com tooltip e estado vazio | R2, R4–R6 |
| `components/KpiCard/` (uso) | meta, variação e divisão por papel | R3, R7, R9–R11 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA4, CA6 | `dashboard.service.spec.ts` |
| CA5 | `SignupsEvolutionChart.spec.tsx` |
| CA7 | integração |

## Decisões técnicas

- Gráfico em SVG próprio, como na CCD058 (sem biblioteca nova).
