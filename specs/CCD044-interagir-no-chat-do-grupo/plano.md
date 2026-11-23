# Plano — CCD044 Interagir no Chat do Grupo

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (lacunas L1–L13 pendentes)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

> **Divisão por módulo (22/11/2026):** o servidor Socket.IO e o cliente do frontend passam a ser criados na CCD046 (Daniel, dono de Mensagens e Notificações), e não mais na CCD044. Onde este plano diz "criado na CCD044", leia "criado na CCD046".

## Solução

Esta story cria o servidor Socket.IO autenticado por JWT (ADR-012), que ainda não existe: o `src/ws-server.ts` (imagem
`cromocard-ws`, `ws.cromocard.com.br` e `hml-ws.cromocard.com.br`) hoje só expõe `/health`. A tela do grupo
(`/comunidades/:id`) busca o cabeçalho e o histórico pela API (cursor de 50), conecta no WS com o access token, entra na
room `group:<id>` e envia texto por `group-message:send`; o servidor valida com o Zod do domínio, grava e só então emite
`group-message:new` para a room. O chat pessoal (CCD045–CCD047) e as notificações em tempo real (CCD053) usam o mesmo
servidor.

## Dependências

- CCD039: domínio `community/groups/`, `group-access.ts` (`assertMember`) e a rota `groupChat` em `routes/paths.ts`.
- Seed existente (`data/groups.json`, `data/group-messages.json`) para os dados do frame e do CA1.
- Dependem desta: CCD040, CCD041, CCD042 e CCD043 (R14, indicador de fixada), e as specs de tempo real do chat pessoal
  e das notificações.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `group_messages` | sim | — | lida e gravada (`content_type = TEXT`) |
| `groups`, `group_members` | sim | — | cabeçalho, membro e suspensão |
| `polls`, `poll_options`, `poll_votes` | não | — | não entram: no MVP só texto (depende da L1) |

Seed: `data/group-messages.json` ganha mensagens suficientes num grupo para o CA1 (mais de 50) e uma `pinned = true`.

## Regras

- **Acesso:** `CUSTOMER` e `SELLER` membros ativos (`assertMember`); grupo excluído responde `404 GROUP_NOT_FOUND`.
- **Envio:** só `TEXT`, `content` de 1 a 2.000 caracteres sem espaços nas pontas (depende da L1 e da L9).
- **Grupo suspenso:** histórico liberado, envio recusado com `GROUP_SUSPENDED` (R10).
- **Conteúdo bloqueado:** lista fixa da plataforma em `group-message-rules.ts` (telefone e pagamento fora da plataforma),
  recusa com `MESSAGE_BLOCKED` e `details.rule` (depende da L2).
- **Histórico:** `deleted_at` nulo; ordem por `id` (UUID v7, ordem de criação), devolvido do mais antigo ao mais novo
  dentro da página; `nextCursor` aponta para a página anterior.
- **Fixada:** a mais recente com `pinned = true` e não excluída vem no cabeçalho (`pinnedMessage`).
- **Aviso de mensagem nova:** um aviso `type = GROUP_MESSAGE` por membro (menos o autor) e por grupo enquanto houver um
  não lido do mesmo grupo; o filtro de silêncio entra na CCD041 (depende da L10).
- **Reconexão:** ao reconectar, o cliente entra de novo nas rooms e recarrega a primeira página do histórico, juntando
  pelo `id` (depende da L12).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.

### `GET /api/v1/groups/:id` — R1, R2, R8, R10

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` + membro
- **Sucesso:** `200`

  ```json
  { "data": { "id": "uuid", "name": "Pokémon TCG São Paulo", "description": "…", "accessType": "CLOSED",
      "status": "ACTIVE", "memberCount": 184, "myRole": "ADMIN",
      "pinnedMessage": { "id": "uuid", "content": "Regras do encontro…", "author": { "name": "…", "username": "…" } } } }
  ```

- **Erros:** `401`, `403 NOT_GROUP_MEMBER`, `404 GROUP_NOT_FOUND`

### `GET /api/v1/groups/:id/messages` — R1–R3, R11

- **Acesso:** igual ao anterior
- **Entrada:** `cursor?` (id de mensagem), `limit` (1–50, padrão 50)
- **Sucesso:** `200`

  ```json
  { "data": [{ "id": "uuid", "groupId": "uuid", "contentType": "TEXT", "content": "Alguém tem Charizard?",
      "pinned": false, "createdAt": "…", "author": { "id": "uuid", "name": "…", "username": "…", "avatarUrl": null } }],
    "meta": { "nextCursor": "uuid" } }
  ```

- **Erros:** `400 VALIDATION_ERROR`, `401`, `403 NOT_GROUP_MEMBER`, `404 GROUP_NOT_FOUND`

### Socket.IO — `wss://ws.cromocard.com.br` — R1, R4, R5, R9, R10

