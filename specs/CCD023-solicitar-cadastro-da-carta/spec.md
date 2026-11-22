# CCD023 — Solicitar Cadastro da Carta

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #156 `CCD023 - Solicitar Cadastro da Carta`
- **Caso de uso:** [23-solicitar-cadastro-da-carta.md](../../docs/Casos-De-Uso/23-solicitar-cadastro-da-carta.md)
- **Atores:** Cliente · **Pré-condições:** cliente autenticado, que pesquisou a carta sem encontrá-la
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso solicitar o cadastro de uma carta para que itens ainda não disponíveis na plataforma possam ser adicionados posteriormente.

A seção 3 de `user-stories.md` repete a story como "Solicitar Cadastro de Carta" ("caso ela não exista na busca global").

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
| R1 | Solicitar exige login: sem token, `401` | Permissão | `23`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | A opção "Solicitar cadastro da carta →" ("Não encontrou a carta?"), no modal "Adicionar carta", abre o formulário | Ação | `23`, FP 1; `36`, FA 2; Figma `1160-28449` (L8) |
| R3 | A página "Solicitar cadastro da carta" mostra "Não achou a carta no catálogo? Informe os dados e envie uma foto da frente para a equipe da CromoCard conferir.", o caminho "Início › Álbuns › Solicitar Cadastro › Nova Carta" e "Voltar aos álbuns" | Tela | `23`, FP 2; Figma `1160-24389` |
| R4 | O formulário pede nome ("Nome Oficial da Carta / Cromo"), número ("Número no Set / Edição"), álbum ("Álbum ou Edição Principal"), franquia ("Categoria / Franquia da Coleção"), raridade ("Raridade Estimada") e idioma ("Idioma da Carta") | Campo | `23`, FP 2; Figma `1160-24389` (L1–L3) |
| R5 | Álbum, raridade e idioma são escolhidos entre os cadastrados: álbuns ativos, `rarities` e `languages` | Regra | `23`, FP 2; DBML `albums.status`, `rarities`, `languages`; CCD064, R5 |
| R6 | "Foto da frente da carta" é obrigatória e "Foto do verso" é "Opcional"; os arquivos são JPG, PNG ou WEBP | Campo | `23`, FP 2; ADR-050, item 1; Figma `1160-24389` (L4, L12) |
| R7 | "Enviar solicitação" grava em `catalog_requests` uma solicitação `type` = `CARD`, `status` = `PENDING`, com o cliente em `requester_id` e os dados e as URLs das imagens em `data`, para a análise do administrador (CCD064) | Ação | `23`, FP 3–4; DBML `catalog_requests`; CCD064, R5 e L8 |
| R8 | Depois do envio, a tela mostra "Solicitação enviada", "A equipe da CromoCard vai analisar o pedido e avisar você pela notificação.", o resumo da carta, o status "Em análise", "1 Foto Anexada (Frente)", "Solicitar Outra Carta", "Acompanhar Solicitações (<n>)" e "Ficou com dúvida? Central de ajuda" | Tela | `23`, FP 4; Figma `1160-24932` (L6) |
| R9 | "Solicitar Outra Carta" abre o formulário vazio | Ação | Figma `1160-24932` |
| R10 | Sem um campo obrigatório, a tela indica os campos pendentes, mantém o formulário aberto com o que já foi preenchido, e a API responde `400 VALIDATION_ERROR` | Mensagem | `23`, FA 1–2; ADR-011 (L1, L10) |
| R11 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `1160-28449`, `1160-24389`, `1160-24932`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R4–R8) — **Dado** o formulário preenchido com nome, número, álbum, franquia, raridade, idioma e a foto da
  frente, **quando** o cliente seleciona "Enviar solicitação", **então** a API responde `201`, grava a solicitação `CARD`
  `PENDING` com o cliente em `requester_id`, e a tela mostra "Solicitação enviada" com o status "Em análise".
