# Plano — CCD049 Exibir Vitrine de Conquistas

Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (feito sobre a spec em Rascunho)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade
- **Código lido:** branch `feature/336-remove-tipo-categoria` dos dois apps (`achievements` e `user_achievements` não estão
  no `schema.prisma`; não há rota pública de perfil nem página `/u/<usuário>` no frontend)

## Solução

As conquistas obtidas são as linhas ativas de `user_achievements` com a conquista ativa. A página "Perfil" (CCD048) mostra
a seção "🏅 Conquistas" com `GET /users/me/achievements`; o perfil público mostra a seção "Conquistas" com
`GET /profiles/:username/achievements`, sem login. Selecionar uma conquista abre os detalhes por
`GET /profiles/:username/achievements/:achievementId`, que responde `404` quando a conquista deixou de existir.

## Dependências

- **CCD048:** a página "Perfil" refeita, onde entra a seção (e a tabela `profiles`, não usada aqui).
- **CCD080 (EA-080-01):** a página pública `/u/<usuário>` (frame `1160-1396`), onde entra a seção pública. Sem ela, a seção
  pública fica pronta como componente e entra quando a página existir.
- **L1 (como se ganha):** nenhum caso de uso grava `user_achievements`; até a decisão, só o seed concede conquistas.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação | Requisitos |
|---|---|---|---|---|
| `achievements` | não | `create_achievements_table` | copiada do DBML (`name` único 90, `description` e `criteria` 255 obrigatórias, `icon_url` opcional) | R2, R4, R8 |
| `user_achievements` | não | `create_user_achievements_table` | PK `(user_id, achievement_id)`; `created_at` = quando foi obtida | R2 |

