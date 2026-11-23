# Plano — CCD030 Visualizar Detalhes

> Revisado em 23/11/2026 com as lacunas L1–L14 decididas e a spec aprovada.

- **Spec:** [spec.md](spec.md), Aprovada (L1–L14 decididas)
- **Repositórios:** backend · frontend (relidos em 2026-11-23 no `develop` dos dois apps, que já tem `cards.code` e `cards.variants` da CCD105; o perfil não os mostra, a CCD031 decide)
- **Data:** 2026-11-22 (revisado em 2026-11-23) · **Autor:** Daniel Andrade

## Solução

O perfil da carta é a página pública `/cartas/:id`, aberta pela busca, pelo marketplace e pela Home. Ela lê
`GET /api/v1/cards/:id` (imagens, identificação da CCD031, preço médio, menor anúncio e contagem de anúncios ativos) e
`GET /api/v1/cards/:id/listings` (anúncios ativos por menor preço). O histórico de preços é o componente da CCD075. O
visitante vê o aviso de conta e, em "Adicionar à coleção" ou "Favoritar", o modal "Entre para continuar", que volta para a
carta depois do login. O cliente logado vê a mesma página, sem o aviso; o vendedor logado vê "Anunciar esta carta" quando
não há anúncios.

## Dependências

Decisão de 23/11/2026: esta spec cria o mínimo de que depende, só para leitura, igual ao DBML; as specs donas passam a
usar o que já existe.

- **CCD106** — esta spec cria o enum `card_status` e a coluna `cards.status` (padrão `ACTIVE`), para o `404` do rascunho (R13).
- **CCD084** — esta spec cria `listing_status`, `card_conditions` e `listings` (migration `create_listings_and_card_conditions`);
  a CCD084 fica com a escrita e a página de criar anúncio ("Anunciar esta carta", em construção até lá).
- **CCD075** — esta spec cria `price_source` e `price_history`; o gráfico e os períodos continuam da CCD075, e o perfil
  reserva o bloco "Histórico de preços" para ela (em construção até lá).
- **CCD031** — regras do bloco de identificação.
- **CCD079** — divide `GET /cards/:cardId/listings`; esta story cria o endpoint.
- **CCD002** — esta spec cria o `LoginRequiredDialog` na feature `auth`, com a mensagem por prop.
- **CCD004** — login e o retorno pela `loginRedirect`.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `cards` | sim, sem `status` | `status` da CCD106 | só `ACTIVE` não excluída abre (R13) |
| `card_photos` | sim | — | a imagem de detalhe (L1): a primeira por `sort_order` |
| `listings` · `card_conditions` | não | da CCD084 | só leitura (R7, R8) |
| `price_history` | não | da CCD075 / CCD007 | só leitura, preço médio (R4, depende da L2) |
| `users` | sim (`username`, `role`) | — | vendedor do anúncio; `SELLER` vê "Anunciar esta carta" |

## Regras

- **Anúncio ativo** (R8): `status = ACTIVE` e `deleted_at` nulo; vale para a lista, a contagem e o menor anúncio.
- **Ordem** (R7, L3): `price` asc, depois `created_at` asc; o select "Ordenar" só com "Menor preço".
- **Página da lista** (L8): o frontend pede `pageSize=20` e mostra "Carregar mais"; o padrão do
  endpoint é 10, o mesmo da CCD079.
- **Anúncio esgotado** (L12): `available_quantity = 0` fica fora da lista, da contagem e do menor anúncio.
- **Condição nula** (L13): `condition` vem `null` e a tela mostra "—".
- **Preço médio de mercado** (L2): média de `price_history.price` dos últimos 30 dias, só
  `source = SALE` (a mesma base da CCD075); sem vendas, `null` e a tela mostra "—".
- **Imagens** (R3, L1): frente, verso e as fotos de `card_photos` não excluídas.
- **Carta inválida** (R13): inexistente, excluída ou `DRAFT` → `404 CARD_NOT_FOUND`.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, dinheiro como string decimal, erros
`{ error, message, details? }`.