- **CA2** (R6, R10) — **Dado** o formulário completo sem a foto da frente, **quando** o cliente envia, **então** a tela
  indica a foto da frente como pendente, o formulário continua aberto com os dados e nada é gravado.
- **CA3** (R10) — **Dado** o formulário sem um dos campos obrigatórios decididos na L1, **quando** o cliente envia,
  **então** a tela indica o campo pendente e a API responde `400 VALIDATION_ERROR`.
- **CA4** (R6) — **Dado** o formulário completo sem a foto do verso, **quando** o cliente envia, **então** a solicitação é
  gravada.
- **CA5** (R6) — **Dado** um arquivo PDF ou maior que o limite da L4, **quando** o cliente tenta anexá-lo, **então** a tela
  recusa o arquivo com a mensagem do tipo ou do tamanho, e a API responde `400` ou `413`.
- **CA6** (R9) — **Dado** a confirmação na tela, **quando** o cliente seleciona "Solicitar Outra Carta", **então** vê o
  formulário vazio.
- **CA7** (R2) — **Dado** o modal "Adicionar carta" aberto, **quando** o cliente seleciona "Solicitar cadastro da carta →",
  **então** a página do formulário abre.
- **CA8** (R1) — **Dado** um visitante sem login, **quando** chama a rota de solicitar carta, **então** recebe `401`.
- **CA9** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-28449`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no bloco "Não encontrou a carta? Solicitar cadastro da carta →"; e em 375, 768 e 1024 px o
  mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA10** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-24389`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem
  horizontal.