- **Handshake:** `auth: { token }`; token ausente ou inválido recusa a conexão (`connect_error` `UNAUTHORIZED`). Ao
  conectar, o socket entra em `user:<id>`.
- **`group:join`** `{ groupId }` → ack `{ data: { groupId } }` ou `{ error: 'NOT_GROUP_MEMBER' | 'GROUP_NOT_FOUND' }`;
  entra em `group:<id>`. **`group:leave`** `{ groupId }` sai da room.
- **`group-message:send`** `{ groupId, content }` → ack `{ data: GroupMessage }` ou `{ error, message, details? }`:

  | `error` | Quando | Requisito |
  |---|---|---|
  | `VALIDATION_ERROR` | payload inválido, vazio ou acima de 2.000 (depende da L9) | R4 |
  | `NOT_GROUP_MEMBER` | não é membro | R1 |
  | `GROUP_SUSPENDED` | grupo suspenso | R10 |
  | `MESSAGE_BLOCKED` | conteúdo bloqueado (depende da L2) | R9 |
  | `INTERNAL_ERROR` | falha ao gravar: nada é emitido | R5 |

- **`group-message:new`** (servidor → room `group:<id>`): o mesmo `GroupMessage` do histórico.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/community/group-messages/` (ADR-004) e infraestrutura do tempo real em `src/socket/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `package.json` | `socket.io` (e `socket.io-client` em `devDependencies`, para os testes) | R1, R5 |
| `src/socket/socket-server.ts` | `createSocketServer(httpServer)`: CORS do `CORS_ORIGIN`, middleware de auth e registro dos handlers dos domínios | R1, R5 |
| `src/socket/socket-auth.middleware.ts` | `io.use` com `verifyAccessToken` (o mesmo de `authenticate`), entra em `user:<id>` | R1 |
| `src/socket/socket-ack.ts` · `socket.types.ts` | envelope do ack no formato do ADR-011 e mapeamento de `AppError` para `{ error, message }` | R5 |
| `src/ws-server.ts` | sobe o Socket.IO no mesmo `http.Server` do `/health` | R1, R5 |
| `group-messages.validator.ts` | `sendGroupMessageSchema`, `listGroupMessagesQuerySchema` | R3, R4 |
| `group-message-rules.ts` | lista fixa de conteúdo bloqueado (depende da L2) | R9 |
| `group-messages.repository.ts` | histórico por cursor, cabeçalho com fixada e contagem, `create` | R2, R3, R8, R11 |
| `group-messages.service.ts` | `getGroup`, `listMessages`, `send` (membro, suspenso, regras, grava, aviso) | R1–R5, R8–R11 |
| `group-messages.socket.ts` | handlers `group:join`, `group:leave`, `group-message:send` (persistência primeiro) | R1, R5 |
| `group-messages.controller.ts` · `.routes.ts` · `.swagger.ts` · `.errors.ts` | as duas rotas e `GROUP_SUSPENDED`, `MESSAGE_BLOCKED` | R1–R3 |
| `src/domains/notifications/notifications.service.ts` | `notifyGroupMessage` agrupado por grupo (depende da L10) | R5 |
| `database/seeds/data/group-messages.json` | mais de 50 mensagens num grupo e uma fixada | R3, R8 |
| `.env.example` · `infra/` | nada novo: o `ws` já tem porta, domínio e `CORS_ORIGIN` | — |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/community/chat/` (ADR-040) e o cliente do tempo real em `src/lib/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `package.json` | `socket.io-client` (mesma major do servidor) | R1 |
| `src/lib/socket.ts` | cliente único com `auth: { token }` do `access-token.ts`, reconexão e renovação do token no `connect_error` | R1, R5 |
| `.env.example` · `public/env.js` · `src/config` | `VITE_WS_URL` (local `http://localhost:3001`) | R1 |
| `group-chat.types.ts` · `group-chat.api.ts` · `group-chat.queries.ts` | cabeçalho e histórico (`useInfiniteQuery` por cursor) | R2, R3, R8 |
| `hooks/useGroupChat.ts` | entra na room, envia com ack, recebe `group-message:new`, recarrega ao reconectar (L12) | R4, R5, R9, R10 |
| `pages/GroupChatPage/` | tela do frame `675-14037` | R2, R4, R8, R10, R12 |
| `components/GroupChatHeader/` | nome, membros, ícones de pesquisa, sino e membros (as ações são das CCD041–CCD043) | R2, R12 |
| `components/MessageList/` · `components/MessageBubble/` | lista com rolagem para cima carregando o `nextCursor`; balão do frame | R2, R3, R12 |
| `components/PinnedMessageBanner/` | indicador da fixada do topo (sem "FIXADA POR", L15 da CCD043) | R8, R12 |
| `components/MessageComposer/` | campo "Mensagem para <grupo>..." e "Enviar", sem ícones de ação (depende da L1); erro de envio, bloqueio e suspenso no estilo do frame | R4, R5, R9, R10, R12 |
| `community.routes.ts` · `routes/paths.ts` | `/comunidades/:id` com `RequireAuth` (a `groupChat` da CCD039) | R1 |

