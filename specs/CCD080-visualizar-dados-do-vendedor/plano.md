# Plano — CCD080 Visualizar Dados do Vendedor

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L12 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O detalhe do anúncio (`GET /api/v1/listings/:id`, CCD079) e a lista de anúncios da carta
(`GET /api/v1/cards/:cardId/listings`, CCD079/CCD030) passam a trazer `seller: { id, username, city, state }`, e a tela
mostra o cartão do vendedor e as colunas do vendedor nas tabelas. O nome do vendedor leva ao perfil público
(`/usuarios/:id`), que chama `GET /api/v1/profiles/:userId` (nome de usuário, cidade, totais) e
`GET /api/v1/profiles/:userId/listings` (anúncios ativos). As duas rotas são públicas e nunca devolvem nome completo,
e-mail, CPF nem endereço (R9).

## Dependências

- **CCD079**: cria `GET /listings/:id`, `GET /cards/:cardId/listings`, a página `/anuncios/:id` e a tabela "Outros
  anúncios"; esta story só acrescenta o vendedor.
- **CCD030 (Visualizar Detalhes)**: dona do Perfil da carta (`1112-4615`) e da lista "Anúncios disponíveis".
- **CCD084/CCD097**: criam `listings`, `card_conditions`, `orders` e o seed do marketplace.
- **CCD110**: define o pedido `COMPLETED` (base de "Vendas concluídas", depende da L4).
- **CCD002**: a busca com "Ver perfil" (só o link muda para o perfil público, R6).
- `profiles` não está no `schema.prisma` e nenhuma spec planejada a cria: esta story cria `create_profiles_table`, copiada
  do DBML.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `profiles` | não | `create_profiles_table` (copiada do DBML: `id`, `user_id` único, `bio`, `avatar_url`, `city`, `portfolio_privacy`, tempos, `deleted_at`) | lê `city` e `avatar_url` (R2, R3, R7) |
| `profiles.state` | não | `add_state_to_profiles` (depende da L3 e de um PR de docs no DBML antes do código) | "cidade - UF" (R2, R3) |
| `users` | sim | — | só `id`, `username`, `role`, `status`, `created_at`, `deleted_at` (R7, R9) |
| `listings`, `orders`, `cards`, `albums`, `categories`, `card_conditions` | não (CCD084/CCD097) | — | só leitura (R7, R8) |

## Regras

- **Cidade:** `profiles.city`; a UF só entra com a L3. Sem cidade, o campo não vem na resposta e a tela não mostra a
  linha (R5).
- **Vendas concluídas** (R7): pedidos do vendedor com `status = COMPLETED` (depende da L4).
- **Anúncios ativos** (R7, R8): `status = ACTIVE` e `deleted_at` nulo; pausados e encerrados não entram (CA5).
- **Usuário indisponível**: inexistente, excluído, suspenso ou bloqueado responde `404 PROFILE_NOT_FOUND` (depende da L10).
- **Selos, "desde", avatar e conquistas** (L5–L8): fora do plano até a decisão; a resposta não traz esses campos.
- **Nota média** (R4): suspensa pela L2; a resposta não traz `averageRating`.
- **Privacidade** (R9): o `select` do repository lista só os campos públicos; nenhum `include` de `users` inteiro.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, dinheiro como string decimal, erros
`{ error, message, details? }`.

### `GET /api/v1/listings/:id` e `GET /api/v1/cards/:cardId/listings` (CCD079) — R2, R3, R5

- Acrescenta, em cada anúncio: `"seller": { "id": "uuid", "username": "tiago_trocas", "city": "Campinas", "state": "SP" }`.
  `city` e `state` só vêm quando cadastrados (R5); `state` depende da L3.

### `GET /api/v1/profiles/:userId` — R1, R7, R9

