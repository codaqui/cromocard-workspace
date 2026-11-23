# Plano — CCD046 Visualizar Mensagens

Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (feito sobre a spec em Rascunho)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade
- **Código lido:** branch `feature/336-remove-tipo-categoria` dos dois apps (o domínio `chat` e a feature `chat` estão
  vazios; `conversations`, `conversation_participants` e `messages` não estão no `schema.prisma`)

> **Divisão por módulo (22/11/2026):** o servidor Socket.IO e o cliente do frontend passam a ser criados na CCD046 (Daniel, dono de Mensagens e Notificações), e não mais na CCD044. Onde este plano diz "criado na CCD044", leia "criado na CCD046".

## Solução

O cliente abre "Mensagens" (`/mensagens`) e a página busca as conversas dele pela API REST, da última mensagem mais
recente para a mais antiga. Ao selecionar uma conversa, a página carrega as mensagens por cursor, marca as recebidas como
lidas e entra na room `conversation:<id>` do servidor Socket.IO criado na CCD044. Mensagem nova chega pelo evento
`message:new` (na room da conversa e na `user:<id>` de cada participante), entra no fim da conversa aberta e atualiza a
prévia, a hora e o contador da lista sem recarregar.

## Dependências

- **CCD044 (lote Grupos):** o servidor Socket.IO no `ws-server.ts` (`src/socket/`), o `io.use` que valida o JWT no
  handshake, a entrada automática na room `user:<id>`, o formato do ack e o cliente `socket.io-client` do frontend. Esta
  story só registra os handlers do chat nele.
- **CCD004:** login e `authenticate`. **CCD048:** `profiles.avatar_url` (a foto do outro participante); até lá, a lista
  mostra as iniciais.
- **L5 (envio):** o caso de uso 46 não tem envio, mas R8 precisa de mensagem nova chegando. Pela proposta da L5 (incluir o
  envio simples na CCD046), o handler `message:send` só com texto nasce aqui (depende da L5); a CCD045 acrescenta a
  citação e a CCD047 o bloqueio.

## Dados

As três tabelas entram com esta story, copiadas do DBML (`03-der-completo.dbml`, módulo 5).

| Tabela | Já no `schema.prisma`? | Migration | Observação | Requisitos |
|---|---|---|---|---|
| `conversations` | não | `create_conversations_table` | `listing_id` entra como coluna sem FK até a tabela `listings` existir (CCD073) | R1, R3 |
| `conversation_participants` | não | `create_conversation_participants_table` | PK `(conversation_id, user_id)` | R1, R3, R9 |
| `messages` | não | `create_messages_table` | autorrelação `reply_to_id`; índice `(conversation_id, created_at)` para o cursor | R3–R5, R9 |

Seed (`database/seeds/chat.seed.ts` + `data/conversations.json`): Gabriel com 4 conversas (Marcos, Renata com 1 não lida,
e mais duas), uma última mensagem do próprio Gabriel e uma mensagem excluída — os dados dos CAs e do frame `1160-32980`.

## Regras

- **Minhas conversas:** onde o usuário é participante com `deleted_at` nulo, a conversa não está excluída e o outro
  participante não tem `users.deleted_at` (R1, R9). Conversa de outra pessoa responde `404 CONVERSATION_NOT_FOUND` (R1).
- **Ordem:** pela `created_at` da última mensagem não excluída, a mais recente primeiro (depende da L14).
- **Prévia:** a última mensagem não excluída; `fromMe = true` quando `author_id` é o usuário, e o frontend prefixa "Você: " (R3).
- **Não lidas:** mensagens com `is_read = false`, `author_id` diferente do usuário e `deleted_at` nulo (R5).
- **Lida:** abrir a conversa chama `POST /read`, que marca `is_read = true` e `read_at = now()` nas recebidas (depende da L13).
- **Mensagens:** ordem cronológica, cursor pelo `id` (UUID v7 é ordenável), `limit` 50 (ADR-011; depende da L14).
- **Papéis:** `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` (depende da L15).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.
Recursos do usuário logado em `/me` (ADR-011).

### `GET /api/v1/me/conversations` — R1, R3, R5, R9

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (L15)
- **Entrada:** `page`, `pageSize` (padrão 20; L14)
- **Sucesso:** `200`

  ```json
  { "data": [{ "id": "uuid", "contact": { "id": "uuid", "name": "Marcos Lima", "username": "marcos_tcg", "avatarUrl": null },
      "lastMessage": { "content": "Fechado!", "fromMe": true, "createdAt": "2026-10-31T14:02:00Z" },
      "unreadCount": 0, "createdAt": "2026-03-02T10:00:00Z" }],
    "meta": { "page": 1, "pageSize": 20, "total": 4 } }
  ```

