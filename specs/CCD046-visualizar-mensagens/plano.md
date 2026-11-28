# Plano — CCD046 Visualizar Mensagens

- **Spec:** [spec.md](spec.md), `Aprovada` em 24/11/2026 (Daniel; a validar pelo PO)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22, revisto em 2026-11-24 com as decisões L1–L17 · **Autor:** Daniel Andrade
- **Código lido:** `develop` dos dois apps em 24/11/2026. O domínio `chat` e a feature `chat` estão vazios.
  `conversations`, `conversation_participants`, `messages`, `user_blocks` e `profiles` não estão no `schema.prisma`.
  `groups`, `group_members`, `orders` e `seller_verifications` já estão.

## Solução

O cliente ou o vendedor abre "Mensagens" (`/mensagens`) e a página busca as conversas dele pela API REST, da última
mensagem mais recente para a mais antiga, com a busca e as abas "Todas" e "Não Lidas". Ao selecionar uma conversa, a
página carrega as 30 mensagens mais recentes, marca as recebidas como lidas e entra na room `conversation:<id>` do
servidor Socket.IO (Onda 0, PR backend #42 e frontend #33). Mensagem nova chega pelo evento `message:new`, entra no fim
da conversa aberta e atualiza a lista. O envio usa o evento `message:send`. "Nova conversa" busca contatos pela API e
abre a conversa, criando-a se ainda não existir. O ponto online vem do processo `ws`, que sabe quem está conectado.

## Dependências

- **Onda 0 (CCD046 T12 e T13):** servidor Socket.IO no `ws-server.ts`, com JWT no handshake, a room `user:<id>`, o
  `withAck` e o registro `socketHandlers` (backend #42), e o cliente `src/lib/socket.ts` (frontend #33). Os PRs desta
  story saem empilhados sobre eles até o merge.
- **CCD048 (Gabriel):** `profiles.avatar_url`, já na `develop` do backend. A API lê a foto de lá; `avatarUrl` é `null` só para quem não tem foto, e aí a tela mostra a inicial (L17).
- **CCD047 (Daniel, a próxima):** a ação do escudo e o bloqueio. A tabela `user_blocks` nasce aqui, porque a busca de
  contatos já exclui os bloqueados (R13), e a CCD047 só usa.
- **CCD080 (Lucas):** a página `/usuarios/:id`. Até lá, "Ver Perfil" leva à rota em construção.
- **CCD045 e CCD073:** a citação da mensagem e a conversa de anúncio (`listing_id`).

## Dados

Tabelas copiadas do DBML (`03-der-completo.dbml`, módulo 5). Nenhuma coluna nova: as decisões cabem no DER atual.

| Tabela | Já no `schema.prisma`? | Migration | Observação | Requisitos |
|---|---|---|---|---|
| `conversations` | não | `create_conversations_table` | `listing_id` com FK para `listings`, que já existe | R1, R3 |
| `conversation_participants` | não | `create_conversation_participants_table` | PK `(conversation_id, user_id)` | R1, R3, R9 |
| `messages` | não | `create_messages_table` | autorrelação `reply_to_id`; ordem por `created_at` e `id`, sem índice novo fora do DER | R3–R5, R9, R18 |
| `user_blocks` | não | `create_user_blocks_table` | único `(blocker_id, blocked_id)`; a CCD047 grava | R13 |

Seed (`database/seeds/chat.seed.ts` + `data/conversations.json`), com os dados do frame `1160-32980`:
- Gabriel tem 4 conversas: Marcos, vendedor verificado; Renata, com 1 não lida; Thiago, com 1 não lida; e Carlos.
- A última mensagem da conversa com Marcos é do próprio Gabriel ("Combinado, compro pelo anúncio.").
- A conversa com Marcos tem uma mensagem excluída.
- Gabriel bloqueou um usuário.
- Renan e Renata participam de grupos em comum com Gabriel.

## Regras

- **Papéis:** `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` (L15).
- **Minhas conversas:** o usuário é participante com `deleted_at` nulo, a conversa não está excluída e o outro participante não tem `users.deleted_at` (R1, R9). Conversa de outra pessoa responde `404 CONVERSATION_NOT_FOUND`.
- **Ordem:** pela `created_at` da última mensagem não excluída, da mais recente para a mais antiga; conversa sem mensagem usa a própria `created_at` (L14).
- **Busca (`q`):** `name` ou `username` do outro participante, sem diferenciar maiúsculas (`ILIKE`), como as outras buscas do projeto (L3).
- **Abas (`filter`):** `all` ou `unread`, esta só com as conversas que têm não lidas. O `meta` traz `totals: { all, unread }` para o selo, as abas e o rodapé (L4, L6).
- **Prévia:** a última mensagem não excluída; com `fromMe = true` o frontend prefixa "Você: " (R3).
- **Não lidas:** `is_read = false`, `author_id` diferente do usuário e `deleted_at` nulo (R5).
- **Lida:** abrir a conversa chama `POST /read`, que marca `is_read` e `read_at` nas recebidas. Com a conversa aberta, cada `message:new` recebido chama o `POST /read` de novo (L13).
- **Mensagens:** ordem cronológica, cursor pelo `id` (UUID v7 é ordenável), 30 por vez (L14).
- **Selo "Verificado":** o outro participante tem `seller_verifications.status = APPROVED` (L7).
- **Contatos da "Nova conversa":**
  - quem aparece: usuários com `status = ACTIVE`, sem `deleted_at`, que não são o próprio usuário, não são `ADMIN` e não estão bloqueados em nenhum dos dois sentidos (`user_blocks`);
  - abas (`scope`): `all`, `groups` (participa de um grupo com o usuário, com os nomes dos grupos em comum), `sellers` (`role = SELLER`) e `deals` (tem pedido com o usuário, como comprador ou vendedor);
  - limite de 10 resultados (L5).
- **Abrir conversa com alguém:** reaproveita a conversa pessoal (sem `listing_id`) que já existe entre os dois; senão cria a conversa e os dois participantes numa transação (L5).
- **Envio:** `content` com `trim`, de 1 a 2000 caracteres. A mensagem é gravada antes do `message:new` (R18).
- **Presença:** o processo `ws` guarda em memória quantos sockets cada usuário tem conectados.
  - Ao conectar o primeiro socket ou desconectar o último, emite `presence:changed` na room `user:<id>` de cada pessoa com quem ele tem conversa.
  - `presence:list` responde quem, de uma lista de ids, está online.
  - Nada é gravado no banco (L8). Com uma instância do `ws` (ADR-012), a memória basta.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.
Todas as rotas: `authenticate` + `authorize('CUSTOMER', 'SELLER')`; `401` sem token e `403 FORBIDDEN` para `ADMIN`.

```ts
Contact = { id, name, username, avatarUrl: string | null, verified: boolean }
ConversationSummary = { id, contact: Contact, lastMessage: { content, fromMe, createdAt } | null, unreadCount, createdAt }
Message = { id, conversationId, author: { id, name, username }, content, isRead, createdAt }
```

### `GET /api/v1/me/conversations` — R1, R3, R5, R9, R11, R12, R14

- **Entrada:** `q` (até 60 caracteres), `filter` (`all` | `unread`, padrão `all`), `page`, `pageSize` (padrão 50).
- **Sucesso:** `200 { data: ConversationSummary[], meta: { page, pageSize, total, totalPages, totals: { all, unread } } }`.
  O `total` respeita `q` e `filter` (rodapé "N de N"); o `totals` não.
- **Erros:** `400 VALIDATION_ERROR` (`filter` fora da lista, `q` longo).

### `POST /api/v1/me/conversations` — R13

- **Entrada:** `{ userId }`.
- **Sucesso:** `201` com `ConversationSummary` quando cria; `200` quando já existia.
- **Erros:**
  - `400 VALIDATION_ERROR`: `userId` não é UUID;
  - `404 USER_NOT_FOUND`: inexistente, inativo, excluído, `ADMIN`, bloqueado ou o próprio usuário.

### `GET /api/v1/me/conversations/:id/messages` — R1, R4, R9

- **Entrada:** `cursor` (id da mensagem mais antiga já carregada), `limit` (1–50, padrão 30).
- **Sucesso:** `200 { data: Message[], meta: { nextCursor: string | null } }`, da mais antiga para a mais nova.
- **Erros:** `400 VALIDATION_ERROR`; `404 CONVERSATION_NOT_FOUND`.

### `POST /api/v1/me/conversations/:id/read` — R5

- **Sucesso:** `204`. **Erros:** `404 CONVERSATION_NOT_FOUND`.

### `GET /api/v1/me/contacts` — R13, R14

- **Entrada:** `q` (até 60 caracteres, opcional), `scope` (`all` | `groups` | `sellers` | `deals`, padrão `all`).
- **Sucesso:** `200 { data: (Contact & { role, commonGroups: string[] })[] }`, até 10, por nome.
- **Erros:** `400 VALIDATION_ERROR`.

### Socket.IO — R1, R8, R15, R18

Ack no formato do ADR-011 (`withAck` da Onda 0).

| Evento | Sentido | Payload | Ack / efeito | Requisitos |
|---|---|---|---|---|
| `conversation:join` | cliente → servidor | `{ conversationId }` | entra na room `conversation:<id>` só se participante; senão `{ error: 'CONVERSATION_NOT_FOUND' }` | R1, R8 |
| `conversation:leave` | cliente → servidor | `{ conversationId }` | sai da room | R8 |
| `message:send` | cliente → servidor | `{ conversationId, content }` | grava e só então emite; ack `{ data: Message }` ou `{ error }` (`VALIDATION_ERROR`, `CONVERSATION_NOT_FOUND`) | R18 |
| `message:new` | servidor → cliente | `Message` | na room `conversation:<id>` e nas `user:<id>` dos participantes | R8 |
| `presence:list` | cliente → servidor | `{ userIds }` (até 100) | ack `{ data: { online: string[] } }` | R15 |
| `presence:changed` | servidor → cliente | `{ userId, online }` | na `user:<id>` de quem tem conversa com ele | R15 |

## Backend — `apps/cromocard-backend`

Domínio `src/domains/chat/`, no modelo de `src/domains/users/` (ADR-004). O módulo REST entra em `src/routes.ts`; os
handlers entram em `src/socket/socket-handlers.ts` (Onda 0).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + 4 migrations | `Conversation`, `ConversationParticipant`, `Message`, `UserBlock` e as relações em `User` e `Listing` | R1, R3–R5, R9, R13 |
| `database/seeds/chat.seed.ts` · `data/conversations.json` · `seeds/index.ts` | conversas, mensagens, bloqueio e grupos em comum | R3, R5, R9, R13 |
| `chat.validator.ts` | `listConversationsQuerySchema`, `startConversationSchema`, `conversationIdParamSchema`, `messagesQuerySchema`, `contactsQuerySchema`, `sendMessageSchema` | R4, R11–R13, R18 |
| `chat.errors.ts` | `ConversationNotFoundError` (404), `ContactNotFoundError` (404 `USER_NOT_FOUND`) | R1, R13 |
| `chat.repository.ts` | conversas com contato, última mensagem, não lidas e selo (uma consulta por página); totais; mensagens por cursor; participação; marcar lidas; gravar mensagem; achar ou criar conversa | R1, R3–R5, R9, R11–R14, R18 |
| `contacts.repository.ts` | busca de contatos por `scope`, com os grupos em comum e os bloqueios | R13, R14 |
| `chat.service.ts` + spec | `listConversations`, `startConversation`, `listMessages`, `markAsRead`, `sendMessage`, `listContacts` | R1, R3–R5, R9, R11–R14, R18 |
| `chat.controller.ts` · `chat.routes.ts` · `chat.swagger.ts` · `chat.module.ts` | as 5 rotas REST | R1, R3–R5, R11–R14 |
| `chat.socket.ts` · `presence.registry.ts` | handlers de conversa, mensagem e presença; o registro em memória | R1, R8, R15, R18 |
| `src/routes.ts` · `src/socket/socket-handlers.ts` | registra o módulo e os handlers | R1, R8 |
| `tests/integration/chat/conversations.spec.ts` · `contacts.spec.ts` · `chat-socket.spec.ts` | REST com Supertest e Socket.IO com clientes reais | R1, R3–R5, R8, R9, R11–R15, R18 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/chat/`, no modelo de `src/features/users/` (ADR-040). Contrato visual: frames `1160-32980`,
`1160-36236` e `1160-34999`, já sem o que ficou fora (ajuste no Figma de 24/11/2026).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `chat.types.ts` · `chat.labels.ts` · `chat.format.ts` | tipos, textos, hora ou data da prévia e o separador "Hoje, 31 de Outubro" | R2–R4, R12, R17 |
| `chat.api.ts` · `chat.queries.ts` | as 5 rotas; `useInfiniteQuery` nas mensagens; atualização do cache pelo socket | R3–R5, R7, R11–R13 |
| `hooks/useChatSocket.ts` · `usePresence.ts` · `useSendMessage.ts` | join/leave, `message:new`, presença e envio pelo cliente da Onda 0 | R8, R15, R18 |
| `components/ConversationList/` · `ConversationListItem/` · `ConversationFilters/` | coluna "Conversas": "N ativas", "Nova conversa", busca, abas, itens e o rodapé "N de N conversas listadas" | R2, R3, R5, R11, R12, R14, R15 |
| `components/ConversationView/` · `ConversationHeader/` · `MessageBubble/` · `DaySeparator/` · `SafetyTip/` | topo com "Ver Perfil" e o escudo, a dica, as mensagens, o destaque e as anteriores ao rolar | R4, R5, R16, R17 |
| `components/MessageComposer/` | campo, "Enviar", Enter e o aviso de compras; texto mantido se o envio falhar | R17, R18 |
| `components/NewConversationModal/` | modal do frame `1160-34999` | R13 |
| `components/ContactAvatar/` | foto ou inicial e o ponto online | R3, R15, R19 |
| `pages/MessagesPage/` | topo "MENSAGENS • Chat pessoal com outros colecionadores", as duas colunas e os estados | R2–R7 |
| `chat.routes.ts` · `app/router.tsx` · `routes/paths.ts` · `siteMenu.ts` | `/mensagens` atrás do `RequireRole` de `CUSTOMER` e `SELLER`, item "Mensagens" no menu e `/usuarios/:id` em construção (até a CCD080) | R1, R2, R16 |

- **Estados:** carregando com `LoadingState` (L14); erro com `ErrorState`, "Não foi possível carregar as mensagens" (R7); vazio do frame `1160-36236` (R6).
- **Reaproveitados:** `Modal`, `Tabs`, `SearchBar` ou `TextField`, `Button`, `Badge`, `Toast`, `LoadingState`, `ErrorState`.
- O escudo aparece com o rótulo "Bloquear ou denunciar"; a ação entra na CCD047.

## Testes

Backend com Vitest + Supertest + `socket.io-client`; frontend com Vitest + Testing Library; 90% de cobertura nos
arquivos alterados (ADR-060).

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 4 conversas na ordem, com contato, prévia e hora; mensagens em ordem e por dia | `chat.service.spec.ts` · `conversations.spec.ts` · `MessagesPage.spec.tsx` |
| CA2 | `fromMe` e o "Você: " | `chat.service.spec.ts` · `ConversationListItem.spec.tsx` |
| CA3 | `unreadCount = 1` com Renata; destaque; `POST /read` zera | `conversations.spec.ts` · `ConversationView.spec.tsx` |
| CA4 | estado vazio do frame | `MessagesPage.spec.tsx` |
| CA5 | erro na lista e na conversa | `MessagesPage.spec.tsx` |
| CA6 | `message:new` entra na conversa, lida, e atualiza a lista | `chat-socket.spec.ts` · `useChatSocket.spec.tsx` |
| CA7 | `401`, `403` (ADMIN) e `404` na conversa alheia (REST e `conversation:join`) | `conversations.spec.ts` · `chat-socket.spec.ts` |
| CA8 | mensagem excluída fora da conversa e da prévia | `chat.service.spec.ts` · `conversations.spec.ts` |
| CA9–CA11 | print em 1280 px igual aos três frames; sem quebra em 375/768/1024 px | validação no navegador (Fases 6 e 7) |
| CA12 | busca "ren", rodapé "1 de 4" e a aba "Não Lidas" | `conversations.spec.ts` · `ConversationList.spec.tsx` |
| CA13 | "Conversar" cria uma vez e reaproveita a existente | `conversations.spec.ts` · `NewConversationModal.spec.tsx` |
| CA14 | bloqueado e suspenso fora da busca; aba de grupos com os grupos em comum | `contacts.spec.ts` |
| CA15 | selo do vendedor aprovado e ponto online pela presença | `chat.service.spec.ts` · `chat-socket.spec.ts` · `ConversationListItem.spec.tsx` |
| CA16 | envio grava, aparece e chega ao outro; falha mantém o texto | `chat-socket.spec.ts` · `MessageComposer.spec.tsx` |

## Dependências e riscos

- Os PRs saem empilhados sobre a Onda 0 (#42 e #33): depois do merge dela, `rebase --onto origin/develop`.
- A presença em memória vale para uma instância do `ws`. Com mais de uma, precisaria do adapter de Redis (fora do MVP, ADR-012).
- `user_blocks` nasce aqui. Se a CCD047 precisar de outra coluna, ela altera o DER e a migration.

## Decisões técnicas

- Conversas paginadas por página (lista curta, com total no rodapé) e mensagens por cursor (ADR-011).
- `message:new` vai também para a `user:<id>` de cada participante, para a lista atualizar com outra conversa aberta (ADR-012).
- A última mensagem, as não lidas e o selo saem numa consulta por página, para não fazer N+1.
- Contatos numa rota própria (`/me/contacts`), separada de `/users` do BackOffice, porque o filtro e os campos são outros.
