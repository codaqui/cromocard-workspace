# Tarefas — CCD047 Moderar Contatos Privados

- **Plano:** [plano.md](plano.md) · **User story:** AB#1231
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- As branches dos apps (`feature/1231-moderar-contatos-privados`) saem empilhadas sobre a CCD046 (backend #49, frontend
  #36). A T11 e a T12, que vieram das decisões de 26/11/2026, foram criadas no Azure no mesmo dia (AB#1561 e AB#1562); os commits delas usam o AB#1231.

## Backend — `apps/cromocard-backend`, branch `feature/1231-moderar-contatos-privados`

- [x] **T1** · Criar migration create_report_evidences_table e o seed da denúncia do chat — R9, R16, R19 · AB#1232
  - Pronto quando: a tabela existe como no DBML (ADR-072) e o seed tem a denúncia da Ana contra a Carla com um print.
- [x] **T2** · Criar validator e erros do bloqueio e da denúncia — R1, R4, R16, R18 · AB#1233
  - Pronto quando: os schemas recusam motivo fora da lista, `description` acima de 500 e `userId` que não é UUID.
- [x] **T3** · Criar repository e service de bloquear, denunciar e desbloquear — R1, R3, R6, R9, R13, R14, R16, R18 · CA1–CA3, CA8, CA17 · AB#1234
  - Pronto quando: `contact-moderation.service.spec.ts` cobre CA1–CA3, CA8 e CA17, com a transação desfeita e os prints apagados se a denúncia falhar.
- [x] **T4** · Recusar envio no chat com bloqueio ativo e expor o bloqueio na lista — R7, R8, R12, R17 · CA5 · AB#1235
  - Pronto quando: `chat.service.spec.ts` e `chat-socket.spec.ts` mostram `422 CONTACT_BLOCKED` nos dois sentidos, sem gravar nem emitir, e a lista devolve `block`.
- [x] **T5** · Criar endpoints POST /me/blocks, DELETE /me/blocks/:userId, GET /me/blocks e POST /me/contact-reports (multipart) — R1, R4, R13, R14, R16 · CA4, CA7, CA9, CA10, CA15 · AB#1236
  - Pronto quando: as rotas aparecem no `/docs` e `contact-moderation.spec.ts` cobre CA1, CA4, CA7–CA10, CA15 e CA17 com o PostgreSQL.
- [x] **T11** · Estender a Fila de moderação às denúncias do chat e resolver a denúncia pela sanção — R19 · CA18 · AB#1561
  - Pronto quando: `community-admin.service.spec.ts` e a integração mostram o card do chat com `origin`, `evidences` e a gravidade, o dispensar e a sanção resolvendo a denúncia.

## Frontend — `apps/cromocard-frontend`, branch `feature/1231-moderar-contatos-privados`

- [x] **T6** [P] · Criar types, labels, api e queries do bloqueio e da denúncia — R3, R4, R6, R9, R10, R16 · AB#1237
  - Pronto quando: o typecheck passa e os testes da api cobrem o `multipart` da denúncia.
- [x] **T7** · Criar modal Bloquear ou denunciar com os prints — R2–R5, R10–R12, R16, R18, R20 · CA1–CA4, CA6, CA12, CA15, CA17, CA19 · AB#1238
  - Pronto quando: `ContactModerationDialog.spec.tsx` cobre as três opções, motivo e print obrigatórios, os limites, o cancelar, o 409 e o erro; print em 1280 px igual ao frame `1160-34298`.
- [x] **T8** · Acrescentar o escudo e os avisos de contato bloqueado na conversa — R2, R8, R12, R13, R17 · CA7, CA11, CA13, CA16 · AB#1239
  - Pronto quando: `BlockedNotice.spec.tsx` e `ConversationView.spec.tsx` cobrem os dois avisos e o desbloquear; print em 1280 px igual aos frames `1160-32980` e `1160-37184`.
- [x] **T9** · Criar o modal Contatos bloqueados para a CCD051 — R13, R14 · CA9 · AB#1240
  - Pronto quando: `BlockedContactsDialog.spec.tsx` cobre "1 contato bloqueado", o vazio e o desbloquear, e o `index.ts` exporta o modal.
- [x] **T12** · Mostrar o card do chat na Fila de moderação — R19 · CA18 · AB#1562
  - Pronto quando: `ReportCard.spec.tsx` cobre a origem "Chat pessoal", os prints e as ações "Dispensar Denúncia" e "Aplicar sanção ao autor"; o subtítulo da fila mudou.

## Fechamento — workspace

- [ ] **T10** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1241
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T3, T5 |
| R2 | T7, T8 |
| R3 | T3, T6, T7 |
| R4 | T2, T5, T6, T7 |
| R5 | T7 |
| R6 | T3, T6 |
| R7 | T4 |
| R8 | T4, T8 |
| R9 | T1, T3, T6 |
| R10 | T6, T7 |
| R11 | T7 |
| R12 | T4, T7, T8 |
| R13 | T3, T5, T8, T9 |
| R14 | T3, T5, T9 |
| R15 | T7, T8 |
| R16 | T1, T2, T3, T5, T6, T7 |
| R17 | T4, T8 |
| R18 | T2, T3, T7 |
| R19 | T1, T11, T12 |
| R20 | T7 |
