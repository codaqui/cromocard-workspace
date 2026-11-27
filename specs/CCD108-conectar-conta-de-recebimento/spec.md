# CCD108 — Conectar Conta de Recebimento

- **Status:** Em implementação
- **Fase:** MVP (fatia mínima do marketplace desde 18/11/2026: legenda de `user-stories.md` e ADR-027)
- **User story:** #920 `CCD108-Conectar Conta de Recebimento`
- **Caso de uso:** [108-conectar-conta-de-recebimento.md](../../docs/Casos-De-Uso/108-conectar-conta-de-recebimento.md)
- **Atores:** Vendedor · **Pré-condições:** autenticado como `SELLER`
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-11-25, Felipe Consulim (PO), na revisão do backend codaqui/cromocard-backend#45: L1–L5 e L7 validadas como estão, e a L6 revista (ADR-071)

## Objetivo

> Como Vendedor preciso conectar minha conta de recebimento na Stripe para receber o valor das minhas vendas.

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
| R1 | Só `SELLER` conecta a conta de recebimento, e só a própria: `401` sem token, `403` para outro papel | Permissão | `108`, Atores e Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Sem a conta pronta, o Painel do vendedor mostra o aviso "Conecte sua conta de recebimento para vender", a ajuda "O cadastro é feito na própria Stripe e leva poucos minutos. Sem a conta pronta, não é possível publicar anúncios." e o botão "Conectar conta Stripe"; "Criar Novo Anúncio" e "Criar Anúncio" ficam desabilitados | Tela | `108`, FP 1–2 (L1, L2) |
| R3 | "Conectar conta Stripe" cria a conta conectada Express do vendedor na Stripe, se ainda não existir, guarda o id dela e leva o vendedor ao cadastro na página da Stripe | Ação | `108`, FP 3–4; ADR-066, itens 4 e 8; DBML `users.stripe_account_id` (único) |
| R4 | Na volta da Stripe, o sistema consulta a conta e grava o estado; enquanto ela analisa o cadastro, o painel mostra "Estamos verificando sua conta na Stripe", o selo "Verificando" e a ajuda "Você poderá publicar anúncios assim que a Stripe liberar a conta. Isso costuma levar poucos minutos." | Estado | `108`, FP 5–6 (L1, L5); DBML `users.stripe_account_status` (`VERIFYING`) |
| R5 | Quando a Stripe avisa que a conta pode receber transferências (evento `account.updated`), o sistema marca a conta como pronta (`READY`), tira o aviso e libera a criação de anúncios | Regra | `108`, FP 7; ADR-066, itens 5 e 6 |
| R6 | O webhook da Stripe só é aceito com a assinatura conferida pelo segredo do webhook; o `account.updated` reconsulta a conta na Stripe e grava o estado atual, então um evento repetido ou fora de ordem não muda o resultado | Regra | ADR-066, item 6; ADR-071 |
| R7 | Se o vendedor sai do cadastro da Stripe sem terminar, o painel mostra "Termine seu cadastro na Stripe para vender" e o botão "Continuar cadastro" retoma o cadastro de onde parou, na mesma conta conectada | Ação | `108`, FA 1–2 (L4); ADR-066, item 4 |
| R8 | Se a Stripe pede mais informações ou recusa a conta, o painel mostra "A Stripe precisa de mais informações" com o botão "Completar cadastro", e os anúncios continuam bloqueados | Estado | `108`, FA 3 (L3, L4); `84`, FA 3–4 |
| R9 | A Stripe fica atrás do `PaymentProvider`, com uma implementação falsa para os testes | Regra | ADR-066, item 9; ADR-009 |
| R11 | Se a Stripe suspende as transferências de uma conta `READY`, o estado volta a `PENDING`, o aviso volta e só criar e reativar anúncio ficam bloqueados; os anúncios ativos continuam ativos | Regra | `108`, FA 4 (L7) |
| R12 | O Painel do vendedor tem "Ver Loja Pública" ao lado de "Criar Novo Anúncio", que leva à loja pública do próprio vendedor (CCD080); até a CCD080 existir, a rota mostra a página em construção | Tela | Figma (frames `1112-9866`, `1112-10347`) (L8) |
| R10 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `1112-9866`, `1112-10347`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2) — **Dado** um vendedor sem conta conectada, **quando** abre o Painel do vendedor, **então** vê "Conecte sua conta de recebimento para vender" e "Conectar conta Stripe".
- **CA2** (R3) — **Dado** um vendedor sem `stripe_account_id`, **quando** seleciona "Conectar conta Stripe", **então** a API cria a conta conectada Express (no provider falso, nos testes), grava o id em `users.stripe_account_id` e devolve o link de cadastro, e o navegador vai para a página da Stripe.
- **CA3** (R4) — **Dado** o vendedor de volta da Stripe com o cadastro enviado e a conta ainda sem transferências liberadas, **quando** o painel abre, **então** mostra "Estamos verificando sua conta na Stripe" com o selo "Verificando".
- **CA4** (R5) — **Dado** uma conta em verificação, **quando** chega um `account.updated` válido com transferências liberadas, **então** `stripe_account_status` passa a `READY`, o painel não mostra mais o aviso e "Criar Novo Anúncio" funciona.
- **CA5** (R6) — **Dado** um `account.updated` com assinatura inválida, **quando** chega ao webhook, **então** a API responde `400` e nada muda; **dado** o mesmo evento válido recebido duas vezes, ou um evento antigo que chega depois de um novo, **então** o estado gravado é o atual da conta na Stripe.
- **CA6** (R7) — **Dado** um vendedor que saiu do cadastro da Stripe sem terminar, **quando** volta ao painel e seleciona o botão do aviso, **então** vai para o cadastro da mesma conta conectada (sem criar outra) e retoma de onde parou.
- **CA7** (R8) — **Dado** uma conta em que a Stripe pediu mais informações, **quando** o vendedor abre o painel, **então** vê o aviso com o botão para completar o cadastro, e a criação de anúncio continua recusada (`422`).
- **CA8** (R1) — **Dado** um visitante sem login, **quando** chama a conexão, **então** recebe `401`; **dado** um `CUSTOMER` ou `ADMIN`, recebe `403`.
- **CA9** (R3) — **Dado** a Stripe fora do ar, **quando** o vendedor seleciona "Conectar conta Stripe", **então** vê uma mensagem de erro, continua no painel e pode tentar de novo; o botão mostra o carregamento enquanto espera.
- **CA12** (R11) — **Dado** uma conta `READY` com um anúncio ativo, **quando** chega um `account.updated` com as transferências suspensas, **então** o estado passa a `PENDING`, o painel volta a mostrar o aviso, o anúncio continua `ACTIVE` e `assertReady` lança `422`.
- **CA13** (R12) — **Dado** um vendedor no Painel do vendedor, **quando** seleciona "Ver Loja Pública", **então** vai para a loja pública dele (`/vendedor/loja`), em construção até a CCD080.
- **CA10** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-9866` (conectar conta de recebimento), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA11** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-10347` (conta em verificação), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `role`, `stripe_account_id`, `stripe_account_status` | `stripe_account_id` varchar(60) único (conta Express); `stripe_account_status` do enum `stripe_account_status` (`PENDING`, `VERIFYING`, `READY`); estados a mais dependem da L3 |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel Vendedor - conectar conta de recebimento | [1112-9866](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-9866) | R2, R3, R7, R12 | ✅ Bate (salvo L1, L2, L8) |
| Painel Vendedor - conta de recebimento em verificação | [1112-10347](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-10347) | R4, R12 | ✅ Bate (salvo L8) |

