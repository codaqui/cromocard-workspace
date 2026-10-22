# Plano — CCD094 Validar Cadastro de Vendedor

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Domínio `admin/seller-verifications` com lista, resumo, dossiê, validação de documento, notas, aprovação e rejeição, cada decisão numa transação com `audit_logs`. O Dashboard ganha a lista e o card; a Gestão de Usuários ganha o status da análise; os Relatórios ganham o tipo "Auditoria de Lojistas".

## Dependências

- Fundação (`AuditLogService`, `ConfirmDialog` com motivo, `DataTable`, `Badge`).
- CCD058 (Dashboard), CCD059 (lista de usuários), CCD063 (exportadores).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `seller_verifications` | `create_seller_verifications_table` | tabela e enum `seller_verification_status` | R5, R8, R9 |
| `seller_documents` | `create_seller_documents_table` | tabela e enum `seller_document_status` | R6 |
| `seller_verification_notes` | `create_seller_verification_notes_table` | tabela | R7 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/admin/seller-verifications` | `status`, `page`, `pageSize` | `200` lista paginada | — | R2, R3 |
| `GET /api/v1/admin/seller-verifications/summary` | período | `200` `{ approved, pending, conversionRate }` | — | R4 |
| `GET /api/v1/admin/seller-verifications/:id` | — | `200` dossiê com documentos e notas | `404` | R5 |
| `POST /api/v1/admin/seller-verifications/:id/documents/:documentId/validate` | — | `200` | `404`, `409` | R6, R11 |
| `POST /api/v1/admin/seller-verifications/:id/notes` | `{ content }` | `201` | `400`, `404` | R7 |
| `POST /api/v1/admin/seller-verifications/:id/approve` | `{ reason? }` | `200` | `404`, `409 VERIFICATION_ALREADY_DECIDED` | R8, R11, R14 |
| `POST /api/v1/admin/seller-verifications/:id/reject` | `{ reason }` | `200` | `400`, `404`, `409` | R9, R11, R14 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + 3 migrations · `database/seeds/seller-verifications.seed.ts` | tabelas copiadas do DBML e cadastros de teste | R5–R7 |
| `src/domains/admin/seller-verifications/` (validator, errors, repository) | filtros, dossiê e mudanças de status | R2, R3, R5, R14 |
| `seller-verifications.service.ts` + `.spec.ts` | validar documento, notas, aprovar, rejeitar, auditoria e notificação | R6–R11, R14 |
| controller · routes · swagger · module | rotas acima | R1, R4 |
| `admin-users.repository.ts` · `reports` (tipo `SELLER_AUDIT`) | status da análise na lista e relatório | R12, R13 |
| `src/lib/logger` (redaction) | `cnpj` e `cpf` no `redact` | R15 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/seller-verifications/` (api, queries, types) | chamadas e tipos | R2–R9 |
| `components/SellerRegistrationsTable/` · `SellerCredentialingCard/` | lista e card no Dashboard | R2–R4 |
| `components/SellerVerificationPanel/` (+ `DocumentList`, `InternalNotes`, `RejectDialog`) | painel "Validar Cadastro" | R5–R10 |

## Testes

| Critério | Onde |
|---|---|
| CA3–CA7 | `seller-verifications.service.spec.ts` · integração |
| CA1, CA2, CA8 | `SellerVerificationPanel.spec.tsx` · `SellerRegistrationsTable.spec.tsx` |
| CA9, CA10 | integração |

## Decisões técnicas

- Novo `notifications.type`: `SELLER_REVIEW` (ADR-051, item 2).
- O painel abre como gaveta lateral sobre o Dashboard, como no Figma.
