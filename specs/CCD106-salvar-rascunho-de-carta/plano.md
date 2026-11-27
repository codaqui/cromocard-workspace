# Plano — CCD106 Salvar Rascunho de Carta

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade · revisto em 2026-11-26 (dependência da CCD030)

## Solução

Migration com o ano (o `status` vem da CCD030); o catálogo (CCD061) aceita rascunho com validação mínima, publica com a validação completa, esconde rascunhos das consultas públicas e ganha verso padrão, aviso de duplicata e tamanho mínimo da imagem.

## Dependências

- CCD061 (catálogo e formulário de carta) e a fundação (`/uploads`).
- **CCD030 (Visualizar Detalhes, PR codaqui/cromocard-backend#47):** começar só depois do merge dela no `develop`. Ela já cria
  `cards.status` e o enum `card_status` (`DRAFT`, `ACTIVE`, padrão `ACTIVE`) na migration `add_status_to_cards_table`, e o
  perfil público da carta (`GET /cards/:id` e `GET /cards/:id/listings`) já responde `404` para carta `DRAFT`.

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `cards` | `add_release_year_to_cards_table` | `release_year`; o `status` e o enum `card_status` já existem (CCD030), sem migration nova | R2, R8 |
| `global_settings` | — (seed) | chave `catalog.default_backs` | R9 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `POST /api/v1/admin/catalog/cards` (CCD061) | acrescenta `status: DRAFT \| ACTIVE`, `releaseYear?` | `201` | `400` | R2, R8 |
| `POST /api/v1/admin/catalog/cards/:id/publish` | — | `200` | `400`, `404`, `409 ALREADY_PUBLISHED` | R5, R6 |
| `GET /api/v1/admin/catalog/cards` (CCD061) | acrescenta `status` | — | — | R4 |
| `GET /api/v1/admin/catalog/cards/duplicates` | `name`, `albumId?`, `number?` | `200` possíveis duplicatas | — | R10 |
| `POST /api/v1/uploads` (fundação) | acrescenta `minWidth`/`minHeight` para `cards` | `201` | `400 IMAGE_TOO_SMALL` | R11 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration · seed | `releaseYear` e verso padrão; `status`/`CardStatus` já vêm da CCD030 | R2, R8, R9 |
| `cards.validator.ts` · `catalog.service.ts` + `.spec.ts` | rascunho, publicar, verso padrão, duplicatas e auditoria | R2, R5, R6, R9, R10 |
| `catalog.repository.ts` (consultas públicas) | só `ACTIVE`; o perfil público da carta (`src/domains/catalog/cards/`, CCD030) já filtra e fica de fora | R3 |
| `uploads` (fundação) | tamanho mínimo para cartas | R11 |
| routes · swagger | rotas acima | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/catalog/` (api, queries, schemas) | rascunho, publicar e duplicatas | R2–R6, R10 |
| `CardForm` | "Salvar como Rascunho", publicar, ano, verso padrão e tamanho mínimo | R2, R5, R6, R8, R9, R11 |
| `CatalogPage` | filtro "Rascunhos", excluir rascunho e aviso de duplicata | R4, R7, R10 |

## Testes

| Critério | Onde |
|---|---|
| CA1, CA3, CA4, CA5, CA7 | `catalog.service.spec.ts` · `uploads` integração |
| CA2, CA6 | `CardForm.spec.tsx` · `CatalogPage.spec.tsx` |
| CA8 | integração |

## Decisões técnicas

- As consultas públicas do catálogo filtram `status = ACTIVE` no repository, num único ponto. O perfil público da carta
  já faz isso no `cards.repository.ts` da CCD030 (`publicWhere`): reaproveite a mesma regra em vez de duplicar.

## Revisão de 12/11/2026 (L5, L6)

- R5: publicar valida nome, franquia, raridade, idioma e imagem da frente (mesma regra da CCD061, L6).
- R4: o filtro de status da lista (`status=DRAFT`) mostra o selo "Rascunho" e esconde a ação duplicar.
- R7: excluir o rascunho passa pelo `DeleteCatalogItemDialog` da CCD061; CA9 no teste da página.
- R10: o aviso de duplicata tem o link "Ver carta existente".
- Telas novas: rascunhos `832-4379`, excluir rascunho `832-5330`, possível duplicata `832-7887` e erros de
  validação `832-7170`.
