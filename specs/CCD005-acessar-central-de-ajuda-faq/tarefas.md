# Tarefas — CCD005 Acessar Central de Ajuda (FAQ)

- **Plano:** [plano.md](plano.md) · **User story:** AB#110
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.
- Só frontend: o backend não muda.

## Frontend — `apps/cromocard-frontend`, branch `feature/110-central-de-ajuda`

- [ ] **T1** · Criar a configuração do e-mail do suporte — R8 · CA4 · AB#963
  - Pronto quando: `env.ts` lê `SUPPORT_EMAIL`, o `.env.example` e o `env.js` de runtime têm a variável e o typecheck passa.
- [ ] **T2** · Criar conteúdo e busca das perguntas frequentes — R4–R6 · CA2, CA3 · AB#964
  - Pronto quando: `help.content.ts` tem os 6 tópicos com o texto do PO (L2) e `help.search.spec.ts` cobre acentos, maiúsculas e todos os tópicos.
- [ ] **T3** · Criar tópicos, cartão de pergunta, busca e cartão do suporte — R4–R8 · CA1–CA4 · AB#965
  - Pronto quando: `HelpTopics.spec.tsx`, `FaqItem.spec.tsx` e `SupportCard.spec.tsx` cobrem CA1–CA4; print em 1280 px igual ao frame `1112-6843` e sem quebra em 375/768/1024 px.
- [ ] **T4** · Criar página Central de ajuda — R1–R8, R14 · CA1, CA3, CA5, CA10 · AB#966
  - Pronto quando: `HelpCenterPage.spec.tsx` cobre CA1, CA3 e CA5; print em 1280 px igual ao frame `1112-6843` e sem quebra em 375/768/1024 px.
- [ ] **T5** [P] · Criar conteúdo e componentes do Como funciona — R10–R12 · CA6–CA8 · AB#967
  - Pronto quando: `PricingCard.spec.tsx` cobre 0%, 5% e o link de cadastro; print em 1280 px igual aos frames `1112-6532` e `1160-2268` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Criar página Como funciona com as abas — R9–R14 · CA5–CA9, CA11–CA13 · AB#968
  - Pronto quando: `HowItWorksPage.spec.tsx` cobre as duas abas e nenhuma chamada à API; print em 1280 px igual aos frames `1112-6532` e `1160-2268` e sem quebra em 375/768/1024 px.
- [ ] **T7** · Registrar as rotas /ajuda e /como-funciona — R1, R2, R9 · CA1, CA5 · AB#969
  - Pronto quando: as duas abrem sem login pelo menu e pelo rodapé, com o item destacado, e `/ajuda` não está mais em construção.

## Fechamento — workspace

- [ ] **T8** · Atualizar o ponteiro `apps/cromocard-frontend` e marcar a spec como `Implementada` · AB#970
  - Pronto quando: o PR do frontend está mergeado em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1, R2 | T4, T7 |
| R3 | T4 |
| R4, R5, R6 | T2, T3, T4 |
| R7 | T3, T4 |
| R8 | T1, T3, T4 |
| R9 | T6, T7 |
| R10, R11, R12 | T5, T6 |
| R13 | T6 |
| R14 | T4, T6 |
