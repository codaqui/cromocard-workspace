# Arquitetura do frontend (`apps/cromocard-frontend`)

Um SPA para Web e BackOffice (ADR-038) em React 19, TypeScript strict e Vite. Decisões nos ADRs 038–046; regras em
`.claude/rules/frontend.md`. **Modelo a copiar: `src/features/users/`.**

Este mapa foi levantado da branch `feature/layouts-figma` em 2026-11-09. Se um arquivo citado não existir mais, confie
no `git -C apps/cromocard-frontend ls-files`.

## Caminho de um dado

```
page → hook de query (<f>.queries.ts) → <f>.api.ts → lib/http.ts → API
```

Uma feature só importa outra pelo `index.ts`. Componente nunca chama a API direto. Dado da API só no TanStack Query; o
único estado global é a sessão.

## Pastas de `src/`

### `app/`: inicialização e cascas das áreas

| Arquivo | Faz |
|---|---|
| `main.tsx` | Ponto de entrada |
| `App.tsx` | Providers e `RouterProvider` |
| `router.tsx` | Único lugar que junta as rotas das features, com os guards e os layouts |
| `layouts/PublicLayout/` | Área pública, para visitantes |
| `layouts/CustomerLayout/` | Área do cliente e do vendedor, atrás do `RequireAuth` |
| `layouts/AdminLayout/` | BackOffice em `/backoffice`, tema `backoffice`; menu em `adminMenu.ts`, ícones em `assets/` |
| `layouts/SiteShell/` | Casca do site (topbar e menu lateral), tema `site`; itens em `siteMenu.ts` |

### `features/<dominio>/`: as telas e regras de cada área

Mesmos nomes do `src/domains` do backend, com subpastas iguais (`admin/dashboard`, `catalog/requests`,
`marketplace/listings`).

| Arquivo | Responsabilidade |
|---|---|
| `pages/<Nome>Page/` | A tela da rota: junta hooks e componentes e trata carregando, erro e vazio |
| `components/<Nome>/` | Componentes só desta feature, um por pasta, com `.module.css` ao lado |
| `hooks/use<Nome>Form.ts` | Lógica dos formulários (React Hook Form + Zod). O componente recebe `onSubmit`, `isSubmitting` e `errorMessage` por props |
| `hooks/use<Nome>.ts` | Outros hooks da feature, como filtros de lista |
| `<f>.api.ts` | Chamadas HTTP, sempre por `lib/http.ts` |
| `<f>.queries.ts` | Fábrica de query keys e hooks do TanStack Query |
| `<f>.schemas.ts` | Zod do formulário, espelho do `.validator.ts` do backend |
| `<f>.types.ts` | Tipos da API e da feature |
| `<f>.labels.ts` | Rótulos em pt-BR dos enums |
| `<f>.routes.ts` | `RouteObject[]` com `lazy`, usando caminhos de `routes/paths.ts` |
| `<f>.format.ts`, `<f>.period.ts` | Funções puras de apoio, quando houver (exemplo em `admin/dashboard`) |
| `assets/` | SVGs só desta feature |
| `index.ts` | API pública: só o que outra feature ou o `router.tsx` pode usar |

Rota com `underConstructionRoute` é tela ainda não feita: troque pelo `lazy` da página real quando a spec chegar nela.

### `components/`: visuais, reutilizáveis, sem regra de negócio

**Procure aqui antes de criar qualquer coisa.** Um componente por pasta, com o `.module.css` ao lado.

| Grupo | Componentes |
|---|---|
| Formulário | `TextField`, `Textarea`, `Select`, `Checkbox`, `FileUpload`, `SearchBar`, `FormField` (rótulo, dica e erro; `field-ids.ts` liga os ids de acessibilidade), `FormError` |
| Ação e navegação | `Button`, `NavItem`, `Tabs`, `Pagination`, `PeriodFilter`, `UserMenu`, `Header`, `BrandLogo` |
| Dados | `DataTable` (rola dentro do próprio contêiner), `KpiCard`, `Badge`, `Icon` (com `icon-paths.ts`) |
| Sobreposição | `OverlayDialog` (base, posição `center` ou `right`), `Modal`, `Drawer`, `ConfirmDialog` (com `useConfirmDialogForm.ts`), `Toast` |
| Estados e páginas | `LoadingState`, `ErrorState`, `EmptyState`, `NotFoundPage`, `UnderConstructionPage` (com `underConstructionRoute.ts`) |

