# Plano — CCD019 Visualizar Progresso

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L9 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O cálculo do progresso fica numa função pura do domínio `collection` (cartas possuídas sobre `albums.total_cards`). A
service `collectionProgressService.recalculate(collectionId, albumId)` grava o resultado em
`user_albums.progress_percentage` e é chamada por toda marcação (CCD014–018, CCD022, CCD035, CCD036). A API devolve o
progresso em `GET /collections/me/albums/:albumId/progress` e no mesmo formato dentro da lista de "Meus álbuns" (CCD008)
e do álbum em destaque do Início (CCD007). No frontend, um componente `AlbumProgress` com três variantes (cabeçalho do
detalhe, cartão de "Meus álbuns" e destaque do Início) mostra a barra e os textos, e as mutações de marcação invalidam a
query do progresso, o que atualiza a tela sem recarregar.

## Dependências

- **CCD007** — cria o domínio `src/domains/collection/` (`collection.module.ts`), as tabelas `collections`, `user_albums` e
  `collection_cards` (enum `collection_card_status`) e o `collectionsService.getOrCreateForUser` (L2 da CCD007). O prefixo
  `/api/v1/collections/me` segue o plano dela; se ela usar outro, os caminhos daqui acompanham.
- **CCD008** (lista "Meus álbuns", frame `1160-23080`) e **CCD013** (detalhe do álbum, frame `1160-23696`) — donas das
  páginas onde o progresso aparece; esta story entrega o componente e o campo `progress`, e as páginas o mostram.
- **CCD014–CCD018, CCD022, CCD035, CCD036** — chamam `recalculate` depois de gravar a marcação (R8). Quem entrar antes desta
  story chama a função quando ela existir; esta story cobre o recálculo com teste próprio.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `user_albums` | não | da CCD007 | grava `progress_percentage` (`decimal(5,2)`) a cada recálculo (R2, R8) |
| `collection_cards` | não | da CCD007 | só leitura: conta as cartas `OWNED` e `DUPLICATE` não excluídas, uma vez por carta (depende da L1) |
| `albums` | sim (`totalCards`) | — | total do álbum = `total_cards`; 0 = indisponível (R6, depende da L2) |
| `cards` | sim | — | liga `collection_cards.card_id` ao `album_id`; `cards.status` (CCD106) não muda a contagem |

Nenhuma coluna nova.

## Regras

- **Possuídas** (R2): cartas distintas do álbum com `status` `OWNED` ou `DUPLICATE` e `deleted_at` nulo, qualquer que seja a
  quantidade (depende da L1).
- **Total** (R2, R6): `albums.total_cards`; com 0, `available: false` e nenhum percentual (depende da L2).
- **Percentual** (R2, R7): `floor(owned / total * 100)`, 100 só com todas as cartas (depende da L3); gravado com duas casas.
- **Faltam** (R3): `total − owned`, nunca negativo (depende da L4).
- **Quem vê** (R1): `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` (depende da L9). Álbum fora da coleção (sem `user_albums`
  ativo do cliente): `404`.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.

```ts
AlbumProgress = { ownedCards: number, totalCards: number, missingCards: number,
  percentage: number | null, available: boolean }   // available = false quando totalCards = 0 (R6)
```

