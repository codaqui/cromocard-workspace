# Tarefas — CCD068 Ordenar por Menor Preço (agrupa CCD069, CCD070 e CCD071)

- **Plano:** [plano.md](plano.md) · **User story:** a criar (L4)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- AB# de cada Task: a criar (as Tasks no Azure só serão criadas com o pedido do Daniel).
- As branches saem depois do merge da CCD078 (e da CCD079 para a lista do perfil da carta).
- T7 e T10 são da CCD070 (Futuro Marketplace): implementar depois do MVP.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-ordenar-anuncios`

- [ ] **T1** · Criar ordenações por preço com desempate estável — R3–R5, R12 · CA1–CA3 · AB# a criar
  - Pronto quando: `listings.sort.spec.ts` cobre `price`, `-price`, `-createdAt`, o desempate e o padrão por rota.
- [ ] **T2** · Aplicar a ordenação em GET /listings — R2, R6, R12 · CA1–CA4, CA6, CA7 · AB# a criar
  - Pronto quando: `tests/integration/listings-public.spec.ts` cobre CA1–CA4, CA6 e CA7 sem token, e o `/docs` mostra os valores.
- [ ] **T3** · Aplicar a ordenação em GET /cards/:cardId/listings com padrão menor preço — R7, R12 · CA5, CA7 · AB# a criar
  - Pronto quando: sem `sort` a lista sai por menor preço e `sort` inválido responde `400`.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-ordenar-anuncios`

- [ ] **T4** [P] · Criar opções e rótulos da ordenação — R1, R3–R5 · AB# a criar
  - Pronto quando: o typecheck passa e as três opções mapeiam para `-createdAt`, `price` e `-price`.
- [ ] **T5** · Criar seletor Ordenar — R1, R13 · CA5 · AB# a criar
  - Pronto quando: `SortSelect.spec.tsx` cobre abrir, escolher e o padrão; print em 1280 px igual ao frame `1112-3281` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Ligar o seletor ao Explorar e à lista Anúncios disponíveis — R1, R6–R8, R13 · CA1–CA6, CA9–CA12 · AB# a criar
  - Pronto quando: `ExploreMarketplacePage.spec.tsx` e `AvailableListings.spec.tsx` cobrem CA1–CA6; print em 1280 px igual aos frames `1112-3281`, `1112-3674` e `1112-4615` e sem quebra em 375/768/1024 px.

## Futuro Marketplace (CCD070)

- [ ] **T7** · Criar ordenação por avaliação do vendedor — R9–R11 · CA8 · AB# a criar
  - Pronto quando: `listings.seller-rating.spec.ts` e a integração cobrem a ordem, os sem avaliação no fim, `sellersWithoutReviews` e o `401` sem token.
- [ ] **T10** · Mostrar a opção de avaliações e o aviso para o cliente logado — R9–R11, R13 · CA8 · AB# a criar
  - Pronto quando: o visitante não vê a opção e o cliente vê o aviso, em `ExploreMarketplacePage.spec.tsx`; sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T8** · Alinhar o plano da CCD079 ao `sort=price` do ADR-011 · docs · AB# a criar
  - Pronto quando: `specs/CCD079-visualizar-quantidade-disponivel/plano.md` usa os mesmos valores de `sort`.
- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
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
| R9, R10, R11 | T7, T10 |
| R12 | T1, T2, T3, T8 |
| R13 | T5, T6, T10 |
