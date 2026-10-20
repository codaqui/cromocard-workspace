# Tarefas — CCDnnn <Nome>

- **Plano:** [plano.md](plano.md) · **User story:** AB#<id>
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-<descricao>`

- [ ] **T1** · <Verbo + objeto, ex.: Criar migration create_refresh_tokens_table> — R3 · AB#<task>
  - Pronto quando: <resultado verificável>.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-<descricao>`

- [ ] **T5** [P] · <Verbo + objeto, ex.: Criar formulário de login> — R1, R2 · CA1 · AB#<task>
  - Pronto quando: <resultado verificável>.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada`
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T5 |
