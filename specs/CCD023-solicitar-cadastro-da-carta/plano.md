# Plano — CCD023 Solicitar Cadastro da Carta

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L13 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O link "Solicitar cadastro da carta →" do modal "Adicionar carta" (CCD021) leva à página `/albuns/solicitar-carta`. O
formulário carrega as opções (álbuns ativos, franquias, raridades e idiomas) de `GET /catalog-requests/card-options`, sobe
as fotos por `POST /uploads` e envia `POST /catalog-requests` com `type = CARD`. A API grava em `catalog_requests` uma
solicitação `PENDING` com o cliente em `requester_id`, que entra na fila do admin da CCD064. A tela troca para a
confirmação "Solicitação enviada", com o resumo, e "Solicitar Outra Carta" volta ao formulário vazio.

## Dependências

- **CCD064** — fila do admin (`src/domains/catalog/requests/`), o formato de `data` de `CARD` (`name`, `number`,
  `albumId`, `categoryId`, `rarityId`, `languageId`, `frontImageUrl`, `backImageUrl?`) e a regra de dados completos.
- **CCD103** — módulo do cliente `catalog-request-votes.module.ts` em `/catalog-requests`; esta story acrescenta a ele as
  rotas de criar e de opções. Ambas saem da branch `feature/339-aprovar-solicitacoes` e entram depois dela.
- **CCD021** — modal "Adicionar carta", onde fica o link (R2).
- **Fundação / ADR-050** — `POST /api/v1/uploads` (hoje só `ADMIN`) e o `StorageProvider`.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `catalog_requests` | sim | — | grava `type = CARD`, `status = PENDING`, `requester_id` e `data` (R7) |
| `albums` · `categories` · `rarities` · `languages` | sim | — | só leitura, para as opções (R5) |

Nenhuma coluna nova. "Ano de lançamento" (`cards.release_year`, CCD106) só entra se a L2 aceitar.

## Regras

- **Obrigatórios** (R10, depende da L1): nome (1–160), número (1–20), álbum, franquia, raridade, idioma e a foto da frente.
  Verso opcional (R6).
- **Opções** (R5): álbum `ACTIVE` não excluído; raridades e idiomas não excluídos; franquia = categorias raiz não
  excluídas (depende da L3: escolher o álbum preenche a franquia dele).
- **Ids válidos** (R5): álbum, franquia, raridade ou idioma inexistente → `422 INVALID_REFERENCE`.
- **Fotos** (R6): JPG, PNG ou WEBP até 4 MB, do ADR-050 (o "15 MB" do Figma depende da L4). O cliente usa o mesmo
  `POST /uploads`, aberto também a `CUSTOMER` e `SELLER` (depende da L4).
- **Duplicadas** (L11): não bloqueia; o admin recusa na CCD064.
- **Quem solicita** (R1): `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` (depende da L13).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }`, JSON camelCase, erros `{ error, message, details? }`.

### `GET /api/v1/catalog-requests/card-options` — R4, R5

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L13)
- **Sucesso:** `200`

  ```json
  { "data": { "albums": [{ "id": "uuid", "title": "Copa do Mundo 2026", "categoryId": "uuid" }],
              "categories": [{ "id": "uuid", "name": "Futebol" }],
              "rarities": [{ "id": "uuid", "name": "Lendária" }], "languages": [{ "id": "uuid", "name": "Português - Brasil" }] } }
  ```

### `POST /api/v1/catalog-requests` — R1, R4–R8, R10

- **Acesso:** o mesmo.
- **Entrada:**

  ```json
  { "type": "CARD", "data": { "name": "Kylian Mbappé", "number": "09", "albumId": "uuid", "categoryId": "uuid",
    "rarityId": "uuid", "languageId": "uuid", "frontImageUrl": "https://…", "backImageUrl": null } }
  ```

- **Sucesso:** `201`

  ```json
  { "data": { "id": "uuid", "code": "SOL-0042", "type": "CARD", "status": "PENDING", "createdAt": "…",
              "summary": { "name": "Kylian Mbappé", "number": "09", "albumTitle": "Copa do Mundo 2026",
                           "photos": { "front": true, "back": false } } },
    "meta": { "myRequestsCount": 3 } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | corpo malformado (tipo errado, URL inválida) | R4 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L13) | R1 |
  | 422 | `REQUIRED_FIELDS_MISSING` | campo obrigatório ausente; `details` lista os campos (depende da L1) | R10 |
  | 422 | `INVALID_REFERENCE` | álbum, franquia, raridade ou idioma inexistente ou inativo | R5 |

### `POST /api/v1/uploads` (fundação) — R6

