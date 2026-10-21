---
name: analisar-figma-playwright
description: Analisa telas do protótipo do CromoCard no Figma pelo MCP do Playwright (servidor playwright-figma), sem a extensão do Chrome e sem gastar a cota do MCP do Figma — print da tela inteira em tamanho real e o texto exato de cada camada — e devolve o inventário de cada tela — seções, campos, botões, textos, mensagens e estados —, opcionalmente localizando uma lista de requisitos. Aceita o link do frame ou o nome da tela. Use quando o usuário pedir o Playwright, quando o Claude in Chrome não estiver conectado ou quando precisar dos textos exatos da tela.
argument-hint: "<link do frame ou nome da tela> [requisitos]"
---

Analisa a tela `$ARGUMENTS` do Figma pelo servidor MCP `playwright-figma`: um Chrome controlado pelo Playwright, com
perfil próprio onde fica o login do Figma. Além do print, o protótipo expõe a árvore de acessibilidade com o texto de
cada camada, então os textos saem exatos, sem depender da leitura do print. Para medidas exatas, tokens ou quando o
usuário pedir o MCP do Figma, use a skill `/analisar-figma-mcp`.

## Regras

- **Só o modo protótipo** (`/proto/`). **Nunca abra o editor** (`/design/`) nem use *Open in editor*: o perfil está
  logado e, para quem pode editar, uma ação no editor altera o arquivo do time.
- Só olhe: não clique no canvas, não use o botão *Comment* da barra do protótipo e não pressione teclas (as setas
  trocam de tela). Siga um fluxo de navegação só quando o pedido for esse: os hotspots aparecem no snapshot como
  `link "<camada>"`, o botão *Restart* volta ao início e o clique pede confirmação.
- Chame as ferramentas **uma por vez**, nunca em paralelo: em paralelo, o print sai antes de a espera terminar.
- Use as ferramentas `mcp__playwright-figma__*`. O servidor `playwright` (sem `-figma`) é isolado e não tem login:
  no Figma ele só mostra a tela de login.

## Antes de começar

- O `/mcp` deve mostrar `playwright-figma` conectado. Se as ferramentas estiverem adiadas, carregue todas de uma vez
  com `ToolSearch`
  (`select:mcp__playwright-figma__browser_navigate,mcp__playwright-figma__browser_wait_for,mcp__playwright-figma__browser_find,mcp__playwright-figma__browser_snapshot,mcp__playwright-figma__browser_resize,mcp__playwright-figma__browser_take_screenshot,mcp__playwright-figma__browser_close`).
- **Login, só na primeira vez.** Se a página responder `HTTP status: 403` ou mostrar "Deseja dar uma olhada neste
  arquivo? Cadastre-se ou faça login", o perfil não está logado. Peça ao usuário para entrar no Figma na janela do
  Chrome que o Playwright abriu, com a conta que tem acesso ao arquivo (se o Google bloquear o navegador
  automatizado, *Continuar com o e-mail*), e espere a confirmação. O perfil guarda o login para as próximas sessões.
  Nunca digite a senha de ninguém.

## Passos

1. **Achar o frame da tela.** Pelo link (`…?node-id=230-4748`) ou pelo nome no índice de telas da skill
   `/analisar-figma-chrome` (`.claude/skills/analisar-figma-chrome/SKILL.md`, seção "Índice de telas"). O protótipo
   só abre frames de tela de primeiro nível: se a URL trocar o `node-id` (por exemplo para `59-1639`, a captura do
   OpenSea que abre o fluxo), o link era de uma camada interna — use o índice ou peça o link do frame.
2. **Abrir em tamanho real.** `browser_navigate` para
   `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=<id>&scaling=min-zoom&content-scaling=fixed`.
3. **Esperar a tela.** `browser_wait_for` com `time: 5` e depois `browser_find` com o texto
   `article "<nome do frame>"` (o nome como está no índice). Sem resultado, a página ainda está em `Loading`: espere
   mais 5 s e procure de novo. Passou de 30 s, navegue de novo — às vezes a carga trava num erro de WebSocket e
   recarregar resolve. Não use o *Restart* como sinal (aparece antes do conteúdo) nem `textGone: "Loading"` (estoura
   em 5 s).
4. **Medir e ler os textos.** `browser_snapshot` com `boxes: true` e `filename: ".playwright-mcp/<id>.yml"`, e leia
   o arquivo com `Grep`/`Read`:
   - a linha `article "<nome do frame>" [box=x,y,L,A]` dá a largura `L` e a altura `A` do frame;
   - cada `paragraph` é um texto da tela, na ordem das camadas (não na ordem visual): o `box` diz onde ele fica;
   - `link "<camada>"` é um hotspot do protótipo (leva a outra tela ou estado);
   - `img "<camada>"` é uma imagem; o nome da camada nem sempre diz o que ela mostra.

   O snapshot não diferencia botão, campo e rótulo: isso sai do print.
5. **Print da tela inteira.** `browser_resize` com `width: L` e `height: A` e depois `browser_take_screenshot` com
   `scale: "css"`. A barra do protótipo some e o frame cabe inteiro num print (testado com 1920×2570, legível). Em
   frames muito altos o print chega reduzido: confie nos textos do snapshot e recorte as partes. Para ver uma parte em
   resolução total, `browser_take_screenshot` com `target: 'role=article[name="<camada>"]'`, usando o nome de um
   `article` do snapshot.
6. **Fechar.** `browser_close` ao terminar. Com várias telas, repita os passos 2 a 5 e feche só no fim.

## O que observar e resposta

Siga as seções "O que observar" e "Resposta" da skill `/analisar-figma-chrome`, com os textos copiados do snapshot
(exatos, com acentos e pontuação). Acrescente no fim da resposta `Ferramenta: Playwright (playwright-figma)`.
