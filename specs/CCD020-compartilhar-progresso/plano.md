# Plano — CCD020 Compartilhar Progresso

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L11 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O botão "Compartilhar progresso" do cabeçalho do detalhe do álbum chama `GET /collections/me/albums/:albumId/share`, que
devolve o cartão (título, `@username`, progresso da CCD019 e os totais) e o link público. Com o álbum em 0%, a tela abre
antes o alerta de álbum vazio. O modal copia o link ou usa o compartilhamento nativo do navegador (L2) e mostra a mensagem
de sucesso. A opção "Mostrar as cartas faltantes" grava por `PATCH` ao mudar. O link abre a página pública
`/u/:username/albuns/:albumId`, que lê `GET /users/:username/albums/:albumId/progress` sem login.

## Dependências

- **CCD007** — domínio `collection`, tabelas `collections`, `user_albums` e `collection_cards` e a criação da coleção.
- **CCD019** — `calculateAlbumProgress` e `collectionProgressService.getProgress`: o cartão usa os mesmos números.
- **CCD013** — página do detalhe do álbum (frame `1160-23696`), onde fica o botão.
- **CCD012 / CCD051** — privacidade da coleção (`collections.is_public`), que a L7 pode ligar ao link do álbum.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `user_albums`, `collection_cards`, `collections` | não | da CCD007 | só leitura: progresso, totais, faltantes e `is_public` (depende da L7) |
| `albums`, `cards` | sim | — | título, total e as faltantes (`name`, `number`, `front_image_url`) |
| `users` | sim (`username`) | — | "Colecionador: @<nome de usuário>" e o caminho do link |
| a definir | — | **bloqueada** | a opção "Mostrar as cartas faltantes" não tem coluna no DBML (depende da L8 e de um PR de docs no DBML antes do código) |

## Regras

- **Link** (R4): `${FRONTEND_URL}/u/<username>/albuns/<albumId>`, com o id do álbum enquanto `albums` não tiver `slug`
  (depende da L6). É determinístico: nada é gravado para gerá-lo.
- **Totais do cartão** (R3): possuídas e percentual da CCD019; faltantes = total − possuídas; repetidas = soma de
  `quantity − 1` das cartas `DUPLICATE` do álbum.
- **Álbum vazio** (R7): `ownedCards = 0` — a decisão de abrir o alerta é do frontend, com o `percentage` da resposta.
- **Página pública** (R9): responde `404` para usuário, álbum ou vínculo inexistente; com a coleção privada também `404`
  (depende da L7). Com a opção ligada, traz as faltantes ordenadas por `number`.
- **Quem compartilha** (R1): `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` (depende da L11).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }`, JSON camelCase, erros `{ error, message, details? }`.

```ts
AlbumShareCard = { albumId, title, username, ownedCards, totalCards, missingCards, duplicateCards,
  percentage: number | null, available: boolean, shareUrl: string, showMissingCards: boolean }
MissingCard = { id, name, number, frontImageUrl }
```

### `GET /api/v1/collections/me/albums/:albumId/share` — R1, R3, R4, R8

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L11)
- **Sucesso:** `200` `{ "data": AlbumShareCard }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `albumId` não é uuid | R1 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 404 | `ALBUM_NOT_IN_COLLECTION` | álbum fora da coleção do cliente (erro da CCD019) | R1 |

### `PATCH /api/v1/collections/me/albums/:albumId/share` — R8 (depende da L8)

- **Acesso:** o mesmo do `GET`.
- **Entrada:** `{ "showMissingCards": true }`
- **Sucesso:** `200` `{ "data": AlbumShareCard }`
- **Erros:** `400 VALIDATION_ERROR` (campo ausente ou não booleano), `401`, `404 ALBUM_NOT_IN_COLLECTION` — R1, R8.

### `GET /api/v1/users/:username/albums/:albumId/progress` — R9

- **Acesso:** público.
- **Sucesso:** `200` `{ "data": { ...AlbumShareCard sem shareUrl, missingCards: MissingCard[] | null } }` — a lista só vem
  com a opção ligada.
