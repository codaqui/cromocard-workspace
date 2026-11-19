# Tarefas — CCD105 Duplicar Carta

- **Plano:** [plano.md](plano.md) · **User story:** AB#609
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/609-duplicar-carta`

- [x] **T1** · Criar migration de código e variantes em cards — R8 · AB#702
  - O `code` ganha o índice único parcial `cards_code_key` (`WHERE deleted_at IS NULL`, ADR-063).
  - Pronto quando: as colunas e o índice existem e o `schema.prisma` bate com o DBML.
- [x] **T2** · Acrescentar código e variantes no validator e no service de cartas — R4, R5, R8, R11 · CA3, CA5, CA10 · AB#703
  - Arquivos: `catalog.validator.ts`, `catalog.errors.ts`, `catalog-cards.repository.ts`, `catalog.service.ts`.
  - O `409 CARD_CODE_TAKEN` traz "Este código já está em uso por <nome>." no campo `code` (L10); o `q` busca também
    no `code` (R11).
  - O código de uma carta excluída não bloqueia (L7, ADR-063).
  - Pronto quando: `catalog.service.spec.ts` cobre CA3 e CA5.
- [x] **T3** · Criar resumo do catálogo, filtro por ano e exclusão em lote com auditoria — R7, R9, R10 · CA4, CA7, CA9 · AB#704
  - O filtro `year` usa o ano do álbum; a exclusão em lote devolve `{ deleted, skipped }`, sem `422`.
  - Pronto quando: `catalog.service.spec.ts` cobre CA4, CA7 e CA9.
- [x] **T4** · Criar rotas de resumo e exclusão em lote do catálogo — R1 · CA8 · AB#705
  - Pronto quando: as rotas aparecem no `/docs` e o teste de integração cobre o `403` para quem não é ADMIN (CA8),
    a busca por código (CA10) e o reuso do código de uma carta excluída (L7).

- [ ] **T9** · Ligar a checagem de coleções e auditar o lote na mesma transação — R10 · CA7, CA9 · AB#704
  - `CardUsage` obrigatório com `cardIdsInCollections(ids)`; o módulo injeta `noCollectionsYet` até a CCD014 (L14).
  - `softDeleteMany` e o `audit_logs` de cada carta numa transação; contratos em `catalog.ports.ts`.
  - Pronto quando: `catalog.service.spec.ts` cobre CA7, CA9 e a falha da auditoria desfazendo a exclusão.

## Frontend — `apps/cromocard-frontend`, branch `feature/609-duplicar-carta`

- [x] **T5** [P] · Criar api, queries e schemas de código, variantes e resumo — R7–R10 · AB#706
  - Arquivos: `src/features/catalog/catalog.api.ts`, `catalog.queries.ts`, `catalog.schemas.ts`, `catalog.types.ts`.
  - Pronto quando: o typecheck passa.
- [x] **T6** · Criar ação Duplicar com o formulário preenchido — R2–R6 · CA1, CA2 · AB#707
  - Arquivos: `CardForm`, `CardFormModal`, `useCardForm.ts`, `CatalogRowActions`.
  - Copia nome, franquia, álbum, raridade, idioma, variantes e descrição (L11); "Ano de lançamento" e "Salvar como
    Rascunho" aparecem desabilitados (L12); código repetido mostra o nome da carta (L10).
  - Pronto quando: `CardFormModal.spec.tsx` cobre CA1 e CA2.
- [x] **T7** · Acrescentar indicadores, código, variantes, filtro por ano e seleção em lote na lista — R7–R10 · CA4, CA6, CA7, CA9 · AB#708
  - Chips e "Limpar todos os filtros" já vêm da CCD061; aqui entram os dois indicadores do Figma no lugar dos atuais
    (L8), o filtro por ano, o filtro de status desabilitado (L12), a seleção e o modal de exclusão em lote com o aviso
    das cartas puladas (L13).
  - Pronto quando: `CatalogAdminPage.spec.tsx` cobre o filtro por ano com CA6, a exclusão em lote (CA7) e o aviso
    das cartas puladas (CA9).

- [ ] **T10** · Separar a seleção e a exclusão em lote do CardsTab e tirar os comentários — R10 · AB#708
  - `useBulkDeletion` em `hooks/`, coluna de seleção em `components/`, regra "todos selecionados" num lugar só.
  - Pronto quando: `CatalogAdminPage.spec.tsx` continua cobrindo CA7 e CA9 e o lint passa.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#709
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4 |
| R2, R3, R6 | T6 |
| R4, R5 | T2, T6 |
| R7, R9 | T3, T5, T7 |
| R10 | T3, T5, T7, T9, T10 |
| R8 | T1, T2, T5, T7 |
| R11 | T2, T4 |
