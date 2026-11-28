# Plano — CCD045 Responder Mensagem Específica

Plano revisto em 26/11/2026 com as decisões L1–L11 e o código da CCD046 e da CCD047.

- **Spec:** [spec.md](spec.md), aprovada em 26/11/2026
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade
- **Código lido:** branches `feature/1231-moderar-contatos-privados` dos dois apps (CCD047, empilhada sobre a CCD046)

## Solução

Na conversa aberta (CCD046), selecionar uma mensagem mostra as ações dela com "Responder". O bloco "Respondendo a
@<autor>:" aparece acima do campo, com o trecho citado, e o envio emite `message:send` com `replyToId`. A service confere
participação, bloqueio (CCD047) e se a mensagem citada é da mesma conversa e não está excluída, grava `messages.reply_to_id`
e só então emite `message:new`, que já traz a citação. O histórico (`GET /messages` da CCD046) devolve a citação também.

## Dependências

- **CCD044:** servidor Socket.IO, handshake com JWT e formato do ack.
- **CCD046:** `messages` (com `reply_to_id`), `chatService.sendMessage`, o handler `message:send`, a conversa aberta e o
  `MessageComposer`. O envio sem citação também é da CCD046 (proposta da L5).
- **CCD047:** `hasActiveBlockBetween` e o erro `422 CONTACT_BLOCKED` (R11 desta story é a mesma checagem).

## Dados

Nenhuma migration: `messages.reply_to_id` (autorrelação, opcional) entra com a CCD046, copiada do DBML.

| Tabela | Colunas | Uso | Requisitos |
|---|---|---|---|
| `messages` | `reply_to_id`, `conversation_id`, `deleted_at`, `content` | grava a citação; valida a mensagem citada | R5, R6, R10 |
| `users` | `username` | o "@" do bloco | R3, R7 |

Seed: uma mensagem longa de Marcos (para CA2) e uma resposta de Gabriel já citando outra mensagem.

## Regras

- **Citação válida:** `replyToId` existe, é da mesma conversa e tem `deleted_at` nulo (R6).
  - De outra conversa ou inexistente: `400 VALIDATION_ERROR` com `details.replyToId` (CA5).
  - Excluída: `422 REPLY_TARGET_UNAVAILABLE` (CA4, R10); o frontend mostra o aviso, tira o bloco e mantém o texto.
- **Ordem na service** (ADR-012, persistência primeiro): payload no Zod → participação (`404 CONVERSATION_NOT_FOUND`,
  L11) → bloqueio (`422 CONTACT_BLOCKED`, CCD047) → citação → grava → emite. Falha em qualquer passo: nada gravado nem
  emitido.
- **Mensagem vazia:** o Zod já recusa `content` só com espaços (`400`); no frontend o "Enviar" fica ativo e enviar vazio
  (botão ou Enter) não emite e mostra "Digite uma mensagem antes de enviar" (R9, L10).
- **Trecho citado:** a API manda o `content` inteiro da mensagem citada; o corte em uma linha com "..." é do CSS
  (`text-overflow: ellipsis`), no bloco acima do campo e no balão (R3, R7, L9).
- **Citação excluída depois:** o histórico devolve `replyTo.unavailable = true` sem o trecho, e a tela mostra
  "Mensagem indisponível" (R14, L4).
- **Papéis:** `CUSTOMER` e `SELLER` (L8), já garantidos pelo handshake e pelas rotas da CCD046.

## Contrato da API

Sem rota REST nova. Muda o evento da CCD046 e o tipo `Message`:

```ts
Message = { id, conversationId, author: { id, name, username }, content, isRead, createdAt,
  replyTo: { id, authorUsername, content, unavailable: false } | { id, authorUsername, unavailable: true } | null }
```

### Evento `message:send` (Socket.IO) — R1, R5, R6, R8–R11

- **Acesso:** socket autenticado no handshake (CCD044); só participante da conversa.
- **Payload:** `{ "conversationId": "uuid", "content": "string", "replyToId": "uuid" }` (`replyToId` opcional)
- **Ack de sucesso:** `{ "data": Message }`; depois o servidor emite `message:new` na room `conversation:<id>` e nas
  `user:<id>` dos participantes.
- **Ack de erro:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `content` vazio ou só espaços; `replyToId` que não é UUID, de outra conversa ou inexistente | R6, R9 |
  | 401 | `UNAUTHORIZED` | handshake sem token válido (conexão recusada) | R1 |
  | 404 | `CONVERSATION_NOT_FOUND` | quem envia não participa da conversa | R1 |
  | 422 | `REPLY_TARGET_UNAVAILABLE` | a mensagem citada foi excluída | R6, R10 |
  | 422 | `CONTACT_BLOCKED` | bloqueio ativo entre os dois (CCD047) | R11 |
  | 500 | `INTERNAL_ERROR` | falha na gravação; nada é emitido | R8 |

