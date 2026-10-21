# ADR-039 — Stack do frontend web: React 19 + TypeScript + Vite + React Router

- **Status:** Aceito
- **Data:** 2026-10-17
- **Decisores:** Equipe CromoCard
- **Substitui:** ADR-022

## Contexto

O ADR-022 escolheu React + Vite para a Web e o BackOffice, mas não definiu versões nem as
bibliotecas de rotas, dados, formulários, estilo e testes. Sem isso, cada feature resolveria esses
problemas de um jeito.

## Decisão

| Peça | Escolha | Detalhe |
|---|---|---|
| Runtime de build | Node.js 24 | Fixado em `.nvmrc` e `engines`, o mesmo do backend (ADR-002) |
| UI | React 19 | Componentes de função e hooks |
| Linguagem | TypeScript `strict` | Mais `noUncheckedIndexedAccess`, `verbatimModuleSyntax` e `isolatedModules` |
| Build e dev server | Vite | O Vitest reaproveita a mesma configuração |
| Rotas | React Router (data router) | `createBrowserRouter`, rotas aninhadas por layout e `lazy` por feature |
| Dados do servidor | TanStack Query + Axios | ADR-041 |
| Formulários | React Hook Form + Zod | ADR-042 |
| Estilo | CSS Modules + design tokens | ADR-044 |
| Testes | Vitest + Testing Library | ADR-046 |
| Estado global | Só React Context, para a sessão | ADR-043 |

Não há Redux nem Zustand. Quase todo o estado é do servidor (fica no cache do TanStack Query) ou é
local da tela (`useState` em um hook da feature).

## Alternativas consideradas

- **Next.js:** traria SSR e pré-renderização, mas precisa de um servidor Node em produção, troca o
  deploy estático (nginx) por um processo a mais e muda o modelo de rotas. Nenhum caso de uso do
  MVP depende de SEO.
- **TanStack Router:** tipagem de rotas melhor, mas com menos material de estudo que o React Router.
- **Redux Toolkit ou Zustand:** resolvem estado global de cliente, que o projeto quase não tem. O
  estado que vem da API fica melhor num cache de servidor (ADR-041).
- **Create React App:** sem manutenção, já descartado no ADR-022.

## Consequências

- Build rápido e HMR. O frontend usa a mesma linguagem, o mesmo Node, o mesmo Zod e o mesmo
  Vitest que o backend.
- Sem SSR: as páginas públicas não são pré-renderizadas. O link público de "Compartilhar coleção"
  (CCD012) terá prévia genérica nas redes sociais. Se a prévia personalizada virar requisito, ela
  pode vir de uma rota da API que devolve as meta tags, ou de pré-renderização (ADR novo).

## Referências

- ADR-022, ADR-002, ADR-041 a ADR-046
- `apps/cromocard-frontend/package.json`, `tsconfig.json`, `vite.config.ts`
