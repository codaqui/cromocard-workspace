# Plano — CCD056 Favoritar Carta

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L5 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Reaproveita a base de favoritos da CCD055: acrescenta o alvo `CARD` ao módulo `/favorites`, monta o `FavoriteButton` no
perfil público da carta e cria a aba "Cartas" de Meus Favoritos. O visitante vê o "Entre para continuar" e, depois do
login, volta ao perfil da mesma carta.

## Dependências

- **CCD055**: tabela `favorites`, módulo `/favorites`, `FavoriteButton`, e `FavoritesPage`.
- **CCD030**: o `LoginToContinueModal`, que volta à página de origem depois do login.
- **CCD106**: cria `cards.status` (`card_status`: `DRAFT`, `ACTIVE`), que ainda não está no `schema.prisma`.
- **CCD030**: dona do perfil público da carta (frame `1112-4615`), onde o botão é montado.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `favorites` | da CCD055 | — | `type = CARD`, só o `card_id` (R4); índice parcial `(user_id, card_id)` da CCD055 (R7, depende da L1) |
| `cards` | sim; `status` da CCD106 | — | leitura de `status`, `deleted_at`, `name`, `number`, `front_image_url` (R8, R9) |

## Regras

- **Alvo carta** (R8): inexistente, excluída ou `status = DRAFT` → `404 CARD_NOT_FOUND` (o rascunho não existe para o
  catálogo, CA4).
- Favoritar, repetir e remover seguem a CCD055 (R4, R6, R7).
- **Lista** (R9): cartas favoritadas ativas, mais recentes primeiro, 20 por página; carta que virou rascunho ou foi
  excluída some.
- Preço, variação, "Avisar abaixo de…", "Comprar" e graduação no cartão (L4) e "Favoritar" no anúncio (L3) ficam fora até
  a decisão.

## Contrato da API

As rotas são as da CCD055, com `:type = cards`.

```ts
FavoriteCardItem = { id, favoritedAt, card: { id, name, number, frontImageUrl, album: { id, title } } }
```

| Método e caminho | Sucesso | Erros | Requisitos |
|---|---|---|---|
| `GET /api/v1/favorites/cards/:cardId` | `200` `{ data: FavoriteState }` | `400`, `401` | R5 |
| `PUT /api/v1/favorites/cards/:cardId` | `200` `{ data: FavoriteState }` | `400 VALIDATION_ERROR`, `401`, `404 CARD_NOT_FOUND` (inexistente, excluída ou `DRAFT`) | R1, R4, R7, R8 |
| `DELETE /api/v1/favorites/cards/:cardId` | `204` | `400`, `401` | R6 |
| `GET /api/v1/favorites?type=CARD` | `200` `{ data: FavoriteCardItem[], meta }` | `400`, `401` | R9 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/notifications/favorites/favorite-targets.ts` | alvo de carta: disponibilidade e item com o álbum | R8, R9 |
| `favorites.validator.ts` | aceita `cards` | R4 |
| `favorites.service.spec.ts` | casos da carta | R4–R9 |
| `favorites.swagger.ts` | exemplos de carta | R4 |
| `database/seeds/` | cartas favoritas do cliente do seed | R9 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/notifications/favorites/favorites.types.ts` · `.labels.ts` | item de carta e os textos de carta (dependem da L2) | R5, R8 |
| `components/FavoriteCardsList/` · `FavoriteCardCard/` | aba "Cartas" com imagem, nome, coleção e ♥ para remover, frame `675-10296`; vazio (texto depende da L5), carregando e erro | R6, R9, R10 |
| perfil público da carta (CCD030) | monta o `FavoriteButton` com `type = CARD`, frame `1112-4615` | R3, R5, R10 |
| `LoginToContinueModal` (CCD055) | confere a volta ao perfil da carta depois do login, frame `1112-5461` | R1, R2, R10 |

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | grava `CARD` com só o `card_id`; botão favoritado e confirmação | `favorites.service.spec.ts` · `tests/integration/favorites.spec.ts` · `FavoriteButton.spec.tsx` |
| CA2 | remove pelo perfil e pelo ♥ da lista | integração · `FavoriteCardsList.spec.tsx` |
| CA3 | duas chamadas simultâneas, um favorito ativo | integração |
| CA4 | `DRAFT` e excluída → `404`, nada gravado, aviso na tela | service · integração · `FavoriteButton.spec.tsx` |
| CA5 | visitante → "Entre para continuar" → login → volta à carta; `401` sem token | `LoginToContinueModal.spec.tsx` · integração |
| CA6, CA7 | 3 cartas, cada uma abre o perfil; carregando e erro | `FavoriteCardsList.spec.tsx` |
| CA8–CA10 | print em 1280 px igual aos frames `1112-4615`, `1112-5461` e `675-10296`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- Nenhuma rota nova: só o alvo `CARD` no Strategy da CCD055.
