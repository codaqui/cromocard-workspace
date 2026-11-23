# CCD002 — Buscar Global

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #107 `CCD002-Buscar Global`
- **Caso de uso:** [02-buscar-global.md](../../docs/Casos-De-Uso/02-buscar-global.md) · complemento: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md) (EA-002-01)
- **Atores:** Visitante (o cliente logado usa a mesma busca) · **Pré-condições:** estar na Home ou com a barra de busca visível
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como visitante eu quero buscar cartas, usuários e grupos diretamente no painel público.

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
| R1 | A busca e a página do álbum do catálogo funcionam sem login, e a API responde sem token. O cliente logado usa a mesma busca, com o menu da Área do Cliente (item "Pesquisar") | Permissão | `02`, Atores; EA-001-01 |
| R2 | Barra de busca global no topo de todas as telas públicas, com o texto de exemplo "Buscar cartas, álbuns, usuários e grupos"; selecioná-la habilita a digitação | Campo | `02`, FP 1–2 |
| R3 | Submeter o termo abre a página de resultados com o termo no título | Ação | `02`, FP 3 |
| R4 | O sistema valida o termo antes de consultar (regra: L1) | Regra | `02`, FP 4 (L1) |
| R5 | Página de resultados com o rótulo "BUSCA", o título "Resultados para “<termo>”" e o resumo "<n> cartas, <n> usuários, <n> grupos e <n> álbuns" | Tela | `02`, FP 5 |
| R6 | Abas "Tudo (<n>)", "Cartas (<n>)", "Usuários (<n>)", "Grupos (<n>)" e "Álbuns (<n>)": "Tudo" mostra todos os grupos; cada uma das outras mostra só o seu | Tela | `02`, FP 5 |
| R7 | Grupo "Cartas" com os anúncios ativos cuja carta corresponde ao termo: imagem, "<categoria> • <coleção>", nome da carta, condição, "Preço", preço e @vendedor; "Ver todas →" abre a aba Cartas | Tela | `02`, FP 5 |
| R8 | Selecionar uma carta do resultado abre o perfil da carta (CCD030) | Ação | `02`, FP 5 |
| R9 | Grupo "Usuários" com iniciais (ou avatar), nome de usuário, "<n> vendas" e "Ver perfil", que abre o perfil público do usuário (CCD080); "Ver todos →" abre a aba Usuários | Tela | `02`, FP 5; EA-080-01 |
| R10 | Grupos com nome, "<n> membros", o selo "PÚBLICO" (`access_type = OPEN`) ou "REQUER APROVAÇÃO" (`CLOSED`) e o botão "Entrar no grupo" ou "Solicitar entrada" | Tela | `02`, FP 5; DBML `groups.access_type` |
| R11 | Álbuns com "Álbum <título>", "<categoria> • <n> cartas", o selo "ÁLBUM OFICIAL" e "Ver álbum", que abre a página pública do álbum | Tela | `02`, FP 5; EA-002-01 |
| R12 | Página pública do álbum do catálogo: trilha "Início / Busca / <álbum>", rótulo "ÁLBUM OFICIAL • <categoria>", capa, título, descrição, "Cartas", "Lançamento" e "Categoria", os botões "Adicionar à minha coleção" e "Favoritar" e "Cartas do álbum (<n>)" com Nº, imagem, nome e "Ver carta" em cada carta | Tela | EA-002-01 |
| R13 | "Ver carta" abre o perfil da carta (CCD030) | Ação | EA-002-01 |
| R14 | Para o visitante, "Adicionar à minha coleção" e "Favoritar" pedem login: abrem "Entre para continuar" com "Continuar com Google", "Entrar com e-mail e senha" e "Criar conta grátis" | Regra | EA-002-01; `30`, FA 1–2 |
| R15 | Sem nenhum resultado, a página mostra "0 resultados" e "Nenhum resultado encontrado para o termo pesquisado" | Mensagem | `02`, FA 1 |
| R16 | Só entram cartas `ACTIVE` não excluídas, anúncios `ACTIVE` não excluídos e registros sem `deleted_at` | Regra | ADR-053, item 5; ADR-015; DBML `listings.status` |
| R17 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R5, R6, R7, R9–R11) — **Dado** anúncios, usuários, grupos e álbuns que correspondem a "charizard",
  **quando** o visitante digita "charizard" na barra do topo e confirma, **então** abre "Resultados para “charizard”" com o
  resumo, as abas com as contagens e os grupos de cartas, usuários, grupos e álbuns.
- **CA2** (R6) — **Dado** os resultados abertos em "Tudo", **quando** o visitante seleciona "Usuários (<n>)", **então** só os
  usuários aparecem; "Ver todos →" do grupo Usuários leva à mesma aba.
