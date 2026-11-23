# Plano — CCD082 Denunciar Anúncio

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.
>
> **Fase MVP** desde 22/11/2026 (telas completadas no Figma, ADR-069).

- **Spec:** [spec.md](spec.md), em Rascunho (L1, L2, L3 e L8 decididas em 22/11/2026; L4–L7 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O detalhe do anúncio ganha "⚑ Denunciar anúncio", que abre o `ReportDialog` com os motivos do anúncio e a observação
opcional. O envio usa o endpoint único `POST /api/v1/reports` (criado pela CCD090 ou pela CCD050) com
`targetType = LISTING` e o `targetId` do anúncio; a API grava em `reports` com `listing_id` e `status = PENDING`, o modal
fecha e a tela mostra a confirmação.

## Dependências

- **CCD090 (ou CCD050)**: cria o domínio `src/domains/moderation/`, o `POST /reports`, a estratégia por `targetType` e o
  `ReportDialog`. Esta story só acrescenta o alvo `LISTING`.
- **CCD079**: cria a página `/anuncios/:id` (frame `1112-5772`) e o `isOwner`.
- **CCD084/CCD097**: criam `listings`.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `reports` | sim (`Report`, com `listing_id` sem relação) | `add_reports_listing_fk` | a FK `reports.listing_id > listings.id` do DBML (`fk_reports_listing_id`) entra quando `listings` existir; grava `target_type = LISTING`, `listing_id`, `reason`, `description` (R6) |
| `listings` | não (CCD084/CCD097) | — | só leitura: `id`, `seller_id`, `deleted_at` (CA4) |

## Regras

- **Motivo** (R4, R8): obrigatório, até 90 caracteres, de uma lista fixa no frontend: Fraude ou tentativa de golpe, Item falso ou falsificado, Anúncio enganoso (fotos ou descrição) e Outro motivo (L2 decidida).
- **Observação** (R5): opcional, até 500 caracteres (L3 decidida).
- **Alvo**: anúncio inexistente ou excluído responde `404` (CA4); o dono não vê a opção e a API responde `422
  CANNOT_REPORT_OWN_LISTING` (depende da L6); denúncia repetida aberta responde `409` (depende da L7).
- **Visitante** (R1): a opção abre "Entre para continuar", como "Comprar" (depende da L5); a API responde `401`.

## Contrato da API

Convenções do ADR-011. Mesmo endpoint da CCD090; esta story acrescenta o alvo `LISTING`.

### `POST /api/v1/reports` — R1, R4–R8

- **Acesso:** autenticado, qualquer papel de cliente.
- **Corpo:** `{ "targetType": "LISTING", "targetId": "uuid", "reason": "Fraude ou tentativa de golpe", "description": "Foto de outro anúncio" }`
- **Sucesso:** `201` `{ "data": { "id": "uuid", "targetType": "LISTING", "status": "PENDING", "createdAt": "…" } }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | sem `reason`, tamanho acima do limite, `targetId` não é uuid | R8 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 404 | `REPORT_TARGET_NOT_FOUND` | anúncio inexistente ou excluído | R6 |
  | 409 | `REPORT_ALREADY_OPEN` | denúncia do mesmo anúncio ainda aberta (depende da L7) | R6 |
  | 422 | `CANNOT_REPORT_OWN_LISTING` | o cliente é o dono do anúncio (depende da L6) | R6 |

## Backend — `apps/cromocard-backend`

No domínio `src/domains/moderation/` (CCD090).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration `add_reports_listing_fk` | relação `Report.listing` ↔ `Listing.reports` | R6 |
| `moderation.validator.ts` | ramo `LISTING` da união (`description` opcional) | R4, R5, R8 |
| `report-targets.ts` | estratégia `LISTING`: confere o anúncio não excluído, bloqueia o dono, monta `listingId` | R6 |
| `moderation.errors.ts` | `CannotReportOwnListingError` | R6 |
| `moderation.service.spec.ts` | casos do alvo `LISTING` | R6 |
| `moderation.swagger.ts` | exemplo do alvo `LISTING` no `/docs` | R6 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/moderation/moderation.labels.ts` | motivos do anúncio (L2), confirmação "Denúncia enviada" e erro "Escolha um motivo para enviar a denúncia." (L8) | R4, R7, R8 |
| `src/features/moderation/components/ReportListingButton/` | "⚑ Denunciar anúncio" ao lado do vendedor no detalhe (`1112-5772`, `1112-6152`), escondido do dono (L6), "Entre para continuar" para o visitante (L5) | R1, R2, R9 |
| `src/features/moderation/components/ReportDialog/` (CCD090) | abre com os motivos do anúncio e a observação opcional; frames `1226-390`, `1226-683` e `1226-977` | R3–R5, R7–R9 |
| `src/features/marketplace/listings/pages/ListingDetailPage/` (CCD079) | inclui o botão e o modal | R2 |

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | `201`, linha `LISTING` com `listing_id`, `reporter_id`, `PENDING`; modal fecha e confirmação aparece | `moderation.service.spec.ts` · `tests/integration/reports.spec.ts` · `ReportListingButton.spec.tsx` |
| CA2 | sem motivo: nada enviado, campo destacado, modal aberto; API `400` sem gravar | `ReportDialog.spec.tsx` · `tests/integration/reports.spec.ts` |
| CA3 | sem token: `401` sem gravar | `tests/integration/reports.spec.ts` |
| CA4 | anúncio excluído: `404` sem gravar | `moderation.service.spec.ts` · `tests/integration/reports.spec.ts` |
| CA5, CA6 | print em 1280 px igual aos frames `1226-390`, `1226-683`, `1226-977` e `1112-5772`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

Cobertura mínima de 90% nos arquivos alterados (ADR-060).

## Decisões técnicas

- Reaproveita o endpoint único e o `ReportDialog` da CCD090 (ADR `Proposto` registrado lá); esta story só acrescenta a
  estratégia `LISTING`, sem rota nova.
- A FK de `reports.listing_id` já está no DBML e entra agora porque `listings` só passa a existir com a CCD084/CCD097.
