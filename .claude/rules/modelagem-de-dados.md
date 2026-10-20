---
paths:
  - "docs/Diagramas/DER/**"
  - "docs/Diagrama-de-Classe/**"
  - "apps/cromocard-backend/database/**"
---

# Modelo de dados — DER, diagrama de classes e `schema.prisma`

- **Fonte da verdade:** `docs/Diagramas/DER/dbdiagram.io/03-der-completo.dbml`. Os `.sql` em
  `chartdb/` e os `.puml` são derivados dele — **mantenha os três formatos sincronizados** ao
  alterar o modelo (44 tabelas, 77 FKs, 22 enums). Os `.svg` estão desatualizados (pré-tradução).
- O diagrama de classes (`docs/Diagrama-de-Classe/cromocard-diagrama-classes.v2.c4`) é 1:1 com o DER
  (ADR-036): entidade criada ou alterada no DER muda também a classe correspondente.
- **Identificadores em inglês** (ADR-003): tabelas `snake_case` no **plural** (`users`, `orders`,
  `groups` — singular colide com palavras reservadas do PostgreSQL), colunas/enums no singular,
  valores de enum em MAIÚSCULAS, datas `*_at`. Comentários e notas continuam em português.
  Glossário PT → EN no `README.md` do DER — use-o ao ler casos de uso que citam nomes antigos.
- PK `id` **UUID v7** (`uuidv7()`, PostgreSQL 18+), FKs `uuid` (ADR-014) · associativas N:N com PK composta (`user_achievements`,
  `poll_votes`, `conversation_participants`) · FKs em `ALTER TABLE` no fim do SQL (`fk_<tabela>_<coluna>`).
- **Alvos polimórficos** (ADR-032): `favorites` (`type` + `album_id`/`card_id`/`group_id`, exatamente
  um preenchido) e `reports` (`target_type` + `listing_id`/`target_user_id`/`group_message_id`).
- `cards.album_id` nulo = carta avulsa (portfólio). `catalog_requests.data` é `jsonb`.
- **Tempo** (ADR-016): toda tabela termina com `created_at`, `updated_at`, `deleted_at` — todos `timestamptz`.
- `refresh_tokens` guarda só o hash do refresh token (ADR-005).
- **Soft delete** (ADR-015): excluir = `deleted_at = now()`, restaurar = `NULL`. Nunca `DELETE` em dado de
  negócio (exceção: tokens expirados, limpos por cron). Re-adicionar item excluído restaura a linha (upsert).
  `DELETED` não existe nos enums de status.
- **`schema.prisma`** (`apps/cromocard-backend/database/`): só tem as tabelas já implementadas. Cada tabela nova
  entra copiada do DBML, numa migration própria (`npm run db:migrate -- --name create_<tabela>_table`), com os
  nomes do banco mapeados (`@@map`/`@map`) para camelCase no Prisma.
- A tabela de rastreabilidade entidade → caso de uso está em `docs/Diagramas/DER/README.md`; atualize-a ao
  criar ou mudar uma entidade.
