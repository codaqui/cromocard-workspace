# ADR-060 — Fluxo de desenvolvimento e revisão: decisão sobre o Figma, cobertura de 90% e skills únicas

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-11-09
- **Decisores:** Daniel Andrade (proposta); validação: Felipe Consulim (PO)
- **Substitui parcialmente:** ADR-008 (limite de cobertura), ADR-046 (ausência de limite de cobertura) e ADR-047 (regra de
  divergência com o Figma e skills do fluxo)

## Contexto

O fluxo definido no ADR-047 considerava que, na divergência entre Figma e documentação, valia a documentação, e o que só
existia no Figma ficava de fora. O time quer as telas o mais fiéis possível ao protótipo, sem perder a documentação como
referência.

O ADR-008 fixa 80% de cobertura nas services do backend e o ADR-046 não define limite no frontend. Em 2026-11-09, sem contar
os testes de integração, o backend tinha 79,6% de linhas cobertas no `src`, e o frontend, 89,1%. O time definiu como meta
ficar entre 90% e 100%, com testes que verifiquem comportamento, e não testes escritos só para cobrir linhas.

As skills `/implementar` e `/revisar-codigo` não cobriam a comparação com o Figma, a validação da tela no navegador nem a
responsividade.

## Decisão

1. **Documentação e Figma.** Mantenha a documentação como fonte principal da verdade e busque a maior fidelidade possível
   ao Figma. Cada diferença entre os dois é decidida pelo usuário antes do código, e até a decisão vale a documentação. O
   que só existe no Figma recebe a pergunta "faz sentido implementar?": se sim, ajuste a documentação e desenvolva; se
   não, registre como fora do escopo.
2. **Sem pendência para codar.** Não escreva código enquanto houver diferença sem decisão registrada.
3. **Cobertura.** Exija de 90% a 100% em linhas, branches, funções e statements em cada arquivo criado ou alterado, com
   testes reais. Meça no CI dos dois apps, em todo Pull Request.
4. **Tudo verde.** Só conclua o desenvolvimento com formatação, lint, tipos, todos os testes e build passando no backend e
   no frontend.
5. **Telas.** Valide cada tela no navegador: fidelidade ao frame e responsividade em celular, tablet, laptop e desktop.
6. **Skills.** Use `/cromocard-desenvolver` no lugar de `/implementar` e `/cromocard-revisor` no lugar de `/revisar-codigo`.
   As duas usam os mesmos arquivos de referência de arquitetura, SOLID, Object Calisthenics, Design Patterns, testes,
   fidelidade e responsividade.

## Alternativas consideradas

- **Manter "vale a documentação" sem pergunta:** deixaria de fora o que o Figma trouxe de útil, sem ninguém decidir.
- **Seguir sempre o Figma:** a documentação deixaria de ser a referência do projeto.
- **Exigir 90% do projeto inteiro de imediato:** o CI ficaria vermelho até escrever os testes de todo o código já existente.
  Medir os arquivos alterados aumenta a cobertura a cada entrega.
- **Manter o limite de 80%:** fica abaixo da meta do time.
- **Manter `/implementar` ao lado da `/cromocard-desenvolver`:** criaria um caminho sem a comparação com o Figma, sem a meta
  de cobertura e sem a validação das telas.
- **Link simbólico para as referências:** evitaria as cópias, mas pode não funcionar igual em todos os ambientes do time.

## Consequências

- Cada entrega leva mais tempo e pede decisões do usuário antes do código, em troca de menos retrabalho.
- A documentação passa a ser ajustada junto com cada decisão sobre o Figma.
- Alterar um arquivo já existente com cobertura baixa obriga a escrever os testes que faltam nele.
- O CI só mede o número. Quem confere se os testes são reais é a `/cromocard-revisor` e a pessoa que revisa o PR.
- Os arquivos de referência existem nas duas skills e precisam ser alterados juntos.
- O limite global do `vitest.config.ts` do backend continua em 80%, restrito às services. Aumentá-lo fica para quando a
  cobertura do projeto chegar à meta.

## Referências

- `.claude/skills/cromocard-desenvolver/SKILL.md` e `.claude/skills/cromocard-revisor/SKILL.md`
- `.claude/skills/conferir-tarefa/SKILL.md`, `.claude/rules/specs.md` e `specs/README.md`
- `.github/workflows/ci.yml` e `.github/scripts/coverage-changed-files.sh` nos repositórios do backend e do frontend
- ADR-008, ADR-046 e ADR-047
