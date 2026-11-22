# CCD005 — Acessar Central de Ajuda (FAQ)

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #110 `CCD005-Central de Ajuda FAQ`
- **Caso de uso:** [05-acessar-central-de-ajuda-faq.md](../../docs/Casos-De-Uso/05-acessar-central-de-ajuda-faq.md) · complementos: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md) (EA-005-01, EA-001-02)
- **Atores:** Visitante (o cliente logado usa a mesma página) · **Pré-condições:** nenhuma
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como visitante eu quero acessar uma página de dúvidas frequentes (FAQ) para entender como a plataforma gerencia trocas e álbuns antes de criar minha conta.

## Fidelidade ao Figma (obrigatória)

> ⚠️ **A tela implementada tem que ficar IGUAL ao Figma.** Os frames listados em **Telas (Figma)** são o contrato visual
> desta user story: não são referência, sugestão nem inspiração. Layout, ordem dos blocos, medidas, espaçamentos,
> alinhamentos, cores, tipografia (fonte, peso, tamanho e altura de linha), raios, bordas, sombras, ícones, imagens, textos
> (letra por letra) e estados (vazio, erro, carregando, hover, foco, desabilitado) seguem o frame. Medidas e cores saem do
> Figma, nunca "a olho".
>
> - Nada é inventado, trocado ou "melhorado" fora do frame. Diferença entre o Figma e a documentação vira lacuna em
>   **Lacunas e decisões** e é decidida antes do código (ADR-060). Até a decisão, vale a documentação.
> - O que o Figma não desenha (R marcado em "O que falta no Figma") segue o estilo da própria tela: os mesmos componentes,
>   tokens e espaçamentos.
> - A tela só está pronta quando o print dela em 1280 px, lado a lado com o print do frame, não mostra diferença. Em
>   celular (375 px), tablet (768 px) e laptop (1024 px), mantém o mesmo design adaptado, sem quebra, corte nem rolagem
>   horizontal.
> - A revisão (`/cromocard-revisor`) reprova o PR que não estiver igual ao Figma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | A Central de ajuda e o Como funciona abrem sem login; o cliente logado vê as mesmas páginas com o menu da Área do Cliente | Permissão | `05`, Pré-condições; EA-001-01 |
| R2 | "Central de ajuda" no menu lateral (e no rodapé) abre a Central de ajuda, com o item destacado no menu | Ação | `05`, FP 1; EA-001-03 |
| R3 | Cabeçalho com o rótulo "CENTRAL DE AJUDA", o título "Como podemos ajudar?" e o texto "Busque uma dúvida ou escolha um tópico." | Tela | `05`, FP 2 |
| R4 | Tópicos "Primeiros passos", "Pagamentos", "Envio e entrega", "Álbuns digitais", "Vender na CromoCard" e "Segurança e denúncias", com "Primeiros passos" selecionado ao abrir; cada tópico lista as perguntas dele | Tela | `05`, FP 2; EA-005-01 |
| R5 | Cada pergunta é um cartão fechado (sinal "+"); selecioná-la expande o cartão com a resposta completa e os links úteis (sinal "−") | Ação | `05`, FP 3–4 (L4, L7) |
| R6 | Campo de busca "Busque por “pagamento”, “frete”, “álbum”..." que filtra as perguntas pelo texto | Campo | EA-005-01 (L5) |
| R7 | Cartão "Não encontrou o que procurava?" com o botão "Enviar e-mail" | Tela | `05`, FA 1 |
| R8 | "Enviar e-mail" abre o e-mail do visitante (link `mailto:`) com o endereço do suporte preenchido | Ação | `05`, FA 2 (L3) |
| R9 | Página "Como funciona", aberta pelo menu lateral e pelo rodapé: rótulo "COMO FUNCIONA", título "Como a CromoCard funciona" e as abas "Quero comprar" (aberta ao entrar) e "Quero vender" | Tela | EA-001-02; EA-001-03 |
| R10 | Aba "Quero comprar": texto "Compre e venda cartas colecionáveis com o pagamento protegido do começo ao fim.", os 4 passos "Encontre a carta", "Pague com proteção", "Receba e confira" e "Colecione", a seção "Suas garantias" ("Pagamento retido", "Vendedores verificados", "Suporte se der problema", "Preços transparentes") e "Quanto custa?" | Tela | EA-001-02 |
| R11 | Aba "Quero vender": texto "Venda suas cartas para colecionadores de todo o Brasil e receba com segurança.", os 4 passos "Crie a conta de vendedor", "Conecte a conta de recebimento", "Anuncie e envie" e "Receba", a seção "Por que vender aqui" ("Pagamento garantido", "Frete sem complicação", "Repasse automático", "Preço de referência") e "Quanto custa?" | Tela | EA-001-02; ADR-066; ADR-067 |
| R12 | "Quanto custa?" mostra 0% "para comprar" e 5% "por venda", o texto "Criar conta e anunciar é grátis. Cobramos 5% do valor da carta em cada venda concluída, descontados do vendedor." e "Criar conta grátis", que abre o cadastro (CCD003) | Tela | EA-001-02; ADR-027 (taxa de 5%); `110`, FP 6 |
| R13 | O Como funciona é estático: não chama a API | Regra | EA-001-02 (observação) |
| R14 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R5) — **Dado** um visitante na Home, **quando** seleciona "Central de ajuda" no menu lateral, **então** abre a
  Central com "Primeiros passos" selecionado e as perguntas fechadas; **quando** seleciona uma pergunta, **então** o cartão
  se expande com a resposta e o sinal muda para "−".
