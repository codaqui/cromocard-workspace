# Plano — CCD085 Editar Anúncio (agrupa CCD086 Excluir, CCD087 Pausar e CCD088 Reativar)

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L16 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

"Meus anúncios" (`/vendedor/anuncios`) lista os anúncios ativos e pausados do vendedor por `GET /api/v1/me/listings`, com
abas, busca, ordenação e paginação. Cada linha abre o modal de edição (`GET` e `PATCH /api/v1/me/listings/:id`), o diálogo
de exclusão (`DELETE`, soft delete) ou as ações `POST /:id/pause` e `POST /:id/reactivate`. Pausar e excluir checam os
pedidos do anúncio; reativar checa a conta do vendedor. As listagens públicas do marketplace já filtram `ACTIVE`, então o
anúncio pausado ou excluído some delas na hora.

## Dependências

- **CCD084:** tabelas `listings`, `listing_photos`, `card_conditions`, o domínio `marketplace/listings/seller-listings.*`,
  a função `platform-fee.ts`, os componentes `ListingPhotosField`, `ListingFeeSummary` e o schema do formulário, que esta
  story reaproveita.
- **CCD108:** `connectedAccountsService.assertReady` para a reativação (depende da L13) e o Painel do vendedor.
- **CCD072 (ou CCD097, a que entrar primeiro):** a migration `create_orders_table`; aqui só se lê `orders` para bloquear a
  pausa (R12) e a exclusão (L7).
- **CCD099:** a coluna `users.suspended_until` (`add_suspended_until_to_users_table`), usada na restrição da reativação
  (R14, depende da L12).
- **CCD076 / CCD079:** as listagens públicas, que mostram só `ACTIVE` e não excluídos (R11, R13).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `listings` · `listing_photos` · `card_conditions` | não | — (CCD084) | edição, `status`, `deleted_at`; as fotos trocadas ganham `deleted_at` |
| `orders` | não | — (CCD072/CCD097) | só leitura: `listing_id`, `status` |
| `users` | sim | — (CCD099, CCD108) | `status`, `suspended_until`, `stripe_account_status` |

Sem coluna nova. "Esgotado" é calculado (`ACTIVE` com `available_quantity = 0`, depende da L3); "Última edição" vem de
`listings.updated_at`; visitas não entram (depende da L2); motivos de pausa e de exclusão não são gravados (depende da L4 e
da L5).

## Regras

- **Dono:** toda rota filtra por `seller_id` do token e `deleted_at` nulo; anúncio de outro vendedor ou excluído responde
  `404 LISTING_NOT_FOUND` (R1).
- **Transições** (R15): editar e excluir só com `ACTIVE` ou `PAUSED`; pausar só `ACTIVE`; reativar só `PAUSED`; fora disso
  `422 INVALID_LISTING_STATUS`.
- **Pausa bloqueada** (R12): existe pedido `AWAITING_PAYMENT` do anúncio → `422 LISTING_HAS_PENDING_ORDER` (depende da L16).
- **Exclusão bloqueada** (R8): existe pedido `AWAITING_PAYMENT`, `PAID`, `SHIPPED` ou `DELIVERED` → `422
  LISTING_HAS_OPEN_ORDERS` (depende da L7). A exclusão grava `deleted_at` no anúncio e nas fotos, numa transação (ADR-015).
- **Reativação** (R13, R14): conta `READY` (`422 STRIPE_ACCOUNT_NOT_READY`, depende da L13) e sem suspensão vigente
  (`suspended_until > now()` → `422 ACCOUNT_RESTRICTED`, depende da L12). Com estoque 0, reativa e aparece "Esgotado".
- **Edição** (R3–R6): a carta não muda (depende da L8); condição, preço e quantidade obrigatórios, descrição e fotos
  opcionais (depende da L9); as fotos enviadas substituem as atuais na ordem do corpo; pedidos já abertos guardam o valor
  antigo em `items_amount` (depende da L10).
- **Lista** (R2, depende da L1): abas `ACTIVE`, `PAUSED` e `SOLD_OUT` com contagem, busca pelo nome da carta ou do álbum,
  ordenação por `createdAt` (padrão, mais recentes) ou `price`, 10 por página.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, dinheiro como string decimal, erros
