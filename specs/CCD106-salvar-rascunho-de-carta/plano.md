# Plano — CCD106 Salvar Rascunho de Carta

- **Spec:** [spec.md](spec.md) — feito sobre a spec em Rascunho (pedido do PO em 2026-10-22), com as propostas das lacunas
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Migration com status e ano; o catálogo (CCD061) aceita rascunho com validação mínima, publica com a validação completa, esconde rascunhos das consultas públicas e ganha verso padrão, aviso de duplicata e tamanho mínimo da imagem.

## Dependências

- CCD061 (catálogo e formulário de carta) e a fundação (`/uploads`).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `cards` | `add_status_and_release_year_to_cards_table` | `status`, `release_year` e o enum `card_status` | R2, R8 |
| `global_settings` | — (seed) | chave `catalog.default_backs` | R9 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `POST /api/v1/admin/catalog/cards` (CCD061) | acrescenta `status: DRAFT \| ACTIVE`, `releaseYear?` | `201` | `400` | R2, R8 |
| `POST /api/v1/admin/catalog/cards/:id/publish` | — | `200` | `400`, `404`, `409 ALREADY_PUBLISHED` | R5, R6 |
| `GET /api/v1/admin/catalog/cards` (CCD061) | acrescenta `status` | — | — | R4 |
| `GET /api/v1/admin/catalog/cards/duplicates` | `name`, `albumId?`, `number?` | `200` possíveis duplicatas | — | R10 |
| `POST /api/v1/uploads` (fundação) | acrescenta `minWidth`/`minHeight` para `cards` | `201` | `400 IMAGE_TOO_SMALL` | R11 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration · seed | colunas, enum e verso padrão | R2, R8, R9 |
| `cards.validator.ts` · `catalog.service.ts` + `.spec.ts` | rascunho, publicar, verso padrão, duplicatas e auditoria | R2, R5, R6, R9, R10 |
| `catalog.repository.ts` (consultas públicas) | só `ACTIVE` | R3 |
| `uploads` (fundação) | tamanho mínimo para cartas | R11 |
| routes · swagger | rotas acima | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/catalog/` (api, queries, schemas) | rascunho, publicar e duplicatas | R2–R6, R10 |
| `CardForm` | "Salvar como Rascunho", publicar, ano, verso padrão e tamanho mínimo | R2, R5, R6, R8, R9, R11 |
| `CatalogPage` | filtro "Rascunhos", excluir rascunho e aviso de duplicata | R4, R7, R10 |

## Testes

| Critério | Onde |
|---|---|
| CA1, CA3, CA4, CA5, CA7 | `catalog.service.spec.ts` · `uploads` integração |
| CA2, CA6 | `CardForm.spec.tsx` · `CatalogPage.spec.tsx` |
| CA8 | integração |

## Decisões técnicas

- As consultas públicas do catálogo filtram `status = ACTIVE` no repository, num único ponto.
