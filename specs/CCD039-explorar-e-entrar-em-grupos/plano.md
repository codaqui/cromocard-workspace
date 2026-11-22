# Plano — CCD039 Explorar e Entrar em Grupos

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (lacunas L1–L19 pendentes)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O cliente abre "Comunidades" (`/comunidades`, só logado), busca grupos por nome ou descrição e vê os cartões paginados
com nome, descrição, membros e tipo de acesso. "Entrar no grupo" num grupo aberto grava (ou restaura) a linha em
`group_members` e abre a tela do grupo (CCD044); "Solicitar entrada" num grupo fechado grava `group_join_requests`
`PENDING` e avisa os administradores do grupo. "Compartilhar" abre o modal com o link fixo do grupo e "Copiar link".

## Dependências

- Nenhuma spec antes desta. Ela cria o domínio `community/groups/` e o `GroupAccess` (membro e administrador do grupo),
  que CCD040–CCD044 reaproveitam.
- CCD044: a tela do grupo (`/comunidades/:id`), para onde "Entrar no grupo" e o link compartilhado levam. Até ela
  existir, a rota fica com o `UnderConstructionPage`.
- CCD043: "Criar grupo" (destino da sugestão do R10).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `groups` | sim (`status` com `WARNED`) | — | lida |
| `group_members` | sim | — | `upsert` em `(group_id, user_id)` para restaurar (R8) |
| `group_join_requests` | não | `create_group_join_requests_table` | copiada do DBML (`id`, `group_id`, `user_id`, `reviewed_by_id`, `status request_status`, `reviewed_at`, colunas de tempo, `deleted_at`); o enum `request_status` já existe; FKs `fk_group_join_requests_group_id`, `_user_id`, `_reviewed_by_id` |
| `notifications` | sim | — | aviso aos `ADMIN` do grupo (depende da L16) |

Seed: `database/seeds/data/groups.json` ganha um grupo fechado com uma solicitação pendente, e `community.seed.ts`
grava `group_join_requests` (dados do CA4 e do frame `417-2915`).

## Regras

- **Quem usa:** `CUSTOMER` e `SELLER`; o `ADMIN` da plataforma recebe `403` (depende da L1).
- **Visível:** `deleted_at` nulo e `status` diferente de `SUSPENDED`; `WARNED` continua visível sem selo (depende da L18).
- **Busca:** `search` com 2 ou mais caracteres, `ILIKE` em `name` e `description` (depende da L2).
- **Ordem:** por nome, sem "Ordenar por" (L4 pendente).
- **Entrar (`OPEN`):** `upsert` da linha com `deleted_at = null`, `role = MEMBER` e `muted_until = null` (R8; L11 da CCD041).
- **Solicitar (`CLOSED`):** uma `PENDING` por usuário e grupo; recusada permite pedir de novo (depende da L15). Na mesma
  transação, um aviso `type = GROUP_JOIN_REQUEST` para cada `ADMIN` do grupo, com `reference_link` para a administração
  do grupo (depende da L16).
- **Link compartilhado:** `<origem do site>/comunidades/<id>`, sem slug, prazo nem código (depende da L13).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.

### `GET /api/v1/groups` — R1, R3–R6, R9

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L1)
- **Entrada:** `search?` (2–120), `page`, `pageSize` (padrão 20)
- **Sucesso:** `200`

  ```json
  { "data": [{ "id": "uuid", "name": "Pokémon TCG São Paulo", "description": "…", "coverImageUrl": null,
      "accessType": "CLOSED", "memberCount": 184, "myRole": null,
      "myJoinRequest": { "status": "PENDING", "createdAt": "2026-11-20T12:00:00Z" } }],
    "meta": { "page": 1, "pageSize": 20, "total": 3 } }
  ```

- **Erros:** `400 VALIDATION_ERROR` (termo curto), `401`, `403` (ADMIN)

### `POST /api/v1/groups/:id/join` — R1, R7–R9

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** nenhuma
- **Sucesso:** `200` `{ "data": { "groupId": "uuid", "result": "MEMBER" } }` (aberto) ou
  `201` `{ "data": { "groupId": "uuid", "result": "PENDING", "requestId": "uuid" } }` (fechado)
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 404 | `GROUP_NOT_FOUND` | inexistente, excluído ou suspenso | R5 |
  | 409 | `ALREADY_MEMBER` | já é membro ativo (depende da L15) | R7 |
  | 409 | `JOIN_REQUEST_PENDING` | já tem solicitação pendente (depende da L15) | R9 |

## Backend — `apps/cromocard-backend`

