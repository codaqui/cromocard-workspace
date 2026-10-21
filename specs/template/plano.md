# Plano — CCDnnn <Nome>

- **Spec:** [spec.md](spec.md), aprovada em AAAA-MM-DD
- **Repositórios:** backend · frontend
- **Data:** AAAA-MM-DD · **Autor:** <nome>

## Solução

<2 a 4 frases: o fluxo de ponta a ponta, da tela ao banco.>

## Dependências

- <spec ou funcionalidade que precisa existir antes> — <por quê>.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `<tabela>` | não | `create_<tabela>_table` | copiada do DBML |

<!-- Se o DBML precisar mudar, pare: o DER muda antes, num PR de docs, nos três formatos. -->

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.

### `<MÉTODO> /api/v1/<recurso>` — R1, R2

- **Acesso:** público | `authenticate` | `authenticate` + `authorize('<PAPEL>')`
- **Entrada:**

  ```json
  { "campo": "string" }
  ```

- **Sucesso:** `<status>`

  ```json
  { "data": { "id": "uuid" } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 422 | `<ERROR_CODE>` | <regra violada> | R3 |

## Backend — `apps/cromocard-backend`

Domínio `src/domains/<dominio>/`, no modelo de `src/domains/users/` (ADR-004), registrado em `src/routes.ts`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `<dominio>.service.ts` | <regra> | R2 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/<feature>/`, no modelo de `src/features/users/` (ADR-040), rotas registradas no `app/router.tsx`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `pages/<Nome>Page/` | <tela> | R1 |

- **Rotas:** `<caminho>` em `routes/paths.ts`, com <público | `RequireAuth` | `RequireRole role="ADMIN"`>.
- **Estados:** carregando, erro e vazio com `LoadingState`, `ErrorState` e `EmptyState`.
- **Componentes reaproveitados de `src/components/`:** <…>

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | <comportamento> | `<dominio>.service.spec.ts` · `tests/integration/…` · `<Componente>.spec.tsx` |

## Decisões técnicas

- <decisão do "como" que nenhum ADR cobre, e por quê> <!-- decisão de arquitetura vira ADR novo `Proposto` -->
