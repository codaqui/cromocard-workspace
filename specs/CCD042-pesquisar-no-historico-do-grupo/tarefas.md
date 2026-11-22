# Tarefas — CCD042 Pesquisar no Histórico do Grupo

- **Plano:** [plano.md](plano.md) · **User story:** AB#145
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/145-pesquisar-no-historico-do-grupo`

- [ ] **T1** · Criar endpoint GET /groups/:id/messages/search — R1, R3–R6, R8 · CA1, CA2, CA5, CA6 · AB#1183
  - Pronto quando: a rota aparece no `/docs` e a integração cobre texto, nome da carta, excluída, `matches`, `total`,
    `401` e `403`.
- [ ] **T2** · Acrescentar a página ao redor de uma mensagem no histórico do grupo — R7 · CA3 · AB#1184
  - Pronto quando: a integração cobre `around` com os dois cursores e o `404` da mensagem excluída.
- [ ] **T3** [P] · Ampliar o seed com mensagens para a busca — R4, R5 · AB#1185
  - Pronto quando: o grupo do frame tem mensagens com "Charizard", uma `CARD` e uma excluída.

## Frontend — `apps/cromocard-frontend`, branch `feature/145-pesquisar-no-historico-do-grupo`

- [ ] **T4** [P] · Criar api e queries da busca no grupo — R3, R4, R7 · AB#1186
  - Pronto quando: o typecheck passa.
- [ ] **T5** · Criar painel Buscar no grupo — R2, R3, R6, R8, R9 · CA1, CA4, CA7 · AB#1187
  - Pronto quando: `GroupSearchPanel.spec.tsx` cobre resultados destacados e o estado sem resultado; print em 1280 px
    igual ao frame `675-14484` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Rolar o chat até o resultado e destacar a mensagem — R7 · CA3 · AB#1188
  - Pronto quando: `MessageList.spec.tsx` cobre carregar ao redor, rolar e destacar, e o "✕" tira o destaque.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1189
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1 |
| R2 | T5 |
| R3 | T1, T4, T5 |
| R4 | T1, T3, T4 |
| R5 | T1, T3 |
| R6 | T1, T5 |
| R7 | T2, T4, T6 |
| R8 | T1, T5 |
| R9 | T5 |
