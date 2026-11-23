# Tarefas — CCD010 Solicitar Álbum

- **Plano:** [plano.md](plano.md) · **User story:** AB#116
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.
  `feature/607-votar-em-solicitacao-de-catalogo`) e da CCD008.

## Backend — `apps/cromocard-backend`, branch `feature/116-solicitar-album`

- [ ] **T1** · Criar validator e erros da solicitação de álbum — R3, R4 · CA3 · AB#997
  - Pronto quando: o schema recusa título, editora, ano ou franquia vazios com `400 VALIDATION_ERROR` e `details` por
    campo (depende da L4).
- [ ] **T2** · Criar service e repository da solicitação de álbum do cliente — R3, R5, R6 · CA1, CA2 · AB#998
  - Pronto quando: `customer-catalog-requests.service.spec.ts` cobre CA1 e CA2, franquia e idioma inexistentes (`404`) e
    as opções (franquias na ordem da CCD104, editoras distintas).
- [ ] **T3** · Criar endpoints POST /catalog-requests, GET /catalog-requests/me e /album-options — R1, R5, R6 · CA1–CA4 · AB#999
  - Pronto quando: as rotas aparecem no `/docs` e `tests/integration/catalog-requests-customer.spec.ts` cobre CA1–CA4,
    com a solicitação na fila `GET /admin/catalog-requests?type=ALBUM`.
- [ ] **T4** · Liberar o upload de imagem para cliente e vendedor — R3 · AB#1000
  - Pronto quando: o `POST /uploads` aceita `CUSTOMER` e `SELLER` e o teste de integração do upload cobre os três papéis
    (depende da L6 e do ADR novo).

## Frontend — `apps/cromocard-frontend`, branch `feature/116-solicitar-album`

- [ ] **T5** [P] · Criar types, api, queries e schema do formulário de solicitação de álbum — R3, R4 · CA3 · AB#1001
  - Pronto quando: o typecheck passa e `album-requests.schemas.spec.ts` cobre os avisos "Informe o <campo>.".
- [ ] **T6** · Criar formulário, foto da capa e prévia da solicitação de álbum — R3, R4, R9 · CA3, CA6 · AB#1002
  - Pronto quando: `AlbumRequestForm.spec.tsx` cobre os campos e o aviso de obrigatório, e print em 1280 px igual ao
    frame `1160-29609` e sem quebra em 375/768/1024 px.
- [ ] **T7** · Criar página Solicitar álbum com sucesso, erro e minhas solicitações — R2, R6–R9 · CA1, CA2, CA5, CA6 · AB#1003
  - Pronto quando: `RequestAlbumPage.spec.tsx` cobre CA1, CA2 e CA5, e print em 1280 px igual ao frame `1160-29609` (o
    sucesso no layout do `1160-24932`, L10) e sem quebra em 375/768/1024 px.
- [ ] **T8** · Ligar os botões Solicitar álbum em Meus álbuns — R2, R9 · CA7, CA8 · AB#1004
  - Pronto quando: os botões levam a `/albuns/solicitar`, e print em 1280 px igual aos frames `1160-23080` e `1160-29088`
    e sem quebra em 375/768/1024 px.

## Docs — workspace

- [ ] **T9** · Renomear o caso de uso 10 para Solicitar Álbum e trocar o FA 1 — R2, R4 · AB#1005
  - Pronto quando: o arquivo é `10-solicitar-album.md` com o título certo, o FA 1 é o campo obrigatório vazio e as
    referências no `CLAUDE.md` e nas specs apontam para ele (depende da L2 e da L3, com a confirmação do PO).
- [ ] **T10** · Registrar ADR do upload de imagem pelo cliente — R3 · AB#1006
  - Pronto quando: o ADR novo nasce `Proposto` em `docs/ADR/` e o índice do `README.md` dos ADRs o lista (depende da L6).

## Fechamento — workspace

- [ ] **T11** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1007
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T7, T8, T9 |
| R3 | T1, T2, T4, T5, T6, T10 |
| R4 | T1, T5, T6, T9 |
| R5 | T2, T3 |
| R6 | T2, T3, T7 |
| R7, R8 | T7 |
| R9 | T6, T7, T8 |
