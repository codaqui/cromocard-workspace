---
name: jibble
description: Registra e consulta as horas do time do CromoCard no Jibble pelo MCP `jibble` — bater ponto (entrada, pausa, volta e saída), lançar horas numa Task do Azure, ver o timesheet do dia, da semana ou da sprint e, para quem é gestor, as horas da equipe. Use quando pedirem para bater ponto, apontar ou lançar horas, ou ver quanto alguém trabalhou.
argument-hint: "[entrada|pausa|volta|saida] [AB#id] · lancar <horas> <AB#id> [data] · horas [hoje|semana|sprint] · equipe [semana|sprint]"
---

Executa `$ARGUMENTS` no Jibble pelo MCP `jibble` (`https://mcp.jibble.io`, login OAuth de cada pessoa).

## Regras

- **Só a conta de quem está usando.** O MCP segue o papel da pessoa no Jibble (membro vê o próprio, gestor vê quem
  gerencia). Nunca bata ponto nem lance horas por outra pessoa, mesmo que a conta permita, sem pedido explícito com o
  nome dela.
- **Toda escrita no Jibble confirma antes**, com o resumo do que vai gravar (ação, projeto, Task, horário ou horas,
  nota). Exceção: `entrada`, `pausa`, `volta` e `saida` pedidos explicitamente nesta chamada já são a confirmação.
  Editar ou apagar um registro existente e pedir folga sempre confirmam.
- **O board não muda.** A skill lê o Azure (título da Task, user story, sprint) e não altera work items.
- Fuso: `America/Sao_Paulo`. Datas na resposta em `DD/MM`, horas em `h:mm`.

## 1. Ferramentas e login

1. As ferramentas do servidor se chamam `mcp__jibble__*`. Se aparecerem só como nome (deferidas), carregue todas
   numa chamada do `ToolSearch` com a consulta `+jibble`.
2. Sem nenhuma ferramenta `mcp__jibble__*`, ou com erro de autenticação: peça para a pessoa rodar `/mcp`, escolher
   `jibble` → **Authenticate** e entrar com a conta do Jibble no navegador. Se `jibble` nem aparecer no `/mcp`, o
   Claude Code foi aberto fora da raiz do workspace ou antes do `.mcp.json` ter o servidor: reinicie na raiz.
3. Use os nomes e os parâmetros que as ferramentas trouxerem; não invente parâmetro. Se nenhuma ferramenta fizer o
   que foi pedido, diga isso em vez de improvisar com outra.

## 2. Ligar a hora ao board

O apontamento serve para o time ver as horas de cada Task. Sempre que houver um `AB#id`:

1. Leia o work item com `mcp__azure-devops__wit_work_item` (título, tipo, user story pai e sprint).
2. Projeto no Jibble: o projeto **CromoCard** (procure na lista de projetos da conta). Se não existir ou houver mais
   de um candidato, pergunte qual usar e não crie projeto.
3. Atividade: a que corresponder ao tipo de trabalho, se a conta tiver atividades (ex.: desenvolvimento, reunião,
   documentação). Sem correspondência clara, deixe sem atividade e diga isso.
4. Nota do registro: `AB#<id> <título da Task>` — ex.: `AB#519 Criar migration da tabela categories`. Assim dá para
   cruzar o Jibble com o board.

Sem `AB#id`, registre sem nota de Task e pergunte uma vez se a pessoa quer ligar a alguma.

## 3. Ações

| Pedido | O que fazer |
|---|---|
| `entrada [AB#id]` | Bate a entrada, com o projeto e a nota da seção 2 quando houver Task |
| `pausa` / `volta` | Começa ou termina a pausa |
| `saida` | Bate a saída e mostra o total trabalhado no dia |
| `lancar <horas> <AB#id> [data]` | Registro manual (padrão: hoje). Confirme antes. Recuse horas que se sobrepõem a outro registro do dia e mostre o conflito |
| `horas [hoje\|semana\|sprint]` | Timesheet da própria pessoa, agrupado por dia e por Task (pela nota `AB#`) |
| `equipe [semana\|sprint]` | Só para gestor: horas de cada pessoa do time. Sem permissão, diga que a conta não tem acesso |

`sprint` usa as datas da sprint atual do Azure (`mcp__azure-devops__work` → iteração atual do time
`CromoCard Team`).

Sem argumento, mostre o estado atual (dentro ou fora do ponto, desde quando) e as horas de hoje.

## 4. Responder

- Escrita: o que foi gravado (ação, horário, projeto, nota) e o total do dia.
- Consulta: tabela curta, por exemplo:

| Dia | Task | Horas |
|---|---|---|
| 22/10 | AB#519 Criar migration da tabela categories | 2:30 |

  com o total no fim. Registros sem `AB#` aparecem como `sem Task`.
