# Plano — CCD001 Visualizar Destaques

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L11 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

A URL base passa a abrir a Home pública (`HomePage`), sem login. Ela faz três chamadas públicas: `GET
/api/v1/listings/most-wanted` (as 4 cartas mais vendidas nos últimos 30 dias, com "A partir de", depende das L2 e L3),
`GET /api/v1/listings?sort=-createdAt&pageSize=8` (CCD078, "Cartas recém-anunciadas", depende da L10) e
`GET /api/v1/categories/default` (CCD078, o filtro "Todas" + categorias padrão na ordem da CCD104). Escolher uma categoria
abre o Explorar filtrado (`/marketplace?categoria=<id>`, pela documentação enquanto a L5 não decide). O `SiteShell` ganha o
menu do visitante (Início, Marketplace, Pesquisar | Como funciona, Central de ajuda), o rodapé das telas públicas e o topo
com "Entrar" e "Criar conta grátis".

## Dependências

- **CCD078:** `GET /listings`, `GET /categories/default`, o `ListingCard` e a rota `/marketplace`. Entra antes desta (ou no
  mesmo ciclo); sem ela, "Cartas recém-anunciadas" não tem dados.
- **CCD097:** `orders` (`create_orders_table`) e o seed de vendas, para "Mais procuradas" (R4, R5). Se esta story vier
  antes, ela cria a migration copiada do DBML.
- **CCD106:** `cards.status` (R4, só cartas `ACTIVE`).
- **CCD002:** comportamento da barra de busca (R15); aqui só o lugar dela no topo.
- **CCD003, CCD004, CCD005, CCD030, CCD079:** destinos de "Criar conta grátis", "Entrar", Como funciona / Central de ajuda,
  perfil da carta e detalhe do anúncio. Os que ainda não existirem ficam com o `underConstructionRoute`.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `orders` | não | `create_orders_table` (da CCD097) | só leitura: `listing_id`, `quantity`, `status`, `released_at` (R4, R5) |
| `listings`, `listing_photos`, `card_conditions` | não | da CCD078/CCD084/CCD097 | R6 |
| `cards`, `albums`, `categories`, `users` | sim | — | `cards.status` da CCD106 |

Seed (`database/seeds/marketplace.seed.ts`): pedidos `COMPLETED` com `released_at` nos últimos 30 dias para 5 cartas e uma
carta com 10 vendas há 40 dias (CA1, CA3). Nenhuma coluna nova.

## Regras

- **Venda concluída** (R5, depende da L3): pedido `COMPLETED`, `released_at` nos últimos 30 dias (contados do momento da
  consulta), somando `quantity` por carta (`listings.card_id`); só cartas `ACTIVE` e não excluídas.
- **Mais procuradas** (R4): as 4 de maior soma, decrescente; empate pelo nome da carta. Sem nenhuma, `data: []` e a seção
  some (R11).
- **"A partir de"** (depende da L2): o menor `price` entre os anúncios ativos da carta; sem anúncio, `fromPrice: null` e o
  cartão não mostra preço.
- **Categoria do cartão** (depende da L7): a raiz da categoria da carta ou do álbum, como na CCD078.
- **Recém-anunciadas** (R6, depende da L10): as regras da CCD078 (ativo, `available_quantity > 0`, vendedor ativo), 8 por
  `-createdAt`.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, dinheiro como string decimal, erros
`{ error, message, details? }`.

### `GET /api/v1/listings/most-wanted` — R1, R4, R5, R11

- **Acesso:** público.
- **Entrada:** nenhuma (30 dias e 4 cartas fixos pelo `01`, FP 2).
- **Sucesso:** `200`

  ```json
  { "data": [{ "card": { "id": "uuid", "name": "Charizard", "imageUrl": "https://…" },
      "category": { "id": "uuid", "name": "Pokémon" }, "salesCount": 32, "fromPrice": "120.00" }] }
  ```

- **Erros:** nenhum de negócio (só `500` do handler).

### Reaproveitados da CCD078

| Método e caminho | Uso na Home | Requisitos |
|---|---|---|
| `GET /api/v1/listings?sort=-createdAt&pageSize=8` | "Cartas recém-anunciadas" | R1, R6, R12 |
| `GET /api/v1/categories/default` | filtro "Todas" + categorias padrão | R1, R7 |

## Backend — `apps/cromocard-backend`

Domínio `src/domains/marketplace/listings/` (da CCD078).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + `create_orders_table` (se ainda não existir) | modelo `Order` e enum `OrderStatus`, copiados do DBML | R5 |
| `database/seeds/marketplace.seed.ts` · `data/orders.json` | vendas recentes e antigas | R4, R5 |
| `listings.most-wanted.repository.ts` | uma consulta SQL: soma de `orders.quantity` por carta, `COMPLETED`, `released_at >= now() - 30 dias`, menor preço ativo e categoria | R4, R5 |
| `listings.service.ts` + `listings.service.spec.ts` | `findMostWanted()`: top 4, empate, `fromPrice` | R4, R5, R11 |
| `listings.controller.ts` · `listings.routes.ts` · `listings.swagger.ts` | `GET /listings/most-wanted`, registrada antes de `/listings/:id` | R1 |
| `tests/integration/listings-most-wanted.spec.ts` | CA2, CA3, CA9 | R1, R4, R5, R11 |

## Frontend — `apps/cromocard-frontend`

