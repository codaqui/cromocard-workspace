# Plano — CCD012 Compartilhar Coleção

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L11 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

"Compartilhar coleção", no Início e em "Meus álbuns", abre o modal do frame `1160-9616`. O modal lê
`GET /api/v1/collections/me/sharing` (público ou não, link, nome de usuário e o resumo), liga e desliga a coleção pública
com `PATCH /api/v1/collections/me` e gera o link com `POST /api/v1/collections/me/share-link`, que grava
`collections.share_link` = nome de usuário (depende da L2). O cliente copia o link, abre WhatsApp, X ou Facebook numa
nova aba ou baixa a imagem do resumo. Quem abre `cromocard.com.br/u/<nome de usuário>`, sem login, vê os álbuns e as
cartas da coleção pública por `GET /api/v1/collections/shared/:shareLink`.

## Dependências

- **CCD007**: domínio `collection`, tabela `collections` (`is_public`, `share_link`) e o resumo (contagens da L3).
- **CCD008**: lista dos álbuns com o progresso, usada no resumo do modal e na página pública.
- **CCD013**: as cartas do álbum com o status, reaproveitadas na página pública.
- **CCD080 (EA-080-01)**: o perfil público usa o mesmo endereço `/u/<nome de usuário>`. A story que entrar primeiro cria
  a rota `/u/:username`; a outra acrescenta o seu bloco (perfil ou coleção) na mesma página (depende da L2, L3).
- **CCD051**: o interruptor "Coleção pública" de Configurações grava o mesmo `PATCH /collections/me` (depende da L5).
- **CCD048**: trocar o nome de usuário muda o link; ver Decisões técnicas.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `collections` | da CCD007 | — | escreve `is_public` e `share_link` (R3, R8) |
| `users` | sim | — | lê `username` (depende da L2, L10) |
| `user_albums`, `albums`, `collection_cards`, `cards` | CCD007 / sim | — | só leitura, filtrando `deleted_at` (R9) |

`profiles.portfolio_privacy` não é lida: a coleção é governada por `collections.is_public` (depende da L5). Nenhuma coluna
nova.

## Regras

- **Link** (R3, depende da L2): `share_link = users.username`; gerar de novo devolve o mesmo (CA2). Sem `username`,
  `422 USERNAME_REQUIRED` e o modal pede para definir no Perfil (depende da L10).
- **Coleção privada** (R8, depende da L4): `POST /share-link` responde `422 COLLECTION_PRIVATE`; o modal mostra o
  interruptor desligado, o link e as redes desabilitados e o aviso "Ligue Coleção pública para compartilhar".
- **Página pública** (R9, depende da L3): sem login; só coleção com `is_public = true`; privada ou inexistente responde
  `404` (CA6). Mostra os álbuns ativos (capa, título, progresso) e as cartas de cada um com o status.
- **Resumo do modal** (depende da L6): "<n> álbuns • <n> cartas • <n> repetidas" com as regras da CCD007 (L3) e o
  progresso de cada álbum.
- **Redes** (R6, depende da L9): links de compartilhamento numa nova aba, sem SDK: `https://wa.me/?text=<link>`,
  `https://twitter.com/intent/tweet?url=<link>`, `https://www.facebook.com/sharer/sharer.php?u=<link>`.
- **Confirmação** (R7, depende da L8): "Copiar link" troca para "Link copiado" por 2 segundos.
- **Imagem** (depende da L7): PNG gerado no navegador com o `canvas`, com o resumo do modal.

## Contrato da API

