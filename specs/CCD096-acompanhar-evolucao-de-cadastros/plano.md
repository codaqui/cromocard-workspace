# Plano — CCD096 Acompanhar Evolução de Cadastros

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22; revisão de 11/11/2026, reaprovada em 12/11/2026
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

## Revisão de 11/11/2026 (L3)

- R3 mudou: o indicador de novos cadastros segue o período, e o percentual da meta mensal só vem no filtro de 30 dias.
  A resposta da evolução manda `goalPercent: null` fora de `30d`; o `KpiCard` esconde o percentual quando é `null`
  (mesmo caminho do R7).
- Testes: o CA8 (7 dias, sem percentual) entra em `dashboard.service.spec.ts` e no teste do card.

## Revisão de 17/11/2026 (L4–L6)

- **Contrato do resumo** — acrescenta `kpis.collectors` e `kpis.sellers` (totais por papel, R10),
  `kpis.newCardsThisWeek` (R11), `kpis.usersVariation` (percentual inteiro; `null` quando o período anterior é zero e
  o atual não, para o "novo" da L2) e `goal: { monthly, percent | null } | null` (`goal` é `null` sem meta, R7;
  `percent` só em `30d`, L3).
- **Contrato da evolução** — `{ bucket: 'hour' | 'day' | 'month', points: [{ at, collectors, sellers }], totals:
  { collectors, sellers } }`, com todos os pontos do período, inclusive os zerados.
- **Intervalo personalizado** — até 1 dia agrupa por hora, até 92 dias por dia e acima disso por mês; os atalhos caem
  nas regras do R4.
- **Lojistas certificados** — `seller_verifications` com `status = APPROVED`, contados por `reviewed_at`.
- **Meta** — lida pela service exportada pelo módulo de configurações (o dashboard não importa o repository de outro
  domínio).
- **Seed (L6)** — cadastros aprovados para alguns vendedores do seed, com `reviewed_at` nos últimos meses.
- **Frontend** — o `SignupsChart` (mensal) dá lugar ao `SignupsEvolutionChart`; a mensagem do R6 fica dentro do card
  do gráfico, como no frame `795-1704`.
