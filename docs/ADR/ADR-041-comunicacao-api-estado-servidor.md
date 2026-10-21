# ADR-041 — Comunicação com a API e estado do servidor: cliente HTTP único + TanStack Query

- **Status:** Aceito
- **Data:** 2026-10-17
- **Decisores:** Equipe CromoCard

## Contexto

Quase toda tela do CromoCard mostra dados da API: busca, carrega, trata erro, pagina e atualiza
depois de uma ação. Sem um padrão, cada tela escreveria seu próprio `useEffect` com loading, erro,
cache e retry. A API já tem um contrato fixo: envelope `{ data }` / `{ data, meta }` (ADR-011) e
erro `{ error, message, details? }` (ADR-006).

## Decisão

### Cliente HTTP (`src/lib/http.ts`)

- Uma única instância do **Axios**, com `baseURL` `${API_URL}/api/v1` e `withCredentials: true`
  (o refresh token vai em cookie, ADR-005).
- Um interceptor de requisição coloca `Authorization: Bearer <access token>` (ADR-043).
- O objeto `api` desembrulha o envelope: `get`, `post` e `patch` devolvem o `data`; `getPage`
  devolve `{ data, meta }`; `delete` não devolve nada.
- Um `401` avisa a sessão (`onUnauthorized`), que é encerrada (ADR-043).

### Erros (`src/lib/api-error.ts`)

Todo erro vira um `ApiError` (`status`, `code`, `message`, `details`):

| Situação | `code` |
|---|---|
| Corpo no contrato do ADR-006 (validado com Zod) | o `error` da API, por exemplo `USER_NOT_FOUND` |
| Sem resposta do servidor | `NETWORK_ERROR` |
| Corpo fora do contrato (HTML de proxy, por exemplo) | `UNEXPECTED_ERROR` |

As telas mostram `error.message`, que já vem em português da API.

### Estado do servidor

- Dado da API vive **só no TanStack Query**. Nenhum componente chama o `api` direto.
- Cada feature tem `<feature>.api.ts` (funções HTTP tipadas) e `<feature>.queries.ts` (hooks
  `useX` / `useUpdateX` e uma fábrica de chaves, por exemplo `usersKeys.list(params)`).
- Padrões do `QueryClient` (`src/lib/query-client.ts`): `staleTime` de 30 s; até 2 novas
  tentativas só em erro de rede ou 5xx, nunca em 4xx; `ApiError` registrado como o tipo de erro
  padrão.
- Listas paginadas usam `placeholderData: keepPreviousData`, para a tabela não piscar ao trocar de
  página. Mutations atualizam o cache (`setQueryData`) ou invalidam a chave afetada.
- Os tipos de resposta ficam em `<feature>.types.ts`, espelhando o JSON camelCase da API.

## Alternativas consideradas

- **`fetch` nativo:** sem interceptors. O token, o envelope e a conversão de erro teriam de ser
  reescritos à mão.
- **`useEffect` + `useState` por tela:** cache, deduplicação, retry e estado de loading manuais e
  repetidos em toda tela.
- **SWR:** mais simples, mas com menos recursos para mutations e atualização do cache.
- **RTK Query:** resolve o mesmo problema, mas traz o Redux junto (ADR-039).

## Consequências

- Uma tela nova só lida com `isPending`, `isError` e `data`, usando `LoadingState`, `ErrorState` e
  `EmptyState`.
- O contrato é duplicado à mão: os tipos do frontend e os validators do backend precisam mudar
  juntos (risco já apontado no ADR-026). Gerar os tipos a partir do OpenAPI do backend (`/docs`) é
  uma melhoria possível.
- Hoje um `401` encerra a sessão. Quando a feature `auth` existir, o interceptor chama
  `POST /auth/refresh` e repete a requisição antes de desistir (ADR-005).

## Referências

- ADR-005, ADR-006, ADR-011, ADR-043
- `apps/cromocard-frontend/src/lib/http.ts`, `api-error.ts`, `query-client.ts`
