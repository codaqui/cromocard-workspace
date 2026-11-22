# CCD057 — Favoritar Grupo

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** não encontrada no board
- **Caso de uso:** [57-favoritar-grupo.md](../../docs/Casos-De-Uso/57-favoritar-grupo.md)
- **Atores:** Cliente · **Pré-condições:** autenticado; grupo disponível para visualização
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso favoritar um grupo para acessá-lo posteriormente com facilidade.

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
| R1 | Favoritar exige login: a API responde `401` sem token | Permissão | `57`, Pré-condições; ADR-005 (L2) |
| R2 | A página do grupo mostra a opção "Favoritar" | Tela | `57`, FP 1–2 (L1) |
| R3 | Selecionar "Favoritar" grava o favorito: `favorites` com `user_id`, `type = GROUP` e `group_id`, e só o `group_id` preenchido entre os alvos | Regra | `57`, FP 3–4; DBML `favorites`; ADR-032 |
| R4 | Depois de favoritar, o indicador visual do grupo muda e o sistema confirma a ação | Estado | `57`, FP 5 (L4) |
| R5 | Selecionar de novo num grupo favoritado remove o favorito (`deleted_at = now()`) e o indicador volta ao normal | Ação | `57`, FA 1–2; ADR-015, item 1 |
| R6 | O usuário tem no máximo um favorito ativo por grupo | Regra | `57`, FA 1–2 (L3) |
| R7 | Grupo indisponível (`groups.status = SUSPENDED` ou excluído) não pode ser favoritado: a API recusa e a tela informa que o grupo não está disponível para ser favoritado | Regra | `57`, FA 3–4; DBML `groups.status` (L2, L4) |
| R8 | "Meus Favoritos" > "Grupos" lista os grupos favoritados do usuário, para acessá-los depois | Tela | user story (narrativa); `57`, Finalidade (L5, L6) |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados. Vale também para o botão "Favoritar" do grupo quando o frame dele existir (L1) | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** o cliente logado na página do grupo "Pokémon TCG São Paulo", não favoritado, **quando** seleciona "Favoritar", **então** uma linha `favorites` com `type = GROUP` e o `group_id` é gravada, o botão passa ao estado de favoritado e aparece a confirmação.
- **CA2** (R5) — **Dado** o grupo favoritado, **quando** o cliente seleciona a opção de novo ou o ♥ dele em "Meus Favoritos", **então** o favorito fica com `deleted_at` preenchido e o grupo sai da lista.
- **CA3** (R6) — **Dado** o grupo favoritado, **quando** chegam duas chamadas de favoritar o mesmo grupo, **então** continua existindo um só favorito ativo.
- **CA4** (R7) — **Dado** um grupo com `status = SUSPENDED`, **quando** o cliente tenta favoritá-lo, **então** a API responde `422`, nada é gravado e a tela informa que o grupo não está disponível; **dado** um grupo excluído, **então** a API responde `404`.
- **CA5** (R1) — **Dado** uma chamada sem token, **quando** pede para favoritar um grupo, **então** recebe `401`.
- **CA6** (R8) — **Dado** o cliente com 4 grupos favoritados, **quando** abre "Meus Favoritos" > "Grupos", **então** vê os 4 e cada um abre o grupo.
- **CA7** (R8) — **Dado** a lista abrindo, **quando** a busca não respondeu ou falhou, **então** a tela mostra o carregamento ou um aviso de erro no estilo da tela.
- **CA8** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-11250`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `favorites` | `id`, `user_id`, `type` (`favorite_type`: `GROUP`), `group_id`, `created_at`, `deleted_at` | exatamente um alvo preenchido (ADR-032); sem índice único no DBML (L3) |
| `groups` | `id`, `name`, `status` (`group_status`: `ACTIVE`, `WARNED`, `SUSPENDED`), `access_type`, `deleted_at` | disponibilidade (R7, L2); não tem coluna de cidade (L5) |
| `group_members` | `user_id`, `group_id` | contagem de membros no cartão (L5) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Notificações — meus favoritos (grupos) | [675-11250](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-11250) | R5, R8 | ⚠️ Conteúdo do cartão só no Figma (L5) |
| Página do grupo com "Favoritar" | **falta o desenho no Figma** (L1) | R2, R4 | ❌ Sem frame |

- Textos de `675-11250`: aba "Grupos (6)", nome do grupo, "142 membros • São Paulo - SP", selos ("12 mensagens novas", "Encontro sábado, 14h", "3 menções a você", "Sem novidades"), chave "Notificações ativas"/"Silenciado", "Abrir chat" e ♥.
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): conteúdo do cartão (L5); busca, ordenação e contadores (CCD055, L6).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R2 e R4 o botão "Favoritar" na página do grupo, com o estado favoritado e a confirmação; R7 o aviso de grupo indisponível; a lista vazia (L6).

## Fora do escopo

- Favoritar álbum e carta — CCD055 e CCD056.
- Chave "Notificações ativas"/"Silenciado" — CCD041 (`group_members.muted_until`).
- "Abrir chat" e o chat do grupo — CCD044; entrar no grupo — CCD039.
- "Encontro sábado, 14h" — encontro presencial, fora do escopo (`escopo-adicional.md`, seção 3).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Falta o desenho do botão "Favoritar" do grupo no Figma: nenhuma tela de Comunidades tem a opção. Em qual tela ele fica (chat do grupo `675-14037`, detalhes `675-17336` ou cartão em Comunidades `417-2915`)? | pendente | — |
| L2 | Quem pode favoritar? Só membro, ou também quem vê o grupo restrito sem ser membro (`access_type`)? `WARNED` conta como disponível? (proposta: qualquer cliente que vê o grupo; `ACTIVE` e `WARNED` disponíveis) | pendente | — |
| L3 | `favorites` não tem índice único. Favoritar de novo restaura a linha ou cria outra? (mesma pergunta da CCD055, L2) | pendente | — |
| L4 | Textos da confirmação ao favoritar e do aviso de grupo indisponível: a documentação não define e o Figma não desenha | pendente | — |
| L5 | Cartão do grupo em Meus Favoritos (só no Figma): membros • cidade (o DBML não tem cidade do grupo), selos de novidade ("12 mensagens novas", "3 menções a você", "Sem novidades") e "Abrir chat". Faz sentido implementar? | pendente | — |
| L6 | Lista de grupos favoritos vazia: sem texto na documentação e sem desenho | pendente | — |
