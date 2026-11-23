# Plano — CCD041 Silenciar Notificações de Grupo

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (lacunas L1–L11 pendentes)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O sino do topo do chat (`675-14037`) abre o modal "Silenciar grupo" (`675-15445`); escolher o período chama
`PUT /groups/:id/mute`, que grava `group_members.muted_until`. Enquanto `muted_until` estiver no futuro, o aviso de
mensagem nova da CCD044 não é criado para esse membro; passado o prazo, volta sozinho, sem job. O grupo silenciado mostra
o sino cortado no topo do chat e no cartão do grupo, e o sino abre "Reativar Notificações", que chama
`DELETE /groups/:id/mute`.

## Dependências

- CCD039: `group-access.ts` e o `upsert` de entrada (L11: zerar o silêncio ao restaurar) e o `GroupCard`.
- CCD044: `GET /groups/:id`, o `GroupChatHeader` e o `notifyGroupMessage`, onde entra o filtro de silêncio.
- CCD053: preferência geral "grupos" (L8); até ela existir, só o silêncio do grupo vale.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `group_members` | sim (`muted_until`) | — | gravado e limpo |
| `notifications` | sim | — | deixa de ser criado para o silenciado |

## Regras

- **Períodos:** `EIGHT_HOURS` (agora + 8 h), `ONE_WEEK` (agora + 7 dias) e `UNTIL_REACTIVATED`; `ONE_HOUR` só se a L1
  aprovar (depende da L1).
- **"Até eu reativar":** `muted_until = 9999-12-31T23:59:59Z`, sem coluna nova (depende da L2; vira ADR `Proposto`).
- **Silenciado:** `muted_until > now()`; o cálculo usa o relógio injetado (`now`) do service.
- **O que pausa:** só o aviso no sino (`notifications`) desse grupo; e-mail do tipo "grupos" também, quando a CCD053
  existir (depende da L5, L8). As mensagens continuam chegando no chat.
- **Reentrada:** restaurar a linha zera `muted_until` (depende da L11).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.
Acesso: `authenticate` + `authorize('CUSTOMER', 'SELLER')` + membro (`403 NOT_GROUP_MEMBER`); grupo excluído
`404 GROUP_NOT_FOUND`.

| Método e caminho | Entrada | Sucesso | Erros próprios | Requisitos |
|---|---|---|---|---|
| `PUT /api/v1/groups/:id/mute` | `{ period: 'EIGHT_HOURS' \| 'ONE_WEEK' \| 'UNTIL_REACTIVATED' }` | `200` `{ data: { mutedUntil, untilReactivated } }` | `400 VALIDATION_ERROR` | R1, R3, R4 |
| `DELETE /api/v1/groups/:id/mute` | — | `204` | — | R1, R8 |
| `GET /api/v1/groups/:id` (CCD044) e `GET /api/v1/groups` (CCD039) | — | cada grupo ganha `mutedUntil` (nulo se não silenciado ou já vencido) e `untilReactivated` | — | R6, R7 |

## Backend — `apps/cromocard-backend`

Domínio `src/domains/community/groups/` (CCD039) e o aviso da CCD044.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `group-mute.validator.ts` · `group-mute.ts` | períodos e o cálculo do `muted_until` (data distante para "até eu reativar") | R3, R4 |
| `groups.repository.ts` · `groups.service.ts` | `mute`, `unmute`; `mutedUntil` na lista e no cabeçalho; zera no `upsert` de entrada | R4, R6–R8 |
| `groups.controller.ts` · `.routes.ts` · `.swagger.ts` | as duas rotas | R1 |
| `community/group-messages/group-messages.repository.ts` · `notifications.service.ts` | destinatários do aviso só com `muted_until` nulo ou vencido | R5, R6 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `features/community/groups/group-mute.api.ts` · `.queries.ts` · `.labels.ts` | silenciar, reativar e rótulos dos períodos | R3, R4, R8 |
| `features/community/groups/components/MuteGroupDialog/` | modal do frame `675-15445`: "Silenciar por" com os períodos, botão que muda com o período (depende da L9), "Cancelar" e "✕" (depende da L10); sem "Mesmo silenciado, me avise sobre" (L3) e sem a média de mensagens (L4) | R2–R4, R9 |
| `features/community/groups/components/UnmuteGroupDialog/` | "Reativar Notificações" no estilo do `675-15445` (sem frame, L7) | R8 |
| `features/community/chat/components/GroupChatHeader/` (CCD044) | sino normal ou cortado (frame `675-14037`, L6); abre o modal certo | R2, R7, R8, R9 |
| `features/community/groups/components/GroupCard/` (CCD039) | sino cortado no grupo silenciado, como o cartão "Figurinhas Panini" do `417-2915` | R7, R9 |

- **Componentes reaproveitados de `src/components/`:** `OverlayDialog`, `Button`, `Icon`, `Toast`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 8 horas grava agora + 8 h, o indicador aparece e a mensagem nova não gera aviso | `groups.service.spec.ts` · `notifications.service.spec.ts` · `tests/integration/group-mute.spec.ts` · `MuteGroupDialog.spec.tsx` |
| CA2 | 1 semana grava agora + 7 dias; "até eu reativar" grava a data distante | `group-mute.spec.ts` (unitário) |
| CA3 | com o relógio depois do prazo, o aviso volta e `mutedUntil` vem nulo | `groups.service.spec.ts` · `notifications.service.spec.ts` |
| CA4 | reativar zera `muted_until` e a próxima mensagem gera aviso | integração · `UnmuteGroupDialog.spec.tsx` |
| CA5 | `401` sem token, `403` para não membro | integração |
| CA6–CA8 | print em 1280 px igual aos frames `675-15445`, `675-14037` e `417-2915`; 375/768/1024 px sem quebra | revisão visual (`/cromocard-revisor`) |

Cobertura de 90% nos arquivos alterados (ADR-060).

## Dependências e riscos

- "Até eu reativar" com data distante (L2) precisa do ADR `Proposto` antes do código.
- O cartão silenciado do CA8 fica na seção "Meus grupos", que depende da L3 da CCD039; sem ela, o indicador aparece no
  cartão da lista de "Comunidades".
- "Mesmo silenciado, me avise sobre" (L3) exige PR de docs no DBML e menções, que não existem.

## Decisões técnicas

- Sem job de expiração: o silêncio vale pela comparação `muted_until > now()` em cada aviso e em cada leitura, e some
  sozinho (R6).
- O filtro do silêncio fica na consulta de destinatários do aviso, para um grupo grande não carregar os membros na memória.
- **ADR novo `Proposto`:** representar "até eu reativar" com `muted_until = 9999-12-31T23:59:59Z` (L2).
