# Tarefas — CCD082 Denunciar Anúncio

- **Plano:** [plano.md](plano.md) · **User story:** não encontrada no board (AB# a criar)
- **Fase MVP** desde 22/11/2026 (telas completadas no Figma, ADR-068).
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende da CCD090 (ou CCD050: `POST /reports` e `ReportDialog`), da CCD079 e de `listings` (CCD084/CCD097). Frames do Figma: `1112-5772`, `1226-390`, `1226-683` e `1226-977`.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-denunciar-anuncio`

- [ ] **T1** · Criar migration da FK reports.listing_id — R6 · AB# a criar
  - Pronto quando: `add_reports_listing_fk` igual ao DBML roda limpa e `Report.listing` existe no client.
- [ ] **T2** · Criar estratégia de denúncia de anúncio — R4–R6, R8 · CA1, CA2, CA4 · AB# a criar
  - Pronto quando: `moderation.service.spec.ts` cobre gravação `LISTING`, motivo obrigatório, `404` do excluído, `422` do dono (depende da L6) e `409` (depende da L7), com 90% de cobertura.
- [ ] **T3** · Cobrir a denúncia de anúncio no endpoint POST /reports — R1, R6, R8 · CA1–CA4 · AB# a criar
  - Pronto quando: `tests/integration/reports.spec.ts` responde `201`, `400`, `401` e `404` para `LISTING` sem gravar nos erros, e o `/docs` mostra o exemplo.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-denunciar-anuncio`

- [ ] **T4** · Criar botão "Denunciar Anúncio" no detalhe do anúncio — R1, R2, R9 · CA1, CA6 · AB# a criar
  - Pronto quando: `ReportListingButton.spec.tsx` cobre cliente, dono e visitante (depende da L5 e L6); print em 1280 px igual ao frame `1112-5772` (e `1112-6152`) e sem quebra em 375/768/1024 px.
- [ ] **T5** · Abrir o modal de denúncia com os motivos do anúncio — R3–R5, R7–R9 · CA1, CA2, CA5 · AB# a criar
  - Pronto quando: `ReportDialog.spec.tsx` cobre envio, sem motivo e confirmação para `LISTING`; print em 1280 px igual aos frames `1226-390` (modal), `1226-683` (sem motivo) e `1226-977` (confirmação) e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3, T4 |
| R2 | T4 |
| R3 | T5 |
| R4, R5 | T2, T5 |
| R6 | T1, T2, T3 |
| R7 | T5 |
| R8 | T2, T3, T5 |
| R9 | T4, T5 |