`{ error, message, details? }`. Todas as rotas: `authenticate` + `authorize('SELLER')`, com `401 UNAUTHORIZED` sem token e
`403 FORBIDDEN` para outro papel (R1).

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/me/listings` | `status` (`ACTIVE` \| `PAUSED` \| `SOLD_OUT`, opcional), `q`, `sort` (`-createdAt` \| `price` \| `-price`), `page`, `pageSize` | `200` `{ data: SellerListing[], meta: { page, pageSize, total, counts: { active, paused, soldOut } } }` | `400 VALIDATION_ERROR` | R2 |
| `GET /api/v1/me/listings/:id` | — | `200` `{ data: SellerListingDetail }` | `404 LISTING_NOT_FOUND` | R1, R3 |
| `PATCH /api/v1/me/listings/:id` | `{ conditionId, price, availableQuantity, description?, photoUrls? }` | `200` `{ data: SellerListingDetail }` | `400 VALIDATION_ERROR` (campo vazio, preço ≤ 0 com "Por favor, insira um valor válido maior que zero", mais de 4 fotos), `404 LISTING_NOT_FOUND`, `404 CARD_CONDITION_NOT_FOUND`, `422 INVALID_LISTING_STATUS` | R3–R6, R15 |
| `DELETE /api/v1/me/listings/:id` | — | `204` | `404 LISTING_NOT_FOUND`, `422 INVALID_LISTING_STATUS`, `422 LISTING_HAS_OPEN_ORDERS` | R7–R9, R15 |
| `POST /api/v1/me/listings/:id/pause` | — | `200` `{ data: SellerListing }` | `404`, `422 INVALID_LISTING_STATUS`, `422 LISTING_HAS_PENDING_ORDER` | R10–R12, R15 |
| `POST /api/v1/me/listings/:id/reactivate` | — | `200` `{ data: SellerListing }` | `404`, `422 INVALID_LISTING_STATUS`, `422 ACCOUNT_RESTRICTED`, `422 STRIPE_ACCOUNT_NOT_READY` | R13–R15 |

```ts
SellerListing = { id, card: { id, name, number, frontImageUrl, album: { title } }, condition: { id, name },
  price, availableQuantity, status: 'ACTIVE' | 'PAUSED', soldOut: boolean, coverUrl, updatedAt }
