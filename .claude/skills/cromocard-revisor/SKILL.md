---
name: cromocard-revisor
description: Revisa um Pull Request ou uma branch do CromoCard (backend, frontend ou workspace) rodando o código de verdade. Roda todos os testes e linters, exige cobertura de 90% com testes reais e valida padrões e arquitetura, spec, se toda divergência entre Figma e documentação foi decidida e registrada, fidelidade ao Figma e responsividade em celular, tablet, laptop e desktop, e devolve um veredito com evidências. Não corrige o código: publica os achados como comentários no PR, e quem corrige é o autor. Use sempre que mandarem um PR para revisar, pedirem /cromocard-revisor, "revisa esse PR", "revisa a branch" ou "esse PR pode entrar?", mesmo sem citar a skill, e antes do /criar-pr.
argument-hint: "este PR \"<link ou número>\" | [backend|frontend|workspace] [base] [#work-item]"
---

Pedido: `$ARGUMENTS`

Exemplos de chamada: `/cromocard-revisor este PR "https://github.com/codaqui/cromocard-frontend/pull/42"`,
`/cromocard-revisor este PR "42" frontend`, `/cromocard-revisor backend`.

Antes de começar, diga em uma ou duas frases o que entendeu que vai revisar. Siga as fases na ordem.

## As regras da revisão

1. **A revisão não corrige.** Ela roda numa cópia à parte, a branch do usuário não muda, e o código do PR nunca é
   alterado: nada de commit ou push na branch do autor, nem quando o ajuste parece pequeno ou o usuário pede. Quem
   corrige é o autor, a partir dos comentários que a Fase 8 publica. Se pedirem a correção, explique isso; sendo o
   usuário o autor, a correção é dele, na própria branch (por exemplo com a `/cromocard-desenvolver`).
2. **Rodar, não presumir.** O que a descrição do PR afirma não é evidência. Checagens, fidelidade e responsividade são
   executadas aqui.
3. **Seis eixos separados.** Não misture os achados: um código pode seguir os padrões e implementar a coisa errada, ou
   ser fiel ao Figma e quebrar no celular.
4. **Nada de aprovar pela metade.** Eixo que se aplica e não pôde rodar deixa a revisão incompleta, nunca aprovada.
5. **Só comentários saem daqui.** Pedir a revisão de um PR é pedir os comentários nele (Fase 8), sempre com o evento
   `COMMENT`. Não aprove, não peça alterações formalmente (`APPROVE`/`REQUEST_CHANGES`), não faça merge e não escreva no
   Azure. Quem aprova o PR é uma pessoa diferente de quem o escreveu (`.claude/rules/git.md`).
6. **Todo achado explica a si mesmo**, em qualquer eixo, com as três partes abaixo. Um achado sem o motivo não ensina nada
   a quem escreveu e não deixa decidir se vale corrigir.

```
`caminho/arquivo.ts:42` ou tela (node-id) e largura · <regra, princípio ou padrão> · <severidade>
Problema: o que está errado neste trecho.
Por que é ruim: a consequência concreta, ou seja, o que quebra, o que fica difícil ou que risco cria.
Sugestão: a correção, com o código quando for curta.
```

| Eixo | Pergunta | Vale para |
|---|---|---|
| 1. PR e checagens | O PR segue o processo, está tudo verde e os testes são reais, com 90% ou mais de cobertura? | Todos |
| 2. Padrões | Segue arquitetura, ADRs e rules? Cada arquivo está na pasta certa? Aplica SOLID, Object Calisthenics e Design Patterns? | Todos |
| 3. Spec | Faz o que a spec pede, e só isso? | Todos com spec |
| 4. Decisões e documentação | Toda divergência foi decidida e a documentação acompanhou? | Todos com spec ou tarefa |
| 5. Fidelidade ao Figma | A tela é igual ao frame? | PR com tela |
| 6. Responsividade | Funciona em todos os tamanhos? | PR com tela |

PR com tela é o que traz uma página nova ou alterada, um componente que já aparece numa página ou um fluxo que dá para
clicar. Nos outros, os eixos 5 e 6 ficam como "não se aplica", com o motivo.

**Referências:** os arquivos de `references/` existem iguais nesta skill e na `/cromocard-desenvolver`. Ao alterar um, altere o outro.

## Fase 1. Achar o que revisar

