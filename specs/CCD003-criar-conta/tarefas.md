# Tarefas — CCD003 Criar Conta

- **Plano:** [plano.md](plano.md) · **User story:** AB#108
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/108-criar-conta`

- [x] **T1** · Criar provider de e-mail (interface MailProvider, Nodemailer e Ethereal em dev) — R30, R31 · AB#500
  - Pronto quando: o envio em dev mostra o link do Ethereal no log e o provider é injetado por interface.
- [x] **T2** · Criar token de confirmação de e-mail (JWT com purpose) e variáveis FRONTEND_URL e EMAIL_VERIFICATION_TTL — R32 · ADR-048 · AB#501
  - Pronto quando: o teste gera, valida e recusa token expirado ou de outro `purpose`.
- [x] **T3** · Criar validator e errors do cadastro (regra de senha, e-mail normalizado, tipos permitidos) — R4–R11, R13, R14 · AB#502
  - Pronto quando: o schema recusa senha fraca, `role` ADMIN e termos não aceitos.
- [x] **T4** · Criar service de cadastro, confirmação e reenvio — R12–R24, R28–R33 · CA1, CA5–CA10 · AB#503
  - Pronto quando: `auth.service.spec.ts` cobre os critérios com repository e mail falsos.
- [x] **T5** · Criar rotas register, verify-email e resend com rate limit e swagger — R1, R23 · CA3 · AB#504
  - Pronto quando: as rotas aparecem no `/docs` e respondem como no contrato.
- [x] **T6** · Criar testes de integração do cadastro — CA1–CA10 · AB#505
  - Pronto quando: `npm run test:integration` passa.

## Frontend — `apps/cromocard-frontend`, branch `feature/108-criar-conta`

- [x] **T7** [P] · Criar schema, labels e api do cadastro — R4–R8, R18, R32, R33 · AB#506
  - Pronto quando: o schema espelha o validator e o typecheck passa.
- [x] **T8** · Criar formulário de cadastro na aba Criar Conta — R3–R9, R16, R27 · CA1, CA3, CA4, CA7, CA11 · AB#507
  - Pronto quando: `RegisterForm.spec.tsx` cobre envio, erros por campo, termos e carregando.
- [x] **T9** · Criar telas Confirme seu e-mail e Confirmar e-mail — R24, R32, R33 · CA2, CA8, CA9 · AB#508
  - Pronto quando: o link válido leva ao login com "E-mail confirmado" e o inválido oferece reenvio.

## Fechamento — workspace

- [ ] **T10** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#509
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T5, T9 |
| R2, R3 | T8 |
| R4–R11 | T3, T7, T8 |
| R12–R14 | T3, T4 |
| R15, R16 | T8 |
| R17 | T3 |
| R18–R24 | T4, T5 |
| R25 | T9 (destino decidido: tela "Confirme seu e-mail", depois login) |
| R26 | T5 |
| R27 | T8 |
| R28–R31 | T1, T4 |
| R32 | T2, T4, T9 |
| R33 | T4, T9 |
| R34 | T1 (redaction da CCD004) |
