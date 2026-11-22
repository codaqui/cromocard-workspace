# Plano — CCD048 Editar Dados do Perfil

Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (feito sobre a spec em Rascunho)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade
- **Código lido:** branch `feature/336-remove-tipo-categoria` dos dois apps. Já existem `GET/PATCH/DELETE /users/me`
  (o `PATCH` só aceita `name`), o modelo `Address` no `schema.prisma`, o `UsernameTakenError`, os validators de
  `username` e `phone` em `users.validator.ts`, o `uploads.service` com o `StorageProvider` (pastas `cards`, `albums`,
  `banners`, só ADMIN) e, no frontend, a `ProfilePage` com `ProfileDetails`, `EditNameForm` e `DeleteAccountSection`.
  `profiles` não está no `schema.prisma`.

## Solução

A página "Perfil" (`/profile`, já roteada) é refeita no frame `1160-37708`: cartão do usuário, "Informações pessoais"
editáveis com "Descartar" e "Salvar alterações" e "Endereços de entrega". O `PATCH /users/me` passa a aceitar nome, @,
celular e bio; a foto vai por um upload próprio (`POST /users/me/avatar`) que reaproveita o `uploads.service` e grava
`profiles.avatar_url`. Os endereços ganham CRUD em `/users/me/addresses`, com um só principal e a remoção do principal
recusada.

## Dependências

- **CCD004:** login e `authenticate`. **CCD003:** as regras do @ (`isValidUsername`) e do celular, já no `users.validator.ts`.
- **ADR-050:** upload PNG, JPG ou WEBP até 4 MB pelo `StorageProvider` (ADR-009).
- A seção "Conquistas" é da CCD049 e "Acessibilidade" da CCD038; esta story deixa o espaço delas na página.
- A CCD051 e a CCD049 usam a tabela `profiles` criada aqui.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação | Requisitos |
|---|---|---|---|---|
| `profiles` | não | `create_profiles_table` | copiada do DBML (`user_id` único, `bio`, `avatar_url`, `city`, `portfolio_privacy` com o enum `privacy`, default `PUBLIC`) | R3, R4, R9 |
| `users` | sim | — | `name`, `username`, `phone` editáveis; `email`, `email_verified`, `created_at` só leitura (L3) | R3, R4, R6 |
| `addresses` | sim | — | o `label` único guarda a identificação (depende da L7: sem coluna nova até o DBML mudar) | R11–R16 |

Seed: perfil com bio e dois endereços de Gabriel ("Apartamento Bela Vista" principal e "Studio Campinas" secundário).

## Regras

- **Perfil 1:1:** a linha de `profiles` é criada no primeiro `PATCH` ou upload (`upsert` por `user_id`); o `GET` devolve
  `bio` e `avatarUrl` nulos enquanto ela não existe.
- **Validação:** `name` 2–120; `username` pela regra do cadastro (3–30, minúsculas, números, ponto e `_`, depende da L3);
  `phone` pelo `phoneSchema` (CCD098); `bio` até 300 (depende da L4). `@` repetido: `409 USERNAME_TAKEN` com o campo
  `username` (R6), pelo `unique-constraint` já existente.
- **Foto:** reaproveita o `uploads.service` com a pasta nova `avatars`, aberta ao dono (não só ADMIN); tipo pelo conteúdo
  (`image-type.ts`), até 4 MB (`413 FILE_TOO_LARGE`, `400 VALIDATION_ERROR` com `details.file`) (R10; textos pela L5). A URL antiga fica no
  storage (sem remoção, L6).
- **Principal único:** criar ou editar com `isPrimary = true` e `make-primary` tiram o `is_primary` dos outros na mesma
  transação. O primeiro endereço da conta nasce principal (depende da L10).
- **Remover:** soft delete (`deleted_at`, ADR-015). O principal responde `409 PRIMARY_ADDRESS_REQUIRED` (R16, depende da L10).
- **Dono:** endereço de outra conta ou excluído responde `404 ADDRESS_NOT_FOUND` (R1).
- **Papéis:** `CUSTOMER` e `SELLER` (depende da L2).

## Contrato da API

Convenções do ADR-011. Os recursos do perfil ficam no módulo `users`, em `/users/me/...`, como o `GET /users/me` atual.

```ts
MyProfile = { id, name, username, email, emailVerified, phone, role, createdAt,
  profile: { bio: string | null, avatarUrl: string | null } }
Address = { id, label, zipCode, street, number, complement, neighborhood, city, state, isPrimary }
```

### `GET /api/v1/users/me` (já existe) — R3, R4

- **Acesso:** `authenticate`
- **Sucesso:** `200` `{ "data": MyProfile }` (ganha `profile`, `phone`, `emailVerified`, `createdAt` se faltarem)
- **Erros:** `401`.

