# Tarefas — CCD006 Recuperar Senha

- **Plano:** [plano.md](plano.md) · **User story:** AB#111
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/111-recuperar-senha`

- [x] **T1** · Criar migration create_password_reset_tokens_table — R11–R14 · AB#510
  - Pronto quando: a tabela existe e o `schema.prisma` bate com o DBML.
- [x] **T2** · Criar validator, errors e repository dos tokens de redefinição — R5, R6, R11–R14, R19, R22 · AB#511
  - Pronto quando: o repository guarda só o hash, invalida pendentes e acha token válido.
- [x] **T3** · Criar service de pedido e redefinição de senha — R7–R10, R20–R22 · CA1, CA2, CA5–CA7 · AB#512
  - Pronto quando: `auth.service.spec.ts` cobre os critérios, inclusive revogar sessões e não enviar para conta suspensa.
- [x] **T4** · Criar rotas forgot e reset com rate limit, e-mails e swagger — R8, R15–R17, R25 · CA3, CA4 · AB#513
  - Pronto quando: as rotas respondem como no contrato e os dois e-mails saem no Ethereal.
- [x] **T5** · Incluir os tokens de redefinição no job de limpeza — R23 · CA8 · AB#514
  - Pronto quando: o job apaga também os tokens de redefinição expirados.
- [x] **T6** · Criar testes de integração da recuperação — CA1–CA7 · AB#515
  - Pronto quando: `npm run test:integration` passa.

## Frontend — `apps/cromocard-frontend`, branch `feature/111-recuperar-senha`

- [x] **T7** [P] · Criar tela Esqueci minha senha — R2–R9, R26 · CA2, CA3, CA10 · AB#516
  - Pronto quando: a tela mostra a confirmação genérica e os erros, no estilo da tela de Login.
- [x] **T8** · Criar tela Redefinir senha — R18–R22, R26 · CA5–CA7, CA10 · AB#517
  - Pronto quando: o sucesso leva ao login com "Senha alterada" e o link inválido oferece novo pedido.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#518
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T7 (o link fica na tela da CCD004) |
| R2–R10 | T3, T7 |
| R11–R14 | T1, T2 |
| R15–R17 | T4 |
| R18–R22 | T2, T3, T8 |
| R23 | T5 |
| R24 | T4 (redaction da CCD004) |
| R25 | T4 |
| R26 | T7, T8 |
