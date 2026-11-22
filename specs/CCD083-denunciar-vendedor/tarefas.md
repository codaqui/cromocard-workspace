# Tarefas — CCD083 Denunciar Vendedor

- **Plano:** [plano.md](plano.md) · **User story:** não encontrada no board (AB# a criar)
- **Fase Futuro Marketplace: implementar depois do MVP.**
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende da CCD090 (ou CCD050: `POST /reports` e `ReportDialog`) e da CCD080 (perfil público).

## Backend — `apps/cromocard-backend`, branch `feature/<id>-denunciar-vendedor`

- [ ] **T1** · Criar estratégia de denúncia de vendedor — R4–R6 · CA1, CA3, CA5 · AB# a criar
  - Pronto quando: `moderation.service.spec.ts` cobre gravação `SELLER`, motivo obrigatório, `404` e `422`/`409` (depende da L8), com 90% de cobertura.
- [ ] **T2** · Cobrir a denúncia de vendedor no endpoint POST /reports — R1, R4, R6 · CA1, CA3–CA5 · AB# a criar
  - Pronto quando: `tests/integration/reports.spec.ts` responde `201`, `400`, `401` e `404` para `SELLER` sem gravar nos erros.
- [ ] **T3** · Criar endpoint GET /admin/moderation/reports — R7 · CA6 · AB# a criar
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/admin-moderation-reports.spec.ts` lista a denúncia do CA1 e responde `401`/`403` (depende da L6).

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-denunciar-vendedor`

- [ ] **T4** · Mostrar "Denunciar perfil" no perfil de vendedor — R2, R10 · CA1, CA7 · AB# a criar
  - Pronto quando: `ReportProfileButton.spec.tsx` cobre cliente, próprio perfil e visitante (depende da L7 e L8); print em 1280 px igual ao frame `1160-1396` e sem quebra em 375/768/1024 px.
- [ ] **T5** · Abrir o modal de denúncia de vendedor — R3–R5, R8–R10 · CA1–CA3, CA8 · AB# a criar
  - Pronto quando: `ReportDialog.spec.tsx` cobre envio `SELLER`, sem motivo, "Cancelar", "✕" e sucesso; print em 1280 px igual ao frame `1160-17495` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Criar lista de denúncias de vendedor no BackOffice — R7 · CA6 · AB# a criar
  - Pronto quando: o teste da página mostra vendedor, motivo, descrição, quem e quando, com carregando e erro; print em 1280 px igual ao frame da L6, quando desenhado, e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T4 |
| R2 | T4 |
| R3 | T5 |
| R4 | T1, T2, T5 |
| R5 | T1, T5 |
| R6 | T1, T2 |
| R7 | T3, T6 |
| R8, R9 | T5 |
| R10 | T4, T5 |