### Demais pastas

| Arquivo | Faz |
|---|---|
| `config/env.ts` | Único uso de `import.meta.env`, validado com Zod; `API_URL` vem em runtime de `/env.js` |
| `contexts/AuthContext.ts` · `AuthProvider.tsx` | Sessão: access token em memória e renovação pelo cookie |
| `hooks/useAuth.ts` | `{ user, isRestoringSession, hasSignedOut, signIn, signOut }` |
| `hooks/useSignOut.ts` | Ação de sair |
| `hooks/useApiFieldErrors.ts` | Leva os `details` do erro da API para os campos do formulário |
| `hooks/useDebounce.ts` | Atraso para buscas |
| `hooks/useOverlay.ts` | Foco preso, Esc e trava de rolagem das sobreposições |
| `lib/http.ts` | Cliente Axios único: `/api/v1`, Bearer, desembrulha `{ data }`, trata `401` |
| `lib/api-error.ts` | Classe `ApiError` (`status`, `code`, `message`, `details`) |
| `lib/access-token.ts` · `jwt.ts` | Token em memória e leitura do payload |
| `lib/query-client.ts` | Configuração do TanStack Query |
| `lib/google-identity.ts` | Login com Google |
| `lib/zod.ts` | O `z` em pt-BR: importe sempre daqui |
| `lib/reason.ts` | Schema do campo "motivo", espelho do backend |
| `routes/paths.ts` | **Todas as URLs** e `homePathByRole` |
| `routes/RoleHomeRedirect.tsx` | Envia para a home do papel do usuário |
| `routes/guards/` | `RequireAuth`, `RequireRole`, `RedirectIfAuthenticated` e `loginRedirect.ts`. Só navegação: quem autoriza é a API |
| `styles/tokens.css` | **Todas as cores, espaços, tamanhos e fontes**, com os temas `backoffice`, `site` e `auth` em `data-theme` |
| `styles/globals.css` · `reset.css` | Estilos globais |
| `test/renderWithProviders.tsx` · `setup.ts` | Render com providers e configuração dos testes |
| `test/fakeAccessToken.ts` · `fakeGoogleIdentity.ts` | Falsos para os testes |
| `types/api.ts` · `authenticated-user.ts` | Tipos globais |
| `utils/cn.ts` · `formatDate.ts` | Junta classes e formata datas |
| `assets/` | Imagens globais importadas no código |

## Fora de `src/`

`public/` guarda arquivos servidos como estão (`env.js`, favicon, `images/`). `docker/` tem o Dockerfile, o nginx e o
`write-env.sh` da imagem.

## Tela nova, na ordem

1. `<f>.types.ts`, `<f>.schemas.ts` e `<f>.labels.ts`.
2. `<f>.api.ts` e `<f>.queries.ts`, com o contrato do plano.
3. Token novo em `styles/tokens.css` se o Figma trouxer um valor que não existe.
4. Componentes, reaproveitando `components/` e já responsivos.
5. Página, com carregando, erro e vazio.
6. Caminho em `paths.ts`, rota em `<f>.routes.ts`, export no `index.ts`.
7. `router.tsx` só se for um grupo de rotas novo.
8. Testes `*.spec.ts(x)` ao lado do arquivo, com Testing Library (papel, label ou texto) e os `CA` no nome.

## Regras que mais reprovam

- Sem comentários no código; sem `console.log`; para sair da feature, alias `@/`.
- ESLint: `max-depth` 1, `max-params` 3, `max-lines-per-function` 25, `no-else-return`.
- CSS Modules e só `var(--…)`: nunca cor ou espaçamento solto. Sem MUI, Chakra ou Tailwind.
- Token de acesso nunca no `localStorage`.
- Não copie o CSS gerado pelo Figma: reproduza o visual com `components/` e os tokens.
