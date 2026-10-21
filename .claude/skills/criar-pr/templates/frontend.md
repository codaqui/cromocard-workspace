## O que foi feito
<!-- Resumo em 1 a 3 frases. Que tela ou comportamento muda para o usuário? -->

## Card do Azure Boards
<!-- Ex.: AB#120 — CCD014 Marcar Carta como Possuo -->
AB#

## Spec
<!-- Ex.: specs/CCD014-marcar-carta-como-possuo/ — requisitos R1–R4 · tarefas T6–T9. Sem spec: "sem spec salva". -->

## Tela no Figma
<!-- Link do frame (com node-id) e o veredito do /conferir-tarefa: bate, ou o que divergiu e como foi tratado. -->

## Tipo de mudança
- [ ] `feat` — funcionalidade nova
- [ ] `fix` — correção de bug
- [ ] `refactor` — sem mudança de comportamento
- [ ] `test` / `docs` / `chore` / `ci`

## Como testar
<!-- Passo a passo: rota no navegador, papel do usuário (CUSTOMER, SELLER, ADMIN), dados e resultado esperado. -->
1.
2.

## Checklist
- [ ] Segue a estrutura da feature (pages · components · hooks · `.api` · `.queries` · `.schemas` · `.types` · `.routes` · `index`)
- [ ] Outra feature importada só pelo `index.ts`; chamada à API só no `.api.ts`/`.queries.ts`
- [ ] Dados da API pelo TanStack Query; a tela trata carregando, erro e vazio
- [ ] Formulários com React Hook Form + Zod; o schema espelha o validator do backend
- [ ] Estilo com CSS Modules e tokens (`var(--…)`), sem valor solto; visual conforme o Figma
- [ ] Rotas novas em `routes/paths.ts`, com o guard certo (`RequireAuth`/`RequireRole`)
- [ ] Testes `.spec.tsx` criados/atualizados (Testing Library, por papel, label ou texto)
- [ ] `npm run format:check`, `lint`, `typecheck`, `test` e `build` passam
- [ ] Variáveis novas no `env.ts`, no `.env.example` e no README; nenhum segredo no frontend
- [ ] Sem `console.log`, sem código comentado

## Revisão
- [ ] Passou pelo `/revisar-codigo` (padrões e spec)

## Observações para o revisor
<!-- Decisões tomadas, dúvidas, pontos de atenção. Prints da tela ajudam. -->
