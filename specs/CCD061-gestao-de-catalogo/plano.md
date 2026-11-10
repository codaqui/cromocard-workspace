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
| `GET /albums` · `GET /cards` · `GET /categories` | `q`, `page`, `pageSize` e os filtros de cada recurso: cartas `albumId`, `categoryId`, `rarityId`; álbuns `categoryId`, `year`; categorias só `q`. Ordem fixa: cartas por álbum e número, álbuns por título, categorias por nome | `200` `{ data, meta }`; a carta traz o álbum com `id`, `title`, `publisher`, `year` e `totalCards`, para a coluna "Álbum / coleção" e o "Nº álbum" (`004 / 102`) do Figma | `400` | R3 |
| `POST /albums` · `PATCH /albums/:id` | campos de R5 | `201` / `200` | `400`, `404` (`ALBUM_NOT_FOUND`, `CATEGORY_NOT_FOUND`) | R4, R5, R8 |
| `DELETE /albums/:id` | — | `204` | `404`, `422 ALBUM_HAS_CARDS` | R10, R11 |
| `POST /cards` · `PATCH /cards/:id` | campos de R6 | `201` / `200` | `400`, `404` (`CARD_NOT_FOUND`, `ALBUM_NOT_FOUND`, `CATEGORY_NOT_FOUND`, `RARITY_NOT_FOUND`, `LANGUAGE_NOT_FOUND`), `409 CARD_NUMBER_TAKEN` | R4, R6–R8 |
| `GET /rarities` · `GET /languages` | — | `200` `{ data }` com `id` e `name` (raridades na ordem de `sort_order`, idiomas por nome), só leitura | — | R6, R15 |
| `DELETE /cards/:id` | — | `204` | `404`, `422 CARD_IN_USE` | R10, R11 |
| `POST /categories` · `PATCH /categories/:id` · `DELETE /categories/:id` | `name`, `type`, `parentCategoryId?` | `201` / `200` / `204` | `400`, `404` (a categoria ou a pai), `422 CATEGORY_PARENT_INVALID` (pai é ela mesma ou uma subcategoria dela), `422 CATEGORY_IN_USE` | R15 |
| `POST /cards/import` | `multipart` com `file` (CSV) | `201` `{ data: { created } }` | `400` sem arquivo, `413` acima de 4 MB, `422 CSV_INVALID` com `details` por linha (`<linha>.<coluna>`; `<linha>.columns` quando a quantidade de colunas está errada; `file` para o arquivo todo) | R13 |
| `GET /cards/import/template` | — | `200` CSV modelo | — | R13 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/catalog/catalog.validator.ts` · `catalog.errors.ts` | schemas e erros acima (as listagens entram na T2) | R3, R5–R8, R11 |
| `albums.repository.ts` · `cards.repository.ts` · `categories.repository.ts` | CRUD, filtros, restauração por (`album_id`, `number`), checagem dos vínculos dentro do catálogo (álbum com cartas; categoria com álbuns, cartas ou subcategorias); a carta e o `total_cards` do álbum são gravados na mesma transação, reaproveitada pela importação | R3, R7, R10, R11 |
| `references.repository.ts` | lista e confere a existência de raridades e idiomas (seed) | R6, R15 |
| `catalog.service.ts` + `.spec.ts` | regras, `total_cards` calculado, auditoria; confere se álbum, categoria, raridade e idioma informados existem (`404`); recebe a interface `CardUsage` (carta usada em coleções) opcional pelo construtor; exportado para a CCD064 | R4–R11, R14, R15 |
| `catalog-import.service.ts` + `.spec.ts` | leitura do CSV (`csv-parse`), validação de todas as linhas e gravação em transação | R13 |
| `catalog-import.parser.ts` · `catalog-import.rows.ts` · `catalog-import.repository.ts` | leitura e cabeçalho do CSV e modelo para baixar; resolução das referências e dos números por linha; consultas e gravação em transação (criar, restaurar e recalcular `total_cards`) | R7, R13 |
| `catalog.controller.ts` · `catalog.routes.ts` · `catalog.swagger.ts` · `catalog.module.ts` | rotas de admin | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/catalog/catalog.api.ts` · `.queries.ts` · `.schemas.ts` · `.types.ts` | chamadas e schemas | R4–R8 |
| `pages/CatalogAdminPage/` | cabeçalho do Figma (selo, título, subtítulo e os botões "+ Cadastrar Carta", "+ Novo Álbum" e "Importar CSV"), dois cards de totais, abas com ícone e contador, "Linhas por página" e as abas Cartas, Álbuns e Categorias com busca, filtros com ícone, chips de filtros ativos, `DataTable` e paginação numerada | R2, R3 |
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

