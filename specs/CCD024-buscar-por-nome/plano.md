# Plano — CCD024 Buscar por Nome (agrupa CCD025–CCD029)

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L12 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Pela proposta da L1, a "tela de pesquisa de cartas" é a aba "Cartas" da página Pesquisar (CCD002), com os filtros de
coleção, categoria, raridade e idioma acima da lista. A aba chama `GET /api/v1/cards`, a pesquisa pública das cartas do
catálogo (depende da L3), com `q` para nome ou número num campo só e os filtros combinados (depende da L6), 8 por vez com
"Carregar mais" (depende da L8). As opções vêm de `GET /api/v1/albums` (coleção, depende da L4),
`GET /api/v1/categories/default` (CCD078), `GET /api/v1/rarities` e `GET /api/v1/languages`. Selecionar uma carta abre o
perfil da carta (CCD030). Pela proposta da L2, a pesquisa fica aberta, como a busca global.

## Dependências

- **CCD002:** a página Pesquisar, as abas, o modelo de `search.search-params.ts` e o ADR da busca sem acentos (`unaccent`).
- **CCD078:** o módulo `catalog/public/`, `GET /categories/default` e o filtro de categoria com subcategorias (mesma CTE).
- **CCD106:** `cards.status`, para só mostrar cartas `ACTIVE` (R12).
- **CCD030:** perfil da carta (`/cartas/:id`), destino do R10.
- **Frame dos filtros:** não existe (L1); o Gabriel desenha antes da tarefa de fidelidade.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `cards` | sim, sem `status` | `add_status_and_release_year_to_cards_table` (da CCD106) | `name`, `number`, `album_id`, `category_id`, `rarity_id`, `language_id`, `front_image_url` |
| `albums`, `categories`, `rarities`, `languages` | sim | — | só leitura |

Nenhuma coluna nova.

## Regras

- **Termo** (R3, R4, depende das L6 e L7): `q` por trecho em `cards.name`, sem diferenciar maiúsculas e acentos; se `q` for
  só dígitos, também `ltrim(number, '0') = ltrim(q, '0')` (o "10" acha o Nº 010).
- **Coleção** (R5, depende da L4): `albumId` = `cards.album_id`.
- **Categoria** (R6, depende da L5): a categoria padrão escolhida e as subcategorias, pela carta (`cards.category_id`) ou pelo
  álbum (`albums.category_id`), com a CTE da CCD078.
- **Raridade e idioma** (R7, R8): `rarityId`, `languageId`; opções por `sort_order` e por `name` (depende da L11).
- **Filtros combinados** (depende da L6): todos com E.
- **Só ativas** (R12): carta `ACTIVE`, sem `deleted_at`, de álbum não excluído.
- **Ordem da lista:** álbum (`title`) e `number`, para a paginação ser estável.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.

### `GET /api/v1/cards` — R1, R3–R5, R7–R9, R12, R13

- **Acesso:** público pela proposta da L2 (o caso de uso pede login: se a L2 decidir assim, entra `authenticate` e sem
  token a resposta é `401 UNAUTHENTICATED`, R1).
- **Entrada:** `q` (1 a 100 caracteres), `albumId`, `categoryId`, `rarityId`, `languageId` (uuid), `page`, `pageSize`
  (padrão 8, máximo 100).
