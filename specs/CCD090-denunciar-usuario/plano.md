# Plano — CCD090 Denunciar Usuário

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L10 pendentes; a fase depende da L1)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O vendedor denuncia um usuário por dois caminhos: o modal "⚑ Denunciar perfil" do perfil público (`1160-17495`) e a
opção "Somente denunciar" do modal "Bloquear ou denunciar" da conversa (`1160-34298`). Os dois chamam
`POST /api/v1/reports` com `targetType = USER`, o `targetId` do usuário, a categoria (`reason`) e a observação
(`description`, obrigatória nesta story). A API grava em `reports` com `status = PENDING` e a tela mostra a confirmação.

Esta é a story que cria a base das denúncias do usuário final (endpoint único `POST /reports`, domínio
`src/domains/moderation/` e o `ReportDialog` do frontend), reaproveitada pela CCD050, CCD082 e CCD083, cada uma com a sua
regra de alvo. Se a CCD050 (Denunciar Perfil, MVP) for implementada antes, ela cria a base e esta só acrescenta o alvo
`USER`.

## Dependências

- **CCD080**: cria o perfil público (`/usuarios/:id`, frame `1160-1396`), onde fica "⚑ Denunciar perfil".
- **CCD047 (Moderar Contatos Privados)** e o chat pessoal: criam a conversa e o modal "Bloquear ou denunciar"
  (`1160-34298`); `conversations` e `conversation_participants` ainda não estão no `schema.prisma`. O caminho pela
  conversa (R2) só fecha quando eles existirem; o caminho pelo perfil não depende deles.
- `reports` e o enum `report_target_type` (com `USER`) já estão no `schema.prisma`.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `reports` | sim (`Report`) | — | grava `reporter_id`, `target_user_id`, `target_type = USER`, `reason`, `description`, `status = PENDING` (R5) |
| `users` | sim | — | o denunciado existe e não está excluído (CA6) |

Nenhuma coluna nova. "Anexar as últimas 20 mensagens" fica fora até a L6 (o DBML não tem a coluna).

## Regras

- **Quem denuncia** (R1): papel `SELLER` (depende da L3; a proposta abre para `CUSTOMER` também, e aí o `authorize` muda).
- **Categoria** (R3, R8): obrigatória, até 90 caracteres, de uma lista fixa no frontend (depende da L5).
- **Observação** (R4, R7): obrigatória para `USER`, até 500 caracteres (depende da L4).
- **Alvo**: usuário inexistente ou excluído responde `404` (CA6); denunciar a si mesmo responde `422` e denúncia repetida
  do mesmo alvo ainda `PENDING` ou `UNDER_REVIEW` responde `409` (depende da L9).
- **Tipo do alvo**: o modal da conversa grava `USER`; o do perfil grava `USER` nesta story até a L2 decidir entre `USER`,
  `PROFILE` e `SELLER` (depende da L2).

## Contrato da API

Convenções do ADR-011.

### `POST /api/v1/reports` — R1, R3–R8

- **Acesso:** autenticado; para `targetType = USER`, papel `SELLER` (depende da L3).
- **Corpo:**

  ```json
  { "targetType": "USER", "targetId": "uuid", "reason": "Spam", "description": "Mandou o mesmo link 10 vezes" }
  ```

