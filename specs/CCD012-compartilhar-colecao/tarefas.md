# Tarefas — CCD012 Compartilhar Coleção

- **Plano:** [plano.md](plano.md) · **User story:** AB#118
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/118-compartilhar-colecao`

- [ ] **T1** · Criar repository e erros do compartilhamento da coleção — R3, R8, R9 · AB#1014
  - Pronto quando: o repository grava `is_public` e `share_link` e busca a coleção pública pelo `share_link`.
- [ ] **T2** · Criar service do link, da coleção pública e da página compartilhada — R3, R8, R9 · CA1, CA2, CA5, CA6 · AB#1015
  - Pronto quando: `collection-sharing.service.spec.ts` cobre CA1, CA2, CA5, CA6 e o `USERNAME_REQUIRED` (depende da L10).
- [ ] **T3** · Criar endpoints de compartilhamento e da coleção compartilhada — R1, R3, R8, R9 · CA1, CA2, CA5–CA7 · AB#1016
  - Pronto quando: as 5 rotas aparecem no `/docs`, `/shared/*` responde sem token e
    `tests/integration/collection-sharing.spec.ts` cobre CA1, CA2 e CA5–CA7.

## Frontend — `apps/cromocard-frontend`, branch `feature/118-compartilhar-colecao`

- [ ] **T4** [P] · Criar types, api, queries e links das redes do compartilhamento — R3–R6 · CA4 · AB#1017
  - Pronto quando: o typecheck passa e `collection-sharing.links.spec.ts` cobre os links de WhatsApp, X e Facebook.
- [ ] **T5** · Criar modal Compartilhar coleção com cópia, redes, imagem e coleção pública — R3–R8, R10, R11 · CA1, CA3–CA5, CA8, CA9 · AB#1018
  - Pronto quando: `ShareCollectionDialog.spec.tsx` cobre CA1, CA3, CA4, CA5 e CA8, e print em 1280 px igual ao frame
    `1160-9616` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Acrescentar o botão Compartilhar coleção no Início e em Meus álbuns — R2, R11 · CA10, CA11 · AB#1019
  - Pronto quando: o botão abre o modal nas duas páginas, e print em 1280 px igual aos frames `1122-17812` e `1160-23080`
    e sem quebra em 375/768/1024 px.
- [ ] **T7** · Criar página pública da coleção compartilhada — R9 · CA6 · AB#1020
  - Pronto quando: `/u/:username` abre sem login, `SharedCollectionPage.spec.tsx` cobre CA6 e o `404`, e a tela segue o
    estilo do perfil público até o frame existir (L3), sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1021
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T6 |
| R3 | T1, T2, T3, T4, T5 |
| R4, R5, R6, R7 | T4, T5 |
| R8 | T1, T2, T3, T5 |
| R9 | T1, T2, T3, T7 |
| R10 | T5 |
| R11 | T5, T6 |
