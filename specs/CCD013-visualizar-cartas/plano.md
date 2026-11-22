# Plano — CCD013 Visualizar Cartas

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L10 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

"Abrir álbum" (CCD008) leva a `/albuns/:albumId`. A página chama `GET /api/v1/collections/me/albums/:albumId` (cabeçalho,
contagens por status e os outros álbuns da coleção para o seletor "COLEÇÃO:") e
`GET /api/v1/collections/me/albums/:albumId/cards` (as cartas publicadas do álbum com o status na coleção do cliente,
filtradas pela aba, ordenadas por número, 24 por vez). As cartas aparecem em grade (padrão) ou em lista. Esta página é a
base da marcação (CCD014), da quantidade (CCD017, CCD018) e do menu do álbum (CCD011).

## Dependências

- **CCD007**: domínio `collection`, tabelas `user_albums`, `collection_cards` e `price_history` e o repository dos preços.
- **CCD008**: a rota `albumDetailPathFor(id)` e o botão "Abrir álbum".
- **CCD106 (Salvar Rascunho de Carta)**: a coluna `cards.status` (`add_status_and_release_year_to_cards_table`), que
  ainda não está no `schema.prisma`. O filtro `status = ACTIVE` (R3, CA2) depende dela; se esta story entrar antes, a
  migration da CCD106 vem antes, num PR próprio.
- **CCD105 (Duplicar Carta)**: a coluna `cards.variants` (`add_code_and_variants_to_cards_table`), usada no selo de
  variante (depende da L7), também fora do `schema.prisma` hoje.
- **CCD078**: "Comprar Faltantes" leva ao marketplace filtrado (depende da L10); até a CCD078, o link abre a página
  "em construção" do marketplace.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `cards` | sim, sem `status` e `variants` | da CCD106 e da CCD105 | lê `album_id`, `number`, `name`, `description`, `variants`, `front_image_url`, `status`, `deleted_at` (R3) |
| `albums`, `categories` | sim | — | cabeçalho: `title`, `publisher`, `cover_url`, `total_cards`, `category.name` (depende da L9) |
| `user_albums`, `collection_cards`, `price_history` | da CCD007 | — | só leitura |

Nenhuma coluna fora do DBML. Os selos do cabeçalho ("PANINI PRIZM 2026", "LICENCIADO FIFA", "OFICIAL") não têm coluna e
saem do Figma (depende da L9).

## Regras

- **Álbum da coleção** (R1, depende da L2): `user_albums` ativo do cliente; fora da coleção, `404`.
- **Cartas** (R3): `cards.album_id` = o álbum, `deleted_at` nulo e `status = ACTIVE`.
- **Status** (R5, depende da L4): o da `collection_cards` ativa do cliente; sem linha, `MISSING` com quantidade 0, sem
  gravar nada.
- **Campos do cartão** (depende da L7): `number` ("#01"), primeira variante de `variants` (separadas por vírgula),
  `description` como subtítulo e preço médio dos últimos 30 dias (regra da CCD007, L5).
- **Abas e ordem** (depende da L8): `status` = `OWNED` · `MISSING` · `DUPLICATE` (sem = todas); a aba "Possuo" traz
  `OWNED` e `DUPLICATE`; ordem por número natural (`#2` antes de `#10`); 24 por página com "Carregar mais"; "Exibindo <n>
  de <total> itens".
- **Seletor "COLEÇÃO:"** (depende da L9): os álbuns ativos da coleção, por título.
- **Rótulos** (depende da L3): "NO ÁLBUM", "<n> REPETIDAS" (`quantity − 1`) e "FALTANDO".

## Contrato da API

Convenções do ADR-011. Acesso: `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L1).

### `GET /api/v1/collections/me/albums/:albumId` — R1, R2

- **Sucesso:** `200`

  ```json
  { "data": { "albumId": "uuid", "title": "Copa do Mundo 2026", "coverUrl": "https://…", "publisher": "Panini",
      "category": { "id": "uuid", "name": "Futebol" }, "totalCards": 54, "progressPercentage": 79.63,
      "counts": { "all": 54, "owned": 43, "missing": 11, "duplicates": 6 },
      "otherAlbums": [ { "albumId": "uuid", "title": "Destinos Brilhantes" } ] } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `albumId` não é uuid | R1 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L1) | R1 |
  | 404 | `COLLECTION_ALBUM_NOT_FOUND` | álbum fora da coleção ou excluído (depende da L2) | R1 |

### `GET /api/v1/collections/me/albums/:albumId/cards` — R1, R3–R5

- **Entrada (query):** `status` (`OWNED` · `MISSING` · `DUPLICATE`, opcional), `page` (padrão 1), `pageSize` (padrão 24,
  máximo 96)
