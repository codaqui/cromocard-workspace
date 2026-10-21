# ADR-043 — Sessão e controle de acesso no frontend

- **Status:** Aceito
- **Data:** 2026-10-17
- **Decisores:** Equipe CromoCard

## Contexto

O ADR-005 define a autenticação: access token JWT de 15 minutos (`sub`, `role`) e refresh token
opaco, que na web vai em cookie `httpOnly`. O frontend precisa saber quem está logado e qual o
papel, para mostrar a área certa (ADR-038), sem expor o token a ataques de XSS.

## Decisão

- **O access token fica só em memória** (`src/lib/access-token.ts`), nunca em `localStorage` ou
  `sessionStorage`. O refresh token é gerenciado pela API em cookie `httpOnly`, por isso o cliente
  HTTP usa `withCredentials` (ADR-041).
- O `AuthProvider` (`src/contexts/`) expõe `user` (`{ id, role }`) e `signOut`. Os componentes
  usam o hook `useAuth()` (`src/hooks/`).
- O `user` sai do payload do JWT (`sub`, `role`, `exp`), lido em `src/lib/jwt.ts` e validado com
  Zod. Token expirado, malformado ou com papel desconhecido equivale a não ter sessão. O frontend
  **não** verifica a assinatura: quem confia no token é a API.
- Guards de rota (`src/routes/guards/`):
  - `RequireAuth`: sem sessão, vai para `/`.
  - `RequireRole`: sem sessão, vai para `/`; com outro papel, vai para a home do próprio papel
    (`homePathByRole`).
- `signOut` apaga o token e limpa o cache do TanStack Query (`queryClient.clear()`), para que dados
  de um usuário não apareçam para o próximo.
- Um `401` da API chama o `signOut` (ADR-041).
- **Enquanto o backend não tem `/auth`:** o `npm run dev` lê um token gerado à mão em
  `VITE_DEV_ACCESS_TOKEN`. Esse valor só é lido em modo dev e é ignorado no build.

## Alternativas consideradas

- **Access token em `localStorage`:** sobrevive ao F5, mas qualquer script injetado (XSS) consegue
  ler e levar o token.
- **Sessão só por cookie, sem JWT no frontend:** já descartada no ADR-005, por ser pior para o
  mobile e para o WebSocket.
- **SDK de provedor de identidade (Auth0, Firebase):** o ADR-005 já descartou o provedor
  gerenciado.

## Consequências

- O guard do frontend é só navegação. A proteção real é o `authorize(...roles)` da API (ADR-038).
- Como o token vive em memória, um F5 perde a sessão. Quando a feature `auth` existir, o app chama
  `POST /auth/refresh` ao iniciar para recuperar o access token pelo cookie, e o interceptor faz o
  refresh e repete a requisição num `401` (ADR-005).
- O `VITE_DEV_ACCESS_TOKEN` e a seção "Sessão de desenvolvimento" do README do frontend somem
  quando o login existir.

## Referências

- ADR-005, ADR-038, ADR-041
- `apps/cromocard-frontend/src/contexts/AuthProvider.tsx`, `src/lib/jwt.ts`, `src/routes/guards/`
