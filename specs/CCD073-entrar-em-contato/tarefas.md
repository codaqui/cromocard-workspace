# Tarefas — CCD073 Entrar em Contato

- **Plano:** [plano.md](plano.md) · **User story:** não encontrada no board (AB# a criar)
- **Fase MVP** desde 22/11/2026 (ADR-068).
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende do chat pessoal (CCD045/CCD046), do Socket.IO (CCD044), do `notify` (CCD053), do bloqueio (CCD047) e do
  detalhe do anúncio (CCD079).

## Backend — `apps/cromocard-backend`, branch `feature/<id>-entrar-em-contato`

- [ ] **T1** · Criar service de contato com o vendedor pelo anúncio — R1, R4–R9 · CA1–CA4, CA6 · AB# a criar
  - Pronto quando: `listing-contact.service.spec.ts` cobre criar e reaproveitar a conversa, bloqueio, vendedor indisponível e a falha sem emissão.
- [ ] **T2** · Criar endpoint POST /listings/:id/contact — R1–R3 · CA1, CA5 · AB# a criar
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/listing-contact.spec.ts` cobre `201`, `401`, `403`, `404` e `422`.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-entrar-em-contato`

- [ ] **T3** [P] · Criar api e textos do contato com o vendedor — R3, R8, R9 · AB# a criar
  - Pronto quando: o typecheck passa e `listing-contact.api.spec.ts` cobre a chamada.
- [ ] **T4** · Criar botão e caixa Entrar em contato no detalhe do anúncio — R1–R3, R8, R9 · CA1, CA3, CA4, CA6 · AB# a criar
  - Pronto quando: `ContactSellerDialog.spec.tsx` cobre enviar, bloqueio, indisponível, erro com o texto mantido e o dono sem botão; no estilo do frame `1112-5772`, sem quebra em 375/768/1024 px.
- [ ] **T5** · Abrir a conversa criada em Mensagens — R5, R6, R10 · CA1, CA2, CA7, CA8 · AB# a criar
  - Pronto quando: depois de enviar, a conversa abre; print em 1280 px igual aos frames `1160-32980` e `1160-37184` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T2, T4 |
| R2, R3 | T2, T4 |
| R4, R7 | T1 |
| R5, R6 | T1, T5 |
| R8, R9 | T1, T3, T4 |
| R10 | T5 |
