# Plano — CCD008 Listar Álbum

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L11 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O item "Álbuns" do menu abre "Meus álbuns" (`/albuns`), que troca a página "em construção" de hoje. A página chama
`GET /api/v1/collections/me/albums` (todos os álbuns ativos da coleção, sem paginação) e, para os indicadores do topo,
o `GET /api/v1/collections/me/summary` da CCD007, que ganha o campo `ownedLast7Days`. Cada cartão leva ao detalhe do
álbum (CCD013).

## Dependências

- **CCD007**: domínio `collection`, as tabelas `collections`, `user_albums`, `collection_cards` e `price_history`, o
  repository dos preços (`collection-prices.repository.ts`), o resumo e o seed da coleção de exemplo.
- **CCD013**: a rota do detalhe `/albuns/:albumId`. Esta story já cria o caminho em `paths.ts` (`albumDetailPathFor`);
  enquanto a CCD013 não entra, a rota mostra a página "em construção".
- **CCD010 / CCD011 / CCD012**: os botões "Solicitar álbum", o menu "⋮" e "Compartilhar coleção" do mesmo frame entram
  com essas stories.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `user_albums`, `collection_cards`, `price_history` | da CCD007 | — | só leitura |
| `albums`, `categories` | sim | — | só leitura: `title`, `cover_url`, `publisher`, `year`, `total_cards`, `status`, `category.name` |

Nenhuma coluna nova. Os selos e a série do rodapé do cartão não têm coluna no DBML e saem do Figma (depende da L6).

## Regras

- **O que entra** (R3, depende da L3): `user_albums` sem `deleted_at`, de `albums` sem `deleted_at`; álbum `INACTIVE`
  continua. Favorito de `favorites` fora da coleção não entra.
- **Valor estimado do álbum** (R5): soma, por carta do álbum com status `OWNED` ou `DUPLICATE`, da média de
  `price_history.price` dos últimos 30 dias; carta sem preço vale zero (mesma regra da CCD007, L5).
- **Contadores do cartão** (depende da L6): possuídas = `OWNED` + `DUPLICATE`; faltantes = `total_cards` − possuídas;
  repetidas ("a mais") = soma de `quantity − 1`.
- **Ordem** (depende da L8, L10): `recent` (`user_albums.created_at` desc, padrão), `progress` (`progress_percentage`
  desc), `name` (`albums.title` asc).
- **Sem paginação** (depende da L7): a lista volta inteira.
- **"+<n> esta semana"** (depende da L5): cartas com status `OWNED` ou `DUPLICATE` e `collection_cards.updated_at` nos
  últimos 7 dias.

## Contrato da API

