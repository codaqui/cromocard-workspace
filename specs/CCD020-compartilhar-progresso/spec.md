# CCD020 — Compartilhar Progresso

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #126 `CCD020 -Compartilhar Progresso`
- **Caso de uso:** [20-compartilhar-progresso.md](../../docs/Casos-De-Uso/20-compartilhar-progresso.md) · complemento: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md), EA-020-01
- **Atores:** Cliente · **Pré-condições:** cliente autenticado, com um álbum com progresso registrado
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso compartilhar o progresso do meu álbum para mostrar a outras pessoas o andamento da minha coleção.

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
| R1 | Compartilhar exige login: sem token, `401`. O cliente só compartilha álbuns da própria coleção: álbum fora da coleção dele responde `404` | Permissão | `20`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | O botão "Compartilhar progresso", no cabeçalho do detalhe do álbum, abre o modal "COMPARTILHAR PROGRESSO DO ÁLBUM", com "Mostre o andamento da sua coleção para a comunidade" e "Gere o cartão para as redes sociais, compartilhe o link do álbum ou mostre o QR Code." | Ação | `20`, FP 1; Figma `1160-23696`, `1160-25301` |
| R3 | O modal gera o cartão com as estatísticas atuais do álbum: título, "Colecionador: @<nome de usuário>", "<n>% Concluído", "(<x> de <total> cartas)", "Faltam <y> cartas para completar" e os totais "<x> no álbum (<n>%)", "<y> faltantes" e "<z> repetidas" | Tela | `20`, FP 2; Figma `1160-25301` |
| R4 | O modal gera o link público do álbum, com "Copiar Link" e o aviso "Qualquer pessoa com o link vê o progresso do álbum." | Ação | `20`, FP 2 e FP 3 ("link direto"); Figma `1160-25301` |
| R5 | O cliente escolhe o meio de compartilhamento: copiar o link ou "Compartilhar Link Público" | Ação | `20`, FP 3; Figma `1160-25301` (L2) |
| R6 | Depois de compartilhar ou copiar o link, a tela mostra uma mensagem de sucesso | Mensagem | `20`, FP 4 (L9) |
| R7 | Com o álbum em 0%, "Compartilhar progresso" abre antes o alerta "Compartilhar um álbum vazio?", com "O álbum "<título>" ainda está em 0%: nenhuma carta foi marcada como possuo. Quer compartilhar mesmo assim?"; "Cancelar" e "✕" fecham sem compartilhar, e "Compartilhar mesmo assim" abre o modal | Regra | `20`, FA 1; Figma `1160-26693` |
| R8 | A opção "Mostrar as cartas faltantes na página do link" ("Lista as <y> cartas que faltam para completar o álbum.") é salva ao mudar ("Salvo automaticamente"); ligada, quem abre o link vê a lista das faltantes | Ação | EA-020-01; Figma `1160-25301` (L8) |
| R9 | Quem abre o link, mesmo sem login, vê o progresso do álbum | Tela | `20`, FP 2; Figma `1160-25301` ("Qualquer pessoa com o link vê o progresso do álbum.") (L10) |
| R10 | "Fechar" e "✕" fecham o modal | Ação | Figma `1160-25301` |
| R11 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `1160-23696`, `1160-25301`, `1160-26693`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R4) — **Dado** um álbum com 44 de 54 cartas, **quando** o cliente seleciona "Compartilhar progresso",
  **então** o modal abre com o cartão do álbum (título, "Colecionador: @<nome de usuário>", percentual, "(44 de 54
  cartas)", "Faltam 10 cartas para completar" e os três totais) e o link público com "Copiar Link".
- **CA2** (R5, R6) — **Dado** o modal aberto, **quando** o cliente seleciona "Copiar Link", **então** o link vai para a
  área de transferência e a tela mostra a mensagem de sucesso.
- **CA3** (R5, R6) — **Dado** o modal aberto, **quando** o cliente seleciona "Compartilhar Link Público", **então** o
  compartilhamento decidido na L2 acontece e a tela mostra a mensagem de sucesso.
- **CA4** (R7) — **Dado** um álbum em 0%, **quando** o cliente seleciona "Compartilhar progresso", **então** vê o alerta
  "Compartilhar um álbum vazio?" com o título do álbum; **quando** seleciona "Cancelar", **então** o alerta fecha e nada é
  compartilhado.
- **CA5** (R7) — **Dado** o alerta de álbum vazio aberto, **quando** o cliente seleciona "Compartilhar mesmo assim",
  **então** o modal de compartilhamento abre com 0%.
- **CA6** (R8, R9) — **Dado** a opção "Mostrar as cartas faltantes na página do link" ligada, **quando** um visitante sem
  login abre o link, **então** vê o progresso e a lista das cartas faltantes; **dado** a opção desligada, **então** vê só
  o progresso.
- **CA7** (R8) — **Dado** o cliente desliga a opção e fecha o modal, **quando** abre o modal de novo, **então** a opção
  continua desligada, sem precisar de botão de salvar.
- **CA8** (R10) — **Dado** o modal aberto, **quando** o cliente seleciona "Fechar" ou "✕", **então** o modal fecha e a
  página do álbum continua como estava.
- **CA9** (R1) — **Dado** um visitante sem login, **quando** chama a rota que gera o link, **então** recebe `401`; **dado**
  um cliente logado, **quando** pede o link de um álbum fora da coleção dele, **então** recebe `404`.
- **CA10** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-23696`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no botão "Compartilhar progresso" do cabeçalho; e em 375, 768 e 1024 px o mesmo design se
  adapta sem quebra, corte nem rolagem horizontal.
- **CA11** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-25301`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no modal de compartilhar; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra,
  corte nem rolagem horizontal.
