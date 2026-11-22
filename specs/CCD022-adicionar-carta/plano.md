# Plano — CCD022 Adicionar Carta

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L8 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

"Adicionar" (resultado do modal da CCD021) e "Adicionar à coleção" (perfil da carta, CCD030) chamam
`POST /api/v1/collections/me/cards` com o `cardId`. A service garante a coleção (CCD007), grava `collection_cards` com
`OWNED` e quantidade 1, soma 1 se a carta já está ativa na coleção ou restaura o registro excluído, e chama o recálculo do
progresso (CCD019). A resposta diz o que aconteceu (`created`, `incremented`, `restored`), e a tela mostra a mensagem de
sucesso ou o aviso de quantidade atualizada e invalida as queries da carta e do álbum. A busca da CCD021 ganha o estado
da carta na coleção de cada resultado.

## Dependências

- **CCD007** — domínio `collection`, tabelas e `collectionsService.getOrCreateForUser`.
- **CCD019** — `collectionProgressService.recalculate` (R4).
- **CCD021** — modal "Adicionar carta" e `GET /cards/search`; **CCD030** — perfil da carta (`/cartas/:id`) com "Adicionar à coleção".
- **CCD106** — `cards.status`, para responder `404` ao rascunho (R7).
- **CCD036** — usa a mesma rota com `quantity`; a regra final depende da L3 (juntar ou separar as duas stories).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `collection_cards` | não | da CCD007 | grava `status` `OWNED` (depende da L1), `quantity`; restaura `deleted_at` (R6); único por (`collection_id`, `card_id`) |
| `collections` | não | da CCD007 | criada na primeira escrita (L2 da CCD007) |
| `user_albums` | não | da CCD007 | criado para o álbum da carta quando ele não está na coleção (depende da L5); carta avulsa não mexe |
| `cards` | sim, sem `status` | `status` da CCD106 | só leitura |

## Regras

- **Carta nova** (R3): `OWNED`, quantidade 1 (depende da L1).
- **Já ativa na coleção** (R5): `quantity + 1`, sem outro registro; com `quantity ≥ 2`, `status` passa a `DUPLICATE`; se
  estava `MISSING`, passa a `OWNED` com quantidade 1 (depende da L2 e da L4).
- **Excluída antes** (R6): o mesmo registro volta com `deleted_at` nulo, `OWNED` e quantidade 1 (ADR-015, item 7).
- **Carta inválida** (R7): inexistente, excluída ou `DRAFT` → `404 CARD_NOT_FOUND`.
- **Álbum da carta** (R4): recalcula o progresso; álbum fora da coleção entra em `user_albums` (depende da L5).
- Tudo numa transação: marcação, `user_albums` e progresso.
- **Quem adiciona** (R1): `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` (depende da L8).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }`, JSON camelCase, erros `{ error, message, details? }`.

### `POST /api/v1/collections/me/cards` — R1–R7

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L8)
- **Entrada:** `{ "cardId": "uuid" }`
- **Sucesso:** `201` quando cria ou restaura, `200` quando soma

  ```json
  { "data": { "cardId": "uuid", "status": "OWNED", "quantity": 1, "result": "created",
              "albumProgress": { "albumId": "uuid", "ownedCards": 45, "totalCards": 54, "percentage": 83 } } }
  ```

  `result`: `created` | `incremented` | `restored`; `albumProgress` é `null` para carta avulsa.
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `cardId` ausente ou não uuid | R3 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L8) | R1 |
  | 404 | `CARD_NOT_FOUND` | carta inexistente, excluída ou em rascunho | R7 |

### `GET /api/v1/cards/search` (CCD021) — R5

Cada resultado ganha `inCollection: { status, quantity } | null`, lido da coleção de quem pesquisa.

### `GET /api/v1/cards/:id` (CCD030) — R2

Com token de cliente, ganha `inCollection: { status, quantity } | null`, para o botão "Adicionar à coleção" (depende da L7).

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/` (CCD007).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-cards.validator.ts` · `collection-cards.errors.ts` | `addCardBody`; `CardNotFoundError` (`404 CARD_NOT_FOUND`) | R3, R7 |
| `collection-cards.repository.ts` | `findByCollectionAndCard` (inclui excluídas), `create`, `increment`, `restore`, `ensureUserAlbum` | R3, R5, R6 |
| `collection-cards.service.ts` + `.spec.ts` | as Regras, numa transação, e `recalculate` da CCD019; `findStatusByCards(userId, cardIds)` exportado pelo módulo | R3–R7 |
| `collection-cards.controller.ts` · `.routes.ts` · `.swagger.ts` | rota `POST /collections/me/cards` | R1 |
| `src/domains/catalog/cards/cards.service.ts` (CCD021/CCD030) | `inCollection` na busca e no perfil, pela service exportada do `collection.module.ts` | R2, R5 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-cards.types.ts` · `.api.ts` · `.queries.ts` · `.labels.ts` | `useAddCardToCollection`; invalida a busca, a carta, a grade e o progresso do álbum; textos de sucesso e do aviso de quantidade (L6) | R3–R5 |
| `components/CardSearchResult/` (CCD021) | "Adicionar" chama a mutação; carta já na coleção mostra o selo "JÁ ESTÁ NA COLEÇÃO" e a ação decidida na L2 — frame `1160-28449` | R2, R5, R8 |
| `components/AddToCollectionButton/` | "Adicionar à coleção" no perfil da carta, com o estado depois de adicionar (L7) — frame `1112-4615` | R2, R8 |
| `pages/AlbumDetailPage/` (CCD013) | a carta adicionada aparece marcada e a barra sobe — frame `1160-23696` | R4, R8 |

- **Estados:** mensagem de sucesso e aviso com `Toast`; erro da API com `ErrorState`/`Toast` `danger`.
- **Componentes reaproveitados de `src/components/`:** `Button`, `Badge`, `Toast`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | nova: `OWNED`, quantidade 1, progresso sobe, estado muda | `collection-cards.service.spec.ts` · `tests/integration/collection-cards.spec.ts` · `CardSearchResult.spec.tsx` |
| CA2 | pelo perfil: gravada com 1 e o botão muda | `AddToCollectionButton.spec.tsx` · integração |
| CA3 | de novo: quantidade 2, sem outro registro, aviso | `collection-cards.service.spec.ts` · integração · `AddToCollectionButton.spec.tsx` |
| CA4 | excluída antes: restaurada com 1 | `collection-cards.service.spec.ts` · integração |
| CA5 | rascunho: `404` | integração |
| CA6 | sem token `401` | integração |
| CA7–CA9 | print em 1280 px igual aos frames `1160-28449`, `1112-4615` e `1160-23696`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- Uma rota só para as duas entradas (modal e perfil) e, depois, para a CCD036: a diferença é o corpo (`quantity`), não o
  caminho. O `result` na resposta deixa a tela escolher a mensagem sem uma segunda chamada.
- O `inCollection` vem dentro da busca e do perfil, calculado com a service exportada pelo `collection.module.ts`, para o
  catálogo não ler o repository da coleção (regra do backend).
