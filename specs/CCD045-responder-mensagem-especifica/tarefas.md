# Tarefas — CCD045 Responder Mensagem Específica

- **Plano:** [plano.md](plano.md) · **User story:** AB#1208
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- As branches dos apps saem de `develop` depois do merge da CCD046 e da CCD047 (que dependem da CCD044).
- Os `AB#` das Tasks ficam "a criar": só com o pedido do Daniel.

## Backend — `apps/cromocard-backend`, branch `feature/1208-responder-mensagem-especifica`

- [ ] **T1** · Acrescentar replyToId ao validator e os erros da citação — R1, R5, R6, R9, R10 · CA3, CA5 · AB#1209
  - Pronto quando: `chat.validator.spec.ts` recusa `content` só com espaços e `replyToId` que não é UUID.
- [ ] **T2** · Validar e gravar a mensagem citada no envio — R5, R6, R8, R10, R11 · CA1, CA4, CA5, CA7, CA8 · AB#1210
  - Pronto quando: `chat.service.spec.ts` cobre a ordem das regras (participação, bloqueio, citação) e nada é gravado em cada erro.
- [ ] **T3** · Devolver a citação no message:send e no histórico de mensagens — R1, R7, R8 · CA1, CA6 · AB#1211
  - Pronto quando: `chat-socket.spec.ts` e `chat-conversations.spec.ts` mostram `replyTo` no `message:new` e no `GET /messages`, o `403` de quem não participa e o seed com a resposta de exemplo.

## Frontend — `apps/cromocard-frontend`, branch `feature/1208-responder-mensagem-especifica`

- [ ] **T4** [P] · Acrescentar replyTo aos types e os textos da resposta — R3, R4, R9, R10 · AB#1212
  - Pronto quando: o typecheck passa com o `Message` novo.
- [ ] **T5** · Criar ações da mensagem com Responder — R2 · CA10 · AB#1213
  - Pronto quando: `MessageActions.spec.tsx` abre as ações ao selecionar a mensagem; print em 1280 px igual ao frame `1160-33616` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Criar bloco Respondendo a e ligar a citação ao campo de envio — R3–R5, R8–R11 · CA1–CA4, CA7, CA9 · AB#1214
  - Pronto quando: `ReplyPreview.spec.tsx` e `MessageComposer.spec.tsx` cobrem CA1–CA4 e CA7; print em 1280 px igual ao frame `1160-32980` e sem quebra em 375/768/1024 px.
- [ ] **T7** · Mostrar a citação na mensagem enviada — R7 · CA1, CA9 · AB#1215
  - Pronto quando: `MessageBubble.spec.tsx` cobre a citação e "Mensagem indisponível"; print em 1280 px igual ao frame `1160-32980` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1216
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T3 |
| R2 | T5 |
| R3 | T4, T6 |
| R4 | T4, T6 |
| R5 | T1, T2, T6 |
| R6 | T1, T2 |
| R7 | T3, T7 |
| R8 | T2, T3, T6 |
| R9 | T1, T4, T6 |
| R10 | T1, T2, T4, T6 |
| R11 | T2, T6 |
| R12 | T5, T6, T7 |
