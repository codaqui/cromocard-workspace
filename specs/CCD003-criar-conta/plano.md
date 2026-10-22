# Plano — CCD003 Criar Conta

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Repositórios:** backend (`develop`) · frontend (`develop`)
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

A aba Criar Conta da página `/cadastro` envia os dados para `POST /api/v1/auth/register`. A service grava o usuário
com a senha em argon2id, `email_verified = false` e `terms_accepted = true`, e manda o link de confirmação (JWT de
24h, ADR-048) pelo `MailProvider`. O link abre `/confirmar-email?token=`, que chama `POST /api/v1/auth/verify-email`.
O reenvio é `POST /api/v1/auth/verify-email/resend`.

## Dependências

- CCD004 (T3 `lib/password.ts`, T13 página de abas e `AuthLayout`). Se a CCD004 não tiver entrado, esta story cria a
  lib de senha e a CCD004 reaproveita.
- ADR-048, item 1.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `users` | sim | — | grava `name`, `email` normalizado, `password_hash`, `role`, `terms_accepted`, `email_verified` |

## Contrato da API

### `POST /api/v1/auth/register` — R3–R24, R28–R31

- **Acesso:** público, rate limit 10/h por IP
- **Entrada:** `{ "name": "string", "email": "string", "password": "string", "role": "CUSTOMER" | "SELLER", "termsAccepted": true }`
- **Sucesso:** `201` `{ "data": { "id": "uuid", "name": "string", "email": "string", "role": "CUSTOMER", "emailVerified": false } }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | campo inválido, senha fora da regra, `role` fora de CUSTOMER/SELLER, termos não aceitos | R10, R11, L1, L2 |
  | 409 | `EMAIL_ALREADY_REGISTERED` | e-mail já cadastrado (`details.emailVerified` diz se pode reenviar) | R13, L6 |
  | 409 | `ACCOUNT_DELETED` | e-mail de conta excluída | R14 |

### `POST /api/v1/auth/verify-email` — R32

- **Entrada:** `{ "token": "string" }` · **Sucesso:** `204` · **Erros:** `400 INVALID_VERIFICATION_TOKEN` (expirado ou inválido)

### `POST /api/v1/auth/verify-email/resend` — R33

- **Entrada:** `{ "email": "string" }` · rate limit 3 por 15 min por IP + e-mail
- **Sucesso:** `202` sempre igual, exista ou não o e-mail (só envia se a conta existir e não estiver confirmada)

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/providers/mail/mail.provider.ts` · `nodemailer.mail-provider.ts` · `templates/` | interface `MailProvider` e implementação (Ethereal em dev, SMTP em produção) | R30, R31 |
| `src/config/env.ts` · `.env.example` | `MAIL_*`, `FRONTEND_URL`, `EMAIL_VERIFICATION_TTL` | R31 |
| `src/lib/jwt.ts` | `signPurposeToken`/`verifyPurposeToken` (`purpose: verify-email`) | R32, ADR-048 |
| `auth.validator.ts` · `auth.errors.ts` | schemas de cadastro (regra de senha, e-mail normalizado) e erros acima | R4–R11, R13, R14 |
| `auth.service.ts` + `.spec.ts` | `register`, `verifyEmail`, `resendVerification`; falha no e-mail não derruba o cadastro | R12–R24, R28–R33 |
| `domains/users/users.service.ts` | `createWithPassword` e `markEmailVerified`, usados pelo auth (sem importar repository) | R18 |
| `auth.controller.ts` · `auth.routes.ts` · `auth.swagger.ts` | 3 rotas e rate limits | R1, R23 |
| `tests/integration/auth-register.spec.ts` | cadastro, conflito, confirmação e reenvio | CA1–CA10 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `auth.schemas.ts` · `auth.labels.ts` | schema do cadastro (espelha o validator), rótulos Cliente/Vendedor | R4–R8 |
| `auth.api.ts` | `register`, `verifyEmail`, `resendVerification` | R18, R32, R33 |
| `components/RegisterForm/` + `hooks/useRegisterForm.ts` | nome, e-mail, tipo, senha com medidor, confirmar senha, aceite dos termos | R3–R9, R16, R27 |
| `pages/CheckEmailPage/` | "Confirme seu e-mail" com reenviar | R24, R33 |
| `pages/VerifyEmailPage/` | `/confirmar-email`: confirma e vai ao login com "E-mail confirmado"; link inválido oferece reenvio | R32 |
| `routes/paths.ts` · `app/router.tsx` | `/confirmar-email`, `/confirme-seu-email` | R1 |

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1, CA2 | grava com hash, flags certos, envia o e-mail e mostra a tela de confirmação | `auth.service.spec.ts` · integração · `RegisterForm.spec.tsx` |
| CA3, CA4, CA7 | `400` por campo, termos e `role` | `auth.service.spec.ts` · `RegisterForm.spec.tsx` |
| CA5, CA6 | `409` e conta excluída | integração |
| CA8, CA9 | confirmar e link inválido | `auth.service.spec.ts` · `VerifyEmailPage.spec.tsx` |
| CA10 | reenvio com limite | integração |
| CA11 | botão carregando | `RegisterForm.spec.tsx` |
| CA12 | redaction | `logger.spec.ts` (da CCD004) |

## Decisões técnicas

- E-mail sai sem `await` no request (registrado no log se falhar), para a resposta não depender do SMTP.
- O texto dos termos não existe: o aceite mostra os rótulos do Figma, sem link, até haver as páginas.