| Repo | Caminho | GitHub | Base |
|---|---|---|---|
| backend | `apps/cromocard-backend` | `codaqui/cromocard-backend` | `develop` |
| frontend | `apps/cromocard-frontend` | `codaqui/cromocard-frontend` | `develop` |
| workspace | `.` | `codaqui/cromocard-workspace` | `development` |

**PR** (link, ou número depois da palavra PR). Sem o repo no link ou no texto, procure o número nos três e pergunte se
houver mais de um. `AB#n`, ou `#n` sem a palavra PR, é work item. Leia os dados:

```bash
gh pr view <n> --repo <GitHub> --json number,title,body,state,isDraft,author,baseRefName,headRefName,headRefOid,isCrossRepository,files,commits,reviewDecision,statusCheckRollup,url
```

- PR fechado ou já mesclado: pergunte se é para revisar mesmo assim. Se o diff contra a base sair vazio, o que é normal
  depois do merge, passe aos agents o comando `gh pr diff <n> --repo <GitHub>`.
- PR de fork ou de alguém de fora do time: pergunte antes de instalar ou rodar o código dele.
- Sem o `gh` autenticado: siga com o `git fetch` e diga no relatório que o eixo 1 ficou parcial.

**Branch** (sem PR nos argumentos). Sem o repo, descubra onde está o trabalho com `git -C <caminho> status --short` e
`git -C <caminho> log --oneline origin/<base>..HEAD`, e pergunte se houver em mais de um. Revise no próprio checkout,
incluindo `git diff HEAD` e avisando que parte é trabalho em andamento. O eixo 1 cobre só commits e checagens.

**Cópia à parte do PR**, para o usuário continuar na branch dele:

```bash
APP=<caminho>; DIR=<scratchpad>/pr-<repo>-<n>
git -C $APP fetch origin pull/<n>/head <base>
git -C $APP worktree add --detach "$DIR" <headRefOid>
```

O diff é `git -C "$DIR" diff origin/<base>...HEAD`, e o relatório cita o `headRefOid`. Diff vazio ou base inexistente:
falhe aqui, não dentro dos agents.

## Fase 2. Achar a spec e as decisões

- **Tarefa:** `#id` nos argumentos, `AB#` no corpo do PR, número da branch, rodapé dos commits. Sem nenhum, pergunte.
- **Spec:** seção **Spec** do corpo do PR, ou `specs/` pelo `CCDnnn` ou pela linha `User story: #<id>`.
- **Versão certa:** a spec e os docs atualizados podem estar num PR do workspace ainda aberto. Procure com
  `gh pr list --repo codaqui/cromocard-workspace --state open --search "<id>"` e leia a versão de lá. PR de um app sem
  spec e docs alcançáveis em nenhuma branch já é achado do eixo 4.
- **PR par:** procure o PR do outro app com a mesma tarefa. Ele é usado na Fase 5.
- Se o usuário disser que não há tarefa, o relatório diz "sem spec" e o eixo 3 fica "não se aplica".

## Fase 3. Eixo 1: PR e checagens

Instale na cópia (`npm ci`, com o `.env` copiado do app, sem exibir o conteúdo) e rode tudo com os comandos de
[references/testes.md](references/testes.md). O CI verde não substitui esta execução.

- **Repositório do PR:** formatação, lint, tipos, todos os testes com cobertura e build. Qualquer falha é **Bloqueante**.
- **O outro app:** o PR par, se existir, senão o `origin/develop`, numa cópia à parte. Falha no PR par é **Bloqueante**.
  Falha no `origin/develop` que este PR não causou entra como **Importante**, separada dos achados do PR.
- **Cobertura:** meça cada arquivo alterado, como manda a referência. Arquivo abaixo de 90% é **Bloqueante**. Informe
  também o total da aplicação.
- **Testes reais:** leia cada `.spec` do diff, confirme que cada `CA` tem teste e faça a prova da quebra, na cópia, em até
  três regras importantes da spec. Teste que só cobre linha, ou que continua verde com a regra quebrada, é **Bloqueante**.
  Atalho para ficar verde (`.skip`, `.only`, limite reduzido, exclusão de arquivo, `eslint-disable`) também.
- workspace: DER nos três `.dbml` com os prints refeitos, ADR novo `Proposto` e no índice, `.puml` com o `.svg`
  exportado, ponteiro de `apps/*` alterado de propósito.