- **CA3** (R8) — **Dado** os resultados, **quando** o visitante seleciona uma carta, **então** abre o perfil daquela carta.
- **CA4** (R9) — **Dado** os resultados, **quando** o visitante seleciona "Ver perfil" de um usuário, **então** abre o perfil
  público dele.
- **CA5** (R11–R13) — **Dado** um álbum no resultado, **quando** o visitante seleciona "Ver álbum", **então** abre a página do
  álbum com capa, dados e a lista de cartas; **quando** seleciona "Ver carta", **então** abre o perfil da carta.
- **CA6** (R14) — **Dado** um visitante na página do álbum, **quando** seleciona "Favoritar" ou "Adicionar à minha coleção",
  **então** abre "Entre para continuar" e nada é gravado.
- **CA7** (R15) — **Dado** um termo sem correspondência, **quando** o visitante busca, **então** vê "0 resultados" e
  "Nenhum resultado encontrado para o termo pesquisado".
- **CA8** (R1) — **Dado** uma requisição sem token, **quando** o frontend chama a busca, **então** a API responde `200`;
  **dado** um cliente logado, **então** a mesma página aparece com o menu da Área do Cliente e "Pesquisar" destacado.
- **CA9** (R4) — **Dado** um termo que não passa na validação da L1, **quando** o visitante tenta buscar, **então** a busca
  não é enviada (ou a API responde `400 VALIDATION_ERROR`) e a tela explica o motivo.
- **CA10** (R16) — **Dado** um anúncio pausado e uma carta em rascunho com o termo no nome, **quando** o visitante busca,
  **então** nenhum dos dois aparece.
- **CA11** (R10) — **Dado** um grupo fechado no resultado, **quando** a página abre, **então** ele mostra "REQUER APROVAÇÃO" e
  "Solicitar entrada"; um grupo aberto mostra "PÚBLICO" e "Entrar no grupo".
- **CA12** (R17 de Fidelidade) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o
  print dela é comparado lado a lado com o print do frame `1112-3970`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem
  rolagem horizontal.
- **CA13** (R17 de Fidelidade) — Idem ao CA12, com o estado sem resultados e o frame `1112-4356`.
- **CA14** (R17 de Fidelidade) — Idem ao CA12, com o modal "Entre para continuar" sobre os resultados e o frame `1160-2457`
  (depende da L6).
- **CA15** (R17 de Fidelidade) — Idem ao CA12, com a página do álbum do catálogo e o frame `1160-1845`.

- **CA16** (R17) — **Dado** cada tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame correspondente (`1112-4356`, `1160-2457`, `1160-1845`), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `listings` | `card_id`, `seller_id`, `condition_id`, `price`, `status` (`ACTIVE`), `deleted_at` | grupo Cartas |
| `listing_photos` | `url`, `sort_order` | imagem do anúncio (L13) |
| `cards` | `name`, `number`, `front_image_url`, `album_id`, `category_id`, `status` (`ACTIVE`), `deleted_at` | busca e página do álbum |
| `albums` | `title`, `description`, `cover_url`, `total_cards`, `year`, `category_id`, `status` (`album_status`), `deleted_at` | grupo Álbuns e página do álbum |
| `categories` | `name`, `parent_category_id` | rótulos |
| `card_conditions` | `name` | condição do anúncio |
| `users` | `username`, `role`, `status`, `deleted_at` | grupo Usuários (L3) |
| `profiles` | `avatar_url` | avatar; sem foto, as iniciais |
| `orders` | `seller_id`, `status` | "<n> vendas" (L4) |
| `groups` | `name`, `access_type` (`group_access_type`), `status` (`group_status`), `deleted_at` | grupo Grupos (L5) |
| `group_members` | `group_id` | "<n> membros" |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Busca | [1112-3970](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-3970) | R2, R3, R5–R11 | ⚠️ Difere: grupos e álbuns numa seção só (L12) |
| Público - Busca - sem resultados | [1112-4356](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-4356) | R15 | ⚠️ Difere: texto de apoio só no Figma (L7) |
| Público - Busca - entre para continuar | [1160-2457](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-2457) | — | ❌ Só no Figma (L6) |
| Público - Álbum do catálogo | [1160-1845](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-1845) | R12–R14 | ⚠️ Difere: busca no álbum e "Carregar mais cartas" só no Figma (L9) |

- O frame de referência "Referência - Pesquisar" (`1122-18396`) diz que o cliente logado usa a mesma busca, com o menu do
  cliente e o topo com notificações e perfil (o topo e o menu do cliente seguem `1122-17812`).
