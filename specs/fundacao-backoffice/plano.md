# Plano — Fundação técnica do Painel Administrador

- **User story:** #481 `Fundação técnica do Painel Administrador` (Feature #277). Não vem de caso de uso: não tem
  `spec.md`; a origem de cada item é um ADR ou a necessidade comum das specs CCD058–CCD066.
- **Repositórios:** backend (`develop`) · frontend (`develop`)
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Quem faz:** Daniel Andrade (backend e frontend)

## Solução

Prepara de uma vez o que as 9 stories do BackOffice usam em comum, para cada pessoa trabalhar só na sua pasta:
tabelas do DER (uma migration por tabela), seeds por domínio, o registro de auditoria com motivo, o upload de imagem,
os componentes repetidos nas telas do Figma e o menu do BackOffice com os 9 módulos.

## Dados

Uma migration por tabela, copiada do DBML, na ordem das FKs. Ficam de fora as tabelas do login (CCD004/CCD006).

| Tabela | Usada por |
|---|---|
| `categories`, `rarities`, `languages`, `albums`, `cards`, `card_photos` | CCD058, CCD061, CCD064, CCD066 |
| `catalog_requests` | CCD064 |
| `groups`, `group_members`, `group_messages`, `reports` | CCD058, CCD062 |
| `global_notifications`, `notifications` | CCD060 |
| `audit_logs` | CCD059–CCD066 (ADR-034) |
| `global_settings` | CCD066 |

- `reports.listing_id` e `group_messages.listing_id` ficam sem FK até a tabela `listings` existir (marketplace); a
  migration de `listings` acrescenta as FKs.

## Contrato da API

### `POST /api/v1/uploads` — ADR-009

- **Acesso:** `authenticate` + `authorize('ADMIN')`
- **Entrada:** `multipart/form-data` com `file` (PNG, JPG ou WEBP, até 4 MB) e `folder` (`cards`, `albums`, `banners`)
- **Sucesso:** `201` `{ "data": { "url": "string", "key": "string" } }`
- **Erros:** `400 VALIDATION_ERROR` (tipo, `folder` ou arquivo ausente) · `413 FILE_TOO_LARGE` (acima de 4 MB, ADR-050) · `401` · `403`

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Origem |
|---|---|---|
| `database/schema.prisma` + 15 migrations | tabelas acima | DBML; `.claude/rules/modelagem-de-dados.md` |
| `database/seeds/index.ts` + `seeds/<dominio>.seed.ts` | admin com senha, usuários, catálogo, grupos com mensagens e denúncias, solicitações, configurações; `npm run db:seed` | telas precisam de dados |
| `src/domains/admin/audit-logs/audit-logs.service.ts` (+ repository e module) | `record({ adminId, action, entityType, entityId, reason, details })`; exportado para os outros domínios; motivo obrigatório nas ações de suspender, reativar, excluir, remover mensagem, dispensar denúncia e recusar solicitação (ADR-051, item 5) | ADR-034; tela de Logs ("motivo obrigatório") |
| `src/shared/validators/reason.ts` | schema Zod do motivo (3 a 500 caracteres) reaproveitado nas ações | idem |
| `src/providers/storage/` (`storage.provider.ts`, `local.storage-provider.ts`, `storage.factory.ts`, `local-uploads.static.ts`) + `src/domains/uploads/` | upload local em dev (MinIO/S3 depois), escolhido por `STORAGE_DRIVER`; arquivos locais servidos em `/uploads`; URL montada com `API_PUBLIC_URL` (obrigatória em produção) | ADR-009 |
| `src/domains/admin/{dashboard,reports,settings}/` | pastas vazias com o `.module.ts` registrado em `src/routes.ts` | ADR-004; evita conflito no `routes.ts` |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Origem |
|---|---|---|
| `src/components/Modal/`, `ConfirmDialog/` (motivo obrigatório com `requireReason`; `confirmationText` para confirmar digitando um texto, CCD059), `Drawer/` | modais e painel lateral do Figma; `Modal` e `Drawer` usam a base `OverlayDialog/` e o hook `hooks/useOverlay.ts` (Esc, Tab preso no diálogo do topo, foco devolvido, rolagem travada) | telas Usuários, Comunidades, Solicitações |
| `src/components/FormField/` · `src/lib/reason.ts` | rótulo, dica e erro comuns aos campos; motivo de 3 a 500 caracteres, igual ao backend | ADR-042 |
| `src/components/Select/`, `Textarea/`, `Checkbox/`, `Tabs/`, `Badge/`, `KpiCard/`, `DataTable/`, `Toast/`, `FileUpload/`, `PeriodFilter/` | componentes repetidos; o `DataTable` não pagina (usa o `Pagination` que já existe) e o `Toast` é controlado pela página | telas do BackOffice |
| `src/styles/tokens.css` | tokens que faltam do Figma (cores de status, sombras, tamanhos, camadas) | ADR-044 |
| `src/app/layouts/AdminLayout/` · `routes/paths.ts` · `app/router.tsx` | menu "Módulos oficiais" com Dashboard, Usuários, Notificação, Catálogo, Comunidades, Relatórios, Solicitações, Logs e Configurações; uma rota por módulo com página provisória (`components/UnderConstructionPage/`); o ADMIN entra pelo Dashboard | Figma (sidebar) |
| `src/features/admin/{dashboard,reports,audit-logs,settings}/` · `features/notifications/` · `features/catalog/` (e `catalog/requests/`) · `features/community/` | `index.ts` e rotas provisórias na feature de cada story (CCD058–CCD066); cada story troca só a sua rota | ADR-040; planos CCD058–CCD066 |

## Testes

- Cada componente com `.spec.tsx` (render, papel e interação).
- `audit-logs.service.spec.ts`: grava com motivo e recusa sem `adminId`.
- `uploads` com teste de integração (tipo e tamanho).

## Decisões técnicas

- As stories do admin não criam tabela: se precisarem de coluna nova, a migration é da própria story, com aviso no
  grupo.
- Cada story só acrescenta uma linha no `routes.ts`, no `router.tsx` e no menu.
- As tabelas nascem só com as colunas do MVP. As colunas marcadas no DBML como escopo adicional (CCD094–CCD107) entram com a story que as usa, numa migration própria (ADR-053, item 10).
