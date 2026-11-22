# Tarefas — CCD043 Criar e Administrar Grupo

- **Plano:** [plano.md](plano.md) · **User story:** AB#146
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure: a criar (só com o pedido do Daniel). Sai depois da CCD039; T5 e T10 depois da CCD044.

## Backend — `apps/cromocard-backend`, branch `feature/146-criar-e-administrar-grupo`

- [ ] **T1** · Liberar o upload da capa do grupo para o cliente — R5 · AB# a criar
  - Pronto quando: `uploads.service.spec.ts` cobre `groups` aceito para `CUSTOMER` e `SELLER` e `403` nas outras pastas.
- [ ] **T2** · Criar endpoints de criar, editar e excluir grupo — R1, R3–R8, R12, R13 · CA1, CA2, CA7, CA8, CA10 · AB# a criar
  - Pronto quando: a integração cobre a criação com o `ADMIN`, o `400`, a edição, a exclusão e o `403` para `MEMBER`.
- [ ] **T3** · Criar aprovação e recusa das solicitações de entrada — R9, R15 · CA3, CA4, CA10 · AB# a criar
  - Pronto quando: `group-administration.service.spec.ts` cobre aprovar com linha restaurada, recusar e o `409`.
- [ ] **T4** · Criar listagem, promoção e remoção de membros — R10, R11, R15 · CA5, CA6, CA10 · AB# a criar
  - Pronto quando: os testes cobrem promover, remover e os `422` do criador e do último admin.
- [ ] **T5** · Criar endpoint PUT /groups/:id/messages/:messageId/pin — R14 · CA9, CA10 · AB# a criar
  - Pronto quando: a integração cobre fixar, desafixar, `404` e `403`.
- [ ] **T6** [P] · Ampliar o seed com membros e solicitações — R9, R15 · AB# a criar
  - Pronto quando: o grupo do frame `675-16465` tem solicitações pendentes e membros com as duas funções.

## Frontend — `apps/cromocard-frontend`, branch `feature/146-criar-e-administrar-grupo`

- [ ] **T7** [P] · Criar api, queries e schemas da administração do grupo — R3–R15 · AB# a criar
  - Pronto quando: o typecheck passa e `group-admin.api.spec.ts` cobre os endpoints.
- [ ] **T8** · Criar formulário Criar grupo e o cartão Crie seu grupo de graça — R2–R8, R16 · CA1, CA2, CA11, CA13 · AB# a criar
  - Pronto quando: `CreateGroupPage.spec.tsx` cobre CA1 e CA2; print em 1280 px igual aos frames `417-2581` e `417-2915`
    e sem quebra em 375/768/1024 px.
- [ ] **T9** · Criar página de administração do grupo com solicitações, membros, editar e excluir — R9–R13, R15, R16 · CA3–CA8, CA12 · AB# a criar
  - Pronto quando: `GroupAdminPage.spec.tsx` cobre aprovar, recusar, promover, remover, editar e excluir; print em 1280 px
    igual ao frame `675-16465` e sem quebra em 375/768/1024 px.
- [ ] **T10** · Acrescentar Fixar e Desafixar no menu da mensagem para o administrador — R14 · CA9 · AB# a criar
  - Pronto quando: `MessageBubble.spec.tsx` cobre as duas ações e o indicador do topo do chat atualiza.

## Fechamento — workspace

- [ ] **T11** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T3, T4, T5 |
| R2 | T8 |
| R3, R4, R6, R7, R8 | T2, T7, T8 |
| R5 | T1, T7, T8 |
| R9 | T3, T6, T7, T9 |
| R10, R11 | T4, T7, T9 |
| R12, R13 | T2, T7, T9 |
| R14 | T5, T7, T10 |
| R15 | T3, T4, T6, T9 |
| R16 | T8, T9 |
