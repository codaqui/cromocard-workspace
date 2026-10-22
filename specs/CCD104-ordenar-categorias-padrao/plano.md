# Plano — CCD104 Ordenar Categorias Padrão

- **Spec:** [spec.md](spec.md) — feito sobre a spec em Rascunho (pedido do PO em 2026-10-22), com as propostas das lacunas
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Migration com as colunas de exibição (gerando o slug das existentes); o serviço de configurações (CCD066) ganha a leitura e a gravação da ordem; o catálogo passa a ordenar por fixada e `display_order`.

## Dependências

- CCD066 (tela de Configurações) e CCD061 (categorias).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `categories` | `add_display_fields_to_categories_table` | `slug`, `display_order`, `is_pinned`, `badge` e o slug das existentes | R5, R9, R10 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/admin/settings/default-categories` | — | `200` lista ordenada com `slug`, `cardsCount`, `badge`, `isPinned` | — | R2 |
| `PUT /api/v1/admin/settings/default-categories/order` | `{ items: [{ id, displayOrder, isPinned }] }` | `200` | `400`, `404`, `422 MORE_THAN_ONE_PINNED` | R3–R5 |
| `POST` · `PATCH /api/v1/admin/catalog/categories` (CCD061) | acrescenta `badge` | acrescenta `slug` | `409 SLUG_TAKEN` | R9, R10 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration | colunas e slug das existentes | R9 |
| `settings.service.ts` (CCD066) + `.spec.ts` | ler e gravar a ordem, com fixada e auditoria | R4, R5 |
| `catalog` (repository e service) | ordem padrão, slug e selo | R6, R9, R10 |
| routes · swagger | rotas acima | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/settings/` (api, queries) | ordem das categorias | R2–R5 |
| `components/DefaultCategoriesOrder/` | lista com setas, arrastar, fixar e salvar | R2–R4, R7, R8 |
| `CategoryForm` (CCD061) | campo selo | R10 |

## Testes

| Critério | Onde |
|---|---|
| CA2–CA4, CA6 | `settings.service.spec.ts` · `catalog.service.spec.ts` |
| CA1, CA5 | `DefaultCategoriesOrder.spec.tsx` |
| CA7 | integração |

## Decisões técnicas

- O slug é gerado com normalização Unicode (sem acentos, minúsculas e hífens), numa função de `src/lib`.
