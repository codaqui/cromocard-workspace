# Tarefas — CCD089 Visualizar Propostas

- **Plano:** [plano.md](plano.md) · **User story:** #348 `CCD089-Visualizar Propostas` (Tasks: AB# a criar)
- **Fase Futuro Marketplace: implementar depois do MVP** (depende da L1).
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende de `listings` (CCD084/CCD097) no `schema.prisma`; o frontend depende dos frames da L2.

## Backend — `apps/cromocard-backend`, branch `feature/348-visualizar-propostas`

- [ ] **T1** · Criar migration da tabela offers — R2, R4, R6 · AB# a criar
  - Pronto quando: `create_offers_table` igual ao DBML roda limpa e o seed tem propostas `PENDING` e `REJECTED` de dois vendedores.
- [ ] **T2** · Criar validator, erros e repository das propostas do vendedor — R2, R4–R6 · AB# a criar
  - Pronto quando: o repository filtra pelo vendedor do anúncio e troca o status só de `PENDING`.
- [ ] **T3** · Criar service das propostas recebidas — R2, R4–R6 · CA1, CA2, CA5 · AB# a criar
  - Pronto quando: `offers.service.spec.ts` cobre ativas (depende da L5), posse, aceitar, recusar e `409`, com 90% de cobertura.
- [ ] **T4** · Criar endpoints GET /seller/offers e GET /seller/offers/:id — R1, R2, R4, R5 · CA1, CA4, CA5 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs` e `tests/integration/seller-offers.spec.ts` responde `200`, `401`, `403` e `404`.
- [ ] **T5** · Criar endpoints POST /seller/offers/:id/accept e /reject — R6 · CA2 · AB# a criar
  - Pronto quando: a integração responde `200` com o novo status, `404` de outro vendedor e `409` fora de `PENDING`.

## Frontend — `apps/cromocard-frontend`, branch `feature/348-visualizar-propostas`

- [ ] **T6** [P] · Criar tipos, api e queries das propostas — R4–R7 · AB# a criar
  - Pronto quando: o typecheck passa e `offers.api.spec.ts` cobre as quatro chamadas.
- [ ] **T7** · Criar página de propostas recebidas e o item no menu do vendedor — R1, R3, R4, R7–R9 · CA1, CA3, CA7, CA8 · AB# a criar
  - Pronto quando: `ReceivedOffersPage.spec.tsx` cobre lista, vazio, carregando e erro, e o menu mostra "Propostas Recebidas" só para `SELLER`; print em 1280 px igual aos frames da lista e da lista vazia (L2) e sem quebra em 375/768/1024 px.
- [ ] **T8** · Criar interface de negociação com aceitar e recusar — R5, R6, R8, R9 · CA2, CA8 · AB# a criar
  - Pronto quando: `OfferDetailPage.spec.tsx` cobre detalhes, aceitar, recusar e `404`; print em 1280 px igual ao frame dos detalhes (L2) e sem quebra em 375/768/1024 px.
- [ ] **T9** · Abrir a proposta pela notificação — R3 · CA6 · AB# a criar
  - Pronto quando: o teste do item de notificação navega para o `referenceLink` da proposta (depende da L6).

## Fechamento — workspace

- [ ] **T10** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4, T7 |
| R2 | T1, T2, T3, T4 |
| R3 | T7, T9 |
| R4 | T1, T2, T3, T4, T6, T7 |
| R5 | T2, T3, T4, T6, T8 |
| R6 | T1, T2, T3, T5, T6, T8 |
| R7 | T6, T7 |
| R8 | T7, T8 |
| R9 | T7, T8 |
