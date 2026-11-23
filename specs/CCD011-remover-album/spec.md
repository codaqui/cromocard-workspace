# CCD011 — Remover Álbum

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #117 `CCD011-Remover Álbum`
- **Caso de uso:** [11-remover-album.md](../../docs/Casos-De-Uso/11-remover-album.md)
- **Atores:** Cliente · **Pré-condições:** autenticado, selecionando a opção de remoção nas configurações do álbum
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso remover álbuns da minha coleção para manter apenas as coleções que desejo acompanhar.

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
| R1 | Remover exige login e só vale para álbum da coleção do próprio cliente: sem token, `401`; álbum fora da coleção dele, `404` | Permissão | `11`, Pré-condições; ADR-005, item 4; ADR-011 (papel `ADMIN`: L1) |
| R2 | O ícone de opções do álbum tem a opção "Remover Álbum" (rótulo e onde fica: L2, L3) | Ação | `11`, FP 1 |
| R3 | A opção abre um modal de confirmação que alerta que todo o progresso de marcação do álbum será perdido | Mensagem | `11`, FP 2 |
| R4 | Ao confirmar, a API exclui de forma lógica o vínculo do álbum com a coleção (`user_albums.deleted_at`) e as marcações das cartas desse álbum (`collection_cards.deleted_at`); o álbum continua no catálogo | Regra | `11`, Finalidade e FP 3–4; ADR-015, itens 1 e 6 |
| R5 | Depois de remover, a tela recarrega a lista de álbuns já sem o álbum removido | Ação | `11`, FP 4 |
| R6 | "Cancelar" fecha o modal sem alterar nenhum dado | Ação | `11`, FA 1 |
| R7 | Se a API falha ao remover, a tela mostra a mensagem de erro da API e o álbum continua na coleção | Estado | ADR-041, Erros |
| R8 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1160-26090`, `1160-27915`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3) — **Dado** o cliente no álbum "Copa do Mundo 2026", **quando** ele abre o menu de opções e seleciona a remoção, **então** vê o modal de confirmação avisando que as marcações das cartas do álbum serão perdidas.
- **CA2** (R4, R5) — **Dado** o modal aberto, **quando** o cliente confirma, **então** a API responde com sucesso, `user_albums` do álbum e as `collection_cards` das cartas dele ficam com `deleted_at` preenchido, o álbum continua no catálogo e a lista de álbuns aparece sem ele, com os indicadores atualizados.
- **CA3** (R4) — **Dado** um cliente com cartas marcadas em dois álbuns, **quando** remove um deles, **então** as marcações do outro álbum não mudam.
- **CA4** (R6) — **Dado** o modal aberto, **quando** o cliente seleciona "Cancelar", **então** o modal fecha e o álbum e as marcações continuam iguais.
- **CA5** (R1) — **Dado** um álbum que não está na coleção do cliente, **quando** ele chama a remoção pela API, **então** recebe `404`; sem login, recebe `401`.
- **CA6** (R7) — **Dado** a API fora do ar, **quando** o cliente confirma a remoção, **então** vê a mensagem de erro e o álbum continua na lista.
- **CA7** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-26090` (menu do álbum aberto), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA8** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-27915` (modal de remoção), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `user_albums` | `collection_id`, `album_id`, `progress_percentage`, `deleted_at` | soft delete (ADR-015); único por (`collection_id`, `album_id`), então readicionar restaura a linha (ADR-015, item 7; L5) |
| `collection_cards` | `collection_id`, `card_id`, `deleted_at` | soft delete das cartas do álbum removido |
| `cards` | `album_id` | quais cartas pertencem ao álbum |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - menu do álbum | [1160-26090](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-26090) | R2, R8 | ❌ Não bate: rótulo "Remover da minha coleção" (L2) |
| Álbuns - remover álbum | [1160-27915](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-27915) | R3–R6, R8 | ✅ Bate: "Remover o álbum da sua coleção?", "<álbum> sai da sua lista de álbuns e as marcações das cartas são apagadas. O álbum continua no catálogo: você pode adicioná-lo de novo quando quiser.", "Cancelar", "Remover álbum" e "✕" (L9) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Menu do álbum — a opção se chama "Remover da minha coleção"; o caso de uso a chama de "Remover Álbum" (L2).
  - O modal aparece sobre "Meus álbuns", mas o único menu aberto no Figma é o do detalhe do álbum; o menu "⋮" do cartão em "Meus álbuns" não tem frame aberto (L3).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "✕" no modal (L9).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R7 mensagem de erro ao remover.

## Fora do escopo

- "Resetar progresso", a outra opção do mesmo menu — CCD035.
- Adicionar o álbum de novo à coleção — CCD022 e página pública do álbum (EA-002-01).
- Lista de álbuns — CCD008.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O `ADMIN` remove álbum pelo Painel Cliente? (proposta: não, como na CCD008, L1) | pendente | — |
| L2 | O caso de uso chama a opção de "Remover Álbum"; o Figma, de "Remover da minha coleção" (menu) e "Remover álbum" (botão do modal). (proposta: como no Figma) | pendente | — |
| L3 | Onde fica a opção: no menu "⋯" do detalhe (`1160-26090`) e também no "⋮" do cartão em "Meus álbuns", que não tem frame aberto? (proposta: nos dois lugares, com o mesmo menu; o Gabriel desenha o "⋮" aberto) | pendente | — |
| L4 | Removendo pelo detalhe do álbum, para onde o cliente vai? (proposta: para "Meus álbuns", que é a lista recarregada do FP 4) | pendente | — |
| L5 | O ADR-015 (item 7) restaura a linha ao readicionar, mas o modal promete que as marcações são apagadas. Ao adicionar o álbum de novo, as marcações antigas voltam? (proposta: não; `user_albums` é restaurado com `progress_percentage = 0` e as `collection_cards` antigas continuam excluídas até o cliente marcar de novo, quando a linha é restaurada com o status novo) | pendente | — |
| L6 | Depois de remover, aparece uma mensagem de sucesso? Nem o caso de uso nem o Figma mostram. (proposta: o aviso padrão "Álbum removido da sua coleção") | pendente | — |
| L7 | Anúncios ativos (`listings`) de cartas do álbum removido mudam? (proposta: não; o anúncio é do vendedor e não depende da coleção) | pendente | — |
| L8 | Álbum removido some do resumo (CCD007), do compartilhamento (CCD012) e das contagens? (proposta: sim, todas as leituras filtram `deleted_at`) | pendente | — |
| L9 | O "✕" do modal só existe no Figma. Faz o mesmo que "Cancelar"? (proposta: sim) | pendente | — |