Confira também, contra o `.claude/rules/git.md`: base correta, nome da branch, Conventional Commits em pt-BR com `AB#`,
sem `Co-Authored-By`, uma user story por PR, CI (`statusCheckRollup`), nenhum `.env` ou segredo em `files`. Na descrição:
template preenchido, link do frame e veredito na tela, um bloco por `CA`, e todo ✅ com GIF ou print de verdade. Item
marcado no checklist que a revisão desmentir é achado.

## Fase 4. Eixos 2 e 3: Padrões e Spec

Na mesma mensagem, chame:

- **`revisor-codigo`** com o caminho da cópia, o comando de diff e a lista de commits;
- **`analista-requisitos`** com a tarefa, a pasta da spec na versão certa **e o comando de diff** (modo revisão), para
  marcar cada requisito, conferir o contrato da API do `plano.md` e listar o que foi feito sem ser pedido.

Mapa de cada pasta e arquivo, que o `revisor-codigo` usa:
[backend](references/arquitetura-backend.md) e
[frontend](references/arquitetura-frontend.md).

Em PR de app, o `revisor-codigo` confere o código conceito por conceito contra
[SOLID](references/solid.md), [Object Calisthenics](references/object-calisthenics.md) e
[Design Patterns](references/design-patterns.md). Os princípios valem sempre. Um padrão de projeto só é achado quando o
problema dele está no diff, ou quando foi aplicado sem problema a resolver.

## Fase 5. Eixo 4: Decisões e documentação

Confira, na versão certa da spec e dos docs:

1. Status `Aprovada` ou adiante, com **Aprovação** preenchida, e nenhuma lacuna `pendente`.
2. Cada linha de **Lacunas e decisões** aparece onde ela diz: no caso de uso, na user story, em `escopo-adicional.md`, no
   ADR `Proposto`, nos três `.dbml` e no diagrama de classes se criou dado. Decisão sem o registro é **Bloqueante**.
3. O código faz o que foi decidido, inclusive o que ficou em **Fora do escopo**.
4. O que o PR mostra e só existe no Figma tem documentação correspondente.

**Toda divergência sem decisão é pendência.** Em PR com tela, abra de novo cada frame da seção **Telas** com a
`/analisar-figma-playwright` (sem o `playwright-figma`, a `/analisar-figma-chrome`; o MCP do Figma só com autorização
do usuário), incluindo as variações de estado, e compare com a documentação. Guarde o resultado para a Fase 6. Sempre em
modo protótipo. O Figma é mantido pelo Gabriel: nunca o edite nem ofereça editar.

Para cada divergência sem decisão registrada, pergunte com `AskUserQuestion`, nas mesmas categorias e com as mesmas
opções da Fase 3 da [`/cromocard-desenvolver`](../cromocard-desenvolver/SKILL.md), a recomendada primeiro, cada pergunta
explicada sozinha (tela e `node-id`, o que o Figma mostra, o que a documentação diz, efeito de cada opção). A resposta
não altera nada agora: vira o que o autor do PR precisa fazer. Sem resposta, a pendência fica aberta no relatório. Em
qualquer caso, é **Bloqueante**, porque o PR entrou sem a decisão registrada.

Cor, espaçamento, ícone e layout não são pendência: neles o Figma manda, e a diferença é tratada na Fase 6.

## Fase 6. Eixos 5 e 6: Fidelidade e responsividade

Só em PR com tela. Siga inteira a referência
[fidelidade-e-responsividade.md](references/fidelidade-e-responsividade.md), usando a cópia do
PR:

- **Portas:** o frontend em 5173 e a API em 3000, que são as que o CORS libera. Se o servidor do usuário estiver numa
  delas, pergunte antes de seguir. Nunca derrube um processo que não foi você que subiu.
- **Dados:** PR com migration roda num banco próprio, `cromocard_pr_<n>`, com `DATABASE_URL` no mesmo comando de
  `npm run db:deploy`, `npm run db:seed` e `npm run dev`. Migration de PR nunca é aplicada no banco de desenvolvimento.
- **API de um PR de frontend**, nesta ordem: o PR par do backend numa cópia à parte; o `develop`, se já tiver os
  endpoints; respostas simuladas do contrato com `page.route`, avisando no relatório que foi simulado.
- **Fidelidade:** cada frame e estado, na largura do frame. Diferença não decidida na spec é **Bloqueante**.
- **Responsividade:** toda tela e todo overlay na matriz inteira, com script de medição e print. Reprovação em qualquer
  largura é **Bloqueante**.
- Cada achado visual cita a tela, o `node-id`, a largura e o caminho completo do print.

