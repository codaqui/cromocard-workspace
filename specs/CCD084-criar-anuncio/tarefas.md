# Tarefas — CCD084 Criar Anúncio

- **Plano:** [plano.md](plano.md) · **User story:** AB#343
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/343-criar-anuncio`

- [ ] **T1** · Criar migrations de card_conditions, listings e listing_photos com o seed — R3, R7, R8 · AB#1448
  - Pronto quando: as três tabelas existem como no DBML e o seed traz as 5 condições e anúncios com e sem foto.
- [ ] **T2** · Criar cálculo da taxa de 5% e do líquido — R6 · CA1 · AB#1449
  - Pronto quando: `platform-fee.spec.ts` cobre R$ 1.850,00 → R$ 92,50 / R$ 1.757,50 e o arredondamento para baixo.
- [ ] **T3** · Criar endpoints GET /cards e GET /card-conditions — R3, R4 · CA3 · AB#1450
  - Pronto quando: a busca não traz carta `DRAFT` nem excluída e as condições vêm na ordem.
- [ ] **T4** · Liberar o upload de fotos de anúncio para o vendedor — R8 · CA6 · AB#1451
  - Pronto quando: `SELLER` envia para a pasta `listings` e o arquivo de 5 MB ou PDF é recusado.
- [ ] **T5** · Criar service de criação de anúncio com elegibilidade — R5–R10 · CA1, CA3–CA5, CA7, CA8 · AB#1452
  - Pronto quando: `seller-listings.service.spec.ts` cobre CA1, CA3–CA5, CA7 e CA8.
- [ ] **T6** · Criar endpoints GET /me/listings/eligibility e POST /me/listings — R1, R3 · CA9 · AB#1453
  - Pronto quando: as rotas aparecem no `/docs` e estão em `src/routes.ts`.
- [ ] **T7** · Criar testes de integração da criação de anúncio — R1, R3–R10 · CA1, CA3–CA9 · AB#1454
  - Pronto quando: `tests/integration/marketplace/seller-listings.spec.ts` passa, com 90% de cobertura nos arquivos alterados.

## Frontend — `apps/cromocard-frontend`, branch `feature/343-criar-anuncio`

- [ ] **T8** [P] · Criar tipos, schema, taxa, api e queries do anúncio — R3, R5, R6 · CA1, CA4 · AB#1455
  - Pronto quando: `listings.schemas.spec.ts` e `listings.fee.spec.ts` passam e o typecheck passa.
- [ ] **T9** · Criar busca da carta e campo de fotos do anúncio — R3, R4, R8 · CA3, CA6 · AB#1456
  - Pronto quando: `CardCatalogPicker.spec.tsx` e `ListingPhotosField.spec.tsx` cobrem a busca, o limite de 4 e o arquivo recusado.
- [ ] **T10** · Criar modal Criar anúncio — R3, R5–R8, R11 · CA1, CA4, CA10, CA11 · AB#1457
  - Pronto quando: `CreateListingModal.spec.tsx` cobre CA1, CA4 e CA10; print em 1280 px igual ao frame `282-4482` e sem
    quebra em 375/768/1024 px.
- [ ] **T11** · Criar aviso bloqueado e pedido de endereço principal — R9, R10, R11 · CA7, CA8, CA12 · AB#1458
  - Pronto quando: `useCreateListingFlow.spec.tsx` cobre CA7 e CA8; print em 1280 px igual ao frame `1112-10828` e sem
    quebra em 375/768/1024 px.
- [ ] **T12** · Ligar Criar anúncio no Painel do vendedor e Anunciar esta carta no perfil da carta — R2 · CA2 · AB#1459
  - Pronto quando: os dois botões abrem o fluxo, e o do perfil da carta já vem com a carta escolhida.

## Fechamento — workspace

- [ ] **T13** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1460
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T6, T7 |
| R2 | T12 |
| R3 | T1, T3, T6, T8, T9, T10 |
| R4 | T3, T5, T9 |
| R5 | T5, T8, T10 |
| R6 | T2, T5, T8, T10 |
| R7 | T1, T5, T10 |
| R8 | T1, T4, T5, T9, T10 |
| R9 | T5, T11 |
| R10 | T5, T11 |
| R11 | T10, T11 |
