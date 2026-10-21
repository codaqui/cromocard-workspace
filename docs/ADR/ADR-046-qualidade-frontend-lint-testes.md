# ADR-046 — Qualidade do frontend: ESLint, Prettier, `tsc` e Vitest + Testing Library

- **Status:** Aceito
- **Data:** 2026-10-17
- **Decisores:** Equipe CromoCard

## Contexto

O ADR-008 define a qualidade do backend. O frontend precisa das mesmas garantias automáticas, mais
as regras de arquitetura do ADR-040, e do critério de code review do projeto (Clean Code, SOLID e
Object Calisthenics) aplicado a componentes React.

## Decisão

### Lint, formatação e tipos

- **ESLint** (flat config) com `typescript-eslint` *type-checked*, `react-hooks` e `react-refresh`.
- Regras que aplicam Clean Code e Object Calisthenics:

  | Regra | Valor | Efeito |
  |---|---|---|
  | `max-depth` | 1 | Um nível de indentação por função |
  | `max-params` | 3 | Mais que isso vira objeto de props |
  | `max-lines-per-function` | 25 (fora dos testes) | Componente grande vira componentes menores |
  | `no-else-return` | erro | Retorno antecipado em vez de `else` |
  | `no-console` | erro | Igual ao backend |
  | `consistent-type-imports` | erro | `import type` para tipos |

- Regras de arquitetura: importar outra feature só pelo `index.ts`, sair da feature só pelo `@/`
  (ADR-040) e `import.meta.env` só no `config/env.ts` (ADR-045).
- **Prettier** para formatação e **`tsc --noEmit`** para tipos.

### Testes

- **Vitest** com **jsdom** e **Testing Library** (`@testing-library/react`, `user-event` e
  `jest-dom`). Arquivos `*.spec.ts(x)` ao lado do arquivo testado.
- Teste o comportamento que o usuário vê: busque por papel, label ou texto (`getByRole`,
  `getByLabelText`), não por classe CSS ou estado interno.
- `renderWithProviders` (`src/test/`) monta o TanStack Query, o contexto de sessão e um roteador em
  memória, para testar rotas e guards com o papel que quiser.
- Prioridade de teste: `lib/` (erros, JWT), guards de rota, hooks e componentes com regra (como os
  formulários).
- Cobertura com `npm run test:cov` (v8), ainda sem limite mínimo no CI.

### CI

GitHub Actions em todo push e PR: `format:check` → `lint` → `typecheck` → `test` → `build` e,
depois, o build da imagem Docker. O Dependabot atualiza as dependências.

## Alternativas consideradas

- **Jest:** precisaria de configuração extra para TypeScript, ESM e aliases. O Vitest reaproveita
  a configuração do Vite (mesmo motivo do ADR-008).
- **Testes E2E (Playwright, Cypress) desde já:** ficam para quando houver fluxos completos com
  login.

## Consequências

- As regras de tamanho forçam componentes e funções pequenos. Por exemplo, o resultado da lista de
  usuários virou o componente `UsersListResult` para caber no limite.
- Diferenças em relação ao backend: ainda não há husky/lint-staged (o CI é a barreira) nem limite
  mínimo de cobertura. Quando entrarem, registre a mudança num ADR novo.

## Referências

- ADR-008, ADR-017, ADR-040, ADR-045
- `apps/cromocard-frontend/eslint.config.mjs`, `vite.config.ts`, `.github/workflows/ci.yml`
