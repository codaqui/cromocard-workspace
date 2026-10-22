# ADR-051 — Convenções das colunas flexíveis do BackOffice

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-10-22
- **Decisores:** Daniel Andrade (PO), equipe CromoCard

## Contexto

O DER deixa algumas colunas abertas, sem dizer o formato do conteúdo: `global_settings.value` (`text`),
`notifications.type` (`varchar`), `catalog_requests.data` (`jsonb`), `audit_logs.action` (`varchar`) e
`audit_logs.details` (`jsonb`). As specs CCD059 a CCD066, aprovadas em 22/10/2026, decidiram usar essas colunas sem
mudar o DER, e cada domínio precisa gravar e ler do mesmo jeito.

## Decisão

1. **`global_settings`:** cada configuração é uma chave com o `value` em JSON, validado por um schema Zod por chave.
   As chaves são criadas pelo seed: `home.banner` e `notification.templates`. Só `home.banner` tem leitura pública,
   em `GET /api/v1/settings/public/home.banner`.
2. **`notifications.type`:** lista fechada em inglês e maiúsculas, num enum do código: `GLOBAL` (CCD060) e
   `CATALOG_REQUEST` (CCD064). Um tipo novo entra pela spec que precisar dele.
3. **`catalog_requests.data`:** guarda o que o usuário sugeriu e, depois da análise, `rejectionReason` (recusa,
   CCD064) e `createdCategoryId` (categoria criada na aprovação, que não tem FK própria).
4. **`audit_logs.action`:** lista fechada no `AuditLogService`, no padrão `ENTIDADE_ACAO` (ex.: `USER_SUSPENDED`,
   `GROUP_DELETED`, `CATALOG_REQUEST_APPROVED`, `EXPORT_REPORT`), com o rótulo em português no frontend.
5. **`audit_logs.details`:** sempre tem `reason` quando a ação exige motivo, e os valores antes e depois quando houver
   alteração. O histórico de exportações da CCD063 é lido daqui (`action = EXPORT_REPORT`, com o tipo, os filtros e
   o formato em `details`), sem tabela própria.

## Alternativas consideradas

- **Uma coluna por configuração ou uma tabela por tipo de configuração:** deixa o banco mais rígido, mas cada
  configuração nova vira migration.
- **Enum no banco para `notifications.type` e `audit_logs.action`:** pegaria erro no banco, mas o DER já definiu
  `varchar` e cada valor novo viraria migration de enum.
- **Colunas `rejection_reason` e `created_category_id` em `catalog_requests`:** mais explícitas, mas mudam o DER para
  dois campos que só a tela de análise lê.
- **Tabela `report_exports`:** duplicaria o que `audit_logs` já guarda (ADR-034).

## Consequências

- Os schemas por chave de `global_settings` e as listas de `type` e `action` ficam no código, testados, e são a
  referência de valores válidos.
- O DER não muda.
- Se a CCD107 (escopo adicional) guardar os arquivos exportados, ela precisa de tabela própria e de um ADR novo.

## Referências

- ADR-034 (trilha de auditoria), DBML `global_settings`, `notifications`, `catalog_requests`, `audit_logs`
- Specs CCD060, CCD063, CCD064, CCD065 e CCD066
