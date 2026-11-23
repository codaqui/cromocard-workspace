# CCD083 — Denunciar Vendedor

- **Status:** Rascunho
- **Fase:** MVP (era Futuro Marketplace; puxada para o MVP em 22/11/2026 com as telas já no Figma, ADR-069)
- **User story:** #1440 `CCD083 - Denunciar Vendedor` (criada em 22/11/2026)
- **Caso de uso:** [83-denunciar-vendedor.md](../../docs/Casos-De-Uso/83-denunciar-vendedor.md) · complemento: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md), EA-080-01 (o perfil público do vendedor)
- **Atores:** Cliente · **Pré-condições:** o cliente está autenticado e no perfil público do vendedor
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso denunciar um vendedor que tenha uma irregularidade dentro da plataforma.

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

> **Fase MVP** desde 22/11/2026: as telas já estão no Figma, e o Daniel puxou a story para o MVP (ADR-069).

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Denunciar exige login: sem token, a API responde `401` | Permissão | `83-denunciar-vendedor.md`, Atores e Pré-condições; ADR-011 |
| R2 | O perfil público do vendedor tem a opção de denunciar ("Denunciar Vendedor" no caso de uso; "⚑ Denunciar perfil" no Figma, L2) | Ação | `83`, FP 1; EA-080-01; Figma `1160-1396` |
| R3 | A opção abre o modal "Denunciar @<nome de usuário>", que pede a escolha de um motivo para a infração, numa lista de opções | Tela | `83`, FP 2; Figma `1160-17495` |
| R4 | O motivo é obrigatório | Regra | `83`, FP 2–3; DBML `reports.reason` (obrigatório) |
| R5 | O cliente descreve a situação num campo de texto ("Detalhes (opcional)" no Figma, L4) | Campo | `83`, FP 3; DBML `reports.description` (até 500 caracteres); Figma `1160-17495` |
| R6 | Ao enviar ("Enviar denúncia"), o sistema grava a denúncia em `reports` com `target_type = SELLER`, o `target_user_id` do vendedor, o `reporter_id` do cliente, o motivo, a descrição e `status = PENDING` | Ação | `83`, FP 4; DBML `reports`; ADR-032 |
| R7 | A denúncia fica disponível no painel de moderação | Regra | `83`, FP 4 (L6) |
| R8 | Depois de gravar, a tela avisa o cliente do sucesso | Mensagem | `83`, FP 4 |
| R9 | Fechar o modal ("✕") ou clicar em "Cancelar" aborta a denúncia sem enviar nenhum dado | Ação | `83`, FA 1–2; Figma `1160-17495` |
| R10 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1160-1396`, `1160-17495`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R5, R6, R8) — **Dado** um cliente logado no perfil público de um vendedor, **quando** ele clica em
  "⚑ Denunciar perfil", escolhe "Tentativa de golpe", escreve os detalhes e clica em "Enviar denúncia", **então** a API
  responde `201`, `reports` ganha uma linha com `target_type = SELLER`, o `target_user_id` do vendedor, o `reporter_id`
  dele e `status = PENDING`, o modal fecha e a tela avisa o sucesso.
- **CA2** (R9) — **Dado** o modal aberto com um motivo escolhido, **quando** o cliente clica em "Cancelar" ou no "✕",
  **então** o modal fecha, nenhuma requisição de denúncia é feita e `reports` não muda.
- **CA3** (R4) — **Dado** o modal aberto, **quando** o cliente clica em "Enviar denúncia" sem escolher o motivo, **então**
  nada é enviado e o modal continua aberto; chamada direta à API sem `reason` responde `400` e não grava nada.
- **CA4** (R1) — **Dado** um visitante sem login, **quando** a API recebe a denúncia, **então** responde `401` e não grava nada.
- **CA5** (R6) — **Dado** um usuário inexistente ou excluído, **quando** o cliente tenta denunciá-lo pela API, **então** a
  API responde `404` e não grava nada.
- **CA6** (R7) — **Dado** a denúncia gravada no CA1, **quando** o administrador abre o painel de moderação definido pela L6,
  **então** vê a denúncia com o vendedor, o motivo, a descrição, quem denunciou e quando.
- **CA7** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-1396` (Perfil público do usuário), **então** não há diferença de
  layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem
  quebra, corte nem rolagem horizontal.