- **Muda:** `authorize('ADMIN', 'CUSTOMER', 'SELLER')` (depende da L4). Erros já existentes: `400` tipo inválido e `413`
  arquivo maior que 4 MB.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/catalog/requests/` (CCD064 e CCD103).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `catalog-request-create.validator.ts` | `createCardRequestBody` (Zod) e a lista de obrigatórios | R4, R6, R10 |
| `catalog-requests.errors.ts` | `RequiredFieldsMissingError`, `InvalidReferenceError` | R5, R10 |
| `catalog-request-create.repository.ts` | opções, conferência dos ids, `create` e `countByRequester` | R5, R7, R8 |
| `catalog-request-create.service.ts` + `.spec.ts` | valida, grava `PENDING` e devolve o resumo e a contagem | R5–R8, R10 |
| `catalog-request-votes.controller.ts` · `.routes.ts` · `.swagger.ts` (CCD103) | rotas `GET /card-options` e `POST /` | R1 |
| `src/domains/uploads/uploads.routes.ts` · `.swagger.ts` | papéis do upload (depende da L4) | R6 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/catalog/requests/` (CCD064 e CCD103).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `card-request.types.ts` · `.api.ts` · `.queries.ts` · `.schemas.ts` · `.labels.ts` | contrato, `useCardRequestOptions`, `useCreateCardRequest`, Zod espelhando os obrigatórios, textos da página, do erro (L10) e da confirmação | R4–R8, R10 |
| `components/CardRequestForm/` | campos "Nome Oficial da Carta / Cromo", "Número no Set / Edição", "Álbum ou Edição Principal", "Categoria / Franquia da Coleção", "Raridade Estimada", "Idioma da Carta", "Foto da frente da carta" e "Foto do verso" ("Opcional"), com `ImageUploadField`; erros por campo, sem perder o preenchido — frame `1160-24389` | R4–R6, R10, R11 |
| `components/CardRequestSent/` | "Solicitação enviada", resumo, "Em análise", "1 Foto Anexada (Frente)", "Solicitar Outra Carta", "Acompanhar Solicitações (<n>)" e "Ficou com dúvida? Central de ajuda" — frame `1160-24932` | R8, R9, R11 |
| `pages/CardRequestPage/` | caminho "Início › Álbuns › Solicitar Cadastro › Nova Carta", "Voltar aos álbuns", alterna formulário e confirmação — frames `1160-24389` e `1160-24932` | R3, R8, R9, R11 |
| `src/features/collection/components/AddCardModal/` (CCD021) | bloco "Não encontrou a carta? Solicitar cadastro da carta →" leva à página — frame `1160-28449` | R2, R11 |
| `catalog.routes.ts` · `src/routes/paths.ts` · `app/router.tsx` | `cardRequest: '/albuns/solicitar-carta'` no `CustomerLayout`, com `RequireAuth` | R1, R3 |

- **Estados:** carregando as opções e erro com `LoadingState` e `ErrorState`; envio com o botão desabilitado.
- **Componentes reaproveitados:** `TextField`, `Select`, `FormField`, `FormError`, `Button`, `Badge`, e
  `ImageUploadField`/`ImageUploadController` de `src/features/catalog/components/` (subir para `src/components/` se o
  reuso pedir, como manda o ADR-040).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | completo: `201`, `CARD` `PENDING` com `requester_id`, tela "Solicitação enviada" e "Em análise" | `catalog-request-create.service.spec.ts` · `tests/integration/catalog-requests-create.spec.ts` · `CardRequestPage.spec.tsx` |
| CA2 | sem a frente: campo pendente, dados mantidos, nada gravado | `CardRequestForm.spec.tsx` · integração (`422`) |
| CA3 | sem um obrigatório: campo pendente e `422 REQUIRED_FIELDS_MISSING` | `catalog-request-create.service.spec.ts` · integração · `CardRequestForm.spec.tsx` |
| CA4 | sem o verso: gravada | integração |
| CA5 | PDF ou maior que 4 MB: tela recusa, API `400`/`413` | `CardRequestForm.spec.tsx` · `tests/integration/uploads.spec.ts` (papel cliente) |
| CA6 | "Solicitar Outra Carta" mostra o formulário vazio | `CardRequestPage.spec.tsx` |
| CA7 | o link do modal abre a página | `AddCardModal.spec.tsx` |
| CA8 | sem token `401` | integração |
| CA9–CA11 | print em 1280 px igual aos frames `1160-28449`, `1160-24389` e `1160-24932`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- A falta de obrigatório responde `422` (não `400`), como pede o FA 2 e o CA3: o Zod valida o formato (`400`) e a service
  confere a presença dos obrigatórios (`422`), com a lista em `details`, para o frontend marcar cada campo.
- As fotos sobem antes do envio, pela rota de upload que já existe, e a solicitação guarda só as URLs em `data` (como o
  admin espera na CCD064). Abrir o upload ao cliente muda uma decisão da fundação: entra só com a L4 decidida.
- "Prévia no catálogo", "Minhas solicitações", "ANÁLISE EM ATÉ 24H ÚTEIS" e "Ano de lançamento" (L2, L5–L7) não entram.
