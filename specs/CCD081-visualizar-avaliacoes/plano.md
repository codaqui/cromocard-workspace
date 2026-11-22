# Plano — CCD081 Visualizar Avaliações

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.
>
> **Fase Futuro Marketplace: implementar depois do MVP.**

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L6 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

A seção "Avaliações" do vendedor entra no detalhe do anúncio (CCD079) e no perfil público (CCD080). Fechada, mostra só o
título; ao clicar, chama `GET /api/v1/profiles/:userId/reviews` (exige login), que devolve as avaliações recebidas e, no
`meta`, a nota média e o total. Sem avaliações, a seção mostra "Este vendedor ainda não possui avaliações".

## Dependências

- **CCD079** (página `/anuncios/:id`) e **CCD080** (domínio `profiles` e página `/usuarios/:id`): a seção entra nas duas.
- **CCD097**: cria `reviews` (`create_reviews_table`) e o seed; sem caso de uso para criar avaliações (L3), os testes e a
  homologação dependem do seed.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `reviews` | não | `create_reviews_table` (da CCD097) | só leitura: `seller_id`, `author_id`, `rating`, `comment`, `created_at`, `deleted_at` (R3–R5) |
| `users` | sim | — | `username` de quem avaliou (depende da L5) |

Nenhuma coluna nova.

## Regras

- **Nota média** (R3, R4): média de `rating` das avaliações não excluídas do vendedor, com uma casa decimal, e o total
  (depende da L6). Sem avaliações, `averageRating: null` e `total: 0` (R6).
- **Lista** (R5): mais recentes primeiro, 10 por página (depende da L6); cada item traz nota, comentário, data e nome de
  usuário de quem avaliou (depende da L5); avaliação sem comentário entra só com a nota (depende da L5).
- **Login** (R1): a rota exige token (depende da L4); qualquer papel autenticado vê.
- **Vendedor inexistente ou excluído:** `404 PROFILE_NOT_FOUND` (mesma regra do perfil público, CCD080).

## Contrato da API

Convenções do ADR-011.

### `GET /api/v1/profiles/:userId/reviews` — R1, R3–R6

- **Acesso:** autenticado (`Authorization: Bearer`).
- **Entrada:** `userId` (uuid) no caminho; `page`, `pageSize` (padrão 10).
- **Sucesso:** `200`

  ```json
  { "data": [ { "id": "uuid", "rating": 5, "comment": "Chegou rápido", "createdAt": "2026-11-20T12:00:00Z",
      "author": { "username": "gabriel_n" } } ],
    "meta": { "page": 1, "pageSize": 10, "total": 3, "averageRating": "4.0" } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `userId` ou paginação inválidos | R3 |
  | 401 | `UNAUTHORIZED` | sem token ou token inválido | R1 |
  | 404 | `PROFILE_NOT_FOUND` | vendedor inexistente ou excluído | R3 |

## Backend — `apps/cromocard-backend`

No domínio `src/domains/profiles/` (CCD080), com a rota protegida por `authenticate` só nela.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `profiles.validator.ts` | `reviewsQuery` (Zod) | R3 |
| `reviews.repository.ts` | `findBySeller` (paginado, mais recentes primeiro) e `averageBySeller` (`aggregate _avg`, `_count`) | R3–R5 |
| `reviews.service.ts` + `reviews.service.spec.ts` | página, média com uma casa, vazio | R3–R6 |
| `profiles.controller.ts` · `profiles.routes.ts` · `profiles.swagger.ts` | `GET /:userId/reviews` com `authenticate`, no `/docs` | R1 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/profiles/reviews.types.ts` · `reviews.api.ts` · `reviews.queries.ts` · `reviews.labels.ts` | contrato, query habilitada só ao abrir a seção, textos (inclui "Este vendedor ainda não possui avaliações") | R3–R6 |
| `src/features/profiles/components/SellerReviewsSection/` | título clicável, nota consolidada, lista com `Pagination`, vazio com `EmptyState`, `LoadingState` e `ErrorState`; frame a desenhar (L1), no estilo das telas `1112-5772` e `1160-1396` | R2, R4–R8 |
| `src/features/marketplace/listings/pages/ListingDetailPage/` (CCD079) | inclui a seção para o cliente logado | R2 |
| `src/features/profiles/pages/PublicProfilePage/` (CCD080) | inclui a seção para o cliente logado | R2 |

Visitante não vê a seção (a rota responde `401`, R1; depende da L4).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | notas 5, 4 e 3: `averageRating: "4.0"`, `total: 3` e os comentários | `reviews.service.spec.ts` · `tests/integration/profile-reviews.spec.ts` · `SellerReviewsSection.spec.tsx` |
| CA2 | a mesma seção no perfil público | `PublicProfilePage.spec.tsx` |
| CA3 | sem avaliações: a mensagem do FA 1 | `reviews.service.spec.ts` · `SellerReviewsSection.spec.tsx` |
| CA4 | sem token: `401` e a seção não aparece | `tests/integration/profile-reviews.spec.ts` · `ListingDetailPage.spec.tsx` |
| CA5 | carregando e erro | `SellerReviewsSection.spec.tsx` |
| CA6 | print em 1280 px igual aos frames da seção e do vazio, quando desenhados (L1); sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

Cobertura mínima de 90% nos arquivos alterados (ADR-060).

## Decisões técnicas

- A nota média sai no `meta` da lista, para uma chamada só e sem endpoint de resumo paralelo.
- A seção busca os dados só quando o cliente a abre (R2: "abre com um clique"), para não pesar o detalhe do anúncio.
- Nenhuma decisão nova de arquitetura: segue ADR-011, ADR-027 e ADR-041.