- **Diferenças com o Figma** (decisão em Lacunas e decisões): Busca — o `02`, FP 5, agrupa em Cartas, Usuários, Grupos e
  Álbuns; o frame junta "Grupos e álbuns" numa seção (L12).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Entre para continuar" ao entrar num grupo
  (L6); "Confira a grafia ou busque pelo nome da coleção." no vazio (L7); "Buscar carta no álbum" e "Carregar mais cartas"
  na página do álbum (L9).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R6 a aba de um grupo só (ex.: "Cartas") aberta
  (L10); R4 o aviso de termo inválido (L1); R14 o modal "Entre para continuar" sobre a página do álbum (o desenho do modal
  está em `1160-2457` e `1112-5461`).

## Fora do escopo

- Entrar no grupo ou solicitar entrada (cliente logado) — CCD039.
- Perfil público do usuário — CCD080 (EA-080-01).
- Perfil da carta — CCD030.
- "Adicionar à minha coleção" e "Favoritar" para o cliente logado — Minha Coleção (CCD008/CCD022) e CCD055.
- Login e cadastro a partir de "Entre para continuar" — CCD004 e CCD003.
- Explorar marketplace com filtros e ordenação — CCD078 e CCD068.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Que validação o termo recebe (`02`, FP 4)? Tamanho mínimo e máximo, termo só com espaços? (proposta: de 2 a 100 caracteres sem contar os espaços das pontas; vazio não envia) | pendente | — |
| L2 | Quais campos cada grupo pesquisa e como compara? (proposta: cartas por `cards.name` dos anúncios ativos; usuários por `username`; grupos por `name`; álbuns por `title`; sem diferenciar maiúsculas e acentos, por trecho) | pendente | — |
| L3 | Quais usuários aparecem? O Figma mostra vendedores com "<n> vendas". Entram colecionadores sem vendas, `ADMIN`, suspensos e bloqueados? (proposta: `CUSTOMER` e `SELLER` com `status = ACTIVE`; "<n> vendas" só para `SELLER`) | pendente | — |
| L4 | O que conta em "<n> vendas"? Mesma pergunta da L3 da CCD001 (status `DELIVERED` ou `COMPLETED`). (proposta: pedidos `COMPLETED` do vendedor) | pendente | — |
| L5 | Grupos suspensos (`group_status.SUSPENDED`) aparecem na busca? (proposta: só `ACTIVE` e `WARNED`) | pendente | — |
| L6 | O Figma (`1160-2457`) mostra "Entre para continuar" com "Faça login para entrar no grupo. É rápido e grátis." quando o visitante seleciona "Entrar no grupo"; o `02` não fala disso. Faz sentido implementar? (proposta: sim, o mesmo modal do `30`, FA 2; depois do login, volta à busca) | pendente | — |
| L7 | O vazio do Figma tem o texto de apoio "Confira a grafia ou busque pelo nome da coleção.", que o `02`, FA 1, não traz. Faz sentido implementar? | pendente | — |
| L8 | O que significa o selo "ÁLBUM OFICIAL"? Todo álbum do catálogo é oficial? Álbum `INACTIVE` aparece? (proposta: todo álbum `ACTIVE` mostra o selo; `INACTIVE` não aparece) | pendente | — |
| L9 | Na página do álbum, "Buscar carta no álbum" e "Carregar mais cartas" só existem no Figma (o EA-002-01 fala só da lista). Faz sentido implementar? (proposta: sim; busca por nome ou número e 8 cartas por vez, como no Explorar) | pendente | — |
| L10 | A aba de um grupo só (ex.: "Cartas (842)") não tem desenho: quantos itens e como carrega mais? (proposta: o mesmo cartão, com "Carregar mais" de 8 em 8) | pendente | — |
| L11 | Quantos itens cada grupo mostra na aba "Tudo"? O Figma mostra 4 cartas, 2 usuários, 2 grupos e 2 álbuns. (proposta: como o Figma) | pendente | — |
| L12 | O `02`, FP 5, separa Grupos e Álbuns; o Figma junta os dois na seção "Grupos e álbuns" (as abas continuam separadas). Qual vale? | pendente | — |
| L13 | Imagem e categoria do cartão do anúncio: mesma pergunta da CCD001 (L7 e L8). Decidir uma vez para CCD001, CCD002 e CCD078 | pendente | — |
| L14 | O que abre o item "Pesquisar" do menu, sem termo? Não há frame nem passo. (proposta: a página "BUSCA" com o campo do topo em foco e sem resultados) | pendente | — |
| L15 | Estados de carregando e de erro não estão na documentação nem no Figma. (proposta: o padrão da Área do Cliente) | pendente | — |
