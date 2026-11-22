# Tarefas — CCD023 Solicitar Cadastro da Carta

- **Plano:** [plano.md](plano.md) · **User story:** AB#156
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- As branches dos apps saem de `feature/339-aprovar-solicitacoes` (CCD064) com a CCD103 e entram depois delas.

## Backend — `apps/cromocard-backend`, branch `feature/156-solicitar-cadastro-da-carta`

- [ ] **T1** · Criar validator e erros da solicitação de carta — R4, R5, R6, R10 · AB# a criar
  - Pronto quando: `createCardRequestBody` valida o formato e os erros `REQUIRED_FIELDS_MISSING` e `INVALID_REFERENCE` respondem `422`.
- [ ] **T2** · Criar repository das opções e da gravação da solicitação — R5, R7, R8 · AB# a criar
  - Pronto quando: traz álbuns ativos, franquias, raridades e idiomas, grava `CARD` `PENDING` e conta as solicitações do cliente.
- [ ] **T3** · Criar service de solicitar cadastro da carta — R5–R8, R10 · CA1, CA3, CA4 · AB# a criar
  - Pronto quando: `catalog-request-create.service.spec.ts` cobre completo, sem verso, sem obrigatório e id inválido, com 90% de cobertura.
- [ ] **T4** · Criar endpoints GET /catalog-requests/card-options e POST /catalog-requests — R1 · CA1–CA4, CA8 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs` e `tests/integration/catalog-requests-create.spec.ts` cobre `201`, `401`, `403` e `422`.
- [ ] **T5** · Liberar o upload de imagem para cliente e vendedor — R6 · CA5 · AB# a criar
  - Pronto quando: a L4 está decidida e `tests/integration/uploads.spec.ts` cobre o cliente com `201`, `400` e `413`.

## Frontend — `apps/cromocard-frontend`, branch `feature/156-solicitar-cadastro-da-carta`

- [ ] **T6** [P] · Criar tipos, api, queries, schema e textos da solicitação de carta — R4–R8, R10 · AB# a criar
  - Pronto quando: o typecheck passa e `card-request.schemas.spec.ts` cobre os obrigatórios.
- [ ] **T7** · Criar formulário de solicitar cadastro da carta — R4–R6, R10, R11 · CA2, CA3, CA5, CA10 · AB# a criar
  - Pronto quando: `CardRequestForm.spec.tsx` cobre erros por campo sem perder o preenchido e a foto recusada; print em 1280 px igual ao frame `1160-24389` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Criar confirmação Solicitação enviada — R8, R9, R11 · CA1, CA6, CA11 · AB# a criar
  - Pronto quando: `CardRequestSent.spec.tsx` cobre o resumo e "Solicitar Outra Carta"; print em 1280 px igual ao frame `1160-24932` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Criar página e rota /albuns/solicitar-carta com o link do modal — R1–R3, R11 · CA7, CA9 · AB# a criar
  - Pronto quando: `CardRequestPage.spec.tsx` e `AddCardModal.spec.tsx` cobrem a navegação; print em 1280 px igual aos frames `1160-24389` e `1160-28449` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T10** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4, T9 |
| R2, R3 | T9 |
| R4 | T1, T6, T7 |
| R5 | T1, T2, T3, T6, T7 |
| R6 | T1, T3, T5, T6, T7 |
| R7 | T2, T3, T6 |
| R8 | T2, T3, T6, T8 |
| R9 | T8 |
| R10 | T1, T3, T6, T7 |
| R11 | T7, T8, T9 |
