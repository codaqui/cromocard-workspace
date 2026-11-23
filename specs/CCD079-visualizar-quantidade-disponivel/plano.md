# Plano — CCD079 Visualizar Quantidade Disponível

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L5 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

A página pública "Detalhe do anúncio" (`/anuncios/:id`) chama `GET /api/v1/listings/:id`, que devolve o anúncio com a
quantidade disponível, a condição, o preço e um campo calculado `availability` (`AVAILABLE` ou `UNAVAILABLE`). Com
`UNAVAILABLE`, a tela troca "Comprar" por "Indisponível", mostra o aviso e a lista "Outros anúncios desta carta", que vem
de `GET /api/v1/cards/:cardId/listings`. O cliente logado vê a mesma página, dentro do `CustomerLayout`.

## Dependências

- **CCD084 (Criar Anúncio)** ou **CCD097**: criam a tabela `listings` (`create_listings_table`); esta story não cria a
  tabela, só a lê. O seed do marketplace (CCD097) traz anúncios com quantidade 0, pausados e ativos.
- **CCD084**: cria `card_conditions` (`create_card_conditions_table`) e o seed das condições (Mint, Near Mint, Ótimo, Bom,
  Regular).
- **CCD030 (Visualizar Detalhes)**: dona do perfil da carta. Se ela criar antes o `GET /api/v1/cards/:cardId/listings`,
  esta story reaproveita o endpoint e só acrescenta o filtro `excludeListingId`.
- **CCD072, CCD074, CCD080 e CCD056** acrescentam blocos à mesma página (comprar, fotos, vendedor, favoritar). Esta story
  cria a página e o endpoint de detalhe; quem vier depois estende (ver Decisões técnicas).
- Domínio `src/domains/marketplace/listings/` e feature `src/features/marketplace/listings/`: as pastas existem, vazias.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `listings` | não | `create_listings_table` (da CCD084/CCD097) | só leitura: `available_quantity`, `status`, `price`, `condition_id`, `card_id`, `seller_id`, `deleted_at` (R2–R4) |
| `card_conditions` | não | `create_card_conditions_table` (da CCD084) | só leitura: `name` (R3) |
| `orders` | não | — | só se a L2 confirmar: pedidos `AWAITING_PAYMENT` com reserva vigente descontam da quantidade (depende da L2) |

Nenhuma coluna nova: tudo o que a spec pede está no DBML.

## Regras

- **Indisponível** (R4): `available_quantity = 0` ou `status = PAUSED`; `CLOSED` também fica indisponível (depende da L1).
- **Excluído** (`deleted_at` preenchido) ou inexistente: `404 LISTING_NOT_FOUND` (depende da L1).
- **Quantidade exibida** (R2): `available_quantity` menos as reservas vigentes do checkout (depende da L2; sem a CCD072
  implementada, é só `available_quantity`).
- **Outros anúncios** (R6): `ACTIVE`, quantidade maior que zero, mesma carta, sem o anúncio atual, por menor preço; sem
  nenhum, a seção some (depende da L3). No anúncio disponível, a seção também aparece (depende da L4).
- **Dono do anúncio**: recebe `isOwner: true` e não vê "Comprar" (depende da L5).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, dinheiro como string decimal, erros
`{ error, message, details? }`.

### `GET /api/v1/listings/:id` — R1–R4

