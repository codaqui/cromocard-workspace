# Plano — CCD011 Remover Álbum

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L9 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O menu de opções do álbum ("⋯" no detalhe e "⋮" no cartão de "Meus álbuns", depende da L3) tem "Remover da minha
coleção", que abre o modal "Remover o álbum da sua coleção?". Ao confirmar, o frontend chama
`DELETE /api/v1/collections/me/albums/:albumId`, que preenche `deleted_at` do `user_albums` e das `collection_cards` das
cartas do álbum numa transação. O frontend invalida a lista, o resumo e o detalhe, mostra o aviso e, se veio do detalhe,
volta para "Meus álbuns".

## Dependências

- **CCD007**: domínio `collection` e as tabelas `user_albums` e `collection_cards`.
- **CCD008**: a página "Meus álbuns", o cartão `CollectionAlbumCard` (onde fica o "⋮") e a query `useMyAlbums`.
- **CCD013**: a página do detalhe do álbum (onde fica o "⋯"). Se ela entrar depois, o menu do detalhe entra com ela,
  reaproveitando o `AlbumOptionsMenu` desta story.
- **CCD035**: acrescenta "Resetar progresso" ao mesmo menu depois.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `user_albums` | da CCD007 | — | `deleted_at = now()` (R4) |
| `collection_cards` | da CCD007 | — | `deleted_at = now()` nas cartas do álbum (`cards.album_id`) da coleção (R4) |
| `albums`, `cards` | sim | — | não mudam: o álbum continua no catálogo (R4) |

Nenhuma coluna nova.

## Regras

- **Só da coleção do cliente** (R1): `user_albums` ativo com o `collection_id` do cliente e o `album_id`; senão `404`.
- **Exclusão lógica** (R4, ADR-015): uma transação com `updateMany` em `user_albums` e em `collection_cards` (filtrando
  `card.albumId` e `deletedAt: null`); as marcações de outros álbuns não mudam (CA3).
- **Readicionar** (depende da L5): fica para a CCD022, que restaura `user_albums` com `progress_percentage = 0`; as
  `collection_cards` antigas só voltam quando o cliente marcar de novo (CCD014).
- **Anúncios** (depende da L7): não mudam.
- **Leituras** (depende da L8): resumo (CCD007), lista (CCD008) e compartilhamento (CCD012) já filtram `deleted_at`.

## Contrato da API

Convenções do ADR-011.

### `DELETE /api/v1/collections/me/albums/:albumId` — R1, R4

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L1)
- **Entrada:** `albumId` (uuid) no caminho
- **Sucesso:** `204`, sem corpo
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `albumId` não é uuid | R1 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L1) | R1 |
  | 404 | `COLLECTION_ALBUM_NOT_FOUND` | álbum fora da coleção do cliente ou já removido | R1 |

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-albums.repository.ts` (CCD008) | `removeFromCollection(collectionId, albumId)` na transação | R4 |
| `collection-albums.service.ts` + `.spec.ts` | confere o vínculo (`404`) e remove | R1, R4 |
| `collection.errors.ts` | `CollectionAlbumNotFoundError` (`COLLECTION_ALBUM_NOT_FOUND`) | R1 |
| `collection.validator.ts` · `.controller.ts` · `.routes.ts` · `.swagger.ts` | param `albumId` e a rota `DELETE /me/albums/:albumId` | R1 |
| `tests/integration/collection-remove-album.spec.ts` | rota de ponta a ponta | CA2, CA3, CA5 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection.api.ts` · `collection.queries.ts` | `removeAlbum(albumId)` e `useRemoveAlbum`, que invalida a lista, o resumo e o detalhe | R4, R5 |
| `components/AlbumOptionsMenu/` | menu com "Remover da minha coleção" (depende da L2); frame `1160-26090` | R2 |
| `components/RemoveAlbumDialog/` | "Remover o álbum da sua coleção?", o texto do frame, "Cancelar", "Remover álbum" e "✕" (que faz o mesmo que "Cancelar", L9), com o `ConfirmDialog`; erro da API dentro do modal; frame `1160-27915` | R3, R6, R7 |
| `components/CollectionAlbumCard/` (CCD008) | o "⋮" abre o `AlbumOptionsMenu` (depende da L3) | R2 |
| `pages/AlbumDetailPage/` (CCD013) | o "⋯" abre o `AlbumOptionsMenu`; depois de remover, vai para `/albuns` (depende da L4) | R2, R5 |
| `pages/MyAlbumsPage/` (CCD008) | aviso "Álbum removido da sua coleção" com o `Toast` (depende da L6) | R5 |

- **Componentes reaproveitados:** `ConfirmDialog`, `Toast`, `Button`, `Icon`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | o menu abre o modal com o aviso das marcações | `RemoveAlbumDialog.spec.tsx` · `MyAlbumsPage.spec.tsx` |
| CA2 | `204`, `deleted_at` nas duas tabelas, álbum no catálogo, lista sem o álbum | `collection-albums.service.spec.ts` · integração · `MyAlbumsPage.spec.tsx` |
| CA3 | marcações do outro álbum intactas | `collection-albums.service.spec.ts` · integração |
| CA4 | "Cancelar" e "✕" fecham sem chamar a API | `RemoveAlbumDialog.spec.tsx` |
| CA5 | `404` fora da coleção, `401` sem token | integração |
| CA6 | API fora do ar: mensagem de erro e álbum na lista | `RemoveAlbumDialog.spec.tsx` |
| CA7, CA8 | prints em 1280 px iguais a `1160-26090` e `1160-27915`; 375, 768 e 1024 px sem quebra | revisão visual |

## Decisões técnicas

- `DELETE` no vínculo (`/me/albums/:albumId`) e não no álbum: o recurso removido é o álbum da coleção, e o catálogo não
  muda (ADR-011, ADR-015).
- As duas exclusões lógicas vão numa transação, para o álbum não sair da lista com as marcações ainda ativas.
