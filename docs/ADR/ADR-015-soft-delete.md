# ADR-015 — Exclusão de dados: soft delete com `deleted_at`

- **Status:** Aceito (item 2 ampliado pelo ADR-016: `deleted_at` em todas as tabelas; exceção ao item 7 no ADR-062)
- **Data:** 2026-09-28
- **Decisores:** Equipe CromoCard

## Contexto

Vários casos de uso excluem dados: Exclusão da Conta (CCD052), Remover Álbum (CCD011),
Remover Carta (CCD018), Excluir Anúncio (CCD086), exclusão de grupos e mensagens pela
moderação, desfavoritar, desbloquear etc. Muitos desses registros são referenciados
por outros (pedidos apontam para o anúncio e o vendedor, denúncias apontam para a
mensagem). A equipe também quer que o usuário **possa voltar atrás**.

Foram avaliadas três estratégias: soft delete para tudo, hard delete para tudo, e
um modelo misto (soft em dados com histórico, hard em estados do usuário, e
anonimização na exclusão de conta). A equipe optou por **soft delete para tudo o que
é dado de negócio**, **sem anonimização**.

## Decisão

1. **Excluir = preencher `deleted_at` com `now()`.** Nenhum dado de negócio sofre `DELETE` físico.
   **Restaurar = voltar `deleted_at` para `NULL`.**
2. `deleted_at timestamp` (nulo = ativo) existe nas tabelas que têm ação de exclusão:
   `users`, `addresses`, `categories`, `albums`, `cards`, `card_photos`, `user_albums`,
   `collection_cards`, `groups`, `group_members`, `group_messages`, `messages`,
   `user_blocks`, `listings`, `listing_photos`, `favorites`, `price_alerts`.
3. **`deleted_at` é a fonte única da verdade da exclusão.** O valor `DELETED` foi removido
   dos enums `user_status`, `group_status` e `listing_status`. O `status` continua
   descrevendo o estado do registro ativo (ex.: `SUSPENDED`, `PAUSED`).
4. **Tabelas sem `deleted_at`**, porque nunca são excluídas: histórico e trilha
   (`orders`, `payments`, `reviews`, `offers`, `price_history`, `reports`,
   `catalog_requests`, `audit_logs`, `notifications`, `global_notifications`); tabelas
   que seguem o registro "pai" (`profiles`, `collections`, `conversations`,
   `conversation_participants`, `user_achievements`); e `poll_votes` (voto é definitivo).
5. **Consultas:** todo repository filtra `deletedAt: null` **de forma explícita**. Um
   helper em `shared/` evita repetição, mas não se usa extensão global "mágica" do
   Prisma, para o filtro ficar visível no código. Endpoints de admin podem aceitar
   `?includeDeleted=true`.
6. **Exclusão em cascata lógica:** excluir um registro "pai" não altera os filhos. Os
   filhos somem porque as consultas também filtram o pai (ex.: mensagens de um grupo
   excluído não aparecem, porque o grupo não aparece).
7. **Re-adicionar restaura.** Como as constraints `UNIQUE` continuam valendo para linhas
   excluídas (`user_albums`, `collection_cards`, `group_members`, `user_blocks`,
   `cards(album_id, number)`), adicionar de novo algo que foi excluído **restaura a linha
   existente** (upsert com `deleted_at = NULL`), em vez de inserir outra.
8. **Conta do usuário (CCD052):**
   - Excluir a conta preenche `users.deleted_at`, revoga todas as sessões
     (`refresh_tokens`) e esconde o perfil, os anúncios e a coleção pública (as consultas
     públicas filtram o dono excluído).
   - **Voltar:** ao tentar logar numa conta excluída, a API responde `403` com o código
     `ACCOUNT_DELETED`, e o front oferece "Reativar conta" (`POST /api/v1/auth/restore`,
     com as mesmas credenciais), que limpa o `deleted_at`.
   - Cadastro com o e-mail de uma conta excluída responde `409 ACCOUNT_DELETED`,
     sugerindo reativar a conta.
9. **Exceção (dados técnicos):** `password_reset_tokens` e `refresh_tokens` não são dados
   de negócio, são credenciais. Eles têm `used` / `revoked_at` e são **removidos
   fisicamente** pelo job de limpeza quando expiram (ADR-010), porque guardar
   credenciais velhas só aumenta a superfície de ataque.
10. **Performance:** nas tabelas grandes (`messages`, `group_messages`, `collection_cards`),
    criar índices parciais `WHERE deleted_at IS NULL` via SQL na migration.

## Alternativas consideradas

- **Hard delete para tudo:** quebra pedidos, denúncias e histórico, e não permite desfazer.
- **Misto com anonimização na exclusão de conta:** atende melhor à LGPD, mas a equipe
  preferiu manter a possibilidade de restaurar a conta sem prazo.

## Consequências

- Qualquer exclusão pode ser desfeita, e o histórico (pedidos, denúncias, auditoria) nunca quebra.
- **Risco principal:** esquecer o filtro `deletedAt: null` numa consulta e mostrar
  dado excluído. Isso precisa ser coberto por testes e cobrado no code review.
- O banco cresce continuamente (nada é removido).
- **LGPD:** a lei garante ao titular o direito de pedir a **eliminação** dos seus dados
  (art. 18, VI). O soft delete sozinho esconde os dados, mas não os elimina. Isso é
  aceitável para um projeto acadêmico. Se o sistema for para produção com usuários
  reais, esta decisão deve ser revista num novo ADR.
- DER atualizado: `deleted_at` nas 17 tabelas listadas e `DELETED` removido dos 3 enums de status.
