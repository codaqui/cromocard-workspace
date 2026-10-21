---
paths:
  - "apps/cromocard-frontend/**"
---

# Frontend (`apps/cromocard-frontend`) — arquitetura decidida nos ADRs 038–046

Repositório próprio (submódulo). Rode git com `git -C apps/cromocard-frontend …`; a branch base é `develop`.

## Comandos

`npm ci` · `cp .env.example .env` · `npm run dev` (http://localhost:5173, precisa da API em
http://localhost:3000) · `npm run format:check` · `npm run lint` · `npm run typecheck` · `npm test` ·
`npm run test:cov` · `npm run build`. Sessão de desenvolvimento (token gerado à mão): README do frontend.

## Estrutura

- **Um SPA para Web e BackOffice** (ADR-038): área Pública (`PublicLayout`), Cliente (`CustomerLayout` +
  `RequireAuth`) e BackOffice em `/backoffice` (`AdminLayout` + `RequireRole role="ADMIN"`); rotas das features
  com `lazy`. O mobile (React Native) é outro app. Guard do frontend é só navegação: quem autoriza é a API.
- **Stack** (ADR-039): React 19 + TypeScript strict (`noUncheckedIndexedAccess`) + Vite + React Router (data
  router) · TanStack Query + Axios · React Hook Form + Zod · CSS Modules · Vitest + Testing Library.
  Sem Redux/Zustand: o único estado global é a sessão (Context).
- **Estrutura do `src`** (ADR-040): `app/` (main, App, `router.tsx`, `layouts/`), `features/<dominio>/` com os
  mesmos nomes de `src/domains` do backend, `components/` (sem regra de negócio, um por pasta), `config/`, `lib/`,
  `routes/` (`paths.ts` + `guards/`), `contexts/`, `hooks/`, `types/`, `utils/`, `styles/`, `test/`.
  A feature `src/features/users/` é o **modelo** para as demais.
- **Arquivos por feature** (ADR-040): `pages/`, `components/`, `hooks/`, `<f>.api.ts`, `<f>.queries.ts`,
  `<f>.schemas.ts`, `<f>.types.ts`, `<f>.labels.ts`, `<f>.routes.ts` e `index.ts` (API pública).
  Fluxo: page → hook de query → `.api.ts` → `lib/http.ts`. Uma feature importa outra **só pelo `index.ts`**;
  para sair da feature, alias `@/` (os dois checados pelo ESLint). URLs só em `routes/paths.ts`; só o `router.tsx`
  junta as rotas. Componentes e páginas em `PascalCase`, uma pasta por componente com o `.module.css` ao lado.

## Regras

- **API** (ADR-041): cliente único `lib/http.ts` (`/api/v1`, `withCredentials`, `Bearer`, desembrulha
  `{ data }` / `{ data, meta }`); todo erro vira `ApiError` (`status`, `code`, `message`, `details`); `401` →
  `signOut`. Dado da API só no TanStack Query (`staleTime` 30 s, sem retry em 4xx), com fábrica de query keys
  por feature; componente nunca chama o `api` direto. Telas tratam carregando/erro/vazio com
  `LoadingState`/`ErrorState`/`EmptyState`.
- **Formulários** (ADR-042): React Hook Form + Zod; `<f>.schemas.ts` espelha o `.validator.ts` do backend; Zod
  sempre de `@/lib/zod` (mensagens pt-BR); lógica em `hooks/use<Nome>Form.ts`, e o componente do formulário
  recebe `onSubmit`/`isSubmitting`/`errorMessage` por props, sem conhecer a API.
- **Sessão** (ADR-043): access token só em memória (nunca `localStorage`), refresh em cookie `httpOnly`;
  `useAuth()` → `{ user: { id, role }, signOut }`; `signOut` limpa o cache do Query. Até existir `/auth`, o dev
  usa `VITE_DEV_ACCESS_TOKEN` (ignorado no build).
- **Estilos** (ADR-044): CSS Modules + tokens em `styles/tokens.css` — só `var(--…)`, nunca cor ou espaçamento
  solto; sem MUI/Chakra/Tailwind; os tokens seguem as variáveis do Figma.
- **Telas a partir do Figma**: a documentação manda no conteúdo (campos, ações, mensagens, regras), o Figma manda
  no visual. Antes de implementar uma tela, rode `/conferir-tarefa`. Reaproveite `src/components/` e os tokens em vez
  de copiar o CSS gerado pelo Figma.
- **Config** (ADR-045): `import.meta.env` só em `config/env.ts` (validado com Zod); `API_URL` em runtime via
  `/env.js` (`window.__ENV__`), uma imagem nginx sem root para homolog e produção. Nada de segredo no frontend.
- **Código sem comentários**, como no backend.

## Qualidade (ADR-046)

- ESLint type-checked com `max-depth` 1, `max-params` 3, `max-lines-per-function` 25, `no-else-return`,
  `no-console`; Prettier; `tsc`.
- Testes `*.spec.ts(x)` ao lado do arquivo, com Testing Library (busca por papel, label ou texto) e
  `renderWithProviders` para rotas e guards. Prioridade: `lib/`, guards, hooks e componentes com regra.
- CI: format → lint → typecheck → test → build → imagem Docker. Ainda sem husky nem limite de cobertura.
