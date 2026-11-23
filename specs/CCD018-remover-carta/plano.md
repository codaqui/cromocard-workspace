# Plano — CCD018 Remover Carta

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L7 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O "−" do controle "Qtd:" (CCD017) chama `POST /api/v1/collections/me/cards/:cardId/decrement`, que tira uma unidade. O
ícone de lixeira do cartão ("Remover da coleção", depende da L2) abre o modal "Remover <carta> da sua coleção?" (depende
da L4) e, ao confirmar, chama `POST /api/v1/collections/me/cards/:cardId/remove`, que zera a quantidade (depende da L3).
Nos dois, ao chegar a zero a carta vira `MISSING`, sem `deleted_at` (depende da L6), e o progresso do álbum é recalculado
na mesma transação. Com zero, o "−" e a lixeira ficam desabilitados e a API responde `422`.

## Dependências

- **CCD014**: `collection-card-state.ts`, `collection-progress.ts`, o service da marcação e a resposta com a carta e as
  contagens do álbum.
- **CCD017**: o `CardQuantityControl`, onde o "−" ganha a ação.
- **CCD013**: o `AlbumCardTile`, o `AlbumCardRow` e as queries das cartas.
- **CCD011**: o `RemoveAlbumDialog`, de onde vem o layout do modal de remover a carta.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `collection_cards` | da CCD007 | — | `quantity − 1` ou `0`; zero grava `MISSING` e mantém a linha (R3, R4, depende da L6) |
| `user_albums` | da CCD007 | — | `progress_percentage` recalculado (R5) |
| `albums` | sim | — | `total_cards`, denominador do progresso |

Nenhuma coluna nova.

## Regras

`collection-card-state.ts` (CCD014) ganha duas ações:

| Ação | De `MISSING` (0) | De `OWNED` (1) | De `DUPLICATE` (n ≥ 2) |
|---|---|---|---|
| `DECREMENT` | `422 QUANTITY_ALREADY_ZERO` (R6) | `MISSING`, 0 (R4) | n − 1; com 1, volta a `OWNED` (L7) |
| `REMOVE` | `422 QUANTITY_ALREADY_ZERO` (R6) | `MISSING`, 0 | `MISSING`, 0 (L3) |

- Carta sem linha conta como `MISSING` com 0 (L3 da CCD014): as duas ações respondem `422`.
- **Sem `deleted_at`** (depende da L6): a carta continua no álbum como faltante; a citação da CCD018 no ADR-015 é revista
  num ADR novo (tarefa de docs).
- **Só da coleção do cliente** (R1): a validação de carta da CCD014 (`404`).

## Contrato da API

Convenções do ADR-011 (ação via `POST /:id/<acao>`). Acesso: `authenticate` + `authorize('CUSTOMER', 'SELLER')`
(depende da L1). Os dois endpoints devolvem o mesmo corpo do `PUT .../status` da CCD014.

### `POST /api/v1/collections/me/cards/:cardId/decrement` — R1, R3–R6

- **Entrada:** sem corpo
- **Sucesso:** `200`

  ```json
  { "data": { "card": { "cardId": "uuid", "status": "MISSING", "quantity": 0 },
      "album": { "albumId": "uuid", "progressPercentage": 79.63,
        "counts": { "all": 54, "owned": 43, "missing": 11, "duplicates": 6 } } } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `cardId` não é uuid | R1 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L1) | R1 |
  | 404 | `COLLECTION_CARD_NOT_FOUND` | carta fora da coleção do cliente | R1 |
  | 422 | `QUANTITY_ALREADY_ZERO` | quantidade já em zero | R6 |

### `POST /api/v1/collections/me/cards/:cardId/remove` — R1–R6 (depende da L2, L3)

- **Entrada:** sem corpo
- **Sucesso:** `200`, o mesmo corpo, com `quantity: 0` e `status: "MISSING"`
- **Erros:** os mesmos do `decrement` (R1, R6).

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-card-state.ts` + `.spec.ts` (CCD014) | ações `DECREMENT` e `REMOVE` | R3, R4, R6 |
| `collection-cards-marking.service.ts` + `.spec.ts` (CCD014) | `decrement` e `remove` na transação com o recálculo | R1, R3–R5 |
| `collection.errors.ts` | `QUANTITY_ALREADY_ZERO` | R6 |
| `collection.controller.ts` · `.routes.ts` · `.swagger.ts` | as 2 rotas | R1 |
| `tests/integration/collection-card-remove.spec.ts` | rotas de ponta a ponta | CA1–CA5 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-marking.api.ts` · `.queries.ts` (CCD014) | `decrementCard`, `removeCard` e as mutations; carta e contagens com a resposta | R3–R5, R7 |
| `components/CardQuantityControl/` (CCD017) | o "−" chama `decrement`; desabilitado com 0; erro da API mantém o valor; frame `1160-23696` | R2, R5–R8 |
| `components/RemoveCardButton/` | ícone de lixeira com o texto de ajuda "Remover da coleção", desabilitado com 0 (depende da L2, L5); frame `1160-23696` | R2, R6, R8 |
| `components/RemoveCardDialog/` | "Remover <carta> da sua coleção?", "Cancelar" e "Remover carta", com o `ConfirmDialog`, no layout do `1160-27915` (sem frame próprio: depende da L4) | R2, R7 |
| `components/AlbumCardTile/` · `AlbumCardRow/` (CCD013) | a lixeira no canto do cartão | R2 |

- **Componentes reaproveitados:** `ConfirmDialog`, `Button`, `Icon`, `Toast`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "−" em "Qtd: 3" grava 2 | `collection-card-state.spec.ts` · integração · `CardQuantityControl.spec.tsx` |
| CA2 | "−" em "Qtd: 1": 0, `MISSING`, progresso 79,63 | `collection-cards-marking.service.spec.ts` · integração |
| CA3 | "Remover" confirmado em "Qtd: 3": 0, `MISSING` | `collection-card-state.spec.ts` · integração · `RemoveCardDialog.spec.tsx` |
| CA4 | "−" desabilitado em "Qtd: 0"; a API responde `422 QUANTITY_ALREADY_ZERO` | `CardQuantityControl.spec.tsx` · integração |
| CA5 | `401` sem token; carta fora da coleção não muda nada | integração |
| CA6 | API fora do ar: mensagem de erro e quantidade anterior | `CardQuantityControl.spec.tsx` |
| CA7 | print em 1280 px igual a `1160-23696` no "−" (normal e desabilitado) e na lixeira; 375, 768 e 1024 px sem quebra | revisão visual |

## Decisões técnicas

- Ações próprias (`decrement`, `remove`) em vez do `PATCH .../quantity` da CCD017: a regra de chegar a zero e virar
  faltante fica no backend, e dois cliques rápidos no "−" não gravam o mesmo valor duas vezes.
- Remover a carta não preenche `deleted_at` (L6), o que diverge da lista de exclusões do ADR-015: a mudança vira ADR novo
  `Proposto`, que revê aquela citação.
