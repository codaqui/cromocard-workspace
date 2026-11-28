# Tarefas — CCD046 Visualizar Mensagens

- **Plano:** [plano.md](plano.md) · **User story:** AB#1217
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- As branches dos apps (`feature/1217-visualizar-mensagens`) saem empilhadas sobre a Onda 0 (backend #42, frontend #33).
- Tasks no Azure criadas em 22/11/2026 (Sprint 08). As T14–T16, que vieram das decisões de 24/11/2026, ficam "AB# a
  criar" até o pedido do Daniel, e os commits delas usam o AB#1217 da user story.

## Backend — `apps/cromocard-backend`, branch `feature/1217-visualizar-mensagens`

- [x] **T12** · Criar servidor Socket.IO autenticado por JWT no processo ws (Onda 0, backend #42) — R1 · AB#1218
  - Pronto quando: `npm run dev:ws` aceita conexão com token válido (entra em `user:<id>`), recusa sem token e o teste de
    socket cobre os dois casos.
- [ ] **T1** · Criar migrations de conversations, conversation_participants, messages e user_blocks com o seed do chat — R1, R3, R5, R9, R13 · AB#1219
  - Pronto quando: `prisma migrate dev` cria as 4 tabelas como no DBML e o seed grava as 4 conversas de Gabriel, as não lidas, a mensagem excluída, o bloqueio e os grupos em comum.
- [ ] **T2** · Criar validator e erros do chat — R1, R4, R11–R13, R18 · AB#1220
  - Pronto quando: os schemas recusam `id`/`cursor`/`userId` que não é UUID, `limit` fora de 1–50, `filter`/`scope` fora da lista e `content` vazio ou com mais de 2000 caracteres.
- [ ] **T3** · Criar repository e service de conversas e mensagens — R1, R3–R5, R9, R11, R12, R14 · CA1–CA3, CA8, CA12, CA15 · AB#1221
  - Pronto quando: `chat.service.spec.ts` cobre CA1–CA3, CA8, CA12 e o selo do CA15 com 90% de cobertura no domínio.
- [ ] **T14** · Criar a busca de contatos e o abrir conversa com alguém — R13, R14 · CA13, CA14 · AB# a criar
  - Pronto quando: `chat.service.spec.ts` cobre os quatro `scope`, os bloqueados e suspensos fora e a conversa reaproveitada.
- [ ] **T4** · Criar endpoints GET/POST /me/conversations, GET /me/conversations/:id/messages, POST /me/conversations/:id/read e GET /me/contacts — R1, R3–R5, R11–R14 · CA1, CA3, CA7, CA12–CA14 · AB#1222
  - Pronto quando: as rotas aparecem no `/docs` e `conversations.spec.ts` e `contacts.spec.ts` cobrem os CAs com o PostgreSQL.
- [ ] **T5** · Criar handlers do Socket.IO conversation:join, conversation:leave e message:send — R1, R8, R18 · CA6, CA7, CA16 · AB#1223
  - Pronto quando: `chat-socket.spec.ts` mostra a mensagem gravada antes do `message:new`, o `404` no join de quem não participa e nada emitido se a gravação falhar.
- [ ] **T15** · Criar a presença online no processo ws (presence:list e presence:changed) — R15 · CA15 · AB# a criar
  - Pronto quando: `chat-socket.spec.ts` mostra o ponto online ao conectar o primeiro socket e o offline ao desconectar o último, avisando só quem tem conversa.

## Frontend — `apps/cromocard-frontend`, branch `feature/1217-visualizar-mensagens`

- [x] **T13** · Criar cliente Socket.IO e a variável VITE_WS_URL (Onda 0, frontend #33) — R1 · AB#1224
  - Pronto quando: `socket.spec.ts` cobre o token no handshake e a renovação no `connect_error`.
- [ ] **T6** [P] · Criar types, labels, format, api e queries do chat — R3–R5, R7, R11–R13 · AB#1225
  - Pronto quando: o typecheck passa e `chat.format.spec.ts` cobre a hora da prévia e o separador "Hoje, 31 de Outubro".
- [ ] **T7** · Criar lista de conversas com busca, abas, contagem e rodapé — R2, R3, R5, R11, R12, R14, R15, R19 · CA1–CA3, CA12, CA15 · AB#1226
  - Pronto quando: `ConversationList.spec.tsx` e `ConversationListItem.spec.tsx` cobrem "Você: ", o contador, a busca, as abas, o selo e o ponto online; print igual à coluna do frame `1160-32980`.
- [ ] **T8** · Criar conversa aberta com topo, dica de segurança, mensagens, separador de dia e campo de envio — R4, R5, R16–R18 · CA1, CA3, CA16 · AB#1227
  - Pronto quando: `ConversationView.spec.tsx` e `MessageComposer.spec.tsx` cobrem a ordem, o destaque, as anteriores ao rolar e o envio com falha; print igual ao frame `1160-32980`.
- [ ] **T16** · Criar o modal Nova conversa — R13 · CA11, CA13 · AB# a criar
  - Pronto quando: `NewConversationModal.spec.tsx` cobre a busca, as abas, "Conversar" e "Cancelar"; print igual ao frame `1160-34999`.
- [ ] **T9** · Ligar a conversa e a lista ao Socket.IO (mensagens e presença) — R8, R15 · CA6, CA15 · AB#1228
  - Pronto quando: `useChatSocket.spec.tsx` e `usePresence.spec.tsx` mostram o `message:new` entrando lido e o ponto online mudando.
- [ ] **T10** · Criar página Mensagens com rota, item no menu, Ver Perfil e os estados — R1, R2, R6, R7, R16 · CA4, CA5, CA9, CA10 · AB#1229
  - Pronto quando: `MessagesPage.spec.tsx` cobre vazio e erro; prints iguais aos frames `1160-32980` e `1160-36236`, sem quebra em 320–1920 px.

## Fechamento — workspace

- [ ] **T11** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1230
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T2, T3, T4, T5, T10, T12, T13 |
| R2 | T7, T10 |
| R3 | T1, T3, T4, T6, T7 |
| R4 | T2, T3, T4, T6, T8 |
| R5 | T1, T3, T4, T6, T7, T8 |
| R6 | T10 |
| R7 | T6, T10 |
| R8 | T5, T9 |
| R9 | T1, T3 |
| R10 | T7, T8, T10, T16 |
| R11 | T2, T3, T4, T6, T7 |
| R12 | T3, T4, T6, T7 |
| R13 | T1, T2, T4, T6, T14, T16 |
| R14 | T3, T4, T7, T14 |
| R15 | T7, T9, T15 |
| R16 | T8, T10 |
| R17 | T8 |
| R18 | T2, T5, T8 |
| R19 | T7 |
