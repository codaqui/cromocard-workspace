# Plano — CCD035 Resetar Progresso do Álbum

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L4 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O menu "⋯" do cabeçalho do detalhe do álbum ganha "Resetar progresso", que abre a confirmação. Confirmar chama
`POST /api/v1/collections/me/albums/:albumId/reset`: numa transação, as marcações das cartas daquele álbum na coleção do
cliente recebem `deleted_at` e `user_albums.progress_percentage` vai a 0, sem tocar no `user_albums` nem em outros
álbuns. A tela mostra a mensagem de sucesso e invalida a grade e o progresso, que aparecem em 0%.

## Dependências

- **CCD007** — domínio `collection` e as tabelas `user_albums` e `collection_cards`.
- **CCD019** — `collectionProgressService.recalculate` e `ALBUM_NOT_IN_COLLECTION`.
- **CCD013** — detalhe do álbum (frame `1160-23696`) com o cabeçalho; **CCD011** — o menu "⋯" com "Remover da minha
  coleção" (quem entrar primeiro cria o menu).
- **CCD014 / CCD022** — re-marcar depois do reset restaura o registro com quantidade 1 (CA5).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `collection_cards` | não | da CCD007 | `updateMany` com `deleted_at = now()` nas cartas do álbum (R4, R5) |
| `user_albums` | não | da CCD007 | `progress_percentage = 0`; o registro continua ativo (R6) |
| `cards` · `albums` | sim | — | `cards.album_id` filtra as cartas; `albums.title` na confirmação |

Nenhuma coluna nova.

## Regras

- **Escopo** (R4, R6): só `collection_cards` da coleção do cliente cujas cartas têm `album_id` = o álbum, e ainda não
  excluídas. Outros álbuns, o `user_albums` e os anúncios ficam como estão.
- **Lógico** (R5): nunca `DELETE`; re-marcar restaura o mesmo registro (ADR-015, item 7).
- **Sem marcação** (L1): a rota responde `200` com `resetCards: 0`; o item do menu fica desabilitado (depende da L1).
- **Quem reseta** (R1): `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` (depende da L4).

## Contrato da API

Convenções do ADR-011: ação via `POST /:id/<acao>`, `{ data }`, erros `{ error, message, details? }`.

### `POST /api/v1/collections/me/albums/:albumId/reset` — R1, R4–R6

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L4)
- **Entrada:** nenhum corpo.
- **Sucesso:** `200`

  ```json
  { "data": { "albumId": "uuid", "resetCards": 50,
              "progress": { "ownedCards": 0, "totalCards": 54, "missingCards": 54, "percentage": 0, "available": true } } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `albumId` não é uuid | R1 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L4) | R1 |
  | 404 | `ALBUM_NOT_IN_COLLECTION` | álbum fora da coleção do cliente | R1 |

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/` (CCD007).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-cards.repository.ts` | `softDeleteByAlbum(collectionId, albumId)` | R4–R6 |
| `collection-reset.service.ts` + `.spec.ts` | confere o álbum na coleção, apaga logicamente e zera o progresso, numa transação | R1, R4–R6 |
| `collection.controller.ts` · `collection.routes.ts` · `collection.swagger.ts` | rota `POST /collections/me/albums/:albumId/reset` | R1 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection.api.ts` · `collection.queries.ts` · `collection.labels.ts` | `useResetAlbumProgress`, invalida grade, progresso e lista de álbuns; textos da confirmação e do sucesso (L2) | R3, R4, R7 |
| `components/AlbumActionsMenu/` (CCD011) | item "Resetar progresso", desabilitado sem marcação (L1) — frame `1160-26090` | R2, R9 |
| `components/ResetProgressDialog/` | "Resetar o progresso do álbum?", texto com o título, "Cancelar", "Resetar progresso" e "✕", sobre o `ConfirmDialog` — frame `1160-27304` | R3, R8, R9 |
| `pages/AlbumDetailPage/` (CCD013) | liga o menu e a confirmação; sucesso com `Toast` e a grade em 0% | R7 |

- **Estados:** botão de confirmar em carregando durante a chamada; erro com `Toast` `danger`.
- **Componentes reaproveitados de `src/components/`:** `ConfirmDialog`, `OverlayDialog`, `Button`, `Toast`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | marcações com `deleted_at`, progresso 0, sucesso e grade sem marcação | `collection-reset.service.spec.ts` · `tests/integration/collection-reset.spec.ts` · `AlbumDetailPage.spec.tsx` |
| CA2 | outro álbum intacto; álbum continua em "Meus álbuns" | `collection-reset.service.spec.ts` · integração |
| CA3 | "Cancelar" e "✕" fecham sem chamar a API | `ResetProgressDialog.spec.tsx` |
| CA4 | sem token `401`; fora da coleção `404` | integração |
| CA5 | re-marcar depois do reset restaura com 1 e o progresso sobe | integração (com a rota da CCD022) |
| CA6, CA7 | print em 1280 px igual aos frames `1160-26090` e `1160-27304`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- O reset é um `updateMany` numa transação com o zero do progresso, para a grade e a barra nunca ficarem divergentes.
- A rota é uma ação do álbum na coleção (`POST …/reset`, ADR-011), e não um `DELETE`, porque o álbum continua na coleção.