Seed (`database/seeds/achievements.seed.ts` + `data/achievements.json`): as 5 do Figma ("Primeiro álbum", "Álbum
completo", "100 cartas", "Primeiro grupo", "Veterano") com o `criteria` em texto (depende da L2); Gabriel e tiago_trocas com
3 cada, uma linha de `user_achievements` excluída (CA6) e um usuário sem conquistas (CA4). O ícone vai em `icon_url`
(depende da L5: se ficar emoji, muda a coluna no DBML antes).

## Regras

- **Obtidas:** `user_achievements.deleted_at` nulo e `achievements.deleted_at` nulo (R2).
- **Ordem:** a do seed, pela `achievements.created_at` (depende da L9).
- **Perfil público:** `users.username` existente e `users.deleted_at` nulo; senão `404 PROFILE_NOT_FOUND` (R9). Coleção
  privada não esconde as conquistas (depende da L8, sem proposta).
- **Detalhe:** nome, descrição, critério e a data em que foi obtida (depende da L6); conquista excluída ou não obtida pelo
  usuário: `404 ACHIEVEMENT_NOT_FOUND` (R8).

## Contrato da API

Convenções do ADR-011.

```ts
Achievement = { id, name, description, iconUrl: string | null, obtainedAt }
AchievementDetail = Achievement & { criteria }
```

### `GET /api/v1/users/me/achievements` — R1–R4, R7

- **Acesso:** `authenticate`
- **Sucesso:** `200` `{ "data": Achievement[] }` (lista vazia quando não há conquistas; poucas linhas, sem paginação)
- **Erros:** `401 UNAUTHORIZED` (R1).

### `GET /api/v1/profiles/:username/achievements` — R1, R2, R4, R5, R9

- **Acesso:** público
- **Sucesso:** `200` `{ "data": Achievement[] }`
- **Erros:** `404 PROFILE_NOT_FOUND` (nome de usuário inexistente ou conta excluída) — R9.

### `GET /api/v1/profiles/:username/achievements/:achievementId` — R6, R8

- **Acesso:** público (o próprio perfil usa o mesmo, com o @ do usuário logado)
- **Sucesso:** `200` `{ "data": AchievementDetail }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `achievementId` não é UUID | R6 |
  | 404 | `PROFILE_NOT_FOUND` | perfil inexistente ou excluído | R9 |
  | 404 | `ACHIEVEMENT_NOT_FOUND` | conquista excluída ou não obtida | R8 |

## Backend — `apps/cromocard-backend`

Subpasta `src/domains/users/achievements/` e o módulo público `src/domains/users/profiles/` (`/profiles`), no modelo de
`src/domains/users/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + 2 migrations | modelos `Achievement` e `UserAchievement`, relação em `User` | R2 |
| `database/seeds/achievements.seed.ts` · `data/achievements.json` · `seeds/index.ts` | as 5 conquistas e as obtidas | R2, R4, R7 |
| `achievements/achievements.{validator,errors,repository,service}.ts` + `achievements.service.spec.ts` | obtidas por usuário, detalhe, `AchievementNotFoundError` | R2, R4, R6, R8 |
| `users.routes.ts` · `users.controller.ts` · `users.swagger.ts` | `GET /users/me/achievements` | R1, R3 |
| `profiles/profiles.{errors,repository,service,controller,routes,swagger}.ts` + `profiles.module.ts` | usuário ativo pelo @ (`ProfileNotFoundError`) e as 2 rotas públicas de conquistas | R5, R6, R9 |
| `src/routes.ts` | registra o `profilesModule` | R5 |
| `tests/integration/achievements.spec.ts` | as 3 rotas com Supertest | R1, R2, R5, R8, R9 |

## Frontend — `apps/cromocard-frontend`

Subpasta `src/features/users/achievements/`, no modelo de `src/features/users/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `achievements.types.ts` · `achievements.labels.ts` · `achievements.api.ts` · `achievements.queries.ts` | tipos, textos ("🏅 Conquistas", "Nenhuma conquista obtida", aviso de indisponível pela L7) e as 3 rotas | R3–R8 |
| `components/AchievementCard/` | ícone, nome e descrição — frames `1160-37708` e `1160-1396` | R4 |
| `components/AchievementShowcase/` | grade de cartões, vazio "Nenhuma conquista obtida" no estilo da seção (sem frame, L7) — seção "🏅 Conquistas" do frame `1160-37708` e "Conquistas" do `1160-1396` | R3, R5, R7 |
| `components/AchievementDetailDialog/` | detalhes ao selecionar (formato pela L6) e o aviso de conquista indisponível no `404` | R6, R8 |
| `features/users/pages/ProfilePage/` (CCD048) | monta a seção com o próprio usuário | R3 |
| página pública da CCD080 | monta a seção com o `:username` da rota | R5, R9 |

- **Fora deste plano:** as não obtidas apagadas e o contador "3 de 5" (L3), compartilhar conquista (fase Futuro).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 3 conquistas com ícone, nome e descrição no "Perfil" | `achievements.service.spec.ts` · `achievements.spec.ts` · `AchievementShowcase.spec.tsx` |
| CA2 | o perfil público de tiago_trocas mostra só as 3 obtidas, sem login | `achievements.spec.ts` · `AchievementShowcase.spec.tsx` |
| CA3 | selecionar abre os detalhes | `AchievementDetailDialog.spec.tsx` |
| CA4 | sem conquistas, "Nenhuma conquista obtida" | `AchievementShowcase.spec.tsx` |
| CA5 | conquista excluída: `404 ACHIEVEMENT_NOT_FOUND` e o aviso | `achievements.service.spec.ts` · `achievements.spec.ts` · `AchievementDetailDialog.spec.tsx` |
| CA6 | linha de `user_achievements` excluída não aparece | `achievements.service.spec.ts` · `achievements.spec.ts` |
| CA7 | `401` em `/users/me/achievements` sem login | `achievements.spec.ts` |
| CA8 | conta excluída: `404 PROFILE_NOT_FOUND` | `achievements.spec.ts` |
| CA9, CA10 | print em 1280 px igual às seções dos frames `1160-37708` e `1160-1396`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Dependências e riscos

- L1: sem regra de concessão, a vitrine só mostra o que o seed gravou. Conceder conquistas é outra story (ou um job do
  ADR-010), não este plano.
- L5: o DBML guarda `icon_url`; se o PO quiser emoji, o DBML muda num PR de docs antes do código.
- L2, L4, L6–L9 seguem a proposta e podem mudar textos, ordem e o detalhe.
- CA2, CA8 e CA10 no frontend dependem da página pública da CCD080; o backend fecha sem ela.

## Decisões técnicas

- O módulo público `/profiles/:username` nasce aqui (o primeiro que precisa dele); a CCD050 e a CCD080 acrescentam rotas
  nele em vez de criar outro.
- O detalhe é uma rota própria, e não só os dados da lista, para responder `404` quando a conquista foi excluída depois
  que a página abriu (R8, CA5).