### `GET /api/v1/cards/:id` — R1, R3–R5, R13

- **Acesso:** público (o token, se vier, só serve à CCD022 e ao papel do vendedor).
- **Sucesso:** `200`

  ```json
  { "data": { "id": "uuid", "name": "Lionel Messi",
    "images": { "front": "https://…", "back": "https://…", "photos": ["https://…"] },
    "breadcrumb": { "category": { "id": "uuid", "name": "Futebol" } },
    "identification": { "number": "10", "album": { "id": "uuid", "title": "Copa do Mundo 2026" },
      "category": { "id": "uuid", "name": "Seleções" }, "rarity": { "name": "Lendária" }, "language": { "name": "Português - Brasil" } },
    "market": { "averagePrice": "1890.00", "lowestListingPrice": "1750.00", "activeListingsCount": 4 } } }
  ```

- **Erros:** `400 VALIDATION_ERROR` (id não é uuid), `404 CARD_NOT_FOUND` (R13).

### `GET /api/v1/cards/:cardId/listings` — R7, R8

- **Acesso:** público.
- **Entrada:** `page`, `pageSize` (padrão 10, máximo 50), `sort=price` (padrão) e `excludeListingId` (uuid, opcional,
  usado pela CCD079). O contrato é o mesmo da CCD079.
- **Sucesso:** `200` `{ data: ListingSummary[], meta: { page, pageSize, total } }`, com
  `ListingSummary = { id, price, condition: { name } | null, seller: { id, username } }`; só anúncios com estoque
  (L12) e `condition` anulável (L13).
- **Contagem na tela** (L12): o título "Anúncios disponíveis (<n>)" usa `market.activeListingsCount` do perfil, o mesmo
  número do card "Anúncios ativos"; o `meta.total` da lista serve só à paginação.
- **Erros:** `400 VALIDATION_ERROR`, `404 CARD_NOT_FOUND` — R7, R13.

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/catalog/cards/cards.validator.ts` | `cardIdParams`; o `404 CARD_NOT_FOUND` reaproveita o `CardNotFoundError` que já existe em `src/domains/catalog/catalog.errors.ts` | R13 |
| `src/domains/catalog/cards/cards.repository.ts` | `findPublicById` com álbum, categoria, raridade, idioma e fotos; só `ACTIVE` não excluída | R3, R5, R13 |
| `src/domains/catalog/cards/cards.service.ts` + `.spec.ts` | monta o perfil; preço médio e resumo dos anúncios pelas services exportadas do marketplace e do histórico | R3–R5, R13 |
| `src/domains/catalog/cards/cards.controller.ts` · `.routes.ts` · `.swagger.ts` · `cards.module.ts` | `GET /cards/:id`, público | R1 |
| `src/domains/marketplace/listings/listings.repository.ts` · `listings.service.ts` + `.spec.ts` | `findActiveByCard` (ordem e página) e `summaryByCard` (contagem e menor preço) | R7, R8 |
| `src/domains/marketplace/listings/listings.module.ts` | exporta a `ListingsService`; a rota `GET /cards/:cardId/listings` fica no `cards.routes.ts`, que confere a carta (404) antes de listar, sem dependência circular entre os módulos | R7, R13 |
| `src/routes.ts` | registra `cardsModule` e `listingsModule` | R1 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/catalog/` (perfil público) e `src/features/marketplace/listings/` (lista de anúncios).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `catalog/card-profile.types.ts` · `.api.ts` · `.queries.ts` · `.labels.ts` | contrato, `useCardProfile(id)`, textos do aviso, da lista vazia e do modal | R3–R5, R10–R12 |
| `catalog/components/CardGallery/` | imagem principal, frente, verso e detalhe — frame `1112-4615` (L1) | R3, R14 |
| `catalog/components/CardMarketStats/` | "Preço médio de mercado", "Menor anúncio", "Anúncios ativos" — frame `1112-4615` | R4, R14 |
| `catalog/components/CardIdentification/` | bloco de identificação (regras da CCD031) — frame `1112-4615` | R5, R14 |
| `marketplace/listings/components/CardListingsList/` | "Anúncios disponíveis (<n>)", vendedor, condição, preço, "Ver anúncio" (`/anuncios/:id`, CCD079), "Carregar mais"; vazia com a mensagem e "Anunciar esta carta" só para `SELLER` — frame `1112-4615` | R7–R9, R12, R14 |
| `auth/components/LoginRequiredDialog/` (da CCD002; sai pelo `index.ts` da feature `auth`; recebe a mensagem por prop e mostra o rodapé dos termos, o que a CCD002 registra no plano dela) | "Entre para continuar", a mensagem "Faça login para continuar. É rápido e grátis.", "Continuar com Google", "Entrar com e-mail e senha", "Criar conta grátis" e o rodapé dos termos; leva ao login com o retorno para a carta — frame `1112-5461` | R11, R14 |
| `catalog/pages/CardProfilePage/` | a página, com o aviso "Ainda não tem conta?…" só para o visitante, "Adicionar à coleção" e "Favoritar" abrindo o modal para o visitante, e o histórico da CCD075 — frames `1112-4615` e `1112-5038` | R1–R6, R10, R11, R14 |
| `catalog.routes.ts` · `src/routes/paths.ts` · `app/router.tsx` | `cardProfile: '/cartas/:id'` e `cardProfilePathFor(id)`, no `PublicLayout` (que já troca o topo para o logado, L7) | R1, R2 |
| cartões da busca (CCD002), do marketplace e da Home (CCD001) | o clique leva a `cardProfilePathFor(id)` | R2 |

