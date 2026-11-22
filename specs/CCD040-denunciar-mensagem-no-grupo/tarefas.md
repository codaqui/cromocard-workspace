# Tarefas — CCD040 Denunciar Mensagem no Grupo

- **Plano:** [plano.md](plano.md) · **User story:** AB#143
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure: a criar (só com o pedido do Daniel). Sai depois da CCD044.

## Backend — `apps/cromocard-backend`, branch `feature/143-denunciar-mensagem-no-grupo`

- [ ] **T1** · Criar motivos de denúncia de mensagem e ligar a fila da moderação a eles — R3, R7 · CA4 · AB# a criar
  - Pronto quando: a fila da CCD062 filtra a gravidade pelos códigos, o seed e as denúncias antigas usam códigos e
    `community-admin.service.spec.ts` continua verde.
- [ ] **T2** · Criar service de denúncia de mensagem com aviso aos administradores do grupo — R1, R4–R6 · CA1–CA3 · AB# a criar
  - Pronto quando: `group-message-reports.service.spec.ts` cobre gravar, avisar, `null` sem descrição e os `409`/`422`.
- [ ] **T3** · Criar endpoint POST /groups/:id/messages/:messageId/reports — R1, R5 · CA1, CA2, CA6 · AB# a criar
  - Pronto quando: a rota aparece no `/docs` e a integração cobre `201`, `400`, `401`, `403` e `404`.

## Frontend — `apps/cromocard-frontend`, branch `feature/143-denunciar-mensagem-no-grupo`

- [ ] **T4** [P] · Criar api, rótulos e schema da denúncia de mensagem — R3, R4, R7 · AB# a criar
  - Pronto quando: o typecheck passa e a fila da CCD062 mostra os rótulos novos.
- [ ] **T5** · Criar menu de ações da mensagem com Denunciar Mensagem — R2 · CA1 · AB# a criar
  - Pronto quando: `MessageActionsMenu.spec.tsx` mostra a opção só em mensagem de outro membro.
- [ ] **T6** · Criar modal Denunciar mensagem — R3–R5, R8–R10 · CA1–CA3, CA5, CA7 · AB# a criar
  - Pronto quando: `ReportMessageDialog.spec.tsx` cobre enviar, motivo obrigatório, cancelar e o aviso de sucesso; print
    em 1280 px igual ao frame `675-14942` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T3 |
| R2 | T5 |
| R3 | T1, T4, T6 |
| R4 | T2, T4, T6 |
| R5 | T2, T3, T6 |
| R6 | T2 |
| R7 | T1, T4 |
| R8, R9, R10 | T6 |
