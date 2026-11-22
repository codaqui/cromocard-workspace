# CCD076 — Visualizar Anúncios Ativos

- **Status:** Rascunho
- **Fase:** Futuro Marketplace
- **User story:** não encontrada no board
- **Caso de uso:** [76-visualizar-anuncios-ativos.md](../../docs/Casos-De-Uso/76-visualizar-anuncios-ativos.md)
- **Atores:** Cliente · **Pré-condições:** autenticado, com acesso ao painel da plataforma
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar meus anúncios ativos para acompanhar os itens que estão atualmente disponíveis para venda.

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

> **Fase Futuro Marketplace** (`***` em `user-stories.md`): fica fora da fatia mínima do marketplace que entrou no MVP
> (ADR-027). A spec existe para quando o PO puxar a story (L4).

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só usuário autenticado vê a lista: `401` sem token | Permissão | `76`, Pré-condições; ADR-005 |
| R2 | No Dashboard, o cliente seleciona a seção "Anúncios Ativos" | Ação | `76`, FP 1–2 (L2) |
| R3 | O sistema busca os anúncios ativos do cliente: `listings` com `seller_id` = cliente, `status = ACTIVE` e `deleted_at` nulo | Regra | `76`, FP 3; user story ("meus anúncios ativos") (L1, L5) |
| R4 | O sistema exibe a lista dos anúncios encontrados | Tela | `76`, FP 4 (L5) |
| R5 | Sem anúncios ativos, a lista mostra "Não existem anúncios ativos no momento." | Mensagem | `76`, FA 1 |
| R6 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** um vendedor com 3 anúncios `ACTIVE`, 1 `PAUSED` e 1 excluído, **quando** ele abre a seção "Anúncios Ativos", **então** vê só os 3 ativos.
- **CA2** (R3) — **Dado** anúncios ativos de outros vendedores, **quando** o cliente abre a seção, **então** eles não aparecem.
- **CA3** (R5) — **Dado** um cliente sem anúncios ativos, **quando** abre a seção, **então** vê "Não existem anúncios ativos no momento."
- **CA4** (R1) — **Dado** uma chamada sem token, **quando** pede a lista, **então** recebe `401`.
- **CA5** (R4) — **Dado** a lista abrindo, **quando** a busca não respondeu ou falhou, **então** a tela mostra o carregamento ou um aviso de erro no estilo da tela, e não a mensagem de lista vazia.
- **CA6** (R6) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-1452`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA7** (R6) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `492-2007`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `listings` | `seller_id`, `card_id`, `condition_id`, `price`, `available_quantity`, `status` (`listing_status`: `ACTIVE`), `created_at`, `deleted_at` | `status` default `ACTIVE`; `available_quantity` default 1 (L5) |
| `cards`, `card_conditions` | `name`, `front_image_url`; `name` | linha da lista |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel Vendedor — meus anúncios (aba "Ativos" e cartão "Anúncios ativos") | [675-1452](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-1452) | R3, R4 | ⚠️ A lista existe como aba de "Meus Anúncios", não como seção do Dashboard (L2, L3) |
| Painel Vendedor — Visão geral (indicador "Anúncios Ativos") | [492-2007](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=492-2007) | R2 | ⚠️ Só o indicador, sem a lista (L2) |

- Textos de `675-1452`: "Meus Anúncios", "Anúncios ativos", "+6 esta semana", abas "Todos (103)", "Ativos (86)", "Pausados (14)", "Esgotados (3)", "Buscar por carta ou coleção...", "Mais recentes ▾", colunas "Carta", "Condição", "Preço", "Estoque", "Visitas", "Status", "Ações", "Mostrando 4 de 103 anúncios". Em `492-2007`: "Anúncios Ativos", "86 cartas", "14 pausados • 3 esgotados".
- **Diferenças com o Figma** (decisão em Lacunas e decisões): o caso de uso fala em seção "Anúncios Ativos" no Dashboard; o Figma tem a aba "Ativos" em "Meus Anúncios" e o indicador da Visão geral do vendedor (L2).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): busca, ordenação, paginação, "Visitas" e "+6 esta semana" (L5, L6).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R5 a lista vazia.

## Fora do escopo

- Criar, editar, excluir, pausar e reativar anúncio — CCD084 a CCD088.
- "Exportar CSV" de Meus Anúncios — não está na documentação.
- Indicadores da Visão geral (vendas, liberado, visualizações) — CCD092 e CCD093.
- Anúncios ativos no perfil público do vendedor — CCD080 (EA-080-01).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | De quem são os anúncios? A user story diz "meus anúncios ativos" (do próprio vendedor); a Finalidade do caso de uso fala em "cartas disponíveis para compra no marketplace" e o FP 3 em anúncios "relacionados ao cliente". O ator é Cliente, mas anunciar é do Vendedor | pendente | — |
| L2 | Onde fica a lista? O Início do cliente (`1122-17812`) não tem seção "Anúncios Ativos"; o Figma tem a aba "Ativos" de "Meus Anúncios" (`675-1452`) e o indicador da Visão geral do vendedor (`492-2007`) | pendente | — |
| L3 | A lista é a mesma tela de "Meus Anúncios" das CCD085–088? Se sim, a CCD076 vira só a aba "Ativos" e o cartão "Anúncios ativos" dela? | pendente | — |
| L4 | Fase: Futuro Marketplace, mas o ADR-027 pôs "criar o anúncio" na fatia mínima do MVP e "Meus Anúncios" está desenhado. Puxar para o MVP? | pendente | — |
| L5 | O que é "ativo": o anúncio `ACTIVE` com `available_quantity = 0` aparece no Figma como "Esgotado"; conta como ativo? Quais colunas a lista mostra? "Visitas" não tem coluna no DBML | pendente | — |
| L6 | Busca "Buscar por carta ou coleção...", ordenação "Mais recentes ▾", paginação e "+6 esta semana" (só no Figma). Faz sentido implementar nesta story? | pendente | — |