- **CA2** (R4) — **Dado** a Central aberta, **quando** o visitante seleciona "Pagamentos", **então** a lista passa a mostrar só
  as perguntas de Pagamentos e o tópico fica destacado.
- **CA3** (R6) — **Dado** a Central aberta, **quando** o visitante digita "frete" na busca, **então** só as perguntas que
  contêm "frete" aparecem.
- **CA4** (R7, R8) — **Dado** a Central aberta, **quando** o visitante seleciona "Enviar e-mail", **então** o navegador abre o
  programa de e-mail com o endereço do suporte no destinatário.
- **CA5** (R1) — **Dado** um cliente logado, **quando** abre a Central de ajuda ou o Como funciona, **então** vê o mesmo
  conteúdo com o menu da Área do Cliente; sem login, as páginas abrem normalmente.
- **CA6** (R9, R10, R12) — **Dado** um visitante, **quando** seleciona "Como funciona", **então** abre a aba "Quero comprar" com
  os 4 passos, "Suas garantias" e "Quanto custa?" com 0% e 5%.
- **CA7** (R11) — **Dado** a página Como funciona, **quando** o visitante seleciona "Quero vender", **então** vê os 4 passos
  do vendedor e "Por que vender aqui".
- **CA8** (R12) — **Dado** a página Como funciona, **quando** o visitante seleciona "Criar conta grátis", **então** abre o
  cadastro.
- **CA9** (R13) — **Dado** a página Como funciona aberta, **quando** as requisições de rede são inspecionadas, **então**
  nenhuma chamada à API é feita para montar o conteúdo.
- **CA10** (R14 de Fidelidade) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o
  print dela é comparado lado a lado com o print do frame `1112-6843`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem
  rolagem horizontal.
- **CA11** (R14 de Fidelidade) — Idem ao CA10, com a aba "Quero comprar" do Como funciona e o frame `1112-6532`.
- **CA12** (R14 de Fidelidade) — Idem ao CA10, com a aba "Quero vender" do Como funciona e o frame `1160-2268`.

- **CA13** (R14) — **Dado** cada tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame correspondente (`1112-6532`, `1160-2268`), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
## Dados