- Biblioteca `csv-parse` para o CSV: ADR-050.
- Carta usada em coleções (R11, L2): a tabela `collection_cards` ainda não existe e o catálogo não lê tabela de outro
  domínio (ADR-001). O `catalogService` declara a interface `CardUsage` (`isCardInCollections(cardId)`) e a recebe
  opcional pelo construtor, no padrão do `CatalogStats` do dashboard (CCD058). Sem implementação, a carta é tratada
  como não usada; **pendência:** a user story que criar o domínio `collection` liga a implementação no
  `catalog.module.ts`. Decidido em 2026-10-29 com Lucas Oliveira Lima.
- Raridades e idiomas (R6, R15): vêm do seed e não são editados, mas o formulário de carta precisa das opções. Entram
  `GET /rarities` e `GET /languages` só de leitura, e a service confere cada referência informada (álbum, categoria,
  raridade, idioma), respondendo `404` em vez do `500` do erro de chave estrangeira. Decidido em 2026-10-30 com Lucas
  Oliveira Lima.
- Editar a carta para um número que pertence a uma carta excluída do mesmo álbum responde `409 CARD_NUMBER_TAKEN`; a
  carta excluída não é alterada. Restaurar pelo número vale só no cadastro (ADR-015, item 7). Decidido em 2026-10-30
  com Lucas Oliveira Lima.
- Importação CSV (R13, L3): as colunas são as da L3, sem imagem; as cartas importadas entram sem imagem e o admin envia
  a frente depois pela edição. A frente obrigatória (`61`, FP 5; L4) vale para o formulário. Cada linha acha o álbum
  pelo título e a categoria pelo nome (só categorias do tipo `CARD`), sem diferenciar maiúsculas, a raridade pelo nome e
  o idioma pelo código (`pt-BR`, `en`…). Referência não encontrada ou ambígua, nome em branco, número repetido no
  arquivo ou já usado no álbum entram em `details` como `<linha>.<coluna>` e nada é gravado; o número de uma carta
  excluída restaura a linha, como no cadastro. O arquivo usa o limite de 4 MB do upload (ADR-050). Decidido em
  2026-10-30 com Lucas Oliveira Lima.
- Sem parâmetro `sort` nas listagens: nenhum requisito pede ordenação escolhida pelo usuário; a ordem é fixa (contrato
  acima). Decidido em 2026-10-29 com Lucas Oliveira Lima.
- Frontend (T7–T10): as imagens sobem pelo `POST /uploads` da fundação (pastas `cards` e `albums`) assim que o arquivo é
  escolhido, e o formulário guarda a URL devolvida; a chamada fica no `catalog.api.ts`, porque o frontend não tem
  feature de uploads, e o "Salvar" fica bloqueado enquanto há envio em andamento. A confirmação antes de gravar (R8) é um
  segundo passo dentro do mesmo modal. Os `details` de um `400` vão para os campos (ADR-042); os outros erros aparecem
  como mensagem no modal ou no diálogo. O modelo do CSV vem pelo `api.getBlob`, novo em `src/lib/http.ts`, que também
  converte um erro devolvido como `Blob` em `ApiError`. Os selects de álbum e categoria carregam a primeira página
  (até 100) e sempre incluem o item já escolhido (L6). Decidido em 2026-11-05 e 2026-11-06 com Lucas Oliveira Lima.
- Tipo da categoria (L7, L9): a `catalogService` confere o tipo num lugar só (`ensureCategory(id, tipo)`): álbum com
  categoria `ALBUM`, carta com categoria `CARD` e categoria pai do mesmo tipo da filha; trocar o tipo de uma categoria
  em uso também é recusado. Outro tipo responde `422 CATEGORY_TYPE_MISMATCH`. Na importação, a coluna `category` só
  encontra categorias `CARD`, e o nome de uma categoria de álbum vira o erro `<linha>.category` do `CSV_INVALID`. O seed ganha a categoria de álbum "Pokémon TCG" para o álbum "Pokémon Base
  Set". Decidido em 2026-11-08 com Lucas Oliveira Lima.
- Leitura do CSV pelo `csv-parse` com `columns` (ADR-050, item 2): o cabeçalho é conferido contra as colunas esperadas
  e uma coluna faltando ou a mais vira o erro `<linha>.columns`. Decidido em 2026-11-08 com Lucas Oliveira Lima.
- Importação concorrente: se outro admin ocupar o número entre a validação e a gravação, a importação responde
  `409 CARD_NUMBER_TAKEN` em vez de `500`. Decidido em 2026-11-08 com Lucas Oliveira Lima.
- Dashboard (CCD058, R6): o catálogo expõe `countCards()` (cartas sem as excluídas) e o `dashboard.module.ts` passa a
  recebê-lo, preenchendo o KPI "cartas cadastradas". Decidido em 2026-11-08 com Lucas Oliveira Lima.
- **Dívida:** a `catalogService` cuida de álbuns, cartas, categorias e referências (cerca de 290 linhas). Dividir em
  `AlbumsService`, `CardsService` e `CategoriesService` atrás de uma fachada fica para uma Task própria, de preferência
  na CCD064, que mexe nas mesmas regras. Decidido em 2026-11-08 com Lucas Oliveira Lima.