### `GET /api/v1/me/conversations/:id/messages` (CCD046) — R7, R14

Cada item ganha `replyTo` no formato acima.

## Backend — `apps/cromocard-backend`

No domínio `src/domains/chat/` (CCD046).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `chat.validator.ts` | `sendMessageSchema` ganha `replyToId` (UUID, opcional) | R5, R8, R9 |
| `chat.errors.ts` | `ReplyTargetUnavailableError` (`422`) e `ReplyTargetInvalidError` (`400`, `details.replyToId`) | R6, R10 |
| `chat.repository.ts` | `findReplyTarget(id)` e o `include` da citação (autor) na listagem e na gravação | R5–R7 |
| `chat.service.ts` + `chat.service.spec.ts` | `sendMessage` valida a citação na ordem das Regras e grava `replyToId` | R5, R6, R8, R10, R11 |
| `chat.socket.ts` | handler `message:send` já repassa o payload validado e devolve os erros no ack (sem mudança, só testes) | R1, R8 |
| `database/seeds/data/conversations.json` | mensagem longa e resposta de exemplo | R3, R7 |
| `tests/integration/chat/chat-socket.spec.ts` · `conversations.spec.ts` | resposta, citação inválida, excluída, bloqueio, falha de gravação; `replyTo` no histórico | R1, R5–R11 |

## Frontend — `apps/cromocard-frontend`

Na feature `src/features/chat/` (CCD046).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `chat.types.ts` · `chat.labels.ts` · `chat.api`/socket | `replyTo` no `Message` e `replyToId` no envio; textos "Responder", "Respondendo a @…:", "Digite uma mensagem antes de enviar", "A mensagem que você está respondendo não está mais disponível.", "Mensagem indisponível" | R3, R5, R9, R10, R14 |
| `components/MessageMenu/` | menu da mensagem com "↩ Responder", aberto ao clicar ou tocar na mensagem; fecha com Esc ou clique fora — frame `1160-33616` | R2 |
| `components/ReplyPreview/` | bloco "Respondendo a @<autor>:" com o começo do texto entre aspas em uma linha; "×" e Esc cancelam — frame `1160-32980` | R3, R13 |
| `components/MessageComposer/` (CCD046) | "Enviar" sempre ativo, aviso de vazio, `replyToId` no `message:send`, erro do ack e o `REPLY_TARGET_UNAVAILABLE` que tira o bloco e mantém o texto — frame `1160-32980` | R4, R5, R8–R10, R13 |
| `components/MessageBubble/` (CCD046) | citação acima do texto (uma linha, "...") e "Mensagem indisponível"; clique abre o menu | R2, R7, R14 |
| `components/ConversationView/` (CCD046) | guarda a mensagem que está sendo respondida e liga menu, bloco e envio | R2, R3, R13 |

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | `reply_to_id` gravado; `message:new` para os dois com a citação | `chat.service.spec.ts` · `chat-socket.spec.ts` · `MessageComposer.spec.tsx` · `MessageBubble.spec.tsx` |
| CA2 | o bloco mostra o trecho entre aspas com a classe de corte | `ReplyPreview.spec.tsx` |
| CA3 | vazio não emite e mostra "Digite uma mensagem antes de enviar"; a API recusa `400` | `MessageComposer.spec.tsx` · `chat.validator.spec.ts` |
| CA4 | citação excluída: `422`, aviso e o bloco some | `chat.service.spec.ts` · `MessageComposer.spec.tsx` |
| CA5 | `replyToId` de outra conversa: `400`, nada gravado nem emitido | `chat.service.spec.ts` · `chat-socket.spec.ts` |
| CA6 | handshake sem token recusado; não participante recebe `404` | `chat-socket.spec.ts` |
| CA7 | falha da gravação: nada emitido e o erro do ack na tela | `chat.service.spec.ts` · `MessageComposer.spec.tsx` |
| CA8 | com bloqueio, os dois recebem `422 CONTACT_BLOCKED` | `chat-socket.spec.ts` |
| CA11 | × e Esc tiram o bloco e mantêm o texto; o envio seguinte vai sem `replyToId` | `ReplyPreview.spec.tsx` · `ConversationView.spec.tsx` |
| CA12 | citação excluída depois: "Mensagem indisponível" | `MessageBubble.spec.tsx` · `conversations.spec.ts` |
| CA9, CA10 | print em 1280 px igual aos frames `1160-32980` e `1160-33616`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Dependências e riscos

- Empilhada sobre a CCD047 (#51 e #37), que está sobre a CCD046 (#49 e #36): a base dos PRs muda conforme elas entram.
- O "Enviar" ativo com aviso de vazio muda o compositor da CCD046 para todas as mensagens (L10).

## Decisões técnicas

- A citação volta já montada no `Message` (autor e trecho), para a resposta aparecer nos dois lados sem outra consulta.
- O corte do trecho é visual (CSS), não da API, para não duplicar regra de tamanho entre backend e frontend.
