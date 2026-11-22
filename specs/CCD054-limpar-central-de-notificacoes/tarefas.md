# Tarefas — CCD054 Limpar Central de Notificações

- **Plano:** [plano.md](plano.md) · **User story:** não encontrada no board (AB# a criar)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- As branches dos apps saem da branch da CCD053 e entram depois dela.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-limpar-central-de-notificacoes`

- [ ] **T1** · Criar service de marcar todas como lidas e limpar a central — R1, R4, R7, R8 · CA1, CA3–CA5 · AB# a criar
  - Pronto quando: `notifications.service.spec.ts` cobre as duas ações, a central vazia e que as de outro usuário não mudam.
- [ ] **T2** · Criar endpoints POST /notifications/read-all e DELETE /notifications — R1, R4, R8 · CA1, CA4, CA5 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs` e `tests/integration/notifications.spec.ts` cobre `200` e `401`.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-limpar-central-de-notificacoes`

- [ ] **T3** [P] · Criar mutations de marcar todas e limpar — R4, R5, R8 · AB# a criar
  - Pronto quando: o typecheck passa e `notifications.api.spec.ts` cobre as duas chamadas.
- [ ] **T4** · Criar botão Marcar todas como lidas com o estado Tudo em dia — R8, R9 · CA4, CA6, CA7, CA8 · AB# a criar
  - Pronto quando: `MarkAllReadButton.spec.tsx` cobre sucesso e erro; print em 1280 px igual aos frames `490-796` e `675-11716` e sem quebra em 375/768/1024 px.
- [ ] **T5** · Criar opção Limpar notificações com confirmação — R2, R3, R5–R7, R9 · CA1–CA3, CA6, CA9 · AB# a criar
  - Pronto quando: `ClearNotificationsButton.spec.tsx` cobre confirmar, cancelar, central vazia e erro; no estilo dos botões do frame `490-796`, sem quebra em 375/768/1024 px (o `675-12111` depende da L5).

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T2 |
| R2, R3, R6 | T5 |
| R4 | T1, T2, T3 |
| R5 | T3, T5 |
| R7 | T1, T5 |
| R8 | T1, T2, T3, T4 |
| R9 | T4, T5 |
