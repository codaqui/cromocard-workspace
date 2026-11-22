# Plano — CCD040 Denunciar Mensagem no Grupo

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (lacunas L1–L10 pendentes)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

No chat do grupo (CCD044), o menu de ações de cada mensagem de outro membro tem "Denunciar Mensagem", que abre o modal
do frame `675-14942`. Confirmar chama `POST /groups/:id/messages/:messageId/reports`, que grava `reports`
(`GROUP_MESSAGE`, `PENDING`) e avisa cada `ADMIN` do grupo numa transação; a denúncia aparece na fila de mensagens
denunciadas que a CCD062 já tem (`GET /admin/community/reports`). A tela confirma com um `Toast`.

## Dependências

- CCD039: `group-access.ts` (`assertMember`, administradores do grupo).
- CCD044: tela do grupo e `MessageBubble`, onde entra o menu de ações.
- CCD062 (no `develop`): fila `listGroupMessageReports` e a constante `REPORT_CATEGORIES` em
  `community-admin.validator.ts`, que hoje guarda o motivo como texto ("Spam/Golpe", "Discurso de ódio/Ameaça") e filtra
  a gravidade por ele.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `reports` | sim | — | `target_type = GROUP_MESSAGE`, só `group_message_id` preenchido (ADR-032) |
| `group_messages`, `group_members` | sim | — | mensagem, autor e administradores |
| `notifications` | sim | — | `type = GROUP_MESSAGE_REPORT`, `reference_link` para a mensagem no chat |

## Regras

- **Motivos:** códigos em inglês gravados em `reason`: `SCAM`, `SPAM`, `HARASSMENT`, `COUNTERFEIT`, `OTHER`, com os
  rótulos do frame (depende da L1). `OTHER` exige descrição (depende da L2).
- **Descrição:** opcional, até 500 caracteres, sem espaços nas pontas; vazia grava `null` (CA3).
- **Quem denuncia:** membro ativo do grupo da mensagem; não denuncia a própria mensagem nem a mesma duas vezes enquanto
  houver denúncia dele (depende da L8).
- **Mensagem:** não excluída e do grupo da rota; senão `404`.
- **Avisos:** um para cada `ADMIN` do grupo, sem o `reporter_id` no texto (depende da L4); a moderação da plataforma vê
  pela fila da CCD062, sem aviso próprio (depende da L7).
- **Fila da CCD062:** os códigos novos entram em `REPORT_CATEGORIES` com o rótulo, e a gravidade passa a usar os códigos
  (`CRITICAL`: `SCAM`, `HARASSMENT`; `SPAM`: `SPAM`); os motivos em texto do seed viram códigos.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.

