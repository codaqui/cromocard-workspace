# Tarefas — CCD035 Resetar Progresso do Álbum

- **Plano:** [plano.md](plano.md) · **User story:** AB#138
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende da CCD007, CCD019 e CCD013; o menu "⋯" pode vir da CCD011.

## Backend — `apps/cromocard-backend`, branch `feature/138-resetar-progresso-do-album`

- [ ] **T1** · Criar service de resetar o progresso do álbum — R1, R4–R6 · CA1, CA2 · AB#1133
  - Pronto quando: `collection-reset.service.spec.ts` cobre o reset, outro álbum intacto, álbum sem marcação e o `404`, com 90% de cobertura.
- [ ] **T2** · Criar endpoint POST /collections/me/albums/:albumId/reset — R1, R5 · CA1, CA2, CA4, CA5 · AB#1134
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/collection-reset.spec.ts` cobre `200`, `401`, `403`, `404` e a restauração ao re-marcar.

## Frontend — `apps/cromocard-frontend`, branch `feature/138-resetar-progresso-do-album`

- [ ] **T3** [P] · Criar mutação e textos do reset do álbum — R3, R4, R7 · AB#1135
  - Pronto quando: o typecheck passa e a mutação invalida grade, progresso e lista de álbuns.
- [ ] **T4** · Criar item Resetar progresso no menu do álbum — R2, R9 · CA6 · AB#1136
  - Pronto quando: `AlbumActionsMenu.spec.tsx` cobre o item e o desabilitado (depende da L1); print em 1280 px igual ao frame `1160-26090` e sem quebra em 375/768/1024 px.
- [ ] **T5** · Criar confirmação de resetar o progresso — R3, R7, R8, R9 · CA1, CA3, CA7 · AB#1137
  - Pronto quando: `ResetProgressDialog.spec.tsx` e `AlbumDetailPage.spec.tsx` cobrem confirmar, cancelar e "✕"; print em 1280 px igual ao frame `1160-27304` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1138
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T2 |
| R2 | T4 |
| R3 | T3, T5 |
| R4 | T1, T3 |
| R5 | T1, T2 |
| R6 | T1 |
| R7 | T3, T5 |
| R8 | T5 |
| R9 | T4, T5 |
