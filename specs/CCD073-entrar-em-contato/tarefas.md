# Tarefas — CCD073 Entrar em Contato

- **Plano:** [plano.md](plano.md) · **User story:** AB#1366
- **Fase MVP** desde 22/11/2026 (ADR-069). Tarefas refeitas em 27/11/2026 com as decisões da spec.
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Empilhada sobre o chat pessoal (`feature/1208-responder-mensagem-especifica`, CCD045/CCD046/CCD047). A página do
  anúncio (CCD079/CCD080) monta o botão depois (L10).

## Backend — `apps/cromocard-backend`, branch `feature/1366-entrar-em-contato`

- [ ] **T1** · Criar service de contato com o vendedor pelo anúncio — R1, R4, R5, R8, R9 · CA1–CA5 · AB#1367
  - Pronto quando: `listing-contact.service.spec.ts` cobre anúncio inexistente, próprio e pausado, os dois bloqueios, vendedor indisponível, conversa nova e conversa reaproveitada.
- [ ] **T2** · Criar endpoint POST /listings/:id/contact — R1 · CA1–CA5 · AB#1368
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/chat/listing-contact.spec.ts` cobre `201`, `200`, `401`, `403` e `404` e os três `422`.

## Frontend — `apps/cromocard-frontend`, branch `feature/1366-entrar-em-contato`

- [ ] **T3** [P] · Criar api e textos do contato com o vendedor — R1, R3, R8, R9 · AB#1369
  - Pronto quando: o typecheck passa e `listing-contact.api.spec.ts` cobre a chamada.
- [ ] **T4** · Criar botão Entrar em contato para o quadro do vendedor — R2, R3, R8, R9, R11 · CA3–CA6, CA9, CA10 · AB#1370
  - Pronto quando: `ContactSellerButton.spec.tsx` cobre o dono sem botão, o visitante, a ida para Mensagens e os três avisos; exportado pelo `index.ts`; no estilo de "Favoritar" e sem quebra em 375/768/1024/1280 px.
- [ ] **T5** · Abrir a conversa em Mensagens com o texto sugerido — R3, R5, R10 · CA1, CA2, CA7 · AB#1371
  - Pronto quando: a conversa abre com o campo preenchido uma vez; print em 1280 px igual ao frame `1160-32980` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1372
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T2, T3 |
| R2 | T4 |
| R3 | T3, T4, T5 |
| R4, R5 | T1, T5 |
| R6, R7 | CCD046 (envio em tempo real); sino na CCD053 |
| R8, R9 | T1, T3, T4 |
| R10 | T4, T5 |
| R11 | T4 |