## Fase 7. Veredito

| Veredito | Quando |
|---|---|
| ✅ **Pode seguir para aprovação** | Todos os eixos aplicáveis rodaram e não há Bloqueante |
| ❌ **Alterações necessárias** | Há pelo menos um Bloqueante |
| ⏸️ **Revisão incompleta** | Sem Bloqueante, mas algum eixo aplicável não pôde rodar |

Se a revisão ficou incompleta, comece a resposta por isso.

```
## Revisão — PR #<n> · <repo> · <sha curto> · <CCDnnn> · #<id>
**Veredito: <…>** · Bloqueantes: <n> · Importantes: <n> · Opcionais: <n>

## 1. PR e checagens
| Checagem | Repo do PR | Outro app |
| Formatação · Lint · Tipos · Testes · Integração · Build | ✅ ou ❌, com a saída | ✅ ou ❌ |
| Arquivo alterado | Linhas | Branches | Funções | Statements |
Total da aplicação: <n>% · Prova da quebra: <regra → ficou vermelho?>

## 2. Padrões
<resposta do revisor-codigo>

## 3. Spec — <specs/<pasta>/ | sem spec salva>
<requisitos com a situação, contrato da API, fora do escopo e lacunas, do analista>

## 4. Decisões e documentação
| Decisão | Registrada em | Confere? |
Pendências sem decisão: <lista com a resposta do usuário | nenhuma>

## 5. Fidelidade ao Figma
| Tela (node-id) | Estado | Resultado |
Diferenças aceitas, todas decididas: <lista | nenhuma>

## 6. Responsividade
| Tela | 320 | 360 | 768 | 1024 | 1366 | 1920 | Frame |

## O que o autor precisa corrigir, em ordem
1. <arquivo:linha, ou tela e largura> · <regra> · <severidade>
   Problema: <…>
   Por que é ruim: <…>
   Sugestão: <…>

Não validado: <o que não rodou e por quê | nada>
```

## Fase 8. Comentar no PR e limpar

Só depois do relatório. A revisão não corrige nada (regra 1): ela publica os achados no PR para o autor corrigir. Não
pergunte se é para corrigir nem ofereça correção.

**Revisão de branch, sem PR:** não há onde comentar. O relatório é a entrega, e quem escreveu corrige na própria branch
antes do `/criar-pr`. Vá direto para a limpeza.

**Revisão de PR:** publique a revisão no PR como comentários no código, sem perguntar, porque o pedido de revisão já é
o pedido dos comentários. Se o usuário disser na chamada que não quer publicar, entregue só o relatório.

- O evento é sempre `COMMENT`. Nunca use `APPROVE` nem `REQUEST_CHANGES`.
- Cada achado com linha no diff vira um comentário naquela linha, com as três partes. O que foi decidido pelo PO
  durante a revisão (Fase 5) entra no comentário como **Decisão do PO nesta revisão**, para o autor saber que não é
  sugestão.
- O `body` leva o veredito, as tabelas de checagens e de cobertura, a prova da quebra e os achados sem linha no diff:
  arquivos fora do diff, achados visuais (tela, `node-id`, largura), documentação e processo, todos com as três partes.
- Antes de enviar, confira que cada `path` e `line` está entre as linhas acrescentadas do diff
  (`git -C "$DIR" diff -U0 origin/<base>...HEAD`). Linha fora do diff faz a API recusar a revisão inteira: mova o
  comentário para uma linha do diff no mesmo trecho ou para o `body`.

Grave um JSON num arquivo temporário e envie:

```json
{
  "commit_id": "<headRefOid>",
  "event": "COMMENT",
  "body": "<veredito e achados que não têm linha no diff>",
  "comments": [
    {
      "path": "src/arquivo.ts",
      "line": 42,
      "side": "RIGHT",
      "body": "**Problema:** …\n\n**Por que é ruim:** …\n\n**Sugestão:** …"
    }
  ]
}
```

```bash
gh api -X POST repos/<GitHub>/pulls/<n>/reviews --input <arquivo>
```

Mostre o link da revisão publicada (`html_url` da resposta) e um resumo curto do que o autor precisa corrigir.

**Limpar.** Pare os servidores que você subiu, feche o navegador (`browser_close`), apague o banco `cromocard_pr_<n>` se o
criou e remova as cópias com `git -C <caminho> worktree remove --force "$DIR"`. Copie antes os prints citados no relatório
para fora da cópia.
