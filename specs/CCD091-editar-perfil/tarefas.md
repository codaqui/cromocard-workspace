# Tarefas — CCD091 Editar Perfil (do vendedor)

- **Plano:** [plano.md](plano.md) · **User story:** AB#350
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/350-editar-perfil-vendedor`

- [ ] **T1** · Criar migration create_profiles_table e o perfil do vendedor no seed — R3, R5 · AB#1484
  - Pronto quando: `profiles` existe como no DBML (ou já veio da CCD048) e o vendedor do seed tem bio e logo.
- [ ] **T2** · Criar service do perfil da loja — R2–R5 · CA1, CA2, CA4 · AB#1485
  - Pronto quando: `seller-profile.service.spec.ts` cobre gravar, vendedor sem credenciamento e o `409` conforme a L1.
- [ ] **T3** · Criar endpoints GET e PATCH /me/seller-profile e a pasta avatars do upload — R1, R5 · CA3, CA6 · AB#1486
  - Pronto quando: as rotas aparecem no `/docs`, estão em `src/routes.ts` e o upload aceita `avatars`.
- [ ] **T4** · Criar testes de integração do perfil da loja — R1–R5 · CA1–CA4, CA6 · AB#1487
  - Pronto quando: `tests/integration/users/seller-profile.spec.ts` passa, com 90% de cobertura nos arquivos alterados.

## Frontend — `apps/cromocard-frontend`, branch `feature/350-editar-perfil-vendedor`

- [ ] **T5** [P] · Criar tipos, schema, api e queries do perfil da loja — R3, R4 · CA4 · AB#1488
  - Pronto quando: `seller-profile.schemas.spec.ts` passa e o typecheck passa.
- [ ] **T6** · Criar modal Editar Perfil do Vendedor — R2–R6 · CA1–CA5, CA7, CA8 · AB#1489
  - Pronto quando: `EditSellerProfileModal.spec.tsx` cobre CA1–CA5 e CA7; print em 1280 px igual ao frame `675-4627` e sem
    quebra em 375/768/1024 px.
- [ ] **T7** · Ligar Editar perfil da loja na Visão geral do vendedor — R2 · CA1 · AB#1490
  - Pronto quando: o botão abre o modal e, salvo, a Visão geral mostra os dados novos.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1491
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3, T4 |
| R2 | T2, T6, T7 |
| R3 | T1, T2, T4, T5, T6 |
| R4 | T2, T4, T5, T6 |
| R5 | T1, T2, T3, T6 |
| R6 | T6 |
