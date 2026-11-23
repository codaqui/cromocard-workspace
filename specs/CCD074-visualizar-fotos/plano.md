# Plano — CCD074 Visualizar Fotos

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L4 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O `GET /api/v1/listings/:id` da CCD079 passa a devolver as fotos do anúncio (até 4, por `sort_order`, sem as excluídas) e
a imagem da carta do catálogo. O detalhe do anúncio ganha a galeria `ListingPhotoGallery`: foto em destaque, miniaturas,
setas e a foto ampliada; sem fotos, mostra a imagem da carta.

## Dependências

- **CCD079**: endpoint e página do detalhe do anúncio (`/anuncios/:id`).
- **CCD084**: tabela `listing_photos` e as fotos gravadas na criação do anúncio.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `listing_photos` | da CCD084 | — | `url`, `sort_order`, `deleted_at` (R2, R7) |
| `cards` | sim | — | `front_image_url` como imagem do catálogo (R6, depende da L3) |

## Regras

- **Fotos** (R2, R7): `deleted_at` nulo, `sort_order` crescente e, no empate, `created_at`; as 4 primeiras (depende da L4).
- **Sem fotos** (R6): a galeria usa `card.frontImageUrl` como única imagem, sem miniaturas (depende da L3).
- **Setas** (R4): avançam e voltam uma foto; da última vão para a primeira e vice-versa (depende da L1); escondidas com uma
  foto só.
- **Ampliar** (R5): abre a foto em destaque num modal com as mesmas setas e fecha pelo botão, pelo `Esc` e pelo fundo
  (entra com esta story, depende da L2).
- **Foto que não carrega** (CA7): o espaço mantém a proporção do frame (`aspect-ratio`) e mostra o fundo neutro.

## Contrato da API

### `GET /api/v1/listings/:id` (CCD079) — R1, R2, R6, R7

- **Acesso:** público (sem mudança).
- **Sucesso:** `200`, a resposta da CCD079 ganha:

  ```json
  { "data": { "photos": [{ "id": "uuid", "url": "https://…", "sortOrder": 0 }],
    "card": { "id": "uuid", "name": "Lionel Messi", "frontImageUrl": "https://…" } } }
  ```

- **Erros:** os da CCD079.

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/marketplace/listings/listings.repository.ts` | `findPublicById` inclui as fotos (filtro, ordem e `take: 4`) e a imagem da carta | R2, R6, R7 |
| `listings.service.ts` + `.spec.ts` · `listings.swagger.ts` | mapeia `photos` e `card`; exemplos | R2, R6, R7 |
| `database/seeds/` | anúncios com 3 fotos, com uma foto excluída e sem fotos | R2, R6, R7 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/marketplace/listings/listings.types.ts` | `photos` e `card` | R2, R6 |
| `components/ListingPhotoGallery/` | destaque, miniaturas com a marcada, setas e botão ampliar, frames `1112-5772` e `1112-6152` (setas e ampliar sem desenho, no estilo da tela) | R2–R6, R8 |
| `components/ListingPhotoViewer/` | foto ampliada sobre o `OverlayDialog`, com setas e fechar | R5 |
| `hooks/usePhotoNavigation.ts` | índice atual, próxima e anterior | R3, R4 |
| `pages/ListingDetailPage/` (CCD079) | troca a imagem fixa pela galeria | R1, R2 |

- **Componentes reaproveitados:** `OverlayDialog`, `Icon`, `Button`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 3 fotos por `sort_order`, sem login | `listings.service.spec.ts` · `tests/integration/listings.spec.ts` · `ListingPhotoGallery.spec.tsx` |
| CA2 | terceira miniatura em destaque e marcada | `ListingPhotoGallery.spec.tsx` |
| CA3 | seta para a frente | `usePhotoNavigation.spec.ts` |
| CA4 | ampliar e fechar | `ListingPhotoViewer.spec.tsx` |
| CA5 | sem fotos: imagem da carta | service · `ListingPhotoGallery.spec.tsx` |
| CA6 | foto excluída não vem | integração |
| CA7 | foto que não carrega mantém o tamanho | `ListingPhotoGallery.spec.tsx` (evento `error`) · validação no navegador |
| CA8, CA9 | print em 1280 px igual aos frames `1112-5772` e `1112-6152`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- As fotos vêm no mesmo `GET /listings/:id`, sem endpoint próprio: a página faz uma chamada só, como a CCD079 combinou.
