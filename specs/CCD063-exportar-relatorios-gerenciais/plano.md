# Plano — CCD063 Exportar Relatórios Gerenciais

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22; revisada em 2026-11-16 (L8–L10)
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade · **Revisão:** 2026-11-16, Lucca Rocha

## Solução

`GET /api/v1/admin/reports/:type` devolve a pré-visualização: as primeiras linhas e o total do período.
`GET /api/v1/admin/reports/:type/export?format=` gera o arquivo inteiro (CSV ou PDF) e grava `EXPORT_REPORT` em
`audit_logs`. O histórico das exportações é da CCD107 (L10).

## Dependências

- CCD058: o filtro de período do Dashboard (`PERIOD_PRESETS`, `resolvePeriod`) é reaproveitado, para os dois terem as
  mesmas opções (L7).
- Fundação: `AuditLogService` e o esqueleto `src/domains/admin/reports/` (module, routes e swagger vazios).

## Contrato da API

O período segue o Dashboard: `period=today|7d|30d|1y` (padrão `30d`) **ou** `from` e `to` em ISO 8601, nunca os dois.

### `GET /api/v1/admin/reports/:type` — R3–R7, R11, R12, R15

- `type`: `signups` | `catalog` · query `period` ou `from`/`to`, `pageSize` (1 a 50, padrão 10)
- **Sucesso:** `200` `{ "data": { "type", "period": { "from", "to" }, "columns": [{ "key", "label" }], "rows": [ … ] },
  "meta": { "total" } }`
  - `signups`: `name`, `email`, `role`, `createdAt` (Nome, E-mail, Papel, Cadastro)
  - `catalog`: `kind` (`CARD` | `ALBUM`), `name`, `number`, `album`, `franchise`, `createdAt` (Tipo, Nome, Número, Álbum,
    Franquia, Cadastro) — L8
- **Erros:** `400 VALIDATION_ERROR` (tipo ou período inválido) · `401` · `403`

### `GET /api/v1/admin/reports/:type/export` — R8–R10, R12

- query `format=csv|pdf` e o mesmo período da prévia
- **Sucesso:** `200` com `Content-Type` `text/csv; charset=utf-8` ou `application/pdf` e
  `Content-Disposition: attachment; filename="cromocard-<type>-<AAAA-MM-DD>-<AAAA-MM-DD>.<ext>"`
- Grava `EXPORT_REPORT` em `audit_logs` com `details: { type, format, from, to, total }` (L4)
- **Erros:** `422 REPORT_EMPTY` (sem linhas) · `400` · `401` · `403`

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/admin/reports/reports.validator.ts` · `.errors.ts` | tipos, formato, período e tamanho da prévia | R4, R5, R10 |
| `reports.repository.ts` | linhas e total de cadastros e de catálogo do período, sem excluídos | R11, R15 |
| `reports.definitions.ts` | colunas e rótulos de cada relatório | R11, L8 |
| `exporters/csv.exporter.ts` · `exporters/pdf.exporter.ts` | CSV (UTF-8 BOM, `;`) e PDF (`pdfkit`) | R10 |
| `reports.service.ts` + `.spec.ts` | pré-visualização, exportação e auditoria | R6–R9, R12 |
| `reports.controller.ts` · `.routes.ts` · `.swagger.ts` · `.module.ts` | 2 rotas ADMIN | R1 |
| `audit-logs.validator.ts` | ação `EXPORT_REPORT` | R9, L4 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/reports/reports.api.ts` · `.queries.ts` · `.types.ts` | chamadas; download por `blob` | R9 |
| `pages/ReportsPage/` | grade dos 4 relatórios (2 desabilitados, "Em breve", L9), `PeriodFilter`, pré-visualização, botões PDF/CSV com `ExportConfirmDialog`, aviso de exportado e a seção de histórico vazia até a CCD107 | R2–R8, R12–R14 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA3 | `reports.service.spec.ts` · `csv.exporter.spec.ts` · `pdf.exporter.spec.ts` · integração |
| CA4, CA5 | `ReportsPage.spec.tsx` (e `422 REPORT_EMPTY` na integração) |
| CA6 | integração |

## Decisões técnicas

- Biblioteca nova `pdfkit` para o PDF: ADR-050 (Aceito).

## Revisão de 12/11/2026 (L6, L7)

- R3 e R5: a tela tem a grade dos 4 relatórios e o seletor de período do Dashboard (Hoje, 7D, 30 dias, 1 ano e intervalo).
- R7: a prévia mostra as primeiras linhas e o total, sem gráficos; sem dados, os botões de exportar ficam desabilitados.
- R8: "Exportar PDF" e "Exportar CSV" abrem `ExportConfirmDialog` com tipo, período, formato e total.
- R16: o histórico e o "Baixar" passam a ser os da CCD107 (`report_exports`), sem gerar o arquivo de novo.
- Telas novas: `843-442`, `843-1246`, `843-1674`.

## Revisão de 16/11/2026 (L8–L10)

- L8: colunas do relatório de catálogo definidas (tabela do contrato).
- L9: "Auditoria de Lojistas" e "Volume Transacionado & Custódia" aparecem desabilitados; a API não aceita esses tipos.
- L10: sai a rota `GET /reports/exports` (que lia `audit_logs`, decisão L3); o histórico é da CCD107.
- A prévia deixou de ser paginada: devolve as primeiras linhas (`pageSize`) e o total, que é o que a tela mostra.
- O período usa o mesmo filtro do Dashboard (`period` ou `from`/`to`).