### `PATCH /api/v1/users/me` (já existe) — R4–R7

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (L2)
- **Entrada:** `{ "name": "Gabriel Nascimento", "username": "gabriel.n", "phone": "(11) 98888-7777", "bio": "string até 300" }` (todos opcionais)
- **Sucesso:** `200` `{ "data": MyProfile }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `name` vazio, `username` fora da regra, celular inválido, `bio` > 300 (`details` por campo) | R5 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 409 | `USERNAME_TAKEN` | @ já usado por outra conta | R6 |

### `POST /api/v1/users/me/avatar` — R9, R10

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** `multipart/form-data` com `file`
- **Sucesso:** `200` `{ "data": { "avatarUrl": "https://…/avatars/…" } }`
- **Erros:** `400 VALIDATION_ERROR` com `details.file` (sem arquivo, GIF e outros tipos; `MissingFileError` e `InvalidImageTypeError` do `uploads.errors.ts`), `413 FILE_TOO_LARGE` (> 4 MB), `401` — R10.

### `GET /api/v1/users/me/addresses` — R1, R11

- **Acesso:** `authenticate`
- **Sucesso:** `200` `{ "data": Address[] }` (o principal primeiro, depois pela criação; lista curta, sem paginação)
- **Erros:** `401`.

### `POST /api/v1/users/me/addresses` — R12, R14

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** `{ "label", "zipCode", "street", "number", "complement?", "neighborhood", "city", "state", "isPrimary?" }`
- **Sucesso:** `201` `{ "data": Address }`
- **Erros:** `400 VALIDATION_ERROR` (obrigatórias do DBML, `zipCode` `00000-000`, `state` UF de 2 letras), `401` — R12.

### `PATCH /api/v1/users/me/addresses/:id` — R1, R13, R14

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** os mesmos campos, todos opcionais
- **Sucesso:** `200` `{ "data": Address }`
- **Erros:** `400 VALIDATION_ERROR`, `401`, `404 ADDRESS_NOT_FOUND` (de outra conta ou excluído) — R1, R13.

### `POST /api/v1/users/me/addresses/:id/make-primary` — R14

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Sucesso:** `200` `{ "data": Address[] }` (a lista atualizada)
- **Erros:** `401`, `404 ADDRESS_NOT_FOUND`.

### `DELETE /api/v1/users/me/addresses/:id` — R15, R16

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Sucesso:** `204`
- **Erros:** `401`, `404 ADDRESS_NOT_FOUND`, `409 PRIMARY_ADDRESS_REQUIRED` (é o principal) — R16.

## Backend — `apps/cromocard-backend`

No domínio `src/domains/users/` (o modelo), com os endereços em `src/domains/users/addresses/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration `create_profiles_table` | enum `Privacy`, modelo `Profile`, relação em `User` | R3, R4, R9 |
| `database/seeds/users.seed.ts` · `data/users.json` | bio, foto e os dois endereços de Gabriel | R3, R11 |
| `users.validator.ts` | `updateMeSchema` (`name`, `username`, `phone`, `bio`), reaproveitando `usernameSchema` e `phoneSchema` | R4, R5 |
| `users.repository.ts` · `users.service.ts` + `users.service.spec.ts` | `findMe` com o perfil; `updateMe` com `upsert` de `profiles` e `409 USERNAME_TAKEN`; `setAvatar` | R3–R7, R9 |
| `users.controller.ts` · `users.routes.ts` · `users.swagger.ts` | `PATCH /me` novo schema; `POST /me/avatar` com o `parseSingleFile` de `uploads.middleware.ts` | R4, R9, R10 |
| `src/domains/uploads/uploads.validator.ts` · `uploads.service.ts` | pasta `avatars` e o método usado pelo `users.service` (sem abrir a rota de upload genérica) | R9, R10 |
| `addresses/addresses.{validator,errors,repository,service,controller,routes,swagger}.ts` + `addresses.service.spec.ts` | CRUD, `make-primary`, principal único em transação, `409` do principal | R1, R11–R16 |
| `users.module.ts` | monta as rotas de endereços em `/users/me/addresses` | R11 |
| `tests/integration/users-profile.spec.ts` · `users-addresses.spec.ts` · `uploads.spec.ts` | perfil, foto e endereços com Supertest | R1, R4–R7, R9–R16 |

## Frontend — `apps/cromocard-frontend`

