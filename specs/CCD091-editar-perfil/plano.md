# Plano — CCD091 Editar Perfil (do vendedor)

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L8 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Seguindo a proposta da L1, a CCD091 edita o perfil da loja pública. "Editar perfil da loja" na Visão geral do vendedor
(L5) abre o modal do frame `675-4627`, que carrega `GET /api/v1/me/seller-profile` e salva com
`PATCH /api/v1/me/seller-profile`: nome da loja em `seller_verifications.trade_name`, logo em `profiles.avatar_url` (enviado
antes pelo `POST /api/v1/uploads`) e bio em `profiles.bio` (L2). Dados pessoais, e-mail e CPF ficam na CCD048.

## Dependências

- **CCD108:** o Painel do vendedor (`/vendedor`, `SellerOverviewPage`) onde entra o botão, e o link para a conta Stripe que
  substitui os "meios de recebimento" (depende da L3).
- **CCD048 (Editar Dados do Perfil):** dona de `profiles` e do `PATCH /api/v1/users/me` com e-mail e CPF. Se a CCD048 ainda
  não tiver criado `profiles`, esta story cria a migration `create_profiles_table`, copiada do DBML.
- **CCD094 (Implementada):** `seller_verifications` com `trade_name`. Vendedor sem credenciamento não tem linha em
  `seller_verifications`; aí o nome da loja não é editável e o modal mostra `users.name` (depende da L2).
- **CCD084:** o `POST /api/v1/uploads` já aceita `SELLER`; aqui só entra a pasta `avatars`.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `profiles` | não | `create_profiles_table` (se a CCD048 não tiver criado) | copiada do DBML, enum `privacy`; usa `bio` (até 300, L7) e `avatar_url` |
| `seller_verifications` | sim | — | `trade_name` (até 160, L7) |
| `users` | sim | — | `username` só leitura, no "Endereço da loja" (L8) |

Banner e especialidades não têm coluna e saem do frame (depende da L2); "WhatsApp de contato" e "Graduadas" saem (depende da
L4). Nenhuma coluna nova.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }`, JSON camelCase, erros `{ error, message, details? }`. As duas rotas:
`authenticate` + `authorize('SELLER')`, com `401 UNAUTHORIZED` e `403 FORBIDDEN` (R1); o vendedor só lê e grava o próprio
perfil, pelo id do token.

### `GET /api/v1/me/seller-profile` — R2

- **Sucesso:** `200`

  ```json
  { "data": { "storeName": "Rodrigo Slabs", "storeNameEditable": true, "username": "rodrigo_slabs",
    "storeUrl": "cromocard.com.br/u/rodrigo_slabs", "bio": "…", "avatarUrl": "https://…" } }
  ```

### `PATCH /api/v1/me/seller-profile` — R2–R5

- **Entrada:** `{ "storeName"?: "string 1–160", "bio"?: "string até 300 ou null", "avatarUrl"?: "url do storage ou null" }`
- **Sucesso:** `200`, o mesmo corpo do `GET`.
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | tamanho fora do limite, URL fora do storage (L7) | R3, R5 |
  | 409 | `INFORMATION_ALREADY_IN_USE` | e-mail ou documento de outra conta, "Esta informação já está em uso por outro usuário" (depende da L1) | R4 |
  | 422 | `STORE_NAME_NOT_EDITABLE` | `storeName` enviado por vendedor sem credenciamento (depende da L2) | R3 |

- **R4 (depende da L1):** com a proposta, o modal não tem e-mail nem CPF e o `409` fica no `PATCH /users/me` da CCD048, com
  a mesma mensagem; o R4 sai desta spec (riscado com o motivo) quando a L1 for decidida. Se o PO mantiver o caso de uso, o
  corpo ganha `email` e `cpf` e o `409` é mapeado pelo `shared/errors/unique-constraint.ts`, como já faz o domínio `users`.

### `POST /api/v1/uploads` (existente) — R5

- A pasta ganha `avatars`; PNG, JPG ou WEBP até 4 MB, como já está no `uploads.validator.ts`.

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + `create_profiles_table` (se faltar) | `Profile`, enum `Privacy` | R3, R5 |
| `database/seeds/users.seed.ts` | perfil com bio e logo do vendedor do seed | R2 |
| `src/domains/users/seller-profile.{validator,repository,service,controller,routes,swagger,errors}.ts` + `seller-profile.module.ts` (`basePath: '/me/seller-profile'`) | leitura e gravação, numa transação, de `profiles` e `seller_verifications` | R1–R5 |
| `src/domains/uploads/uploads.validator.ts` | pasta `avatars` | R5 |
| `src/routes.ts` | registra o módulo | R1 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/marketplace/seller-profile/seller-profile.{types,schemas,api,queries,labels}.ts` | perfil da loja, schema Zod (L7) e o texto "Perfil da loja atualizado" (L6) | R2–R5 |
| `components/EditSellerProfileModal/` | modal do frame `675-4627`: "Editar Perfil do Vendedor", subtítulo, "Nome da loja" com "Endereço da loja: …" só leitura, "Logo (1:1)", "Bio da loja", "Cancelar" e "Salvar Perfil" em carregamento (CA7); sem banner, especialidades e WhatsApp (L2, L4); link para a conta Stripe no lugar de "Dados de recebimento criptografados" (L3) | R2, R3, R5, R6 |
| `pages/SellerOverviewPage/` (CCD108) | botão "Editar perfil da loja" perto de "Ver Loja Pública" (L5) | R2 |

- **Componentes reaproveitados:** `Modal`, `TextField`, `Textarea`, `FileUpload`, `FormField`, `FormError`, `Button`,
  `Toast`; `ImageUploadField` da feature `catalog` para o logo.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | salvar grava nome da loja, bio e logo e mostra a confirmação | `seller-profile.service.spec.ts` · `tests/integration/users/seller-profile.spec.ts` · `EditSellerProfileModal.spec.tsx` |
| CA2 | informação em uso responde `409` com a mensagem (depende da L1) | integração (aqui ou na CCD048) · `EditSellerProfileModal.spec.tsx` |
| CA3 | PNG de 1 MB gravado; PDF e 5 MB recusados | integração do upload · `EditSellerProfileModal.spec.tsx` |
| CA4 | campo inválido mostra o erro e a API responde `400` | `seller-profile.schemas.spec.ts` · integração |
| CA5 | "Cancelar" fecha sem gravar | `EditSellerProfileModal.spec.tsx` |
| CA6 | `401` sem token; `403` para `CUSTOMER` e `ADMIN` | integração |
| CA7 | botão em carregamento; erro mantém os campos | `EditSellerProfileModal.spec.tsx` |
| CA8 | print em 1280 px igual ao frame `675-4627`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Decisões técnicas

- O perfil da loja junta `profiles` e `seller_verifications` num endpoint só de `/me`, para o modal salvar tudo de uma vez
  numa transação.
- O logo da loja é o mesmo `profiles.avatar_url` do usuário (L2): trocar aqui troca a foto do Perfil.
