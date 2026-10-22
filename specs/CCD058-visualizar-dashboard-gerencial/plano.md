# Plano — CCD058 Visualizar Dashboard Gerencial

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Repositórios:** backend · frontend
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

`GET /api/v1/admin/dashboard?period=` agrega no banco (Prisma `count`/`groupBy`, SQL cru se precisar) os KPIs, a série
mensal e os vendedores recentes. A tela `/backoffice` monta os cards, o gráfico e a lista com os componentes da
fundação.

## Dependências

- Fundação #481 (tabela `cards`, seeds, `KpiCard`, `PeriodFilter`, `DataTable`, módulo `admin/dashboard`).
- A CCD063 reaproveita o `DashboardService`.

## Contrato da API

### `GET /api/v1/admin/dashboard` — R1, R4–R11, R14, R15

- **Acesso:** `authenticate` + `authorize('ADMIN')`
- **Entrada (query):** `period=today|7d|30d|1y` (padrão `30d`) ou `from` e `to` (ISO)
- **Sucesso:** `200`

  ```json
  { "data": {
      "period": { "from": "ISO", "to": "ISO" },
      "kpis": { "totalUsers": 0, "totalCards": 0, "newUsers": 0, "newSellers": 0 },
      "signupsByMonth": [{ "month": "2026-10", "customers": 0, "sellers": 0 }],
      "isEmpty": false
  } }
  ```

- **Erros:** `400 VALIDATION_ERROR` (período inválido) · `401` · `403`

### `GET /api/v1/admin/dashboard/recent-sellers` — R9

- **Acesso:** ADMIN · **Entrada:** `page`, `pageSize`, `from`, `to`
- **Sucesso:** `200` `{ "data": [{ "id", "name", "email", "createdAt" }], "meta": { … } }`

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/admin/dashboard/dashboard.validator.ts` | período e intervalo | R10, R15 |
| `dashboard.repository.ts` | contagens e série mensal filtrando `deletedAt: null` | R5–R9, R14 |
| `dashboard.service.ts` + `.spec.ts` | resolve o período (fuso de São Paulo), monta a resposta e `isEmpty` | R11, R12 |
| `dashboard.controller.ts` · `.routes.ts` · `.swagger.ts` · `.module.ts` | 2 rotas ADMIN | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/dashboard/dashboard.api.ts` · `.queries.ts` · `.types.ts` | chamadas e query keys por período | R4, R11 |
| `pages/DashboardPage/` | cards, `PeriodFilter`, gráfico, lista e botão "Exportar Dados" (link para Relatórios) | R2, R3, R5–R10 |
| `components/SignupsChart/` | gráfico em SVG, duas séries | R8 |
| `components/RecentSellersTable/` | `DataTable` paginada; "Ver informações" abre a Gestão de Usuários | R9 |
| estados | `LoadingState`, `ErrorState`, `EmptyState` com os textos do caso de uso | R12, R13, R16 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA4 | `dashboard.service.spec.ts` · `tests/integration/admin-dashboard.spec.ts` |
| CA5, CA6, CA8 | `DashboardPage.spec.tsx` |
| CA7 | integração |

## Decisões técnicas

- Gráfico em SVG próprio, sem biblioteca nova (ADR-044 não prevê lib de gráfico).
