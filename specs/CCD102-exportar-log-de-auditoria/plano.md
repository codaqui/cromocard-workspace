# Plano — CCD102 Exportar Log de Auditoria

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Migration com `ip_address`; o `AuditLogService` passa a gravar o IP do request; o domínio `admin/audit-logs` (CCD065) ganha o CSV dos registros filtrados, o resumo de 30 dias, a busca por IP e os filtros rápidos.

## Dependências

- CCD065 (tela de Logs) e a fundação (`AuditLogService`).
- CCD063 (`csv.exporter.ts`).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `audit_logs` | `add_ip_address_to_audit_logs_table` | `ip_address` | R9 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/admin/audit-logs/export` | mesmos filtros da lista | `200` `text/csv` | `404 NO_RECORDS`, `422 TOO_MANY_RECORDS` | R2–R5 |
| `GET /api/v1/admin/audit-logs/summary` | — | `200` `{ total30d, variation, dailyAverage }` | — | R7 |
| `GET /api/v1/admin/audit-logs` (CCD065) | acrescenta `ip` e `preset` | acrescenta `ipAddress` e `reason` | — | R6, R8, R9 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration · `audit-logs.service.ts` | `ip_address` vindo do contexto do request | R9 |
| `audit-logs.service.ts` + `.spec.ts` | exportação, resumo, filtros rápidos e busca por IP | R2–R5, R7–R9 |
| routes · swagger | rotas acima | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/audit-logs/` (api, queries) | exportar e resumo | R2, R7 |
| `AuditLogsPage` | botão "Extrair Logs", resumo, filtros rápidos, coluna de justificativa e busca por IP | R2, R3, R5–R9 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA5 | `audit-logs.service.spec.ts` · integração |
| CA6 | integração |

## Decisões técnicas

- O IP sai de `req.ip` com `trust proxy` configurado (ADR-019).
