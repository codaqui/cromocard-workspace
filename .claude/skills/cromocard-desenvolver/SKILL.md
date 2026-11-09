---
name: cromocard-desenvolver
description: Desenvolve do início ao fim uma spec do CromoCard. Lê a spec, compara o Figma com a documentação, pergunta ao usuário cada divergência, atualiza a documentação, e só com zero pendências escreve o código no padrão dos apps, com testes reais e cobertura de 90% a 100%, fiel ao Figma, validado em celular, tablet, laptop e desktop, e só termina com testes e linters verdes nos dois apps. Use sempre que pedirem /cromocard-desenvolver, "faça esta spec", "desenvolve a spec", "desenvolve o CCDnnn" ou "implementa essa tela seguindo o Figma", mesmo sem citar a skill.
argument-hint: "faça esta spec \"<CCDnnn, #id, nome ou caminho da spec>\" [backend|frontend]"
---

Pedido: `$ARGUMENTS`

Exemplos de chamada: `/cromocard-desenvolver faça esta spec "CCD058"`,
`/cromocard-desenvolver faça esta spec "gestão de usuários" frontend`.

Antes de começar, diga em uma ou duas frases qual spec entendeu e o que vai fazer. Siga as fases na ordem, sem pular
nenhuma: cada uma depende da anterior.

## As cinco regras que não se negociam

1. **Primeiro analisar, depois perguntar.** O Figma e a documentação são lidos e comparados antes de qualquer outra
   coisa, e toda divergência é perguntada ao usuário.
2. **Sem pendência para codar.** Nenhum arquivo de `apps/*` muda enquanto houver pendência aberta. Código feito sobre
   uma dúvida vira retrabalho e esconde do time uma decisão que era dele. Uma recomendação nunca vale como resposta.
3. **Fiel ao Figma.** A tela pronta é igual ao frame. A única diferença aceita é a que o usuário decidiu na Fase 3.
4. **Responsivo em todos os tamanhos.** A entrega só termina com celular, tablet, laptop e desktop validados no
   navegador.
5. **Só termina verde.** Formatação, linters, tipos, todos os testes e build, no backend e no frontend. Com testes reais
   e cobertura de 90% a 100% em tudo que a spec tocou.

**Documentação e Figma:** a documentação é a fonte principal da verdade, e o objetivo é ser o mais fiel possível ao Figma.
Por isso nenhuma diferença entre os dois se resolve sozinha: o usuário decide, e a documentação é ajustada antes do
código. Enquanto não houver decisão, vale a documentação. A `/conferir-tarefa` segue o mesmo critério.

**Referências:** os arquivos de `references/` existem iguais nesta skill e na `/cromocard-revisor`. Ao alterar um, altere o outro.

## Fase 1. Achar e ler a spec

- Encontre a spec a partir do texto do pedido: `CCDnnn`, `#id` ou `AB#id` (cabeçalho da spec), nome da user story
  (índice do `specs/README.md`) ou caminho. Com mais de uma candidata, pergunte qual. Sem texto, pergunte qual spec.
- Sem spec para o pedido: pare e ofereça o `/especificar`.
- Status `Implementada` ou `Cancelada`: pare e pergunte se é para reabrir.
- Leia `spec.md`, `plano.md` e `tarefas.md` (se existirem). Os dois últimos podem não existir ainda: a Fase 4 cuida
  disso.
- App: o que o pedido citar. Sem citar, os apps que a spec envolve, com o backend antes do frontend, para validar a
  tela com a API real.
- As decisões já registradas em **Lacunas e decisões** valem e não são perguntadas de novo.

## Fase 2. Analisar a documentação e o Figma

Esta fase roda mesmo que o pedido seja só de backend, porque uma decisão sobre a tela pode mudar o contrato da API.
Só leia: nada é alterado aqui.

**Documentação.** Chame o agent `analista-requisitos` com o `CCDnnn` e confira você mesmo o caso de uso, a user story,
as tabelas no `docs/Diagramas/DER/03-der-completo.dbml` e os ADRs citados. Considere as inconsistências conhecidas
listadas no `CLAUDE.md`.

