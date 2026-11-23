# Plano — CCD078 Mostrar Todas as Cartas

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L10 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

A página pública "Explorar marketplace" (`/marketplace`) chama `GET /api/v1/listings`, que devolve os anúncios ativos
paginados de 8 em 8, com os filtros de categoria, condição, faixa de preço e o termo do campo de busca (depende da L1), e o
total no `meta`. As opções dos filtros vêm de `GET /api/v1/categories/default` (a ordem da CCD104) e de
`GET /api/v1/card-conditions`. Os filtros e a ordenação ficam na URL (depende da L9), viram etiquetas com "✕" e "Carregar
mais cartas" acumula as páginas. O cartão do anúncio (`ListingCard`) nasce aqui e é reaproveitado pela Home (CCD001) e pela
busca global (CCD002).

## Dependências

- **Tabelas do marketplace:** `listings` e `orders` são criadas pela CCD097 e `card_conditions` pela CCD084 (como o plano da
  CCD079 já registra). Se esta story for implementada antes, ela cria as migrations com os mesmos nomes, copiadas do DBML, e
  as outras passam a só ler.
- **CCD106:** `cards.status` (`add_status_and_release_year_to_cards_table`), para mostrar só cartas `ACTIVE` (R4).
- **CCD104:** `defaultCategoriesService.findDefaults` (já no `develop`), com a fixada primeiro e depois `display_order`.
- **CCD079:** cria o módulo `src/domains/marketplace/listings/` com `GET /listings/:id` e a página `/anuncios/:id` (destino
  do R13). A primeira das duas a ser implementada cria o módulo; a outra acrescenta a sua rota.
- **CCD068:** dona das regras de ordenação por preço. Esta story entrega o seletor e a ordem padrão "Mais recentes"; a
  CCD068 acrescenta "Menor preço" e "Maior preço" à lista de `sort` permitidos.
- **CCD001:** dona do menu do visitante. Se esta story vier antes, ela mesma acrescenta "Marketplace" ao menu (R2).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `card_conditions` | não | `create_card_conditions_table` (da CCD084) | seed com Mint, Near Mint, Ótimo, Bom e Regular, nessa `sort_order` (R8) |
| `listings` | não | `create_listings_table` (da CCD097), com o enum `listing_status` | só leitura (R4) |
| `listing_photos` | não | `create_listing_photos_table` | só leitura: a primeira foto por `sort_order` (R4, depende da L7) |
| `cards`, `albums`, `categories`, `users` | sim | — | `cards.status` vem da CCD106 |

Seed do marketplace (`database/seeds/marketplace.seed.ts` + `data/listings.json`): 20 anúncios ativos em categorias,
condições e preços variados, mais um pausado e um excluído (CA1, CA2, CA10). Nenhuma coluna nova: tudo está no DBML.

## Regras

- **Entra na lista** (R4): `listings.status = ACTIVE`, `deleted_at` nulo, carta `ACTIVE` e não excluída; também
  `available_quantity > 0` e vendedor com `status = ACTIVE` (depende da L8).
- **Categoria do anúncio** (R4, R7): a categoria raiz da carta ou, sem ela, a do álbum; filtrar por uma categoria padrão
  traz também as subcategorias (depende da L6).
- **Imagem** (R4): a primeira foto do anúncio por `sort_order`; sem foto, `cards.front_image_url` (depende da L7).
- **Faixa de preço** (R9): `minPrice` e `maxPrice` opcionais e inclusivos; vazios = "Qualquer valor" (depende da L3).
- **Busca** (depende da L1): `q` por trecho no nome da carta ou no título do álbum, sem diferenciar maiúsculas.
- **Ordem padrão** (R10): `-createdAt`, com `id` como desempate estável entre páginas.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, dinheiro como string decimal, erros
`{ error, message, details? }`.

### `GET /api/v1/listings` — R1, R4–R11

- **Acesso:** público (sem `authenticate`).
- **Entrada (query):** `q` (2 a 100 caracteres, depende da L1), `categoryId` (uuid), `conditionId` (uuid), `minPrice` e
  `maxPrice` (decimal ≥ 0), `sort` (`-createdAt`, padrão; a CCD068 acrescenta `price` e `-price`), `page` (padrão 1),
  `pageSize` (padrão 8, máximo 100).
