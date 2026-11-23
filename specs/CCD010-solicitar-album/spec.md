# CCD010 — Solicitar Álbum

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #116 `CCD010-Solicitar Álbum`
- **Caso de uso:** [10-buscar-album.md](../../docs/Casos-De-Uso/10-buscar-album.md) (o arquivo tem o título "Buscar Álbum", mas o conteúdo é Solicitar Álbum: L2)
- **Atores:** Cliente · **Pré-condições:** autenticado, preenchendo o formulário de solicitações na área de biblioteca (Álbuns)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso solicitar o cadastro de um novo álbum para expandir as opções da plataforma.

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
| R1 | Solicitar exige login: sem token, a API responde `401` | Permissão | `10`, Pré-condições; ADR-005, item 4; ADR-011 (papel `ADMIN`: L1) |
| R2 | A área de biblioteca (Álbuns) tem a opção "Solicitar cadastro de álbum", que abre o formulário de solicitação (rótulo: L14) | Ação | `10`, FP 1 e Pré-condições |
| R3 | O formulário pede Título, Editora/Ano e uma descrição opcional (campos do Figma: L4) | Campo | `10`, FP 2 |
| R4 | Título e Editora/Ano são obrigatórios: sem eles, o envio não acontece e o campo avisa (texto: L11) | Regra | `10`, FP 3 |
| R5 | Ao confirmar, a API grava a solicitação em `catalog_requests` com `type = ALBUM`, `status = PENDING`, `requester_id` = o cliente e os dados sugeridos em `data` | Regra | `10`, FP 4; DBML `catalog_requests`; ADR-051, item 3 |
| R6 | A solicitação gravada entra na fila de Solicitações do BackOffice (CCD064), na aba de álbuns, para a análise do administrador | Regra | `10`, FP 4; `64`, FP 2 |
| R7 | Depois de gravar, a tela mostra um alerta de sucesso (desenho: L10) | Mensagem | `10`, FP 4 |
| R8 | Se a API falha ao gravar, a tela mostra a mensagem de erro da API | Estado | ADR-041, Erros |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1160-29609`, `1160-23080`, `1160-29088`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R5, R6, R7) — **Dado** um cliente em "Meus álbuns", **quando** ele abre a solicitação, preenche o título "Panini Brasileirão 2026", a editora e o ano e confirma, **então** a API responde `201`, grava uma linha em `catalog_requests` com `type = ALBUM`, `status = PENDING` e os dados em `data`, a tela mostra o alerta de sucesso e a solicitação aparece na fila do BackOffice.
- **CA2** (R3, R5) — **Dado** o formulário preenchido sem a descrição, **quando** o cliente confirma, **então** a solicitação é gravada normalmente.
- **CA3** (R4) — **Dado** o formulário sem o título, **quando** o cliente tenta enviar, **então** nada é gravado e o campo de título mostra o aviso de obrigatório; a API, chamada sem o título, responde `400 VALIDATION_ERROR`.
- **CA4** (R1) — **Dado** um visitante sem login, **quando** chama a API de solicitação, **então** recebe `401`.
- **CA5** (R8) — **Dado** a API fora do ar, **quando** o cliente envia o formulário, **então** vê a mensagem de erro e nenhuma solicitação é gravada.
- **CA6** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-29609`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA7** (R9) — **Dado** "Meus álbuns" aberto em 1280 px, **quando** o print é comparado lado a lado com o frame `1160-23080`, **então** o botão "Solicitar álbum" do topo e o bloco "Não encontrou a coleção que você coleciona?" com o botão "Solicitar álbum" não têm diferença; e em 375, 768 e 1024 px se adaptam sem quebra, corte nem rolagem horizontal.
- **CA8** (R9) — **Dado** "Meus álbuns" sem álbuns aberto em 1280 px, **quando** o print é comparado lado a lado com o frame `1160-29088`, **então** os botões "Solicitar álbum" do topo e do estado vazio não têm diferença; e em 375, 768 e 1024 px se adaptam sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `catalog_requests` | `requester_id`, `type` (`catalog_request_type`: `ALBUM`), `data`, `status` (`request_status`: `PENDING`), `created_at` | `type` e `data` (`jsonb`) obrigatórios; `status` default `PENDING`; sem `deleted_at` (ADR-015, item 4); o que vai em `data`: ADR-051, item 3 (L4) |
| `categories` | `name`, `is_default`, `display_order` | só se a franquia entrar no formulário (L4, L5) |
| `languages` | `name`, `code` | só se o idioma entrar no formulário (L4) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - solicitar álbum | [1160-29609](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-29609) | R3, R4, R9 | ❌ Não bate: campos diferentes do caso de uso (L4) e blocos só no Figma (L6–L9) |
| Álbuns - Meus álbuns (botões de entrada) | [1160-23080](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23080) | R2, R9 | ❌ Não bate: rótulo "Solicitar álbum" (L14) |
| Álbuns - sem álbuns (botões de entrada) | [1160-29088](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-29088) | R2, R9 | ❌ Não bate: rótulo "Solicitar álbum" (L14) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Solicitar álbum — o formulário tem "Nome do álbum" ("Conforme estampado no papel"), "Total de cartas", "Ano de lançamento", "Editora ou fabricante" (lista), "Categoria / Franquia da Coleção" (opções "Futebol / Esportes", "Pokémon TCG", "Anime & Mangá", "Yu-Gi-Oh!", "Magic / TCGs Diversos"), "Link de referência (opcional)" e "Idioma do álbum"; o caso de uso pede Título, Editora/Ano e descrição opcional, que o Figma não tem (L4).
  - Entrada — o botão se chama "Solicitar álbum"; o caso de uso chama a opção de "Solicitar cadastro de álbum" (L14).
  - Sucesso — o único frame de sucesso, "Álbuns - solicitação enviada" (`1160-24932`), é da solicitação de carta (CCD023): mostra "Solicitação enviada", "Solicitar Outra Carta" e "Acompanhar Solicitações (3)" (L10).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões):
  - Solicitar álbum — bloco "02 Foto da capa (opcional)", com a dica "Use luz difusa e enquadre a capa reta, sem reflexo de flash.", "Imagem anexada (1,8 MB)", "Pronto para conferência" e "Alterar Foto" (L6).
  - Solicitar álbum — "Prévia no catálogo" ("Veja como o álbum vai aparecer no catálogo depois de aprovado.") (L7).
  - Solicitar álbum — "Minhas solicitações" com status ("Aprovado", "Em análise") e "Ver todas", e o botão "Minhas Solicitações Anteriores" com a contagem (L8).
  - Solicitar álbum — selo "ANÁLISE EM ATÉ 24H ÚTEIS" (L9).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R3 descrição opcional (L4).
  - R4 aviso de campo obrigatório (L11).
  - R7 alerta de sucesso da solicitação de álbum (L10).
  - R8 mensagem de erro ao enviar.