Feature nova `src/features/public/` (Área Pública: Home, Central de ajuda e Como funciona), no modelo de
`src/features/users/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/routes/paths.ts` | `marketplace` (se a CCD078 não criou), `howItWorks: '/como-funciona'`, `terms: '/termos'`; sai `highlights` | R3, R13, R14 |
| `app/layouts/SiteShell/siteMenu.ts` | `visitorMainMenu` (Início, Marketplace, Pesquisar) e `visitorSecondaryMenu` (Como funciona, Central de ajuda); sai `siteLinks` | R13 |
| `app/layouts/SiteShell/SiteShell.tsx` · `SiteShell.module.css` | menu do visitante ou do cliente pelo `useAuth`; topo com a barra e "Entrar" / "Criar conta grátis"; `SiteFooter` só para o visitante, frame `1112-2169` | R13–R15 |
| `app/layouts/SiteShell/SiteFooter/` | "© 2026 CromoCard", "Como funciona", "Central de ajuda", "Termos de Uso e Privacidade", frame `1112-2169` | R14 |
| `public/home/home.{types,api,queries,labels}.ts` | `useMostWanted`; textos do destaque e do vazio (texto: L6) | R2, R4, R12 |
| `public/home/components/HomeHero/` | rótulo, título, texto e os dois atalhos, frame `1112-2169` | R2, R3 |
| `public/home/components/HowItWorksSteps/` | "1 Encontre a carta / 2 Pague com proteção / 3 Receba e confirme", estático (depende da L1), frame `1112-2169` | R16 |
| `public/home/components/MostWantedSection/` | 4 cartões com imagem, "<n> vendas • <categoria>", nome e "A partir de" (L2); link "Ver no marketplace →" (L4); some sem dados; frame `1112-2169` | R4, R8, R11 |
| `public/home/components/RecentListingsSection/` | chips "Todas" + categorias (navegam para o Explorar filtrado, L5), 8 `ListingCard` (CCD078), "Ver todas →" (L4) e o vazio "Ainda não há anúncios" (L6), frame `1112-2169` | R6, R7, R9, R10, R12 |
| `public/home/pages/HomePage/` | monta as seções; carregando e erro por seção (depende da L11) | R1–R12, R16 |
| `public/public.routes.ts` · `public/index.ts` · `app/router.tsx` | a rota índice do `PublicLayout` vira a `HomePage` (no lugar do `RoleHomeRedirect` para `CUSTOMER` e `SELLER`, depende da L9; o `ADMIN` continua indo para o BackOffice); `/como-funciona` e `/termos` em construção até a CCD005 e a CCD003 | R1, R13, R14 |
| `src/features/catalog/catalog.routes.ts` | sai a rota em construção de `/destaques` | R13 |

- **Rotas:** `/` (Home), pública.
- **Estados:** carregando e erro com `LoadingState` e `ErrorState` por seção (depende da L11); vazio de anúncios com
  `EmptyState` (L6).
- **Componentes reaproveitados de `src/components/`:** `Button`, `Badge`, `SearchBar`, `NavItem`, `EmptyState`,
  `LoadingState`, `ErrorState`; `ListingCard` da CCD078.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | destaque com os atalhos, 4 mais procuradas em ordem e recém-anunciadas do mais novo ao mais antigo | `listings.service.spec.ts` · `HomePage.spec.tsx` |
| CA2 | `GET /listings/most-wanted` sem token responde `200` | `tests/integration/listings-most-wanted.spec.ts` |
| CA3 | 10 vendas há 40 dias não entram | `listings.service.spec.ts` · integração |
| CA4 | filtro "Todas", Pokémon, Futebol, Magic | `RecentListingsSection.spec.tsx` |
| CA5 | "Pokémon" leva a `/marketplace?categoria=<id>` (conforme a L5) | `RecentListingsSection.spec.tsx` |
| CA6, CA7 | carta abre `/cartas/:id`; anúncio abre `/anuncios/:id` | `MostWantedSection.spec.tsx` · `ListingCard.spec.tsx` |
| CA8 | os atalhos abrem `/cadastro` e `/marketplace` | `HomeHero.spec.tsx` |
| CA9 | sem vendas, a seção não aparece | integração · `HomePage.spec.tsx` |
| CA10 | sem anúncios, o aviso da L6 | `RecentListingsSection.spec.tsx` |
| CA11 | visitante com "Início" destacado e rodapé; cliente com o menu da Área do Cliente | `SiteShell.spec.tsx` · `SiteFooter.spec.tsx` |
| CA12 | termo na barra abre `/pesquisar?q=` | `SiteShell.spec.tsx` |
| CA13 | print em 1280 px igual ao frame `1112-2169`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Dependências e riscos

- **L9:** sem decisão, o plano segue o EA-001-01 (a Home com o menu do cliente). Se a L9 escolher o Início da coleção
  (CCD007), a rota índice volta a redirecionar o cliente e só o visitante vê a Home.
- **L5:** se o PO decidir filtrar na própria Home (como o Figma), os chips passam `categoryId` ao `GET /listings` em vez de
  navegar; o contrato não muda.
- **L1, L2, L4:** se o PO disser "não" a algum, o componente correspondente sai (`HowItWorksSteps`, `fromPrice`, os links).

## Decisões técnicas

- As vendas ficam numa consulta só (agregação em SQL), porque o Prisma não agrupa por coluna de tabela relacionada
  (`listings.card_id`) com a soma de `orders.quantity`.
- A rota `most-wanted` fica no módulo de anúncios (marketplace), dona de `orders` e `listings`, e não no catálogo.
- A Home, a Central de ajuda e o Como funciona ficam numa feature `public`, porque não pertencem a um domínio do backend.
