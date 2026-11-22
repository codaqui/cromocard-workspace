# Tarefas — CCD080 Visualizar Dados do Vendedor

- **Plano:** [plano.md](plano.md) · **User story:** não encontrada no board (AB# a criar)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende da CCD079 (detalhe do anúncio) e de `listings`, `orders` e `card_conditions` (CCD084/CCD097) no `schema.prisma`.

## Docs — workspace

- [ ] **T1** · Acrescentar `profiles.state` ao DER — R2, R3 · AB# a criar
  - Pronto quando: a L3 está decidida e os três `.dbml` e o diagrama de classes têm a coluna, com ADR `Proposto` (só se a L3 confirmar a coluna).

## Backend — `apps/cromocard-backend`, branch `feature/<id>-visualizar-dados-do-vendedor`

- [ ] **T2** · Criar migration da tabela profiles — R2, R3, R7 · AB# a criar
  - Pronto quando: `create_profiles_table` igual ao DBML (e `add_state_to_profiles`, se a T1 entrou) roda limpa e o seed tem vendedores com e sem cidade.
- [ ] **T3** · Incluir o vendedor no detalhe e na lista de anúncios da carta — R2, R3, R5 · CA1, CA2, CA3 · AB# a criar
  - Pronto quando: `GET /listings/:id` e `GET /cards/:cardId/listings` trazem `seller` sem campos vazios, com teste no `listings.service.spec.ts` e na integração.
- [ ] **T4** · Criar validator, erros e repository do perfil público — R7–R9 · AB# a criar
  - Pronto quando: o repository só seleciona campos públicos, conta vendas `COMPLETED` (depende da L4) e anúncios `ACTIVE`.
- [ ] **T5** · Criar service do perfil público — R5, R7–R9 · CA4, CA5, CA6 · AB# a criar
  - Pronto quando: `profiles.service.spec.ts` cobre totais, ativo × pausado, usuário indisponível `404` (depende da L10) e omissão de campos, com 90% de cobertura.
- [ ] **T6** · Criar endpoints GET /profiles/:userId e GET /profiles/:userId/listings — R1, R7, R8, R9 · CA4, CA5, CA6 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs` e `tests/integration/profiles.spec.ts` responde `200` sem token, `404` e `400`, sem `name`, `email` nem `cpf` no corpo.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-visualizar-dados-do-vendedor`

- [ ] **T7** [P] · Criar tipos, api e queries do perfil público e do vendedor do anúncio — R2, R3, R7, R8 · AB# a criar
  - Pronto quando: o typecheck passa e `profiles.api.spec.ts` cobre as duas chamadas.
- [ ] **T8** · Criar cartão do vendedor no detalhe do anúncio — R2, R5, R6, R11 · CA1, CA3, CA4, CA8, CA9 · AB# a criar
  - Pronto quando: `SellerCard.spec.tsx` cobre com e sem cidade e o link; print em 1280 px igual aos frames `1112-5772` e `1112-6152` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Mostrar o vendedor nas tabelas de anúncios da carta — R3, R6, R11 · CA2, CA8, CA10 · AB# a criar
  - Pronto quando: os testes das duas tabelas cobrem o vendedor de cada linha; print em 1280 px igual aos frames `1112-5772` e `1112-4615` e sem quebra em 375/768/1024 px.
- [ ] **T10** · Criar página do perfil público e a rota /usuarios/:id — R1, R6–R10, R11 · CA4–CA7, CA11 · AB# a criar
  - Pronto quando: `PublicProfilePage.spec.tsx` cobre totais, lista "(n)", aviso de privacidade, carregando, erro e `404`; "Ver perfil" da busca abre a rota; print em 1280 px igual ao frame `1160-1396` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T11** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T6, T10 |
| R2 | T1, T2, T3, T7, T8 |
| R3 | T1, T2, T3, T7, T9 |
| R4 | suspenso pela L2 (nenhuma tarefa até a decisão) |
| R5 | T3, T5, T8 |
| R6 | T8, T9, T10 |
| R7, R8 | T2, T4, T5, T6, T7, T10 |
| R9 | T4, T5, T6, T10 |
| R10 | T10 |
| R11 | T8, T9, T10 |
