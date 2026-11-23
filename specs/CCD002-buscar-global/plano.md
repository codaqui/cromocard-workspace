# Plano — CCD002 Buscar Global

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L15 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

A barra do topo valida o termo (2 a 100 caracteres, depende da L1) e abre `/pesquisar?q=<termo>&tipo=<aba>`. A página
"BUSCA" chama `GET /api/v1/search`, que devolve, num só pedido, as contagens dos quatro grupos e os itens da aba aberta:
em "Tudo", 4 anúncios, 2 usuários, 2 grupos e 2 álbuns (depende da L11); numa aba só, 8 por vez com "Carregar mais"
(depende da L10). O grupo "Cartas" usa a listagem pública da CCD078 com `q`. "Ver álbum" abre a página pública do álbum
(`/catalogo/albuns/:id`), que chama `GET /api/v1/albums/:id` e `GET /api/v1/albums/:id/cards`. Para o visitante,
"Favoritar", "Adicionar à minha coleção" e "Entrar no grupo" abrem o modal "Entre para continuar" sem gravar nada.

## Dependências

- **CCD078:** `GET /listings` com `q`, o `ListingCard` e o módulo `catalog/public/`. O grupo "Cartas" reaproveita os dois.
- **CCD106:** `cards.status`, para só mostrar cartas `ACTIVE` (R16).
- **CCD097:** `orders`, para "<n> vendas" (R9, depende da L4); sem a tabela, o número fica `0`.
- **CCD048:** `profiles` (`avatar_url`); até lá, o cartão do usuário mostra as iniciais (R9).
- **CCD001:** dona do topo do visitante (botões "Entrar" e "Criar conta grátis"); esta story muda só a barra de busca.
- **CCD030 / CCD080 / CCD039:** destinos de "Ver carta", "Ver perfil" e "Entrar no grupo" para o cliente logado.
- **ADR novo `Proposto` (busca sem acentos):** ver Decisões técnicas; precisa estar registrado antes do código.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `listings`, `listing_photos`, `card_conditions` | não | da CCD078/CCD084/CCD097 | grupo Cartas (R7) |
| `cards`, `albums`, `categories` | sim | — | `cards.status` da CCD106 (R12, R16) |
| `users` | sim | — | `username`, `role`, `status`, `deleted_at` (R9, L3) |
| `profiles` | não | da CCD048 | `avatar_url` (R9) |
| `orders` | não | da CCD097 | `seller_id`, `status = COMPLETED` (R9, L4) |
| `groups`, `group_members` | sim | — | `access_type`, `status` (R10, L5) |
| — | — | `enable_unaccent_extension` | `CREATE EXTENSION IF NOT EXISTS unaccent` (depende do ADR novo) |

## Regras

- **Termo** (R4, depende da L1): `trim`, 2 a 100 caracteres; vazio não é enviado.
- **Comparação** (depende da L2): por trecho, sem diferenciar maiúsculas e acentos: cartas por `cards.name` dos anúncios
  ativos; usuários por `username`; grupos por `name`; álbuns por `title`.
- **Usuários** (depende da L3): `CUSTOMER` e `SELLER` com `status = ACTIVE`; "<n> vendas" só para `SELLER`, contando pedidos
  `COMPLETED` (depende da L4).
- **Grupos** (depende da L5): status diferente de `SUSPENDED`, não excluídos; `OPEN` = "PÚBLICO" e "Entrar no grupo",
  `CLOSED` = "REQUER APROVAÇÃO" e "Solicitar entrada".
- **Álbuns** (depende da L8): só `ACTIVE` e não excluídos; todos com o selo "ÁLBUM OFICIAL".
- **Cartas e anúncios** (R16): só carta `ACTIVE`, anúncio `ACTIVE` e sem `deleted_at`, pela regra da CCD078.
- **Grupos e álbuns** (depende da L12): na aba "Tudo", a seção "Grupos e álbuns" do Figma; as abas continuam separadas.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.

### `GET /api/v1/search` — R1, R3–R11, R15, R16

- **Acesso:** público.
- **Entrada:** `q` (obrigatório), `type` (`all` padrão, `cards`, `users`, `groups`, `albums`), `page`, `pageSize` (padrão
  8; ignorado em `all`).
- **Sucesso:** `200`

  ```json
  { "data": {
      "cards": [{ "...": "ListingCard da CCD078" }],
      "users": [{ "id": "uuid", "username": "tiago_trocas", "avatarUrl": null, "role": "SELLER", "salesCount": 12 }],
      "groups": [{ "id": "uuid", "name": "Pokémon BR", "membersCount": 340, "accessType": "OPEN" }],
      "albums": [{ "id": "uuid", "title": "Base Set", "category": { "id": "uuid", "name": "Pokémon" }, "totalCards": 102 }] },
    "meta": { "counts": { "cards": 842, "users": 2, "groups": 2, "albums": 2, "total": 848 },
              "page": 1, "pageSize": 8 } }
  ```

  Em `type=all`, cada grupo traz até 4 cartas, 2 usuários, 2 grupos e 2 álbuns; numa aba só, os outros grupos vêm vazios
  e as contagens continuam completas (para as abas).
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `q` ausente, só com espaços ou fora de 2 a 100 caracteres; `type` fora da lista | R4 |

