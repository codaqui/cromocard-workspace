# Tarefas — CCD031 Visualizar Informações da Carta

- **Plano:** [plano.md](plano.md) · **User story:** AB#164
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende da CCD030 (rota, página e componente).

## Backend — `apps/cromocard-backend`, branch `feature/164-visualizar-informacoes-da-carta`

- [ ] **T1** · Criar montagem da identificação da carta — R3–R6 · CA1, CA3, CA4 · AB#1117
  - Pronto quando: `card-identification.spec.ts` cobre carta completa, avulsa, sem idioma e a categoria do álbum (depende da L1), com 100% de cobertura.
- [ ] **T2** · Usar a identificação no perfil público da carta — R1, R4 · CA2 · AB#1118
  - Pronto quando: `GET /cards/:id` sem token traz `identification` sem condição, coberto em integração.

## Frontend — `apps/cromocard-frontend`, branch `feature/164-visualizar-informacoes-da-carta`

- [ ] **T3** [P] · Mostrar título e bloco de identificação do perfil da carta — R1–R7 · CA1–CA5 · AB#1119
  - Pronto quando: `CardIdentification.spec.tsx` cobre os cinco campos e o "—"; print em 1280 px igual ao frame `1112-4615` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T4** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1120
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T3 |
| R2 | T3 |
| R3, R5, R6 | T1, T3 |
| R4 | T1, T2, T3 |
| R7 | T3 |