- **Erros:** `401` (sem token), `403 FORBIDDEN` (ADMIN, L15).

### `GET /api/v1/me/conversations/:id/messages` — R1, R4, R9

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** `cursor` (id da mensagem mais antiga já carregada), `limit` (1–50, padrão 50)
- **Sucesso:** `200` `{ "data": Message[], "meta": { "nextCursor": "uuid" | null } }`, da mais antiga para a mais nova

  ```ts
  Message = { id, conversationId, author: { id, name, username }, content, isRead, createdAt }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `id` ou `cursor` não é UUID, `limit` fora de 1–50 | R4 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 404 | `CONVERSATION_NOT_FOUND` | conversa inexistente, excluída ou de que o usuário não participa | R1, R9 |

### `POST /api/v1/me/conversations/:id/read` — R5 (depende da L13)

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Sucesso:** `204`
- **Erros:** `401`; `404 CONVERSATION_NOT_FOUND` (R1).

### Socket.IO (servidor da CCD044) — R1, R8

| Evento | Sentido | Payload | Ack / efeito | Requisitos |
|---|---|---|---|---|
| `conversation:join` | cliente → servidor | `{ conversationId }` | entra na room `conversation:<id>` só se participante; senão ack `{ error: 'CONVERSATION_NOT_FOUND', status: 404 }` | R1, R8 |
| `conversation:leave` | cliente → servidor | `{ conversationId }` | sai da room | R8 |
| `message:send` | cliente → servidor | `{ conversationId, content }` | grava e só então emite; ack `{ data: Message }` ou `{ error, status }` (`400 VALIDATION_ERROR`, `404 CONVERSATION_NOT_FOUND`) (depende da L5) | R8 |
| `message:new` | servidor → cliente | `Message` | emitido na room `conversation:<id>` e nas `user:<id>` dos participantes | R8 |

## Backend — `apps/cromocard-backend`

Domínio `src/domains/chat/`, no modelo de `src/domains/users/` (ADR-004). O módulo REST entra em `src/routes.ts`; os
handlers do Socket.IO entram no registro de handlers do `ws-server.ts` criado pela CCD044.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + 3 migrations | modelos `Conversation`, `ConversationParticipant`, `Message` e as relações em `User` | R1, R3–R5, R9 |
| `database/seeds/chat.seed.ts` · `data/conversations.json` · `seeds/index.ts` | conversas e mensagens de exemplo | R3, R5, R9 |
| `chat.validator.ts` | `conversationIdParamSchema`, `messagesQuerySchema` (cursor, limit), `sendMessageSchema` (`content` com `trim`, mínimo 1; máximo pela L6) | R4, R8 |
| `chat.errors.ts` | `ConversationNotFoundError` (`404 CONVERSATION_NOT_FOUND`) | R1 |
| `chat.repository.ts` | conversas do usuário com o outro participante, a última mensagem e as não lidas (uma consulta com `DISTINCT ON`/`groupBy`), mensagens por cursor, participação, marcar lidas, gravar mensagem | R1, R3–R5, R9 |
| `chat.service.ts` + `chat.service.spec.ts` | `listConversations`, `listMessages`, `markAsRead`, `sendMessage` (confere participação e grava) | R1, R3–R5, R8, R9 |
| `chat.controller.ts` · `chat.routes.ts` · `chat.swagger.ts` · `chat.module.ts` | as 3 rotas REST em `/me/conversations` | R1, R3–R5 |
| `chat.socket.ts` | handlers `conversation:join`, `conversation:leave` e `message:send` (valida com o Zod, chama a service e só então emite `message:new`) | R1, R8 |
| `src/routes.ts` | registra o `chatModule` | R1 |
| `tests/integration/chat-conversations.spec.ts` · `tests/integration/chat-socket.spec.ts` | REST com Supertest; Socket.IO com `socket.io-client` contra o servidor de teste da CCD044 | R1, R3–R5, R8, R9 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/chat/`, no modelo de `src/features/users/` (ADR-040), rotas no `chat.routes.ts` registradas no
`app/router.tsx`. Tudo no contrato visual do frame `1160-32980` (conversas) e `1160-36236` (sem conversas).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `chat.types.ts` · `chat.labels.ts` · `chat.format.ts` | tipos do contrato; textos da tela; hora/data da prévia e o separador "Hoje, 31 de Outubro" | R2–R4 |
| `chat.api.ts` · `chat.queries.ts` | as 3 rotas REST com TanStack Query (ADR-041); `useInfiniteQuery` nas mensagens | R3–R5, R7 |
| `chat.socket.ts` (hook `useConversationSocket`) | `conversation:join`/`leave`, `message:new` atualizando o cache da conversa e da lista; usa o cliente da CCD044 | R8 |
| `components/ConversationList/` · `ConversationListItem/` | coluna "Conversas": foto ou iniciais, nome, @, prévia com "Você: ", hora e contador — frame `1160-32980` | R2, R3, R5 |
| `components/ConversationView/` · `MessageBubble/` · `DaySeparator/` | topo com nome e @, mensagens em ordem e o destaque das não lidas — frame `1160-32980` | R4, R5 |
| `components/MessageComposer/` | campo e "Enviar" que emitem `message:send` (depende da L5); a CCD045 acrescenta a citação | R8 |
| `pages/MessagesPage/` | topo "MENSAGENS • Chat pessoal com outros colecionadores", as duas colunas, estados — frames `1160-32980` e `1160-36236` | R2–R7 |
| `chat.routes.ts` · `app/router.tsx` · `routes/paths.ts` · `app/layouts/SiteShell/siteMenu.ts` | `paths.messages = '/mensagens'` em `RequireAuth`, item "Mensagens" no menu | R1, R2 |