- **Acesso:** público.
- **Entrada:** `userId` (uuid) no caminho.
- **Sucesso:** `200`

  ```json
  { "data": { "id": "uuid", "username": "tiago_trocas", "city": "Campinas", "state": "SP",
    "completedSales": 312, "activeListings": 1 } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `userId` não é uuid | R1 |
  | 404 | `PROFILE_NOT_FOUND` | inexistente, excluído, suspenso ou bloqueado (depende da L10) | R7 |

### `GET /api/v1/profiles/:userId/listings` — R1, R8

- **Acesso:** público.
- **Entrada:** `page`, `pageSize` (padrão 12).
- **Sucesso:** `200` `{ data: PublicListing[], meta: { page, pageSize, total } }`, com
  `PublicListing = { id, price, condition: { name }, card: { id, name, imageUrl }, album: { name }, category: { name } }`.
- **Erros:** `400 VALIDATION_ERROR`, `404 PROFILE_NOT_FOUND` — R8.

## Backend — `apps/cromocard-backend`

Domínio novo `src/domains/profiles/` (componente "Perfil" do C4), no modelo de `src/domains/users/` (ADR-004),
registrado em `src/routes.ts`. Rotas públicas, sem `router.use(authenticate)`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration `create_profiles_table` | model `Profile` copiado do DBML, relação 1:1 com `User` | R2, R3, R7 |
| `database/seed` (marketplace) | perfis com cidade para os vendedores do seed, um sem cidade | R5 |
| `profiles.validator.ts` | `userIdParams`, `publicListingsQuery` (Zod) | R1, R8 |
| `profiles.errors.ts` | `ProfileNotFoundError` (`404 PROFILE_NOT_FOUND`) | R7 |
| `profiles.repository.ts` | `findPublicProfile` (só campos públicos, totais com `count`), `findActiveListings` | R7–R9 |
| `profiles.service.ts` + `profiles.service.spec.ts` | perfil público, regra de usuário indisponível, omissão de campos vazios | R5, R7–R9 |
| `profiles.controller.ts` · `profiles.routes.ts` · `profiles.swagger.ts` · `profiles.module.ts` | as duas rotas, no `/docs` | R1 |
| `src/domains/marketplace/listings/listings.repository.ts` (CCD079) | `select` do vendedor (`username`, `profile.city`) no detalhe e na lista da carta | R2, R3 |
| `src/domains/marketplace/listings/listings.service.ts` | monta `seller` sem campos vazios | R5 |
| `src/routes.ts` | registra o `profilesModule` | R1 |

## Frontend — `apps/cromocard-frontend`

Feature nova `src/features/profiles/`, no modelo de `src/features/users/` (ADR-040); rota no `PublicLayout` do
`app/router.tsx` (o layout já troca o topo para o cliente logado).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/marketplace/listings/listings.types.ts` | `ListingSeller` no contrato | R2, R3 |
| `src/features/marketplace/listings/components/SellerCard/` | cartão do vendedor (nome de usuário com link e "cidade - UF"), frames `1112-5772` e `1112-6152` | R2, R5, R6, R11 |
| `src/features/marketplace/listings/components/OtherListingsTable/` (CCD079) | coluna do vendedor com link, frame `1112-5772` | R3, R6, R11 |
| tabela "Anúncios disponíveis" do Perfil da carta (CCD030) | coluna do vendedor com link, frame `1112-4615` | R3, R6, R11 |
| `profiles.types.ts` · `profiles.api.ts` · `profiles.queries.ts` · `profiles.labels.ts` | contrato, chamadas (TanStack Query, ADR-041) e textos ("Vendas concluídas", "Anúncios ativos", aviso de privacidade) | R7–R9 |
| `components/PublicProfileHeader/` | nome de usuário, cidade e os dois totais, frame `1160-1396` | R7, R11 |
| `components/PublicListingsGrid/` | "Anúncios ativos de <nome de usuário> (<n>)" com os cartões, frame `1160-1396` | R8, R11 |
| `components/PrivacyNotice/` | aviso no fim da página, frame `1160-1396` | R9, R11 |
| `pages/PublicProfilePage/` | página com `LoadingState`, `ErrorState` e `NotFoundPage` | R1, R10 |
| `profiles.routes.ts` · `index.ts` · `src/routes/paths.ts` | `publicProfile: '/usuarios/:id'` e `publicProfilePathFor(id)` | R1, R6 |
| `src/app/router.tsx` | rota pública no `PublicLayout` | R1 |
| resultado de usuários da busca (CCD002) | "Ver perfil" aponta para `publicProfilePathFor` | R6 |

- **Componentes reaproveitados de `src/components/`:** `Badge`, `Pagination`, `LoadingState`, `ErrorState`, `EmptyState`,
  `NotFoundPage`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | visitante sem token: `200` com `seller.username` e `city`; cartão mostra "cidade - UF" | `tests/integration/listings.spec.ts` · `SellerCard.spec.tsx` |
| CA2 | cada linha das duas tabelas mostra o vendedor dela | `OtherListingsTable.spec.tsx` · teste da tabela do Perfil da carta |
| CA3 | vendedor sem cidade: sem `city` na resposta e sem linha vazia ou "—" | `listings.service.spec.ts` · `SellerCard.spec.tsx` |
| CA4 | clicar no nome abre `/usuarios/:id` com os totais | `SellerCard.spec.tsx` · `PublicProfilePage.spec.tsx` · `profiles.service.spec.ts` |
| CA5 | 1 ativo e 1 pausado: "(1)" e só o ativo | `profiles.service.spec.ts` · `tests/integration/profiles.spec.ts` |
| CA6 | resposta sem `name`, `email`, `cpf` e endereço; aviso de privacidade na tela | `tests/integration/profiles.spec.ts` · `PublicProfilePage.spec.tsx` |
| CA7 | carregando e erro sem quebrar o layout | `PublicProfilePage.spec.tsx` |
| CA8–CA11 | print em 1280 px igual aos frames `1112-5772`, `1112-6152`, `1112-4615` e `1160-1396`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

Cobertura mínima de 90% nos arquivos alterados (ADR-060).

## Decisões técnicas

- O perfil público fica num domínio próprio (`profiles`), e não em `users`, porque o router de `users` exige token e
  papel `ADMIN` depois de `/me`; o perfil é público e só lê campos públicos.
- A rota usa o `id` do usuário, não o nome de usuário, porque `username` pode ser nulo (L12).
- O vendedor entra na resposta do anúncio que já existe (CCD079), sem endpoint paralelo.
- Nenhuma decisão nova de arquitetura: segue ADR-004, ADR-011 e ADR-041.
