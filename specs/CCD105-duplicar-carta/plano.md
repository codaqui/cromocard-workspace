# Plano — CCD105 Duplicar Carta

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Revisão:** 2026-11-19, Lucas Oliveira Lima — caminhos conferidos com o código da CCD061 já implementada

## Solução

Migration com código e variantes; o catálogo (CCD061) aceita os campos, ganha o resumo, o filtro por ano e a exclusão em lote; o frontend abre o formulário de criar preenchido a partir da carta de origem.

## Dependências

- CCD061 (catálogo, formulário de carta e lista) — implementada. Já entrega o filtro por álbum, os chips dos filtros
  ativos e o "Limpar todos os filtros" (`ActiveFilters`); de R9 falta só o filtro por ano.
- `catalog_requests` (tabela do MVP, já no `schema.prisma`) para contar as solicitações de álbum pendentes. O resumo
  conta direto na tabela e não depende do código da CCD064 (Planejada): até ela entrar, o indicador de pendentes
  mostra 0.

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `cards` | `add_code_and_variants_to_cards_table` | `code` (`varchar(30)`, único), `variants` (`varchar(120)`), copiadas do DBML | R8 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/admin/catalog/summary` | — | `200` `{ albums, licensedAlbums, pendingAlbumRequests }` | `401`, `403` | R1, R7 |
| `GET /api/v1/admin/catalog/cards` (CCD061) | acrescenta `year` (ano do álbum, `albums.year`); o `q` passa a buscar também em `code` | acrescenta `code`, `variants` em cada carta | `401`, `403` | R8, R9, R11 |
| `POST` · `PATCH /api/v1/admin/catalog/cards` (CCD061) | acrescenta `code?`, `variants?` | `201` / `200` | `409 CARD_NUMBER_TAKEN` (CCD061), `409 CARD_CODE_TAKEN` com `details: [{ field: 'code', message: 'Este código já está em uso por <nome>.' }]` | R3–R5, R8 |

- Resumo (L8): `albums` = álbuns não excluídos (`ACTIVE` e `INACTIVE`); `licensedAlbums` = álbuns `ACTIVE`;
  `pendingAlbumRequests` = `catalog_requests` com `type = ALBUM` e `status = PENDING`, não excluídas.
| `POST /api/v1/admin/catalog/cards/bulk-delete` | `{ ids, reason }` | `200` `{ deleted: [ids], skipped: [{ id, name, number }] }` | `400` (lista vazia ou sem motivo), `401`, `403` | R1, R10 |

- A carta não tem ano próprio (o `release_year` é da CCD106): o filtro `year` filtra pelo ano do álbum.
- Na exclusão em lote, as cartas usadas em coleções vão em `skipped` e não geram erro (L6); o motivo vai no
  `details` do `audit_logs` de cada carta excluída.
- Excluir uma carta (`DELETE /cards/:id` da CCD061 ou em lote) grava `code = null` junto com o `deleted_at` e guarda o
  código antigo no `details` do `audit_logs` (L7). Assim o `409 CARD_CODE_TAKEN` só aparece para carta ativa, e a
  carta restaurada pela numeração (`saveNewCard` → `restore`) recebe o `code` do formulário.

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration | colunas novas | R8 |
| `src/domains/catalog/catalog.validator.ts` (+ `.spec.ts`) | `code` e `variants` no criar e editar, `year` na lista de cartas, corpo da exclusão em lote | R3, R8–R10 |
| `src/domains/catalog/catalog.errors.ts` | `CardCodeTakenError` (`409 CARD_CODE_TAKEN`, com o nome da carta dona no `details`, L10) | R8 |
| `src/domains/catalog/catalog-cards.repository.ts` | gravar e devolver `code` e `variants`, busca também por `code`, filtro por ano do álbum, exclusão em lote, `softDelete` limpando o `code` (L7) | R8–R11 |
| `src/domains/catalog/catalog.service.ts` (+ `.spec.ts`) | código único, resumo, exclusão em lote com auditoria e cartas puladas, código antigo no `details` da exclusão (L7) | R4, R5, R7–R10 |
| `catalog.controller.ts` · `catalog.routes.ts` · `catalog.swagger.ts` | rotas de resumo e de exclusão em lote | R1, R7, R10 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/catalog/` (`catalog.api.ts`, `catalog.queries.ts`, `catalog.schemas.ts`, `catalog.types.ts`) | campos e rotas novas | R7–R10 |
| `components/CardForm` · `components/CardFormModal` · `hooks/useCardForm.ts` | código, variantes, mensagem de código repetido com o nome (L10) e o modo "Duplicar carta" (formulário de criar preenchido com nome, franquia, álbum, raridade, idioma, variantes e descrição, sem numeração, código e imagens, L11); "Ano de lançamento" e "Salvar como Rascunho" desabilitados (L12) | R2–R6, R8 |
| `components/CardsTab` · `components/CatalogRowActions` | ação "Duplicar", colunas de código e variantes, filtro por ano, filtro de status desabilitado (L12), seleção e "Excluir selecionadas" | R2, R8–R11 |
| `components/CatalogStats` · `hooks/useCatalogTotals.ts` | os dois cards do Figma no lugar dos da CCD061 (L8) | R7 |
| modal de exclusão em lote (novo, no padrão do `DeleteCatalogItemDialog`) | motivo obrigatório e aviso das cartas puladas no estilo da tela (L13) | R10 |