### `GET /api/v1/collections/me/albums/:albumId/progress` — R1–R7

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L9)
- **Entrada:** `albumId` (uuid) no caminho.
- **Sucesso:** `200`

  ```json
  { "data": { "albumId": "uuid", "title": "Copa do Mundo 2026", "ownedCards": 44, "totalCards": 54,
              "missingCards": 10, "percentage": 81, "available": true } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `albumId` não é uuid | R1 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L9) | R1 |
  | 404 | `ALBUM_NOT_IN_COLLECTION` | álbum inexistente, excluído ou fora da coleção do cliente | R1 |

### Lista de "Meus álbuns" (CCD008) e álbum em destaque (CCD007) — R4, R5

Cada álbum da resposta dessas rotas ganha `progress: AlbumProgress`, calculado pela mesma função. Nenhuma rota nova.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/` (da CCD007), no modelo de `src/domains/users/` (ADR-004).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-progress.ts` + `.spec.ts` | função pura `calculateAlbumProgress({ ownedCards, totalCards })` com as Regras | R2, R3, R6, R7 |
| `collection-progress.repository.ts` | `countOwnedByAlbum(collectionId, albumIds[])` (um `groupBy` para a lista), `findUserAlbum`, `updateProgress` | R2, R8 |
| `collection-progress.service.ts` + `.spec.ts` | `getProgress(userId, albumId)` e `recalculate(collectionId, albumId)`, exportados pelo `collection.module.ts` | R1, R2, R8 |
| `collection.validator.ts` · `collection.errors.ts` | `albumIdParams`; `AlbumNotInCollectionError` (`404 ALBUM_NOT_IN_COLLECTION`) | R1 |
| `collection.controller.ts` · `collection.routes.ts` · `collection.swagger.ts` | rota do progresso, documentada no `/docs` | R1 |
| serviços da lista de álbuns (CCD008) e do resumo (CCD007) | acrescentam `progress` a cada álbum, numa consulta só por página | R4, R5 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`, no modelo de `src/features/users/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection.types.ts` · `collection.api.ts` · `collection.queries.ts` | `AlbumProgress`, `getAlbumProgress`, `collectionKeys.albumProgress(albumId)` | R1, R2 |
| `collection.labels.ts` · `collection.format.ts` | "Progresso do Álbum: <n>% Concluído", "<x> de <total> cartas colecionadas (Faltam apenas <y> cartas)", "<x> de <total> cartas", "<n>% concluído", "<x> de <total> cartas • <n>% completo", "Progresso indisponível" | R3–R7 |
| `components/AlbumProgress/` | barra e textos, variantes `header` (frame `1160-23696`), `card` (frame `1160-23080`) e `highlight` (frame `1122-17812`); com `available: false`, só "Progresso indisponível" no estilo da tela (L8) | R3–R7, R9 |
| `pages/AlbumDetailPage/` (CCD013) | cabeçalho com `AlbumProgress variant="header"` — frame `1160-23696` | R3, R9 |
| `components/AlbumCard/` (CCD008) | `AlbumProgress variant="card"` em cada cartão — frame `1160-23080` | R4, R9 |
| bloco "Álbum em destaque" do Início (CCD007) | `AlbumProgress variant="highlight"` — frame `1122-17812` | R5, R9 |
| `collection.queries.ts` (mutações das marcações) | `onSuccess` invalida `albumProgress(albumId)` e a lista de álbuns | R8 |

- **Rotas:** nenhuma nova; as páginas são da CCD007, CCD008 e CCD013, com `RequireAuth` no `CustomerLayout`.
- **Estados:** carregando e erro com `LoadingState` e `ErrorState`; indisponível dentro do `AlbumProgress`.
- **Componentes reaproveitados de `src/components/`:** `LoadingState`, `ErrorState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 44 de 54: 81% (depende da L3), "44 de 54 cartas colecionadas (Faltam apenas 10 cartas)" | `collection-progress.spec.ts` · `AlbumProgress.spec.tsx` |
| CA2 | cada cartão de "Meus álbuns" com o progresso do próprio álbum | integração `tests/integration/collection-progress.spec.ts` · `AlbumProgress.spec.tsx` |
| CA3 | destaque com "<x> de <total> cartas • <n>% completo" | `AlbumProgress.spec.tsx` |
| CA4 | `total_cards` = 0: `available: false`; tela com "Progresso indisponível" sem barra | `collection-progress.spec.ts` · `AlbumProgress.spec.tsx` |
| CA5 | sem possuídas: 0% e "0 de 54" | `collection-progress.spec.ts` · `AlbumProgress.spec.tsx` |
| CA6 | marcar uma carta: `recalculate` grava 45/54; a tela muda sem recarregar | `collection-progress.service.spec.ts` · `AlbumDetailPage.spec.tsx` |
| CA7 | sem token `401`; álbum fora da coleção `404` | integração |
| CA8–CA10 | print em 1280 px igual aos frames `1160-23696`, `1160-23080` e `1122-17812`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- O progresso é calculado por uma função pura e gravado em `user_albums.progress_percentage` a cada marcação: a lista de
  álbuns e o resumo do Início (CCD007) leem a coluna sem recontar, e a rota do progresso devolve também os números
  absolutos, que a coluna não guarda.
- "Sem recarregar" (R8) é invalidação da query no TanStack Query (ADR-041) depois da mutação; não precisa de Socket.IO,
  porque quem marca é o próprio cliente na mesma tela.
- Os indicadores "NO ÁLBUM", "FALTANTES" e "REPETIDAS" (L5) e o selo "QUASE COMPLETO!" (L6) não entram: se o PO aceitar,
  a spec ganha requisitos e o plano, campos novos no `AlbumProgress`.
