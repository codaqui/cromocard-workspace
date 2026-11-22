# Tarefas — CCD044 Interagir no Chat do Grupo

- **Plano:** [plano.md](plano.md) · **User story:** AB#147
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/147-interagir-no-chat-do-grupo`

- ~~**T1**~~ · ~~Criar servidor Socket.IO autenticado por JWT no processo ws~~ — movida para a CCD046 (T12) (divisão por módulo de 22/11/2026: a base do tempo real fica com o Daniel, dono de Mensagens e Notificações). Esta story usa o servidor de lá.
- [ ] **T2** · Criar endpoints GET /groups/:id e GET /groups/:id/messages — R1–R3, R8, R10, R11 · CA1, CA5, CA7–CA9 · AB#1201
  - Pronto quando: as rotas aparecem no `/docs` e a integração cobre cursor, fixada, suspenso, excluída, `401` e `403`.
- [ ] **T3** · Criar envio de mensagem do grupo pelo Socket.IO com persistência primeiro — R1, R4–R6, R9, R10 · CA2–CA4, CA6, CA7, CA9 · AB#1202
  - Pronto quando: o teste com dois clientes cobre o envio, a falha sem emissão, o bloqueio, o suspenso e o não membro.
- [ ] **T4** · Criar aviso de mensagem nova agrupado por grupo — R5 · AB#1203
  - Pronto quando: `notifications.service.spec.ts` cobre um aviso por membro e grupo, sem aviso para o autor (depende da L10).
- [ ] **T5** [P] · Ampliar o seed de mensagens do grupo — R3, R8 · AB#1204
  - Pronto quando: um grupo do seed tem mais de 50 mensagens e uma fixada.

## Frontend — `apps/cromocard-frontend`, branch `feature/147-interagir-no-chat-do-grupo`

- ~~**T6**~~ · ~~Criar cliente Socket.IO e a variável VITE_WS_URL~~ — movida para a CCD046 (T13) (divisão por módulo de 22/11/2026: a base do tempo real fica com o Daniel, dono de Mensagens e Notificações).
- [ ] **T7** · Criar api, queries e o hook useGroupChat — R2–R5, R9, R10 · CA1–CA3 · AB#1205
  - Pronto quando: `useGroupChat.spec.tsx` cobre receber, enviar com ack, erro e recarga ao reconectar.
- [ ] **T8** · Criar tela do chat do grupo — R2, R4, R6–R12 · CA1–CA3, CA5–CA8, CA10 · AB#1206
  - Pronto quando: `GroupChatPage.spec.tsx` cobre histórico, envio, fixada, bloqueio e suspenso; print em 1280 px igual
    ao frame `675-14037` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1207
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T2, T3, T6 |
| R2, R3 | T2, T7, T8 |
| R4 | T3, T7, T8 |
| R5 | T1, T3, T4, T6, T7 |
| R6, R7 | T3, T8 (só texto, depende da L1) |
| R8 | T2, T5, T8 |
| R9, R10 | T3, T7, T8 |
| R11 | T2, T8 |
| R12 | T8 |