## Testes

| Critério | Onde |
|---|---|
| CA3, CA5, CA7, CA9 | `catalog.service.spec.ts` |
| CA5 com carta excluída (L7) | `catalog.service.spec.ts` — o código de uma carta excluída pode ser usado de novo |
| CA4 | `catalog.service.spec.ts` (resumo) |
| CA8 | integração das rotas de resumo e de exclusão em lote (`403` vem do middleware da rota, não do service) |
| CA10 | integração de `GET /cards?q=` (a busca é um filtro do Prisma, só o banco real prova) |
| CA1, CA2 | `CardFormModal.spec.tsx` |
| CA6 | `CatalogAdminPage.spec.tsx` — o "Limpar todos os filtros" já é da CCD061; o teste novo cobre o filtro por ano junto |
| CA7, CA9 (tela) | `CatalogAdminPage.spec.tsx` — exclusão em lote com motivo e aviso das puladas |

## Decisões técnicas

- A duplicação é só no frontend (L1).

## Revisão de 12/11/2026 (L5, L6)

- R9: os filtros da lista são Álbum (`albumId`) e Ano (`year`), sem o "Edição / Ano" combinado.
- R10: a exclusão em lote responde com as cartas excluídas e as que ficaram por estarem em coleções
  (`{ deleted: [...], skipped: [...] }`); o modal pede o motivo, que vai no `details` do `audit_logs` de cada carta.
- Telas novas: duplicar carta `832-6457` e excluir em lote `832-4908`.

## Revisão de 19/11/2026

- Caminhos dos arquivos ajustados ao código da CCD061 (`catalog.validator.ts`, `src/features/catalog/`,
  `CatalogAdminPage`, `CardFormModal`).
- Contrato da exclusão em lote alinhado à L6: sem `422 CARD_IN_USE`, as cartas em uso vão em `skipped`.
- Filtro `year` definido como o ano do álbum.
- Resumo sem dependência do código da CCD064.
- CA8 passa para os testes de integração e CA9 entra na tabela de testes.
- L7: excluir a carta libera o código (`code = null`), com o código antigo no `details` do `audit_logs`.
- Conferência com o Figma (L8–L13): indicadores do Figma no lugar dos da CCD061, busca por código (R11, CA10),
  mensagem de código repetido com o nome da carta, campos copiados ao duplicar, elementos da CCD106 desabilitados e
  aviso das cartas puladas no estilo da tela.
