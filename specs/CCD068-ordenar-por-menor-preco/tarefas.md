# Tarefas — CCD068 Ordenar por Menor Preço (agrupa CCD069 e CCD071)

- **Plano:** [plano.md](plano.md) · **User story:** AB#1343
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.
- As branches saem depois do merge da CCD078 (e da CCD079 para a lista do perfil da carta).
- A T7 e a T10 eram da CCD070, que foi removida do projeto em 22/11/2026 (ADR-068).

## Backend — `apps/cromocard-backend`, branch `feature/1343-ordenar-anuncios`

- [ ] **T1** · Criar ordenações por preço com desempate estável — R3–R5, R12 · CA1–CA3 · AB#1344
  - Pronto quando: `listings.sort.spec.ts` cobre `price`, `-price`, `-createdAt`, o desempate e o padrão por rota.
- [ ] **T2** · Aplicar a ordenação em GET /listings — R2, R6, R12 · CA1–CA4, CA6, CA7 · AB#1345
  - Pronto quando: `tests/integration/listings-public.spec.ts` cobre CA1–CA4, CA6 e CA7 sem token, e o `/docs` mostra os valores.
- [ ] **T3** · Aplicar a ordenação em GET /cards/:cardId/listings com padrão menor preço — R7, R12 · CA5, CA7 · AB#1346
  - Pronto quando: sem `sort` a lista sai por menor preço e `sort` inválido responde `400`.

## Frontend — `apps/cromocard-frontend`, branch `feature/1343-ordenar-anuncios`

- [ ] **T4** [P] · Criar opções e rótulos da ordenação — R1, R3–R5 · AB#1347
  - Pronto quando: o typecheck passa e as três opções mapeiam para `-createdAt`, `price` e `-price`.
- [ ] **T5** · Criar seletor Ordenar — R1, R13 · CA5 · AB#1348
  - Pronto quando: `SortSelect.spec.tsx` cobre abrir, escolher e o padrão; print em 1280 px igual ao frame `1112-3281` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Ligar o seletor ao Explorar e à lista Anúncios disponíveis — R1, R6–R8, R13 · CA1–CA6, CA9–CA12 · AB#1349
  - Pronto quando: `ExploreMarketplacePage.spec.tsx` e `AvailableListings.spec.tsx` cobrem CA1–CA6; print em 1280 px igual aos frames `1112-3281`, `1112-3674` e `1112-4615` e sem quebra em 375/768/1024 px.

## Removidas

- ~~**T7**~~ e ~~**T10**~~ removidas: a CCD070 (ordenar por avaliações) foi removida do projeto em 22/11/2026 (ADR-068).

## Fechamento — workspace

- [ ] **T8** · Alinhar o plano da CCD079 ao `sort=price` do ADR-011 · docs · AB#1350
  - Pronto quando: `specs/CCD079-visualizar-quantidade-disponivel/plano.md` usa os mesmos valores de `sort`.
- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1351
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4, T5, T6 |
| R2 | T2 |
| R3, R4, R5 | T1, T4 |
| R6 | T2, T6 |
| R7 | T3, T6 |
| R8 | T6 |
| ~~R9, R10, R11~~ | removidos (ADR-068) |
| R12 | T1, T2, T3, T8 |
| R13 | T5, T6 |
