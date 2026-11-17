# ADR-062 — Slug de categoria único só entre as categorias não excluídas

- **Status:** Aceito (validado pelo PO em 17/11/2026)
- **Data:** 2026-11-17
- **Decisores:** Lucas Oliveira Lima (proposta, na CCD104); validação: Felipe Consulim (PO)

## Contexto

A CCD104 (ADR-053, item 4) cria `categories.slug`, gerado a partir do nome e único. O ADR-015, item 7, diz que as
constraints `UNIQUE` continuam valendo para as linhas excluídas e que adicionar de novo algo excluído **restaura a
linha** (upsert com `deleted_at = NULL`). Ele lista as tabelas onde isso acontece (`user_albums`, `collection_cards`,
`group_members`, `user_blocks`, `cards(album_id, number)`), e `categories` não está entre elas.

Com o slug, a regra do ADR-015 traria dois problemas:

- uma categoria excluída prenderia o slug para sempre, e recriar "Pokémon" depois de excluir daria conflito;
- restaurar a excluída também não serve, porque nomes diferentes geram o mesmo slug ("Pokémon TCG" e "Pokemon TCG"),
  e a categoria restaurada traria de volta tipo, categoria pai e descrição antigos sem o admin pedir.

Na CCD104, a lacuna L14 decidiu que o slug é único só entre as categorias não excluídas, que o slug repetido de uma
categoria ativa responde `409 SLUG_TAKEN` e que a categoria excluída não é restaurada.

## Decisão

1. Garanta a unicidade de `categories.slug` com um **índice único parcial** no PostgreSQL:
   `CREATE UNIQUE INDEX categories_slug_key ON categories (slug) WHERE deleted_at IS NULL`. Descreva-o no
   `schema.prisma` com `@@unique([slug], map: "categories_slug_key", where: raw("deleted_at IS NULL"))` e a preview
   feature `partialIndexes` do Prisma (7.10), para o `migrate dev` conhecer o índice e não o apagar. Testado em
   17/11/2026 num PostgreSQL 18 descartável, com o schema do `develop` do backend: o `prisma migrate diff` gerou
   `CREATE UNIQUE INDEX "categories_slug_key" ON "categories"("slug") WHERE (deleted_at IS NULL)`; depois de aplicar
   a migration, o diff entre as migrations e o schema ficou vazio (o `migrate dev` não apaga nem recria o índice); e
   o banco aceitou um slug repetido de uma categoria excluída e recusou o de duas ativas.
2. Ao criar ou renomear uma categoria, gere o slug a partir do nome (sem acentos, minúsculas e hífens) e, se ele já
   pertencer a outra categoria não excluída, responda `409 SLUG_TAKEN` no campo `name`. Uma categoria excluída com o
   mesmo slug não bloqueia e **não é restaurada**.
3. Na migration que cria a coluna, gere o slug das categorias existentes e resolva repetições com sufixo numérico
   (`-2`, `-3`…), pela ordem de criação.
4. O item 7 do ADR-015 continua valendo para as tabelas que ele lista. Esta exceção vale só para `categories.slug`.

## Alternativas consideradas

- **`UNIQUE` comum e restaurar a excluída (ADR-015, item 7):** recusada pelos dois problemas do contexto.
- **`UNIQUE` comum e trocar o slug da excluída ao excluir** (ex.: `pokemon--excluida-<id>`): libera o slug sem índice
  parcial, mas grava um valor artificial na linha excluída e complica restaurar a categoria no futuro.

## Consequências

- Recriar uma categoria excluída funciona e gera um registro novo; o histórico da antiga continua no banco.
- O backend passa a usar uma preview feature do Prisma (`partialIndexes`). Se ela mudar numa versão futura, o índice
  continua no banco e a migration SQL gerada continua valendo. Um teste de integração confirma o `409` com duas
  categorias ativas e a criação com uma excluída.
- A busca por slug no Catálogo (CCD104, L15) usa o mesmo índice.

## Referências

- ADR-015 (soft delete), item 7 · ADR-053, item 4 · ADR-011 (erros `409`)
- `docs/Casos-De-Uso/61-gestao-de-catalogo.md`, FP 5–6 · `docs/Casos-De-Uso/104-ordenar-categorias-padrao.md`
- `specs/CCD104-ordenar-categorias-padrao/spec.md`, L14
- `docs/Diagramas/DER/03-der-completo.dbml`, tabela `categories`
