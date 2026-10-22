# Plano — CCD061 Gestão de Catálogo

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

Domínio `catalog` com CRUD de álbuns, cartas e categorias para ADMIN, mais a importação CSV. O `catalogService` é
exportado pelo `catalog.module.ts` para a CCD064 criar itens aprovados. A tela tem as três abas, os formulários em
modal e a importação.

## Dependências

- Fundação (tabelas, seeds de raridades e idiomas, `/uploads`, `AuditLogService`, `Tabs`, `DataTable`, `FileUpload`).

## Contrato da API

Todas com `authenticate` + `authorize('ADMIN')`, prefixo `/api/v1/admin/catalog`.

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /albums` · `GET /cards` · `GET /categories` | `q`, filtros (`albumId`, `categoryId`, `rarityId`, `year`), `page`, `pageSize`, `sort` | `200` `{ data, meta }` | `400` | R3 |
| `POST /albums` · `PATCH /albums/:id` | campos de R5 | `201` / `200` | `400`, `404 ALBUM_NOT_FOUND` | R4, R5, R8 |
| `DELETE /albums/:id` | — | `204` | `404`, `422 ALBUM_HAS_CARDS` | R10, R11 |
| `POST /cards` · `PATCH /cards/:id` | campos de R6 | `201` / `200` | `400`, `404`, `409 CARD_NUMBER_TAKEN` | R4, R6–R8 |
| `DELETE /cards/:id` | — | `204` | `404`, `422 CARD_IN_USE` | R10, R11 |
| `POST /categories` · `PATCH /categories/:id` · `DELETE /categories/:id` | `name`, `type`, `parentCategoryId?` | `201` / `200` / `204` | `400`, `404`, `422 CATEGORY_IN_USE` | R15 |
| `POST /cards/import` | `multipart` com `file` (CSV) | `201` `{ data: { created } }` | `422 CSV_INVALID` com `details` por linha | R13 |
| `GET /cards/import/template` | — | `200` CSV modelo | — | R13 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/catalog/catalog.validator.ts` · `catalog.errors.ts` | schemas e erros acima | R5–R8, R11 |
| `albums.repository.ts` · `cards.repository.ts` · `categories.repository.ts` | CRUD, filtros, restauração por (`album_id`, `number`), checagem de vínculos | R3, R7, R10, R11 |
| `catalog.service.ts` + `.spec.ts` | regras, `total_cards` calculado, auditoria; exportado para a CCD064 | R4–R11, R14 |
| `catalog-import.service.ts` + `.spec.ts` | leitura do CSV (`csv-parse`), validação de todas as linhas e gravação em transação | R13 |
| `catalog.controller.ts` · `catalog.routes.ts` · `catalog.swagger.ts` · `catalog.module.ts` | rotas de admin | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/catalog/catalog.api.ts` · `.queries.ts` · `.schemas.ts` · `.types.ts` | chamadas e schemas | R4–R8 |
| `pages/CatalogAdminPage/` | abas Cartas, Álbuns e Categorias com busca, filtros e `DataTable` | R2, R3 |
| `components/CardFormModal/` · `AlbumFormModal/` · `CategoryFormModal/` | formulários com upload de imagem | R4–R9, R12 |
| `components/ImportCsvModal/` | upload do CSV, modelo para baixar e lista de erros por linha | R13 |
| `components/DeleteCatalogItemDialog/` | confirmação e motivo do bloqueio | R10, R11 |

## Testes

| Critério | Onde |
|---|---|
| CA1 | `CatalogAdminPage.spec.tsx` |
| CA2–CA4 | `catalog.service.spec.ts` · integração |
| CA5, CA6 | `catalog-import.service.spec.ts` · integração |
| CA7 | integração |

## Decisões técnicas

- Biblioteca `csv-parse` para o CSV: ADR-050 (Proposto).
