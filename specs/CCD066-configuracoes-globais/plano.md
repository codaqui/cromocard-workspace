# Plano — CCD066 Configurações Globais

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

`global_settings` guarda cada configuração como JSON validado por chave (`home.banner`, `notification.templates`).
As categorias padrão mudam `categories.is_default` pelo `catalogService`. Cada alteração grava `updated_by_id` e
`audit_logs`. O banner tem uma leitura pública para a Home.

## Dependências

- Fundação (`global_settings`, seed das chaves, `/uploads`, `AuditLogService`, `FileUpload`, `Checkbox`).
- CCD061 (`catalogService` para `is_default`).

## Contrato da API

| Método e caminho | Acesso | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|---|
| `GET /api/v1/admin/settings` | ADMIN | — | `200` `{ data: [{ key, value, description, updatedAt, updatedBy }] }` | — | R3 |
| `PATCH /api/v1/admin/settings/:key` | ADMIN | `{ value }` (schema da chave) | `200` | `400`, `404 SETTING_NOT_FOUND` | R4–R7, R14 |
| `PATCH /api/v1/admin/settings/default-categories` | ADMIN | `{ categoryIds: [] }` | `200` | `400`, `404 CATEGORY_NOT_FOUND` | R10, R13 |
| `GET /api/v1/settings/public/:key` | público (só `home.banner`) | — | `200` | `404` | R15 |

Schema de `home.banner`: `{ enabled: boolean, title: 1–80, subtitle: 0–200, ctaText: 1–30, ctaUrl: URL, imageUrl: URL }`.
Schema de `notification.templates`: lista de `{ name: 1–60, title: 1–120, content: 1–500 }`.

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/admin/settings/settings.validator.ts` · `setting-schemas.ts` | schema por chave | R4, R7 |
| `settings.repository.ts` | ler e atualizar com `updated_by_id` | R3, R5 |
| `settings.service.ts` + `.spec.ts` | validar, salvar, auditar, categorias padrão via `catalogService` | R4–R7, R10, R13, R14 |
| `settings.controller.ts` · `.routes.ts` · `.swagger.ts` | rotas de admin, no módulo que a fundação já montou em `/admin/settings` (ADMIN) | R1 |
| `settings-public.routes.ts` + `settings-public.module.ts` · `src/routes.ts` | rota pública `GET /settings/public/:key` num módulo próprio, sem `authenticate`, registrado com uma linha no `routes.ts` (o módulo da fundação exige ADMIN em todas as rotas) | R15 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/settings/` (api, queries, schemas) | chamadas e schemas | R4, R7 |
| `pages/SettingsPage/` | módulos Banner, Categorias padrão e Templates, com "Salvar" e `ConfirmDialog` | R2–R11 |
| `components/BannerForm/` | campos, upload e pré-visualização | R9, R12 |
| `components/DefaultCategoriesForm/` · `NotificationTemplatesForm/` | marcar categorias; lista de modelos | R10, R11 |

## Testes

| Critério | Onde |
|---|---|
| CA2–CA4 | `settings.service.spec.ts` · integração |
| CA1, CA5 | `SettingsPage.spec.tsx` |
| CA6 | integração |
