# Tarefas — CCD074 Visualizar Fotos

- **Plano:** [plano.md](plano.md) · **User story:** não encontrada no board (AB# a criar)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende do detalhe do anúncio (CCD079) e de `listing_photos` (CCD084).

## Backend — `apps/cromocard-backend`, branch `feature/<id>-visualizar-fotos`

- [ ] **T1** · Incluir fotos e imagem da carta no detalhe do anúncio — R1, R2, R6, R7 · CA1, CA5, CA6 · AB# a criar
  - Pronto quando: `listings.service.spec.ts` e `tests/integration/listings.spec.ts` cobrem ordem, limite de 4 (depende da L4), foto excluída e anúncio sem fotos; o seed tem os três casos.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-visualizar-fotos`

- [ ] **T2** [P] · Criar galeria de fotos do anúncio — R2–R4, R6, R8 · CA1–CA3, CA5, CA7–CA9 · AB# a criar
  - Pronto quando: `ListingPhotoGallery.spec.tsx` e `usePhotoNavigation.spec.ts` cobrem destaque, miniaturas, setas, sem fotos e foto quebrada; print em 1280 px igual aos frames `1112-5772` e `1112-6152` e sem quebra em 375/768/1024 px.
- [ ] **T3** · Criar visualização ampliada da foto — R5 · CA4 · AB# a criar
  - Pronto quando: `ListingPhotoViewer.spec.tsx` cobre abrir, navegar e fechar (botão, `Esc` e fundo), sem quebra em 375/768/1024 px (depende da L2).

## Fechamento — workspace

- [ ] **T4** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1, R7 | T1 |
| R2, R6 | T1, T2 |
| R3, R4, R8 | T2 |
| R5 | T3 |
