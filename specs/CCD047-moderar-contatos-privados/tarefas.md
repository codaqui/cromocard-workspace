# Tarefas — CCD047 Moderar Contatos Privados

- **Plano:** [plano.md](plano.md) · **User story:** AB# a criar (não encontrada no board)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- As branches dos apps saem de `develop` depois do merge da CCD046; a T9 espera a página de Configurações da CCD051.
- Os `AB#` das Tasks ficam "a criar": só com o pedido do Daniel.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-moderar-contatos-privados`

- [ ] **T1** · Criar migration create_user_blocks_table e o seed do contato bloqueado — R6, R13, R14 · AB# a criar
  - Pronto quando: a tabela existe com o único `(blocker_id, blocked_id)` e o seed tem Marcos bloqueado por Gabriel.
- [ ] **T2** · Criar validator e erros do bloqueio e da denúncia — R1, R4 · AB# a criar
  - Pronto quando: os schemas recusam `report` sem `reason`, motivo fora da lista e `description` com mais de 500 caracteres.
- [ ] **T3** · Criar repository e service de bloquear, denunciar e desbloquear — R1, R3, R6, R9, R13, R14 · CA1–CA3, CA8 · AB# a criar
  - Pronto quando: `user-blocks.service.spec.ts` cobre CA1–CA3 e CA8 (restaura a linha), com a transação desfeita se a denúncia falhar.
- [ ] **T4** · Recusar envio no chat com bloqueio ativo e expor o bloqueio na lista — R7, R8, R12 · CA5 · AB# a criar
  - Pronto quando: `chat.service.spec.ts` e `chat-socket.spec.ts` mostram `422 CONTACT_BLOCKED` nos dois sentidos, sem gravar nem emitir, e a lista devolve `block`.
- [ ] **T5** · Criar endpoints POST /me/blocks, POST /me/contact-reports, GET /me/blocks e DELETE /me/blocks/:userId — R1, R4, R13, R14 · CA4, CA7, CA9, CA10 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs` e `chat-blocks.spec.ts` cobre CA1, CA4, CA7–CA10.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-moderar-contatos-privados`

- [ ] **T6** [P] · Criar types, schemas, labels, api e queries do bloqueio — R3, R4, R6, R9, R10 · AB# a criar
  - Pronto quando: o typecheck passa e o schema exige o motivo nas opções com denúncia.
- [ ] **T7** · Criar modal Bloquear ou denunciar — R2–R5, R10, R11 · CA1–CA4, CA6, CA12 · AB# a criar
  - Pronto quando: `ContactModerationDialog.spec.tsx` cobre as três opções, o motivo obrigatório e o cancelar; print em 1280 px igual ao frame `1160-34298` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Acrescentar o escudo e o aviso de contato bloqueado na conversa — R2, R8, R12, R13 · CA7, CA11, CA13 · AB# a criar
  - Pronto quando: `ConversationView.spec.tsx` cobre o aviso e o desbloquear; print em 1280 px igual aos frames `1160-32980` e `1160-37184` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Criar linha Contatos bloqueados e a lista Ver bloqueados em Configurações — R13, R14 · CA9, CA14 · AB# a criar
  - Pronto quando: `PrivacySection.spec.tsx` e `BlockedContactsDialog.spec.tsx` cobrem "1 contato bloqueado" e o desbloquear; print em 1280 px igual ao frame `1160-41305` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T10** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T3, T5 |
| R2 | T7, T8 |
| R3 | T3, T6, T7 |
| R4 | T2, T5, T6, T7 |
| R5 | T7 |
| R6 | T1, T3, T6 |
| R7 | T4 |
| R8 | T4, T8 |
| R9 | T3, T6 |
| R10 | T6, T7 |
| R11 | T7 |
| R12 | T4, T8 |
| R13 | T1, T3, T5, T8, T9 |
| R14 | T1, T3, T5, T9 |
| R15 | T7, T8, T9 |
