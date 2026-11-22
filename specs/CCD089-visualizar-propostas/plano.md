# Plano — CCD089 Visualizar Propostas

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.
>
> **Fase Futuro Marketplace: implementar depois do MVP** (depende da L1).

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L9 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O vendedor abre "Propostas Recebidas" (`/vendedor/propostas`) pelo menu do vendedor ou por uma notificação. A tela chama
`GET /api/v1/seller/offers`, que devolve só as propostas ativas feitas nos anúncios dele, com valor, data e o usuário. Ao
clicar numa proposta, abre `/vendedor/propostas/:id` (`GET /api/v1/seller/offers/:id`), a interface de negociação, com
"Aceitar" e "Recusar" (`POST /api/v1/seller/offers/:id/accept` e `/reject`), que só mudam o `status` da proposta: o efeito
no pedido, no estoque e no aviso ao comprador fica para a L4.

## Dependências

- **CCD084/CCD097**: criam `listings` e o seed do marketplace.
- `offers` não está no `schema.prisma` e nenhuma spec planejada a cria: esta story cria `create_offers_table`, copiada do
  DBML. Sem caso de uso para o comprador propor (L3), os testes e a homologação dependem do seed.
- **Notificações**: a CCD que gera a notificação de proposta nova não existe (L6); esta story só garante que a notificação
  com `reference_link` para a proposta abre a tela.
- **CCD080**: o perfil público, se a L7 decidir ligar o nome do comprador a ele.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `offers` | não | `create_offers_table` (copiada do DBML: `id`, `listing_id`, `buyer_id`, `offered_amount`, `message`, `status` `offer_status`, tempos, `deleted_at`; FKs `offers.listing_id > listings.id` e `offers.buyer_id > users.id`) | R2, R4, R6 |
| `listings` | não (CCD084/CCD097) | — | `seller_id`, `card_id`, `price` (R2, depende da L8) |
| `users` | sim | — | `username` do comprador (depende da L7) |
| `notifications` | sim (`Notification`) | — | `reference_link` para a proposta (R3, depende da L6) |

## Regras

- **Do vendedor** (R2): `offers.listing.seller_id = usuário logado`; proposta de outro vendedor ou excluída responde
  `404 OFFER_NOT_FOUND`.
- **Ativas** (R4, R7): `status = PENDING` (depende da L5), mais recentes primeiro.
- **Aceitar / recusar** (R6): só de `PENDING` para `ACCEPTED` ou `REJECTED`; de outro status responde
  `409 OFFER_NOT_PENDING`. Nenhum outro efeito (depende da L4).
- **Mensagem e anúncio** (L8): os detalhes trazem `message` e a carta com o preço pedido; a lista, não.

## Contrato da API

Convenções do ADR-011. Todas as rotas: autenticado com papel `SELLER` (`401` sem token, `403` outro papel, R1).

### `GET /api/v1/seller/offers` — R1, R2, R4, R7

- **Entrada:** `page`, `pageSize` (padrão 20).
- **Sucesso:** `200` `{ data: [ { id, offeredAmount: "150.00", createdAt, buyer: { id, username } } ],
  meta: { page, pageSize, total } }`
- **Erros:** `400 VALIDATION_ERROR` · `401 UNAUTHORIZED` · `403 FORBIDDEN`.

### `GET /api/v1/seller/offers/:id` — R1, R2, R5, R6

- **Sucesso:** `200` `{ data: { id, offeredAmount, message, status, createdAt, buyer: { id, username },
  listing: { id, price, card: { id, name } } } }`
- **Erros:** `400 VALIDATION_ERROR` (id não é uuid) · `401` · `403` · `404 OFFER_NOT_FOUND` (de outro vendedor ou
  excluída, R2).

### `POST /api/v1/seller/offers/:id/accept` e `POST /api/v1/seller/offers/:id/reject` — R6

- **Corpo:** vazio.
- **Sucesso:** `200` `{ data: { id, status: "ACCEPTED" | "REJECTED" } }`
- **Erros:** `401` · `403` · `404 OFFER_NOT_FOUND` · `409 OFFER_NOT_PENDING` (depende da L4/L5).

## Backend — `apps/cromocard-backend`

