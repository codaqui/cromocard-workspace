# Tarefas — CCD052 Exclusão da Conta

- **Plano:** [plano.md](plano.md) · **User story:** AB# a criar (não encontrada no board)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- As branches dos apps saem de `develop` depois do merge da CCD051 (página de Configurações e `CURRENT_PASSWORD_INCORRECT`).
- Os `AB#` das Tasks ficam "a criar": só com o pedido do Daniel.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-exclusao-da-conta`

- [ ] **T1** · Criar validator e erro da confirmação de exclusão — R4, R7 · CA3 · AB# a criar
  - Pronto quando: o schema aceita `password` ou `confirmation = "EXCLUIR"` e recusa os outros casos.
- [ ] **T2** · Excluir a conta com confirmação e revogar todas as sessões — R1, R4, R5, R7 · CA1, CA3, CA7, CA8 · AB# a criar
  - Pronto quando: `users.service.spec.ts` cobre CA1 e CA3, e `users.spec.ts`/`auth.spec.ts` cobrem o `401`, a transação e o refresh recusado depois.
- [ ] **T3** · Filtrar o dono excluído nas consultas públicas de perfil — R6 · CA5 · AB# a criar
  - Pronto quando: a rota pública de perfil responde `404` para a conta excluída num teste de integração.
- [ ] **T4** · Criar endpoint POST /auth/restore — R9, R10 · CA6 · AB# a criar
  - Pronto quando: a rota aparece no `/docs` e `auth.service.spec.ts`/`auth.spec.ts` cobrem a reativação, o `401` e o `409`.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-exclusao-da-conta`

- [ ] **T5** [P] · Ajustar types, schemas, labels, api e queries da exclusão e da reativação — R3–R5, R7, R10 · AB# a criar
  - Pronto quando: o typecheck passa e `deleteMe` encerra a sessão ao concluir.
- [ ] **T6** · Criar modal Excluir sua conta — R3, R4, R7, R8 · CA1–CA4, CA10 · AB# a criar
  - Pronto quando: `DeleteAccountDialog.spec.tsx` cobre CA1–CA4; print em 1280 px igual ao frame `1160-43273` e sem quebra em 375/768/1024 px.
- [ ] **T7** · Mover o bloco Excluir conta para Configurações — R2 · CA9 · AB# a criar
  - Pronto quando: o bloco está na `SettingsPage` e saiu da `ProfilePage`; print em 1280 px igual ao bloco "Excluir conta" do frame `1160-41305` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Acrescentar Reativar conta no login de conta excluída — R9, R10 · CA6, CA11 · AB# a criar
  - Pronto quando: `LoginPanel.spec.tsx` cobre a mensagem e a reativação; print em 1280 px igual ao frame `1160-561` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2 |
| R2 | T7 |
| R3 | T5, T6 |
| R4 | T1, T2, T5, T6 |
| R5 | T2, T5 |
| R6 | T3 |
| R7 | T1, T2, T5, T6 |
| R8 | T6 |
| R9 | T4, T8 |
| R10 | T4, T5, T8 |
| R11 | T6, T7, T8 |
