# Plano — CCD055 Favoritar Álbum

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L7 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Esta story cria a base de favoritos que a CCD056 (carta) e a CCD057 (grupo) reaproveitam: a tabela `favorites`, o módulo
`/favorites` com um alvo por tipo e o botão `FavoriteButton`. O botão "Favoritar" da página pública do álbum chama
`PUT /api/v1/favorites/albums/:albumId` (favoritar, idempotente) ou `DELETE` (remover); o visitante vê o modal
"Entre para continuar". "Meus Favoritos" > "Álbuns" lista os favoritos por `GET /api/v1/favorites?type=ALBUM`.

## Dependências

- **CCD053**: a página de Notificações & Favoritos, com a aba "Meus Favoritos".
- **Página pública do álbum** (frame `1160-1845`, CCD008 / EA-002-01): onde o botão é montado. Se ela ainda não existir,
  o botão entra quando ela entrar (a story do botão no detalhe da coleção depende da L4).
- **CCD030**: o modal `LoginToContinueModal` ("Entre para continuar", frame `1112-5461`), que volta à página de origem.
- **PR de docs no DBML e ADR** com o índice único parcial de `favorites` (L2) antes da migration.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `favorites` | não | `create_favorites_table` | copiada do DBML, com o enum `favorite_type` (`ALBUM`, `CARD`, `GROUP`) e as FKs para `users`, `albums`, `cards`, `groups` (R3) |
| `favorites` | — | na mesma migration, em SQL | `CHECK` de um alvo só (ADR-032) e índices únicos parciais `(user_id, album_id)`, `(user_id, card_id)`, `(user_id, group_id)` onde `deleted_at` é nulo (R6, depende da L2) |
| `albums` | sim | — | leitura de `status` e `deleted_at` (R7) |

`user_albums.is_favorite` não é usado: vale `favorites` (depende da L1).

## Regras

- **Favoritar** (R3, R6): se já existe favorito ativo do usuário para o alvo, devolve o mesmo (`200`); senão cria a
  linha. Remover e favoritar de novo cria outra linha (depende da L2). A corrida entre duas chamadas cai no índice único
  parcial e a segunda devolve o favorito existente (CA3).
- **Remover** (R5): `deleted_at = now()` no favorito ativo; sem favorito ativo, `204` sem gravar nada.
- **Alvo álbum** (R7): inexistente ou excluído → `404 ALBUM_NOT_FOUND`; `status = INACTIVE` → `422 ALBUM_UNAVAILABLE`.
- **Lista** (R8): favoritos ativos do usuário do tipo pedido, do mais recente ao mais antigo, 20 por página; álbum
  excluído depois de favoritado não aparece.
- **Alvos por tipo**: `favorite-targets.ts` tem um objeto por tipo (`findAvailable`, `toItem`); esta story cria o de
  álbum, a CCD056 e a CCD057 acrescentam os seus (Strategy).
- Busca, ordenação, contadores por aba (L6), progresso e avisos no cartão (L5) e "Desfazer" (L3) ficam fora até a decisão.

## Contrato da API

Convenções do ADR-011. `:type` é `albums` nesta story (`cards` na CCD056, `groups` na CCD057).

```ts
FavoriteState = { type: 'ALBUM', targetId, isFavorite: boolean, favoritedAt: string | null }
FavoriteAlbumItem = { id, favoritedAt, album: { id, title, publisher, totalCards, coverUrl } }
```

### `GET /api/v1/favorites/:type/:targetId` — R4

- **Acesso:** `authenticate`
- **Sucesso:** `200` `{ data: FavoriteState }`
- **Erros:** `400 VALIDATION_ERROR`, `401`

### `PUT /api/v1/favorites/:type/:targetId` — R1, R3, R6, R7

- **Acesso:** `authenticate`
- **Sucesso:** `200` `{ data: FavoriteState }` com `isFavorite: true`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | tipo desconhecido ou id que não é uuid | R3 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 404 | `ALBUM_NOT_FOUND` | álbum inexistente ou excluído | R7 |
  | 422 | `ALBUM_UNAVAILABLE` | `status = INACTIVE` | R7 |

### `DELETE /api/v1/favorites/:type/:targetId` — R1, R5

- **Acesso:** `authenticate` · **Sucesso:** `204` · **Erros:** `400`, `401`

### `GET /api/v1/favorites?type=ALBUM` — R8

- **Acesso:** `authenticate` · **Entrada:** `type`, `page`, `pageSize`
- **Sucesso:** `200` `{ data: FavoriteAlbumItem[], meta: { page, pageSize, total } }`
- **Erros:** `400 VALIDATION_ERROR`, `401`