**Figma.** Abra de novo cada frame da seção **Telas** da spec, mesmo com veredito preenchido: o arquivo pode ter
mudado. Inclua as variações de estado listadas no índice de telas da `/analisar-figma-chrome`.

- Use a skill `/analisar-figma-playwright`, que dá os textos exatos, as caixas de cada camada e o print em tamanho
  real, e guarde esses resultados para a Fase 6.
- Sem o `playwright-figma`, use a `/analisar-figma-chrome`. O MCP do Figma tem cota: use a `/analisar-figma-mcp` só se
  o usuário autorizar.
- Sempre em modo protótipo, nunca o editor. O Figma é mantido pelo Gabriel: nunca o edite nem ofereça editar.
- Spec sem tela (só API ou job): registre isso, pule o Figma e as Fases 6 e 7, e pergunte o que a documentação deixar
  em aberto.

## Fase 3. Perguntar tudo

Compare item a item e monte a lista de pendências. Cor, espaçamento, ícone e layout não são pendência: neles o Figma
manda, sem pergunta. Só vira pendência o que contradiz uma regra ou muda campo, texto, ação, fluxo, permissão ou dado.

| Pendência | Quando | Opções, a recomendada primeiro |
|---|---|---|
| **Divergência** | Figma e documentação mostram a mesma coisa de formas diferentes | **Seguir o Figma (Recomendado)**, atualiza a documentação · Seguir a documentação, a tela fica diferente do frame nesse ponto · Não fazer |
| **Só no Figma** | O Figma mostra e nenhuma documentação pede | Pergunte **se faz sentido implementar**, recomendando conforme a user story e dizendo o motivo: Sim, ajustar a documentação e desenvolver · Não, fica fora do escopo e a tela difere do frame nesse ponto |
| **De outra user story** | O elemento está no frame, mas pertence a outra story ou fase | **Mostrar como no Figma e deixar a ação para a CCDnnn (Recomendado)**, com `underConstructionRoute` quando for rota · Fazer agora nesta spec · Não mostrar |
| **Só na documentação** | O requisito existe e o Figma não mostra | **Fazer no estilo visual da tela (Recomendado)** · Não fazer e atualizar a documentação |
| **Lacuna ou conflito** | Lacuna `pendente` da spec, contradição entre documentos, frame que não existe ou que não dá para ler | Opções concretas para o caso, com a sua recomendação |

Em "Só na documentação" a recomendação é manter o requisito: um frame estático que não mostra um erro ou um estado não
decidiu tirar esse requisito, só não o desenhou.

Como perguntar:

- Use `AskUserQuestion`, até quatro por chamada, e repita até acabar a lista. Só agrupe itens com a mesma causa.
- O usuário pode ver só a caixa da pergunta, então cada uma se explica sozinha: tela e `node-id`, o que o Figma mostra,
  o que a documentação diz com a origem (`58-…md, FP 3`) e o efeito de cada opção. O `header` numera (`Pend. 3/9`).
- Resposta em "Other", ambígua ou "vou ver com o time": a pendência continua aberta. Se o usuário não puder decidir
  agora, pare e entregue a lista do que falta, sem codar.
- **Sem nenhuma divergência:** mostre a tabela requisito × Figma e pergunte mesmo assim se confirma que está tudo
  coberto. A pergunta é obrigatória, porque a comparação pode ter deixado passar algo que o usuário enxerga.

Antes de seguir, mostre a tabela `Pendência | Decisão` com **Pendências abertas: 0**.

## Fase 4. Registrar as decisões

Ainda sem tocar em `apps/*`, nesta ordem:

1. **Git do workspace.** `git fetch --all` e `git status`. Em branch fixa, crie `docs/<id>-<descricao>` a partir de
   `origin/development`. Em branch de outro assunto, pergunte onde gravar.
2. **Documentação**, conforme cada decisão de seguir o Figma, fazer o que só ele mostra ou deixar de fazer um requisito:
   - regra, campo, texto ou fluxo: o caso de uso em `docs/Casos-De-Uso/`, no formato de `.claude/rules/casos-de-uso.md`,
     e a user story se a narrativa mudar;
   - funcionalidade que só existe no Figma e não cabe num caso de uso: complemento em `escopo-adicional.md`, com a
     marca `++`;
   - dado novo: os três `.dbml`, o diagrama de classes e a rastreabilidade do `README.md` do DER
     (`.claude/rules/modelagem-de-dados.md`), e peça ao usuário os prints novos no dbdiagram.io;
   - decisão técnica: ADR novo `Proposto` (`.claude/rules/adrs.md`).