- **Estados:** carregando com `LoadingState` (sem frame, L14); erro com `ErrorState` ("Não foi possível carregar as
  mensagens", R7); vazio com `EmptyState` no estilo do frame `1160-36236` (texto pela L2).
- **Reaproveitados de `src/components/`:** `EmptyState`, `ErrorState`, `LoadingState`, `Badge` (contador), `Button`, `TextField`.
- **Fora deste plano:** busca, abas, filtros, "Nova conversa", arquivadas, selo, presença, reações, "Concluído", "Ver
  Perfil" e a dica de segurança só entram se as lacunas L3–L12 decidirem que sim.

## Testes

Backend com Vitest + Supertest; frontend com Vitest + Testing Library; 90% de cobertura nos arquivos alterados (ADR-060).

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 4 conversas com contato, prévia e hora; mensagens com Marcos em ordem e separadas por dia | `chat.service.spec.ts` · `chat-conversations.spec.ts` · `MessagesPage.spec.tsx` |
| CA2 | `fromMe = true` e o prefixo "Você: " | `chat.service.spec.ts` · `ConversationListItem.spec.tsx` |
| CA3 | `unreadCount = 1` na conversa com Renata; destaque ao abrir; `POST /read` zera | `chat.service.spec.ts` · `chat-conversations.spec.ts` · `ConversationView.spec.tsx` |
| CA4 | lista vazia mostra o estado vazio | `MessagesPage.spec.tsx` |
| CA5 | erro na lista e nas mensagens mostra o aviso | `MessagesPage.spec.tsx` |
| CA6 | `message:send` de Marcos chega como `message:new` para Gabriel; a lista e a conversa atualizam | `chat-socket.spec.ts` · `useConversationSocket.spec.tsx` |
| CA7 | `401` sem token; `404` na conversa de outras duas pessoas (REST e `conversation:join`) | `chat-conversations.spec.ts` · `chat-socket.spec.ts` |
| CA8 | a mensagem excluída do seed não volta na lista nem na prévia | `chat.service.spec.ts` · `chat-conversations.spec.ts` |
| CA9, CA10 | print em 1280 px igual aos frames `1160-32980` e `1160-36236`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |
| CA11 | só se a L5 trouxer "Nova conversa": frame `1160-34999` | — (depende da L5) |

## Dependências e riscos

- Depende do servidor Socket.IO da CCD044; sem ele, R8 e CA6 não fecham (a lista e as mensagens por REST, sim).
- O envio simples (`message:send`) nasce aqui pela proposta da L5; se o PO criar outro caso de uso, o handler muda de
  dono, sem mudar o contrato.
- L2 (texto do vazio), L13 (quando marca lida), L14 (ordem, paginação, carregando) e L15 (papéis) seguem a proposta e
  podem mudar o plano.
- `conversations.listing_id` fica sem FK até `listings` existir no `schema.prisma`; a FK entra com a CCD073.

## Decisões técnicas

- As conversas usam paginação por página (lista curta, com total no rodapé se a L6 pedir) e as mensagens por cursor
  (ADR-011, histórico do chat).
- `message:new` vai também para `user:<id>` de cada participante, para a lista atualizar mesmo com outra conversa aberta
  (ADR-012, rooms).
- A contagem de não lidas e a última mensagem saem numa consulta só por página, para não fazer N+1.