- **Acesso:** público (o token, se vier, só preenche `isOwner`).
- **Entrada:** `id` (uuid) no caminho.
- **Sucesso:** `200`

  ```json
  { "data": { "id": "uuid", "cardId": "uuid", "price": "1750.00", "availableQuantity": 1,
    "status": "ACTIVE", "availability": "AVAILABLE", "condition": { "id": "uuid", "name": "Bom" },
    "isOwner": false } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `id` não é uuid | R1 |
  | 404 | `LISTING_NOT_FOUND` | anúncio inexistente ou excluído (depende da L1) | R2 |

### `GET /api/v1/cards/:cardId/listings` — R6

- **Acesso:** público.
- **Entrada:** `excludeListingId` (uuid, opcional), `sort=price` (padrão), `page`, `pageSize` (padrão 10).
- **Sucesso:** `200` `{ data: ListingSummary[], meta: { page, pageSize, total } }`, com
  `ListingSummary = { id, price, condition: { name }, seller: { id, username } }` (a cidade do vendedor entra pela CCD080).
  A CCD030 propõe acrescentar `availableQuantity` e tornar `condition` anulável (L12, L13 da CCD030): se o PO aceitar, o
  contrato muda nos dois planos.
- **Erros:** `400 VALIDATION_ERROR` (parâmetro inválido), `404 CARD_NOT_FOUND` (carta inexistente) — R6.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/marketplace/listings/`, no modelo de `src/domains/users/` (ADR-004), registrado em `src/routes.ts`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `listings.validator.ts` | `listingIdParams`, `cardListingsQuery` (Zod) | R1, R6 |
| `listings.errors.ts` | `ListingNotFoundError` (`404 LISTING_NOT_FOUND`) | R2 |
| `listings.repository.ts` | `findPublicById` (com a condição, filtra `deletedAt: null`), `findActiveByCard` (filtros e ordem das Regras) | R2, R6 |
| `listings.availability.ts` | função pura que calcula `availability` a partir de quantidade e status | R4 |
| `listings.service.ts` + `listings.service.spec.ts` | detalhe, disponibilidade, `isOwner`, outros anúncios | R2–R6 |
| `listings.controller.ts` · `listings.routes.ts` · `listings.swagger.ts` · `listings.module.ts` | rotas públicas com `optionalAuthenticate` (ou leitura do token sem exigir), documentadas no `/docs` | R1 |
| `src/routes.ts` | registra o `listingsModule` | R1 |
| `src/domains/catalog/catalog.routes.ts` (ou o módulo de listings montado em `/cards/:cardId/listings`) | rota dos outros anúncios da carta | R6 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/marketplace/listings/`, no modelo de `src/features/users/` (ADR-040), rotas registradas no
`app/router.tsx`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `listings.types.ts` · `listings.api.ts` · `listings.queries.ts` · `listings.labels.ts` | tipos do contrato, chamadas e queries (TanStack Query, ADR-041); textos "Disponível", "Indisponível" e o aviso | R2–R6 |
| `components/ListingPurchasePanel/` | bloco "Preço · Condição · Disponível", botão "Comprar" ou "Indisponível" (desabilitado) e o aviso, frames `1112-5772` e `1112-6152` | R3–R5, R8 |
| `components/OtherListingsTable/` | "Outros anúncios desta carta (<n>)", "Compare com os outros vendedores", tabela Vendedor · Condição · Preço · "Ver anúncio", frame `1112-6152` (e `1112-5772`, depende da L4) | R6, R8 |
| `pages/ListingDetailPage/` | página do detalhe, com breadcrumb e os blocos; estados com `LoadingState` e `ErrorState`; `NotFoundPage` no `404` | R1, R7, R8 |
| `listings.routes.ts` · `index.ts` | rota pública `/anuncios/:id` | R1 |
| `src/routes/paths.ts` | `listingDetail: '/anuncios/:id'` e `listingDetailPathFor(id)` | R1 |
| `src/app/router.tsx` | registra a rota no `PublicLayout` (o layout já troca o topo e o menu para o cliente logado) | R1 |

- **Rotas:** `/anuncios/:id`, pública.
- **Estados:** carregando, erro e não encontrado com `LoadingState`, `ErrorState` e `NotFoundPage` (R7).
- **Componentes reaproveitados de `src/components/`:** `Button`, `Badge`, `DataTable`, `Select` (ordenação, depende da L4),
  `LoadingState`, `ErrorState`, `NotFoundPage`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | anúncio ativo com 3 unidades: `200`, `availableQuantity: 3`, `availability: AVAILABLE`; tela com "Disponível" 3 e "Comprar" habilitado | `listings.service.spec.ts` · `tests/integration/listings.spec.ts` · `ListingDetailPage.spec.tsx` |
| CA2 | cliente logado vê a mesma página com o menu do cliente | `ListingDetailPage.spec.tsx` |
| CA3 | quantidade 0: "Indisponível" desabilitado, aviso e outros anúncios | `listings.availability.spec.ts` · `ListingPurchasePanel.spec.tsx` · `OtherListingsTable.spec.tsx` |
| CA4 | `PAUSED` com estoque: mesmo estado do CA3 | `listings.availability.spec.ts` · integração |
| CA5 | carregando e erro sem quebrar o layout | `ListingDetailPage.spec.tsx` |
| CA6, CA7 | print em 1280 px igual aos frames `1112-5772` e `1112-6152`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- A disponibilidade é calculada no backend (`availability`), para a regra ficar num lugar só e a CCD072 reaproveitá-la
  ao conferir de novo antes do pagamento.
- O detalhe do anúncio é um endpoint público com autenticação opcional, para o `isOwner` sem obrigar login; se o
  middleware `optionalAuthenticate` não existir em `src/shared/middlewares/`, esta story o cria (sem regra de negócio).
- Esta story cria a página e o endpoint de detalhe; as outras stories da mesma tela (CCD072, CCD074, CCD080, CCD056)
  acrescentam campos à resposta e blocos à página, sem endpoints paralelos.
