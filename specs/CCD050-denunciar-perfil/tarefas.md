# Tarefas — CCD050 Denunciar Perfil

- **Plano:** [plano.md](plano.md) · **User story:** AB#1265
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- O backend usa o módulo `/profiles` da CCD049; a T6 espera a página pública da CCD080.
- Os `AB#` das Tasks ficam "a criar": só com o pedido do Daniel.

## Backend — `apps/cromocard-backend`, branch `feature/1265-denunciar-perfil`

- [ ] **T1** · Criar validator e erros da denúncia de perfil — R3–R6 · AB#1266
  - Pronto quando: o schema recusa motivo ausente ou fora da lista e detalhe com mais de 500 caracteres.
- [ ] **T2** · Criar service de denúncia de perfil — R6, R9 · CA1, CA6 · AB#1267
  - Pronto quando: `profiles.service.spec.ts` cobre CA1, CA6 e o `CANNOT_REPORT_SELF`.
- [ ] **T3** · Criar endpoint POST /profiles/:username/reports — R1, R4–R6, R9 · CA1–CA3, CA5, CA6 · AB#1268
  - Pronto quando: a rota aparece no `/docs` e `profiles-reports.spec.ts` cobre CA1–CA3, CA5 e CA6.

## Frontend — `apps/cromocard-frontend`, branch `feature/1265-denunciar-perfil`

- [ ] **T4** [P] · Criar types, schemas, labels, api e queries da denúncia de perfil — R3–R7 · AB#1269
  - Pronto quando: o typecheck passa e o schema exige o motivo.
- [ ] **T5** · Criar modal Denunciar perfil — R3–R5, R7, R8 · CA1, CA2, CA4, CA8 · AB#1270
  - Pronto quando: `ReportProfileDialog.spec.tsx` cobre o envio, o motivo obrigatório e o cancelar; print em 1280 px igual ao frame `1160-17495` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Acrescentar Denunciar perfil no perfil público — R1, R2 · CA5, CA7 · AB#1271
  - Pronto quando: `ReportProfileLink.spec.tsx` cobre o visitante (Entre para continuar) e o dono (sem link); print em 1280 px igual ao frame `1160-1396` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1272
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3, T6 |
| R2 | T6 |
| R3 | T1, T4, T5 |
| R4 | T1, T3, T4, T5 |
| R5 | T1, T3, T4, T5 |
| R6 | T1, T2, T3, T4 |
| R7 | T4, T5 |
| R8 | T5 |
| R9 | T2, T3 |
| R10 | T5, T6 |
