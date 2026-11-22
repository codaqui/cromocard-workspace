# Tarefas — CCD039 Explorar e Entrar em Grupos

- **Plano:** [plano.md](plano.md) · **User story:** AB#142
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure: a criar (só com o pedido do Daniel).

## Backend — `apps/cromocard-backend`, branch `feature/142-explorar-e-entrar-em-grupos`

- [ ] **T1** · Criar migration create_group_join_requests_table e o seed do grupo fechado — R9 · AB# a criar
  - Pronto quando: a tabela existe igual ao DBML e o seed tem um grupo fechado com solicitação pendente.
- [ ] **T2** · Criar listagem de grupos com busca e paginação — R3–R6 · CA1, CA6 · AB# a criar
  - Pronto quando: `groups.service.spec.ts` cobre a busca, os campos do cartão e o filtro de suspenso e excluído.
- [ ] **T3** · Criar entrada em grupo aberto e solicitação em grupo fechado — R7–R9 · CA2–CA4 · AB# a criar
  - Pronto quando: os testes cobrem `MEMBER`, a linha restaurada, `PENDING`, os `409` e o aviso aos administradores.
- [ ] **T4** · Criar GroupAccess e as rotas GET /groups e POST /groups/:id/join — R1 · CA7 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs` e a integração responde `401` sem token e `403` como admin da plataforma.

## Frontend — `apps/cromocard-frontend`, branch `feature/142-explorar-e-entrar-em-grupos`

- [ ] **T5** [P] · Criar api e queries de grupos — R3–R9 · AB# a criar
  - Pronto quando: o typecheck passa e `groups.api.spec.ts` cobre os dois endpoints.
- [ ] **T6** · Criar página Comunidades com busca, cartões e estados — R2–R7, R9, R10, R12 · CA1, CA2, CA4, CA5, CA9 · AB# a criar
  - Pronto quando: `CommunitiesPage.spec.tsx` cobre CA1, CA2, CA4 e CA5; print em 1280 px igual ao frame `417-2915` e sem
    quebra em 375/768/1024 px.
- [ ] **T7** · Criar modal Compartilhar grupo — R11, R12 · CA8, CA10 · AB# a criar
  - Pronto quando: `ShareGroupDialog.spec.tsx` cobre CA8; print em 1280 px igual ao frame `675-17336` e sem quebra em
    375/768/1024 px.
- [ ] **T8** · Mover Comunidades para a área logada e esconder o item do visitante — R1, R2 · CA7 · AB# a criar
  - Pronto quando: `/comunidades` sem login vai para o login e `SiteShell.spec.tsx` não mostra "Comunidades" ao visitante.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4, T8 |
| R2 | T6, T8 |
| R3, R4, R6 | T2, T5, T6 |
| R5 | T2, T6 |
| R7, R8 | T3, T5, T6 |
| R9 | T1, T3, T5, T6 |
| R10 | T6 |
| R11 | T7 |
| R12 | T6, T7 |
