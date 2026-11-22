# Tarefas — CCD048 Editar Dados do Perfil

- **Plano:** [plano.md](plano.md) · **User story:** AB#1242
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Os `AB#` das Tasks ficam "a criar": só com o pedido do Daniel.

## Backend — `apps/cromocard-backend`, branch `feature/1242-editar-dados-do-perfil`

- [ ] **T1** · Criar migration create_profiles_table e o seed do perfil e dos endereços — R3, R4, R9, R11 · AB#1243
  - Pronto quando: a tabela existe como no DBML e o seed tem a bio, a foto e os dois endereços de Gabriel.
- [ ] **T2** · Ampliar GET e PATCH /users/me com @, celular e bio — R1, R3–R7 · CA1–CA3, CA12 · AB#1244
  - Pronto quando: `users.service.spec.ts` e `users-profile.spec.ts` cobrem CA1–CA3 e o `401`.
- [ ] **T3** · Criar endpoint POST /users/me/avatar — R9, R10 · CA5 · AB#1245
  - Pronto quando: `users-profile.spec.ts` grava o JPG de 2 MB e recusa o GIF (`400`) e o de 6 MB (`413`).
- [ ] **T4** · Criar validator, erros, repository e service de endereços — R1, R11–R16 · CA6, CA9–CA11 · AB#1246
  - Pronto quando: `addresses.service.spec.ts` cobre o principal único em transação, a remoção do secundário e o `409` do principal.
- [ ] **T5** · Criar endpoints de endereços em /users/me/addresses — R1, R11–R16 · CA6–CA12 · AB#1247
  - Pronto quando: as 5 rotas aparecem no `/docs` e `users-addresses.spec.ts` cobre CA6–CA12.

## Frontend — `apps/cromocard-frontend`, branch `feature/1242-editar-dados-do-perfil`

- [ ] **T6** [P] · Criar types, schemas, labels, api e queries do perfil e dos endereços — R4, R5, R7, R9, R11–R15 · AB#1248
  - Pronto quando: o typecheck passa e `users.schemas.spec.ts` cobre nome vazio, @ fora da regra, bio > 300 e endereço sem número.
- [ ] **T7** · Criar cartão do usuário e formulário Informações pessoais — R3–R8 · CA1–CA4, CA13–CA15 · AB#1249
  - Pronto quando: `PersonalInfoForm.spec.tsx` cobre CA1–CA4; print em 1280 px igual aos frames `1160-37708`, `1160-38269` e `1160-38711` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Criar modal Alterar Foto do Perfil — R9, R10 · CA5, CA16 · AB#1250
  - Pronto quando: `AvatarUploadDialog.spec.tsx` cobre o envio e o arquivo recusado; print em 1280 px igual ao frame `1160-39158` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Criar lista e modais de endereços de entrega — R11–R16 · CA6–CA11, CA13, CA17–CA19 · AB#1251
  - Pronto quando: `AddressList.spec.tsx`, `AddressFormDialog.spec.tsx` e `RemoveAddressDialog.spec.tsx` cobrem CA6–CA11; print em 1280 px igual aos frames `1160-37708`, `1160-39672`, `1160-40220` e `1160-40789` e sem quebra em 375/768/1024 px.
- [ ] **T10** · Refazer a página Perfil com o topo e as seções — R2, R17 · CA13 · AB#1252
  - Pronto quando: `ProfilePage.spec.tsx` monta as seções com os estados de carregando e erro; print em 1280 px igual ao frame `1160-37708` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T11** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1253
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T4, T5 |
| R2 | T10 |
| R3 | T1, T2, T7 |
| R4 | T1, T2, T6, T7 |
| R5 | T2, T6, T7 |
| R6 | T2, T7 |
| R7 | T2, T6, T7 |
| R8 | T7 |
| R9 | T1, T3, T6, T8 |
| R10 | T3, T8 |
| R11 | T1, T4, T5, T6, T9 |
| R12–R16 | T4, T5, T6, T9 |
| R17 | T7, T8, T9, T10 |
