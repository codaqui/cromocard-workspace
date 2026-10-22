# Plano — CCD063 Exportar Relatórios Gerenciais

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

`GET /api/v1/admin/reports/:type` devolve a pré-visualização paginada; `GET /api/v1/admin/reports/:type/export?format=`
gera o arquivo inteiro (CSV ou PDF) e grava `EXPORT_REPORT` em `audit_logs`. O histórico lê esses registros.

## Dependências

- CCD058 (`DashboardService` para as consultas de cadastros) e fundação (`AuditLogService`, `Tabs`, `DataTable`).

## Contrato da API

### `GET /api/v1/admin/reports/:type` — R3–R7, R11, R12, R15

- `type`: `signups` | `catalog` · query `from`, `to`, `page`, `pageSize`
- **Sucesso:** `200` `{ "data": [ … linhas … ], "meta": { page, pageSize, total, totalPages } }`
- **Erros:** `400 VALIDATION_ERROR` · `404 REPORT_TYPE_NOT_FOUND` · `401` · `403`

### `GET /api/v1/admin/reports/:type/export` — R8–R10

- query `format=csv|pdf`, `from`, `to`
- **Sucesso:** `200` com `Content-Type` `text/csv` ou `application/pdf` e `Content-Disposition: attachment;
  filename="cromocard-<type>-<from>-<to>.<ext>"`
- **Erros:** `422 REPORT_EMPTY` (sem linhas) · `400` · `401` · `403`

### `GET /api/v1/admin/reports/exports` — R16

- **Sucesso:** `200` `{ "data": [{ "id", "type", "format", "from", "to", "adminName", "createdAt" }], "meta": … }`

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/admin/reports/reports.validator.ts` · `.errors.ts` | tipos, formato e período | R4, R5, R10 |
| `reports.repository.ts` | linhas de cadastros e de catálogo, sem excluídos | R11, R15 |
| `reports.service.ts` + `.spec.ts` | pré-visualização, exportação, auditoria e histórico | R6–R9, R12 |
| `exporters/csv.exporter.ts` · `exporters/pdf.exporter.ts` | CSV (UTF-8 BOM, `;`) e PDF (`pdfkit`) | R10 |
| `reports.controller.ts` · `.routes.ts` · `.swagger.ts` | 3 rotas ADMIN | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/reports/reports.api.ts` · `.queries.ts` · `.types.ts` | chamadas; download por `blob` | R9 |
| `pages/ReportsPage/` | seletor de tipo, `PeriodFilter`, pré-visualização, botões CSV/PDF com `ConfirmDialog`, histórico | R2–R8, R12–R14 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA3 | `reports.service.spec.ts` · `csv.exporter.spec.ts` · integração |
| CA4, CA5 | `ReportsPage.spec.tsx` |
| CA6 | integração |

## Decisões técnicas

- Biblioteca nova `pdfkit` para o PDF: ADR-050 (Proposto).