- **Estados:** carregando, erro, sem mensagens e reconectando com `LoadingState`, `ErrorState`, `EmptyState` e um aviso
  no topo do chat (depende da L13).
- **Componentes reaproveitados de `src/components/`:** `Button`, `Textarea`, `Icon`, `Toast`, `Badge`.
- Fora do frame até decisão: reações (L3), resposta citada (L4), avisos de sistema (L5), "✓✓" (L6), online (L7),
  painel "Sobre o grupo" com hashtags e regras (L8), menu "⋯" (L11).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 50 mais recentes em ordem cronológica e a página anterior pelo `nextCursor` | `group-messages.service.spec.ts` · `tests/integration/group-messages.spec.ts` · `GroupChatPage.spec.tsx` |
| CA2 | dois clientes `socket.io-client` na room: o ack traz o id e o outro recebe `group-message:new` | `tests/integration/group-messages.socket.spec.ts` · `useGroupChat.spec.tsx` |
| CA3 | falha simulada no repositório: nenhum evento e ack com erro; a tela avisa | `group-messages.service.spec.ts` · socket · `MessageComposer.spec.tsx` |
| CA4 | só `TEXT` aceito no MVP (depende da L1) | `group-messages.validator.spec.ts` |
| CA5 | cabeçalho com e sem fixada | `group-messages.service.spec.ts` · `PinnedMessageBanner.spec.tsx` |
| CA6 | conteúdo da lista fixa recusado com `MESSAGE_BLOCKED` (depende da L2) | `group-message-rules.spec.ts` · socket |
| CA7 | grupo suspenso: histórico `200`, envio `GROUP_SUSPENDED` | integração · socket |
| CA8 | mensagem com `deleted_at` fora do histórico | integração |
| CA9 | `401` sem token, handshake recusado, `403` e `group:join` recusado para não membro | integração · socket |
| CA10 | print em 1280 px igual ao frame `675-14037`; 375/768/1024 px sem quebra | revisão visual (`/cromocard-revisor`) |

Cobertura de 90% nos arquivos alterados (ADR-060).

## Dependências e riscos

- Tipos `IMAGE`, `CARD`, `LISTING` e `POLL` (R6, R7) dependem da L1: se o PO aceitar algum, o plano ganha as migrations
  de `polls`, `poll_options` e `poll_votes` (copiadas do DBML), os ícones de ação e os formatos, e o Figma precisa do
  frame. Hoje o R6 e o R7 ficam atendidos pela proposta da L1 (só texto).
- Regras de bloqueio (L2), limite de texto (L9) e aviso de mensagem nova (L10) seguem as propostas e podem mudar.
- O processo `api` não emite eventos: tudo que precisa sair em tempo real nasce no processo `ws`. Se uma ação HTTP
  (fixar, remover pela moderação) precisar emitir, isso vira ADR novo (adapter entre processos).

## Decisões técnicas

- O servidor Socket.IO fica no processo `ws` já previsto na infraestrutura (ADR-007, ADR-012), com os handlers no
  domínio (`group-messages.socket.ts`) e a infraestrutura em `src/socket/`, para o chat pessoal e as notificações só
  registrarem os seus handlers.
- Entrar na room é um evento explícito (`group:join`) com checagem de membro, porque a tela abre um grupo por vez e a
  lista de grupos do usuário pode ser grande.
- Ao reconectar, recarregar a primeira página do histórico basta para recuperar o que se perdeu (L12): a página tem 50
  mensagens e o cliente junta pelo `id`, sem parâmetro novo na API.
- Os testes de tempo real sobem o servidor numa porta livre e conectam dois `socket.io-client`, sem mock do Socket.IO.
