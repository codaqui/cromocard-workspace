# CCD056 — Favoritar Carta

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** não encontrada no board
- **Caso de uso:** [56-favoritar-carta.md](../../docs/Casos-De-Uso/56-favoritar-carta.md) · relacionado: [30-visualizar-detalhes.md](../../docs/Casos-De-Uso/30-visualizar-detalhes.md) (FA 1–2)
- **Atores:** Cliente · **Pré-condições:** autenticado; carta disponível para visualização
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso favoritar uma carta para acessá-la posteriormente com facilidade.

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
| R1 | Favoritar exige login: a API responde `401` sem token; o visitante que seleciona "Favoritar" no perfil da carta vê "Entre para continuar", com "Continuar com Google", "Entrar com e-mail e senha" e "Criar conta grátis" | Permissão | `56`, Pré-condições; `30`, FA 1–2; ADR-005 |
| R2 | Depois do login pelo "Entre para continuar", o usuário volta para a carta | Ação | `30`, FA 2 |
| R3 | O perfil da carta mostra a opção "Favoritar" | Tela | `56`, FP 1–2; `30`, Pré-condições |
| R4 | Selecionar "Favoritar" grava o favorito: `favorites` com `user_id`, `type = CARD` e `card_id`, e só o `card_id` preenchido entre os alvos | Regra | `56`, FP 3–4; DBML `favorites`; ADR-032 |
| R5 | Depois de favoritar, o indicador visual da carta muda e o sistema confirma a ação | Estado | `56`, FP 5 (L2) |
| R6 | Selecionar de novo numa carta favoritada remove o favorito (`deleted_at = now()`) e o indicador volta ao normal | Ação | `56`, FA 1–2; ADR-015, item 1 |
| R7 | O usuário tem no máximo um favorito ativo por carta | Regra | `56`, FA 1–2 (L1) |
| R8 | Carta indisponível (`cards.status = DRAFT` ou excluída) não pode ser favoritada: a API recusa e a tela informa que a carta não está disponível para ser favoritada | Regra | `56`, FA 3–4; DBML `cards.status` (L2) |
| R9 | "Meus Favoritos" > "Cartas" lista as cartas favoritadas do usuário, para acessá-las depois | Tela | user story (narrativa); `56`, Finalidade (L4, L5) |
| R10 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R3–R5) — **Dado** o cliente logado no perfil da carta "Lionel Messi", não favoritada, **quando** seleciona "Favoritar", **então** uma linha `favorites` com `type = CARD` e o `card_id` é gravada, o botão passa ao estado de favoritada e aparece a confirmação.
- **CA2** (R6) — **Dado** a carta favoritada, **quando** o cliente seleciona a opção de novo ou o ♥ dela em "Meus Favoritos", **então** o favorito fica com `deleted_at` preenchido e a carta sai da lista.
- **CA3** (R7) — **Dado** a carta favoritada, **quando** chegam duas chamadas de favoritar a mesma carta, **então** continua existindo um só favorito ativo.
- **CA4** (R8) — **Dado** uma carta com `status = DRAFT`, **quando** alguém tenta favoritá-la pela API, **então** recebe `404` (a carta em rascunho não aparece no catálogo) e nada é gravado; **dado** uma carta excluída, **então** também `404`, e a tela informa que a carta não está disponível.
- **CA5** (R1, R2) — **Dado** um visitante no perfil da carta, **quando** seleciona "Favoritar", **então** vê "Entre para continuar"; **quando** entra com e-mail e senha, **então** volta ao perfil da mesma carta. Sem token, a API responde `401`.
- **CA6** (R9) — **Dado** o cliente com 3 cartas favoritadas, **quando** abre "Meus Favoritos" > "Cartas", **então** vê as 3 e cada uma abre o perfil da carta.
- **CA7** (R9) — **Dado** a lista abrindo, **quando** a busca não respondeu ou falhou, **então** a tela mostra o carregamento ou um aviso de erro no estilo da tela.
- **CA8** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-4615`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA9** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-5461`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA10** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-10296`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `favorites` | `id`, `user_id`, `type` (`favorite_type`: `CARD`), `card_id`, `created_at`, `deleted_at` | exatamente um alvo preenchido (ADR-032); sem índice único no DBML (L1) |
| `cards` | `id`, `name`, `status` (`card_status`: `DRAFT`, `ACTIVE`), `deleted_at`, `front_image_url` | disponibilidade (R8) e cartão da lista |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público — Perfil da carta | [1112-4615](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-4615) | R3 | ⚠️ Botão "Favoritar" bate; estado favoritado não desenhado |
| Público — Entre para continuar | [1112-5461](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-5461) | R1, R2 | ✅ Bate |
| Notificações — meus favoritos (cartas) | [675-10296](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-10296) | R6, R9 | ⚠️ Conteúdo do cartão só no Figma, com graduação fora do escopo (L4) |

- Textos: "Favoritar", "Ainda não tem conta? Você pode ver tudo nesta página; para comprar, favoritar ou adicionar à coleção, basta entrar."; no modal, "Entre para continuar", "Faça login para continuar. É rápido e grátis.", "Continuar com Google", "ou", "Entrar com e-mail e senha", "Criar conta grátis", "Ao continuar, você aceita os Termos de Uso e a Política de Privacidade."
- **Diferenças com o Figma** (decisão em Lacunas e decisões): o cartão de `675-10296` mostra graduação ("PSA 10", "BGS 9.5", "BGS 10"), que o `escopo-adicional.md` (seção 3) tira do escopo (L4).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Favoritar" no detalhe do anúncio (`1112-5772`, `1112-6152`) (L3); preço, variação, "Avisar abaixo de…" e "Comprar" no cartão (L4); busca, ordenação e contadores (CCD055, L6).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R5 o botão no estado favoritado e a confirmação; R8 o aviso de carta indisponível; a lista vazia (L5).

## Fora do escopo

- Favoritar álbum e grupo — CCD055 e CCD057.
- "Adicionar à coleção" — CCD022; "Ver anúncios" e o restante do perfil da carta — CCD030 e CCD031.
- "Comprar" — CCD072.
- "🔔 Avisar abaixo de R$ …" — alerta de preço, fase Futuro ("Configurar Alertas de Preço", `**`).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | `favorites` não tem índice único. Favoritar de novo restaura a linha ou cria outra? (mesma pergunta da CCD055, L2; proposta: índice único parcial, com ADR e DBML) | pendente | — |
| L2 | Textos da confirmação ao favoritar e do aviso de carta indisponível: a documentação não define e o Figma não desenha | pendente | — |
| L3 | O Figma tem "Favoritar" também no detalhe do anúncio (`1112-5772`, `1112-6152`), e `favorites` não tem `listing_id`. Faz sentido implementar? Se sim, favorita a carta do anúncio? | pendente | — |
| L4 | Cartão da carta em Meus Favoritos (só no Figma): coleção • condição ou graduação ("PSA 10", fora do escopo), preço (qual: preço médio ou menor anúncio?), variação ("-3% hoje", "Estável", "+4% no mês"), "🔔 Avisar abaixo de R$ 1.700" (fase Futuro) e "Comprar" (para qual anúncio?). Faz sentido implementar? O quê? | pendente | — |
| L5 | Lista de cartas favoritas vazia: sem texto na documentação e sem desenho | pendente | — |