- **Sucesso:** `201` `{ "data": { "id": "uuid", "targetType": "USER", "status": "PENDING", "createdAt": "…" } }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | sem `reason` ou sem `description` (para `USER`), tamanho acima do limite, `targetId` não é uuid | R7, R8 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel diferente de `SELLER` (depende da L3) | R1 |
  | 404 | `REPORT_TARGET_NOT_FOUND` | usuário inexistente ou excluído | R5 |
  | 409 | `REPORT_ALREADY_OPEN` | denúncia do mesmo alvo ainda aberta (depende da L9) | R5 |
  | 422 | `CANNOT_REPORT_SELF` | o alvo é o próprio usuário (depende da L9) | R5 |

## Backend — `apps/cromocard-backend`

Domínio novo `src/domains/moderation/` (o nome evita confusão com `admin/reports`, que são os relatórios gerenciais), no
modelo de `src/domains/users/` (ADR-004), registrado em `src/routes.ts`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `moderation.validator.ts` | `createReportBody` (Zod, união discriminada por `targetType`; `USER` exige `description`) | R3, R4, R7, R8 |
| `moderation.errors.ts` | `ReportTargetNotFoundError`, `ReportAlreadyOpenError`, `CannotReportSelfError` | R5 |
| `report-targets.ts` | estratégia por `targetType` (Strategy): `USER` confere o usuário, monta `targetUserId` e diz o papel exigido | R1, R5 |
| `moderation.repository.ts` | `createReport`, `hasOpenReport` (status `PENDING`/`UNDER_REVIEW`, reaproveitando `OPEN_REPORT_STATUSES` da CCD062) | R5 |
| `moderation.service.ts` + `moderation.service.spec.ts` | regras de alvo, papel, duplicata e auto-denúncia | R1, R5 |
| `moderation.controller.ts` · `moderation.routes.ts` · `moderation.swagger.ts` · `moderation.module.ts` | `POST /reports` com `authenticate`, no `/docs` | R1, R5 |
| `src/routes.ts` | registra o `moderationModule` | R5 |

## Frontend — `apps/cromocard-frontend`

Feature nova `src/features/moderation/`, no modelo de `src/features/users/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `moderation.types.ts` · `moderation.api.ts` · `moderation.queries.ts` · `moderation.labels.ts` | contrato, mutation e textos (categorias da L5, alerta da L4, confirmação da L10) | R3–R8 |
| `components/ReportDialog/` | modal "Denunciar @<usuário>" com motivos, "Detalhes", "Cancelar" e "Enviar denúncia", erros no campo com `FormError`, frame `1160-17495` | R3, R4, R7–R9 |
| `components/ReportProfileButton/` | "⚑ Denunciar perfil" no perfil público, só para o vendedor logado (depende da L3), frame `1160-1396` | R2, R9 |
| `src/features/profiles/pages/PublicProfilePage/` (CCD080) | inclui o botão e o modal | R2 |
| modal "Bloquear ou denunciar" da conversa (CCD047) | a opção "Somente denunciar" chama a mutation com `targetType = USER`, frame `1160-34298` | R2–R5, R9 |
| `Toast` | confirmação de que a moderação vai analisar o caso | R6 |

- **Componentes reaproveitados de `src/components/`:** `Modal`, `Select` ou lista de opções, `Textarea`, `FormField`,
  `FormError`, `Button`, `Toast`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | pela conversa: `201`, linha `USER` com `target_user_id`, `reporter_id`, `PENDING`; confirmação | `moderation.service.spec.ts` · `tests/integration/reports.spec.ts` · teste do modal da conversa |
| CA2 | pelo perfil: o mesmo registro | `ReportDialog.spec.tsx` · `PublicProfilePage.spec.tsx` |
| CA3 | sem observação: nada enviado, alerta na tela; API `400` sem gravar | `ReportDialog.spec.tsx` · `tests/integration/reports.spec.ts` |
| CA4 | sem categoria: nada enviado; API `400` | `ReportDialog.spec.tsx` · `tests/integration/reports.spec.ts` |
| CA5 | sem token `401`; `CUSTOMER` `403` | `tests/integration/reports.spec.ts` |
| CA6 | usuário inexistente ou excluído: `404` sem gravar | `moderation.service.spec.ts` · `tests/integration/reports.spec.ts` |
| CA7–CA9 | print em 1280 px igual aos frames `1160-34298`, `1160-1396` e `1160-17495`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

Cobertura mínima de 90% nos arquivos alterados (ADR-060).

## Decisões técnicas

- **Endpoint único `POST /api/v1/reports`** com `targetType` e `targetId`, e uma estratégia por tipo de alvo no service,
  em vez de uma rota por recurso (`/listings/:id/reports`, `/users/:id/reports`): as cinco stories de denúncia (CCD047,
  CCD050, CCD082, CCD083, CCD090) gravam a mesma tabela polimórfica (ADR-032) e usam o mesmo modal. Nenhum ADR cobre a
  forma da rota: vira **ADR novo `Proposto`** antes do código (tarefa T1).
- O `ReportDialog` é um componente só, parametrizado pelos motivos e pela obrigatoriedade dos detalhes, porque o Figma usa
  o mesmo modal no perfil e o da conversa só muda as opções.
