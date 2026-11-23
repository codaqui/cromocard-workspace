# Plano — CCD050 Denunciar Perfil

Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (feito sobre a spec em Rascunho)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade
- **Código lido:** branch `feature/336-remove-tipo-categoria` dos dois apps (`Report` e o enum `ReportTargetType` com
  `PROFILE` já estão no `schema.prisma`; não há rota pública de perfil nem a página `/u/<usuário>`)

## Solução

No perfil público (CCD080), "⚑ Denunciar perfil" abre o modal "Denunciar @<usuário>". O usuário logado escolhe uma
categoria, escreve um detalhe opcional e envia; a API grava `reports` com `target_type = PROFILE`, `target_user_id` do dono
do perfil e `status = PENDING`, e a tela confirma. O visitante sem login que seleciona o link recebe o "Entre para
continuar" (proposta da L1).

## Dependências

- **CCD049:** o módulo público `src/domains/users/profiles/` (`/profiles`, `ProfileNotFoundError`). Se esta story vier
  antes, ela cria o módulo com o mesmo desenho.
- **CCD080 (EA-080-01):** a página pública `/u/<usuário>` (frame `1160-1396`), onde entra o link.
- **CCD004:** login e `authenticate`; o "Entre para continuar" da busca (frame `1160-2457`) para o visitante (L1).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação | Requisitos |
|---|---|---|---|---|
| `reports` | sim | — | `reporter_id`, `target_user_id`, `target_type = PROFILE`, `reason` (90), `description` (500), `status = PENDING` | R6 |
| `users` | sim | — | o dono do perfil pelo `username`, com `deleted_at` nulo | R9 |

Seed: nenhum novo (o tiago_trocas do seed da CCD049 serve aos CAs).

## Regras

- **Motivo:** um dos quatro textos ("Perfil falso ou bot", "Tentativa de golpe", "Conteúdo ofensivo no perfil", "Outro
  motivo"), gravado como está em `reports.reason` (depende da L5); "Outro motivo" não exige detalhe (L5).
- **Detalhe:** opcional, até 500 caracteres (R4).
- **Alvo:** sempre `PROFILE` nesta página, mesmo se o dono for vendedor (depende da L8).
- **A si mesmo:** `400 CANNOT_REPORT_SELF`, e o link não aparece para o dono (depende da L2).
- **Repetida:** cria outra denúncia (depende da L3, sem proposta; o plano não recusa).
- **Sigilo:** a resposta e nenhuma rota pública mostram o denunciante (L4).
- **Papéis:** `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` (depende da L9).

## Contrato da API

### `POST /api/v1/profiles/:username/reports` — R1, R3–R6, R9

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** `{ "reason": "Tentativa de golpe", "description": "string até 500" }`
- **Sucesso:** `201` `{ "data": { "id": "uuid", "status": "PENDING", "createdAt": "iso" } }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | sem `reason`, motivo fora da lista ou `description` > 500 | R4, R5 |
  | 400 | `CANNOT_REPORT_SELF` | o @ é do próprio usuário (L2) | R6 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 404 | `PROFILE_NOT_FOUND` | perfil inexistente ou conta excluída | R9 |

## Backend — `apps/cromocard-backend`

No módulo `src/domains/users/profiles/` (CCD049).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `profiles.validator.ts` | `reportProfileSchema` (motivos da L5, `description` até 500) | R3–R5 |
| `profiles.errors.ts` | `CannotReportSelfError` | R6 |
| `profiles.repository.ts` | `createProfileReport` (`target_type = PROFILE`, `status` default) | R6 |
| `profiles.service.ts` + `profiles.service.spec.ts` | `reportProfile`: dono ativo pelo @, a si mesmo, grava | R6, R9 |
| `profiles.controller.ts` · `profiles.routes.ts` · `profiles.swagger.ts` | `POST /:username/reports` com `authenticate` | R1 |
| `tests/integration/profiles-reports.spec.ts` | a rota com Supertest | R1, R4–R6, R9 |

## Frontend — `apps/cromocard-frontend`

Subpasta `src/features/users/profiles/` (a mesma da página pública da CCD080).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `profile-reports.types.ts` · `profile-reports.schemas.ts` · `profile-reports.labels.ts` | categorias, schema (motivo obrigatório, 500), textos do aviso e da confirmação (L6) | R3–R5, R7 |
| `profile-reports.api.ts` · `profile-reports.queries.ts` | `reportProfile` | R6 |
| `components/ReportProfileDialog/` | "Denunciar @<usuário>", categorias de escolha única, "DETALHES (OPCIONAL)", "Cancelar", "✕", "Enviar denúncia", aviso de motivo e a confirmação — frame `1160-17495` (texto de sigilo só com a L4) | R3–R5, R7, R8 |
| `components/ReportProfileLink/` | "⚑ Denunciar perfil"; visitante recebe o "Entre para continuar" (L1); escondido para o dono (L2) — frame `1160-1396` | R1, R2 |
| página pública da CCD080 | monta o link | R2 |

- **Reaproveitados:** `Modal`, `Textarea`, `Button`, `Toast`, `FormError` e o diálogo "Entre para continuar" já usado na busca.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | `reports` com `PROFILE`, o dono e `PENDING`; a confirmação na tela | `profiles.service.spec.ts` · `profiles-reports.spec.ts` · `ReportProfileDialog.spec.tsx` |
| CA2 | sem motivo: nada enviado, a tela pede o motivo; a API responde `400` | `profiles-reports.spec.ts` · `ReportProfileDialog.spec.tsx` |
| CA3 | detalhe > 500: `400`, nada gravado | `profiles-reports.spec.ts` |
| CA4 | "Cancelar" e "✕" não chamam a API | `ReportProfileDialog.spec.tsx` |
| CA5 | `401` sem login | `profiles-reports.spec.ts` · `ReportProfileLink.spec.tsx` |
| CA6 | conta excluída: `404` | `profiles.service.spec.ts` · `profiles-reports.spec.ts` |
| CA7, CA8 | print em 1280 px igual aos frames `1160-1396` e `1160-17495`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Dependências e riscos

- A tela depende da página pública da CCD080; o backend fecha sem ela.
- L7: nenhuma fila do BackOffice mostra denúncia de perfil (a CCD062 só trata `GROUP_MESSAGE`); a denúncia fica gravada
  até alguém planejar a análise.
- L1–L6, L8 e L9 seguem a proposta e podem mudar textos e regras.

## Decisões técnicas

- A rota fica no recurso do perfil (`/profiles/:username/reports`), porque a página só conhece o @; o id do dono não vai
  para o frontend só para isso.
