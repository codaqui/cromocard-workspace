# CCD050 — Denunciar Perfil

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #1265 `CCD050 - Denunciar Perfil` (criada em 22/11/2026)
- **Caso de uso:** [50-denunciar-perfil.md](../../docs/Casos-De-Uso/50-denunciar-perfil.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e com acesso ao perfil que deseja denunciar
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso poder reportar um perfil inteiro na plataforma caso suspeite que seja um bot ou golpista.

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
| R1 | Denunciar exige login: a API responde `401` sem token | Permissão | `50`, Pré-condições; ADR-005 (L1) |
| R2 | O perfil público do usuário mostra a opção "⚑ Denunciar perfil" | Tela | `50`, FP 1–2; EA-080-01; Figma `1160-1396` |
| R3 | "Denunciar perfil" abre o modal "Denunciar @<nome de usuário>" com as categorias "Perfil falso ou bot", "Tentativa de golpe", "Conteúdo ofensivo no perfil" e "Outro motivo", uma só escolhida | Campo | `50`, FP 3–5; Figma `1160-17495` (L5) |
| R4 | "DETALHES (OPCIONAL)" aceita uma descrição de até 500 caracteres | Campo | `50`, FP 5; DBML `reports.description` (500) |
| R5 | O motivo é obrigatório: sem motivo, a denúncia não é enviada e a tela pede a seleção de um motivo; a API responde `400` | Regra | `50`, FP 6 e FA 1–2; DBML `reports.reason` (obrigatória) |
| R6 | "Enviar denúncia" grava `reports` com `reporter_id` = usuário, `target_user_id` = dono do perfil, `target_type = PROFILE`, `reason`, `description` e `status = PENDING` | Regra | `50`, FP 7–8; DBML `reports`, `report_target_type`; ADR-032 |
| R7 | Depois de gravar, a tela informa que a denúncia foi enviada para análise | Mensagem | `50`, FP 8 (L6) |
| R8 | "Cancelar" ou o "✕" fecha o modal sem registrar a denúncia | Ação | `50`, FA 3–4 |
| R9 | Perfil inexistente ou de conta excluída responde `404` | Regra | ADR-015, item 8; ADR-011 |
| R10 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`1160-1396`, `1160-17495`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R6, R7) — **Dado** Gabriel logado no perfil público de tiago_trocas, **quando** seleciona "Denunciar perfil", escolhe "Tentativa de golpe", escreve um detalhe e seleciona "Enviar denúncia", **então** `reports` é gravado com `target_type = PROFILE`, `target_user_id` de tiago_trocas e `status = PENDING`, e a tela informa que a denúncia foi enviada para análise.
- **CA2** (R5) — **Dado** o modal sem motivo escolhido, **quando** Gabriel seleciona "Enviar denúncia", **então** nada é gravado e a tela pede a seleção de um motivo; a API responde `400` sem `reason`.
- **CA3** (R4) — **Dado** um detalhe com mais de 500 caracteres, **quando** Gabriel envia, **então** a API responde `400` e nada é gravado.
- **CA4** (R8) — **Dado** o modal com um motivo escolhido, **quando** Gabriel seleciona "Cancelar" ou o "✕", **então** o modal fecha e nada é gravado.
- **CA5** (R1) — **Dado** um visitante sem login, **quando** chama a rota de denúncia, **então** recebe `401`.
- **CA6** (R9) — **Dado** um perfil de conta excluída, **quando** Gabriel tenta denunciá-lo, **então** recebe `404`.
- **CA7** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-1396` (perfil público com "Denunciar perfil"), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA8** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-17495` (denunciar perfil), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `reports` | `reporter_id`, `target_user_id`, `target_type` (`PROFILE`), `reason`, `description`, `status` (`PENDING`) | `reason` obrigatório (90); `description` até 500; `status` default `PENDING`; alvo polimórfico (ADR-032) |
| `users` | `id`, `username`, `deleted_at` | dono do perfil denunciado |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Perfil público do usuário | [1160-1396](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-1396) | R2 | ❌ Não bate: desenhado para o visitante, que vê "Denunciar perfil" sem login (L1) |
| Público - Perfil público - denunciar perfil | [1160-17495](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-17495) | R3–R5, R8 | ❌ Não bate: promessa de sigilo e prazo de 24 horas só no Figma (L4) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): perfil público — o frame é da visão do visitante ("Entrar",
  "Criar conta grátis") e mostra "Denunciar perfil"; o `50` exige login (L1).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "A denúncia é sigilosa: a pessoa não sabe
  quem denunciou. A moderação analisa em até 24 horas." (L4).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R5 aviso de motivo obrigatório; R7 confirmação de
  denúncia enviada.

## Fora do escopo

- O perfil público em si (dados, vendas, anúncios) — CCD080 (EA-080-01). A vitrine de conquistas — CCD049.
- Bloquear ou denunciar pelo chat — CCD047. Denunciar anúncio — CCD082. Denunciar vendedor — CCD083. Denunciar usuário pelo painel do vendedor — CCD090.
- Analisar a denúncia no BackOffice (L7).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O visitante vê "Denunciar perfil" no frame `1160-1396`. Ao selecionar, o que acontece? (proposta: o "Entre para continuar" da busca, `1160-2457`) Ou o link só aparece para quem está logado? | pendente | — |
| L2 | O dono do perfil vê "Denunciar perfil" na própria página? (proposta: não; a API recusa denunciar a si mesmo com `400`) | pendente | — |
| L3 | Denunciar o mesmo perfil de novo, com uma denúncia ainda `PENDING`, cria outra ou é recusado? | pendente | — |
| L4 | Só no Figma: "A denúncia é sigilosa: a pessoa não sabe quem denunciou. A moderação analisa em até 24 horas.". Faz sentido prometer sigilo e prazo? (sigilo: a API nunca mostra o denunciante ao denunciado) | pendente | — |
| L5 | Os motivos são fixos? Como ficam gravados em `reports.reason` (texto da tela ou código)? "Outro motivo" exige detalhes? A lista difere da do chat (CCD047) | pendente | — |
| L6 | Texto exato da confirmação de envio e do aviso de motivo obrigatório; pedir o frame ao Gabriel | pendente | — |
| L7 | Quem analisa a denúncia de perfil? A fila do BackOffice (CCD062) só trata `GROUP_MESSAGE` | pendente | — |
| L8 | O perfil do frame é de um vendedor: a denúncia usa `PROFILE` ou `SELLER` (CCD083)? (proposta: `PROFILE` sempre que vier desta página) | pendente | — |
| L9 | O ator é Cliente: `SELLER` e `ADMIN` também denunciam por aqui? (proposta: `CUSTOMER` e `SELLER`) | pendente | — |
