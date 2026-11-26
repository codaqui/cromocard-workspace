# Plano — CCD084 Criar Anúncio

> Revisto em 24/11/2026 com as lacunas L1–L13 decididas pelo PO e com a base do marketplace (Onda 0) já no `develop`.

- **Spec:** [spec.md](spec.md), aprovada em 24/11/2026 (Felipe Consulim, PO), lacunas L1–L13 decididas
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

"Criar anúncio" (Painel do vendedor), "Anunciar esta carta" (perfil da carta) e "Anunciar repetida" (Início, só `SELLER`) consultam
`GET /api/v1/me/listings/eligibility`. Sem conta Stripe pronta, abre o aviso bloqueado; sem endereço principal, o pedido
de cadastro do endereço; com os dois, o modal "Criar anúncio". O vendedor busca a carta no catálogo, escolhe a condição,
informa preço, quantidade, descrição e até 4 fotos (enviadas antes pelo `POST /api/v1/uploads`), vê a taxa de 5% e o
líquido e publica com `POST /api/v1/me/listings`, que grava `listings` `ACTIVE` e `listing_photos` numa transação.

## Dependências

- **Base do marketplace (Onda 0, backend #44):** `card_conditions` com o seed das 5 condições, `listings` com
  `condition_id`, `listing_photos` e `users.stripe_account_status` já estão no `develop`. Esta story não cria tabela.
- **CCD007 (Início):** o botão "Anunciar repetida", hoje com `underConstructionRoute`, passa a abrir este fluxo (L9, R2).
- **CCD108:** `users.stripe_account_status` e `connectedAccountsService.assertReady` (R9), o Painel do vendedor
  (`/vendedor`, grupo "Vendedor" do menu) e o aviso de conectar a conta.
- **CCD106 (Salvar Rascunho de Carta):** cria `cards.status` (`card_status`: `DRAFT`, `ACTIVE`); a busca filtra por ele
  (R4). Se a CCD106 ainda não estiver no `develop`, esta story espera por ela.
- **CCD048 (Editar Dados do Perfil):** dona do cadastro de endereços; aqui só se lê `addresses.is_primary` e o botão leva ao
  Perfil (R10). A tabela `addresses` já existe.
- **CCD030 (Visualizar Detalhes):** dona do perfil da carta, onde entra "Anunciar esta carta" (R2). Se a página ainda não
  existir, o botão entra quando ela for feita, e a entrada pelo Painel cobre o R2 até lá.
- **CCD079 / CCD076:** o detalhe público do anúncio (`GET /api/v1/listings/:id`) e a busca do marketplace, onde o anúncio
  publicado aparece (R7) e onde entram as fotos ou a imagem da carta (R8).
- **Busca de cartas do catálogo** para quem não é admin: hoje só existe `GET /api/v1/admin/catalog/cards`. Se a CCD021 ou
  a CCD002 já tiver criado uma busca pública de cartas, esta story a reaproveita e garante o filtro de status; se não,
  cria `GET /api/v1/cards` com só o parâmetro `q` (R4).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `card_conditions` | sim (#44) | — | seed Mint, Near Mint, Ótimo, Bom, Regular (`sort_order` 1–5) já existe |
| `listings` | sim (#41 e #44) | — | enum `listing_status`, `condition_id` opcional no banco |
| `listing_photos` | sim (#44) | — | FK para `listings`, `sort_order` default 0 |
| `cards` | sim | — (status vem da CCD106) | `status`, `deleted_at`, `front_image_url` |
| `users` · `addresses` | sim | — (#44 criou as colunas Stripe; a CCD108 as preenche) | `stripe_account_status`; `is_primary`, `deleted_at` |

Sem tabela nem coluna nova. A migration `insert_card_conditions` grava as 5 condições com os mesmos ids do seed, para
existirem também em homologação e produção, onde o seed não roda. A condição obrigatória (L5) fica na validação, sem mudar o DBML. A quantidade é inteira de 1 a
99 (L10). Dois anúncios iguais do mesmo vendedor são permitidos (L13).

## Regras

- **Taxa e líquido** (R6): `platformFee = floor(price × 5) / 100` em centavos (`floor(priceCents × 0,05)`), `net = price −
  platformFee`; R$ 1.850,00 → taxa R$ 92,50 e líquido R$ 1.757,50. A mesma função (`platform-fee.ts`) serve a CCD110 e a
  CCD111. A tela recalcula enquanto o vendedor digita (L2).
- **Pode anunciar** (R9, R10): conta `READY` e endereço principal não excluído. A ordem das checagens é a da conta e
  depois a do endereço. O credenciamento (`seller_verifications`) não entra (L11).
- **Carta do catálogo** (R4): `deleted_at` nulo; outra carta responde `404 CARD_NOT_FOUND`. O filtro `cards.status = ACTIVE`
  entra quando a CCD106 criar a coluna (L15).
- **Conta pronta** (R9): `users.stripe_account_status = READY`, lido direto do usuário; quando a CCD108 trouxer o
  `connectedAccountsService.assertReady`, a checagem passa a usá-lo (L14).
- **Fotos** (R8): até 4 URLs devolvidas pelo upload, gravadas com `sort_order` 0–3 na ordem do corpo. Sem foto, o anúncio
  usa `cards.front_image_url` (quem mostra é o detalhe da CCD079).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, dinheiro como string decimal, erros
`{ error, message, details? }`.

### `GET /api/v1/me/listings/eligibility` — R9, R10

- **Acesso:** `authenticate` + `authorize('SELLER')`
- **Sucesso:** `200` `{ "data": { "canCreate": false, "stripeAccountReady": false, "hasPrimaryAddress": true } }`
- **Erros:** `401`, `403` (R1).

### `GET /api/v1/cards` — R3, R4

- **Acesso:** `authenticate`
- **Entrada:** `q` (2 a 100 caracteres), `pageSize` (padrão 10, máximo 20).
- **Sucesso:** `200` `{ data: CardOption[], meta }`, com `CardOption = { id, name, number, frontImageUrl, album: { id,
  title }, category: { id, name } }` (a categoria e o álbum formam a ajuda da L6). Só cartas `ACTIVE` e não excluídas.
- **Erros:** `400 VALIDATION_ERROR`, `401`.

### `GET /api/v1/card-conditions` — R3

- **Acesso:** `authenticate`
- **Sucesso:** `200` `{ data: [{ id, name, sortOrder }] }`, por `sort_order`.

### `POST /api/v1/uploads` (existente) — R8

- Muda só o acesso, para `authorize('ADMIN', 'SELLER')`, e a pasta, que ganha `listings`. O limite de 4 MB e PNG, JPG ou
  WEBP já estão no domínio (`400 VALIDATION_ERROR`, `413 FILE_TOO_LARGE` e `415 UNSUPPORTED_FILE_TYPE`, os erros que o
  domínio já usa, ADR-050).

### `POST /api/v1/me/listings` — R1, R3–R10

- **Acesso:** `authenticate` + `authorize('SELLER')`
- **Entrada:**

  ```json
  { "cardId": "uuid", "conditionId": "uuid", "price": "1850.00", "availableQuantity": 1,
    "description": "opcional, até 2000", "photoUrls": ["https://…"] }
  ```

- **Sucesso:** `201`

  ```json
  { "data": { "id": "uuid", "status": "ACTIVE", "price": "1850.00", "platformFee": "92.50", "netAmount": "1757.50",
    "availableQuantity": 1, "description": "…", "card": { "id": "uuid", "name": "…" },
    "condition": { "id": "uuid", "name": "Mint" }, "photos": [{ "url": "…", "sortOrder": 0 }] } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | preço ≤ 0 (mensagem "Por favor, insira um valor válido maior que zero"), quantidade fora de 1–99, mais de 4 fotos, URL fora do storage, condição ausente | R3, R5, R8 (L5, L10) |
  | 401 / 403 | `UNAUTHORIZED` / `FORBIDDEN` | sem token / papel diferente de `SELLER` | R1 |
  | 404 | `CARD_NOT_FOUND` | carta inexistente, excluída ou em rascunho | R4 |
  | 404 | `CARD_CONDITION_NOT_FOUND` | condição inexistente | R3 |
  | 422 | `STRIPE_ACCOUNT_NOT_READY` | conta de recebimento não está `READY` | R9 |
  | 422 | `PRIMARY_ADDRESS_REQUIRED` | vendedor sem endereço principal | R10 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/seeds/data/marketplace.json` · `marketplace.seed.ts` | fotos de exemplo (`listing_photos`) em parte dos anúncios do seed, para ter anúncio com e sem foto | R8 |
| `src/domains/marketplace/shared/platform-fee.ts` (+ `.spec.ts`) | taxa de 5% arredondada para baixo e líquido | R6 |
| `src/domains/marketplace/listings/seller-listings.{validator,repository,service,controller,routes,swagger,errors}.ts` + `seller-listings.module.ts` (`basePath: '/me/listings'`) | elegibilidade e criação | R1, R3, R5–R10 |
| `src/domains/catalog/public-cards.{validator,repository,controller,routes,swagger}.ts` + módulo (`basePath: '/cards'`) e `card-conditions` (`basePath: '/card-conditions'`) | busca do catálogo para o vendedor e lista das condições | R3, R4 |
| `src/domains/uploads/uploads.routes.ts` · `uploads.validator.ts` | `SELLER` pode enviar; pasta `listings` | R8 |
| `src/routes.ts` | registra os módulos novos | R1 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/marketplace/listings/` (a mesma da CCD079), no modelo de `src/features/users/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `listings.{types,schemas,labels,api,queries}.ts` | tipos, schema Zod do formulário (preço > 0 com a mensagem do R5, quantidade 1–99, até 4 fotos), textos e chamadas | R3, R5, R7–R10 |
| `listings.fee.ts` (+ `.spec.ts`) | taxa e líquido para a tela, com a mesma regra do backend | R6 |
| `components/CardCatalogPicker/` | busca da carta com a ajuda "Identificada no catálogo oficial <categoria> • <álbum>" (L6) | R3, R4, R12 |
| `components/ListingPhotosField/` | os 2 espaços do frame e, preenchidos, mais até 4 no mesmo estilo (L1); erro de arquivo recusado | R8 |
| `components/ListingFeeSummary/` | "Taxa  (5%):" e "Você recebe líquido:" | R6 |
| `components/CreateListingModal/` | modal do frame `282-4482`: título, subtítulo, campos, "Cancelar" e "Publicar anúncio" em carregamento (CA10); sem o rodapé "Vault / Escrow" (L3) e sem o campo sem rótulo (L4) | R3, R5–R8, R11, R12 |
| `components/ListingBlockedDialog/` | aviso do frame `1112-10828` com "Agora não" (L8) e "Conectar conta Stripe", que usa o link da CCD108 | R9, R11 |
| `components/PrimaryAddressRequiredDialog/` | pedido do endereço principal no estilo do aviso bloqueado, com "Cadastrar endereço" para o Perfil (L12) | R10 |
| `hooks/useCreateListingFlow.ts` | consulta a elegibilidade e abre o aviso, o pedido de endereço ou o modal | R2, R9, R10 |
| `pages/SellerOverviewPage/` (CCD108) · perfil da carta (CCD030) | botões "Criar Novo Anúncio"/"Criar Anúncio" desabilitados sem a conta `READY` (L7; já feitos na CCD108) e "Anunciar esta carta" só para `SELLER`, com a carta escolhida | R2 |
| `features/collection` (Início, CCD007) | "Anunciar repetida" só para `SELLER`, abrindo o fluxo com a carta escolhida, no lugar do `underConstructionRoute` (L9) | R2 |

- **Estados:** busca carregando e sem resultado; erro da API no modal, com os campos preenchidos (CA10).
- **Componentes reaproveitados de `src/components/`:** `Modal`, `OverlayDialog`, `TextField`, `Select`, `Textarea`,
  `FileUpload`, `FormField`, `FormError`, `Button`, `Toast`; `ImageUploadField` da feature `catalog` como base do
  `ListingPhotosField`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | taxa R$ 92,50 e líquido R$ 1.757,50; anúncio `ACTIVE` gravado com todos os campos | `platform-fee.spec.ts` · `seller-listings.service.spec.ts` · `tests/integration/marketplace/seller-listings.spec.ts` · `CreateListingModal.spec.tsx` |
| CA2 | "Anunciar esta carta" abre o modal com a carta escolhida | `useCreateListingFlow.spec.tsx` |
| CA3 | carta `DRAFT` e excluída não aparecem na busca e respondem `404` na criação | `public-cards` integração · `seller-listings.service.spec.ts` |
| CA4 | preço 0 e −10 mostram a mensagem; API responde `400` | `listings.schemas.spec.ts` · integração |
| CA5 | 2 fotos gravadas na ordem; sem foto, a imagem da carta | `seller-listings.service.spec.ts` · integração (via `GET /listings/:id` da CCD079) |
| CA6 | quinta foto, PDF e arquivo de 5 MB recusados | `ListingPhotosField.spec.tsx` · integração do upload como `SELLER` |
| CA7 | sem conta pronta: aviso com "Conectar conta Stripe"; API `422` sem gravar | `useCreateListingFlow.spec.tsx` · integração |
| CA8 | sem endereço principal: pedido de cadastro; API `422` | `useCreateListingFlow.spec.tsx` · integração |
| CA9 | `401` sem token; `403` para `CUSTOMER` e `ADMIN` | integração |
| CA10 | botão em carregamento; erro mantém o formulário preenchido | `CreateListingModal.spec.tsx` |
| CA11, CA12 | print em 1280 px igual aos frames `282-4482` e `1112-10828`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |
| CA13 | sem condição, quantidade 0 e 100: erro no campo; API `400 VALIDATION_ERROR` | `listings.schemas.spec.ts` · `seller-listings.validator.spec.ts` · integração |
| CA14 | "Anunciar repetida" abre com a carta escolhida para `SELLER` e não aparece para `CUSTOMER` | `useCreateListingFlow.spec.tsx` · spec da Início (CCD007) |
| CA15 | ajuda "Identificada no catálogo oficial Pokémon TCG • Shining Fates" | `CardCatalogPicker.spec.tsx` |

## Decisões técnicas

- As fotos sobem antes, uma a uma, pelo `POST /api/v1/uploads` (ADR-050), e a criação recebe só as URLs; a API aceita só
  URLs do próprio storage, para o anúncio não apontar para imagem de fora.
- Os endpoints do vendedor ficam em `/me/listings` (ADR-011, recursos do usuário logado); o detalhe público continua em
  `/listings/:id` (CCD079).
- A taxa é calculada em centavos inteiros, nunca em ponto flutuante, numa função só usada por criação, edição, liberação e
  BackOffice.
