# Tarefas — CCD051 Configurar Privacidade e Senha

- **Plano:** [plano.md](plano.md) · **User story:** AB# a criar (não encontrada no board)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- As branches dos apps saem de `develop` depois do merge da CCD048 (tabela `profiles`).
- Os `AB#` das Tasks ficam "a criar": só com o pedido do Daniel.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-configurar-privacidade-e-senha`

- [ ] **T1** · Criar service e endpoint PATCH /users/me/privacy com o helper de visibilidade — R1, R3–R5, R12 · CA1, CA2, CA7 · AB# a criar
  - Pronto quando: `users.service.spec.ts` cobre CA1 e CA2 e `users-privacy.spec.ts` cobre CA1 e o `401`.
- [ ] **T2** · Criar validator e erros da troca de senha — R7, R8, R10, R11 · CA5 · AB# a criar
  - Pronto quando: `auth.validator.spec.ts` recusa "abc12345" e a confirmação diferente.
- [ ] **T3** · Criar service de troca de senha — R7–R10 · CA3, CA4 · AB# a criar
  - Pronto quando: `auth.service.spec.ts` cobre CA3, CA4 e a conta só Google.
- [ ] **T4** · Criar endpoint POST /auth/password/change e o redaction das senhas no log — R1, R6, R13 · CA3–CA5, CA7, CA8 · AB# a criar
  - Pronto quando: a rota aparece no `/docs` e `auth-password.spec.ts` cobre CA3–CA5, CA7 e CA8 (login só com a nova e log sem senha nem hash).

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-configurar-privacidade-e-senha`

- [ ] **T5** [P] · Criar types, schemas, labels, api e queries de privacidade e senha — R3, R4, R6, R8, R9, R11 · AB# a criar
  - Pronto quando: o typecheck passa e `users.schemas.spec.ts` cobre a regra da nova senha e a confirmação.
- [ ] **T6** · Criar componente Switch — R3 · AB# a criar
  - Pronto quando: `Switch.spec.tsx` cobre ligar, desligar e o teclado.
- [ ] **T7** · Criar bloco Privacidade com a chave Coleção pública — R3, R4, R12 · CA1 · AB# a criar
  - Pronto quando: `PrivacySection.spec.tsx` cobre gravar, confirmar e manter o valor no erro; print em 1280 px igual ao bloco "Privacidade" do frame `1160-41305` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Criar modal Alterar senha — R6, R8–R12 · CA3–CA6, CA10–CA12 · AB# a criar
  - Pronto quando: `ChangePasswordDialog.spec.tsx` cobre CA3–CA6; print em 1280 px igual aos frames `1160-41859`, `1160-42338` e `1160-42817` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Criar página Configurações com Conta e segurança na rota /configuracoes — R1, R2, R6 · CA9 · AB# a criar
  - Pronto quando: `SettingsPage.spec.tsx` monta os blocos com carregando e erro; print em 1280 px igual ao frame `1160-41305` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T10** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T4, T9 |
| R2 | T9 |
| R3 | T1, T5, T6, T7 |
| R4 | T1, T5, T7 |
| R5 | T1 |
| R6 | T4, T5, T8, T9 |
| R7 | T2, T3 |
| R8 | T2, T3, T5, T8 |
| R9 | T3, T5, T8 |
| R10 | T2, T3, T8 |
| R11 | T2, T5, T8 |
| R12 | T1, T7, T8 |
| R13 | T4 |
| R14 | T7, T8, T9 |
