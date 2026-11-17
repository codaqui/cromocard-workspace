# Plano — CCD066 Configurações Globais

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22, reaprovada em 2026-11-12 e de novo em 2026-11-15 (L9–L19)
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade · revisado em 2026-11-15 por Gabriel Nascimento

## Solução

`global_settings` guarda cada configuração como JSON validado por um schema Zod por chave (ADR-051, item 1). Os
módulos gravam assim:

| Módulo | Chaves | Rota |
|---|---|---|
| 1. Banner da Home | `home.banner` | `PATCH /admin/settings/home.banner` |
| 2. Categorias padrão | `categories.is_default` + `catalog.default_backs` | `PATCH /admin/settings/default-categories`, numa transação |
| 3. Templates de notificação | `notification.templates` | `PATCH /admin/settings/notification.templates` a cada salvar ou excluir |
| 4. Metas | `dashboard.monthly_signup_goal` + `catalog.voting_goal` | `PATCH /admin/settings/goals`, numa transação |

Toda gravação registra `updated_by_id` e `audit_logs` com o antes e o depois, dentro da mesma transação. As categorias
padrão ficam num serviço próprio do domínio do catálogo (`DefaultCategoriesService`), exportado pelo `catalog.module.ts`:
o domínio de configurações não lê o repository de outro domínio. O banner tem uma leitura pública para a Home.

## Dependências

- Fundação: `global_settings` e o seed, `/uploads` (`StorageProvider`), `AuditLogService` com `SETTING_UPDATED` e
  `DEFAULT_CATEGORIES_UPDATED` já na lista de ações, `runInTransaction`.
- CCD061: `categories` e o CRUD de categorias.

## Contrato da API

| Método e caminho | Acesso | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|---|
| `GET /api/v1/admin/settings` | ADMIN | — | `200` `{ data: [{ key, value, description, updatedAt, updatedBy: { id, name } \| null }] }` | `401`, `403` | R1, R3 |
| `PATCH /api/v1/admin/settings/:key` | ADMIN | `{ value }` com o schema da chave; só `home.banner` e `notification.templates` | `200` `{ data: <configuração> }` | `400 VALIDATION_ERROR`, `404 SETTING_NOT_FOUND` | R4–R7, R9, R11, R12, R14, R19 |
| `GET /api/v1/admin/settings/default-categories` | ADMIN | — | `200` `{ data: [{ id, name, type, backImageUrl \| null }] }` | `401`, `403` | R3, R10, R13, R17 |
| `PATCH /api/v1/admin/settings/default-categories` | ADMIN | `{ categories: [{ id, backImageUrl \| null }] }` | `200` `{ data: [{ id, name, type, backImageUrl }] }` | `400`, `404 CATEGORY_NOT_FOUND`, `422 DEFAULT_CATEGORY_NOT_ROOT` | R10, R12–R14, R17 |
| `PATCH /api/v1/admin/settings/goals` | ADMIN | `{ monthlySignupGoal: inteiro ≥ 1 \| null, votingGoal: inteiro ≥ 1 }` | `200` `{ data: { monthlySignupGoal, votingGoal } }` | `400` | R14, R16 |
| `GET /api/v1/settings/public/:key` | público, só `home.banner` | — | `200` `{ data: <banner> }`, mesmo com `enabled: false` | `404 SETTING_NOT_FOUND` | R15 |

As rotas fixas (`default-categories` e `goals`) são registradas antes de `/:key`.

### Schemas por chave

| Chave | `value` |
|---|---|
| `home.banner` | `{ enabled: boolean, title: 1–80, subtitle: 0–200, ctaText: 1–30, ctaUrl: URL https, imageUrl: URL de imagem \| null }` |
| `notification.templates` | lista de até 50 `{ id: UUID (gerado pela API quando vem sem id), único, name: 1–60, único sem diferenciar maiúsculas, title: 1–120, content: 1–500 }`; `{campo}` é texto comum |
| `dashboard.monthly_signup_goal` | inteiro de 1 a 1.000.000 ou `null` |
| `catalog.voting_goal` | inteiro de 1 a 1.000.000 |
| `catalog.default_backs` | objeto `{ [categoryId]: URL de imagem }`, só com as categorias padrão que têm verso |

URL de imagem: `http` ou `https`, até 500 caracteres (recusa `javascript:` e `data:`, porque a Home pública exibe o
valor). Os textos são gravados sem espaços nas pontas. O `PATCH /default-categories` aceita até 50 categorias, sem
repetir.

### Auditoria