- **Sucesso:** `200`

  ```json
  { "data": [{ "id": "uuid", "price": "380.00", "imageUrl": "https://…",
      "card": { "id": "uuid", "name": "Charizard" }, "category": { "id": "uuid", "name": "Pokémon" },
      "album": { "id": "uuid", "title": "Base Set" }, "condition": { "id": "uuid", "name": "Near Mint" },
      "seller": { "id": "uuid", "username": "tiago_trocas" } }],
    "meta": { "page": 1, "pageSize": 8, "total": 20, "totalPages": 3 } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `categoryId` ou `conditionId` não é uuid, preço negativo, `minPrice` maior que `maxPrice`, `sort` fora da lista, `q` fora do tamanho | R7–R11 |

### `GET /api/v1/categories/default` — R7

- **Acesso:** público.
- **Sucesso:** `200` `{ "data": [{ "id": "uuid", "name": "Pokémon", "slug": "pokemon" }] }`, com a fixada primeiro, depois
  `displayOrder` e `name` (depende da L4). Reaproveitado pela CCD001 e pela CCD024.

### `GET /api/v1/card-conditions` — R8

- **Acesso:** público.
- **Sucesso:** `200` `{ "data": [{ "id": "uuid", "name": "Mint" }] }`, por `sort_order`, só as não excluídas.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/marketplace/listings/` (pasta vazia hoje) e um módulo público do catálogo em
`src/domains/catalog/public/`, no modelo de `src/domains/users/` (ADR-004), registrados em `src/routes.ts`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migrations `create_card_conditions_table`, `create_listings_table`, `create_listing_photos_table` (se ainda não existirem) | modelos `CardCondition`, `Listing`, `ListingPhoto` e o enum `ListingStatus`, copiados do DBML | R4, R8 |
| `database/seeds/marketplace.seed.ts` · `data/card-conditions.json` · `data/listings.json` · `seeds/index.ts` | condições e anúncios de exemplo | R4, R5, R8 |
| `listings.validator.ts` | `listListingsQuery` (Zod): uuids, preços, `minPrice ≤ maxPrice`, `sort` permitido, `pageSize` padrão 8 | R7–R11 |
| `listings.repository.ts` | `findPublicPage(filters)`: filtros das Regras, `count` e página na mesma transação, foto, carta, álbum, categoria, condição e vendedor | R4–R9, R11 |
| `listings.sort.ts` | lista de `sort` permitidos → `orderBy` do Prisma (aqui só `-createdAt`; a CCD068 estende) | R10 |
| `listings.service.ts` + `listings.service.spec.ts` | monta o filtro de categoria com as subcategorias, escolhe a imagem e devolve `{ items, meta }` | R4, R6, R7, R11 |
| `listings.controller.ts` · `listings.routes.ts` · `listings.swagger.ts` · `listings.module.ts` | `GET /listings` público, documentado no `/docs` | R1 |
| `src/domains/catalog/catalog-category-counts.repository.ts` | expõe `findCategoryTreeIds(rootId)` (a CTE recursiva que já existe) para o filtro de categoria | R7 |
| `src/domains/catalog/public/catalog-public.{repository,service,controller,routes,swagger}.ts` + `catalog-public.module.ts` | `GET /categories/default` (pelo `defaultCategoriesService`) e `GET /card-conditions`, montados em `/api/v1` | R7, R8 |
| `src/routes.ts` | registra `listingsModule` e `catalogPublicModule` | R1 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/marketplace/listings/` (pasta vazia hoje), no modelo de `src/features/users/` (ADR-040), rotas no
`app/router.tsx`, dentro do `PublicLayout` (o `SiteShell` já troca o topo para o cliente logado).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/routes/paths.ts` | `marketplace: '/marketplace'` e `marketplacePathFor(filtros)` | R2 |
| `app/layouts/SiteShell/siteMenu.ts` | item "Marketplace" no menu do visitante (CCD001) e no do cliente, destacado na página | R1, R2 |
| `listings.types.ts` · `listings.api.ts` · `listings.queries.ts` · `listings.labels.ts` · `listings.format.ts` | contrato, `useInfiniteQuery` de 8 em 8 (ADR-041), preço em reais, rótulos das etiquetas ("R$ 100 – R$ 2.000") e textos do vazio | R4–R6, R12, R14 |
| `listings.search-params.ts` | lê e grava filtros e ordenação na URL (depende da L9) | R11, R12 |
| `src/features/catalog/public/catalog-public.{types,api,queries}.ts` + `index.ts` | `useDefaultCategories` e `useCardConditions`, exportados pelo `index.ts` | R7, R8 |
| `components/ListingCard/` | imagem, "<categoria> • <coleção>", nome, condição, "Preço", preço e @vendedor, frame `1112-3281`; link para `/anuncios/:id` (CCD079) | R4, R13 |
| `components/ListingFilters/` · `components/PriceRangeFilter/` | "Buscar por carta ou coleção" (depende da L1), "Categoria:", "Condição:", "Preço:" (depende da L3) e "Ordenar:", frame `1112-3281` | R7–R10 |
| `src/components/ActiveFilters/` (movido de `features/catalog/components/`) | etiquetas com "✕" e "Limpar filtros" (depende da L2), usado pelo catálogo do admin e pelo Explorar | R12, R14 |
| `components/ListingGrid/` | grade de 8 por linha de 4, "<n> anúncios" e "Carregar mais cartas", frame `1112-3281` | R5, R6 |
| `pages/ExploreMarketplacePage/` | cabeçalho "MARKETPLACE" / "Explorar marketplace", filtros, grade e o vazio "Nenhum anúncio encontrado" com "Limpar filtros", frames `1112-3281` e `1112-3674` | R3–R14 |
| `listings.routes.ts` · `index.ts` · `src/app/router.tsx` | rota pública `/marketplace` | R1 |