- **Sucesso:** `200`

  ```json
  { "data": [ { "cardId": "uuid", "number": "01", "name": "Thibaut Courtois", "description": "Bélgica • Goleiro (GK)",
      "variant": "BASE FOIL", "frontImageUrl": "https://…", "status": "DUPLICATE", "quantity": 3,
      "averagePrice": "12.50" } ],
    "meta": { "page": 1, "pageSize": 24, "total": 54 } }
  ```

  Álbum sem cartas publicadas: `data: []` e `meta.total = 0` (R6).

- **Erros:** os mesmos do endpoint anterior (R1).

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-album-cards.repository.ts` | cartas `ACTIVE` do álbum com `LEFT JOIN` na `collection_cards` do cliente, filtro por status, ordem natural por número, contagens | R3–R5 |
| `collection-albums.repository.ts` (CCD008) | cabeçalho do álbum da coleção e os outros álbuns | R1, R2 |
| `collection-album-detail.service.ts` + `.spec.ts` | `404` fora da coleção, cabeçalho, lista paginada com preço médio | R1–R6 |
| `collection.validator.ts` · `.controller.ts` · `.routes.ts` · `.swagger.ts` | params e query; as 2 rotas | R1 |
| `database/seeds/data/collection.json` (CCD007) | o álbum "Copa do Mundo 2026" com 54 cartas, uma `DRAFT`, uma excluída e marcações | CA1, CA2, CA8 |
| `tests/integration/collection-album-detail.spec.ts` | rotas de ponta a ponta | CA1, CA2, CA4–CA6 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-album.types.ts` · `.api.ts` · `.queries.ts` · `.labels.ts` | contrato, `useInfiniteQuery` das cartas, rótulos "NO ÁLBUM", "<n> REPETIDAS", "FALTANDO" | R3–R5 |
| `components/AlbumDetailHeader/` | caminho "Início / Álbuns / <álbum>", seletor "COLEÇÃO:", capa, título, "Panini • Futebol • 54 cartas catalogadas" (depende da L9); frame `1160-23696` | R2 |
| `components/AlbumCardsToolbar/` | abas com contagem (`Tabs`), "Ordenar por: Número (#01 a #54)", ícones de grade e lista, "Exibindo <n> de <total> itens" (depende da L8); frame `1160-23696` | R4 |
| `components/AlbumCardTile/` | cartão da grade: número, selo de variante, imagem, nome, subtítulo, "Preço médio:" e o selo de status (depende da L7); frame `1160-23696` | R4, R5 |
| `components/AlbumCardRow/` | a mesma carta em lista (sem frame: L5, no estilo do cartão) | R4 |
| `components/AlbumTipBanner/` | "Dica: marque cada carta do álbum" e "Comprar Faltantes" (depende da L10); frame `1160-23696` | R2 |
| `pages/AlbumDetailPage/` | os blocos acima, "Carregar mais", vazio "Nenhuma carta cadastrada para este álbum ainda" (L6), `LoadingState`, `ErrorState` e o `404`; frame `1160-23696` | R2, R4, R6–R8 |
| `collection.routes.ts` | rota `/albuns/:albumId` (lazy) | R2 |

- **Componentes reaproveitados:** `Tabs`, `Select`, `Badge`, `Button`, `EmptyState`, `LoadingState`, `ErrorState`, `Icon`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 54 cartas em grade com o status do cliente | `collection-album-detail.service.spec.ts` · integração · `AlbumDetailPage.spec.tsx` |
| CA2 | carta `DRAFT` e carta excluída fora | `collection-album-detail.service.spec.ts` · integração |
| CA3 | ícone de lista mostra as mesmas cartas em lista | `AlbumDetailPage.spec.tsx` |
| CA4 | repetida para um cliente, sem marcação para outro | integração |
| CA5 | álbum sem cartas mostra a mensagem do FA 1 | `collection-album-detail.service.spec.ts` · `AlbumDetailPage.spec.tsx` |
| CA6 | `401` sem token | integração |
| CA7 | carregando e erro | `AlbumDetailPage.spec.tsx` |
| CA8 | print em 1280 px igual a `1160-23696`; 375, 768 e 1024 px sem quebra | revisão visual com o seed |

## Decisões técnicas

- Uma consulta com `LEFT JOIN` entre `cards` e a `collection_cards` do cliente dá o status de toda carta, inclusive a
  nunca marcada (L4), sem gravar linhas vazias.
- A ordem natural do número (`varchar(20)`) usa a parte numérica no `ORDER BY` (`NULLIF(regexp_replace(number, '\D', '',
  'g'), '')::int`, depois o texto), para "#2" vir antes de "#10".
- A preferência grade/lista fica no `localStorage` do navegador; não vai para a API.