| Ação | `entity_type` · `entity_id` | `details` |
|---|---|---|
| `SETTING_UPDATED` | `SETTING` · id da configuração | `{ key, before, after }`, uma linha por gravação do banner ou dos templates |
| `SETTING_UPDATED` (metas) | `SETTING` · sem `entity_id`, porque vale para as duas chaves | `{ keys, before, after }`, com `before` e `after` indexados pela chave: uma linha só para as duas metas |
| `DEFAULT_CATEGORIES_UPDATED` | `SETTING` · id de `catalog.default_backs` | `{ before, after }` com as categorias e os versos |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/admin/settings/setting-schemas.ts` | schema de cada chave, a lista de chaves editáveis por `/:key` e a pública | R7, R11, R16, R17, R19 |
| `settings.validator.ts` | `{ value }` por chave, `default-categories`, `goals`, parâmetro `:key` (só schemas) | R4, R7, R10, R16 |
| `settings.errors.ts` | `SETTING_NOT_FOUND` | R15 |
| `settings.repository.ts` | ler as chaves e gravar `value` com `updated_by_id`, sempre dentro da transação | R3, R5 |
| `settings.store.ts` | ler uma chave e gravar o valor com o `audit_logs` (antes e depois) na mesma transação; `saveAll` grava várias chaves com um registro só | R5, R14 |
| `settings.service.ts` + `.spec.ts` | chaves editáveis por `/:key`, validar, gerar id dos templates, metas numa transação e leitura pública | R3–R7, R11, R14–R16 |
| `settings-default-categories.service.ts` + `.spec.ts` | listar e trocar as categorias padrão com os versos numa transação, pelo `DefaultCategoriesService` do catálogo | R10, R13, R14, R17 |
| `settings.controller.ts` · `settings.routes.ts` · `settings.swagger.ts` · `settings.module.ts` | rotas de admin no módulo que a fundação já montou em `/admin/settings` (ADMIN) | R1 |
| `settings.routes.ts` (`createPublicSettingsRoutes`) · `settings.module.ts` (`publicSettingsModule`) · `src/routes.ts` | rota pública `GET /settings/public/:key`, num segundo módulo sem `authenticate`, que reusa o controller | R15 |
| `src/domains/catalog/catalog-default-categories.repository.ts` · `catalog-default-categories.service.ts` + `.spec.ts` · `catalog.errors.ts` · `catalog.module.ts` | listar as padrão, validar (existe, não excluída, raiz) e trocar o conjunto `is_default` numa transação; `DEFAULT_CATEGORY_NOT_ROOT` | R10, R13 |
| `database/seeds/data/global-settings.json` · `admin.seed.ts` | chaves das metas e dos versos e o link `https` do banner | R18 |
| `tests/integration/admin-settings.spec.ts` | rotas de admin e pública com PostgreSQL | CA2–CA4, CA6–CA10 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/settings/` (`settings.types.ts`, `settings.schemas.ts`, `settings.api.ts`, `settings.queries.ts`) | tipos, schemas que espelham o `setting-schemas.ts` e o `settings.validator.ts`, chamadas das rotas do contrato e de `GET /admin/catalog/categories` (busca das franquias para adicionar) e `POST /uploads` | R4, R7, R12, R16, R20 |
| `hooks/use<Módulo>Form.ts` | um formulário por módulo (React Hook Form + Zod), com Cancelar voltando aos valores carregados e os erros da API nos campos | R4, R7, R8 |
| `pages/SettingsPage/` | cabeçalho e os quatro módulos, com carregando e erro; troca o `underConstructionRoute` | R2, R3, R6 |
| `components/BannerModule/` | "Exibir Banner na Home", pré-visualização, campos e upload WEBP/PNG até 4 MB na pasta `banners` | R9, R12, R20 |
| `components/DefaultCategoriesModule/` · `AddDefaultCategoryDialog/` | lista com nome, verso e remover; adicionar franquia (só raiz); "Trocar verso"/"Enviar verso" na pasta `cards`; botão "Salvar categorias" (L20, L22) | R10, R13, R17 |
| `components/NotificationTemplatesModule/` · `TemplateDialog/` | lista, "Novo template" e "Editar template" no mesmo modal com contadores 120/500, excluir com `ConfirmDialog` | R11, R19 |
| `components/GoalsModule/` | as duas metas, com a mensal vazia como "sem meta" | R16 |

A feature `settings` tem as próprias chamadas de `GET /admin/catalog/categories` e `POST /uploads`, sem importar a
feature `catalog` (CCD061), que só exporta as rotas no `index.ts`. Decisão de Gabriel Nascimento, 16/11/2026.

Avisos (L23): "Banner atualizado", "Categorias padrão atualizadas", "Templates atualizados" e "Metas atualizadas", no
`Toast`, com o mesmo formato do frame `859-1068`; erro sem campo vira aviso de erro no mesmo formato.

## Testes

| Critério | Onde |
|---|---|
| CA2–CA4, CA7, CA9, CA10 | `settings.service.spec.ts`, `settings-default-categories.service.spec.ts`, `catalog-default-categories.service.spec.ts` · integração |
| CA6, CA8 | integração |
| CA1–CA5, CA7, CA9–CA11 (tela) | `SettingsPage.spec.tsx` e o `.spec.tsx` de cada módulo |

## Decisões técnicas

As chaves das metas e dos versos (`dashboard.monthly_signup_goal`, `catalog.voting_goal` e `catalog.default_backs`)
estão no ADR-061 (Proposto), que substitui parcialmente o item 1 do ADR-051. O resto segue os ADRs existentes: o
formato das chaves o ADR-051, item 1, os verbos o ADR-011 e a auditoria o ADR-034 e o ADR-051, itens 4–5.
