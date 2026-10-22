# Plano — CCD107 Consultar Histórico de Relatórios

- **Spec:** [spec.md](spec.md) — feito sobre a spec em Rascunho (pedido do PO em 2026-10-22), com as propostas das lacunas
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Tabela `report_exports`; a exportação da CCD063 passa a guardar o arquivo no `StorageProvider` e a registrar a linha; o histórico e o download leem dessa tabela; um job diário apaga os vencidos.

## Dependências

- CCD063 (exportação e tela de Relatórios).
- Fundação (`StorageProvider`).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `report_exports` | `create_report_exports_table` | tabela | R2, R4 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/admin/reports/exports` (CCD063) | `page`, `pageSize` | `200` lista de `report_exports` | — | R2, R6 |
| `GET /api/v1/admin/reports/exports/:id/file` | — | `200` arquivo | `404`, `410 EXPORT_EXPIRED` | R3, R5 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration | tabela copiada do DBML | R2, R4 |
| `reports.service.ts` (CCD063) + `.spec.ts` | guardar o arquivo e registrar; histórico e download | R2–R5 |
| `src/jobs/cleanup-expired-reports.job.ts` | job diário | R7 |
| routes · swagger | rotas acima | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/reports/` (api, queries) | histórico e download | R2, R3 |
| `ReportsPage` (histórico) | colunas, "Baixar", vencido e vazio | R2, R3, R5, R6 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA3 | `reports.service.spec.ts` · integração |
| CA4 | `cleanup-expired-reports.job.spec.ts` |
| CA5 | `ReportsPage.spec.tsx` |
| CA6 | integração |

## Decisões técnicas

- O arquivo vai para a pasta `reports/` do storage, com o id da exportação no nome.