Domínio `src/domains/community/groups/`, no modelo de `src/domains/users/` (ADR-004), exportado por
`community.module.ts` e registrado em `src/routes.ts` com `basePath: '/groups'`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration | modelo `GroupJoinRequest` e relações em `Group` e `User` | R9 |
| `database/seeds/community.seed.ts` · `data/groups.json` | grupo fechado com solicitação pendente | R9 |
| `groups.validator.ts` | `listGroupsQuerySchema` | R3, R6 |
| `groups.repository.ts` | lista visível com contagem de membros, `myRole` e `myJoinRequest`; `upsertMember`; `createJoinRequest`; `findAdmins` | R4–R9 |
| `groups.service.ts` | regras de visibilidade, entrar e solicitar, aviso aos administradores | R5, R7–R9 |
| `group-access.ts` | `assertMember(groupId, userId)` e `assertGroupAdmin(...)`, com `403 NOT_GROUP_MEMBER` e `403 NOT_GROUP_ADMIN`; reaproveitado por CCD040–CCD044 | R1 |
| `groups.errors.ts` | `GROUP_NOT_FOUND`, `ALREADY_MEMBER`, `JOIN_REQUEST_PENDING`, `NOT_GROUP_MEMBER`, `NOT_GROUP_ADMIN` | R5, R7, R9 |
| `groups.controller.ts` · `groups.routes.ts` · `groups.swagger.ts` | as duas rotas | R1 |
| `src/domains/community/community.module.ts` · `src/routes.ts` | `groupsModule` | R1 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/community/groups/`, no modelo de `src/features/users/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `groups.types.ts` · `groups.api.ts` · `groups.queries.ts` · `groups.labels.ts` | `listGroups`, `joinGroup`, rótulos do tipo de acesso | R3–R9 |
| `pages/CommunitiesPage/` | a página do frame `417-2915`: título, busca, lista paginada, estados | R2–R6, R10, R12 |
| `components/GroupCard/` | cartão do frame `417-2915`: nome, descrição, membros, selo do acesso, "Entrar no grupo" / "Solicitar entrada" / pendente (texto depende da L5), "Compartilhar" | R4, R7, R9, R11, R12 |
| `components/ShareGroupDialog/` | modal do frame `675-17336` só com o link e "Copiar link" (`navigator.clipboard`), sem QR nem atalhos (depende da L13, L14) | R11, R12 |
| `components/NoGroupsFound/` | estado sem resultado com "Criar grupo" (no estilo do frame, R10 não desenhado) | R10 |
| `community.routes.ts` | `/comunidades` sai do `UnderConstructionPage` e do `PublicLayout` e vai para `RequireAuth` + `CustomerLayout` | R1, R2 |
| `app/layouts/SiteShell/siteMenu.ts` · `SiteShell.tsx` | "Comunidades" só para usuário logado | R1 |
| `routes/paths.ts` | `groupChat: '/comunidades/:id'` e `groupChatPathFor(id)` | R7, R11 |

- **Rotas:** `/comunidades` com `RequireAuth`.
- **Estados:** carregando, erro e vazio com `LoadingState`, `ErrorState` e `EmptyState` (depende da L19).
- **Componentes reaproveitados de `src/components/`:** `SearchBar`, `Pagination`, `Badge`, `Button`, `Modal`, `Toast`,
  `Icon`.
- Fora do frame até decisão: abas e "Meus grupos" (L3), ordenação (L4), online (L6), verificado (L7), franquia (L8),
  painéis laterais (L9, L10), botão só com ícone (L17), página de detalhes antes de entrar (L11).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | busca por nome e descrição, campos do cartão, paginação | `groups.service.spec.ts` · `tests/integration/groups.spec.ts` · `CommunitiesPage.spec.tsx` |
| CA2 | grupo aberto grava `MEMBER` e navega para `/comunidades/:id` | `groups.service.spec.ts` · integração · `GroupCard.spec.tsx` |
| CA3 | reentrada restaura a mesma linha | `groups.service.spec.ts` · integração |
| CA4 | grupo fechado grava `PENDING`, avisa os `ADMIN` e o cartão mostra pendente | `groups.service.spec.ts` · integração · `GroupCard.spec.tsx` |
| CA5 | sem resultado mostra "Criar grupo" | `CommunitiesPage.spec.tsx` |
| CA6 | suspenso e excluído não aparecem; entrar responde `404` | integração |
| CA7 | `401` sem token; menu do visitante sem "Comunidades" | integração · `SiteShell.spec.tsx` |
| CA8 | "Copiar link" grava o link na área de transferência | `ShareGroupDialog.spec.tsx` |
| CA9, CA10 | print em 1280 px igual aos frames `417-2915` e `675-17336`; 375/768/1024 px sem quebra | revisão visual (`/cromocard-revisor`) |

Cobertura de 90% nos arquivos alterados (ADR-060).

## Dependências e riscos

- A tela segue só o que a documentação pede; L2–L11, L13, L14 e L17 podem acrescentar blocos do frame `417-2915` e
  `675-17336`. Cidade (L2, L8), slug e convite (L13) e verificado (L7) exigem PR de docs no DBML antes do código.

## Decisões técnicas

- Entrar é um único `POST /groups/:id/join` que decide pelo `access_type`, para o front não precisar saber a regra.
- A contagem de membros é um `_count` filtrado por `deleted_at = null`, numa consulta só para a página.
- `group-access.ts` concentra a checagem de membro e de administrador do grupo, para CCD040–CCD044 não repetirem a regra.
