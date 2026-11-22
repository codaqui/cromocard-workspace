# Plano — CCD010 Solicitar Álbum

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L14 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria`; o domínio
  `catalog/requests` vem das branches `feature/339-aprovar-solicitacoes` e `feature/607-votar-em-solicitacao-de-catalogo`)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

"Solicitar álbum" (no topo de "Meus álbuns", no vazio e no bloco "Não encontrou a coleção que você coleciona?") abre
`/albuns/solicitar`. O formulário carrega as opções de `GET /api/v1/catalog-requests/album-options` (franquias, idiomas
e editoras já usadas), sobe a foto opcional pelo `POST /api/v1/uploads` (ADR-050) e envia `POST /api/v1/catalog-requests`,
que grava `catalog_requests` com `type = ALBUM` e `status = PENDING`. A solicitação entra na fila do BackOffice da CCD064
sem mudança nela. A página mostra "Minhas solicitações" de `GET /api/v1/catalog-requests/me` e, depois de enviar, o
sucesso.

## Dependências

- **CCD064 (Aprovar Solicitações)** e **CCD103**: o domínio `src/domains/catalog/requests/`, o módulo do cliente em
  `/catalog-requests` (`catalog-request-votes.module.ts`, com `authorize('CUSTOMER', 'SELLER')`) e a fila do admin. As
  branches desta story saem de `feature/607-votar-em-solicitacao-de-catalogo` ou de `develop` depois do merge dela.
- **CCD064**: aprova `ALBUM` validando `data` com o `createAlbumSchema` do catálogo (`title`, `publisher`, `year`,
  `description`, `coverUrl`, `categoryId`). As chaves de `data` desta story seguem esses nomes, para a aprovação criar o
  álbum direto.
- **CCD104**: a ordem das categorias padrão (`defaultCategoriesService`), usada nas franquias (depende da L5).
- **CCD008**: a página "Meus álbuns" e o vazio, onde ficam os botões de entrada.
- **ADR-050**: o `POST /api/v1/uploads` hoje só aceita `ADMIN`; a foto da capa (depende da L6) precisa abrir a rota para
  `CUSTOMER` e `SELLER`.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `catalog_requests` | sim | — | grava `requester_id`, `type = ALBUM`, `data`, `status = PENDING` (R5) |
| `categories`, `languages`, `albums` | sim | — | só leitura: franquias, idiomas e `DISTINCT publisher` (depende da L4, L5) |

Chaves de `data` (depende da L4): `title`, `publisher`, `year`, `categoryId`, `totalCards`, `referenceUrl`,
`languageCode` e `coverUrl` (opcional, depende da L6). Nenhuma coluna nova: `data` é `jsonb` (ADR-051, item 3).

## Regras

- **Obrigatórios** (R4, depende da L4): `title` (1 a 160), `publisher` (1 a 120), `year` (1900 até o ano atual + 1) e
  `categoryId` (categoria existente); opcionais `totalCards` (inteiro ≥ 1), `referenceUrl` (URL), `languageCode`
  (idioma existente) e `coverUrl`. A descrição sai (L4).
- **Sem bloqueio de duplicata** (depende da L12) e **sem notificação ao admin** (depende da L13).
- **Minhas solicitações** (depende da L8): as do próprio cliente, da mais nova à mais antiga; rótulos `PENDING` = "Em
  análise", `APPROVED` = "Aprovado", `REJECTED` = "Recusado".
- **Papel** (R1, depende da L1): `CUSTOMER` e `SELLER`; `ADMIN` recebe `403`.

## Contrato da API

Convenções do ADR-011. As 3 rotas ficam no módulo do cliente `/catalog-requests` (CCD103), que já aplica `authenticate` +
`authorize('CUSTOMER', 'SELLER')`.

### `POST /api/v1/catalog-requests` — R1, R3–R6

- **Entrada:**

  ```json
  { "type": "ALBUM", "title": "Panini Brasileirão 2026", "publisher": "Panini", "year": 2026,
    "categoryId": "uuid", "totalCards": 520, "referenceUrl": "https://…", "languageCode": "pt-BR",
    "coverUrl": "https://…" }
  ```

- **Sucesso:** `201`

  ```json
  { "data": { "id": "uuid", "code": "SOL-0042", "type": "ALBUM", "status": "PENDING",
      "data": { "title": "Panini Brasileirão 2026", "…": "…" }, "createdAt": "2026-11-22T12:00:00Z" } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | campo obrigatório vazio ou formato inválido (`details` por campo) | R4 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L1) | R1 |
  | 404 | `CATEGORY_NOT_FOUND` · `LANGUAGE_NOT_FOUND` | franquia ou idioma inexistente | R5 |

  O CA3 da spec pede `422` para o título vazio; a validação do ADR-006 responde `400 VALIDATION_ERROR` em todo o
  projeto. O plano segue o ADR-006 e o CA3 precisa ser corrigido na spec.

### `GET /api/v1/catalog-requests/me` — R6 (depende da L8)

- **Entrada (query):** `type` (`ALBUM`), `page`, `pageSize` (padrão 3)
- **Sucesso:** `200` `{ data: [ { id, code, status, title, createdAt } ], meta: { page, pageSize, total } }`;
  `meta.total` é o "(n)" de "Minhas Solicitações Anteriores".
- **Erros:** `400 VALIDATION_ERROR`, `401`, `403` (R1).

### `GET /api/v1/catalog-requests/album-options` — R3 (depende da L4, L5)

