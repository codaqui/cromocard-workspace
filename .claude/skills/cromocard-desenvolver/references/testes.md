# Testes no CromoCard

Usado pela `/cromocard-desenvolver` (ao escrever) e pela `/cromocard-revisor` (ao revisar). Os exemplos com `arquivo:linha`
são do código real, levantados em 2026-11-09. O que está marcado como **ilustrativo** não existe no projeto.

## A meta

- **Cobertura de 90% a 100%** em linhas, branches, funções e statements, **em cada arquivo criado ou alterado**.
- O número da aplicação inteira é informado e não pode cair. Em 2026-11-09 o backend tinha 79,6% de linhas sem contar a
  integração e o frontend 89,1%.
- Cobertura é consequência. **O que se busca é teste que falha quando o comportamento quebra.** Um arquivo com 100% e
  testes vazios está reprovado.

O limite de 80% no `vitest.config.ts` só olha as services e é mais baixo que esta meta. Por isso, passar no
`npm run test:cov` não basta: meça os arquivos da spec com o comando abaixo.

## O que é um teste real

Todo teste precisa responder sim a estas perguntas:

1. Se eu quebrar a regra, este teste fica vermelho?
2. Ele afirma um resultado que o usuário ou quem chama a API consegue observar?
3. O nome diz o comportamento, com o `CA` quando existir?
4. Só o que é externo está falso? A unidade testada é sempre a de verdade.

**Exemplos reais.**

- `apps/cromocard-frontend/src/features/auth/components/LoginForm/LoginForm.spec.tsx:19` digita como uma pessoa, encontra os
  campos pelo rótulo e confere o e-mail normalizado que sai do formulário.
- `LoginForm.spec.tsx:33` (`CA5`) entrega um erro da API e confere a mensagem no campo e a ausência do alerta geral.
- `apps/cromocard-backend/src/domains/users/users.service.spec.ts:46` usa um repository em memória, que realmente filtra
  `deletedAt`: a service testada é a real, e só a borda com o banco é falsa.
- `apps/cromocard-backend/tests/integration/auth.spec.ts:42` faz a requisição HTTP de verdade, com PostgreSQL de verdade.

## O que testar em cada lugar

| Arquivo | Tipo de teste | O que precisa estar coberto |
|---|---|---|
| `.service.ts` | Unitário, com repository falso pelo construtor | Caminho feliz, cada erro de negócio, cada fluxo alternativo |
| `.repository.ts` | Integração | Soft delete, filtros, paginação, restauração |
| `.routes.ts` e `.controller.ts` | Integração com `supertest` | Status, formato `{ data }`, `401`, `403`, `422`, `409` |
| `.validator.ts` | Unitário | Limites aceitos e recusados de cada campo |
| `.job.ts`, `lib/`, `providers/` | Unitário | Sucesso, falha e borda |
| `lib/`, `utils/`, `<f>.format.ts` no frontend | Unitário | Entradas de borda e formatos |
| Hooks e `.schemas.ts` | Unitário ou por componente | Regras e mensagens em pt-BR |
| Componentes | Testing Library, por papel, rótulo ou texto | Interação, regra e estados |
| Páginas | Testing Library com `renderWithProviders` | Carregando, erro, vazio, sucesso e permissão |
| Guards | `renderWithProviders` | Cada redirecionamento |

**Cada `CA` da spec tem ao menos um teste com o ID no nome.** Cada fluxo alternativo do caso de uso também.

Arquivos só de tipos, `index.ts` e `.d.ts` não contam na meta. Responsividade não se testa aqui, porque o jsdom não mede
layout: ela é validada no navegador.

## O que não vale

| Reprovado | Por que é ruim |
|---|---|
| Teste sem `expect`, ou só `expect(x).toBeDefined()` | Passa com o comportamento errado |
| Renderizar só para "passar pela linha" | Sobe o número sem proteger nada |
| Conferir só que um mock foi chamado, sem olhar o resultado | Testa a implementação, e quebra ao refatorar |
| Mockar a própria unidade testada | Testa o mock |
| Expected copiado da mesma fórmula do código | Repete o erro nos dois lados |
| Snapshot de tela inteira | É aprovado sem que ninguém leia |
| Buscar por classe CSS ou `data-testid` havendo papel ou texto | Preso à estrutura, não ao que o usuário vê |
| `setTimeout` para esperar | Instável. Use `findBy…` ou `waitFor` |

Exemplo ilustrativo do que não fazer:

```ts
it('renderiza', () => {
  render(<OrdersTable rows={[]} />);
  expect(true).toBe(true);
});
```

**Nunca fique verde na marra:** `.skip`, `.only`, teste apagado ou enfraquecido, limite de cobertura reduzido, arquivo
excluído da cobertura, `/* v8 ignore */`, `eslint-disable`, `@ts-ignore`, `as any` e regra de lint desligada.

## Prova da quebra

Para confirmar que um teste é real: nas regras mais importantes da spec, inverta temporariamente a condição (troque `!==`
por `===`, remova o filtro `notDeleted`, retire o `authorize`), rode os testes do arquivo, confirme que ficou vermelho e
desfaça. Se continuar verde, o teste não protege essa regra.

## Rodar tudo

Sempre a lista inteira, numa rodada só, depois da última alteração.

**Backend** (`docker compose up -d`, e o banco `cromocard_test` criado no PostgreSQL local). A integração usa esse banco
de teste, nunca o de desenvolvimento:

```bash
export DATABASE_URL=postgresql://cromocard:cromocard@localhost:5432/cromocard_test
npx prisma validate && npx prisma migrate deploy
npm run format:check && npm run lint && npm run typecheck && npm run test:cov && npm run build
```

O `test:cov` já inclui os testes de integração.

**Frontend:**

```bash
npm run format:check && npm run lint && npm run typecheck && npm run test:cov && npm run build
```

## Medir os arquivos alterados

Na raiz do app, com `<base>` igual a `origin/develop`:

```bash
ARQUIVOS=$(git diff --name-only --diff-filter=AM <base>...HEAD -- src | grep -E '\.tsx?$' | grep -vE '\.spec\.|\.d\.ts$|/index\.ts$|\.types\.ts$|/(server|ws-server)\.ts$|/app/(main|router)\.tsx$|^src/test/')
npx vitest run --coverage $(printf -- '--coverage.include=%s ' $ARQUIVOS) \
  --coverage.thresholds.perFile --coverage.thresholds.lines=90 --coverage.thresholds.functions=90 \
  --coverage.thresholds.branches=90 --coverage.thresholds.statements=90 \
  --coverage.reportsDirectory=<scratchpad>/cobertura --coverage.reporter=text
```

Se ainda não houver commit, inclua os arquivos de `git status --short`. No backend, rode com o `DATABASE_URL` acima, para
contar a integração. Um arquivo abaixo de 90% faz o comando falhar. O CI dos dois apps aplica a mesma medição em todo PR.

## Modelo de achado

```
`features/marketplace/orders/hooks/useOrders.spec.ts:12` (Testes) · Bloqueante
Problema: o teste só confere que `ordersApi.list` foi chamado.
Por que é ruim: a lista pode vir vazia ou errada e ele continua verde, então a cobertura sobe sem proteger o `CA3`.
Sugestão: renderize a página com a resposta falsa e confira as linhas exibidas.
```

Exemplo ilustrativo.
