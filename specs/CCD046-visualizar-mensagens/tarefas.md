# Tarefas — CCD046 Visualizar Mensagens

- **Plano:** [plano.md](plano.md) · **User story:** AB# a criar (não encontrada no board)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende do servidor Socket.IO da CCD044: as branches dos apps saem de `develop` depois do merge dela (T5, T9).
- Os `AB#` das Tasks ficam "a criar": só com o pedido do Daniel.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-visualizar-mensagens`

- [ ] **T1** · Criar migrations de conversations, conversation_participants e messages com o seed do chat — R1, R3, R5, R9 · AB# a criar
  - Pronto quando: `prisma migrate dev` cria as 3 tabelas como no DBML e o seed grava as 4 conversas de Gabriel, a não lida de Renata e uma mensagem excluída.
- [ ] **T2** · Criar validator e erros do chat — R1, R4, R8 · AB# a criar
  - Pronto quando: os schemas recusam `id`/`cursor` que não é UUID, `limit` fora de 1–50 e `content` vazio.
- [ ] **T3** · Criar repository e service de conversas e mensagens — R1, R3–R5, R9 · CA1–CA3, CA8 · AB# a criar
  - Pronto quando: `chat.service.spec.ts` cobre CA1–CA3 e CA8 com 90% de cobertura no domínio.
- [ ] **T4** · Criar endpoints GET /me/conversations, GET /me/conversations/:id/messages e POST /me/conversations/:id/read — R1, R3–R5 · CA1, CA3, CA7 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs` e `chat-conversations.spec.ts` cobre CA1, CA3, CA7 e CA8 (`401` e `404`).
- [ ] **T5** · Criar handlers do Socket.IO conversation:join, conversation:leave e message:send — R1, R8 · CA6, CA7 · AB# a criar
  - Pronto quando: `chat-socket.spec.ts` mostra a mensagem gravada antes do `message:new`, o `404` no join de quem não participa e nada emitido se a gravação falhar.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-visualizar-mensagens`

- [ ] **T6** [P] · Criar types, labels, format, api e queries do chat — R3–R5, R7 · AB# a criar
  - Pronto quando: o typecheck passa e `chat.format.spec.ts` cobre a hora da prévia e o separador "Hoje, 31 de Outubro".
- [ ] **T7** · Criar lista de conversas — R2, R3, R5 · CA1–CA3 · AB# a criar
  - Pronto quando: `ConversationListItem.spec.tsx` cobre "Você: " e o contador; print em 1280 px igual ao frame `1160-32980` (coluna "Conversas") e sem quebra em 375/768/1024 px.
- [ ] **T8** · Criar conversa aberta com mensagens, separador de dia e campo de envio — R4, R5, R8 · CA1, CA3 · AB# a criar
  - Pronto quando: `ConversationView.spec.tsx` cobre a ordem e o destaque da não lida; print em 1280 px igual ao frame `1160-32980` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Ligar a conversa ao Socket.IO para receber mensagens em tempo real — R8 · CA6 · AB# a criar
  - Pronto quando: `useConversationSocket.spec.tsx` mostra o `message:new` entrando na conversa e atualizando a prévia e a hora da lista.
- [ ] **T10** · Criar página Mensagens com rota, item no menu e os estados — R1, R2, R6, R7 · CA4, CA5, CA9, CA10 · AB# a criar
  - Pronto quando: `MessagesPage.spec.tsx` cobre vazio e erro; print em 1280 px igual aos frames `1160-32980` e `1160-36236` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T11** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T2, T3, T4, T5, T10 |
| R2 | T7, T10 |
| R3 | T1, T3, T4, T6, T7 |
| R4 | T2, T3, T4, T6, T8 |
| R5 | T1, T3, T4, T6, T7, T8 |
| R6 | T10 |
| R7 | T6, T10 |
| R8 | T2, T5, T8, T9 |
| R9 | T1, T3 |
| R10 | T7, T8, T10 |