Domínio `src/domains/marketplace/offers/` (a pasta `marketplace/` já existe), no modelo de `src/domains/users/`
(ADR-004), registrado em `src/routes.ts` com `basePath: '/seller/offers'`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration `create_offers_table` | model `Offer` e enum `OfferStatus` copiados do DBML | R2, R4, R6 |
| `database/seed` (marketplace) | propostas `PENDING` e `REJECTED` em anúncios de dois vendedores | R4, R7 |
| `offers.validator.ts` | `offerIdParams`, `sellerOffersQuery` (Zod) | R2, R4 |
| `offers.errors.ts` | `OfferNotFoundError`, `OfferNotPendingError` | R2, R6 |
| `offers.repository.ts` | `findActiveBySeller`, `findSellerOffer`, `changeStatus` (condicional a `PENDING`) | R2, R4–R6 |
| `offers.service.ts` + `offers.service.spec.ts` | posse do vendedor, filtro de ativas, aceitar e recusar | R2, R4–R6 |
| `offers.controller.ts` · `offers.routes.ts` · `offers.swagger.ts` · `offers.module.ts` | quatro rotas com `authenticate` + `authorize('SELLER')`, no `/docs` | R1 |
| `src/routes.ts` | registra o `offersModule` | R1 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/marketplace/offers/`, no modelo de `src/features/users/` (ADR-040); rotas no `CustomerLayout`.
Sem frame (L2): as telas seguem o estilo do Painel do vendedor (ex.: `492-2007`, `675-1452`).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `offers.types.ts` · `offers.api.ts` · `offers.queries.ts` · `offers.labels.ts` | contrato, queries e mutations (ADR-041), textos (inclui "Você não tem novas propostas no momento") | R4–R7 |
| `components/OffersTable/` | valor, data e usuário de cada proposta, com `DataTable` e `Pagination`; frame da lista (L2) | R4, R5, R9 |
| `components/OfferNegotiationPanel/` | detalhes, "Aceitar" e "Recusar" com `ConfirmDialog` e `Toast`; frame dos detalhes (L2) | R6, R9 |
| `pages/ReceivedOffersPage/` · `pages/OfferDetailPage/` | estados com `LoadingState`, `ErrorState`, `EmptyState` (lista vazia, frame da L2) e `NotFoundPage` no `404` | R5, R7–R9 |
| `offers.routes.ts` · `index.ts` · `src/routes/paths.ts` | `sellerOffers: '/vendedor/propostas'`, `sellerOfferDetail: '/vendedor/propostas/:id'`, só para `SELLER` | R1, R3 |
| menu do vendedor no `CustomerLayout` | item "Propostas Recebidas" (L2) | R3 |
| item de notificação (feature `notifications`) | clicar navega para o `referenceLink` da proposta (depende da L6) | R3 |

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 2 `PENDING` e 1 `REJECTED`: `200` com só as 2, com valor, data e usuário | `offers.service.spec.ts` · `tests/integration/seller-offers.spec.ts` · `ReceivedOffersPage.spec.tsx` |
| CA2 | clicar abre os detalhes com "Aceitar" e "Recusar"; aceitar e recusar mudam o status | `OfferDetailPage.spec.tsx` · `tests/integration/seller-offers.spec.ts` |
| CA3 | sem ativas: a mensagem do FA 1 | `ReceivedOffersPage.spec.tsx` |
| CA4 | sem token `401`; `CUSTOMER` `403` | `tests/integration/seller-offers.spec.ts` |
| CA5 | proposta de outro vendedor: `404` | `offers.service.spec.ts` · `tests/integration/seller-offers.spec.ts` |
| CA6 | notificação de proposta abre a tela (depende da L6) | teste do item de notificação |
| CA7 | carregando e erro | `ReceivedOffersPage.spec.tsx` |
| CA8 | print em 1280 px igual aos frames da lista, dos detalhes e da lista vazia (L2); sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

Cobertura mínima de 90% nos arquivos alterados (ADR-060).

## Decisões técnicas

- As rotas ficam em `/seller/offers` (visão do vendedor), separadas de uma futura rota do comprador, que depende do caso de
  uso da L3.
- Aceitar e recusar são ações (`POST .../accept`, `.../reject`) e não um `PATCH` de status, porque cada uma vai ganhar
  efeitos próprios com a L4; a troca de status é condicional a `PENDING` no `updateMany`, sem corrida.
- Nenhuma decisão nova de arquitetura: segue ADR-004, ADR-011 e ADR-041.