- **Sucesso:** `200`

  ```json
  { "data": [{ "id": "uuid", "name": "Lionel Messi", "number": "10", "frontImageUrl": "https://…",
      "album": { "id": "uuid", "title": "Copa do Mundo 2026" }, "rarity": { "id": "uuid", "name": "Lendária" } }],
    "meta": { "page": 1, "pageSize": 8, "total": 2, "totalPages": 1 } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | filtro que não é uuid, `q` com mais de 100 caracteres, paginação inválida | R13 |
  | 401 | `UNAUTHENTICATED` | sem token, só se a L2 decidir pelo login | R1 |

### `GET /api/v1/albums` — R5

- **Acesso:** público. **Entrada:** `q` (trecho do título, opcional), `page`, `pageSize` (padrão 20).
- **Sucesso:** `200` `{ "data": [{ "id", "title" }], "meta": {…} }`, só `ACTIVE` e não excluídos, por `title`.

### `GET /api/v1/rarities` · `GET /api/v1/languages` — R7, R8

- **Acesso:** público.
- **Sucesso:** `200` `{ "data": [{ "id", "name" }] }`, raridades por `sort_order` e idiomas por `name` (L11), só não
  excluídos. Reaproveitam o `catalog-references.repository.ts` que já atende `/admin/catalog/rarities` e `/languages`.

## Backend — `apps/cromocard-backend`

Módulo público do catálogo `src/domains/catalog/public/` (da CCD078).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `catalog-public.validator.ts` + `.spec.ts` | `searchCardsQuery` e `listAlbumsQuery` (Zod) | R13 |
| `catalog-public.repository.ts` | `searchCards(filters)` com termo, número, filtros e CTE de categoria; `listAlbums(q)` | R3–R9, R12 |
| `catalog-public.service.ts` + `.spec.ts` | monta os filtros e devolve `{ items, meta }`; raridades e idiomas pelo `catalog-references.repository.ts` | R3–R9, R12 |
| `catalog-public.controller.ts` · `catalog-public.routes.ts` · `catalog-public.swagger.ts` | `GET /cards`, `GET /albums`, `GET /rarities`, `GET /languages` | R1, R13 |
| `database/seeds/data/cards.json` | "Lionel Messi" e "Lionel Scaloni", a Nº 10 da "Copa do Mundo 2026", uma em rascunho e uma excluída | CA1, CA2, CA10 |
| `tests/integration/catalog-public.spec.ts` | CA1–CA6, CA8–CA10 | R1, R3–R13 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/catalog/public/catalog-public.{types,api,queries}.ts` + `index.ts` | `useCatalogCardSearch` (infinita), `useCatalogAlbums`, `useRarities`, `useLanguages` | R3–R9 |
| `src/features/search/search.search-params.ts` (CCD002) | `albumId`, `categoryId`, `rarityId`, `languageId` na URL da aba Cartas | R5–R8 |
| `src/features/catalog/public/components/CardSearchFilters/` | "Coleção", "Categoria", "Raridade", "Idioma" com o `Select`, no estilo dos filtros do `1160-23696` até o frame da L1 | R2, R5–R8, R14 |
| `src/features/catalog/public/components/CatalogCardResult/` | imagem, nome, Nº, coleção e raridade (depende da L8), link para `/cartas/:id` (CCD030) | R9, R10 |
| `src/features/search/pages/SearchPage/` (CCD002) | na aba "Cartas", os filtros e a lista do catálogo; vazio "Nenhuma carta encontrada com os termos informados" (depende da L9), frames `1112-3970` e `1112-4356` | R2, R9, R11, R14 |

- **Rotas:** nenhuma nova (`/pesquisar?tipo=cartas`).
- **Estados:** `LoadingState` e `ErrorState` (depende da L12); vazio com `EmptyState`.
- **Componentes reaproveitados:** `Select`, `EmptyState`, `LoadingState`, `ErrorState`, `ActiveFilters` (CCD078).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "lionel" traz Messi e Scaloni | `catalog-public.service.spec.ts` · integração · `SearchPage.spec.tsx` |
| CA2 | "10" traz a Nº 10 (também "010") | integração |
| CA3 | coleção filtra só as cartas do álbum | integração · `CardSearchFilters.spec.tsx` |
| CA4 | categorias na ordem da CCD104 e Futebol com subcategorias | integração · `CardSearchFilters.spec.tsx` |
| CA5, CA6 | raridade e idioma filtram | integração |
| CA7 | a carta abre `/cartas/:id` | `CatalogCardResult.spec.tsx` |
| CA8 | sem correspondência, a mensagem do R11 | `SearchPage.spec.tsx` |
| CA9 | conforme a L2: `200` sem token (proposta) ou `401` | integração |
| CA10 | rascunho e excluída não aparecem | integração |
| CA11–CA14 | print em 1280 px igual aos frames `1112-3970` e `1112-4356` e ao frame dos filtros (L1); sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Dependências e riscos

- **L1 e L3 mudam a aba "Cartas" da CCD002:** lá ela lista anúncios; aqui, cartas do catálogo. Pelas propostas, a aba
  "Cartas" passa a ser do catálogo, e o grupo "Cartas" de "Tudo" continua com anúncios (depende da L1, da L3 e da L13 da
  CCD002). O PO precisa confirmar antes do código.
- O frame dos filtros não existe (L1): o R14 vale quando ele for desenhado.
- A sobreposição com CCD021 e CCD037 (L10) pode juntar as três telas; o endpoint `GET /cards` serve às três.

## Decisões técnicas

- A pesquisa é pública e mora no módulo `catalog/public/`, ao lado de `/albums` e `/categories/default`, separada do
  `/admin/catalog/cards` do BackOffice.
- O número é comparado ignorando zeros à esquerda em SQL (`ltrim`), porque `cards.number` é `varchar(20)`.
