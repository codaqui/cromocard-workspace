# Plano — CCD083 Denunciar Vendedor

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.
>
> **Fase MVP** desde 22/11/2026 (ADR-068).

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L9 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

No perfil público de um vendedor (`1160-1396`), "⚑ Denunciar perfil" abre o `ReportDialog` "Denunciar @<usuário>"
(`1160-17495`). O envio usa o endpoint único `POST /api/v1/reports` (CCD090) com `targetType = SELLER` e o `targetId` do
vendedor; a API grava em `reports` com `target_user_id` e `status = PENDING`, o modal fecha e a tela avisa o sucesso. O
administrador vê as denúncias de vendedor em `GET /api/v1/admin/moderation/reports?targetType=SELLER` (depende da L6).

## Dependências

- **CCD090 (ou CCD050)**: cria `src/domains/moderation/`, `POST /reports`, a estratégia por `targetType` e o
  `ReportDialog`. Esta story acrescenta o alvo `SELLER` e a lista do administrador.
- **CCD080**: cria o perfil público `/usuarios/:id`.
- **L1** decide se o modal do perfil grava `SELLER` (vendedor) ou `PROFILE` (CCD050); o plano segue a proposta: `SELLER`
  quando o denunciado tem `role = SELLER` (depende da L1).
- `reports` e o enum com `SELLER` já estão no `schema.prisma`.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `reports` | sim (`Report`) | — | grava `target_type = SELLER`, `target_user_id`, `reason`, `description`, `status = PENDING` (R6) |
| `users` | sim | — | `id`, `username`, `role`, `deleted_at` do denunciado (CA5) |

Nenhuma coluna nova.

## Regras

- **Motivo** (R3, R4): obrigatório, até 90 caracteres; os do Figma ("Perfil falso ou bot", "Tentativa de golpe",
  "Conteúdo ofensivo no perfil", "Outro motivo") até a L3 decidir.
- **Detalhes** (R5): opcionais, até 500 caracteres (depende da L4).
- **Alvo** (R6): usuário inexistente ou excluído responde `404` (CA5); a opção não aparece no próprio perfil e a API
  responde `422 CANNOT_REPORT_SELF`; denúncia repetida aberta responde `409` (depende da L8).
- **Cancelar** (R9): "Cancelar" e "✕" fecham o modal sem requisição.
- **Visitante**: a opção abre "Entre para continuar" (depende da L7); a API responde `401` (R1).
- **Painel de moderação** (R7): lista as denúncias `SELLER` com vendedor, motivo, descrição, quem denunciou e quando
  (depende da L6).

## Contrato da API

Convenções do ADR-011.

### `POST /api/v1/reports` — R1, R4–R6, R8

- **Acesso:** autenticado.
- **Corpo:** `{ "targetType": "SELLER", "targetId": "uuid", "reason": "Tentativa de golpe", "description": "…" }`
- **Sucesso:** `201` `{ "data": { "id": "uuid", "targetType": "SELLER", "status": "PENDING", "createdAt": "…" } }`
- **Erros:** `400 VALIDATION_ERROR` (sem `reason`, R4) · `401 UNAUTHORIZED` (R1) · `404 REPORT_TARGET_NOT_FOUND`
  (inexistente, excluído ou não vendedor, R6) · `409 REPORT_ALREADY_OPEN` (depende da L8) · `422 CANNOT_REPORT_SELF`
  (depende da L8).

### `GET /api/v1/admin/moderation/reports` — R7 (depende da L6)

- **Acesso:** `ADMIN`.
- **Entrada:** `targetType=SELLER`, `status` (opcional), `page`, `pageSize` (padrão 20).
- **Sucesso:** `200` `{ data: [ { id, reason, description, status, createdAt, reporter: { id, username },
  target: { id, username } } ], meta: { page, pageSize, total } }`
- **Erros:** `400 VALIDATION_ERROR` · `401 UNAUTHORIZED` · `403 FORBIDDEN` — R7.

## Backend — `apps/cromocard-backend`

No domínio `src/domains/moderation/` (CCD090).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `moderation.validator.ts` | ramo `SELLER` (`description` opcional); `adminReportsQuery` | R4, R5, R7 |
| `report-targets.ts` | estratégia `SELLER`: confere usuário não excluído com `role = SELLER` (depende da L1), monta `targetUserId` | R6 |
| `moderation.repository.ts` | `findReportsPage` (filtro por `targetType`, com reporter e alvo só com `username`) | R7 |
| `moderation.service.ts` + `moderation.service.spec.ts` | casos `SELLER` e a lista do administrador | R6, R7 |
| `moderation-admin.routes.ts` · `moderation.controller.ts` · `moderation.swagger.ts` · `moderation.module.ts` | `GET /admin/moderation/reports` com `authenticate` + `authorize('ADMIN')`, no `/docs` | R7 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/moderation/moderation.labels.ts` | motivos e textos do Figma, aviso de sigilo (depende da L5), sucesso e erro (L9) | R3–R5, R8 |
| `src/features/moderation/components/ReportProfileButton/` (CCD090) | aparece para qualquer cliente logado no perfil de vendedor, some no próprio perfil (L8), frame `1160-1396` | R2, R10 |
| `src/features/moderation/components/ReportDialog/` (CCD090) | "Denunciar @<usuário>", motivos, "Detalhes (opcional)", "Cancelar", "✕", "Enviar denúncia", frame `1160-17495` | R3–R5, R8–R10 |
| `src/features/moderation/admin/` (página, tabela e query) | lista de denúncias de vendedor no BackOffice, no estilo da fila da CCD062 até haver frame (depende da L6) | R7 |
| `src/routes/paths.ts` · `src/app/router.tsx` | rota do BackOffice da lista (depende da L6) | R7 |

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | `201`, linha `SELLER` com `target_user_id`, `reporter_id`, `PENDING`; modal fecha e sucesso aparece | `moderation.service.spec.ts` · `tests/integration/reports.spec.ts` · `ReportDialog.spec.tsx` |
| CA2 | "Cancelar" e "✕": nenhuma requisição | `ReportDialog.spec.tsx` |
| CA3 | sem motivo: nada enviado; API `400` sem gravar | `ReportDialog.spec.tsx` · `tests/integration/reports.spec.ts` |
| CA4 | sem token: `401` | `tests/integration/reports.spec.ts` |
| CA5 | inexistente ou excluído: `404` | `moderation.service.spec.ts` · `tests/integration/reports.spec.ts` |
| CA6 | o administrador vê a denúncia com vendedor, motivo, descrição, quem e quando | `tests/integration/admin-moderation-reports.spec.ts` · teste da página do BackOffice |
| CA7, CA8 | print em 1280 px igual aos frames `1160-1396` e `1160-17495`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

Cobertura mínima de 90% nos arquivos alterados (ADR-060).

## Decisões técnicas

- Reaproveita o endpoint único e o `ReportDialog` da CCD090 (ADR `Proposto` registrado lá).
- A lista do administrador fica em `/admin/moderation/reports`, separada de `/admin/reports` (relatórios gerenciais) e da
  fila de mensagens de grupo da CCD062; se a L6 decidir unificar com a CCD062, o plano muda antes do código.
