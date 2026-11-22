# Plano — CCD073 Entrar em Contato

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

> Fase Futuro Marketplace: implementar depois do MVP (depende da L3).

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L8 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

"Entrar em contato" no detalhe do anúncio abre uma caixa de mensagem (desenho depende da L1). Enviar chama
`POST /api/v1/listings/:id/contact`: o backend confere o anúncio, o vendedor e o bloqueio, cria ou reabre a conversa
daquele anúncio entre os dois, grava a mensagem e só depois emite a mensagem na room da conversa e a notificação ao
vendedor (ADR-012). O cliente é levado à conversa em Mensagens.

## Dependências

- **CCD045 / CCD046** (lote Chat): tabelas `conversations`, `conversation_participants`, `messages` e `user_blocks`, a tela
  Mensagens (`/mensagens/:conversationId`) e o evento de mensagem nova na room `conversation:<id>`.
- **CCD044**: servidor Socket.IO autenticado por JWT.
- **CCD053**: `notificationsService.notify` (aviso ao vendedor, tipo novo `NEW_MESSAGE`, depende da L4 da CCD053).
- **CCD047**: bloqueio de contatos e o aviso "Você bloqueou…" (`1160-37184`).
- **CCD079**: detalhe do anúncio (`/anuncios/:id`) e `isOwner`.
- **CCD055**: `LoginToContinueModal` para o visitante (depende da L7).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `listings` | da CCD097 (ADR-054) | — | `seller_id`, `status`, `deleted_at` (R1, R4) |
| `conversations` · `conversation_participants` · `messages` · `user_blocks` | da CCD045/CCD046 | — | `listing_id` da conversa (R5), mensagem (R6), bloqueio nos dois sentidos (R9) |
| `notifications` | sim | — | aviso ao vendedor pela CCD053 (R7) |

## Regras

- **Anúncio** (R1): inexistente ou excluído → `404 LISTING_NOT_FOUND`; não `ACTIVE` → `422 LISTING_UNAVAILABLE`; o
  próprio anúncio → `422 OWN_LISTING` e o botão não aparece (depende da L8).
- **Vendedor indisponível** (R8): `users.status` diferente de `ACTIVE` ou conta excluída → `422 SELLER_UNAVAILABLE`
  (depende da L4).
- **Bloqueio** (R9): `user_blocks` ativo em qualquer sentido → `403 CONTACT_BLOCKED`; nada é gravado.
- **Conversa** (R5): uma por anúncio e par de usuários; existindo, a mensagem vai para ela (CA2); conversa entre os dois
  sem anúncio ou de outro anúncio não é reaproveitada (depende da L5).
- **Persistência primeiro** (R6, R7): conversa e mensagem numa transação; a emissão e a notificação só depois do commit.
- Conteúdo: o mesmo validator de mensagem da CCD046 (texto obrigatório, mesmo tamanho máximo).

## Contrato da API

### `POST /api/v1/listings/:id/contact` — R1–R9

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** `{ "content": "A carta tem marcas no verso?" }`
- **Sucesso:** `201` `{ data: { conversationId, message: { id, content, authorId, createdAt }, created: boolean } }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | conteúdo vazio ou longo demais | R3 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `CONTACT_BLOCKED` | bloqueio em qualquer sentido | R9 |
  | 404 | `LISTING_NOT_FOUND` | anúncio inexistente ou excluído | R1 |
  | 422 | `LISTING_UNAVAILABLE` · `OWN_LISTING` · `SELLER_UNAVAILABLE` | anúncio não ativo, próprio (L8) ou vendedor indisponível (L4) | R1, R8 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/marketplace/listings/listing-contact.{validator,service,controller,routes,swagger}.ts` + `.service.spec.ts` | regras acima, usando o repository de conversas da CCD046 | R1–R9 |
| `src/domains/chat/conversations.repository.ts` (CCD046) | `findByListingAndParticipants`, `createForListing` | R5 |
| `src/domains/chat/messages.publisher.ts` (CCD046) | reaproveitado para emitir a mensagem nova | R7 |
| `listings.module.ts` (CCD079) | registra a rota | R2 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/marketplace/listings/listing-contact.{api,queries,labels}.ts` | chamada e textos (vendedor indisponível depende da L4; bloqueado pelo vendedor, da L6) | R3, R8, R9 |
| `components/ContactSellerButton/` · `ContactSellerDialog/` | "Entrar em contato" e a caixa da mensagem no estilo do detalhe do anúncio (sem frame, depende da L1); erro mantém o texto digitado | R2, R3, R8, R9 |
| `ListingPurchasePanel` (CCD079) | monta o botão; escondido para o dono (L8) e com "Entre para continuar" para o visitante (L7) | R1, R2 |
| tela Mensagens (CCD046) | abre a conversa criada, frame `1160-32980`; aviso de bloqueio, frame `1160-37184` | R5, R6, R9, R10 |

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | conversa com `listing_id` e os dois participantes, mensagem gravada, emissão e notificação ao vendedor | `listing-contact.service.spec.ts` · `tests/integration/listing-contact.spec.ts` |
| CA2 | segunda mensagem na mesma conversa (`created: false`) | service · integração |
| CA3 | vendedor indisponível → `422`, nada gravado | service |
| CA4 | bloqueio nos dois sentidos → `403`, aviso na tela | service · `ContactSellerDialog.spec.tsx` |
| CA5 | `401`; pausado `422`; excluído `404` | integração |
| CA6 | falha ao gravar: nada emitido, texto mantido | service (publisher falso) · `ContactSellerDialog.spec.tsx` |
| CA7, CA8 | print em 1280 px igual aos frames `1160-32980` e `1160-37184`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- O contato pelo anúncio é uma rota REST, e não o `message:send` do socket, porque cria a conversa e precisa responder
  com erros de negócio antes de existir a room; as mensagens seguintes usam o fluxo da CCD046.
