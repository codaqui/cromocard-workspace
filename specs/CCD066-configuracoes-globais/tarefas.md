# Tarefas — CCD066 Configurações Globais

- **Plano:** [plano.md](plano.md) · **User story:** AB#341
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- As tarefas T7 e T8 nasceram das decisões L9–L19 (15/11/2026) e ainda não têm Task no Azure: usam o `AB#341`.

## Backend — `apps/cromocard-backend`, branch `feature/341-configuracoes-globais`

- [x] **T1** · Criar schemas por chave, validator e repository das configurações — R3–R5, R7, R11, R16, R17, R19 · AB#592
  - Pronto quando: as cinco chaves validam, os templates ganham `id` e o nome não se repete, e o repository grava `updated_by_id`.
- [x] **T7** · Criar serviço de categorias padrão no catálogo — R10, R13 · CA4 · AB#341
  - Pronto quando: `catalog-default-categories.service.spec.ts` cobre o conjunto trocado, a categoria excluída e a com pai.
- [x] **T2** · Criar service de configurações com auditoria, metas e categorias padrão — R4–R7, R10, R11, R13, R14, R16, R17 · CA2–CA4, CA7, CA9, CA10 · AB#593
  - Pronto quando: `settings.service.spec.ts` e `settings-default-categories.service.spec.ts` cobrem os CAs da tarefa e cada gravação audita na mesma transação.
- [x] **T3** · Criar rotas de admin e a leitura pública do banner — R1, R15 · CA6, CA8 · AB#594
  - Pronto quando: as rotas aparecem no `/docs`, a pública só aceita `home.banner` e a integração cobre `401`, `403` e `404`.
- [x] **T8** [P] · Criar no seed as chaves das metas e dos versos e o link `https` do banner — R18 · AB#341
  - Pronto quando: `npm run db:seed` cria as cinco chaves e os valores passam nos schemas da T1.

## Frontend — `apps/cromocard-frontend`, branch `feature/341-configuracoes-globais`

- [ ] **T4** [P] · Criar api, queries e schemas das configurações — R4, R7, R12, R16, R20 · AB#595
  - Pronto quando: os schemas espelham o backend e o typecheck passa.
- [ ] **T5** · Criar tela de configurações com banner, categorias padrão, templates e metas — R2–R13, R16, R17, R19, R20 · CA1–CA5, CA7, CA9–CA11 · AB#596
  - Pronto quando: os testes da página e dos módulos cobrem salvar, erro por campo e cancelar em cada módulo, e a tela
    bate com os frames `228-3048`, `859-661`, `859-1068` e `859-1479` (com as diferenças da L9 e da L20) em todas as
    larguras.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#597
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2, R6, R8 | T5 |
| R3–R5, R7 | T1, T2, T4, T5 |
| R9, R12, R20 | T4, T5 |
| R10, R13 | T7, T2, T5 |
| R11, R19 | T1, T2, T5 |
| R14 | T2 |
| R15 | T3 |
| R16, R17 | T1, T2, T4, T5 |
| R18 | T8 |
