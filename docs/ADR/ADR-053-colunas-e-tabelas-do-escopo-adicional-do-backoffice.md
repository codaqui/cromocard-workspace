# ADR-053 — Colunas, enums e tabelas do escopo adicional do BackOffice

- **Status:** Aceito (validado pelo PO em 22/10/2026)
- **Data:** 2026-10-22
- **Decisores:** Daniel Andrade (PO), equipe CromoCard

## Contexto

O escopo adicional do protótipo (CCD096 a CCD107, `docs/Casos-De-Uso/escopo-adicional.md`) entrou na Sprint 06.
Fora o credenciamento de vendedor (ADR-052), essas user stories precisam de dados que o DER não tem: nome de usuário,
CPF e último acesso; suspensão com prazo, bloqueio e advertências; ordem das categorias; rascunho e código da carta;
agendamento e público da notificação global; votos nas solicitações; IP no log; e o arquivo exportado guardado por
90 dias.

O PR #4 (cancelado) já propunha parte disso (`users.phone`, `users.username`, `users.last_login_at`,
`categories.slug`, `categories.display_order`); esta decisão parte daquela proposta e cobre o resto.

## Decisão

1. **`users`:** acrescente `username` (único), `phone`, `cpf` (único), `last_login_at`, `last_login_ip`
   (CCD098) e `suspended_until` (CCD099). O enum `user_status` ganha `BLOCKED` (banido definitivamente).
2. Crie **`user_warnings`** (CCD099): `user_id`, `admin_id`, `report_id` opcional (denúncia que originou) e `reason`.
   A contagem de advertências é a quantidade de linhas.
3. **`groups`:** o enum `group_status` ganha `WARNED` (grupo advertido, CCD099).
4. **`categories`:** acrescente `slug` (único), `display_order`, `is_pinned` e `badge` (CCD104).
5. **`cards`:** acrescente `status` (enum novo **`card_status`**: `DRAFT`, `ACTIVE`, padrão `ACTIVE`, CCD106), `code`
   (único), `variants` (CCD105) e `release_year` (CCD106). O catálogo, as buscas e as coleções só mostram
   `status = ACTIVE`.
6. **`global_notifications`:** acrescente `reference_link`, `audience` (`ALL`, `ACTIVE_COLLECTORS`, `SELLERS`),
   `channels` (`IN_APP`, `EMAIL`), `status` (enum novo **`notification_dispatch_status`**: `SCHEDULED`, `SENT`,
   `CANCELED`, padrão `SENT`), `scheduled_at` e `sent_at` (CCD100, CCD101). Um job do ADR-010 envia os agendados.
7. Crie **`catalog_request_votes`** (CCD103), com PK composta (`catalog_request_id`, `user_id`) e `vote` (enum novo
   **`catalog_vote`**: `FOR`, `NEUTRAL`, `AGAINST`). A meta de votos fica em `global_settings`
   (`catalog.voting_goal`).
8. **`audit_logs`:** acrescente `ip_address` (CCD102).
9. Crie **`report_exports`** (CCD107): `admin_id`, `report_type`, `filters`, `format`, `file_url`, `file_size` e
   `expires_at` (`created_at` + 90 dias). Um job do ADR-010 apaga o arquivo vencido no storage e marca a linha como
   excluída.
10. **Cada coluna entra com a user story que a usa**, numa migration própria (`add_<colunas>_to_<tabela>`), mesmo
    quando a tabela já existe pela fundação do BackOffice. A fundação cria as tabelas só com as colunas do MVP.

## Alternativas consideradas

- **Status `SUSPENDED` com prazo em vez de `BLOCKED`:** o banimento definitivo não tem prazo, e o protótipo mostra
  "Bloqueado" separado de "Suspenso (7d)".
- **Contador `warning_count` em `users`:** mais simples, mas perde quem advertiu, por quê e a denúncia de origem.
- **Push no `channels`:** não há app mobile nem serviço de push no projeto; fica para um ADR próprio.
- **Histórico de exportações só em `audit_logs` (ADR-051, item 5):** continua valendo para o MVP; o
  `report_exports` só existe porque a CCD107 guarda o arquivo.
- **Guardar o CPF:** o PR #4 descartou pela LGPD. O PO incluiu a CCD098 com CPF; ele só aparece no BackOffice, e os
  logs não registram o valor (ADR-019).

## Consequências

- O DER fica com 50 tabelas, 90 FKs e 27 enums, nos três formatos e no diagrama de classes.
- As specs CCD096 a CCD107 citam estas colunas e criam as migrations delas.
- O login (CCD004) passa a gravar `last_login_at` e `last_login_ip` quando a CCD098 for implementada; a CCD098 faz
  essa mudança no `auth.service`.
- Usuário `BLOCKED` não loga nem renova o token, como o `SUSPENDED` (ADR-005, item 6).

## Referências

- Casos de uso 96 a 107; `docs/Casos-De-Uso/escopo-adicional.md`
- ADR-005, ADR-010 (jobs), ADR-015, ADR-019, ADR-051, ADR-052
