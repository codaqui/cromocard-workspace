# Tarefas — CCD090 Denunciar Usuário

- **Plano:** [plano.md](plano.md) · **User story:** #349 `CCD090-Denunciar Usuario` (Tasks: AB# a criar)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende da CCD080 (perfil público); o caminho pela conversa depende da CCD047 e do chat pessoal.

## Docs — workspace

- [ ] **T1** · Registrar ADR do endpoint único de denúncias — R5 · AB#1474
  - Pronto quando: `docs/ADR/` tem o ADR `Proposto` de `POST /api/v1/reports` com estratégia por `targetType`, citado no plano.

## Backend — `apps/cromocard-backend`, branch `feature/349-denunciar-usuario`

- [ ] **T2** · Criar validator e erros das denúncias — R3, R4, R7, R8 · CA3, CA4 · AB#1475
  - Pronto quando: `createReportBody` exige `reason` e, para `USER`, `description` (depende da L4), com `moderation.validator.spec.ts`.
- [ ] **T3** · Criar repository e estratégia de alvo USER — R5 · CA6 · AB#1476
  - Pronto quando: a estratégia `USER` confere o usuário não excluído e o repository grava e procura denúncia aberta.
- [ ] **T4** · Criar service de denúncia — R1, R5 · CA1, CA5, CA6 · AB#1477
  - Pronto quando: `moderation.service.spec.ts` cobre gravação `PENDING`, papel `SELLER` (depende da L3), `404`, `409` e `422` (depende da L9), com 90% de cobertura.
- [ ] **T5** · Criar endpoint POST /reports — R1, R5, R7, R8 · CA1, CA3–CA6 · AB#1478
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/reports.spec.ts` responde `201`, `400`, `401`, `403` e `404` sem gravar nos erros.

## Frontend — `apps/cromocard-frontend`, branch `feature/349-denunciar-usuario`

- [ ] **T6** [P] · Criar tipos, api e mutation de denúncia — R3–R6 · AB#1479
  - Pronto quando: o typecheck passa e `moderation.api.spec.ts` cobre o envio.
- [ ] **T7** · Criar modal de denúncia — R3, R4, R6–R9 · CA2–CA4, CA9 · AB#1480
  - Pronto quando: `ReportDialog.spec.tsx` cobre envio, sem categoria, sem observação, cancelar e confirmação; print em 1280 px igual ao frame `1160-17495` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Incluir "Denunciar perfil" no perfil público — R2, R9 · CA2, CA8 · AB#1481
  - Pronto quando: `PublicProfilePage.spec.tsx` mostra o botão para o vendedor logado e abre o modal; print em 1280 px igual ao frame `1160-1396` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Ligar "Somente denunciar" do modal da conversa à denúncia — R2–R6, R9 · CA1, CA7 · AB#1482
  - Pronto quando: o teste do modal da conversa (CCD047) envia `targetType = USER` e mostra a confirmação; print em 1280 px igual ao frame `1160-34298` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T10** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1483
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4, T5 |
| R2 | T8, T9 |
| R3, R4 | T2, T6, T7, T9 |
| R5 | T1, T3, T4, T5, T9 |
| R6 | T6, T7, T9 |
| R7, R8 | T2, T5, T7 |
| R9 | T7, T8, T9 |