- **Sucesso:** `200`

  ```json
  { "data": { "categories": [ { "id": "uuid", "name": "Futebol / Esportes" } ],
      "languages": [ { "code": "pt-BR", "name": "Português" } ],
      "publishers": [ "Panini", "Topps" ] } }
  ```

  `categories` = categorias padrão na ordem da CCD104; `publishers` = `DISTINCT albums.publisher` de álbuns não excluídos.

- **Erros:** `401`, `403` (R1).

### `POST /api/v1/uploads` (ADR-050) — R3 (depende da L6)

- Passa a aceitar `authorize('ADMIN', 'CUSTOMER', 'SELLER')`; o resto do contrato (PNG, JPG ou WEBP até 4 MB) não muda.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/catalog/requests/` (CCD064 e CCD103).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `customer-catalog-requests.validator.ts` | `createAlbumRequestSchema` e a query de `/me` | R3, R4 |
| `customer-catalog-requests.repository.ts` | gravar a solicitação, listar as do cliente, editoras usadas | R5, R6 |
| `customer-catalog-requests.service.ts` + `.spec.ts` | confere franquia e idioma, grava `data`, monta as opções com o `defaultCategoriesService` e o `references` do catálogo | R3–R6 |
| `catalog-requests.errors.ts` (CCD064) | `CATEGORY_NOT_FOUND`, `LANGUAGE_NOT_FOUND` (se o domínio ainda não tiver) | R5 |
| `catalog-request-votes.module.ts` · `.routes.ts` · `.controller.ts` · `.swagger.ts` (CCD103) | as 3 rotas no mesmo router do cliente, antes de `/:id/vote` | R1 |
| `src/domains/uploads/uploads.routes.ts` | `authorize` com os três papéis | R3 (depende da L6) |
| `tests/integration/catalog-requests-customer.spec.ts` | criar, listar as próprias e opções; a solicitação aparece no `GET /admin/catalog-requests?type=ALBUM` | CA1–CA4 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/catalog/requests/` (CCD064 e CCD103), rota do cliente no `CustomerLayout`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `album-requests.types.ts` · `.api.ts` · `.queries.ts` · `.schemas.ts` · `.labels.ts` | contrato, mutation, `zod` do formulário com "Informe o <campo>." (depende da L11), rótulos dos status | R3–R8 |
| `components/AlbumRequestForm/` | "Nome do álbum", "Total de cartas", "Ano de lançamento", "Editora ou fabricante", "Categoria / Franquia da Coleção", "Link de referência (opcional)", "Idioma do álbum"; frame `1160-29609` | R3, R4 |
| `components/AlbumCoverUpload/` | "02 Foto da capa (opcional)" com o `FileUpload` (depende da L6); frame `1160-29609` | R3 |
| `components/AlbumRequestPreview/` | "Prévia no catálogo", atualizada ao digitar (depende da L7); frame `1160-29609` | R3 |
| `components/MyAlbumRequests/` | "Minhas solicitações" com status e "Minhas Solicitações Anteriores (n)" (depende da L8); frame `1160-29609` | R6 |
| `components/AlbumRequestSuccess/` | "Solicitação enviada", a prévia, "Solicitar outro álbum" e "Acompanhar solicitações (n)", no layout do `1160-24932` (depende da L10) | R7 |
| `pages/RequestAlbumPage/` | o formulário, o envio, o erro da API com `FormError`; frame `1160-29609` | R2, R3, R7–R9 |
| `requests.routes.ts` · `src/routes/paths.ts` | `albumRequest: '/albuns/solicitar'`, só para usuário logado | R2 |
| `features/collection/pages/MyAlbumsPage/` · `MyAlbumsEmptyState` (CCD008) | botões "Solicitar álbum" e o bloco "Não encontrou a coleção que você coleciona?"; frames `1160-23080` e `1160-29088` | R2, R9 |

- **Estados:** erro de envio com a mensagem da API (R8); carregando das opções com `LoadingState`.
- **Componentes reaproveitados:** `FormField`, `TextField`, `Select`, `FileUpload`, `Button`, `FormError`, `Toast`.
- O selo "ANÁLISE EM ATÉ 24H ÚTEIS" não entra (depende da L9).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | `201`, linha `ALBUM`/`PENDING` com `data`, sucesso na tela, item na fila do admin | `customer-catalog-requests.service.spec.ts` · integração · `RequestAlbumPage.spec.tsx` |
| CA2 | envio sem os opcionais | `customer-catalog-requests.service.spec.ts` · integração |
| CA3 | sem título: nada gravado, aviso no campo, `400 VALIDATION_ERROR` na API | `album-requests.schemas.spec.ts` · integração |
| CA4 | `401` sem token | integração |
| CA5 | API fora do ar: mensagem de erro | `RequestAlbumPage.spec.tsx` |
| CA6–CA8 | prints em 1280 px iguais a `1160-29609`, `1160-23080` e `1160-29088`; 375, 768 e 1024 px sem quebra | revisão visual |

## Decisões técnicas

- As rotas do cliente ficam no mesmo módulo `/catalog-requests` da votação (CCD103), com service e repository próprios
  (`customer-catalog-requests.*`), para não misturar a votação com a criação.
- `data` usa os nomes do `createAlbumSchema` do catálogo: a aprovação da CCD064 valida e cria o álbum sem tradução de
  chaves. `totalCards`, `referenceUrl` e `languageCode` ficam em `data` só para o admin conferir.
- **Risco:** o `plano.md` da CCD103 diz que a fila lê a capa sugerida de `data.coverImageUrl`; a CCD064 aprova com
  `coverUrl`. O plano usa `coverUrl` (o que a aprovação lê) e a CCD103 precisa conferir a chave lida no cartão.
- Abrir o upload para o cliente muda o ADR-050 (só `ADMIN`): se a L6 for aprovada, isso vira ADR novo `Proposto`.
