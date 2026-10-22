---
name: analisar-figma-chrome
description: Analisa telas do protótipo do CromoCard no Figma pelo Claude in Chrome, tirando prints no modo protótipo (só leitura), sem gastar a cota do MCP do Figma, e devolve o inventário de cada tela — seções, campos, botões, textos, mensagens e estados —, opcionalmente localizando uma lista de requisitos. Aceita o link do frame ou o nome da tela. É o caminho padrão para ver o Figma; use no /conferir-tarefa ou sempre que precisar olhar uma tela.
argument-hint: "<link do frame ou nome da tela> [requisitos]"
---

Analisa a tela `$ARGUMENTS` do Figma pelo navegador, por prints. Para medidas exatas, tokens ou quando o usuário
pedir o MCP, use a skill `/analisar-figma-mcp`.

## Regras

- **Só o modo protótipo** (`/proto/`). **Nunca abra o editor** (`/design/`) nem clique em *Open in editor*: o
  editor trava a extensão do Claude in Chrome (todas as ações falham até a aba fechar) e, para quem pode editar, um
  clique no canvas altera o arquivo do time.
- No protótipo, só olhe: não comente e não clique no canvas, exceto para seguir um fluxo de navegação quando o
  pedido for esse (o botão *Restart* volta ao início).
- **Não use a ação `zoom`** do `computer`: no teste ela congelou a aba. Para ler detalhes, abra a tela em tamanho
  real (passo 3).

## Antes de começar

- O Chrome precisa estar **aberto, com uma janela visível** e logado numa conta do Figma com acesso ao arquivo, e o
  Claude in Chrome conectado (`/chrome` → *Status: Enabled*). Se não estiver conectado, peça ao usuário para abrir o
  Chrome **antes** de rodar `/chrome` → *Reconnect extension* (com o Chrome fechado, ele abre e fecha sozinho).

## Passos

1. **Achar o frame da tela.** Pelo link (`…?node-id=230-4748`) ou pelo nome no [índice](#índice-de-telas) abaixo.
   O protótipo só abre frames de tela de primeiro nível: o link de uma camada interna cai no início do fluxo.
2. **Visão geral.** `tabs_context_mcp` com `createIfEmpty: true`; numa aba do grupo, `navigate` para
   `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=<id>`, `computer` → `wait` de 10 s e
   `computer` → `screenshot`. A tela inteira aparece reduzida: bom para entender a estrutura e as seções. Junte as
   ações num `browser_batch`.
   - Se a URL da aba trocar o `node-id` (por exemplo para `59-1639`, a captura do OpenSea que abre o fluxo), o link
     era de uma camada interna: use o índice ou peça o link do frame (no Figma: clicar no nome do frame no canvas →
     botão direito → *Copy link to selection*).
3. **Detalhes em tamanho real.** `navigate` para o mesmo link com `&scaling=min-zoom&content-scaling=fixed` no fim,
   `wait` de 10 s e `screenshot` sem `scale`: os textos ficam legíveis. Para ver o que não coube, `computer` →
   `scroll` para baixo (ou para a direita) sobre a tela e novo `screenshot`, até cobrir a tela toda. Áreas com rolagem
   própria (como a lista de mensagens do chat) rolam separadas: role com o cursor sobre elas.
4. **Fechar.** `tabs_close_mcp` na aba ao terminar.

## Quando o navegador falha

- "Browser extension is not connected": chame `tabs_context_mcp` uma vez (costuma reconectar sozinho). Antes de
  repetir a última ação, tire um `screenshot` para ver se ela já aconteceu.
- `screenshot` com *timed out* ("renderer may be frozen"): feche a aba e abra uma nova.
- Duas falhas seguidas: pare e peça ao usuário para conferir o Chrome aberto e rodar `/chrome` → *Reconnect extension*.

## O que observar

Seções e hierarquia; campos (rótulo, placeholder, obrigatoriedade aparente); botões e links (rótulo e destino
provável); textos, títulos e mensagens; listas e tabelas (colunas, filtros, contadores, ordenação, paginação);
estados mostrados (vazio, erro, carregando, sucesso, modal, confirmação); dados de exemplo que revelam regra
(preço, quantidade, status, avaliação). Descreva só o que está na tela e marque o que for dedução com `(?)`.
Se receber requisitos, diga para cada um onde aparece na tela ou `não encontrado`, sem julgar quem está certo —
quem compara com a documentação é quem pediu.

## Resposta

```
## Tela: <nome do frame> (node <id>)
Protótipo: <link /proto/>

### Seções
- <seção>: <o que tem>

### Elementos
| Tipo | Rótulo / texto | Onde | Observação |
|---|---|---|---|

### Estados e mensagens
### Requisitos localizados (se recebeu a lista)
| ID | Onde aparece ou "não encontrado" |
|---|---|
```

## Índice de telas

Frames de tela da `Page 1` (arquivo `43K7rTPJQNIOroQ4j09YTP`), levantados em 2026-10-19. Nomes como estão no
Figma. Vários ids no mesmo nome são variações (estados) da tela: veja as que fizerem sentido para a tarefa. Se a tela
não estiver aqui, o arquivo mudou: peça o link do frame ou regenere o índice com `/analisar-figma-mcp`.

**Painel Público**
- Painel Publico - Perfil: `108-1423`, `116-534`, `150-701`, `150-946`, `150-1157`, `126-1221`, `126-1417`, `152-1641`, `152-1797`, `152-1953`, `152-2109`, `152-2265`, `152-2425`, `284-5290`
- Painel Publico - SEM LOGIN: `178-1214`

**Login**
- Painel Login: `77-533`, `152-2587`, `238-1204`

**Perfil e configurações**
- Perfil e configurações: `229-3585`

**Comunidade e chat**
- Comunidade - chat: `230-4748`
- Comunidades - Grupos: `231-5395`

**Painel do vendedor**
- Painel vendedor: `281-3729`
- Painel vendedor - criar anuncio: `282-4482`

**Administração (BackOffice)**
- Administração - dashboard geral: `208-1240`
- Administração - dashboard geral - filtro de 7 dias: `247-2499`, `247-3539`
- administração - Gestão de usuarios: `208-1793`
- administração -notificação: `208-2380`
- administração - adicionando notificação: `277-2689`
- administração - catalago: `208-2895`
- administração - comunidade: `220-3524`
- administração - relatorio: `228-1236`
- administração - fila de solicitações de cartas: `228-1804`
- administração - logs do sistema: `228-2395`
- administração - configurações da plataforma: `228-3048`
- administração - Validar Cadastro: `246-1201`
- Administraçaão - notificar pendencia de cadastro: `246-2038`
- Administração - tela de notificação enviada: `252-1375`
- administração - adicionar novo usuario: `276-1202`
- administração - remover usuario: `276-1735`
- administração - notificação enviada: `277-2982`

**Sem nome (camadas importadas de HTML)**
- Html → Body: `252-1723` e `252-2837` (dossiê do vendedor, estados Em análise e Aprovado), `278-3246` (cadastrar carta)

Fora do índice: slides da apresentação (`Slide 16:9 - N`), componentes soltos e a captura de referência do OpenSea
(`59-1639`).
