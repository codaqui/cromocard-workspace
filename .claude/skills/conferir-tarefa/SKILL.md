---
name: conferir-tarefa
description: Confere se a tela do protótipo no Figma e a documentação do CromoCard batem para uma tarefa (work item do Azure, código CCDnnn ou nome do caso de uso). Aponta as diferenças, pergunta ao usuário o que fazer com cada uma (o que só existe no Figma recebe a pergunta "faz sentido implementar?") e ajusta a documentação com as respostas, sem escrever código. Use para avaliar uma tela antes de desenvolver ou quando pedirem para comparar documentação e Figma.
argument-hint: "<#work-item | CCDnnn> [link do frame no Figma]"
---

Confere a tarefa `$ARGUMENTS` comparando a documentação com o protótipo no Figma.

**Princípio:** a documentação (caso de uso, user story, work item, DER, ADRs) é a fonte principal da verdade, e o
objetivo é ser o mais fiel possível ao Figma. É o mesmo critério da `/cromocard-desenvolver`. Então:

- requisito da documentação que o Figma não mostra **continua valendo**, salvo decisão em contrário do usuário;
- quando os dois divergem, o usuário decide, e **até a decisão vale a documentação**;
- o que o Figma mostra e a documentação não tem recebe a pergunta **"faz sentido implementar?"**. Se sim, a documentação
  é ajustada, e a tarefa pode ser desenvolvida.

Esta skill só altera a documentação e a spec, e só depois da resposta do usuário. Não escreve código e não edita o Figma
nem o board.

## 1. Entender a entrada

- Tarefa: `#123`/`AB#123` (work item), `CCD014` ou o nome do caso de uso. Sem tarefa, pergunte qual é.
- Tela: um ou mais links do Figma com `node-id`, ou o nome da tela. Sem nenhum dos dois, procure no índice
  de telas da skill `/analisar-figma-chrome` a tela que corresponde à área do caso de uso (ex.: chat → "Comunidade -
  chat"). Se houver mais de uma candidata e não der para decidir pelo nome, pergunte qual usar.

## 2. Levantar os requisitos

Chame o agent `analista-requisitos` com a tarefa. Ele devolve a tabela de requisitos (R1, R2…), os dados
envolvidos, os conflitos e as lacunas da documentação.

Se a fase for **Futuro**, **Futuro Marketplace** ou **Escopo Adicional**, avise antes de seguir: a tarefa está fora do MVP.

## 3. Ler o Figma

Chame o agent `leitor-figma` com o(s) frame(s) **e a tabela de requisitos**, pedindo o inventário da tela e a
localização de cada requisito. Ele lê pelo Claude in Chrome, no modo protótipo, sem gastar a cota do MCP do Figma.
Várias telas vão na mesma chamada (ele usa uma aba só).

Se o agent voltar dizendo que o Chrome não está conectado, peça ao usuário para abrir o Chrome e rodar `/chrome` →
*Reconnect extension* (com o Chrome já aberto) e chame o agent de novo. Se o usuário pedir o Playwright, ou se o
Chrome continuar sem conectar, use a skill `/analisar-figma-playwright` no lugar do agent. Se o usuário pedir o MCP do
Figma, use a skill `/analisar-figma-mcp`.

## 4. Comparar

Monte a matriz requisito × Figma com uma destas situações:

| Situação | Quando |
|---|---|
| ✅ Coberto | O Figma mostra o requisito como a documentação descreve |
| ⚠️ Divergente | O Figma mostra, mas diferente (rótulo, regra, campo, fluxo, permissão) |
| ❌ Faltando | O Figma não mostra o requisito |

Depois liste os **extras do Figma**: elementos da tela que nenhum requisito pede. Para cada um, veja em
`docs/Casos-De-Uso/user-stories.md` se pertence a outra user story (outra tarefa, ou fase Futuro): se sim, diga
qual; se não, é algo fora da documentação.

Elementos puramente visuais (ícones, ilustrações, layout, cores) não são requisitos: só entram se contradisserem
uma regra (ex.: botão de excluir visível para quem não tem permissão).

## 5. Perguntar

Siga a **Fase 3** da `/cromocard-desenvolver` (`.claude/skills/cromocard-desenvolver/SKILL.md`): as mesmas categorias de
pendência, as mesmas opções e o mesmo formato de pergunta com `AskUserQuestion`. Decisão já registrada na spec não é
perguntada de novo. Sem nenhuma diferença, peça a confirmação de que está tudo coberto.

Quem não puder decidir agora deixa a pendência aberta: nada é alterado para ela, e ela aparece no relatório.

## 6. Registrar

Com as respostas, siga os passos 1 a 3 da **Fase 4** da `/cromocard-desenvolver`: Git do workspace, ajuste da documentação
e, se a tarefa já tiver spec, atualização da spec. Sem spec, ajuste só a documentação e ofereça o `/especificar`. Sem esse
registro, um "não fazer" será perguntado de novo no desenvolvimento.

## 7. Responder

```
## <CCDnnn> — <Nome> · #<work item> · fase <MVP|…>
Tela: <nome do frame> — <link>

**Veredito: ✅ Bate** | **Veredito: ⚠️ Com diferenças (<n> decididas, <n> abertas)**

| ID | Requisito (documentação) | Figma | Situação |
|---|---|---|---|

### Decisões
| Diferença | Decisão | Registrada em |

### Extras do Figma de outra tarefa
- <tela> — "<texto ou elemento>": pertence a <CCDnnn / Futuro>; <decisão>.

### Pendências abertas
- <o que falta decidir> | nenhuma

### Para o Gabriel (telas que ficam diferentes do Figma por decisão)
- <tela> — <o que muda e por quê>
```

Sem pendências abertas, ofereça desenvolver com `/cromocard-desenvolver faça esta spec "<CCDnnn>"`. Publicar o resumo como
comentário no work item é escrita no board: só com pedido explícito.
