# CCD090 — Denunciar Usuário

- **Status:** Rascunho
- **Fase:** MVP pela legenda (a user story, no Painel Vendedor, não tem marca); o ADR-027 tira do MVP as denúncias do marketplace: ver L1
- **User story:** #349 `CCD090-Denunciar Usuario`
- **Caso de uso:** [90-denunciar-usuario.md](../../docs/Casos-De-Uso/90-denunciar-usuario.md)
- **Atores:** Vendedor · **Pré-condições:** o vendedor acessa o perfil ou o chat do usuário comprador
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Vendedor preciso denunciar usuários para informar comportamentos inadequados à plataforma.

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
| R1 | Denunciar exige login como vendedor: sem token, `401`; papel diferente de `SELLER`, `403` (ver L3) | Permissão | `90-denunciar-usuario.md`, Atores; ADR-011 |
| R2 | A conversa com o comprador e o perfil dele têm a opção "Denunciar" | Ação | `90`, FP 1; Figma `1160-34298`, `1160-1396` |
| R3 | A opção pede a categoria da denúncia, numa lista de opções (ex.: spam, linguagem ofensiva) | Campo | `90`, FP 2; DBML `reports.reason` (obrigatório, até 90 caracteres) |
| R4 | O vendedor detalha o comportamento num campo de observação obrigatório | Campo | `90`, FP 3 e FA 1; DBML `reports.description` (até 500 caracteres) |
| R5 | Ao enviar, o sistema grava a denúncia em `reports` com `target_type = USER`, o `target_user_id` do comprador, o `reporter_id` do vendedor, a categoria, a observação e `status = PENDING` | Ação | `90`, FP 4; DBML `reports`; ADR-032 |
| R6 | Depois de gravar, a tela informa que a moderação vai analisar o caso | Mensagem | `90`, FP 4 |
| R7 | Sem a observação, o envio é bloqueado e a tela alerta pedindo uma breve explicação do ocorrido; a API, se chamada, responde `400` | Regra | `90`, FA 1–2; ADR-011 |
| R8 | Sem a categoria, o envio é bloqueado; a API, se chamada, responde `400` | Regra | `90`, FP 2; DBML `reports.reason` (obrigatório); ADR-011 |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1160-34298`, `1160-1396`, `1160-17495`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R6) — **Dado** um vendedor logado na conversa com um comprador, **quando** ele abre "Bloquear ou denunciar
  @<usuário>", escolhe "Somente denunciar", a categoria "Spam", escreve o que aconteceu e envia, **então** a API responde
  `201`, `reports` ganha uma linha com `target_type = USER`, o `target_user_id` do comprador, o `reporter_id` dele e
  `status = PENDING`, e a tela informa que a moderação vai analisar o caso.
- **CA2** (R2–R6) — **Dado** o vendedor no perfil público do comprador, **quando** ele clica em "⚑ Denunciar perfil",
  escolhe o motivo, escreve os detalhes e clica em "Enviar denúncia", **então** a denúncia é gravada como no CA1.
- **CA3** (R7) — **Dado** o formulário com a categoria escolhida e a observação vazia, **quando** o vendedor envia, **então**
  nada é enviado e a tela alerta pedindo uma breve explicação; chamada direta à API sem `description` responde `400` e não
  grava nada.
- **CA4** (R8) — **Dado** o formulário sem categoria, **quando** o vendedor envia, **então** nada é enviado; chamada direta à
  API sem `reason` responde `400`.
- **CA5** (R1) — **Dado** um visitante sem login, **quando** a API recebe a denúncia, **então** responde `401`; **dado** um
  `CUSTOMER`, **então** responde `403` (enquanto a L3 não mudar o ator).
- **CA6** (R5) — **Dado** um usuário inexistente ou excluído, **quando** o vendedor tenta denunciá-lo pela API, **então** a
  API responde `404` e não grava nada.
- **CA7** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-34298` (Mensagens - bloquear ou denunciar), **então** não há diferença
  de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta
  sem quebra, corte nem rolagem horizontal.
- **CA8** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-1396` (Perfil público do usuário), **então** não há diferença de
  layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem
  quebra, corte nem rolagem horizontal.
- **CA9** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-17495` (Perfil público - denunciar perfil), **então** não há diferença
  de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta
  sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `reports` | `reporter_id`, `target_user_id`, `target_type` (`report_target_type`: `USER`; ver L2), `reason`, `description`, `status` (`report_status`: `PENDING`), `created_at` | `reporter_id`, `target_type` e `reason` (até 90) obrigatórios; `description` é opcional no DBML, mas obrigatória por esta story (R4); `status` default `PENDING`. Alvo polimórfico: só `target_user_id` preenchido (ADR-032). Não há coluna para anexar mensagens do chat (L6) |
| `users` | `id`, `username`, `role`, `deleted_at` | O denunciado tem de existir |
| `conversations`, `conversation_participants` | `id`, `listing_id` | Abrir a denúncia pela conversa (R2) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Mensagens - bloquear ou denunciar | [1160-34298](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-34298) | R2–R5, R9 | ❌ Não bate (categorias, observação sem marca de obrigatória, anexar mensagens, tela do cliente: L3–L6) |
| Público - Perfil público do usuário | [1160-1396](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-1396) | R2, R9 | ❌ Não bate (rótulo "⚑ Denunciar perfil"; o caso de uso pede "Denunciar", L2) |
| Público - Perfil público - denunciar perfil | [1160-17495](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-17495) | R3–R5, R9 | ❌ Não bate ("Detalhes (opcional)"; o caso de uso exige a observação, L4) |