3. **Spec**, com IDs que nunca se renumeram (`.claude/rules/specs.md`): uma linha em **Lacunas e decisões** por decisão,
   com onde foi registrada; `R` e `CA` novos citando o passo novo como origem; `~~R4~~ removido: <motivo>` para o que
   saiu; **Fora do escopo** para o que não será feito; **Telas** atualizada, com o que vai ficar diferente do frame.
4. **Aprovação.** Se a spec mudou ou está em `Rascunho`, ela volta a `Rascunho` e só o usuário confirma `Aprovada`.
   Pergunte com `AskUserQuestion` e pergunte junto se pode commitar ao fim de cada tarefa. Sem o sim da aprovação, pare.
5. **Plano.** Sem `plano.md` ou com o plano defasado pelas decisões, siga os passos do `/planejar`, inclusive
   o status `Planejada` e o índice. Criar Tasks no Azure só com o pedido explícito do usuário.

## Fase 5. Desenvolver

Agora sim. Antes da primeira linha, leia a referência do app e o modelo que ela indica:

- backend: [references/arquitetura-backend.md](references/arquitetura-backend.md);
- frontend: [references/arquitetura-frontend.md](references/arquitetura-frontend.md) e
  [references/fidelidade-e-responsividade.md](references/fidelidade-e-responsividade.md);
- nos dois apps: [SOLID](references/solid.md),
  [Object Calisthenics](references/object-calisthenics.md) e
  [Design Patterns](references/design-patterns.md);
- nos dois apps: [Testes](references/testes.md).

O código faz o que a spec pede, do jeito que o plano diz, com as decisões da Fase 3.

**Antes da primeira tarefa, em cada app** (`git -C apps/cromocard-<app> …`):

- `git fetch --all` e `git status`. Se houver mudança não commitada que não é desta spec, pergunte antes de seguir.
- Em branch fixa, crie `feature/<id>-<descricao>` a partir de `origin/develop`, com o `<id>` da user story e a descrição do
  nome da pasta da spec. Numa branch de feature desta spec, continue nela.
- Mude o status da spec para `Em implementação` e atualize o índice do `specs/README.md`.
- Tarefas já marcadas `[x]` ficam como estão. Se o pedido citar uma `T<n>`, comece por ela.
- Frontend antes do backend estar pronto: use o contrato do plano como referência, não o código do backend.

**Para cada tarefa pendente, em ordem:**

1. Leia os arquivos que ela toca e o modelo do app (`src/domains/users/` no backend, `src/features/users/` no frontend), e
   copie o padrão.
2. Implemente só o que a tarefa descreve, com o contrato da API exatamente como está no plano (caminho, campos, status,
   códigos de erro).
3. Escreva os testes dos `CA` da tarefa, com o ID no nome (`it('CA2: recusa senha incorreta com 401')`).
4. Rode `npm run lint`, `npm run typecheck` e os testes afetados.
5. Marque `[x]` no `tarefas.md`. Com a permissão da Fase 4, commite no padrão do `.claude/rules/git.md`, com o domínio no
   escopo e o `AB#` da Task (ou da user story) no rodapé, sem `Co-Authored-By` nem rodapé de ferramenta.

Decisão de arquitetura que nenhum ADR cobre vira ADR novo `Proposto`, não uma escolha silenciosa no código.

Construa cada tela já responsiva: adaptar depois quase sempre obriga a refazer a estrutura.

**Antes de marcar cada tarefa como feita**, confira o código dela contra os cinco princípios SOLID, as nove regras de
Object Calisthenics e os Design Patterns, e arrume na hora o que violar. Os padrões de arquitetura do projeto são
obrigatórios. Os demais entram quando o problema deles existe: padrão aplicado sem necessidade também é defeito. A
`/cromocard-revisor` vai cobrar a mesma lista no PR.