- **Rotas:** `/marketplace`, pública.
- **Estados:** carregando e erro com `LoadingState` e `ErrorState` (depende da L10); vazio com `EmptyState` nos textos do
  frame `1112-3674`.
- **Componentes reaproveitados de `src/components/`:** `Select`, `TextField`, `Button`, `EmptyState`, `LoadingState`,
  `ErrorState`, `Icon`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1, CA2 | 20 ativos: `meta.total` 20, 8 por página, terceira página com 4; tela com "20 anúncios" e "Carregar mais cartas" até 20 | `listings.service.spec.ts` · `tests/integration/listings-public.spec.ts` · `ExploreMarketplacePage.spec.tsx` |
| CA3 | `categoryId` de Pokémon traz também as subcategorias; etiqueta "Pokémon ✕" remove só o filtro | integração · `ExploreMarketplacePage.spec.tsx` · `ActiveFilters.spec.tsx` |
| CA4 | `conditionId` de Near Mint filtra; opções na ordem de `sort_order` | integração · `ListingFilters.spec.tsx` |
| CA5 | `minPrice=100&maxPrice=2000` traz só o de R$ 380; `minPrice > maxPrice` responde `400` | `listings.validator.spec.ts` · integração · `PriceRangeFilter.spec.tsx` |
| CA6 | sem `sort`, do mais novo ao mais antigo; seletor mostra "Mais recentes" | integração · `ListingFilters.spec.tsx` |
| CA7 | o cartão leva a `/anuncios/:id` | `ListingCard.spec.tsx` |
| CA8 | vazio com "Nenhum anúncio encontrado", "0 anúncios" e "Limpar filtros", que zera a URL | `ExploreMarketplacePage.spec.tsx` |
| CA9 | sem token responde `200`; logado, mesmo conteúdo com "Marketplace" destacado no menu do cliente | integração · `SiteShell.spec.tsx` |
| CA10 | pausado e excluído não aparecem | integração |
| CA11–CA13 | print em 1280 px igual aos frames `1112-3281` e `1112-3674`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- O cartão do anúncio e `GET /listings` são compartilhados pela Home (CCD001), pela busca global (CCD002) e pelo perfil
  público do vendedor (CCD067/CCD080): um endpoint só, com filtros, em vez de um por tela.
- As rotas públicas do catálogo (`/categories/default`, `/card-conditions` e, nas CCD002 e CCD024, `/albums` e `/cards`)
  ficam num módulo próprio `catalog/public/`, separado do módulo do admin em `/admin/catalog`, como a CCD103 fez com a
  votação.
- `ActiveFilters` sai de `features/catalog/components/` para `src/components/`, porque passa a ser usado por duas features
  (ADR-040: componente compartilhado mora em `src/components/`).
- O filtro de categoria reaproveita a CTE recursiva da `catalog-category-counts.repository.ts` (CCD104) para incluir as
  subcategorias, em vez de uma segunda implementação.
