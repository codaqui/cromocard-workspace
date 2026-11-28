# Plano — CCD073 Entrar em Contato

> **Fase MVP** desde 22/11/2026 (ADR-069). Plano refeito em 27/11/2026 com as decisões L1, L2 e L4–L10 da spec.

- **Spec:** [spec.md](spec.md), Aprovada
- **Repositórios:** backend · frontend, empilhados sobre o chat pessoal (`feature/1208-responder-mensagem-especifica`,
  CCD045, que já traz a CCD046 e a CCD047)
- **Data:** 2026-11-22 (refeito em 2026-11-27) · **Autor:** Daniel Andrade

## Solução

"Entrar em contato" chama `POST /api/v1/listings/:id/contact`. O backend confere o anúncio, o dono e o vendedor,
reaproveita a conversa direta que já existe entre os dois ou cria uma (a mesma regra da Nova conversa da CCD046) e
devolve o id. O frontend leva o cliente a `/mensagens?conversa=<id>` com o texto sugerido no estado da navegação, e a
conversa abre com o campo preenchido. O envio é o da CCD046 (`message:send`), que já grava antes de emitir e entrega em
tempo real ao vendedor.

O botão é o componente `ContactSellerButton` da feature `chat`, exportado pelo `index.ts`. A página do anúncio
(CCD079/CCD080) monta o botão no quadro do vendedor quando existir (L10).

## Dependências

- **CCD045 / CCD046 / CCD047** (PRs #49, #51, #52 e #36, #37, #38): conversas, envio em tempo real, a regra
  `reachableBy` e o bloqueio. Os PRs desta story saem empilhados sobre a `feature/1208-responder-mensagem-especifica`.
- **CCD079 / CCD080** (Lucas): a página do anúncio, que monta o botão. **CCD030** (Lucas): o aviso "Entre para
  continuar", que a página passa para o botão como `onLoginRequired`.
- **CCD053**: o aviso no sino (`NEW_MESSAGE`), fora desta story (L9).

## Dados

Nenhuma migration. Usa `listings` (já no `schema.prisma`, ADR-054), `users`, `conversations` (direta, `listing_id`
nulo), `conversation_participants` e `user_blocks`.

## Regras

Na ordem em que são conferidas, para a mensagem de erro ser a mais útil:

1. Anúncio inexistente ou excluído → `404 LISTING_NOT_FOUND`.
2. Anúncio de quem pede → `422 OWN_LISTING` (R1, L8).
3. Anúncio não `ACTIVE` → `422 LISTING_UNAVAILABLE` (R1).
4. Cliente bloqueou o vendedor (`user_blocks` ativo com `blocker_id` = cliente) → `403 CONTACT_BLOCKED` (R9).
5. Vendedor fora da regra `reachableBy` da CCD046 (excluído, não `ACTIVE`, `ADMIN` ou que bloqueou o cliente) →
   `422 SELLER_UNAVAILABLE` (R8, L4, L6).
6. Conversa direta entre os dois: existe → devolve (`created: false`, `200`); não existe → cria (`created: true`, `201`)
   (R5, L5).

## Contrato da API

### `POST /api/v1/listings/:id/contact` — R1, R4, R5, R8, R9

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** `:id` UUID do anúncio, sem corpo
- **Sucesso:** `201` (criada) ou `200` (já existia) `{ data: { conversationId: string, created: boolean } }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `:id` não é UUID | R1 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | `ADMIN` | R1 |
  | 403 | `CONTACT_BLOCKED` | o cliente bloqueou o vendedor | R9 |
  | 404 | `LISTING_NOT_FOUND` | anúncio inexistente ou excluído | R1 |
  | 422 | `OWN_LISTING` · `LISTING_UNAVAILABLE` · `SELLER_UNAVAILABLE` | próprio, não ativo, vendedor indisponível ou que bloqueou o cliente | R1, R8 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/chat/listing-contact.service.ts` + `.spec.ts` | regras 1–6, usando o repository do chat e o `isReachable` dos contatos | R1, R4, R5, R8, R9 |
| `src/domains/chat/chat.repository.ts` | `findListingForContact(id)` (vendedor, status e exclusão) e `hasBlocked(blockerId, blockedId)` | R1, R9 |
| `src/domains/chat/chat.errors.ts` | `ListingNotFoundError`, `OwnListingError`, `ListingUnavailableError`, `ContactBlockedByYouError`, `SellerUnavailableError` | R1, R8, R9 |
| `src/domains/chat/listing-contact.{controller,routes,swagger}.ts` e `chat.module.ts` | rota com o `listingIdParamSchema` | R1 |
| `tests/integration/chat/listing-contact.spec.ts` | `201`, `200` sem conversa nova, `401`, `403`, `404` e os três `422` | CA1–CA5 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/chat/listing-contact.api.ts` + `.spec.ts` | `contactSeller(listingId)` | R1 |
| `src/features/chat/chat.labels.ts` | textos do botão, dos avisos (R8, R9, CA6) e o texto sugerido | R3, R8, R9 |
| `src/features/chat/components/ContactSellerButton/` + `.spec.tsx` | botão no estilo de "Favoritar", escondido para o dono, `onLoginRequired` para o visitante, aviso abaixo do botão, e a ida para Mensagens com o texto sugerido | R2, R3, R8, R9, R11 |
| `src/features/chat/index.ts` | exporta o `ContactSellerButton` | R11 |
| `MessagesPage` · `ConversationView` · `MessageComposer` | o campo começa com o texto do estado da navegação, uma vez, na conversa indicada | R3 |

## Testes e validação

- Backend: `listing-contact.service.spec.ts` (cada regra) e a integração com o PostgreSQL.
- Frontend: `ContactSellerButton.spec.tsx` (dono, visitante, sucesso, os três avisos) e o campo preenchido em Mensagens.
- Navegador: sem a página do anúncio, o botão é validado numa página de teste local, fora do commit, no estilo do quadro
  do vendedor de `1112-5772`, em 375, 768, 1024 e 1280 px; a conversa aberta é comparada com `1160-32980`.
