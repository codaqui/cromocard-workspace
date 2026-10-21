---
name: analisar-figma-mcp
description: Analisa telas do protótipo do CromoCard pelo MCP oficial do Figma — estrutura de camadas, print, variáveis e contexto de implementação — e regenera o índice de telas. Gasta a cota do MCP (cerca de 20 chamadas por mês no plano Starter), então use só quando o usuário pedir o MCP, quando precisar de medidas exatas ou tokens, ou para atualizar o índice; no dia a dia use /analisar-figma-chrome.
argument-hint: "<link do frame ou nome da tela> [o que precisa: estrutura, print, tokens, implementação, índice]"
disable-model-invocation: true
---

Analisa `$ARGUMENTS` pelo MCP `figma`. Cada chamada de leitura gasta a cota do mês: planeje as chamadas antes,
faça só as necessárias e diga no fim quantas usou.

## Regras

- **Só leitura.** Nunca use ferramentas que escrevem no arquivo (`use_figma`, `generate_figma_design`,
  `html_to_figma`, `send_code_to_figma`, `upload_assets`, `create_new_file`, `add_code_connect_map`, `generate_diagram`)
  sem pedido explícito — o `.claude/settings.json` também pede confirmação para elas.
- Arquivo do time: fileKey `43K7rTPJQNIOroQ4j09YTP`, uma página (`0:1`, "Page 1"). Link `…?node-id=230-4748` vira
  `nodeId` `230:4748` (troque `-` por `:`). O nome da tela vira id pelo índice da skill `/analisar-figma-chrome`.
- `whoami` não conta na cota. Use quando der erro de acesso ou de limite: ele mostra a conta, o plano e o seat.

## Ferramentas, da mais barata para a mais cara

| Ferramenta | Traz | Quando |
|---|---|---|
| `create_session` | id da sessão | Uma vez, antes de qualquer leitura; passe o `sessionId` em todas as chamadas |
| `get_metadata` (com `nodeId`) | XML com camadas, nomes, textos, posições e tamanhos | Estrutura da tela e os textos (o nome de uma camada de texto costuma ser o próprio texto) |
| `get_screenshot` | URL temporária e comando `curl` do PNG | Ver o visual: baixe o PNG para um arquivo temporário e abra com `Read` |
| `get_variable_defs` | Variáveis (cores, espaçamentos, tipografia) usadas no nó | Alinhar `styles/tokens.css` do frontend (ADR-044) |
| `get_design_context` | Código de referência e contexto de implementação | Só para implementar a tela, e só depois de carregar a skill `/figma-design-to-code` (ou o recurso `skill://figma/figma-design-to-code/SKILL.md`), como o MCP exige. A saída é referência a adaptar aos componentes e tokens do projeto, não código final |

Respostas grandes (o `get_metadata` de uma tela pode passar de 50 KB) vêm salvas num arquivo: leia com `Grep`/`Read`
em partes ou extraia com um comando, sem despejar tudo na conversa.

## Passos para analisar uma tela

1. `create_session` com o fileKey e uma descrição curta do pedido.
2. `get_metadata` do nó da tela: seções, campos, botões e textos.
3. `get_screenshot` só se a estrutura não bastar (estado visual, ícone sem nome, layout).
4. `get_variable_defs` ou `get_design_context` só se o pedido for tokens ou implementação.
5. Responda no mesmo formato da skill `/analisar-figma-chrome` (Seções, Elementos, Estados e mensagens, Requisitos
   localizados) e acrescente `Chamadas ao MCP usadas: <n>`.

## Regenerar o índice de telas

Quando o designer criar ou renomear telas (2 chamadas):

1. `get_metadata` sem `nodeId`: lista as páginas.
2. `get_metadata` com o id de cada página: a resposta é grande e vem salva num arquivo. Extraia dela só os nós
   `frame` de primeiro nível (filhos diretos da página), com `id` e `name`; ignore slides (`Slide 16:9 - N`),
   componentes, textos soltos e as camadas da captura do OpenSea.
3. Agrupe por área (Painel Público, Login, Perfil e configurações, Comunidade e chat, Painel do vendedor,
   Administração) e substitua a seção **Índice de telas** de `.claude/skills/analisar-figma-chrome/SKILL.md`,
   com a data do levantamento. Ids no formato do link (`230-4748`), variações do mesmo nome na mesma linha.