- **Erros:** `404 SHARED_ALBUM_NOT_FOUND` (usuário, álbum ou vínculo inexistente; coleção privada, depende da L7) — R9.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/` (CCD007).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-share.validator.ts` · `collection-share.errors.ts` | `shareParams`, `updateShareBody`, `publicProgressParams`; `SharedAlbumNotFoundError` | R1, R8, R9 |
| `collection-share.repository.ts` | totais de repetidas, faltantes do álbum, busca por `username` + álbum, leitura e gravação da opção (depende da L8) | R3, R8, R9 |
| `collection-share.service.ts` + `.spec.ts` | monta o cartão com `collectionProgressService` (CCD019), o link e a página pública | R3, R4, R8, R9 |
| `collection-share.controller.ts` · `.routes.ts` · `.swagger.ts` | as rotas `/collections/me/albums/:albumId/share` | R1 |
| `collection-share-public.routes.ts` + registro em `collection.module.ts` / `src/routes.ts` | a rota pública `/users/:username/albums/:albumId/progress`, sem `authenticate` | R9 |
| `src/config/env.ts` | usa o `FRONTEND_URL` já existente para montar o link (se não existir, entra aqui) | R4 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-share.types.ts` · `.api.ts` · `.queries.ts` · `.labels.ts` | contrato, `useAlbumShare`, `useUpdateAlbumShare`, `usePublicAlbumProgress`; textos do modal, do alerta e do sucesso (L9) | R2–R9 |
| `components/ShareProgressButton/` | botão "Compartilhar progresso" do cabeçalho; em 0% abre o alerta — frame `1160-23696` | R2, R7, R11 |
| `components/EmptyAlbumShareDialog/` | "Compartilhar um álbum vazio?", com o título do álbum, "Cancelar", "✕" e "Compartilhar mesmo assim", sobre o `ConfirmDialog` — frame `1160-26693` | R7, R11 |
| `components/ShareProgressModal/` | "COMPARTILHAR PROGRESSO DO ÁLBUM", cartão, "Copiar Link", "Compartilhar Link Público" (`navigator.share` com o link; sem suporte, copia — L2), aviso do link, opção das faltantes com "Salvo automaticamente", "Fechar" e "✕" — frame `1160-25301` | R2–R6, R8, R10, R11 |
| `pages/SharedAlbumPage/` | página pública com o cartão e, com a opção ligada, as faltantes; `NotFoundPage` no `404`; sem frame, no estilo do cartão do modal (L10) | R9 |
| `collection.routes.ts` · `src/routes/paths.ts` · `app/router.tsx` | `sharedAlbum: '/u/:username/albuns/:albumId'` no `PublicLayout`, e `sharedAlbumPathFor` | R9 |

- **Estados:** carregando e erro com `LoadingState` e `ErrorState`; sucesso com `Toast` (`tone="success"`, texto da L9).
- **Componentes reaproveitados de `src/components/`:** `Modal`, `ConfirmDialog`, `Button`, `Checkbox`, `Toast`,
  `LoadingState`, `ErrorState`, `NotFoundPage`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 44 de 54: cartão com título, `@username`, "(44 de 54 cartas)", "Faltam 10 cartas para completar", totais e o link | `collection-share.service.spec.ts` · `ShareProgressModal.spec.tsx` |
| CA2 | "Copiar Link" grava na área de transferência e mostra o sucesso | `ShareProgressModal.spec.tsx` |
| CA3 | "Compartilhar Link Público" chama `navigator.share`; sem suporte, copia; sucesso nos dois (depende da L2) | `ShareProgressModal.spec.tsx` |
| CA4, CA5 | 0%: alerta com o título; "Cancelar" fecha sem abrir o modal; "Compartilhar mesmo assim" abre com 0% | `ShareProgressButton.spec.tsx` |
| CA6 | página pública sem login com e sem as faltantes | `collection-share.service.spec.ts` · `tests/integration/collection-share.spec.ts` · `SharedAlbumPage.spec.tsx` |
| CA7 | desligar, fechar e abrir: continua desligada | integração (`PATCH` + `GET`) · `ShareProgressModal.spec.tsx` |
| CA8 | "Fechar" e "✕" fecham o modal | `ShareProgressModal.spec.tsx` |
| CA9 | sem token `401`; álbum de outro cliente `404` | integração |
| CA10–CA12 | print em 1280 px igual aos frames `1160-23696`, `1160-25301` e `1160-26693`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- O link usa o id do álbum e não é gravado: sem `slug` em `albums` (L6) e sem coluna para o link do álbum, o caminho é
  montado a partir de `username` e `albumId`, o que não pede mudança no DER.
- A opção "Mostrar as cartas faltantes" precisa de uma coluna (L8). Proposta para o PR de docs: `user_albums.share_missing_cards
  boolean not null default true`, nos três `.dbml` e com ADR `Proposto`; a tarefa T1 só começa depois dele.
- Imagem para baixar, redes sociais, QR Code, valor estimado, destaques e "Atualizado hoje" (L1, L3–L5) não entram: viram
  requisitos se o PO aceitar.
