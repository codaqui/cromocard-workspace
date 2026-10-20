## O que foi feito
<!-- Resumo em 1 a 3 frases. O que muda para o usuário ou para o sistema? -->

## Card do Azure Boards
<!-- Ex.: AB#120 — CCD014 Marcar Carta como Possuo -->
AB#

## Spec
<!-- Ex.: specs/CCD014-marcar-carta-como-possuo/ — requisitos R1–R4 · tarefas T1–T5. Sem spec: "sem spec salva". -->

## Tipo de mudança
- [ ] `feat` — funcionalidade nova
- [ ] `fix` — correção de bug
- [ ] `refactor` — sem mudança de comportamento
- [ ] `test` / `docs` / `chore` / `ci`

## Como testar
<!-- Passo a passo para quem vai revisar. Inclua a rota, o payload e o resultado esperado. -->
1.
2.

## Checklist
- [ ] Segue a estrutura de domínio (routes · controller · service · repository · validator · errors · swagger · module)
- [ ] Nenhuma regra de negócio no controller; nenhum import de repository de outro domínio
- [ ] Entradas validadas com Zod
- [ ] Consultas filtram `deletedAt: null`; exclusão é soft delete
- [ ] Rotas protegidas com `authenticate`/`authorize`; ação administrativa grava `audit_logs`
- [ ] Testes `.spec.ts` criados/atualizados; `npm run test:cov` passa (services ≥ 80%)
- [ ] `npm run lint` e `npm run typecheck` passam
- [ ] Endpoint documentado no Swagger
- [ ] Migration criada (uma por tabela) e DER atualizado (se mudou o banco)
- [ ] Variáveis de ambiente novas adicionadas ao `.env.example`
- [ ] Sem `console.log`, sem código comentado, sem segredos no código

## Revisão
- [ ] Passou pelo `/revisar-codigo` (padrões e spec)

## Observações para o revisor
<!-- Decisões tomadas, dúvidas, pontos de atenção. Screenshots do Swagger/Insomnia se ajudar. -->
