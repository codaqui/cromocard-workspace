# Plano — CCD054 Limpar Central de Notificações

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L7 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

A central da CCD053 ganha duas ações para a central inteira do usuário: "Marcar todas como lidas"
(`POST /api/v1/notifications/read-all`, `is_read = true`) e "Limpar notificações" (`DELETE /api/v1/notifications`,
`deleted_at = now()`), esta com confirmação. As duas atualizam o cache da lista e o contador de não lidas.

## Dependências

- **CCD053**: a página `/notificacoes`, o domínio `src/domains/notifications/` (repository, service, rotas) e o contador
  `meta.unreadCount`. Esta story sai da branch da CCD053 e entra depois dela.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `notifications` | sim | — | `is_read` (R8) e `deleted_at` (R4, soft delete, depende da L2) |

## Regras

- **Escopo** (R1): só as notificações do usuário do token, com `deleted_at` nulo; a central inteira, mesmo com filtro
  (depende da L7).
- **Limpar** (R4): `updateMany` com `user_id` e `deleted_at` nulo → `deleted_at = now()` (ADR-015, item 1; depende da L2).
- **Marcar todas** (R8): `updateMany` com `user_id`, `is_read = false` e `deleted_at` nulo → `is_read = true`.
- **Central vazia** (R7): o frontend não chama a API quando a lista tem `total = 0` e mostra o aviso; a API, chamada assim
  mesmo, responde `200` com `cleared: 0` e não grava nada.
- Depois de marcar todas, as lidas continuam na central, só sem o destaque (documentação; o que o `675-11716` faz com
  "HOJE" depende da L6). "Desfazer" (L4) e a seleção e exclusão individual (L5) ficam fora até a decisão.

## Contrato da API

Convenções do ADR-011.

### `POST /api/v1/notifications/read-all` — R1, R8

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (CCD053, L1)
- **Sucesso:** `200` `{ data: { updated: number } }`
- **Erros:** `401`, `403` — R1

### `DELETE /api/v1/notifications` — R1, R4, R7

- **Acesso:** igual ao anterior
- **Sucesso:** `200` `{ data: { cleared: number } }`
- **Erros:** `401`, `403` — R1

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `notifications.repository.ts` | `markAllAsRead(userId)`, `clearAll(userId)` | R4, R8 |
| `notifications.service.ts` + `.spec.ts` | as duas ações, só do usuário | R1, R4, R7, R8 |
| `notifications.controller.ts` · `.routes.ts` · `.swagger.ts` | as duas rotas | R1 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `notifications.api.ts` · `.queries.ts` | `markAllAsRead`, `clearAll` (mutations que invalidam a lista) | R4, R5, R8 |
| `components/MarkAllReadButton/` | botão "Marcar todas como lidas" do topo, aviso "<n> notificações marcadas como lidas" e o estado "Tudo em dia!" sem não lidas, frames `490-796` e `675-11716` | R8, R9 |
| `components/ClearNotificationsButton/` | "Limpar notificações" no estilo dos botões do topo, `ConfirmDialog`, aviso de central limpa e de central já vazia (textos dependem da L3) | R2, R3, R5–R7 |
| `pages/NotificationsPage/` (CCD053) | monta os dois botões; erro com `Toast` sem mudar a lista | R2, R5, R9 |

- **Componentes reaproveitados:** `Button`, `ConfirmDialog`, `Toast`, `EmptyState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 4 notificações com `deleted_at`, lista vazia, aviso de limpa | `notifications.service.spec.ts` · `tests/integration/notifications.spec.ts` · `ClearNotificationsButton.spec.tsx` |
| CA2 | cancelar não chama a API | `ClearNotificationsButton.spec.tsx` |
| CA3 | central vazia: aviso e nenhuma chamada | `ClearNotificationsButton.spec.tsx` · integração (`cleared: 0`) |
| CA4 | 5 não lidas passam a lidas, "0 Não Lidas" e "Tudo em dia!" | service · integração · `MarkAllReadButton.spec.tsx` |
| CA5 | `401` sem token; as de B não mudam quando A limpa ou marca | integração |
| CA6 | erro da API mantém a lista e mostra o aviso | `NotificationsPage.spec.tsx` |
| CA7–CA9 | print em 1280 px igual aos frames `490-796`, `675-11716` e `675-12111` (este depende da L5); sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- As duas ações são em lote, com um `updateMany` cada, sem ler as linhas antes: é uma escrita só e nunca toca nas
  notificações de outro usuário, porque o `user_id` está no `where`.
- `DELETE` na coleção (sem id) segue o ADR-011 para a remoção em lote do próprio recurso do usuário.