SellerListingDetail = SellerListing & { description, platformFee, netAmount, photos: [{ url, sortOrder }] }
```

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/marketplace/listings/seller-listings.validator.ts` | query da lista, corpo do `PATCH` | R2, R3, R5 |
| `seller-listings.repository.ts` | lista com contagem por aba, detalhe do dono, atualização com troca de fotos, soft delete, mudança de status, contagem de pedidos por status | R2–R4, R8, R10, R12, R13 |
| `seller-listings.service.ts` (+ `.spec.ts`) | transições, bloqueios e restrição de conta | R1, R4, R8, R10, R12–R15 |
| `seller-listings.errors.ts` | `LISTING_NOT_FOUND`, `INVALID_LISTING_STATUS`, `LISTING_HAS_PENDING_ORDER`, `LISTING_HAS_OPEN_ORDERS`, `ACCOUNT_RESTRICTED` | R1, R8, R12, R14, R15 |
| `seller-listings.controller.ts` · `.routes.ts` · `.swagger.ts` | as seis rotas | R1–R15 |
| `database/seeds/data/listings.json` | anúncios ativos, pausados, esgotados e um excluído do mesmo vendedor | R2 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/routes/paths.ts` · `siteMenu.ts` | `/vendedor/anuncios` e o item "Meus anúncios" no grupo "Vendedor" | R2 |
| `src/features/marketplace/listings/listings.{types,api,queries,labels}.ts` | lista, detalhe, editar, excluir, pausar, reativar e os textos da L11 | R2–R15 |
| `pages/MyListingsPage/` | página do frame `675-1452`: cartões de contagem, abas, busca, ordenação, tabela (Carta, Condição, Preço, Estoque, Status, Ações), selos "Ativo", "Pausado" e "Esgotado", paginação; sem "Visitas" e "Exportar CSV" (L1, L2); vazio, carregamento e erro (CA12) | R2, R16 |
| `components/MyListingsTable/` · `components/ListingStatusBadge/` | linhas e ações por status; "Repor estoque" abre o editar com a quantidade em foco (L3) | R2 |
| `components/EditListingModal/` | modal do frame `675-4218` com os dados atuais, taxa e líquido (`ListingFeeSummary`), fotos (`ListingPhotosField`), "Descartar" e "Salvar Alterações", "Última edição" sem visitas; carta travada (L8, L14) | R3–R6, R16 |
| `components/DeleteListingDialog/` | diálogo do frame `675-2112`, com a caixa "Entendo…" que habilita "Excluir definitivamente" e sem o motivo (L5) | R7–R9, R16 |
| `components/PauseListingDialog/` | confirmação do frame `675-2808` sem o motivo (L4); alerta da pausa bloqueada | R10–R12, R16 |
| `hooks/useReactivateListing.ts` | reativação direta com `Toast` de sucesso ou de erro (L6, L11) | R13, R14, R16 |

- **Estados:** `LoadingState`, `ErrorState` com "Tentar de novo" e `EmptyState` "Você ainda não tem anúncios" com "Criar
  Novo Anúncio" (L11, que abre o fluxo da CCD084).
- **Componentes reaproveitados de `src/components/`:** `DataTable`, `Tabs`, `SearchBar`, `Select`, `Pagination`,
  `KpiCard`, `Badge`, `Modal`, `ConfirmDialog`, `Checkbox`, `Toast`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 3 anúncios não excluídos com as ações certas por status | `seller-listings.service.spec.ts` · integração · `MyListingsPage.spec.tsx` |
| CA2 | editar o preço para R$ 1.790,00 mostra taxa R$ 89,50 e líquido R$ 1.700,50 e grava | `EditListingModal.spec.tsx` · integração |
| CA3 | preço vazio pede o campo; 0 mostra a mensagem; API `400` | `EditListingModal.spec.tsx` · integração |
| CA4 | excluir grava `deleted_at` e some da lista e do marketplace | `seller-listings.service.spec.ts` · integração · `DeleteListingDialog.spec.tsx` |
| CA5 | "Cancelar" não muda nada | `DeleteListingDialog.spec.tsx` |
| CA6 | pausar troca o status e o anúncio sai da listagem pública | integração (com `GET /cards/:cardId/listings` da CCD079) · `PauseListingDialog.spec.tsx` |
| CA7 | pedido `AWAITING_PAYMENT` bloqueia a pausa com `422` e o alerta | `seller-listings.service.spec.ts` · integração · `PauseListingDialog.spec.tsx` |
| CA8 | reativar volta a `ACTIVE` e às buscas | integração · `useReactivateListing.spec.tsx` |
| CA9 | suspensão vigente impede a reativação com `422` e a notificação | `seller-listings.service.spec.ts` · `useReactivateListing.spec.tsx` |
| CA10 | pausar pausado e reativar ativo respondem `422` | `seller-listings.service.spec.ts` · integração |
| CA11 | `401`, `403` para `CUSTOMER`, `404` para outro vendedor | integração |
| CA12 | vazio, carregamento e erro com nova tentativa | `MyListingsPage.spec.tsx` |
| CA13–CA17 | print em 1280 px igual aos frames `675-1452`, `675-4218`, `675-2112`, `675-2808` e `675-3522` (depois da L6), sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Decisões técnicas

- As quatro user stories usam o mesmo domínio e os mesmos endpoints de `/me/listings` da CCD084, com as ações como
  `POST /:id/<acao>` (ADR-011).
- "Esgotado" é um filtro calculado (`ACTIVE` + `available_quantity = 0`), não um valor de `listing_status`, para não mudar
  o DBML.
- A troca de fotos no `PATCH` marca as antigas com `deleted_at` e grava as novas, para o histórico seguir o soft delete
  (ADR-015).
