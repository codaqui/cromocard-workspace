# Plano — CCD017 Adicionar Quantidade

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L5 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O controle "Qtd:" das cartas do detalhe do álbum (CCD013) ganha o "+" e o número editável (depende da L4). O "+" envia a
quantidade atual + 1 e o número editado envia o valor digitado, os dois por
`PATCH /api/v1/collections/me/cards/:cardId/quantity`, que valida o inteiro de 1 a 999, grava `quantity`, ajusta o status
pela regra de estado da CCD014 (1 = `OWNED`, 2 ou mais = `DUPLICATE`, depende da L2) e devolve a carta e as contagens do
álbum. Erro de validação fica no campo, sem salvar; erro da API mostra a mensagem e mantém o valor anterior.

## Dependências

- **CCD014**: `collection-card-state.ts`, `collection-progress.ts`, `collection-cards-marking.repository.ts`, os erros
  `COLLECTION_CARD_NOT_FOUND` e o padrão da mutation com atualização da lista e das contagens.
- **CCD013**: o `AlbumCardTile`, o `AlbumCardRow` e as queries das cartas, onde o controle "Qtd:" fica (depende da L5).
- **CCD018**: o "−" do mesmo controle entra com ela; esta story desenha o controle inteiro com o "−" sem ação.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `collection_cards` | da CCD007 | — | grava `quantity` e o `status` derivado (R3) |
| `user_albums` | da CCD007 | — | contagens do álbum na resposta; o progresso não muda de `OWNED` para `DUPLICATE` |

Nenhuma coluna nova.

## Regras

- **Valor válido** (R5, depende da L4): inteiro de 1 a 999; negativo, zero, decimal, texto ou acima de 999 é inválido.
- **Status** (R3, depende da L2): `collection-card-state.ts` ganha a ação `SET_QUANTITY`: 1 → `OWNED`, 2 a 999 →
  `DUPLICATE`.
- **Carta faltante** (depende da L3): `MISSING` (ou sem linha) responde `422 CARD_NOT_OWNED`; no frontend o "+" fica
  desabilitado e o número não é editável.
- **Teto:** com 999, o "+" fica desabilitado.
- **Só da coleção do cliente** (R1): a mesma validação de carta da CCD014 (`404`).

## Contrato da API

Convenções do ADR-011.

### `PATCH /api/v1/collections/me/cards/:cardId/quantity` — R1, R3, R5

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L1)
- **Entrada:**

  ```json
  { "quantity": 2 }
  ```

- **Sucesso:** `200` — o mesmo corpo do `PUT .../status` da CCD014:

  ```json
  { "data": { "card": { "cardId": "uuid", "status": "DUPLICATE", "quantity": 2 },
      "album": { "albumId": "uuid", "progressPercentage": 79.63,
        "counts": { "all": 54, "owned": 43, "missing": 11, "duplicates": 7 } } } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `quantity` não é inteiro de 1 a 999 | R5 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L1) | R1 |
  | 404 | `COLLECTION_CARD_NOT_FOUND` | carta fora da coleção do cliente | R1 |
  | 422 | `CARD_NOT_OWNED` | carta faltante (depende da L3) | R3 |

  O R5 e o CA2 da spec pedem `422` para o valor inválido; a validação do ADR-006 responde `400 VALIDATION_ERROR` em todo
  o projeto. O plano segue o ADR-006 e a spec precisa ser corrigida.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-card-state.ts` + `.spec.ts` (CCD014) | ação `SET_QUANTITY` e o `CARD_NOT_OWNED` | R3 |
| `collection-cards-marking.service.ts` + `.spec.ts` (CCD014) | `setQuantity` na mesma transação com as contagens | R1, R3 |
| `collection.errors.ts` | `CARD_NOT_OWNED` | R3 |
| `collection.validator.ts` · `.controller.ts` · `.routes.ts` · `.swagger.ts` | `quantity` inteiro de 1 a 999 e a rota `PATCH /me/cards/:cardId/quantity` | R1, R5 |
| `tests/integration/collection-card-quantity.spec.ts` | rota de ponta a ponta | CA1–CA3 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-marking.api.ts` · `.queries.ts` (CCD014) | `setCardQuantity` e `useSetCardQuantity`; atualiza a carta e as contagens só com a resposta | R3, R4, R6 |
| `collection-quantity.schema.ts` + `.spec.ts` | `zod` do valor manual e o texto "Informe um número inteiro de 1 a 999." (depende da L4) | R5 |
| `components/CardQuantityControl/` | "Qtd:", "−", o número (botão que vira campo numérico ao clicar) e "+", normal e desabilitado (carta faltante e 999), o alerta abaixo do controle e o erro da API; frame `1160-23696` | R2, R4–R7 |
| `components/AlbumCardTile/` · `AlbumCardRow/` (CCD013) | o controle no cartão e na linha | R2 |

- **Componentes reaproveitados:** `Button`, `TextField`, `FormError`, `Toast`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "+" em "Qtd: 1" grava 2 e mostra "Qtd: 2" | `collection-cards-marking.service.spec.ts` · integração · `CardQuantityControl.spec.tsx` |
| CA2 | "-1" e "abc" não salvam, mantêm 3 e mostram o alerta; a API responde `400 VALIDATION_ERROR` | `collection-quantity.schema.spec.ts` · `CardQuantityControl.spec.tsx` · integração |
| CA3 | `401` sem token; carta de outro cliente não muda | integração |
| CA4 | API fora do ar: mensagem de erro e quantidade anterior | `CardQuantityControl.spec.tsx` |
| CA5 | print em 1280 px igual a `1160-23696` no controle "Qtd:" (normal e desabilitado); 375, 768 e 1024 px sem quebra | revisão visual |

## Decisões técnicas

- A quantidade vai como valor absoluto (`PATCH` com `quantity`), para o "+" e o valor manual usarem o mesmo endpoint. O
  "−" da CCD018 usa uma ação própria, porque chega a zero e muda o status para faltante.
- Sem atualização otimista na quantidade: o número só muda com a resposta, para o valor manual inválido nunca aparecer
  como salvo (R5).