### `POST /api/v1/groups/:id/messages/:messageId/reports` — R1, R4–R7

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` + membro
- **Entrada:**

  ```json
  { "reason": "SCAM", "description": "Pediu Pix fora da plataforma." }
  ```

- **Sucesso:** `201`

  ```json
  { "data": { "id": "uuid", "status": "PENDING", "createdAt": "2026-11-22T12:00:00Z" } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | sem motivo, motivo fora da lista, descrição acima de 500 ou `OTHER` sem descrição | R4 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `NOT_GROUP_MEMBER` | não é membro do grupo | R1 |
  | 404 | `GROUP_MESSAGE_NOT_FOUND` | mensagem inexistente, excluída ou de outro grupo | R5 |
  | 422 | `CANNOT_REPORT_OWN_MESSAGE` | mensagem do próprio autor (depende da L8) | R5 |
  | 409 | `ALREADY_REPORTED` | já denunciou essa mensagem (depende da L8) | R5 |

A CA2 da spec diz `422` para a descrição acima de 500; pelo ADR-011, validação de entrada é `400 VALIDATION_ERROR`, e o
plano segue o ADR.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/community/group-messages/` (da CCD044).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/community/group-message-report-reasons.ts` | códigos, rótulos e gravidade, usados pela denúncia e pela fila da CCD062 | R3, R7 |
| `group-message-reports.validator.ts` | `reportGroupMessageSchema` | R4 |
| `group-message-reports.repository.ts` | `create`, `existsByReporter`, administradores do grupo | R5, R6 |
| `group-message-reports.service.ts` | regras e aviso numa transação | R1, R5, R6 |
| `group-messages.controller.ts` · `.routes.ts` · `.swagger.ts` · `.errors.ts` | rota e erros novos | R1, R5 |
| `community/admin/community-admin.validator.ts` · `.repository.ts` | `REPORT_CATEGORIES` e `SEVERITY_CATEGORIES` a partir de `group-message-report-reasons.ts` | R7 |
| `database/seeds/data/reports.json` | motivos como código | R7 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/community/chat/` (da CCD044).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `group-message-reports.api.ts` · `.queries.ts` · `.labels.ts` · `.schemas.ts` | denúncia, rótulos dos motivos e validação | R3, R4 |
| `components/MessageActionsMenu/` | menu "⋯" do `MessageBubble` com "Denunciar Mensagem" só em mensagem de outro membro, no estilo do "ações da mensagem" do chat pessoal `1160-33616` (depende da L5) | R2 |
| `components/ReportMessageDialog/` | modal do frame `675-14942`: mensagem citada, motivos, descrição com contador, "Cancelar", "✕" e confirmar; sem "Ocultar esta mensagem para mim" (L3); aviso de anonimato só se a L4 aprovar | R3–R5, R9, R10 |
| `features/community/admin/community-admin.labels.ts` (CCD062) | rótulo dos códigos na fila | R7 |

- **Mensagens:** erro "motivo obrigatório" no campo (no estilo do frame, não desenhado); sucesso com `Toast`
  "Denúncia enviada" (depende da L6).
- **Componentes reaproveitados de `src/components/`:** `OverlayDialog`, `Textarea`, `FormError`, `Button`, `Toast`, `Icon`.
- Fora do frame até decisão: fila de denúncias do grupo `675-16922` e "Banir do grupo" (L9, L10).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | grava `reports` `GROUP_MESSAGE`/`PENDING` e avisa cada `ADMIN`; a tela confirma | `group-message-reports.service.spec.ts` · `tests/integration/group-message-reports.spec.ts` · `ReportMessageDialog.spec.tsx` |
| CA2 | sem motivo: erro no campo; descrição acima de 500: `400` | `group-message-reports.validator.spec.ts` · integração · `ReportMessageDialog.spec.tsx` |
| CA3 | sem descrição grava `null` | integração |
| CA4 | a denúncia aparece na fila da CCD062 com o rótulo do motivo | `tests/integration/community-admin.spec.ts` |
| CA5 | "Cancelar" e "✕" fecham sem chamar a API | `ReportMessageDialog.spec.tsx` |
| CA6 | `401` sem token, `403` para não membro | integração |
| CA7 | print em 1280 px igual ao frame `675-14942`; 375/768/1024 px sem quebra | revisão visual (`/cromocard-revisor`) |
| CA8 | não se aplica enquanto a L9 não aprovar a fila do grupo | — |

Cobertura de 90% nos arquivos alterados (ADR-060).

## Dependências e riscos

- Trocar o motivo de texto para código mexe na fila da CCD062 (gravidade e rótulo); as denúncias já gravadas em hml
  precisam de uma migration de dados que troque os dois textos atuais pelos códigos (`SPAM`, `HARASSMENT`).
- "Ocultar esta mensagem para mim" (L3) e a fila do grupo (L9) exigem PR de docs no DBML antes do código, se aceitos.

## Decisões técnicas

- A lista de motivos fica num arquivo só do domínio `community`, lido pela denúncia e pela moderação, para os rótulos e
  a gravidade não divergirem.
- A denúncia e os avisos aos administradores gravam numa transação (`runInTransaction`), como a CCD062.