Nenhuma tabela: o DER não tem tabela de perguntas frequentes (L1), e o Como funciona é estático (R13). O endereço do suporte
é a L3.

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Central de ajuda | [1112-6843](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-6843) | R2–R8 | ⚠️ Difere: sem links úteis na resposta (L4); prazo e horário de atendimento só no Figma (L6) |
| Público - Como funciona | [1112-6532](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-6532) | R9, R10, R12, R13 | ✅ Bate (EA-001-02) |
| Público - Como funciona - quero vender | [1160-2268](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-2268) | R9, R11–R13 | ✅ Bate (EA-001-02) |

- O frame de referência "Referência - Central de ajuda" (`1122-19326`) diz que o cliente logado usa a mesma Central, com o
  menu do cliente (menu e topo seguem `1122-17812`).
- O frame `1112-6843` mostra a segunda pergunta já aberta: é o estado depois do FP 3.
- **Diferenças com o Figma** (decisão em Lacunas e decisões): Central de ajuda — a resposta aberta não tem os "links úteis"
  do `05`, FP 4 (L4).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): Central de ajuda — "Nossa equipe responde em até
  24h úteis." e "Seg. a sex., 9h às 18h" (L6).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R6 o resultado da busca e o estado sem resultado
  (L5); R4 as perguntas dos outros tópicos (L2).

## Fora do escopo

- Cadastro aberto por "Criar conta grátis" — CCD003.
- Atendimento do suporte (responder e-mails, analisar reclamações, reembolsar) — fora do sistema; o reembolso pelo admin é
  da CCD111.
- Tópico "Trocas" e chat do suporte — saíram do Figma (EA-005-01; `escopo-adicional.md`, seção 3).
- Termos de Uso e Política de Privacidade (link do rodapé) — CCD003 (EA-001-04).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | De onde vêm os tópicos e as perguntas (`05`, FP 2, "o sistema carrega")? O DER não tem tabela de FAQ. (proposta: conteúdo estático no frontend, como o Como funciona; o admin não edita) | pendente | — |
| L2 | Qual o texto das perguntas e respostas? O Figma mostra 5 perguntas de "Primeiros passos" e só uma resposta; os outros 5 tópicos não têm texto. (proposta: o PO escreve, como o texto dos Termos no EA-001-04) | pendente | — |
| L3 | Qual o endereço de e-mail do suporte (`05`, FA 2)? Não está na documentação nem no Figma. Fica numa configuração do frontend (ADR-045) ou numa chave de `global_settings`? (proposta: configuração do frontend) | pendente | — |
| L4 | O `05`, FP 4, fala em "links úteis" na resposta; a resposta aberta no Figma não tem links. Quais links e em quais respostas? (proposta: links internos só onde a resposta pedir, ex.: "Como funciona") | pendente | — |
| L5 | A busca da Central procura em todos os tópicos ou só no selecionado? O que aparece sem resultado? Nada disso está desenhado. (proposta: em todos os tópicos, sem diferenciar acentos; sem resultado, um aviso no estilo do vazio da busca `1112-4356`, com o cartão "Enviar e-mail" ao lado) | pendente | — |
| L6 | O cartão do suporte no Figma promete "Nossa equipe responde em até 24h úteis." e "Seg. a sex., 9h às 18h"; nenhum documento define prazo ou horário de atendimento. Faz sentido implementar esses textos? | pendente | — |
| L7 | Abrir uma pergunta fecha a que estava aberta? Selecionar a aberta a recolhe? O `05` só diz que expande. (proposta: selecionar de novo recolhe; várias podem ficar abertas) | pendente | — |
| L8 | A narrativa da user story fala em entender "trocas", mas trocas estão fora do MVP (ADR-027) e o tópico "Trocas" saiu do Figma (EA-005-01). A narrativa deve mudar para "compras, vendas e álbuns"? | pendente | — |
