# ADR-063 — Código de carta único só entre as cartas não excluídas

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-11-19
- **Decisores:** Lucas Oliveira Lima (proposta, na CCD105); validação: Felipe Consulim (PO)
- **Exceção a:** ADR-015, item 7 (só para `cards.code`)

## Contexto

A CCD105 (ADR-053, item 5) cria `cards.code`, o código da carta (ex.: `CRD-POK-0004`), digitado, opcional e único
(EA-061-02). O ADR-015, item 7, diz que as constraints `UNIQUE` continuam valendo para as linhas excluídas e que
adicionar de novo algo excluído restaura a linha. `cards.code` não está entre as tabelas que ele lista.

Com a regra do ADR-015, uma carta excluída prenderia o código para sempre: o admin receberia `409` por um código que
não vê em lugar nenhum e não teria como liberar. Restaurar a carta excluída também não serve, porque o código não
identifica uma posição no álbum, como a numeração (`cards (album_id, number)`), e a carta restaurada traria de volta
nome, imagens e dados antigos sem o admin pedir.

O ADR-062 resolveu o mesmo problema para `categories.slug` com um índice único parcial, e o projeto já usa a preview
feature `partialIndexes` do Prisma 7.10 para descrevê-lo no `schema.prisma`.

## Decisão

1. Garanta a unicidade de `cards.code` com um **índice único parcial**:
   `CREATE UNIQUE INDEX cards_code_key ON cards (code) WHERE deleted_at IS NULL`, descrito no `schema.prisma` com
   `@@unique([code], map: "cards_code_key", where: raw("deleted_at IS NULL"))`, como no ADR-062.
2. Ao criar ou editar uma carta com um código que já pertence a outra carta não excluída, responda
   `409 CARD_CODE_TAKEN` no campo `code`, com a mensagem "Este código já está em uso por <nome da carta>."
   (CCD105, L10). Uma carta excluída com o mesmo código não bloqueia e **não é restaurada** por causa dele.
3. A carta excluída mantém o código na linha: a exclusão não altera o `code`.
4. O item 7 do ADR-015 continua valendo para as tabelas que ele lista, inclusive `cards (album_id, number)`. Esta
   exceção vale só para `cards.code`.

## Alternativas consideradas

- **`UNIQUE` comum (ADR-015, item 7):** recusada, porque a carta excluída prenderia o código para sempre.
- **`UNIQUE` comum e gravar `code = null` ao excluir, com o código antigo no `audit_logs`:** libera o código sem
  índice parcial, mas altera a linha excluída, espalha a regra pelos dois caminhos de exclusão (uma carta e em lote) e
  vai contra o que o ADR-062 recusou para o slug. Foi a primeira proposta da L7 da CCD105, trocada por esta.

## Consequências

- Cadastrar de novo o código de uma carta excluída funciona, e o histórico da carta antiga continua intacto no banco.
- A exclusão de carta (uma e em lote) não muda por causa do código.
- A restauração de carta pela numeração (ADR-015, item 7) pode encontrar o código da carta restaurada em uso por
  outra carta ativa: a carta restaurada recebe o `code` do formulário, e o `409` vale para ele.
- Um teste de integração confirma o `409` com duas cartas ativas e a criação com o código de uma excluída.

## Referências

- ADR-015 (soft delete), item 7 · ADR-062 (slug de categoria) · ADR-053, item 5 · ADR-011 (erros `409`)
- `docs/Casos-De-Uso/escopo-adicional.md`, EA-061-02
- `specs/CCD105-duplicar-carta/spec.md`, L7 e L10
- `docs/Diagramas/DER/03-der-completo.dbml`, tabela `cards`
