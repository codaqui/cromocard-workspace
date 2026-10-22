# Tarefas — Fundação técnica do Painel Administrador

- **Plano:** [plano.md](plano.md) · **User story:** AB#481
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/481-fundacao-backoffice` (Felipe Broetto)

- [ ] **T1** · Criar migrations do catálogo (categories, rarities, languages, albums, cards, card_photos) · AB#519
  - Pronto quando: as 6 tabelas existem, uma migration por tabela, e o `schema.prisma` bate com o DBML.
- [ ] **T2** · Criar migrations de comunidade e moderação (groups, group_members, group_messages, reports, catalog_requests) · AB#520
  - Pronto quando: as 5 tabelas existem; `listing_id` sem FK, como no plano.
- [ ] **T3** · Criar migrations de administração (audit_logs, global_settings, global_notifications, notifications) · AB#521
  - Pronto quando: as 4 tabelas existem e o `schema.prisma` bate com o DBML.
- [ ] **T4** · Criar seeds por domínio e o script db:seed · AB#522
  - Pronto quando: `npm run db:seed` cria admin com senha, usuários, catálogo, grupos, denúncias, solicitações e configurações.
- [ ] **T5** · Criar AuditLogService com motivo no domínio admin · AB#523
  - Pronto quando: o service grava `audit_logs` com o motivo em `details` e tem teste.
- [ ] **T6** · Criar provider de storage local e endpoint POST /uploads · AB#524
  - Pronto quando: o upload aceita PNG/JPG/WEBP até 4 MB, devolve a URL e recusa o resto com `400`.
- [ ] **T7** · Registrar os módulos vazios do admin (dashboard, reports, settings) em routes.ts · AB#525
  - Pronto quando: os módulos sobem sem rotas e cada story só acrescenta as suas.

## Frontend — `apps/cromocard-frontend`, branch `feature/481-fundacao-backoffice` (Gabriel)

- [ ] **T8** [P] · Criar componentes Modal, ConfirmDialog com motivo e Drawer · AB#526
  - Pronto quando: os três têm `.spec.tsx`, abrem e fecham por teclado e seguem o Figma.
- [ ] **T9** · Criar componentes de formulário Select, Textarea, Checkbox e FileUpload · AB#527
  - Pronto quando: os quatro funcionam com React Hook Form e têm teste.
- [ ] **T10** · Criar componentes Tabs, Badge, KpiCard, DataTable, Toast e PeriodFilter · AB#528
  - Pronto quando: os seis têm teste e aparecem na página provisória do Dashboard.
- [ ] **T11** · Montar o menu do BackOffice com os 9 módulos e rotas provisórias · AB#529
  - Pronto quando: o menu do Figma navega para as 9 rotas, cada uma com página "em construção".
- [ ] **T12** · Desenhar no Figma as telas que faltam (recuperar senha, redefinir senha, confirmar e-mail, tipo de usuário no cadastro) · AB#530
  - Pronto quando: as telas existem no arquivo do Figma e o índice do `/analisar-figma-chrome` foi atualizado.

## Fechamento — workspace

- [ ] **T13** · Atualizar os ponteiros `apps/*` e marcar a fundação como concluída no índice · AB#531
  - Pronto quando: os PRs dos apps estão mergeados em `develop`.