- **CA11** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-24932`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem
  horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `catalog_requests` | `requester_id`, `type` (`catalog_request_type`: `CARD`), `data`, `status` (`request_status`: `PENDING`) | `data` `jsonb` obrigatório; `status` default `PENDING`; sem `deleted_at` (ADR-015, item 4) |
| `albums` | `id`, `title`, `category_id`, `status` (`album_status`: `ACTIVE`) | lista de álbuns; franquia do álbum na L3 |
| `categories` | `id`, `name`, `deleted_at` | opções de franquia (L3) |
| `rarities` | `id`, `name`, `sort_order` | opções de raridade |
| `languages` | `id`, `name`, `code` | opções de idioma |
| `cards` | `release_year` | só se a L2 aceitar "Ano de lançamento" (a coluna é da CCD106) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - adicionar carta (link de solicitar) | [1160-28449](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-28449) | R2 | ⚠️ Texto e lugar do link diferem do `23`, FP 1 (L8) |
| Álbuns - solicitar carta | [1160-24389](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-24389) | R3–R6, R10 | ❌ Não bate: "Ano de lançamento", prévia, lista de solicitações e prazo de 24h só no Figma (L2, L5–L7); limite de 15 MB contra 4 MB do ADR-050 (L4) |
| Álbuns - solicitação enviada | [1160-24932](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-24932) | R8, R9 | ⚠️ "Acompanhar Solicitações" e "Análise em até 24h úteis" só no Figma (L6, L7) |

- O fundo borrado do frame `1160-24932` traz textos antigos ("Solicitar Nova Carta ao Catálogo", "livro de ofertas do
  vault") que não entram na tela: o fundo é o formulário de `1160-24389` (`escopo-adicional.md`, seção 3, "vault").
- **Diferenças com o Figma** (decisão em Lacunas e decisões): formulário — "JPG, PNG ou WEBP até 15 MB"; o ADR-050 limita
  a 4 MB (L4). Franquia em botões fixos ("Futebol / Esportes", "Pokémon TCG", "Anime & Mangá", "Yu-Gi-Oh!", "Magic / TCGs
  Diversos"), independente do álbum escolhido (L3). Ponto de entrada no modal, não "na tela de busca", e o texto "Solicitar
  cadastro da carta" no lugar de "Solicitar Cadastro de Carta" (L8).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Ano de lançamento" (L2); "Prévia no catálogo",
  com preço (L5); "Minhas solicitações", "Ver todas", "Minhas Solicitações Anteriores" e "Acompanhar Solicitações (<n>)"
  (L6); "ANÁLISE EM ATÉ 24H ÚTEIS" (L7); textos de ajuda "Dica", "Conforme estampado no papel", "Dados que aparecem
  impressos na carta", "Fotos reais aceleram o processo de checagem do comitê de catalogação", "Pronto para conferência" e
  "Dúvidas no cadastro? Ver ajuda" (L9).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R10 o estado de erro com os campos pendentes (L10).

## Fora do escopo

- Analisar, aprovar ou recusar a solicitação e notificar o cliente — CCD064.
- Votar na sugestão — CCD103 (só categorias).
- "+ Não encontrou o Álbum? Sugerir Álbum" — CCD010 (Solicitar Álbum).
- "Ficou com dúvida? Central de ajuda" e "Ver ajuda" levam à Central de ajuda — CCD005.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Quais campos são obrigatórios? O FP 2 só diz que a frente é obrigatória e o verso opcional; o Figma marca a seção 01 como "OBRIGATÓRIO"; a CCD064 (L8) exige franquia, raridade, idioma e frente para publicar. (proposta: nome, número, álbum, franquia, raridade, idioma e frente) E uma carta avulsa, sem álbum, pode ser solicitada? | pendente | — |
| L2 | "Ano de lançamento" só existe no Figma (o DBML já tem `cards.release_year`, da CCD106): faz sentido implementar? | pendente | — |
| L3 | O álbum já tem franquia (`albums.category_id`), e o ADR-063 (Proposto, ainda fora da `development`) diz que a carta com álbum tem a franquia do álbum. Escolher o álbum preenche a franquia? As opções vêm das categorias cadastradas em vez dos botões fixos do Figma? | pendente | — |
| L4 | Limite das fotos: o Figma diz "até 15 MB"; o ADR-050 limita o upload a 4 MB. Qual vale? E o `POST /api/v1/uploads` da fundação é só para `ADMIN`: o cliente usa a mesma rota com outra permissão ou manda as imagens junto da solicitação? | pendente | — |
| L5 | "Prévia no catálogo" só existe no Figma, e mostra preço ("R$ 850,00") de uma carta que ainda não está no catálogo: faz sentido implementar? Sem o preço? | pendente | — |
| L6 | "Minhas solicitações" (com status "Aprovado" e "Em análise" e "Ver todas"), "Minhas Solicitações Anteriores" e "Acompanhar Solicitações (<n>)" só existem no Figma, e nenhum caso de uso lista as solicitações do cliente: faz sentido implementar? Que tela "Ver todas" abre? | pendente | — |
| L7 | "ANÁLISE EM ATÉ 24H ÚTEIS" promete um prazo que nenhuma regra da documentação garante: manter o texto? | pendente | — |
| L8 | O FP 1 põe a opção "na tela de busca" e a chama de "Solicitar Cadastro de Carta"; o Figma a põe no modal "Adicionar carta" como "Solicitar cadastro da carta →", e a busca sem resultados (`1112-4356`) não tem o link. Onde ela aparece e com que texto? | pendente | — |
| L9 | Os textos de ajuda do formulário só existem no Figma ("Dica", "Conforme estampado no papel" etc.): manter como estão? | pendente | — |
| L10 | O Figma não desenha o erro de campo obrigatório (FA 2): mensagem por campo, texto e lugar | pendente | — |
| L11 | Bloquear solicitação de carta que já está no catálogo ou que o cliente já pediu? (proposta: não bloquear; o admin recusa na CCD064) | pendente | — |
| L12 | Que tela abre "Alterar Foto" e o que faz "Procurar Arquivo"/arrastar a foto? (proposta: o seletor de arquivos do sistema, com arrastar e soltar na área da foto) | pendente | — |
| L13 | "Cliente" são os papéis `CUSTOMER` e `SELLER`? E o `ADMIN`? (proposta: `CUSTOMER` e `SELLER`; `ADMIN` recebe `403`, como na CCD103, L8) | pendente | — |
