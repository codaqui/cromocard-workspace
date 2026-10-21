# ADR-040 — Estrutura de pastas do frontend por feature

- **Status:** Aceito
- **Data:** 2026-10-17
- **Decisores:** Equipe CromoCard

## Contexto

O backend organiza o código por domínio (ADR-004 e ADR-020). O frontend precisa de uma estrutura
equivalente, para que uma especificação seja rastreada do caso de uso até a tela pelo mesmo nome de
domínio e para que seis pessoas trabalhem em features diferentes sem editar os mesmos arquivos.

## Decisão

### Estrutura

```
src/
├── app/            casca: main.tsx, App.tsx (providers), router.tsx (junta todas as rotas), layouts/
├── features/       um módulo por domínio, com os mesmos nomes de src/domains do backend
│   ├── users/      feature modelo
│   ├── auth/  catalog/  collection/  community/  chat/  notifications/  admin/
│   └── marketplace/listings/  orders/  payments/
├── components/     componentes reutilizáveis SEM regra de negócio, um por pasta (Button/, TextField/…)
├── config/         env.ts: lê e valida as variáveis de ambiente (ADR-045)
├── lib/            bibliotecas configuradas: http.ts, api-error.ts, query-client.ts, zod.ts, jwt.ts
├── routes/         paths.ts (todas as URLs) e guards/ (ADR-043)
├── contexts/       estado global do app: só a sessão
├── hooks/          hooks reutilizáveis entre features (useAuth, useDebounce)
├── types/          tipos compartilhados: envelope da API, papéis do usuário
├── utils/          funções puras (formatDate, cn)
├── styles/         reset.css, tokens.css, globals.css (ADR-044)
└── test/           setup do Vitest e renderWithProviders
```

### Dentro de uma feature

| Arquivo / pasta | Papel |
|---|---|
| `pages/` | Telas ligadas a uma URL. Chamam os hooks de query e tratam carregando, erro e vazio |
| `components/` | Componentes usados só nesta feature. Recebem dados por props |
| `hooks/` | Lógica de formulário, filtros e estado local da feature |
| `<feature>.api.ts` | Chamadas HTTP (ADR-041) |
| `<feature>.queries.ts` | Hooks do TanStack Query e fábrica de query keys (ADR-041) |
| `<feature>.schemas.ts` | Schemas Zod dos formulários, espelhando o `.validator.ts` do backend (ADR-042) |
| `<feature>.types.ts` | Tipos do domínio, espelhando o JSON da API |
| `<feature>.labels.ts` | Textos de exibição dos enums (`ADMIN` → "Administrador") |
| `<feature>.routes.ts` | Rotas da feature, com `lazy` |
| `index.ts` | API pública da feature: o que o resto do app pode importar |

Fluxo: `page → hook (.queries.ts) → .api.ts → lib/http.ts → API`.

### Regras

1. **Uma feature importa outra só pelo `index.ts`** (`@/features/<nome>`). O ESLint bloqueia
   `@/features/*/*`.
2. **Para sair da pasta da feature, use o alias `@/`.** O ESLint bloqueia `../../../`.
3. **`components/` da raiz não tem regra de negócio** nem chama a API. Componente que conhece um
   domínio fica na feature.
4. **Um componente por pasta:** `Button/Button.tsx`, `Button.module.css` e, se houver,
   `Button.spec.tsx`.
5. **As URLs ficam em `src/routes/paths.ts`.** Nenhum componente escreve uma URL literal.
6. **Só o `router.tsx` junta as rotas.** Cada feature exporta as suas pelo `index.ts`.
7. Nomes: pastas de feature e arquivos `<feature>.<papel>.ts` em minúsculo e em inglês, iguais ao
   domínio do backend (`users` ↔ `src/domains/users`). Componentes e páginas em `PascalCase`.

## Alternativas consideradas

- **Pastas por tipo na raiz** (`src/pages`, `src/services`, `src/hooks`): cada feature fica
  espalhada, e o acoplamento entre features não aparece. É o mesmo motivo do ADR-004.
- **Feature-Sliced Design:** camadas (`entities`, `widgets`, `processes`…) com vocabulário próprio,
  pesadas para o tamanho do projeto.
- **Atomic Design** (`atoms`, `molecules`…): organiza por tamanho do componente, não por domínio.

## Consequências

- Criar uma feature = copiar a estrutura de `users/`, exportar as rotas no `index.ts` e registrá-las
  no `router.tsx`.
- Frontend e backend usam os mesmos nomes de domínio, então o SDD liga spec, endpoint e tela sem
  tradução.
- As regras 1 e 2 são checadas pelo lint. As demais dependem do code review.

## Referências

- ADR-004, ADR-020
- `apps/cromocard-frontend/README.md` (seção "Estrutura"), `eslint.config.mjs`
