# Plano — CCD052 Exclusão da Conta

Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (feito sobre a spec em Rascunho)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade
- **Código lido:** branch `feature/336-remove-tipo-categoria` dos dois apps. Já existem `DELETE /users/me` (soft delete sem
  confirmação e sem revogar sessões), `authRepository.revokeAllRefreshTokens`, o login que responde `403 ACCOUNT_DELETED`
  (CCD004), o `INVALID_CREDENTIALS` e, no frontend, `DeleteAccountSection` na `ProfilePage` e o `LoginPanel` que já trata o
  `ACCOUNT_DELETED`. Não existe `POST /auth/restore`.

## Solução

Em "Configurações" (CCD051), o bloco "Excluir conta" abre o modal "Excluir sua conta?". O botão "Confirmar Exclusão da
Conta" só libera com a confirmação de segurança e a caixa "Entendi o que acontece com a minha conta.". O
`DELETE /users/me` passa a exigir a confirmação, preenche `users.deleted_at` e revoga todos os refresh tokens numa
transação; o frontend encerra a sessão e volta ao login. No login de conta excluída, a mensagem da CCD004 ganha "Reativar
conta", que chama `POST /auth/restore` com as mesmas credenciais e limpa o `deleted_at`.

## Dependências

- **CCD051:** a página "Configurações", onde entra o bloco (a `DeleteAccountSection` sai da `ProfilePage`, CCD048).
- **CCD004:** o login, o `403 ACCOUNT_DELETED` e o `LoginPanel` (frame `1160-561`).
- **CCD051:** o erro `CURRENT_PASSWORD_INCORRECT` (`422`), reaproveitado na confirmação por senha.
- **Consultas públicas** (perfil `/profiles/:username` da CCD049/CCD050/CCD080, anúncios do marketplace): filtram o dono
  excluído (R6). Hoje só a `/profiles` está planejada; os anúncios aplicam o filtro quando existirem.

## Dados

Nenhuma migration.

| Tabela | Colunas | Uso | Requisitos |
|---|---|---|---|
| `users` | `deleted_at`, `password_hash`, `oauth_provider` | excluir e reativar; confirmação por senha ou "EXCLUIR" (conta Google) | R4, R5, R10 |
| `refresh_tokens` | `revoked_at` | todas revogadas na exclusão | R5 |

## Regras

- **Confirmação** (depende da L2): conta com senha confirma com `password` (comparada com o hash); conta só Google confirma
  com `confirmation = "EXCLUIR"`. Sem confirmação ou texto errado: `400 CONFIRMATION_REQUIRED`; senha errada:
  `422 CURRENT_PASSWORD_INCORRECT` (R7). A caixa "Entendi…" é só da tela (libera o botão).
- **Excluir:** numa transação, `users.deleted_at = now()` e `revokeAllRefreshTokens` (R5). Pedidos, anúncios, grupos e
  mensagens não mudam (depende da L4, sem proposta; o plano não bloqueia a exclusão).
- **Depois:** o frontend limpa a sessão (ADR-043) e vai para o login com um aviso (depende da L5).
- **Público:** as consultas públicas filtram `users.deleted_at` nulo do dono (R6, ADR-015 item 8).
- **Reativar:** `POST /auth/restore` confere e-mail e senha da conta excluída, limpa `deleted_at` e responde como o login
  (tokens), para a pessoa já entrar (depende da L7). Conta ativa: `409 ACCOUNT_NOT_DELETED`. Conta só Google reativa só
  depois da L7.
- **Auditoria:** a exclusão pelo próprio usuário não grava `audit_logs` (ADR-034 cobre ações administrativas; L8).
- **Papéis:** `CUSTOMER` e `SELLER`; o `ADMIN` recebe `403` (depende da L6).

## Contrato da API

### `DELETE /api/v1/users/me` (já existe, muda) — R1, R4, R5, R7

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (L6)
- **Entrada:** `{ "password": "string" }` ou `{ "confirmation": "EXCLUIR" }` (conta só Google)
- **Sucesso:** `204`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `CONFIRMATION_REQUIRED` | sem `password` nem `confirmation`, ou texto diferente de "EXCLUIR" | R7 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | `ADMIN` (L6) | R1 |
  | 422 | `CURRENT_PASSWORD_INCORRECT` | senha não confere | R7 |

### `POST /api/v1/auth/restore` — R9, R10