- Textos do modal da conversa `1160-34298`: "Bloquear ou denunciar @marcos_tcg", "Escolha o que fazer com este contato.",
  "O que você quer fazer?", "Somente bloquear" ("Ele não poderá mais te enviar mensagens"), "Bloquear e denunciar" ("A
  moderação analisa a conversa em até 24h"), "Somente denunciar" ("A conversa continua aberta"), "Motivo da denúncia"
  ("Golpe / pagamento externo", "Assédio", "Spam", "Perfil falso"), "Conte o que aconteceu", "Anexar as últimas 20
  mensagens" ("Ajuda a moderação a entender o contexto"), "Você pode desbloquear em Configurações.", "Cancelar" e
  "Bloquear e denunciar".
- Textos do modal do perfil `1160-17495`: "Denunciar @tiago_trocas", "A denúncia é sigilosa: a pessoa não sabe quem
  denunciou. A moderação analisa em até 24 horas.", "Perfil falso ou bot", "Tentativa de golpe", "Conteúdo ofensivo no
  perfil", "Outro motivo", "Detalhes (opcional)", "Cancelar" e "Enviar denúncia".
- **Diferenças com o Figma** (decisão em Lacunas e decisões): os dois modais — as categorias não são as do caso de uso
  ("spam, linguagem ofensiva") e diferem entre si (L5); o perfil marca os detalhes como "(opcional)" e a conversa não marca
  "Conte o que aconteceu" como obrigatório, mas o caso de uso exige a observação (L4); os dois frames estão na visão do
  cliente (Gabriel, sem o grupo "Vendedor" no menu, e o visitante no perfil), não do vendedor (L3).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): conversa — "Anexar as últimas 20 mensagens"
  (L6); os dois modais — o prazo de 24 horas e o aviso de sigilo (L7).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R6 a confirmação de envio; R7 o alerta sem
  observação; R8 o erro sem categoria.

## Fora do escopo

- Bloquear o contato ("Somente bloquear", a parte de bloqueio de "Bloquear e denunciar") — CCD047 (Moderar Contatos Privados).
- Tratar a denúncia no BackOffice — não há caso de uso para denúncias de usuário (L8); a CCD099 aplica sanções.
- Denunciar pela proposta — escopo adicional fora do MVP (`escopo-adicional.md`, seção 3); propostas são a CCD089.
- Os dados do perfil público — CCD080.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Fase: a user story não tem marca (MVP pela legenda), mas o ADR-027 tira do MVP as "denúncias do marketplace", e o `escopo-adicional.md` tira "denunciar usuário pela proposta". A denúncia pela conversa e pelo perfil entra no MVP? | pendente | — |
| L2 | A CCD090 (alvo `USER`) se sobrepõe à CCD047 (bloquear ou denunciar no chat), à CCD050 (Denunciar Perfil, alvo `PROFILE`) e à CCD083 (Denunciar Vendedor, alvo `SELLER`), que usam os mesmos modais. Um fluxo só ou separados? Qual `target_type` vale em cada caminho? (proposta: um fluxo só por caminho — o modal da conversa grava `USER` e o do perfil, `PROFILE` ou `SELLER` —, e a CCD090 só confirma que o vendedor também denuncia) | pendente | — |
| L3 | Só o vendedor denuncia? O caso de uso diz Vendedor e "comprador", mas os frames estão na visão do cliente, e a CCD047 e a CCD050 dão a mesma opção ao cliente. Abrir para `CUSTOMER` e `SELLER` e para qualquer usuário, não só comprador? (proposta: sim; `ADMIN` não denuncia) | pendente | — |
| L4 | A observação é obrigatória (FP 3, FA 1), mas o modal do perfil diz "Detalhes (opcional)" e o da conversa não marca "Conte o que aconteceu" como obrigatório. Qual vale? E o texto do alerta? | pendente | — |
| L5 | Quais são as categorias? O caso de uso dá "spam, linguagem ofensiva"; a conversa usa "Golpe / pagamento externo", "Assédio", "Spam", "Perfil falso"; o perfil usa "Perfil falso ou bot", "Tentativa de golpe", "Conteúdo ofensivo no perfil", "Outro motivo" | pendente | — |
| L6 | "Anexar as últimas 20 mensagens" (só no Figma): faz sentido implementar? `reports` não tem coluna para a conversa nem para mensagens do chat pessoal (só `group_message_id`); seria mudança no DER e ADR | pendente | — |
| L7 | Prazo "em até 24h" e aviso de sigilo (só no Figma): fazem sentido? O prazo vira regra de negócio? | pendente | — |
| L8 | Quem trata a denúncia de usuário? O BackOffice só tem a fila de mensagens de grupo (CCD062) | pendente | — |
| L9 | Denúncia repetida do mesmo usuário com outra ainda aberta e denunciar a si mesmo (proposta: `409` e `422`) | pendente | — |
| L10 | Texto da confirmação: o FP 4 diz que a tela "informa que a moderação irá analisar o caso", sem o texto exato e sem frame | pendente | — |