## Fora do escopo

- Analisar, aprovar ou recusar a solicitação e avisar o solicitante — CCD064.
- Votar em sugestões — CCD103 (só categorias).
- Solicitar o cadastro de uma carta — CCD023.
- "Dúvidas no cadastro? Ver ajuda" — Central de ajuda (CCD005).
- "Voltar aos álbuns" e o caminho "Início > Álbuns > Solicitar Cadastro > Novo Álbum" — navegação comum da Área do Cliente.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O `ADMIN` solicita álbum pelo Painel Cliente? (proposta: não; `CUSTOMER` e `SELLER` solicitam, o `ADMIN` recebe `403`, porque ele cadastra direto na CCD061) | pendente | — |
| L2 | O arquivo `10-buscar-album.md` tem o título "Buscar Álbum", mas o conteúdo é Solicitar Álbum (inconsistência conhecida do `CLAUDE.md`). Renomear o arquivo para `10-solicitar-album.md` e corrigir o título? (proposta: sim) | pendente | — |
| L3 | O FA 1 do caso de uso (sem álbuns, mensagem e botão para o Catálogo Global) é cópia da CCD008 e não trata a solicitação. Trocar por um fluxo de campos obrigatórios em branco? (proposta: sim, FA 1 = campo obrigatório vazio, como no R4) | pendente | — |
| L4 | Campos: o caso de uso pede Título, Editora/Ano (um campo só) e descrição opcional; o Figma pede nome, total de cartas, ano, editora, franquia, link de referência e idioma, sem descrição. Qual vale? Quais são obrigatórios? A CCD064 mostra ao admin "título, franquia, editora e ano", e o DBML de `albums` não tem idioma nem link. (proposta: os campos do Figma, gravados em `data` como `title`, `totalCards`, `year`, `publisher`, `categoryId`, `referenceUrl` e `languageCode`; obrigatórios nome, editora, ano e franquia; a descrição sai do caso de uso) | pendente | — |
| L5 | De onde vêm as opções de franquia e de editora? O DBML não tem tabela de editoras. (proposta: franquia = categorias padrão na ordem da CCD104; editora = texto livre com sugestões dos valores já usados em `albums.publisher`) | pendente | — |
| L6 | A foto da capa (opcional) só existe no Figma. Faz sentido? (proposta: sim, pelo upload do ADR-050 (PNG, JPG ou WEBP até 4 MB), com a URL em `data.coverUrl`, que a CCD103 já lê para a capa sugerida, R13) | pendente | — |
| L7 | A "Prévia no catálogo" só existe no Figma. Faz sentido? (proposta: sim, atualizada enquanto o cliente digita, com a foto, o nome, a editora e a franquia) | pendente | — |
| L8 | "Minhas solicitações" (lista com status e "Ver todas") e "Minhas Solicitações Anteriores (n)" só existem no Figma; nenhum caso de uso descreve acompanhar as próprias solicitações (a CCD023 também mostra "Acompanhar Solicitações"). Faz sentido? Qual tela abre "Ver todas"? (proposta: sim, as 3 últimas solicitações do cliente, com `PENDING` = "Em análise", `APPROVED` = "Aprovado" e `REJECTED` = "Recusado"; a página completa vira caso de uso novo, com desenho) | pendente | — |
| L9 | "ANÁLISE EM ATÉ 24H ÚTEIS" promete um prazo que a documentação não tem. Mantém? (proposta: sai do Figma, a menos que o PO confirme o prazo) | pendente | — |
| L10 | O caso de uso pede um alerta de sucesso, e o Figma só desenha o sucesso da carta (`1160-24932`). Como fica o sucesso do álbum? (proposta: o mesmo layout, com "Solicitação enviada", "A equipe da CromoCard vai analisar o pedido e avisar você pela notificação.", a prévia do álbum, "Solicitar outro álbum" e "Acompanhar solicitações (n)"; o Gabriel desenha) | pendente | — |
| L11 | Texto do aviso de campo obrigatório: nem o caso de uso nem o Figma dizem. (proposta: "Informe o <campo>." abaixo do campo, no estilo de "Criar conta - erros de validação", `1160-786`) | pendente | — |
| L12 | Álbum que já existe no catálogo ou solicitação igual já pendente do mesmo cliente: bloqueia? (proposta: não bloqueia; o admin recusa na CCD064) | pendente | — |
| L13 | A solicitação avisa o admin (notificação) ao ser criada? (proposta: não; ela só entra na fila da CCD064) | pendente | — |
| L14 | O caso de uso chama a opção de "Solicitar cadastro de álbum"; o Figma, de "Solicitar álbum" (botão e título da página). (proposta: como no Figma) | pendente | — |