- Conectar: aviso "Conecte sua conta de recebimento para vender", ajuda "O cadastro é feito na própria Stripe e leva poucos
  minutos. Sem a conta pronta, não é possível publicar anúncios." e o botão "Conectar conta Stripe"; "Criar Novo Anúncio" e
  "Criar Anúncio" do topo aparecem desabilitados (L2 e CCD084, L7).
- Verificação: "Estamos verificando sua conta na Stripe", selo "Verificando" e "Você poderá publicar anúncios assim que a
  Stripe liberar a conta. Isso costuma levar poucos minutos."
- **Só no Figma**, decidido implementar: ajuda abaixo do aviso nos dois frames (L1) e "Ver Loja Pública" no topo da Visão
  geral (L8).
- **Só no Figma**, decidido não implementar: "Exportar Fiscal/CSV" e "• Sincronizado há 2 min" no topo dos dois frames (L8).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R7 "Termine seu cadastro na Stripe para vender" com
  "Continuar cadastro"; R8 "A Stripe precisa de mais informações" com "Completar cadastro" (L4); o erro ao falar com a Stripe.

## Fora do escopo

- Métricas zeradas da Visão geral e a mensagem do gráfico — CCD092 e CCD093.
- O aviso "Conecte sua conta de recebimento antes de anunciar" ao criar anúncio — CCD084.
- Transferir o valor das vendas para a conta conectada — CCD110 e CCD111.
- Saque via Pix e dados bancários no CromoCard — fora do MVP (`escopo-adicional.md`, 20/11/2026).
- "Exportar Fiscal/CSV" e "• Sincronizado há 2 min" do topo dos frames `1112-9866` e `1112-10347` — o painel lê a API na hora (L8).
- A loja pública do vendedor — CCD080 (aqui só o botão "Ver Loja Pública" e a rota em construção, L8).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | As ajudas "O cadastro é feito na própria Stripe e leva poucos minutos. Sem a conta pronta, não é possível publicar anúncios." e "Você poderá publicar anúncios assim que a Stripe liberar a conta. Isso costuma levar poucos minutos." só existem no Figma. Faz sentido implementar? (proposta: sim, são explicação do FP 2 e do FP 6) | Sim, como no Figma: as duas ajudas entram no aviso. Decisão de Daniel Andrade em 24/11/2026 | `108`, FP 2 e 6; R2, R4 |
| L2 | Sem a conta pronta, "Criar Novo Anúncio" fica desabilitado (Figma) ou abre o aviso da CCD084 (FA 3–4)? (mesma pergunta da CCD084, L7) | Desabilitado, como no Figma: os dois botões ficam desabilitados até `READY`; a API recusa com `422 STRIPE_ACCOUNT_NOT_READY`. Decisão de Daniel Andrade em 24/11/2026 | `108`, FP 2; `84`, FA 3–4; CCD084, L7 |
| L3 | `stripe_account_status` tem `PENDING`, `VERIFYING` e `READY`. Como representar "a Stripe pediu mais informações" e "conta recusada" (FA 3)? E quem não clicou ainda fica nulo ou `PENDING`? (proposta: nulo = sem conta; `PENDING` = cadastro não terminado, pedido de informação ou recusa; `VERIFYING` = cadastro enviado em análise; `READY` = transferências liberadas) | A proposta, sem enum novo: nulo = sem conta; `PENDING` = cadastro não terminado, pedido de informação ou recusa; `VERIFYING` = em análise; `READY` = transferências liberadas. O motivo da pendência é lido na Stripe. Decisão de Daniel Andrade em 24/11/2026 | R8; plano.md, Dados e Regras |
| L4 | Textos do cadastro não terminado e do pedido de informação ou recusa, sem frame (proposta: "Termine seu cadastro na Stripe para vender" com "Continuar cadastro"; "A Stripe precisa de mais informações" com "Completar cadastro") | Os da proposta: "Termine seu cadastro na Stripe para vender" com "Continuar cadastro"; "A Stripe precisa de mais informações" com "Completar cadastro". Decisão de Daniel Andrade em 24/11/2026 | `108`, FA 2–3; R7, R8 |
| L5 | Como o sistema sabe que o vendedor voltou da Stripe e que está em verificação? (proposta: a volta (`return_url`) consulta a conta na Stripe e grava `VERIFYING` se os dados foram enviados; o link vencido (`refresh_url`) gera outro link) | A volta (`return_url`) chama o refresh, que consulta a conta e grava `VERIFYING` ou `PENDING`; o link vencido (`refresh_url`) gera outro link. O `account.updated` marca `READY`. Decisão de Daniel Andrade em 24/11/2026 | `108`, FP 6; R4; plano.md, Regras |
| L6 | A idempotência por id do evento (ADR-066, item 6) precisa guardar os ids processados, e o DBML não tem tabela para isso. (proposta: o `account.updated` é idempotente por natureza, porque só grava o estado atual; sem tabela nova) | Revista pelo PO: o `account.updated` só dispara a reconsulta da conta na Stripe (`getConnectedAccount`), e o estado gravado é o atual; sem tabela nova, e o id do evento vai para o log. Decisão do PO (Felipe Consulim) em 25/11/2026, na revisão do backend #45, no lugar da proposta de Daniel Andrade de 24/11/2026 (gravar o estado que veio no evento) | R6, CA5; plano.md, Regras e Decisões técnicas; ADR-071 |
| L7 | Se a Stripe tira a permissão de transferência de uma conta já pronta, os anúncios ativos são pausados? (proposta: não; o status volta a `PENDING`, o aviso volta e só a criação e a reativação ficam bloqueadas) | Não pausa os ativos: o estado volta a `PENDING`, o aviso volta e só criar e reativar ficam bloqueados. Decisão de Daniel Andrade em 24/11/2026 | `108`, FA 4; R11, CA12 |
| L8 | O topo dos frames `1112-9866` e `1112-10347` tem "Exportar Fiscal/CSV", "• Sincronizado há 2 min" e "Ver Loja Pública", que a documentação não traz. Faz sentido implementar? | "Exportar Fiscal/CSV" e "Sincronizado": não (fora do escopo; o painel lê a API na hora). "Ver Loja Pública": sim, ao lado de "Criar Novo Anúncio", levando à loja pública do vendedor (CCD080), em construção até lá. Decisão do PO (Felipe, 25/11/2026), na revisão do frontend codaqui/cromocard-frontend#34 | `108`, FP 2; R12, CA13; Fora do escopo |
