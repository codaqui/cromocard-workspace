# CCD055 — Favoritar Álbum

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #1315 `CCD055 - Favoritar Álbum` (criada em 22/11/2026)
- **Caso de uso:** [55-favoritar-album.md](../../docs/Casos-De-Uso/55-favoritar-album.md) · complemento: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md) (EA-002-01)
- **Atores:** Cliente · **Pré-condições:** autenticado; álbum disponível para visualização
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso favoritar álbuns para acessá-los rapidamente posteriormente.

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
| R1 | Favoritar exige login: a API responde `401` sem token; o visitante que seleciona "Favoritar" na página pública do álbum vê "Entre para continuar" | Permissão | `55`, Pré-condições; EA-002-01; ADR-005 |
| R2 | A página do álbum mostra a opção "Favoritar" | Tela | `55`, FP 1–2; EA-002-01 (L4) |
| R3 | Selecionar "Favoritar" grava o favorito: `favorites` com `user_id`, `type = ALBUM` e `album_id`, e só o `album_id` preenchido entre os alvos | Regra | `55`, FP 3–4; DBML `favorites`; ADR-032 (L1) |
| R4 | Depois de favoritar, o indicador visual do álbum muda e o sistema confirma a ação | Estado | `55`, FP 5 (L3) |
| R5 | Selecionar de novo num álbum favoritado remove o favorito (`deleted_at = now()`) e o indicador volta ao normal | Ação | `55`, FA 1–2; ADR-015, item 1 |
| R6 | O usuário tem no máximo um favorito ativo por álbum: favoritar um álbum já favoritado não cria outra linha | Regra | `55`, FA 1–2 (L2) |
| R7 | Álbum indisponível (`albums.status = INACTIVE` ou excluído) não pode ser favoritado: a API recusa e a tela informa que o álbum não está disponível para ser favoritado | Regra | `55`, FA 3–4; DBML `albums.status` (L3) |
| R8 | "Meus Favoritos" > "Álbuns" lista os álbuns favoritados do usuário, para acessá-los depois | Tela | user story (narrativa); `55`, Finalidade (L5, L6) |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** o cliente logado na página do álbum "Destinos Brilhantes", não favoritado, **quando** seleciona "Favoritar", **então** uma linha `favorites` com `type = ALBUM` e o `album_id` é gravada, o botão passa ao estado de favoritado e aparece a confirmação.
- **CA2** (R5) — **Dado** o álbum favoritado, **quando** o cliente seleciona a opção de novo, **então** o favorito fica com `deleted_at` preenchido, o botão volta ao normal e o álbum sai de "Meus Favoritos".
- **CA3** (R6) — **Dado** o álbum favoritado, **quando** chegam duas chamadas de favoritar o mesmo álbum, **então** continua existindo um só favorito ativo.
- **CA4** (R7) — **Dado** um álbum com `status = INACTIVE`, **quando** o cliente tenta favoritá-lo, **então** a API responde `422`, nada é gravado e a tela informa que o álbum não está disponível; **dado** um álbum excluído, **então** a API responde `404`.
- **CA5** (R1) — **Dado** um visitante na página pública do álbum, **quando** seleciona "Favoritar", **então** vê "Entre para continuar" e nada é gravado; **dado** uma chamada sem token, **então** a API responde `401`.
- **CA6** (R8) — **Dado** o cliente com 2 álbuns favoritados, **quando** abre "Meus Favoritos" > "Álbuns", **então** vê os 2 álbuns e cada um abre a página do álbum.
- **CA7** (R8) — **Dado** a lista abrindo, **quando** a busca não respondeu ou falhou, **então** a tela mostra o carregamento ou um aviso de erro no estilo da tela.
- **CA8** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-1845`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA9** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-10770`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `favorites` | `id`, `user_id`, `type` (`favorite_type`: `ALBUM`), `album_id`, `created_at`, `deleted_at` | `user_id` e `type` obrigatórios; exatamente um alvo preenchido (ADR-032); sem índice único no DBML (L2) |
| `albums` | `id`, `title`, `status` (`album_status`: `ACTIVE`, `INACTIVE`), `deleted_at` | disponibilidade (R7) |
| `user_albums` | `is_favorite` | outra marca de favorito no DBML (L1) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público — Álbum do catálogo | [1160-1845](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-1845) | R1, R2 | ⚠️ Botão "Favoritar" bate; estado favoritado não desenhado |
| Notificações — meus favoritos (álbuns) | [675-10770](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-10770) | R5, R8 | ⚠️ Conteúdo do cartão, busca e ordenação só no Figma (L5, L6) |

- Textos: "Favoritar" (página do álbum); em Meus Favoritos, "Meus Favoritos", abas "Cartas (14)", "Álbuns (8)", "Grupos (6)", "Buscar nos favoritos...", "Recentes ▾", "Abrir álbum", "Faltantes", ♥ para remover e o aviso "Álbum “Euro 2024” removido dos favoritos" com "Desfazer".
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Desfazer" no aviso de remoção (L3); progresso, avisos e "Faltantes" no cartão (L5); busca, ordenação e contadores (L6).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R4 o botão no estado favoritado e a confirmação ao favoritar; R7 o aviso de álbum indisponível; o modal "Entre para continuar" sobre a página do álbum (R1, igual ao de `1112-5461`); a lista de favoritos vazia (L7).

## Fora do escopo

- Favoritar carta e grupo — CCD056 e CCD057.
- "Adicionar à minha coleção" — CCD002 (EA-002-01).
- A aba "Central de Notificações" — CCD053.
- Avisos de mudança no checklist do álbum favoritado — sem caso de uso (L5).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O DBML tem duas marcas de favorito de álbum: `favorites` (`type = ALBUM`) e `user_albums.is_favorite`. Qual vale? (proposta: `favorites`, que serve também para álbum fora da coleção; `is_favorite` sai do DBML ou ganha outro sentido, com ADR) | pendente | — |
| L2 | `favorites` não tem índice único e não está na lista do ADR-015 (item 7). Favoritar de novo depois de remover restaura a linha ou cria outra? Como evitar duplicata? (proposta: índice único parcial por usuário e alvo onde `deleted_at` é nulo, com ADR e DBML) | pendente | — |
| L3 | Textos da confirmação ao favoritar e do aviso de álbum indisponível: a documentação não define. O Figma só desenha o aviso de remoção, com "Desfazer". O "Desfazer" faz sentido? | pendente | — |
| L4 | Onde fica o botão para o cliente logado? O Figma só tem "Favoritar" na página pública do álbum (`1160-1845`); o detalhe do álbum da coleção (`1160-23696`) não tem. Favoritar também lá? | pendente | — |
| L5 | Cartão do álbum em Meus Favoritos (só no Figma): editora • total de cartas, progresso ("412 / 680 cartas", %), avisos ("🔔 Atualizado: 18 novas cartas", "Checklist oficial atualizado", "Faltam só 11 cartas!") e "Faltantes". Faz sentido implementar? O progresso só existe com o álbum na coleção (`user_albums`) e os avisos não têm dado no DBML | pendente | — |
| L6 | Busca "Buscar nos favoritos...", ordenação "Recentes ▾", contadores por aba e "28 Itens Salvos" (só no Figma, valem também para CCD056 e CCD057). Faz sentido implementar? | pendente | — |
| L7 | Lista de favoritos vazia: sem texto na documentação e sem desenho | pendente | — |