Convenções do ADR-011. As rotas `/me` usam `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L1).

### `GET /api/v1/collections/me/sharing` — R1, R3, R8

- **Sucesso:** `200`

  ```json
  { "data": { "isPublic": true, "shareLink": "daniel", "username": "daniel",
      "summary": { "albums": 4, "ownedCards": 184, "duplicates": 28,
        "albumsProgress": [ { "albumId": "uuid", "title": "Copa do Mundo 2026", "progressPercentage": 79.63 } ] } } }
  ```

  `shareLink: null` enquanto não foi gerado; `username: null` sem nome de usuário.

- **Erros:** `401 UNAUTHORIZED`, `403 FORBIDDEN` (R1).

### `PATCH /api/v1/collections/me` — R8 (depende da L4)

- **Entrada:** `{ "isPublic": true }`
- **Sucesso:** `200` `{ data: { isPublic, shareLink } }`
- **Erros:** `400 VALIDATION_ERROR` (sem `isPublic` booleano), `401`, `403` (R1).

### `POST /api/v1/collections/me/share-link` — R1, R3

- **Sucesso:** `200` `{ "data": { "shareLink": "daniel" } }` (idempotente: o mesmo link ao gerar de novo)
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L1) | R1 |
  | 422 | `COLLECTION_PRIVATE` | `is_public = false` | R8 |
  | 422 | `USERNAME_REQUIRED` | usuário sem `username` (depende da L10) | R3 |
  | 409 | `SHARE_LINK_TAKEN` | outro registro já usa o mesmo `share_link` (índice único) | R3 |

### `GET /api/v1/collections/shared/:shareLink` — R9

- **Acesso:** público
- **Sucesso:** `200`

  ```json
  { "data": { "owner": { "username": "daniel", "name": "Daniel" },
      "albums": [ { "albumId": "uuid", "title": "Copa do Mundo 2026", "coverUrl": "https://…",
        "totalCards": 54, "ownedCards": 43, "progressPercentage": 79.63 } ] } }
  ```

- **Erros:** `404 COLLECTION_NOT_FOUND` (inexistente ou privada) (R9).

### `GET /api/v1/collections/shared/:shareLink/albums/:albumId/cards` — R9

- **Acesso:** público
- **Entrada (query):** `page`, `pageSize` (padrão 24, como a CCD013)
- **Sucesso:** `200` `{ data: [ { cardId, number, name, frontImageUrl, status, quantity } ], meta }` — o mesmo item da
  CCD013, sem preço.
- **Erros:** `404 COLLECTION_NOT_FOUND`, `404 COLLECTION_ALBUM_NOT_FOUND` (R9).

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-sharing.repository.ts` | lê e grava `is_public` e `share_link`, busca por `share_link`, lê `username` | R3, R8, R9 |
| `collection-sharing.service.ts` + `.spec.ts` | link idempotente, privada, sem nome de usuário, resumo, página pública | R3, R8, R9 |
| `collection.errors.ts` | `COLLECTION_PRIVATE`, `USERNAME_REQUIRED`, `SHARE_LINK_TAKEN`, `COLLECTION_NOT_FOUND` | R3, R8, R9 |
| `collection.validator.ts` · `.controller.ts` · `.routes.ts` · `.swagger.ts` | as 5 rotas; `/shared/*` montadas antes do `authenticate` de `/me` | R1, R9 |
| `tests/integration/collection-sharing.spec.ts` | rotas de ponta a ponta | CA1, CA2, CA5–CA7 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-sharing.types.ts` · `.api.ts` · `.queries.ts` · `.links.ts` | contrato, queries, mutations e os links das redes | R3–R6 |
| `collection-sharing.image.ts` + `.spec.ts` | PNG do resumo com o `canvas` (depende da L7) | R4 |
| `components/ShareCollectionDialog/` | "Compartilhar coleção", "LINK PÚBLICO", "Copiar link" / "Link copiado", "COMPARTILHAR EM" (WhatsApp, X, Facebook, "Baixar imagem"), o interruptor "Coleção pública", o resumo, o estado privado, o aviso sem nome de usuário, o erro da API, "Fechar" e "✕", com o `Modal`; frame `1160-9616` | R3–R8, R10, R11 |
| `components/ShareCollectionButton/` | botão "Compartilhar coleção"; frames `1122-17812` e `1160-23080` | R2, R11 |
| `pages/CollectionHomePage/` (CCD007) · `pages/MyAlbumsPage/` (CCD008) | o botão nos dois lugares (depende da L11) | R2 |
| `pages/SharedCollectionPage/` | página pública `/u/:username` com os álbuns e as cartas, no estilo do perfil público (sem frame: L3); `LoadingState`, `ErrorState` e o `404` | R9 |
| `collection.routes.ts` · `src/routes/paths.ts` · `app/router.tsx` | `sharedCollection: '/u/:username'` nas rotas do `PublicLayout` | R9 |

- **Componentes reaproveitados:** `Modal`, `Button`, `Checkbox` (ou o interruptor do `Settings`), `Toast`, `Icon`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | link e redes com a coleção pública; `share_link` gravado | `collection-sharing.service.spec.ts` · integração · `ShareCollectionDialog.spec.tsx` |
| CA2 | mesmo link ao gerar de novo | `collection-sharing.service.spec.ts` · integração |
| CA3 | "Copiar link" grava na área de transferência e mostra "Link copiado" | `ShareCollectionDialog.spec.tsx` |
| CA4 | "WhatsApp" abre `wa.me` com o link | `collection-sharing.links.spec.ts` · `ShareCollectionDialog.spec.tsx` |
| CA5 | privada: aviso e link e redes desabilitados; `422 COLLECTION_PRIVATE` | `collection-sharing.service.spec.ts` · integração · `ShareCollectionDialog.spec.tsx` |
| CA6 | página pública mostra os 4 álbuns e as cartas; privada depois, `404` | integração · `SharedCollectionPage.spec.tsx` |
| CA7 | `401` sem token | integração |
| CA8 | API fora do ar: mensagem de erro no modal | `ShareCollectionDialog.spec.tsx` |
| CA9–CA11 | prints em 1280 px iguais a `1160-9616`, `1122-17812` e `1160-23080`; 375, 768 e 1024 px sem quebra | revisão visual |

## Decisões técnicas

- `share_link` guarda o nome de usuário (L2) para o link bater com o `/u/<nome de usuário>` do Figma. **Risco:** se o
  cliente trocar o `username` (CCD048), o link antigo para de funcionar; o service grava o `share_link` novo na troca do
  nome, desde que a L2 seja aprovada. A CCD048 precisa chamar esse ajuste.
- A página pública lê a coleção pelo `share_link`, não pelo `username`, para que a coleção dependa só da própria tabela.
- Sem SDK de rede social nem biblioteca de imagem: links de compartilhamento e `canvas` do navegador.
