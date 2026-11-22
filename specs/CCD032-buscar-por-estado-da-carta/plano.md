# Plano — CCD032 Buscar por Estado da Carta

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

> Fase Futuro: implementar depois do MVP.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L5 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Pela proposta da L2, o filtro de estado de conservação é o filtro "Condição:" do Explorar marketplace, que a CCD078 já
entrega no MVP: `GET /api/v1/card-conditions` para as opções e `conditionId` em `GET /api/v1/listings` para filtrar
anúncios (depende da L3). O filtro fica aberto ao visitante, como o Explorar (depende da L4). Esta story não cria endpoint
nem tela: ela confere os critérios de aceite sobre o que a CCD078 entregou, desenha a lista aberta do filtro no estilo da
tela e ajusta a mensagem do vazio se a L5 decidir pelo texto do caso de uso. Se a L2 cancelar a story, as tarefas de
código saem e fica só a de documentação.

## Dependências

- **CCD078:** `GET /card-conditions`, `conditionId` em `GET /listings`, o `ListingFilters` e o vazio do Explorar.
- **CCD079:** detalhe do anúncio, aberto ao selecionar um item (R4, depende da L3).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `card_conditions` | não | da CCD084/CCD078 | só leitura: `name`, `sort_order` (R2, R6) |
| `listings` | não | da CCD097/CCD078 | só leitura: `condition_id` (R3) |

## Contrato da API

Nenhuma rota nova. Reaproveita, da CCD078:

| Método e caminho | Uso nesta story | Requisitos |
|---|---|---|
| `GET /api/v1/card-conditions` | opções na ordem de `sort_order` | R2, R6 |
| `GET /api/v1/listings?conditionId=<uuid>` | anúncios da condição escolhida; `400 VALIDATION_ERROR` se não for uuid | R3 |

- **Acesso:** público pela proposta da L4. Se a L4 decidir pelo caso de uso (login), `GET /listings` com `conditionId`
  passaria a exigir token só para esse filtro, o que quebraria o Explorar público: nesse caso o plano volta ao PO antes do
  código (R1, depende da L4).

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `tests/integration/listings-public.spec.ts` | casos da CCD032: só Near Mint, condição sem anúncio devolve lista vazia, opções na ordem | R2, R3, R5, R6 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/marketplace/listings/` (da CCD078).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `components/ListingFilters/` | a lista aberta de "Condição:" ("Todas", Mint, Near Mint, Ótimo, Bom, Regular), no estilo do `Select` da tela `1112-3281` (não desenhada) | R2, R6, R7 |
| `listings.labels.ts` | texto do vazio conforme a L5 ("Nenhum anúncio encontrado", do frame `1112-3674`, ou o do caso de uso) | R5 |

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | escolher Near Mint mostra só Near Mint | integração · `ListingFilters.spec.tsx` |
| CA2 | o item abre `/anuncios/:id` (depende da L3) | `ListingCard.spec.tsx` (da CCD078) |
| CA3 | Regular sem anúncio mostra o vazio da L5 | `ExploreMarketplacePage.spec.tsx` |
| CA4 | conforme a L4: sem token, `200` (proposta) | integração |
| CA5 | opções em Mint, Near Mint, Ótimo, Bom, Regular | integração · `ListingFilters.spec.tsx` |
| CA6–CA8 | print em 1280 px igual aos frames `1112-3281` e `1112-3674`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Dependências e riscos

- A user story #165 tem outro título no board (L1); corrigir o board é com o Daniel, fora deste plano.
- Com a L2 aprovada como proposta, a story é `Cancelada` e só a T4 (documentação) é feita.

## Decisões técnicas

- Nenhum endpoint paralelo: o estado de conservação é um filtro do Explorar, para não duplicar a listagem da CCD078.
