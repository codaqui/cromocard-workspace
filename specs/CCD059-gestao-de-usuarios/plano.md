# Plano — CCD059 Gestão de Usuários

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

Estende o domínio `users` (que já tem `GET /users` para ADMIN) com detalhe, criação com convite, edição, troca de
papel, suspensão, reativação e exclusão. As ações sensíveis pedem motivo, revogam sessões pelo `authService` e
gravam `audit_logs`. A tela existente `UsersListPage` ganha filtros, ações e os modais.

## Dependências

- Fundação (`AuditLogService`, `ConfirmDialog` com motivo, `Modal`, `Select`, `Badge`).
- CCD004 (`authService.revokeAllSessions`) e CCD006 (token de definir senha para o convite).

## Contrato da API

Todas com `authenticate` + `authorize('ADMIN')`.

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/users` | `q`, `role`, `status`, `page`, `pageSize`, `sort` | `200` `{ data, meta }` | `400` | R3, R16 |
| `GET /api/v1/users/:id` | — | `200` | `404 USER_NOT_FOUND` | R4 |
| `POST /api/v1/users` | `{ name, email, role }` | `201` + e-mail de convite | `400`, `409 EMAIL_ALREADY_REGISTERED` | R5, R10, R17 |
| `PATCH /api/v1/users/:id` | `{ name?, email?, role? }` | `200` | `400`, `404`, `409`, `422 CANNOT_CHANGE_OWN_ROLE`, `422 LAST_ADMIN` | R6, R7, R18 |
| `POST /api/v1/users/:id/suspend` | `{ reason }` | `200` | `404`, `409 ALREADY_SUSPENDED`, `422 CANNOT_SUSPEND_SELF`, `422 LAST_ADMIN` | R8, R14, R18, R19 |
| `POST /api/v1/users/:id/reactivate` | `{ reason }` | `200` | `404`, `409 NOT_SUSPENDED` | R8 |
| `DELETE /api/v1/users/:id` | `{ reason }` | `204` | `404`, `422 CANNOT_DELETE_SELF`, `422 LAST_ADMIN` | R9, R14 |

**Decisão tomada na implementação (T7/T8), revista na revisão do PR do frontend (08/11, @Danixzy):** a primeira
versão não chamava o `GET /api/v1/users/:id` — o modal de editar usava os dados que a própria linha da lista já
tinha. O Daniel apontou que isso não atende o R4 nem os passos 3 e 4 do CCD059 ("seleciona um usuário e vê os
dados e as opções"): clicar na linha abria direto o editar, sem uma tela só de visualização. A partir da T10,
o clique na linha (e um botão "Visualizar" na linha, acessível por teclado) leva para `/backoffice/users/:id`
(`UserDetailPage`), que chama o `GET /api/v1/users/:id` e mostra nome, e-mail, papel, status e data de cadastro,
com as ações editar, suspender/reativar e excluir reaproveitando os mesmos modais/diálogos da lista. O lápis na
lista continua abrindo o editar direto, sem passar pela tela de visualização. O `PATCH /api/v1/users/:id`
continua recebendo o corpo completo do formulário (sem mudança nisso).

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/users/users.validator.ts` · `users.errors.ts` | schemas de admin e erros acima; busca passa a `q` (ADR-011) | R5–R11 |
| `users.repository.ts` | filtros, detalhe, criar, atualizar, mudar status, soft delete | R3–R9 |
| `admin-users.service.ts` + `.spec.ts` | regras de admin, convite, revogação e auditoria | R5–R10, R14, R17–R19 |
| `users.routes.ts` · `users.controller.ts` · `users.swagger.ts` · `users.module.ts` | rotas novas | R1 |
| `tests/integration/admin-users.spec.ts` | fluxo completo | CA1–CA9 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/users/users.api.ts` · `.queries.ts` · `.schemas.ts` · `.labels.ts` | chamadas, schemas e `useUser(id)` (`GET /:id`) | R4–R9 |
| `pages/UsersListPage/` · `components/UsersTable/` | filtros, ações por linha (visualizar, editar, suspender/reativar, excluir), `Badge` de status e papel | R2, R3 |
| `pages/UserDetailPage/` (`/backoffice/users/:id`) | tela de visualização com dados e ações, reaproveita os modais/diálogos da lista | R4 |
| `components/UserFormModal/` + `hooks/useUserForm.ts` | criar e editar (nome, e-mail, papel) | R5–R7, R11–R13 |
| `components/SuspendUserDialog/` · `DeleteUserDialog/` | `ConfirmDialog` com motivo; exclusão pede digitar o nome | R8, R9, R14 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA7 | `admin-users.service.spec.ts` · integração |
| CA2, CA6, CA8 | `UserFormModal.spec.tsx` · `DeleteUserDialog.spec.tsx` |
| CA9 | integração |
