# Tarefas — CCD104 Ordenar Categorias Padrão

- **Plano:** [plano.md](plano.md) · **User story:** AB#608
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Refeitas em 2026-11-17 sobre o código da CCD066. Os títulos de T1–T3 e T5–T7 mudaram e precisam ser atualizados nas
  Tasks do Azure; T9 e T10 ainda não têm Task.

## Backend — `apps/cromocard-backend`, branch `feature/608-ordenar-categorias-padrao`

- [ ] **T1** · Criar migration de exibição em categories com slug, ordem inicial e índice parcial — R9, R13 · CA16 · AB#694
  - Pronto quando: a migration `add_display_fields_to_categories_table` cria as 4 colunas e o índice
    `categories_slug_key` `WHERE deleted_at IS NULL` (conferido no SQL gerado); o `prisma migrate dev` não acusa
    diferença; as categorias do seed têm slug, as padrão estão em ordem alfabética e nenhuma está fixada.
- [ ] **T3** · Gerar slug e receber o selo no cadastro de categoria — R9, R10 · CA6, CA12, CA13 · AB#696
  - Pronto quando: `slug.spec.ts` e `catalog.service.spec.ts` cobrem CA6, CA12 e CA13, e o
    `tests/integration/admin-catalog.spec.ts` confirma o `409 SLUG_TAKEN` com duas ativas e a criação com uma excluída.
- [ ] **T9** · Contar cartas e buscar por slug nas categorias do catálogo — R2, R11 · CA1, CA15
  - Pronto quando: a contagem soma cartas diretas e dos álbuns das subcategorias (Futebol no seed), e a busca
    `magic-the` encontra Magic: The Gathering no `GET /admin/catalog/categories`.
- [ ] **T2** · Gravar a ordem e a categoria fixada no PATCH das categorias padrão com auditoria — R4, R5, R6 · CA2, CA3, CA7, CA8, CA11 · AB#695
  - Pronto quando: `settings-default-categories.service.spec.ts` e `settings.validator.spec.ts` cobrem CA2, CA3 e CA8
    (dois fixados dão 400), e o `tests/integration/admin-settings.spec.ts` cobre CA7 e CA11 e o antes e depois do log.
- ~~**T4**~~ · removida: não há rota nova (L11); o R1 e o CA7 ficam com a rota da CCD066, testados na T2 · AB#697

## Frontend — `apps/cromocard-frontend`, branch `feature/608-ordenar-categorias-padrao` (depois do merge do PR 21)

- [ ] **T5** [P] · Acrescentar slug, selo, fixada, ordem e quantidade aos tipos, schemas e api das categorias — R2, R5, R9, R10 · AB#698
  - Pronto quando: `catalog` e `admin/settings` tipam os campos novos, `categoryBadgeLabels` sai pelo `index.ts` do
    catálogo, `src/lib/slug.ts` passa nos mesmos exemplos do backend e o typecheck passa.
- [ ] **T7** · Acrescentar o selo e o slug no formulário de categoria — R9, R10 · CA6, CA13, CA14 · AB#700
  - Pronto quando: `CategoryForm.spec.tsx` cobre a prévia do slug, as três opções do selo e o `409 SLUG_TAKEN` no
    campo Nome, fiel ao `833-10832`.
- [ ] **T10** · Mostrar slug, selo e quantidade de cartas na aba Categorias com busca por slug — R11 · CA14, CA15
  - Pronto quando: `CategoriesTab.spec.tsx` cobre as colunas e a busca, fiel ao fundo do `833-10832`.
- [ ] **T6** · Criar a ordenação no módulo de categorias padrão com setas, arrastar, alfinete e salvar — R2–R4, R7, R8, R12 · CA1–CA4, CA8–CA10 · AB#699
  - Pronto quando: `useDefaultCategoriesEditor.spec.ts` e `DefaultCategoriesModule.spec.tsx` cobrem mover, arrastar,
    fixar, desafixar, setas nas pontas, "Cancelar" e "Salvar ordem", fiel ao `228-3048` com as diferenças decididas, e
    a matriz de responsividade passa.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#701
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2 |
| R2 | T9, T5, T6 |
| R3 | T6 |
| R4 | T2, T6 |
| R5 | T2, T5, T6 |
| R6 | T2 |
| R7, R8 | T6 |
| R9 | T1, T3, T5, T7 |
| R10 | T3, T5, T7 |
| R11 | T9, T10 |
| R12 | T6 |
| R13 | T1 |