**Todo arquivo com lógica ganha o seu `.spec` na mesma tarefa**, conforme a referência de testes: cada `CA` e cada fluxo
alternativo com teste, afirmando o resultado que o usuário observa. O objetivo é o teste ficar vermelho quando a regra
quebra, e não subir o número. Um teste escrito só para cobrir linha não conta, mesmo que a cobertura suba.

**Apareceu algo novo no meio do caminho** (requisito que falta, frame que não fecha, contrato que não funciona): pare
naquele ponto, trate como pendência da Fase 3, registre como na Fase 4 e só então continue.

## Fase 6. Validar a fidelidade ao Figma

Siga [references/fidelidade-e-responsividade.md](references/fidelidade-e-responsividade.md). Compare cada frame com a
tela rodando, na largura do frame, em todos os estados que o Figma mostra. Toda diferença que não foi decidida na Fase 3
é defeito: corrija e compare de novo até não sobrar nenhuma. O que não der para igualar vira pergunta ao usuário, nunca
um "ficou quase igual".

## Fase 7. Validar a responsividade

Siga a mesma referência. Toda tela e todo overlay passam por todas as larguras da matriz, com o script de medição e o
print de cada uma. Qualquer reprovação volta para o código, e depois da correção a matriz é refeita, porque um ajuste num tamanho
costuma quebrar outro. Testes com jsdom não medem layout: só o navegador conta.

## Fase 8. Deixar tudo verde e fechar

Ao fim do código, rode **tudo, no backend e no frontend**, mesmo que a spec só tenha mexido em um deles, com os comandos
de [Testes](references/testes.md): formatação, lint, tipos, todos os testes (inclusive os de integração
com o PostgreSQL de pé) e build. Meça também a cobertura de cada arquivo alterado e faça a prova da quebra nas regras
mais importantes da spec.

**Não termine enquanto não estiver tudo verde.** A cada falha, ache a causa, corrija e rode a lista inteira de novo, até
passar tudo numa rodada só, sem nenhuma alteração depois dela.

- Arquivo abaixo de 90%: escreva o teste que falta, de comportamento real. Se a linha não for alcançável por nenhum
  comportamento, ela provavelmente é código morto: remova.
- Falha que a spec não causou também precisa ficar verde. Corrija em commit próprio e diga no relatório. No outro app, use
  uma branch própria a partir de `origin/develop` e pergunte antes se houver trabalho não commitado lá.
- Falha por ambiente (Docker fora do ar, banco ausente): tente subir e preparar o ambiente antes de desistir.
- Atalhos não contam como verde: veja "Nunca fique verde na marra" na referência.

Se, esgotadas as tentativas, algo continuar vermelho ou alguma fase não tiver rodado de verdade (API fora do ar, Figma
sem login), a entrega **não está pronta**: comece a resposta por isso, com a saída do erro, e diga o que falta.

```
## <CCDnnn> — <Nome> · <app(s)> · branch <branch>
Tarefas: <n> feitas, <n> pendentes

### Tudo verde
| Checagem | Backend | Frontend |
| Formatação · Lint · Tipos · Testes · Integração · Build | ✅ <n testes> | ✅ <n testes> |
| Arquivo alterado | Linhas | Branches | Funções | Statements |
Total da aplicação: backend <n>% · frontend <n>% · Prova da quebra: <regra → ficou vermelho>

### Decisões (<n>)
| Pendência | Decisão | Registrada em |

### Requisitos
| Requisito | Situação |
| R1 | ✅ T2 · ⚠️ parcial (o que falta) · ↪ outro app |

### Fidelidade ao Figma
| Tela (node-id) | Estado | Resultado |
Diferenças aceitas, todas decididas: <lista ou "nenhuma">

### Responsividade
| Tela | 320 | 360 | 768 | 1024 | 1366 | 1920 | Frame |

### Para o Gabriel (telas que ficaram diferentes do Figma por decisão)
- <tela> — <o que mudou e por quê>
```

Próximo passo: `/cromocard-revisor <app>` e `/criar-pr <app>`. As mudanças de `docs/` e `specs/` entram no PR do workspace.
