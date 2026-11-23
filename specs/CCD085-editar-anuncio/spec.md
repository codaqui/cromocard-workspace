# CCD085 — Editar Anúncio

- **Status:** Rascunho
- **Fase:** MVP (sem marca nas user stories do Painel Vendedor)
- **User story:** #344 `CCD085-Editar Anúncio`
- **Agrupa:** CCD086 Excluir Anúncio (#345), CCD087 Pausar Anúncio (#346), CCD088 Reativar Anúncio (#347)
- **Caso de uso:** [85-editar-anuncio.md](../../docs/Casos-De-Uso/85-editar-anuncio.md) · [86-excluir-anuncio.md](../../docs/Casos-De-Uso/86-excluir-anuncio.md) · [87-pausar-anuncio.md](../../docs/Casos-De-Uso/87-pausar-anuncio.md) · [88-reativar-anuncio.md](../../docs/Casos-De-Uso/88-reativar-anuncio.md)
- **Atores:** Vendedor · **Pré-condições:** autenticado como `SELLER`, com anúncio ativo ou pausado (editar e excluir), ativo (pausar) ou pausado (reativar)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Vendedor preciso editar meus anúncios para manter suas informações atualizadas.
>
> Como Vendedor preciso excluir um anúncio para retirar uma carta definitivamente do marketplace.
>
> Como Vendedor preciso pausar um anúncio para interromper temporariamente sua disponibilidade para venda.
>
> Como Vendedor preciso reativar um anúncio para disponibilizar novamente uma carta para venda.

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
| R1 | Só o `SELLER` dono do anúncio edita, exclui, pausa ou reativa: `401` sem token, `403` para outro papel, `404` para anúncio de outro vendedor ou excluído | Permissão | `85`–`88`, Atores e Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Lista "Meus Anúncios" com os anúncios ativos e pausados do vendedor; cada um tem "Editar" e "Excluir", os ativos têm "Pausar" e os pausados, "Reativar" | Tela | `85`, FP 1; `86`, FP 1; `87`, FP 1; `88`, FP 1; DBML `listings.status` |
| R3 | "Editar" abre o formulário com os dados atuais do anúncio: condição, preço, quantidade disponível, descrição e fotos | Tela | `85`, FP 1–2; DBML `listings`, `listing_photos` |
| R4 | Salvar grava as alterações e confirma a edição; o marketplace passa a mostrar os dados novos | Ação | `85`, FP 3–4 |
| R5 | Campo obrigatório em branco impede salvar e pede o preenchimento do campo; preço zerado ou negativo mostra "Por favor, insira um valor válido maior que zero" | Regra | `85`, FA 1–2; `84`, FA 1–2 (mesma regra do anúncio) |
| R6 | No formulário de edição, a taxa de 5% e o valor líquido por unidade acompanham o preço, como na criação | Tela | `84`, FP 4; ADR-066, item 4 |
| R7 | "Excluir" abre uma caixa de diálogo que pede a confirmação da exclusão definitiva | Tela | `86`, FP 1–2 |
| R8 | Confirmar a exclusão tira o anúncio do marketplace e do painel do vendedor (soft delete) | Ação | `86`, FP 3–4; ADR-015 |
| R9 | "Cancelar" no diálogo fecha o aviso e mantém o anúncio inalterado | Ação | `86`, FA 1–2 |
| R10 | "Pausar" muda o status do anúncio ativo para pausado (`PAUSED`) | Ação | `87`, FP 1–2; DBML `listing_status` |
| R11 | Anúncio pausado sai na hora das buscas e listagens públicas do marketplace | Regra | `87`, FP 3 |
| R12 | Anúncio com negociação em andamento (pedido aguardando pagamento, com a carta reservada) não pode ser pausado: o sistema alerta e a API responde `422` | Regra | `87`, FA 1; `72`, FP 6 (reserva de 30 minutos) |
| R13 | "Reativar" muda o status do anúncio pausado para ativo (`ACTIVE`) e o recoloca nas buscas do marketplace | Ação | `88`, FP 1–3 |
| R14 | Com restrição na conta do vendedor, a reativação é impedida com uma notificação de erro | Regra | `88`, FA 1; DBML `users.status`, `users.suspended_until` |
| R15 | Só anúncio ativo é pausado e só anúncio pausado é reativado; editar e excluir valem para ativo ou pausado. Fora disso a API responde `422` | Regra | `85`–`88`, Pré-condições; ADR-011 |
| R16 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `675-1452`, `675-4218`, `675-2112`, `675-2808`, `675-3522`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2) — **Dado** um vendedor com 2 anúncios ativos, 1 pausado e 1 excluído, **quando** abre "Meus anúncios", **então** vê os 3 não excluídos, com "Editar", "Pausar" e "Excluir" nos ativos e "Editar", "Reativar" e "Excluir" no pausado.
- **CA2** (R3, R4, R6) — **Dado** um anúncio ativo de R$ 1.850,00, **quando** o vendedor seleciona "Editar", muda o preço para 1.790,00 e salva, **então** o formulário veio com os dados atuais, mostrou a taxa (R$ 89,50) e o líquido (R$ 1.700,50), a API grava o preço novo, a tela confirma a edição e o anúncio mostra R$ 1.790,00 no marketplace.
- **CA3** (R5) — **Dado** o formulário de edição, **quando** o vendedor apaga o preço e salva, **então** a tela pede o preenchimento do campo e nada é gravado; com preço 0, vê "Por favor, insira um valor válido maior que zero"; chamando a API direto, ela responde `400`.
- **CA4** (R7, R8) — **Dado** um anúncio pausado, **quando** o vendedor seleciona "Excluir" e confirma no diálogo, **então** o anúncio some de "Meus anúncios" e do marketplace e fica com `deleted_at` preenchido.
- **CA5** (R9) — **Dado** o diálogo de exclusão aberto, **quando** o vendedor seleciona "Cancelar", **então** o diálogo fecha e o anúncio continua igual, com o mesmo status.
- **CA6** (R10, R11) — **Dado** um anúncio ativo visível no marketplace, **quando** o vendedor o pausa, **então** o status passa a "Pausado" na lista e o anúncio some das buscas e listagens públicas na hora.
- **CA7** (R12) — **Dado** um anúncio com um pedido aguardando pagamento, **quando** o vendedor tenta pausá-lo, **então** vê o alerta de que o anúncio não pode ser pausado no momento, o status continua ativo e a API responde `422`.
- **CA8** (R13) — **Dado** um anúncio pausado, **quando** o vendedor seleciona "Reativar", **então** o status passa a "Ativo" e o anúncio volta às buscas do marketplace.
- **CA9** (R14) — **Dado** um vendedor com restrição na conta (L12), **quando** tenta reativar um anúncio pausado, **então** vê a notificação de erro, o anúncio continua pausado e a API recusa.
- **CA10** (R15) — **Dado** um anúncio pausado, **quando** a API recebe o pedido de pausar, **então** responde `422`; **dado** um anúncio ativo, **quando** recebe o de reativar, **então** responde `422`.
- **CA11** (R1) — **Dado** um visitante sem login, **quando** chama qualquer das ações, **então** recebe `401`; **dado** um `CUSTOMER`, recebe `403`; **dado** outro vendedor, **quando** tenta editar o anúncio que não é dele, recebe `404`.
- **CA12** (R2) — **Dado** um vendedor sem anúncios, **quando** abre "Meus anúncios", **então** vê o estado vazio (L11) com "Criar Novo Anúncio"; enquanto a lista carrega, vê o carregamento; se a API falhar, vê o erro com a opção de tentar de novo.
- **CA13** (R16) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-1452` (Meus anúncios), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA14** (R16) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-4218` (Editar anúncio), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA15** (R16) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-2112` (Excluir anúncio), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA16** (R16) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-2808` (Pausar anúncio), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA17** (R16) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-3522` (Reativar anúncio, depois da decisão da L6), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `listings` | `seller_id`, `card_id`, `condition_id`, `price`, `available_quantity`, `description`, `status` (`listing_status`: `ACTIVE`, `PAUSED`, `CLOSED`), `updated_at`, `deleted_at` | `price` decimal(10,2) obrigatório; `available_quantity` obrigatório, default 1; exclusão por `deleted_at` (ADR-015, L7) |
| `listing_photos` | `listing_id`, `url`, `sort_order`, `deleted_at` | até 4 fotos (`84`, FP 2) |
| `card_conditions` | `id`, `name` | Mint, Near Mint, Ótimo, Bom, Regular |
| `orders` | `listing_id`, `status` (`order_status`) | pedido `AWAITING_PAYMENT` bloqueia a pausa (R12, L16) |
| `users` | `role`, `status` (`user_status`), `suspended_until`, `stripe_account_status` | restrição de conta na reativação (R14, L12, L13) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel Vendedor - meus anúncios | [675-1452](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-1452) | R2 | ❌ Não bate (L1–L3) |
| Painel Vendedor - editar anúncio | [675-4218](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-4218) | R3–R6 | ❌ Não bate (L2, L8, L14, L15) |
| Painel Vendedor - excluir anúncio | [675-2112](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-2112) | R7–R9 | ❌ Não bate (L5) |
| Painel Vendedor - pausar anúncio | [675-2808](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-2808) | R10, R11 | ❌ Não bate (L4) |
| Painel Vendedor - reativar anúncio | [675-3522](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-3522) | R13 | ❌ Não bate (L6) |

- Meus anúncios: título "Meus Anúncios", subtítulo "Gerencie as cartas que você colocou à venda: edite, pause, reative ou
  exclua anúncios do marketplace.", colunas "Carta", "Condição", "Preço", "Estoque", "Visitas", "Status" e "Ações", selos
  "Ativo", "Pausado" e "Esgotado", botões "Editar", "Pausar", "Reativar", "Repor estoque" e "Excluir".
- Editar anúncio: "Editar Anúncio", "Atualize preço, fotos, estado e descrição. As alterações aparecem no marketplace na
  hora.", "Clique para trocar a foto", "✓ Foto atual mantida", "Descartar", "Salvar Alterações" e "Última edição: hoje às
  09:42 • 1.204 visitas".
- Excluir anúncio: "Excluir anúncio?", "Esta ação é permanente e não pode ser desfeita.", "Ao excluir este anúncio:",
  "•  A carta sai definitivamente do marketplace e da sua loja pública.", "•  O histórico de vendas já concluídas continua
  no seu painel.", "Motivo da exclusão (opcional)", "Entendo que esta ação não pode ser desfeita", "Cancelar" e "Excluir
  definitivamente".
- Pausar anúncio: "Pausar anúncio", "O anúncio sai do marketplace temporariamente. Você pode reativá-lo quando quiser.",
  "Motivo da pausa" com "Vou revisar preço ou fotos", "Carta reservada para outro comprador", "Estou viajando / sem envio no
  momento" e "Outro motivo", "Cancelar" e "Pausar anúncio".
- Reativar anúncio: o frame mostra só a lista desfocada, sem caixa de diálogo nem mensagem (L6).
- **Diferenças com o Figma** (decisão em Lacunas e decisões): Pausar — o Figma pede confirmação num modal com motivo; o caso
  de uso pausa direto pelo botão ou switch (L4). Fotos — o Figma desenha 2 espaços; o caso de uso da criação pede até 4
  (L15). Reativar — o frame não desenha nada além do fundo (L6).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): cartões "Anúncios ativos", "Pausados" e
  "Esgotados", abas com contagem, busca "Buscar por carta ou coleção...", ordenação "Mais recentes ▾", paginação "Mostrando
  4 de 103 anúncios", "Exportar CSV" e o selo "86 ativos • 14 pausados" (L1); coluna "Visitas" e "Última edição" (L2);
  status "Esgotado" e "Repor estoque" (L3); motivo da pausa (L4); motivo da exclusão e a caixa "Entendo que esta ação não
  pode ser desfeita" (L5); campo "Carta do catálogo" no editar (L8).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R4 a confirmação da edição; R5 o pedido de campo
  obrigatório; R12 o alerta de pausa bloqueada; R13 o retorno da reativação; R14 a notificação de erro da reativação; o
  estado vazio de "Meus anúncios" (L11).

## Fora do escopo

- Criar anúncio ("Criar Novo Anúncio" e "Criar Anúncio" do topo) — CCD084.
- Propostas recebidas — removidas do projeto em 22/11/2026 (CCD089, ADR-069).
- Visão geral, Pedidos e envios e Financeiro do menu do vendedor — CCD092, CCD093 e CCD109.
- Loja pública do vendedor citada no diálogo de exclusão — CCD080 e CCD091.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | A lista do Figma tem cartões de contagem ("+6 esta semana", "Fora do marketplace", "Sem estoque"), abas com contagem, busca, ordenação "Mais recentes", paginação, "Exportar CSV" e o selo "86 ativos • 14 pausados"; o caso de uso só diz "lista dos seus anúncios". Faz sentido implementar? (proposta: sim para cartões, abas, busca, ordenação e paginação; não para "Exportar CSV" e "+6 esta semana") | pendente | — |
| L2 | Coluna "Visitas" e "Última edição: … • 1.204 visitas" não têm coluna no DBML. Faz sentido implementar? (proposta: tirar as visitas; "Última edição" vem de `listings.updated_at`) | pendente | — |
| L3 | "Esgotado" não existe em `listing_status`, e "Repor estoque" não tem caso de uso. Faz sentido implementar? (proposta: "Esgotado" = `ACTIVE` com `available_quantity = 0`, calculado; "Repor estoque" abre o editar com a quantidade em foco) | pendente | — |
| L4 | Pausar: direto pelo botão (`87`, FP 1) ou num modal de confirmação com "Motivo da pausa" (Figma)? O motivo não tem coluna no DBML (proposta: modal de confirmação sem gravar o motivo, e o Gabriel tira o motivo do frame) | pendente | — |
| L5 | Excluir: o "Motivo da exclusão (opcional)" não tem coluna, e a caixa "Entendo que esta ação não pode ser desfeita" só existe no Figma. Faz sentido implementar? (proposta: a caixa habilita "Excluir definitivamente"; o motivo sai do frame) | pendente | — |
| L6 | Reativar: o frame `675-3522` mostra só o fundo desfocado. A reativação é direta (`88`, FP 1) ou tem confirmação? (proposta: direta, com aviso de sucesso no estilo da tela; o Gabriel ajusta ou tira o frame) | pendente | — |
| L7 | Excluir grava `deleted_at` (ADR-015) ou muda o status para `CLOSED`? E com pedido pago ainda não concluído? (proposta: `deleted_at`; bloquear com `422` se houver pedido `AWAITING_PAYMENT`, `PAID`, `SHIPPED` ou `DELIVERED`) | pendente | — |
| L8 | No editar, a carta do catálogo pode ser trocada? O Figma mostra o campo de busca; o caso de uso cita preço e descrição (proposta: a carta fica travada; para trocar, cria-se outro anúncio) | pendente | — |
| L9 | Quais campos são obrigatórios no editar (`85`, FA 1)? (proposta: condição, preço e quantidade; descrição e fotos opcionais) | pendente | — |
| L10 | Editar o preço com um pedido aguardando pagamento muda o valor desse pedido? (proposta: não; o pedido guarda `items_amount` e a edição vale para compras novas) | pendente | — |
| L11 | Textos sem frame: confirmação da edição, campo obrigatório, alerta de pausa bloqueada, erro da reativação, sucesso de exclusão, pausa e reativação, e o estado vazio da lista (propostas: "Anúncio atualizado", "Preencha este campo", "Este anúncio tem uma compra em andamento e não pode ser pausado agora", "Não foi possível reativar: sua conta está com restrição", "Anúncio excluído", "Anúncio pausado", "Anúncio reativado", "Você ainda não tem anúncios") | pendente | — |
| L12 | O que é "restrição na conta" (`88`, FA 1)? Conta `SUSPENDED` ou `BLOCKED` (CCD099) nem entra no sistema (proposta: suspensão com `suspended_until` vigente e conta Stripe que deixou de estar `READY`) | pendente | — |
| L13 | Reativar exige a conta Stripe pronta (ADR-066, item 5) e estoque maior que zero? (proposta: exige a conta pronta; com estoque 0, reativa e aparece como "Esgotado") | pendente | — |
| L14 | No editar, "Descartar", "Clique para trocar a foto" e "✓ Foto atual mantida" só existem no Figma. Faz sentido implementar? (proposta: sim; "Descartar" fecha sem salvar) | pendente | — |
| L15 | Fotos: o Figma desenha 2 espaços e o rótulo diz "até 4" (mesma lacuna da CCD084, L1) | pendente | — |
| L16 | "Negociação em andamento (carrinho/pagamento pendente)" = pedido `AWAITING_PAYMENT` do anúncio? E pedido `PAID`? (proposta: só `AWAITING_PAYMENT`, a reserva de 30 minutos da CCD072) | pendente | — |