- **Acesso:** público, com o `rateLimitRequests(loginLimit)` do login
- **Entrada:** `{ "email": "string", "password": "string" }`
- **Sucesso:** `200` com o mesmo corpo e o mesmo cookie de refresh do `POST /auth/login` (CCD004)
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | e-mail ou senha ausentes | R10 |
  | 401 | `INVALID_CREDENTIALS` | e-mail ou senha não conferem | R10 |
  | 409 | `ACCOUNT_NOT_DELETED` | a conta não está excluída | R10 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/users/users.validator.ts` | `deleteMeSchema` (`password` ou `confirmation: 'EXCLUIR'`) | R4, R7 |
| `src/domains/users/users.errors.ts` | `ConfirmationRequiredError` (`400`) | R7 |
| `src/domains/users/users.service.ts` + `users.service.spec.ts` | `deleteOwnAccount`: confere a confirmação, `softDelete` e revoga as sessões na transação (pelo `authService.revokeAllSessions` injetado) | R4, R5, R7 |
| `src/domains/users/users.controller.ts` · `users.routes.ts` · `users.swagger.ts` | `DELETE /me` com o corpo e o `authorize` | R1 |
| `src/domains/auth/auth.validator.ts` · `auth.errors.ts` | `restoreSchema`; `AccountNotDeletedError` (`409`) | R10 |
| `src/domains/auth/auth.repository.ts` · `auth.service.ts` + `auth.service.spec.ts` | `restore`: confere a senha da conta excluída, limpa `deleted_at` e emite os tokens como o login | R10 |
| `src/domains/auth/auth.controller.ts` · `auth.routes.ts` · `auth.swagger.ts` | `POST /restore` | R10 |
| `src/domains/users/profiles/profiles.repository.ts` (CCD049) | o filtro do dono excluído coberto por teste | R6 |
| `tests/integration/users.spec.ts` · `auth.spec.ts` | exclusão, refresh recusado depois, restore, perfil público sumido | R1, R5–R7, R10 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `features/users/users.types.ts` · `users.schemas.ts` · `users.labels.ts` | entrada da exclusão; textos do bloco, do modal e do aviso de confirmação (L3 para os textos do Figma) | R2–R4, R7 |
| `features/users/users.api.ts` · `users.queries.ts` | `deleteMe` com o corpo; ao concluir, encerra a sessão | R5 |
| `features/users/components/DeleteAccountSection/` (já existe) | vira o bloco "Excluir conta" com o texto e "Excluir minha conta" — frame `1160-41305` | R2 |
| `features/users/components/DeleteAccountDialog/` | "Excluir sua conta?", as consequências, o campo "digite EXCLUIR ou insira sua senha atual" (L2), a caixa "Entendi…", o botão desabilitado até a confirmação, "Cancelar"/"✕" e o aviso de confirmação necessária — frame `1160-43273` | R3, R4, R7, R8 |
| `features/users/pages/SettingsPage/` (CCD051) · `pages/ProfilePage/` | monta o bloco em Configurações e o tira do Perfil | R2 |
| `features/auth/auth.api.ts` · `auth.queries.ts` | `restore` | R10 |
| `features/auth/components/LoginPanel/` | no `ACCOUNT_DELETED`, "Esta conta foi excluída. Quer voltar? Reativar conta." com o link que chama o `restore` e entra — frame `1160-561` | R9, R10 |

- **Reaproveitados:** `Modal`, `TextField`, `Checkbox`, `Button`, `FormError`, `Toast`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | `deleted_at` preenchido, todos os refresh tokens revogados, sessão encerrada | `users.service.spec.ts` · `users.spec.ts` · `DeleteAccountDialog.spec.tsx` |
| CA2 | botão desabilitado sem a confirmação e a caixa | `DeleteAccountDialog.spec.tsx` |
| CA3 | senha errada (`422`) ou texto diferente de "EXCLUIR" (`400`): conta ativa e o aviso | `users.service.spec.ts` · `users.spec.ts` · `DeleteAccountDialog.spec.tsx` |
| CA4 | "Cancelar" e "✕" não chamam a API | `DeleteAccountDialog.spec.tsx` |
| CA5 | perfil público da conta excluída responde `404` (anúncios quando existirem) | `users.spec.ts` · `achievements.spec.ts` |
| CA6 | login mostra "Reativar conta"; o `restore` limpa `deleted_at` | `auth.service.spec.ts` · `auth.spec.ts` · `LoginPanel.spec.tsx` |
| CA7 | `401` sem login | `users.spec.ts` |
| CA8 | refresh token anterior recusado em `POST /auth/refresh` | `auth.spec.ts` |
| CA9–CA11 | print em 1280 px igual aos frames `1160-41305`, `1160-43273` e `1160-561`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Dependências e riscos

- A spec R7 diz "`401` para senha errada": o plano usa `422 CURRENT_PASSWORD_INCORRECT`, porque o `http.ts` do frontend
  tenta renovar a sessão em todo `401`. Ajustar a R7 da spec na revisão.
- L1 (exclusão definitiva × ADR-015) não muda o plano: vale o ADR-015, aceito.
- L2 (confirmação), L4 (pedidos e anúncios em andamento), L5, L6 e L7 seguem a proposta ou ficam sem regra extra; a L4
  pode exigir bloquear a exclusão com pedido `PAID`/`SHIPPED`.
- L3: os textos do modal no Figma contrariam o ADR-015; até o Gabriel ajustar, a tela usa o texto da R3.
- O bloco depende da página de Configurações da CCD051.

## Decisões técnicas

- A exclusão continua no `DELETE /users/me` que já existe (com corpo, como o `DELETE /users/:id` do admin), em vez de uma
  rota nova.
- O `restore` responde como o login para a pessoa já entrar, sem um segundo envio de credenciais (até a L7 decidir).