- **CA12** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-26693`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no alerta de álbum vazio; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra,
  corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `user_albums` | `collection_id`, `album_id`, `progress_percentage`, `updated_at`, `deleted_at` | progresso do álbum (regras da CCD019) |
| `albums` | `title`, `total_cards` | título e total no cartão |
| `collection_cards` | `card_id`, `status` (`OWNED`, `MISSING`, `DUPLICATE`), `quantity`, `deleted_at` | totais e lista das faltantes |
| `cards` | `album_id`, `name`, `number`, `front_image_url` | lista das faltantes na página do link |
| `users` | `username` | "Colecionador: @<nome de usuário>" e o caminho do link |
| `collections` | `is_public`, `share_link` | privacidade e link da coleção (CCD012); relação com o link do álbum na L7 |
| `profiles` | `portfolio_privacy` (`privacy`: `PUBLIC`, `PRIVATE`) | default `PUBLIC`; conflito com `collections.is_public` (default `false`) na L7 |

O DBML não tem onde guardar o link do álbum nem a opção "Mostrar as cartas faltantes" (L6, L8).

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - detalhe do álbum (botão "Compartilhar progresso") | [1160-23696](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23696) | R2 | ✅ Bate |
| Álbuns - compartilhar progresso | [1160-25301](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-25301) | R2–R5, R8–R10 | ❌ Não bate: sem imagem para baixar nem redes sociais (L1, L2); QR Code, valor estimado, destaques e hora de atualização só no Figma (L3–L5) |
| Álbuns - compartilhar álbum vazio | [1160-26693](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-26693) | R7 | ✅ Bate |

- O `EA-020-01` cita o frame `1160-6346`, que não está mais no índice; a opção "Mostrar as cartas faltantes" hoje está no
  modal `1160-25301`.
- No alerta `1160-26693`, o exemplo cita "Legend of Blue Eyes" sobre a página da Copa do Mundo 2026: é dado de exemplo; a
  tela mostra o título do álbum aberto (R7).
- **Diferenças com o Figma** (decisão em Lacunas e decisões): modal — o FP 2 pede "imagem ou link" e o FP 3 "rede social,
  link direto"; o modal não tem "Baixar imagem" nem botões de rede social, que o modal de compartilhar coleção (`1160-9616`)
  tem (L1, L2).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): modal — "QR Code Rápido", "Escaneamento em
  encontros e ligas." e "Ampliar QR" (L3); "VALOR ESTIMADO" e "DESTAQUES DA COLEÇÃO NO CARD" / "3 cartas em destaque" (L4);
  "Atualizado hoje às 14:32" (L5).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R6 a mensagem de sucesso (L9); R9 a página pública
  que o link abre (L10).

## Fora do escopo

- Compartilhar a coleção inteira — CCD012.
- Ligar ou desligar "Coleção pública" — CCD051 (Configurações).
- Calcular o progresso — CCD019.
- "Comprar Faltantes" e a grade de cartas que aparecem atrás do modal — CCD013 e marketplace.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O FP 2 fala em gerar "uma imagem ou link". O modal mostra o cartão, mas não tem como baixar a imagem (o de compartilhar coleção tem "Baixar imagem"). Gerar o arquivo de imagem do cartão? | pendente | — |
| L2 | O FP 3 fala em "rede social, link direto". O modal só tem "Copiar Link" e "Compartilhar Link Público". O que este botão faz? (proposta: o compartilhamento nativo do navegador, com o link; sem suporte, copia o link) Acrescentar WhatsApp, X e Facebook, como no compartilhar coleção? | pendente | — |
| L3 | "QR Code Rápido", com "Ampliar QR", só existe no Figma: faz sentido implementar? | pendente | — |
| L4 | "VALOR ESTIMADO" (EA-007-01) e "DESTAQUES DA COLEÇÃO NO CARD" ("3 cartas em destaque") só existem no Figma: faz sentido implementar? Quais três cartas? (proposta: as três possuídas de maior preço médio) | pendente | — |
| L5 | "Atualizado hoje às 14:32" só existe no Figma: é a hora da última marcação do álbum (`user_albums.updated_at`)? Faz sentido implementar? | pendente | — |
| L6 | O link do Figma é `cromocard.com.br/u/<nome de usuário>/albuns/<slug>`, mas `albums` não tem `slug` no DBML. Usar o id do álbum ou criar a coluna (mudança no DER e ADR)? | pendente | — |
| L7 | O link do álbum segue a privacidade da coleção? Configurações (`1160-41305`) diz "Coleção pública … o link de compartilhar funciona. Desligada, só você vê.", e a CCD012 (FA 1) pede torná-la pública antes. E qual coluna vale: `collections.is_public` (default `false`) ou `profiles.portfolio_privacy` (default `PUBLIC`)? O critério de aceite da coleção privada nasce com a decisão | pendente | — |
| L8 | Onde guardar a opção "Mostrar as cartas faltantes na página do link"? O DBML não tem coluna. E começa ligada, como no Figma? | pendente | — |
| L9 | Texto e forma da mensagem de sucesso (FP 4), que o Figma não desenha | pendente | — |
| L10 | A página pública que o link abre não tem frame no Figma: pedir o desenho? O que ela mostra (o cartão do modal e, com a opção ligada, as faltantes)? | pendente | — |
| L11 | "Cliente" são os papéis `CUSTOMER` e `SELLER`? E o `ADMIN`? (proposta: `CUSTOMER` e `SELLER`; `ADMIN` recebe `403`, como na CCD103, L8) | pendente | — |
