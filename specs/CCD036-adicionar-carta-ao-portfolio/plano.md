# Plano — CCD036 Adicionar Carta ao Portfólio

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L9 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O fluxo é o da CCD021 e da CCD022 com a quantidade: no modal "Adicionar carta", "Adicionar" abre o campo de quantidade
(L4) e confirma com `POST /api/v1/collections/me/cards` e `{ cardId, quantity }`. A carta entra `OWNED` com a quantidade
informada (ou restaura o registro excluído), e o progresso do álbum é recalculado. Se a carta já está ativa na coleção, a
API responde `409` com a quantidade atual e a tela oferece atualizar, que chama `PATCH /collections/me/cards/:cardId`.
Sem resultado na busca, o modal oferece "Solicitar cadastro da carta" (CCD023).

## Dependências

- **CCD022** — `POST /collections/me/cards`, a service e a mutação; esta story acrescenta `quantity` e o `409`. A regra final
  entre as duas depende da L3.
- **CCD021** — modal e busca; **CCD023** — formulário de solicitar; **CCD019** — recálculo do progresso.
- **CCD017** — mudar a quantidade na grade do álbum: se ela criar antes o `PATCH /collections/me/cards/:cardId`, esta
  story o reaproveita; senão, cria aqui.
- **CCD007** — domínio `collection` e tabelas.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `collection_cards` | não | da CCD007 | `status = OWNED`, `quantity` informada (R6); restaura `deleted_at` (R10) |
| `user_albums` | não | da CCD007 | progresso recalculado (R7); álbum de outra carta na L8 (mesma regra da L5 da CCD022) |
| `cards` · `albums` | sim | — | só leitura |

Nenhuma coluna nova. "Portfólio" = a coleção inteira (`collection_cards`), não só as avulsas (depende da L1).

## Regras

- **Quantidade** (R5): inteiro de 1 a 999; 0 ou negativa → `422 INVALID_QUANTITY` (CA5).
- **Nova ou excluída** (R6, R10): `OWNED` com a quantidade; excluída volta pelo mesmo registro.
- **Já ativa** (R8): com `quantity` no corpo, `409 CARD_ALREADY_IN_COLLECTION` com `details.quantity` atual; sem
  `quantity`, vale a regra da CCD022 (soma 1). A escolha entre as duas depende da L3 e da L5.
- **Atualizar** (R8): o `PATCH` grava a quantidade nova; com 2 ou mais, `DUPLICATE` (regra da L4 da CCD022).
- **Solicitar** (R9): o link aparece quando a busca não tem resultado (depende da L7).
- **Quem adiciona** (R1): `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` (depende da L9).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }`, JSON camelCase, erros `{ error, message, details? }`.

### `POST /api/v1/collections/me/cards` (CCD022) — R1, R5–R7, R10

- **Entrada:** `{ "cardId": "uuid", "quantity": 2 }` (`quantity` opcional; com ela, a regra desta story).
- **Sucesso:** `201` `{ data: { cardId, status: "OWNED", quantity: 2, result: "created" | "restored", albumProgress } }`
- **Erros (novos):**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 409 | `CARD_ALREADY_IN_COLLECTION` | carta já ativa na coleção; `details: { quantity }` | R8 |
  | 422 | `INVALID_QUANTITY` | quantidade 0, negativa ou acima de 999 | R5 |

  Os da CCD022 continuam (`400`, `401`, `403`, `404 CARD_NOT_FOUND`).

### `PATCH /api/v1/collections/me/cards/:cardId` — R8

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L9)
- **Entrada:** `{ "quantity": 3 }`
- **Sucesso:** `200` `{ data: { cardId, status, quantity: 3, albumProgress } }`
- **Erros:** `400 VALIDATION_ERROR`, `401`, `404 COLLECTION_CARD_NOT_FOUND` (carta fora da coleção), `422 INVALID_QUANTITY` — R5, R8.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/` (CCD007 e CCD022).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-cards.validator.ts` | `quantity` opcional no `addCardBody`; `updateQuantityBody`; `cardIdParams` | R5, R8 |
| `collection-cards.errors.ts` | `CardAlreadyInCollectionError` (`409`), `InvalidQuantityError` (`422`), `CollectionCardNotFoundError` (`404`) | R5, R8 |
| `collection-cards.repository.ts` | `create`/`restore` com quantidade; `updateQuantity` | R6, R8, R10 |
| `collection-cards.service.ts` + `.spec.ts` | as Regras, numa transação, com `recalculate` (CCD019) | R5–R8, R10 |
| `collection-cards.controller.ts` · `.routes.ts` · `.swagger.ts` | corpo novo do `POST` e o `PATCH` | R1, R8 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-cards.api.ts` · `.queries.ts` · `.schemas.ts` · `.labels.ts` | `quantity` na mutação, `useUpdateCollectionCardQuantity`, Zod da quantidade, textos de sucesso (L6) e de "já existe" | R5–R8 |
| `components/AddQuantityForm/` | campo de quantidade e confirmação do "Adicionar" (L4), no estilo do modal — frame `1160-28449` | R5, R11 |
| `components/CardAlreadyInCollection/` | aviso de que a carta já existe e a opção de atualizar a quantidade, no lugar do selo "JÁ ESTÁ NA COLEÇÃO" (L5) — frame `1160-28449` | R8, R11 |
| `components/AddCardModal/` (CCD021) | resultados com nome, número, álbum e imagem; sem resultado, "Solicitar cadastro da carta" (CCD023, L7) — frame `1160-28449` | R3, R4, R9, R11 |
| `pages/AlbumDetailPage/` (CCD013) | "+ Adicionar carta" abre o modal; depois de adicionar, a barra sobe e o `Toast` de sucesso aparece — frame `1160-23696` | R2, R7, R11 |

- **Estados:** carregando no botão de confirmar; erro com `Toast` `danger`; `422` mostrado no campo de quantidade.
- **Componentes reaproveitados de `src/components/`:** `Modal`, `TextField`, `Button`, `Toast`, `FormError`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | busca "mbappé", quantidade 2: `OWNED` 2, progresso sobe, sucesso | `collection-cards.service.spec.ts` · `tests/integration/collection-cards.spec.ts` · `AddCardModal.spec.tsx` |
| CA2 | já com 1: aviso e atualizar para 3, sem outro registro | `collection-cards.service.spec.ts` · integração (`409` + `PATCH`) · `CardAlreadyInCollection.spec.tsx` |
| CA3 | sem resultado: "Solicitar cadastro da carta" abre a CCD023 | `AddCardModal.spec.tsx` |
| CA4 | excluída antes: restaurada `OWNED` com 1 | `collection-cards.service.spec.ts` · integração |
| CA5 | 0 ou negativa: tela recusa e API `422` | `AddQuantityForm.spec.tsx` · integração |
| CA6 | sem token `401` | integração |
| CA7, CA8 | print em 1280 px igual aos frames `1160-23696` e `1160-28449`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- A quantidade fora da faixa responde `422` (CA5), e não `400`: o Zod só confere que é inteiro, e a service aplica a faixa,
  como regra de negócio.
- Com `quantity` no corpo, a carta já ativa responde `409` em vez de somar: o cliente informou uma quantidade e decide se
  troca (FA 1). Sem `quantity`, vale o incremento da CCD022. Se a L3 juntar as duas stories, fica uma regra só.
