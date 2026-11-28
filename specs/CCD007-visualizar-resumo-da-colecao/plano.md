# Plano — CCD007 Visualizar Resumo da Coleção

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026), e revisado por Lucca Rocha em 23/11/2026 com as
> decisões do PO (L1–L11). Spec aprovada pelo PO em 23/11/2026. Atualizado em 26/11/2026 por Lucca Rocha com o que o
> backend entregou (codaqui/cromocard-backend#48) e com as correções da revisão de código.

- **Spec:** [spec.md](spec.md), aprovada pelo PO em 23/11/2026 (lacunas L1–L11 decididas; L12 em 27/11/2026)
- **Repositórios:** backend · frontend (relidos em 23/11/2026 no `develop` dos dois apps)
- **Data:** 2026-11-22 (revisado em 2026-11-23 e em 2026-11-26) · **Autor:** Daniel Andrade · **Revisão:** Lucca Rocha

## Solução

Esta story cria o domínio `collection` do backend e a feature `collection` do frontend, de que as CCD008 a CCD018
dependem. O Início do cliente (`/inicio`) chama `GET /api/v1/collections/me/summary` (indicadores, valor estimado, álbum
em destaque e saudação) e `GET /api/v1/collections/me/cards` (a grade dos principais itens). A coleção do cliente nasce
na primeira leitura ou escrita da API (L2): sem coleção, o resumo vem zerado.

**Ordem de entrega** (orientação do PO, 23/11/2026): primeiro o domínio `collection` e os contadores, que não dependem
do marketplace, e por último os preços. Como `price_history` e `listings` já estavam no `develop` (backend #41 e #44),
o valor estimado (R7) e o "Menor anúncio" (R8) entraram ligados no mesmo PR do backend (#48), sem implementação nula.

## Dependências

- **CCD004 (Realizar Login)**: `authenticate`, `authorize` e o `RequireAuth` do frontend (já no código).
- **CCD061 (Gestão de Catálogo)**: `albums`, `cards` e `categories` já existem no `schema.prisma`.
- **CCD097 (Indicadores Financeiros)**: o codaqui/cromocard-backend#41, mergeado em 24/11/2026, criou `listings`, `orders`,
  `payments` e `price_history`, e o #44 completou as tabelas do marketplace. A T2 desta story fica sem migration.
- **CCD084 / CCD097**: criam `listings` (`create_listings_table`). O "Menor anúncio" da carta faltante (L6) lê essa
  tabela por uma interface (ver Decisões técnicas); sem anúncio, "—".
- **CCD061 / CCD105 (trava da exclusão de carta)**: o catálogo recebe a `CardUsage` (`cardIdsInCollections(ids)`) e,
  até `collection_cards` existir, injetava `noCollectionsYet` (CCD105, L14). Como esta story cria a tabela, ela liga a
  consulta real (ver Decisões técnicas). Isso antecipa a T5 da CCD014 (AB#1033).
- **CCD030 (Visualizar Detalhes)** e **CCD084 (Criar Anúncio)**: destinos de "Ver carta" e "Anunciar repetida". Até
  entrarem, os links levam a rotas de `underConstructionRoute` (L10).
- **CCD022 (Adicionar Carta)** e a página pública do álbum (EA-002-01) são quem põe álbuns na coleção; até lá, o seed
  desta story cria a coleção de exemplo. "Adicionar Primeiro Álbum" leva à CCD022 (L8).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `collections` | não | `create_collections_table` | copiada do DBML: `user_id` único, `is_public` default `false`, `share_link` único (R1, R3) |
| `user_albums` | não | `create_user_albums_table` | copiada do DBML: único (`collection_id`, `album_id`), `is_favorite`, `progress_percentage decimal(5,2)` (R3, R5) |
| `collection_cards` | não | `create_collection_cards_table` | copiada do DBML, com o enum `collection_card_status` (`OWNED`, `MISSING`, `DUPLICATE`) e `market_value`; único (`collection_id`, `card_id`) (R4) |
| `price_history` | sim (backend #41) | — | só leitura (R7) |
| `albums`, `cards`, `categories`, `users` | sim | — | só leitura |

Nenhuma coluna fora do DBML. O seed `database/seeds/collection.seed.ts` cria, para o cliente de exemplo, a coleção com os
4 álbuns e as cartas do frame `1122-17812` (CA1, CA8), o histórico de preços dos últimos 60 dias (CA3 e o valor do CA8)
e os anúncios ativos do "Menor anúncio".

## Regras

- **Coleção** (L2): `findOrCreateByUserId` lê `collections` por `user_id` e só cria (`is_public = false`) quando a
  linha não existe; a leitura não grava nada. Duas leituras ao mesmo tempo: quem perde a corrida no índice único lê a
  coleção criada pela outra. A coleção excluída não volta ao ser lida (o ADR-015 restaura ao re-adicionar): responde
  `404 COLLECTION_NOT_FOUND`. Revisão do codaqui/cromocard-backend#48, 27/11/2026.
- **Álbuns ativos** (R3): `user_albums` sem `deleted_at`, de `albums` sem `deleted_at`.
- **Cartas** (R4, L3): total = soma de `albums.total_cards` dos álbuns ativos; possuo = cartas desses álbuns
  com status `OWNED` ou `DUPLICATE`; faltantes = total − possuo; repetidas = soma de `quantity − 1` das `DUPLICATE` (`extraCopies`).
- **Percentual médio** (R5, L4): média de `progress_percentage` dos álbuns ativos, com 2 casas; sem álbum, 0.
- **Valor estimado** (R7, L5): uma vez por carta possuída (`OWNED` ou `DUPLICATE`); preço médio = média de
  `price_history.price` com `reference_date` nos últimos 30 dias; sem preço, zero. Variação = valor de hoje contra o
  valor com os preços de 30 a 60 dias atrás; sem valor anterior, `null`. Sem preço nenhum, `"0.00"` e `null`.
- **Álbum em destaque** (R12, L7): o favorito (`is_favorite`); sem favorito, o álbum da `collection_cards` com o
  `updated_at` mais recente; sem marcação, o álbum adicionado por último; sem álbum, `null`.
- **Principais itens** (R8, L6): cartas dos álbuns ativos; carta sem linha em `collection_cards` conta como
  faltante; ordem "maior valor" (preço médio, e para faltante o menor anúncio, sem preço no fim, desempate pelo nome);
  8 por página. As abas contam as cartas que a grade lista (L13, L14): "Repetidas" conta cartas `DUPLICATE`
  (`duplicateCards`), diferente do card do resumo, que soma as cópias extras.
- **Carta usada em coleções** (CCD061 FA 5, CCD105 R10): a carta tem marcação em `collection_cards` sem `deleted_at`,
  de qualquer status, numa coleção sem `deleted_at`.
- **Saudação** (R13, L9): primeiro nome de `users.name` e mês e ano de `users.created_at`.
- **Papel** (R1, L1): `CUSTOMER` e `SELLER`; `ADMIN` recebe `403`.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, dinheiro como string decimal, erros
`{ error, message, details? }`. Todas as rotas `/collections/me/*` usam `authenticate` + `authorize('CUSTOMER', 'SELLER')`.

### `GET /api/v1/collections/me/summary` — R1, R3–R7, R9, R12, R13

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (L1)
- **Sucesso:** `200`

  ```json
  { "data": {
      "collector": { "firstName": "Daniel", "memberSince": "2026-10-01" },
      "activeAlbums": 4,
      "averageProgress": 69.7,
      "cards": { "total": 264, "owned": 184, "missing": 80, "extraCopies": 28 },
      "estimatedValue": { "amount": "1234.50", "variationPercent": 14.2 },
      "featuredAlbum": { "albumId": "uuid", "title": "Copa do Mundo 2026", "coverUrl": "https://…",
        "ownedCards": 43, "totalCards": 54, "progressPercentage": 79.63 } } }
  ```

  Sem álbum nem carta: contadores em 0, `estimatedValue.amount = "0.00"`, `variationPercent: null` e
  `featuredAlbum: null` (R9).

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 401 | `UNAUTHORIZED` | sem token ou token inválido | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (L1) | R1 |

### `GET /api/v1/collections/me/cards` — R1, R8

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada (query):** `status` (`OWNED` · `MISSING` · `DUPLICATE`, opcional = todas), `q` (trecho do nome, opcional),
  `categoryId` (uuid, opcional), `page` (padrão 1), `pageSize` (padrão 8, máximo 48); a ordem é sempre o maior valor
  (L6)
- **Sucesso:** `200`

  ```json
  { "data": [ { "cardId": "uuid", "name": "Pikachu VMAX", "frontImageUrl": "https://…",
      "album": { "id": "uuid", "title": "Destinos Brilhantes" }, "category": { "id": "uuid", "name": "Pokémon" },
      "status": "DUPLICATE", "quantity": 2, "averagePrice": "180.00", "lowestListingPrice": null } ],
    "meta": { "page": 1, "pageSize": 8, "total": 264, "totalPages": 33,
      "counts": { "all": 264, "owned": 184, "missing": 80, "duplicateCards": 28 },
      "categories": [ { "id": "uuid", "name": "Pokémon" } ] } }
  ```

  `lowestListingPrice` só vem na carta `MISSING` (L6); `averagePrice` vem em todas, `null` sem preço nos últimos 30 dias;
  a carta `MISSING` vem com `quantity: 0`; `categories` são as dos álbuns ativos, para os filtros. `counts` são as
  cartas que cada aba lista (L13, L14): com o catálogo completo, `all` bate com o `cards.total` do resumo, mas
  `duplicateCards` conta cartas e não as cópias extras (no seed os dois dão 28, porque cada repetida tem 2 cópias;
  uma carta com 3 cópias soma 1 em `duplicateCards` e 2 em `extraCopies`).

- **Erros:** `400 VALIDATION_ERROR` (query inválida), `401`, `403` (R1) e `404 COLLECTION_NOT_FOUND` (coleção
  excluída, L2).

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/`, no modelo de `src/domains/users/` (ADR-004), registrado em `src/routes.ts` com
`basePath: '/collections'`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + 3 migrations | modelos `Collection`, `UserAlbum` e `CollectionCard` e o enum `CollectionCardStatus`, com as relações em `User`, `Album` e `Card` | R3, R4, R7 |
| `database/seeds/collection.seed.ts` · `data/collection.json` | coleção de exemplo com os dados do frame, o histórico de preços e os anúncios ativos (T3) | CA1, CA3, CA8 |
| `collection.repository.ts` | `findOrCreateByUserId` (lê e só cria quando não existe; a excluída responde `404`), álbuns ativos, marcações por álbum e cartas possuídas | R1, R3–R5, R7, R9 |
| `collection-prices.ts` | interface `CollectionPrices` (`averagePrices(cardIds, range)`), em centavos | R7 (L5) |
| `collection-prices.repository.ts` | implementação Prisma de `CollectionPrices`: preço médio por carta numa janela de datas (`$queryRaw` com `AVG` agrupado por `card_id`) (T2) | R7 |
| `collection-cards.repository.ts` | página da grade ordenada pelo maior valor no banco, com filtros, preço médio e menor anúncio `ACTIVE` da faltante (`findPage`), contagem por aba (L13, L14), categorias e as cartas marcadas em coleções (`findCardIdsInCollections`) | R8 (L6) |
| `collection.service.ts` + `.spec.ts` | resumo, valor estimado e variação, álbum em destaque, saudação, lista paginada e `cardIdsInCollections` para o catálogo; a query da lista é tipada pelo `z.infer` do validator (ADR-006) | R3–R9 |
| `collection.validator.ts` | query da lista; não há `collection.errors.ts`, porque o domínio não tem erro próprio (os `400`, `401` e `403` são os compartilhados) | R8 |
| `collection.controller.ts` · `collection.routes.ts` · `collection.swagger.ts` · `collection.module.ts` | as 2 rotas, com `authenticate` + `authorize('CUSTOMER', 'SELLER')` | R1 |
| `src/routes.ts` | registra `collectionModule` | R1 |
| `catalog.module.ts` · `catalog.ports.ts` (CCD061) | o catálogo passa a receber o `collectionService` como `CardUsage`; sai o `noCollectionsYet` | CCD061 FA 5 |
| `tests/integration/catalog-card-usage.spec.ts` | a carta marcada numa coleção não é excluída (`422 CARD_IN_USE`) e a exclusão em lote a pula | CCD105 CA9 |
| `tests/integration/collection-summary.spec.ts` | rotas de ponta a ponta | CA1–CA6 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`, no modelo de `src/features/users/` (ADR-040), rotas em `collection.routes.ts`, já
registradas no `CustomerLayout` do `app/router.tsx`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection.types.ts` · `collection.api.ts` · `collection.queries.ts` · `collection.labels.ts` · `collection.format.ts` | tipos do contrato, chamadas, queries do TanStack Query, rótulos dos status ("Possuo", "Repetida (x2)", "Faltante") e formato de dinheiro e percentual | R3–R8 |
| `components/CollectionSummaryCards/` | "Valor estimado", "Total de cartas", "Possuo", "Faltantes" e "Repetidas", com o `KpiCard`; frame `1122-17812` | R4, R6, R7 |
| `components/FeaturedAlbum/` | "Álbum em destaque: <álbum>", barra, "<n> de <total> cartas • <n>% completo", "Abrir álbum" (L7); frame `1122-17812` | R12 |
| `components/CollectionCardsGrid/` · `components/CollectionCardTile/` | abas com contagem (`Tabs`), "Buscar carta na coleção" (`SearchBar`), "Ordenar: Maior valor", filtros por categoria, cartões com selo, "Preço médio" / "Menor anúncio" e os botões "Ver carta", "Anunciar repetida" (só `SELLER`) e "Comprar no marketplace" como links; "Ver carta", "Anunciar repetida" e "Comprar no marketplace" levam a rotas de `underConstructionRoute` até a CCD030, a CCD084 e o marketplace (CCD078, CCD072) entrarem (L6, L10); paginação com `Pagination`; frame `1122-17812` | R8, R14 |
| `pages/CollectionHomePage/` | saudação (L9), subtítulo "Colecionador desde … • <n> álbuns ativos" com o percentual médio de completude ao lado (L4), os blocos acima, o vazio com "Adicionar Primeiro Álbum" levando à CCD022 (L8), `LoadingState` e `ErrorState`; frame `1122-17812` | R2, R3, R5, R9–R11, R13 |
| `src/routes/paths.ts` | `dashboard: '/inicio'`; `homePathByRole` de `CUSTOMER` e `SELLER` passa a `/inicio` | R2 |
| `app/layouts/SiteShell/siteMenu.ts` | item "Início" aponta para `paths.dashboard` | R2 |
| `collection.routes.ts` | rota `/inicio` (lazy) | R2 |

- **Rotas:** `/inicio` em `routes/paths.ts`, dentro do `RequireAuth` + `CustomerLayout`.
- **Estados:** carregando, erro e vazio com `LoadingState`, `ErrorState` e o estado vazio do Início (R9, que o Figma não
  desenha: no estilo do `1160-29088`, L8).
- **Componentes reaproveitados de `src/components/`:** `KpiCard`, `Tabs`, `SearchBar`, `Select`, `Badge`, `Button`,
  `Pagination`, `EmptyState`, `LoadingState`, `ErrorState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 4 álbuns, cartas, média do progresso | `collection.service.spec.ts` · `tests/integration/collection-summary.spec.ts` · `CollectionHomePage.spec.tsx` |
| CA2 | álbum com `deleted_at` fora da contagem | `collection.service.spec.ts` · integração |
| CA3 | soma dos preços médios e variação em 30 dias | `collection.service.spec.ts` · integração |
| CA4 | lista com nome e status, carta sem marcação como faltante, abas e busca | `collection.service.spec.ts` · integração · `CollectionCardsGrid.spec.tsx` |
| CA5 | coleção nova zerada e botão "Adicionar Primeiro Álbum" | `collection.service.spec.ts` · `CollectionHomePage.spec.tsx` |
| CA6 | `401` sem token, `403` para `ADMIN`, isolamento entre dois clientes | integração |
| CA7 | carregando e erro com a mensagem da API | `CollectionHomePage.spec.tsx` |
| CA8 | print em 1280 px igual ao `1122-17812`; 375, 768 e 1024 px sem quebra | revisão visual (`/cromocard-revisor`) com o seed |
| CA9 | sem favorito, o destaque é o último álbum com carta marcada | `collection.service.spec.ts` |

Meta de 90% de cobertura nos arquivos alterados (ADR-060).

## Decisões técnicas

- O domínio `collection` concentra coleção, álbuns da coleção e marcações: as CCD008 a CCD018 só acrescentam rotas e
  métodos a ele, sem módulo novo.
- O catálogo não lê tabela de outro domínio (ADR-001); do mesmo jeito, o service da coleção não lê `price_history`
  direto: recebe a interface `CollectionPrices` (L5) pelo construtor, e o `collection.module.ts` injeta a implementação
  Prisma (T2). A exceção é a grade, que lê `listings` no repository (ver abaixo). Os preços circulam em centavos e viram string com 2 casas
  só na resposta, numa função só do service.
- A trava "carta já usada em coleções" do catálogo (CCD061 FA 5) passa a valer nesta story, porque é ela que cria
  `collection_cards`: sem isso, o admin conseguiria excluir uma carta marcada na coleção de um cliente. Pela regra do
  backend (o domínio só usa a service exportada pelo `.module.ts` do outro), o `catalog.module.ts` recebe o
  `collectionService`, que implementa a `CardUsage`, em vez da `PrismaCardUsage` que o plano da CCD014 previa.
  Revisão de código de 26/11/2026; a T5 da CCD014 (AB#1033) fica coberta.
- O preço médio é calculado no banco (`$queryRaw` com `AVG`), para não carregar o histórico inteiro na memória.
- A grade ordena e pagina no banco, numa query só (`LEFT JOIN LATERAL` em `price_history` e `listings`,
  `ORDER BY valor DESC NULLS LAST, nome, id` com `LIMIT/OFFSET`), para o custo de cada página seguir o `pageSize` e não
  o número de cartas dos álbuns do cliente. Revisão do codaqui/cromocard-backend#48, 27/11/2026, decidido pelo PO; isso
  substitui a ordem no service da T6 (25/11/2026), que buscava todas as cartas da aba a cada página.
- Por isso, o `PrismaCollectionCardsRepository` lê `listings` (do marketplace) no SQL da grade, e a interface
  `ListingPrices` saiu. Quando o marketplace ganhar uma service de anúncios, a regra "anúncio ativo" vai para lá e é
  injetada no `collection.module.ts`, como o catálogo fez com a `CardUsage`. O valor estimado do resumo continua
  pela interface `CollectionPrices`.
- A coleção nascer na primeira leitura (L2) é uma regra de negócio decidida pelo PO em 23/11/2026; o caso de uso 07 só
  descreve o resumo, e a regra fica registrada na spec.