### `GET /api/v1/albums/:id` — R12

- **Acesso:** público.
- **Sucesso:** `200` `{ "data": { "id", "title", "description", "coverUrl", "totalCards", "year", "category": { "id", "name" } } }`
- **Erros:** `400 VALIDATION_ERROR` (`id` não é uuid); `404 ALBUM_NOT_FOUND` (inexistente, excluído ou `INACTIVE`, depende
  da L8) — R12.

### `GET /api/v1/albums/:id/cards` — R12, R13

- **Acesso:** público.
- **Entrada:** `q` (nome ou número, depende da L9), `page`, `pageSize` (padrão 8, depende da L9).
- **Sucesso:** `200` `{ "data": [{ "id", "number", "name", "frontImageUrl" }], "meta": { page, pageSize, total, totalPages } }`,
  por `number`, só cartas `ACTIVE`.
- **Erros:** `404 ALBUM_NOT_FOUND` — R12.

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/migrations/<data>_enable_unaccent_extension/` | extensão `unaccent` (depende do ADR novo) | R3, R5 |
| `src/domains/search/search.validator.ts` + `.spec.ts` | `q` com `trim` e tamanho, `type`, paginação | R4 |
| `src/domains/search/search.service.ts` + `.spec.ts` | junta os quatro grupos pelos services de cada domínio, com limites por aba e contagens | R5–R11, R15 |
| `src/domains/search/search.controller.ts` · `search.routes.ts` · `search.swagger.ts` · `search.module.ts` | `GET /search` público | R1 |
| `src/domains/marketplace/listings/listings.service.ts` (CCD078) | `q` sem acentos e `countPublic(filters)` | R7, R16 |
| `src/domains/users/users.repository.ts` · `users.service.ts` | `searchPublic(q, page)` e `countSearchPublic(q)`, com `salesCount` (depende das L3, L4) | R9 |
| `src/domains/community/groups.repository.ts` · `groups.service.ts` (novos) | `searchPublic` com `membersCount` (`_count` de `group_members`) | R10 |
| `src/domains/catalog/public/catalog-public.{repository,service,controller,routes,swagger}.ts` (CCD078) | `searchAlbums`, `GET /albums/:id`, `GET /albums/:id/cards` | R11–R13 |
| `src/domains/catalog/catalog.errors.ts` | `AlbumNotFoundError` (`404 ALBUM_NOT_FOUND`), se ainda não existir | R12 |
| `src/routes.ts` | registra `searchModule` | R1 |
| `database/seeds/` | anúncios, usuários, grupos e álbuns com "charizard" no nome | CA1 |
| `tests/integration/search.spec.ts` · `catalog-public.spec.ts` | CA1–CA11 sem token | R1–R16 |

## Frontend — `apps/cromocard-frontend`

Feature nova `src/features/search/` no modelo de `src/features/users/` (ADR-040); a página do álbum fica em
`src/features/catalog/public/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/components/SearchBar/` · `app/layouts/SiteShell/SiteShell.tsx` · `siteMenu.ts` | sem as abas de escopo, texto de exemplo "Buscar cartas, álbuns, usuários e grupos", validação do termo e aviso no estilo do campo (depende da L1), frame `1112-2169` | R2–R4 |
| `src/routes/paths.ts` | `searchPathFor(term, tab = 'tudo')`, `catalogAlbum: '/catalogo/albuns/:id'` e `catalogAlbumPathFor(id)` | R3, R11 |
| `search.types.ts` · `search.api.ts` · `search.queries.ts` · `search.labels.ts` · `search.search-params.ts` | contrato, query por aba, `useInfiniteQuery` numa aba só, textos (resumo, selos, botões, vazio) | R5, R6, R10, R15 |
| `components/SearchHeader/` | "BUSCA", "Resultados para “<termo>”" e o resumo "<n> cartas, <n> usuários, <n> grupos e <n> álbuns", frame `1112-3970` | R5 |
| `components/SearchTabs/` | "Tudo (<n>)" … "Álbuns (<n>)" com `Tabs`, na URL (`tipo`), frame `1112-3970` (aba de um grupo só: L10) | R6 |
| `components/UserResultCard/` · `GroupResultCard/` · `AlbumResultCard/` | cartões de usuário ("Ver perfil"), grupo (selo e botão por `accessType`) e álbum ("ÁLBUM OFICIAL", "Ver álbum"), frame `1112-3970` | R9–R11 |
| `components/SearchSection/` | título do grupo e "Ver todas →" / "Ver todos →", que trocam a aba; "Grupos e álbuns" juntos em "Tudo" (depende da L12) | R6, R7, R9 |
| `pages/SearchPage/` | página com `ListingCard` (CCD078) no grupo Cartas, "Carregar mais" por aba e o vazio "0 resultados" / "Nenhum resultado encontrado para o termo pesquisado" (texto de apoio: L7), frames `1112-3970` e `1112-4356` | R5–R8, R15, R17 |
| `search.routes.ts` · `index.ts` · `src/features/catalog/catalog.routes.ts` | troca o `underConstructionRoute` de `/pesquisar` pela página; item "Pesquisar" sem termo mostra a página com o campo em foco (depende da L14) | R1, R3 |
| `src/features/catalog/public/pages/CatalogAlbumPage/` · `components/AlbumCardList/` | trilha "Início / Busca / <álbum>", "ÁLBUM OFICIAL • <categoria>", capa, dados, "Adicionar à minha coleção", "Favoritar", "Buscar carta no álbum", "Cartas do álbum (<n>)" com "Ver carta" e "Carregar mais cartas" (depende da L9), frame `1160-1845` | R12, R13 |
| `src/features/catalog/public/catalog-public.{api,queries}.ts` | `useCatalogAlbum`, `useAlbumCards` | R12 |
| `src/features/auth/components/LoginRequiredDialog/` + `index.ts` | "Entre para continuar" com "Continuar com Google" (`GoogleButton`), "Entrar com e-mail e senha" e "Criar conta grátis"; volta à página depois do login (depende da L6), frame `1160-2457` | R14 |

- **Rotas:** `/pesquisar` e `/catalogo/albuns/:id`, públicas.
- **Estados:** carregando e erro com `LoadingState` e `ErrorState` por página (depende da L15); vazio com `EmptyState`.
- **Componentes reaproveitados de `src/components/`:** `SearchBar`, `Tabs`, `Badge`, `Button`, `Modal`, `EmptyState`,
  `LoadingState`, `ErrorState`, `Icon`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "charizard" traz contagens e os quatro grupos | `search.service.spec.ts` · `tests/integration/search.spec.ts` · `SearchPage.spec.tsx` |
| CA2 | aba "Usuários" e "Ver todos →" mostram só usuários | `SearchPage.spec.tsx` |
| CA3, CA4 | carta abre o perfil da carta; "Ver perfil" abre o perfil público | `SearchPage.spec.tsx` · `UserResultCard.spec.tsx` |
| CA5 | "Ver álbum" abre a página com capa, dados e cartas; "Ver carta" abre a carta | integração · `CatalogAlbumPage.spec.tsx` |
| CA6 | visitante em "Favoritar" e "Adicionar à minha coleção" vê o modal e nenhuma chamada de escrita sai | `CatalogAlbumPage.spec.tsx` · `LoginRequiredDialog.spec.tsx` |
| CA7 | termo sem resultado mostra "0 resultados" e a mensagem | integração · `SearchPage.spec.tsx` |
| CA8 | sem token `200`; logado, menu do cliente com "Pesquisar" destacado | integração · `SiteShell.spec.tsx` |
| CA9 | termo de 1 caractere não é enviado e a API responde `400` | `search.validator.spec.ts` · `SearchBar.spec.tsx` |
| CA10 | anúncio pausado e carta em rascunho não aparecem | integração |
| CA11 | grupo fechado com "REQUER APROVAÇÃO" e "Solicitar entrada"; aberto com "PÚBLICO" e "Entrar no grupo" | `GroupResultCard.spec.tsx` |
| CA12–CA16 | print em 1280 px igual aos frames `1112-3970`, `1112-4356`, `1160-2457` e `1160-1845`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Dependências e riscos

- A busca sem acentos precisa da extensão `unaccent` no PostgreSQL de todos os ambientes (local, CI, homologação): é
  decisão de arquitetura e pede um ADR novo `Proposto` (T1) antes da migration.
- A página do álbum fica em `/catalogo/albuns/:id` porque `/albuns` já é a Minha Coleção do cliente (CCD008).

## Decisões técnicas

- **ADR novo `Proposto` — busca textual sem acentos com `unaccent`:** comparação por `unaccent(lower(coluna)) LIKE
  unaccent(lower('%termo%'))` em SQL (o `mode: 'insensitive'` do Prisma só ignora maiúsculas). Vale também para a CCD024 e a
  CCD078 (L1). Sem o ADR aceito, a busca ignora só maiúsculas.
- A busca global fica num domínio próprio `src/domains/search/` (componente "Acesso Público" do C4), que só lê pelos
  services de `marketplace`, `users`, `community` e `catalog` (ADR-001); o escopo de commit `search` precisa entrar na lista
  da `.claude/rules/git.md` (ou usar `catalog`).
- Um pedido só devolve contagens e itens, para as abas mostrarem os números sem quatro chamadas.
- O `LoginRequiredDialog` fica na feature `auth` e sai pelo `index.ts`, porque a CCD030 e a CCD039 usam o mesmo modal.
