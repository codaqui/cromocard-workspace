# Plano — CCD006 Recuperar Senha

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Repositórios:** backend (`develop`) · frontend (`develop`)
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

`/esqueci-senha` envia o e-mail para `POST /api/v1/auth/password/forgot`, que responde sempre `202` e, se a conta
estiver ativa, grava o SHA-256 de um token aleatório em `password_reset_tokens` (1 hora) e manda o link. O link abre
`/redefinir-senha?token=`, que envia a senha nova para `POST /api/v1/auth/password/reset`: troca o hash, marca o token
como usado, revoga todos os refresh tokens, confirma o e-mail e avisa por e-mail.

## Dependências

- CCD004 (`refresh_tokens`, `lib/password.ts`, job de limpeza) e CCD003 (`MailProvider`, regra de senha).
- ADR-048, item 2.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `password_reset_tokens` | não | `create_password_reset_tokens_table` | copiada do DBML; `token` guarda o hash |
| `refresh_tokens` | CCD004 | — | revogar todas as sessões |

## Contrato da API

### `POST /api/v1/auth/password/forgot` — R2–R17

- **Acesso:** público, rate limit 3 por 15 min por IP + e-mail
- **Entrada:** `{ "email": "string" }`
- **Sucesso:** `202` sem corpo, igual para e-mail existente ou não; o e-mail sai fora do ciclo da requisição
- **Erros:** `400 VALIDATION_ERROR` (R6) · `429 TOO_MANY_REQUESTS` (R16)

### `POST /api/v1/auth/password/reset` — R18–R22

- **Acesso:** público, rate limit 10 por 15 min por IP
- **Entrada:** `{ "token": "string", "password": "string" }`
- **Sucesso:** `204`
- **Erros:** `400 VALIDATION_ERROR` (senha fora da regra) · `400 INVALID_RESET_TOKEN` (inexistente, usado ou expirado)

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration | `PasswordResetToken` | R11–R14 |
| `src/config/env.ts` | `PASSWORD_RESET_TTL` | R13 |
| `auth.validator.ts` · `auth.errors.ts` | schemas e `INVALID_RESET_TOKEN` | R5, R6, R19 |
| `auth.repository.ts` | criar token, invalidar pendentes, achar por hash válido, marcar usado | R11–R14, R19, R22 |
| `auth.service.ts` + `.spec.ts` | `forgotPassword` (sem enviar para suspensa/excluída), `resetPassword` (hash, revoga sessões, confirma e-mail, aviso) | R7–R10, R20–R22 |
| `providers/mail/templates/` | e-mails "redefinir senha" e "senha alterada" | R8 |
| `auth.routes.ts` · `auth.swagger.ts` | 2 rotas e rate limits | R16, R17, R25 |
| `src/jobs/cleanup-expired-tokens.job.ts` | apagar também `password_reset_tokens` expirados | R23 |
| `tests/integration/auth-password.spec.ts` | pedido e redefinição | CA1–CA7 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `auth.schemas.ts` · `auth.api.ts` | schemas e chamadas | R5, R20 |
| `pages/ForgotPasswordPage/` + `components/ForgotPasswordForm/` | campo e-mail e confirmação genérica | R2–R9, R26 |
| `pages/ResetPasswordPage/` + `components/ResetPasswordForm/` | senha nova e confirmação; link inválido oferece novo pedido; sucesso vai ao login com "Senha alterada" | R18–R22, R26 |
| `routes/paths.ts` · `app/router.tsx` | `/esqueci-senha`, `/redefinir-senha` | R17 |

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1, CA2 | token com hash e resposta igual | `auth.service.spec.ts` · integração |
| CA3, CA4 | `400` e `429` | integração · `ForgotPasswordForm.spec.tsx` |
| CA5–CA7 | redefinição, link inválido e senha fraca | `auth.service.spec.ts` · `ResetPasswordForm.spec.tsx` |
| CA8 | job | `cleanup-expired-tokens.job.spec.ts` |
| CA9 | redaction | `logger.spec.ts` |
| CA10 | carregando | specs dos formulários |
