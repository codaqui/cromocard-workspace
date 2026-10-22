# Tarefas — CCD063 Exportar Relatórios Gerenciais

- **Plano:** [plano.md](plano.md) · **User story:** AB#338
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/338-exportar-relatorios`

- [ ] **T1** · Criar validator, errors e repository dos relatórios — R4, R5, R10, R11, R15 · AB#574
  - Pronto quando: o repository devolve as linhas de cadastros e de catálogo do período, sem excluídos.
- [ ] **T2** · Criar exportadores CSV e PDF — R10 · CA2, CA3 · AB#575
  - Pronto quando: os testes geram um CSV com BOM e `;` e um PDF com cabeçalho e tabela.
- [ ] **T3** · Criar service de pré-visualização, exportação com auditoria e histórico — R6–R9, R12 · CA1, CA4 · AB#576
  - Pronto quando: `reports.service.spec.ts` cobre os critérios e a exportação grava `EXPORT_REPORT`.
- [ ] **T4** · Criar rotas de relatórios, exportação e histórico — R1 · CA6 · AB#577
  - Pronto quando: as 3 rotas aparecem no `/docs` e o download chega com o nome do arquivo.

## Frontend — `apps/cromocard-frontend`, branch `feature/338-exportar-relatorios`

- [ ] **T5** [P] · Criar types, api e queries dos relatórios — R9 · AB#578
  - Pronto quando: o download por `blob` funciona e o typecheck passa.
- [ ] **T6** · Criar página de Relatórios com pré-visualização, exportação e histórico — R2–R8, R12–R14 · CA1, CA4, CA5 · AB#579
  - Pronto quando: `ReportsPage.spec.tsx` cobre filtro vazio, cancelar e exportar.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#580
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4 |
| R2–R8 | T3, T6 |
| R9 | T3, T5 |
| R10 | T1, T2 |
| R11 | T1 |
| R12–R14 | T3, T6 |
| R15 | T1 |
| R16 | T3, T4, T6 |