- **Estados:** carregando e erro com `LoadingState` e `ErrorState`; `404` com `NotFoundPage`, no estilo do vazio da busca (L9).
- **Componentes reaproveitados de `src/components/`:** `Modal`, `Button`, `Badge`, `Select`, `DataTable`, `LoadingState`,
  `ErrorState`, `NotFoundPage`, `EmptyState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 4 anúncios: imagens, preço médio, menor anúncio, "4", identificação, histórico e "Anúncios disponíveis (4)" | `cards.service.spec.ts` · `tests/integration/cards-profile.spec.ts` · `CardProfilePage.spec.tsx` |
| CA2 | ordem R$ 1.750, 1.980, 2.390; pausado fora; menor = 1.750 | `listings.service.spec.ts` · integração |
| CA3 | "Ver anúncio" leva a `/anuncios/:id` | `CardListingsList.spec.tsx` |
| CA4, CA5 | visitante: "Favoritar" e "Adicionar à coleção" abrem o modal; login volta para a carta | `CardProfilePage.spec.tsx` · `LoginRequiredDialog.spec.tsx` |
| CA6 | logado não vê o aviso | `CardProfilePage.spec.tsx` |
| CA7 | sem anúncios: mensagem; "Anunciar esta carta" só para `SELLER` | `CardListingsList.spec.tsx` |
| CA8 | rascunho: `404` | integração |
| CA9–CA11 | print em 1280 px igual aos frames `1112-4615`, `1112-5038` e `1112-5461`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- O perfil é uma rota pública do catálogo (`/cards/:id`) e a lista de anúncios fica no marketplace
  (`/cards/:cardId/listings`), cada domínio com o seu dado; o resumo de anúncios entra no perfil pela service exportada do
  `listings.module.ts`, sem o catálogo ler o repository do marketplace.
- Selos, subtítulo e caminho (R17) saem da identificação; "Ver anúncios (<n>)" (R15) e a nota (R16) são do frontend; a
  cidade do vendedor fica com a CCD080 (L5).
- O `GET /cards/:cardId/listings` é um contrato só para a CCD030 e a CCD079; mudar um parâmetro é mudar os dois planos.