Convenções do ADR-011 (ver CCD007). Acesso: `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L1).

### `GET /api/v1/collections/me/albums` — R1, R3–R6

- **Entrada (query):** `sort` (`recent` · `progress` · `name`, padrão `recent`)
- **Sucesso:** `200`

  ```json
  { "data": [ { "albumId": "uuid", "title": "Copa do Mundo 2026", "coverUrl": "https://…",
      "publisher": "Panini", "year": 2026, "category": { "id": "uuid", "name": "Futebol / Esportes" },
      "totalCards": 54, "ownedCards": 43, "missingCards": 11, "duplicateUnits": 6,
      "progressPercentage": 79.63, "estimatedValue": "820.00", "isFavorite": false,
      "addedAt": "2026-10-02T12:00:00Z" } ] }
  ```

  Sem álbuns: `{ "data": [] }` (R7).

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `sort` fora da lista | R3 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L1) | R1 |

### `GET /api/v1/collections/me/summary` (CCD007) — acrescenta `ownedLast7Days`

- **Sucesso:** `200`, `data` ganha `"ownedLast7Days": 12` (depende da L5). Os outros campos dos indicadores ("Álbuns",
  "Cartas que possuo", "Cartas faltantes", "Repetidas") já vêm da CCD007.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/` (criado na CCD007).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-albums.repository.ts` | álbuns ativos da coleção com categoria, contadores e ordem | R1, R3, R4 |
| `collection-prices.repository.ts` (CCD007) | valor estimado agrupado por álbum | R5 |
| `collection-albums.service.ts` + `.spec.ts` | lista com valor estimado e contadores | R3–R5 |
| `collection.repository.ts` · `collection.service.ts` (CCD007) | `ownedLast7Days` no resumo | R3 (depende da L5) |
| `collection.validator.ts` · `collection.controller.ts` · `collection.routes.ts` · `collection.swagger.ts` · `collection.module.ts` | query `sort` e a rota `GET /me/albums` | R1 |
| `tests/integration/collection-albums.spec.ts` | rota de ponta a ponta | CA1–CA3, CA6 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/` (criada na CCD007).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection.types.ts` · `collection.api.ts` · `collection.queries.ts` · `collection.labels.ts` | `CollectionAlbum`, `listMyAlbums(sort)`, `useMyAlbums`, rótulos das ordens | R3–R5 |
| `components/AlbumsIndicators/` | "Álbuns", "Cartas que possuo" com "+<n> esta semana", "Cartas faltantes", "Repetidas", com `KpiCard` (depende da L5); frames `1160-23080` e `1160-29088` | R9 |
| `components/CollectionAlbumCard/` | capa, título, categoria, editora e ano, "<n> de <total> cartas", barra e "<n>% concluído", faltantes, repetidas "a mais", valor estimado e "Abrir álbum" (depende da L6, L9: sem a lupa); frame `1160-23080` | R4–R6 |
| `components/MyAlbumsEmptyState/` | "Você ainda não tem álbuns", o texto do Figma e o botão "Ver catálogo" para Pesquisar (depende da L4); frame `1160-29088` | R7 |
| `pages/MyAlbumsPage/` | título "Meus álbuns", "Ordenar por" com `Select` (depende da L8), grade de cartões, `LoadingState` e `ErrorState`; frames `1160-23080` e `1160-29088` | R2, R3, R8, R9 |
| `collection.routes.ts` | troca o `underConstructionRoute` de `/albuns` pela `MyAlbumsPage` (lazy) | R2 |
| `src/routes/paths.ts` | `albumDetail: '/albuns/:albumId'` e `albumDetailPathFor(id)` | R6 |

- **Rotas:** `/albuns` dentro do `RequireAuth` + `CustomerLayout`; o item "Álbuns" do menu já aponta para ele (L11).
- **Estados:** `LoadingState`, `ErrorState` e o vazio `MyAlbumsEmptyState` (R7, R8).
- **Componentes reaproveitados:** `KpiCard`, `Select`, `Button`, `Badge`, `EmptyState`, `LoadingState`, `ErrorState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 4 álbuns com capa, título e progresso | `collection-albums.service.spec.ts` · integração · `MyAlbumsPage.spec.tsx` |
| CA2 | álbum removido não aparece | `collection-albums.service.spec.ts` · integração |
| CA3 | valor estimado de R$ 150,00 com duas cartas | `collection-albums.service.spec.ts` · integração |
| CA4 | "Abrir álbum" navega para `/albuns/:albumId` | `MyAlbumsPage.spec.tsx` |
| CA5 | vazio com o botão para o catálogo | `MyAlbumsPage.spec.tsx` |
| CA6 | `401`, `403` e isolamento entre clientes | integração |
| CA7 | carregando e erro | `MyAlbumsPage.spec.tsx` |
| CA8, CA9 | prints em 1280 px iguais a `1160-23080` e `1160-29088`; 375, 768 e 1024 px sem quebra | revisão visual com o seed |

## Decisões técnicas

- A lista não pagina (L7) e já traz os contadores de cada álbum, numa consulta agrupada por álbum: a busca da CCD009
  filtra essa mesma lista no navegador.
- Os indicadores do topo reaproveitam o resumo da CCD007 em vez de um endpoint novo.