## Backend — `apps/cromocard-backend`

Domínio `src/domains/notifications/favorites/`, no modelo de `src/domains/users/` (ADR-004), registrado em `src/routes.ts`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration | enum `FavoriteType`, modelo `Favorite`, `CHECK` e índices parciais | R3, R6 |
| `favorites.validator.ts` | `type` (`albums`/`cards`/`groups` → enum), `targetId`, lista | R3, R8 |
| `favorites.errors.ts` | `AlbumUnavailableError` (`422`); reaproveita o `404` do catálogo | R7 |
| `favorite-targets.ts` | alvo de álbum: disponibilidade e item da lista | R7, R8 |
| `favorites.repository.ts` | `findActive`, `create` (captura a violação do índice único), `softDelete`, `listByUser` | R3, R5, R6, R8 |
| `favorites.service.ts` + `.spec.ts` | estado, favoritar, remover, listar | R3–R8 |
| `favorites.controller.ts` · `.routes.ts` · `.swagger.ts` · `favorites.module.ts` | rotas em `/favorites` | R1 |
| `src/routes.ts` | registra o `favoritesModule` | R1 |
| `database/seeds/` | favoritos de exemplo do cliente do seed | R8 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/notifications/favorites/`, no modelo de `src/features/users/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `favorites.types.ts` · `.api.ts` · `.queries.ts` · `.labels.ts` | contrato, chamadas, queries com atualização otimista e os textos de confirmação e indisponível (dependem da L3) | R3–R8 |
| `components/FavoriteButton/` | "Favoritar" nos estados normal, favoritado e carregando, com a confirmação por `Toast`; sem login abre o `LoginToContinueModal`; frame `1160-1845` | R1, R2, R4, R5, R7, R9 |
| `src/features/catalog/components/LoginToContinueModal/` (da CCD030; se ela ainda não entrou, esta story o cria) | modal "Entre para continuar" com "Continuar com Google", "Entrar com e-mail e senha" e "Criar conta grátis", voltando à página de origem pelo `loginRedirect`, frame `1112-5461` | R1 |
| `components/FavoriteAlbumsList/` · `FavoriteAlbumCard/` | aba "Álbuns" com capa, título, "Abrir álbum" e ♥ para remover, frame `675-10770`; estados `LoadingState`, `ErrorState` e `EmptyState` (texto depende da L7) | R5, R8, R9 |
| `pages/FavoritesPage/` · `notifications.routes.ts` | aba "Meus Favoritos" da página da CCD053, com as subabas Cartas, Álbuns e Grupos | R8 |
| `src/routes/paths.ts` | `favorites: '/favoritos'` e `favoritesPathFor(tipo)` (`?tipo=albuns`) | R8 |
| página pública do álbum | monta o `FavoriteButton` no lugar do frame | R2 |

- **Rotas:** `/favoritos` no `CustomerLayout` com `RequireAuth`.
- **Componentes reaproveitados:** `Button`, `Icon`, `Toast`, `Tabs`, `Modal`, `Pagination`, `LoadingState`, `ErrorState`,
  `EmptyState`; `GoogleButton` de `features/auth`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | grava `ALBUM` com só o `album_id`; botão favoritado e confirmação | `favorites.service.spec.ts` · `tests/integration/favorites.spec.ts` · `FavoriteButton.spec.tsx` |
| CA2 | `deleted_at` preenchido, botão normal, álbum sai da lista | service · integração · `FavoriteAlbumsList.spec.tsx` |
| CA3 | duas chamadas simultâneas, um favorito ativo | integração (`Promise.all`) |
| CA4 | `INACTIVE` → `422`; excluído → `404`; nada gravado; aviso na tela | service · integração · `FavoriteButton.spec.tsx` |
| CA5 | visitante vê "Entre para continuar"; `401` sem token | `FavoriteButton.spec.tsx` · `LoginToContinueModal.spec.tsx` · integração |
| CA6, CA7 | 2 álbuns na lista, cada um abre o álbum; carregando e erro | `FavoriteAlbumsList.spec.tsx` |
| CA8, CA9 | print em 1280 px igual aos frames `1160-1845` e `675-10770`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- Um módulo só para os três tipos, com o alvo escolhido por `type` (Strategy em `favorite-targets.ts`): as três stories
  mudam só o alvo, sem rotas paralelas.
- `PUT` para favoritar, porque é idempotente; `DELETE` para remover.
- A garantia de um favorito ativo por alvo vem do índice único parcial, e não de uma leitura antes da escrita, que perde a
  corrida (depende da L2, com ADR novo `Proposto` e o DBML atualizado).
