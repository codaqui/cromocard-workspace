# Tarefas — CCD049 Exibir Vitrine de Conquistas

- **Plano:** [plano.md](plano.md) · **User story:** AB# a criar (não encontrada no board)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- A T8 espera a página "Perfil" da CCD048 e a T9 a página pública da CCD080.
- Os `AB#` das Tasks ficam "a criar": só com o pedido do Daniel.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-exibir-vitrine-de-conquistas`

- [ ] **T1** · Criar migrations de achievements e user_achievements com o seed das conquistas — R2, R4, R7 · AB# a criar
  - Pronto quando: as tabelas existem como no DBML e o seed tem as 5 conquistas, 3 obtidas por Gabriel e por tiago_trocas, uma excluída e um usuário sem nenhuma.
- [ ] **T2** · Criar repository e service das conquistas obtidas e do detalhe — R2, R4, R6, R8 · CA1, CA5, CA6 · AB# a criar
  - Pronto quando: `achievements.service.spec.ts` cobre CA1, CA5 e CA6.
- [ ] **T3** · Criar endpoint GET /users/me/achievements — R1, R3 · CA1, CA7 · AB# a criar
  - Pronto quando: a rota aparece no `/docs` e responde `401` sem login.
- [ ] **T4** · Criar módulo público /profiles com as rotas de conquistas — R5, R6, R9 · CA2, CA5, CA8 · AB# a criar
  - Pronto quando: `achievements.spec.ts` cobre CA2, CA5, CA7 e CA8 sem login nas rotas públicas.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-exibir-vitrine-de-conquistas`

- [ ] **T5** [P] · Criar types, labels, api e queries das conquistas — R3–R8 · AB# a criar
  - Pronto quando: o typecheck passa.
- [ ] **T6** · Criar cartão e vitrine de conquistas — R3–R5, R7 · CA1, CA2, CA4 · AB# a criar
  - Pronto quando: `AchievementShowcase.spec.tsx` cobre a lista e o vazio.
- [ ] **T7** · Criar detalhes da conquista com o aviso de indisponível — R6, R8 · CA3, CA5 · AB# a criar
  - Pronto quando: `AchievementDetailDialog.spec.tsx` cobre o detalhe e o `404`.
- [ ] **T8** · Montar a seção Conquistas na página Perfil — R3 · CA1, CA9 · AB# a criar
  - Pronto quando: print em 1280 px igual à seção "🏅 Conquistas" do frame `1160-37708` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Montar a seção Conquistas no perfil público — R5, R9 · CA2, CA8, CA10 · AB# a criar
  - Pronto quando: print em 1280 px igual à seção "Conquistas" do frame `1160-1396` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T10** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T1, T2 |
| R3 | T3, T5, T6, T8 |
| R4 | T1, T2, T5, T6 |
| R5 | T4, T5, T6, T9 |
| R6 | T2, T4, T5, T7 |
| R7 | T1, T5, T6 |
| R8 | T2, T5, T7 |
| R9 | T4, T9 |
| R10 | T8, T9 |
