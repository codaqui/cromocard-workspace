# Tarefas — CCD020 Compartilhar Progresso

- **Plano:** [plano.md](plano.md) · **User story:** AB#126
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende da CCD007 (coleção), da CCD019 (progresso) e da CCD013 (detalhe do álbum). A T1 espera o PR de docs da L8.

## Docs — workspace

- [ ] **T1** · Registrar no DBML a coluna da opção de mostrar as faltantes — R8 · AB#1062
  - Pronto quando: a L8 está decidida, os três `.dbml` têm a coluna e o ADR `Proposto` foi aberto.

## Backend — `apps/cromocard-backend`, branch `feature/126-compartilhar-progresso`

- [ ] **T2** · Criar migration da opção de mostrar as faltantes — R8 · AB#1063
  - Pronto quando: a coluna decidida na T1 existe no `schema.prisma` e o `migrate diff` sai vazio.
- [ ] **T3** · Criar validator, erros e repository do compartilhamento — R1, R3, R8, R9 · AB#1064
  - Pronto quando: o repository conta repetidas, lista as faltantes por número e acha o álbum por `username` + `albumId`.
- [ ] **T4** · Criar service do cartão, do link e da página pública — R3, R4, R8, R9 · CA1, CA6 · AB#1065
  - Pronto quando: `collection-share.service.spec.ts` cobre 44/54, 0%, opção ligada e desligada e o `404` da página pública (e coleção privada, depende da L7).
- [ ] **T5** · Criar endpoints GET e PATCH /collections/me/albums/:albumId/share e GET /users/:username/albums/:albumId/progress — R1, R8, R9 · CA6, CA7, CA9 · AB#1066
  - Pronto quando: as rotas aparecem no `/docs` e `tests/integration/collection-share.spec.ts` cobre `200`, `401`, `404` e a opção persistida.

## Frontend — `apps/cromocard-frontend`, branch `feature/126-compartilhar-progresso`

- [ ] **T6** [P] · Criar tipos, api, queries e textos do compartilhamento — R2–R9 · AB#1067
  - Pronto quando: o typecheck passa e os textos do modal, do alerta e do sucesso (L9) estão em `collection-share.labels.ts`.
- [ ] **T7** · Criar botão Compartilhar progresso e o alerta de álbum vazio — R2, R7, R11 · CA4, CA5, CA10, CA12 · AB#1068
  - Pronto quando: `ShareProgressButton.spec.tsx` cobre 0% e > 0%; print em 1280 px igual aos frames `1160-23696` e `1160-26693` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Criar modal de compartilhar progresso — R2–R6, R8, R10, R11 · CA1–CA3, CA7, CA8, CA11 · AB#1069
  - Pronto quando: `ShareProgressModal.spec.tsx` cobre copiar, compartilhar, a opção salva ao mudar e fechar; print em 1280 px igual ao frame `1160-25301` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Criar página pública do progresso do álbum e a rota /u/:username/albuns/:albumId — R9 · CA6 · AB#1070
  - Pronto quando: `SharedAlbumPage.spec.tsx` cobre com e sem faltantes e o `404`, sem login; sem quebra em 375/768/1024/1280 px (sem frame, L10).

## Fechamento — workspace

- [ ] **T10** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1071
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3, T5 |
| R2 | T6, T7, T8 |
| R3, R4 | T3, T4, T6, T8 |
| R5, R6, R10 | T6, T8 |
| R7 | T6, T7 |
| R8 | T1, T2, T3, T4, T5, T6, T8 |
| R9 | T3, T4, T5, T6, T9 |
| R11 | T7, T8 |