- **CA8** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-17495` (Perfil público - denunciar perfil), **então** não há diferença
  de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta
  sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `reports` | `reporter_id`, `target_user_id`, `target_type` (`report_target_type`: `SELLER`; ver L1), `reason`, `description`, `status` (`report_status`: `PENDING`), `created_at` | `reporter_id`, `target_type` e `reason` (até 90) obrigatórios; `description` opcional (até 500); `status` default `PENDING`. Alvo polimórfico: só `target_user_id` preenchido (ADR-032) |
| `users` | `id`, `username`, `role`, `deleted_at` | O vendedor denunciado tem de existir |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Perfil público do usuário | [1160-1396](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-1396) | R2, R10 | ❌ Não bate (rótulo "⚑ Denunciar perfil", L2) |
| Público - Perfil público - denunciar perfil | [1160-17495](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-17495) | R3–R6, R9, R10 | ❌ Não bate (descrição opcional, motivos, aviso de sigilo, topo de visitante: L3–L5, L7) |

- Textos do modal `1160-17495`: título "Denunciar @tiago_trocas"; subtítulo "A denúncia é sigilosa: a pessoa não sabe quem
  denunciou. A moderação analisa em até 24 horas."; motivos "Perfil falso ou bot", "Tentativa de golpe", "Conteúdo
  ofensivo no perfil" e "Outro motivo"; campo "Detalhes (opcional)"; botões "Cancelar" e "Enviar denúncia"; "✕".
- **Diferenças com o Figma** (decisão em Lacunas e decisões): Perfil público — o botão é "⚑ Denunciar perfil"; o caso de
  uso pede "Denunciar Vendedor" (L2). Modal — "Detalhes (opcional)"; o caso de uso pede que o cliente "descreve a
  situação" (L4). Modal — o topo mostra "Entrar" e "Criar conta grátis", como se o visitante pudesse denunciar; o caso de
  uso exige login (L7).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): Modal — a lista de motivos (L3) e o aviso
  "A denúncia é sigilosa: a pessoa não sabe quem denunciou. A moderação analisa em até 24 horas." (L5).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R4 o erro sem motivo; R8 o aviso de sucesso.

## Fora do escopo

- Tratar a denúncia no BackOffice (fila, dispensar, sancionar) — não há caso de uso para denúncias de vendedor (L6); a
  CCD099 aplica sanções.
- Os dados do perfil público (nome, cidade, vendas, anúncios, conquistas) — CCD080 (EA-080-01).
- Denunciar anúncio — CCD082; denunciar usuário pelo vendedor — CCD090; denunciar contato no chat — CCD047.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O modal `1160-17495` serve a três casos de uso parecidos: CCD050 Denunciar Perfil (Cliente, alvo `PROFILE`, sem marca), CCD083 Denunciar Vendedor (alvo `SELLER`, `***`) e CCD090 Denunciar Usuário (Vendedor, alvo `USER`). Um fluxo só ou três? Qual `target_type` grava a denúncia feita no perfil público de um vendedor? E, se for um fluxo só, qual fase vale? (proposta: um fluxo só, o da CCD050, com `target_type = SELLER` quando o denunciado for vendedor e `PROFILE` nos demais) | pendente | — |
| L2 | O caso de uso pede a opção "Denunciar Vendedor"; o Figma mostra "⚑ Denunciar perfil". Qual texto vale? | pendente | — |
| L3 | Os motivos do Figma ("Perfil falso ou bot", "Tentativa de golpe", "Conteúdo ofensivo no perfil", "Outro motivo") não estão no caso de uso. Fazem sentido para denunciar um vendedor? E "Outro motivo" exige descrição? | pendente | — |
| L4 | A descrição é obrigatória? O FP 3 diz que o cliente "descreve a situação"; o Figma usa "Detalhes (opcional)" e `reports.description` é opcional (proposta: opcional, como no Figma) | pendente | — |
| L5 | Aviso de sigilo e prazo ("a pessoa não sabe quem denunciou", "analisa em até 24 horas"): só no Figma. Faz sentido implementar? O prazo de 24 horas vira regra de negócio? | pendente | — |
| L6 | O FP 4 diz que a ocorrência vai para o "painel de moderação", mas o BackOffice só tem a fila de mensagens de grupo (CCD062). Onde o administrador vê as denúncias de vendedor? | pendente | — |
| L7 | O frame `1160-17495` mostra o modal com o topo de visitante ("Entrar", "Criar conta grátis"); o caso de uso exige login. O visitante que clica em "⚑ Denunciar perfil" vê "Entre para continuar"? | pendente | — |
| L8 | O cliente pode denunciar a si mesmo ou denunciar o mesmo vendedor de novo com uma denúncia ainda aberta? (proposta: a opção não aparece no próprio perfil; denúncia repetida `PENDING` ou `UNDER_REVIEW` responde `409`) | pendente | — |
| L9 | Textos do aviso de sucesso e do erro sem motivo não estão na documentação nem no Figma | pendente | — |
