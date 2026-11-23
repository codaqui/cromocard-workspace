# Plano — CCD057 Favoritar Grupo

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L6 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Reaproveita a base de favoritos da CCD055: acrescenta o alvo `GROUP` ao módulo `/favorites`, monta o `FavoriteButton` na
página do grupo (tela depende da L1) e cria a aba "Grupos" de Meus Favoritos, com o nome do grupo e a quantidade de
membros.

## Dependências

- **CCD055**: tabela `favorites`, módulo `/favorites`, `FavoriteButton` e `FavoritesPage`.
- **CCD039 / CCD044**: a página do grupo (detalhes ou chat) onde o botão fica; qual delas depende da L1, porque o Figma
  não desenha o botão.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `favorites` | da CCD055 | — | `type = GROUP`, só o `group_id` (R3); índice parcial `(user_id, group_id)` da CCD055 (R6, depende da L3) |
| `groups` | sim | — | `name`, `cover_image_url`, `status`, `access_type`, `deleted_at` (R7, R8) |
| `group_members` | sim | — | contagem de membros do cartão (R8, depende da L5) |

## Regras

- **Alvo grupo** (R7): inexistente ou excluído → `404 GROUP_NOT_FOUND`; `status = SUSPENDED` → `422 GROUP_UNAVAILABLE`;
  `ACTIVE` e `WARNED` disponíveis, para qualquer cliente que vê o grupo, membro ou não (depende da L2).
- Favoritar, repetir e remover seguem a CCD055 (R3, R5, R6).
- **Lista** (R8): grupos favoritados ativos, mais recentes primeiro, 20 por página; grupo suspenso continua na lista,
  excluído some.
- Cidade, selos de novidade e "Abrir chat" (L5) e a chave de silenciar (CCD041) ficam fora até a decisão.

## Contrato da API

As rotas são as da CCD055, com `:type = groups`.

```ts
FavoriteGroupItem = { id, favoritedAt, group: { id, name, coverImageUrl, memberCount, status } }
```

| Método e caminho | Sucesso | Erros | Requisitos |
|---|---|---|---|
| `GET /api/v1/favorites/groups/:groupId` | `200` `{ data: FavoriteState }` | `400`, `401` | R4 |
| `PUT /api/v1/favorites/groups/:groupId` | `200` `{ data: FavoriteState }` | `400 VALIDATION_ERROR`, `401`, `404 GROUP_NOT_FOUND`, `422 GROUP_UNAVAILABLE` | R1, R3, R6, R7 |
| `DELETE /api/v1/favorites/groups/:groupId` | `204` | `400`, `401` | R5 |
| `GET /api/v1/favorites?type=GROUP` | `200` `{ data: FavoriteGroupItem[], meta }` | `400`, `401` | R8 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/notifications/favorites/favorite-targets.ts` | alvo de grupo: disponibilidade e item com `memberCount` (`_count` de membros ativos) | R7, R8 |
| `favorites.errors.ts` | `GroupUnavailableError` (`422`); o `404` reaproveita o de comunidade | R7 |
| `favorites.validator.ts` · `.swagger.ts` · `.service.spec.ts` | aceita `groups`, exemplos e casos do grupo | R3–R8 |
| `database/seeds/` | grupos favoritos do cliente do seed | R8 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/notifications/favorites/favorites.types.ts` · `.labels.ts` | item de grupo e os textos de grupo (dependem da L4) | R4, R7 |
| `components/FavoriteGroupsList/` · `FavoriteGroupCard/` | aba "Grupos" com nome, "<n> membros" e ♥ para remover, frame `675-11250`; vazio (texto depende da L6), carregando e erro | R5, R8, R9 |
| página do grupo (CCD039/CCD044) | monta o `FavoriteButton` com `type = GROUP`, no estilo da própria tela (sem frame, depende da L1) | R2, R4, R5, R7 |

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | grava `GROUP` com só o `group_id`; botão favoritado e confirmação | `favorites.service.spec.ts` · `tests/integration/favorites.spec.ts` · `FavoriteButton.spec.tsx` |
| CA2 | remove pela página e pelo ♥ da lista | integração · `FavoriteGroupsList.spec.tsx` |
| CA3 | duas chamadas simultâneas, um favorito ativo | integração |
| CA4 | `SUSPENDED` → `422`; excluído → `404`; aviso na tela | service · integração · `FavoriteButton.spec.tsx` |
| CA5 | `401` sem token | integração |
| CA6, CA7 | 4 grupos, cada um abre o grupo; carregando e erro | `FavoriteGroupsList.spec.tsx` |
| CA8 | print em 1280 px igual ao frame `675-11250`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- Nenhuma rota nova: só o alvo `GROUP` no Strategy da CCD055.