Na feature `src/features/users/` (o modelo), página `pages/ProfilePage/` já roteada em `paths.profile` com `RequireAuth`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `users.types.ts` · `users.schemas.ts` · `users.labels.ts` | `MyProfile`, `Address`; schemas do perfil e do endereço (React Hook Form + Zod, ADR-042); textos da tela | R4, R5, R12 |
| `users.api.ts` · `users.queries.ts` | `updateMe` ampliado, `uploadAvatar`, CRUD de endereços e `makePrimary` | R7, R9, R11–R15 |
| `components/ProfileCard/` | foto ou iniciais, nome, @, link `cromocard.com.br/u/<usuário>`, "Alterar Foto", "Recomendado…", "STATUS" (L11) e "MEMBRO Desde <ano>" — frame `1160-37708` | R3 |
| `components/PersonalInfoForm/` (substitui `EditNameForm/`) | campos, selo "Verificado", contador "<n> / 300 caracteres", erro no rótulo ("Nome completo • informe o nome"), `409` no @, "Descartar" e "Salvar alterações" com o aviso "Perfil atualizado" — frames `1160-37708`, `1160-38269`, `1160-38711` | R4–R8 |
| `components/AvatarUploadDialog/` | "Alterar Foto do Perfil", área "Clique ou arraste…", "Cancelar", "Aplicar e Salvar Foto", aviso de arquivo recusado — frame `1160-39158` (zoom e remover só com a L6) | R9, R10 |
| `components/AddressList/` · `AddressCard/` | "Endereços de entrega", selos "Endereço Principal (Padrão)" e "SECUNDÁRIO", editar, remover, "Tornar Padrão", "+ Adicionar Novo Endereço" — frame `1160-37708` | R11, R14 |
| `components/AddressFormDialog/` | "Novo endereço" e "Editar Endereço" (mesmo formulário; estilo pela L9) com "Definir como Endereço Principal" e "Remover este Endereço" — frames `1160-39672`, `1160-40220` | R12–R14 |
| `components/RemoveAddressDialog/` | "Remover este endereço de entrega?" com o aviso do principal — frame `1160-40789` | R15, R16 |
| `pages/ProfilePage/` | topo "MINHA CONTA", "Perfil" e o subtítulo; monta as seções; tira `ProfileDetails` e `DeleteAccountSection` (a exclusão vai para Configurações, CCD052) — frame `1160-37708` | R2 |
| `app/layouts/SiteShell/siteMenu.ts` | item "Perfil" no menu, se ainda não houver | R2 |

- **Reaproveitados:** `TextField`, `Textarea`, `FormField`, `FormError`, `Checkbox`, `Badge`, `Button`, `Modal`,
  `ConfirmDialog`, `FileUpload`, `Toast`, `LoadingState`, `ErrorState`.
- **Fora deste plano:** "Buscar CEP" (L8, precisa de provider e ADR), "LOGÍSTICA SEGURADA"/"Validado pelos Correios" (L9),
  zoom e remover foto (L6), cidade do perfil (L12).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | `bio` gravada e o aviso "Perfil atualizado" | `users.service.spec.ts` · `users-profile.spec.ts` · `PersonalInfoForm.spec.tsx` |
| CA2 | nome vazio: `400` com `name` e o rótulo em vermelho | `users-profile.spec.ts` · `PersonalInfoForm.spec.tsx` |
| CA3 | `409 USERNAME_TAKEN` e o campo indicado | `users.service.spec.ts` · `users-profile.spec.ts` · `PersonalInfoForm.spec.tsx` |
| CA4 | "Descartar" volta aos valores gravados | `PersonalInfoForm.spec.tsx` |
| CA5 | JPG de 2 MB grava `avatar_url`; GIF e 6 MB recusados | `users-profile.spec.ts` · `AvatarUploadDialog.spec.tsx` |
| CA6, CA9 | principal novo tira o do anterior; "Tornar Padrão" troca os selos | `addresses.service.spec.ts` · `users-addresses.spec.ts` · `AddressList.spec.tsx` |
| CA7 | sem número: nada gravado e o campo com erro | `AddressFormDialog.spec.tsx` · `users-addresses.spec.ts` |
| CA8 | editar o complemento atualiza a lista | `users-addresses.spec.ts` · `AddressFormDialog.spec.tsx` |
| CA10 | remover o secundário preenche `deleted_at`; "Cancelar" não chama a API | `addresses.service.spec.ts` · `RemoveAddressDialog.spec.tsx` |
| CA11 | remover o principal: `409` e o aviso | `addresses.service.spec.ts` · `users-addresses.spec.ts` · `RemoveAddressDialog.spec.tsx` |
| CA12 | `401` sem login; `404` no endereço de outra conta | `users-profile.spec.ts` · `users-addresses.spec.ts` |
| CA13–CA19 | print em 1280 px igual aos frames `1160-37708`, `1160-38269`, `1160-38711`, `1160-39158`, `1160-39672`, `1160-40220` e `1160-40789`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Dependências e riscos

- L7: o Figma mostra nome e tipo do endereço, e o DBML tem só `label`. O plano grava a identificação em `label`; uma
  coluna nova exige PR de docs no DBML (três `.dbml`) e ADR antes do código.
- L1 (página já editável, como no Figma), L3 (troca do @ e e-mail só leitura), L4 (300 na bio), L5 (4 MB do ADR-050),
  L10 (primeiro endereço principal e remoção do principal) seguem a proposta ou a documentação e podem mudar o plano.
- L2: se o `SELLER` editar pelo Painel do vendedor (CCD091), o `authorize` muda.
- Tirar `DeleteAccountSection` da página só depois que a CCD052 a levar para Configurações, para não sumir a exclusão.

## Decisões técnicas

- O perfil fica no `PATCH /users/me` que já existe, em vez de uma rota `/profiles/me`: o frontend salva `users` e
  `profiles` num envio só, como na tela.
- A foto tem rota própria em `/users/me/avatar`, para o cliente não usar a rota de upload genérica do admin.
- Um formulário só para "Novo endereço" e "Editar Endereço" (L9 pede que o Gabriel alinhe os dois frames).
