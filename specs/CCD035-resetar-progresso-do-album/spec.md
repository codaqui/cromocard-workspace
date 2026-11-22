# CCD035 — Resetar Progresso do Álbum

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #138 `CCD035 - Resetar Progresso do Álbum`
- **Caso de uso:** [35-resetar-progresso-do-album.md](../../docs/Casos-De-Uso/35-resetar-progresso-do-album.md)
- **Atores:** Cliente · **Pré-condições:** cliente autenticado, com um álbum com pelo menos uma carta marcada
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso poder limpar todos os dados de um álbum caso decida recomeçar a coleção do zero.

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
| R1 | Resetar exige login: sem token, `401`. O cliente só reseta álbum da própria coleção: álbum fora da coleção dele responde `404` | Permissão | `35`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | No detalhe do álbum, o menu "⋯" do cabeçalho tem a opção "Resetar progresso" | Ação | `35`, FP 1–2; Figma `1160-26090` |
| R3 | "Resetar progresso" abre a confirmação "Resetar o progresso do álbum?", com "Todas as marcações do álbum <título> (possuo, faltante, repetida e quantidades) serão apagadas e o progresso volta a 0%. Isso não pode ser desfeito.", "Cancelar", "Resetar progresso" e "✕" | Tela | `35`, FP 3; Figma `1160-27304` |
| R4 | Confirmar remove todas as marcações e quantidades das cartas daquele álbum na coleção do cliente e põe o progresso em 0% | Regra | `35`, FP 4–5; DBML `collection_cards`, `user_albums.progress_percentage` |
| R5 | A remoção é lógica: as marcações ganham `deleted_at`, sem `DELETE` físico | Regra | ADR-015, itens 1 e 2 |
| R6 | O reset só mexe nas cartas do álbum escolhido: as de outros álbuns e o próprio álbum na coleção (`user_albums`) continuam | Regra | `35`, Finalidade e FP 5 |
| R7 | Depois do reset, a tela mostra uma mensagem de sucesso e o detalhe do álbum aparece em 0%, com as cartas sem marcação | Mensagem | `35`, FP 6 (L2) |
| R8 | "Cancelar" ou "✕" fecham a confirmação e o progresso continua como estava | Ação | `35`, FA 1–2; Figma `1160-27304` |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `1160-26090`, `1160-27304`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R7) — **Dado** a Copa do Mundo 2026 com 44 cartas possuídas, 6 repetidas e 10 faltantes, **quando** o
  cliente abre "⋯", seleciona "Resetar progresso" e confirma, **então** as marcações das cartas desse álbum ficam com
  `deleted_at`, o progresso vai a 0%, a tela mostra a mensagem de sucesso e a grade aparece sem marcação.
- **CA2** (R6) — **Dado** cartas marcadas em dois álbuns, **quando** o cliente reseta um deles, **então** as marcações do
  outro continuam iguais e o álbum resetado continua em "Meus álbuns".
- **CA3** (R8) — **Dado** a confirmação aberta, **quando** o cliente seleciona "Cancelar" ou "✕", **então** a confirmação
  fecha e nenhuma marcação muda.
- **CA4** (R1) — **Dado** um visitante sem login, **quando** chama a rota de resetar, **então** recebe `401`; **dado** um
  cliente logado, **quando** pede o reset de um álbum fora da coleção dele, **então** recebe `404`.
- **CA5** (R4) — **Dado** um álbum resetado, **quando** o cliente marca de novo uma carta como possuo, **então** a marcação
  é gravada com quantidade 1 (o registro antigo é restaurado, ADR-015, item 7) e o progresso sobe.
- **CA6** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-26090`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no menu "⋯"; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem
  rolagem horizontal.
- **CA7** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-27304`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem na confirmação; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem
  rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `collection_cards` | `collection_id`, `card_id`, `status`, `quantity`, `deleted_at` | reset = preencher `deleted_at` (ADR-015); re-marcar restaura (item 7) |
| `cards` | `album_id` | quais cartas pertencem ao álbum |
| `user_albums` | `collection_id`, `album_id`, `progress_percentage` | progresso volta a 0; o registro continua |
| `albums` | `title` | título na confirmação |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - menu do álbum | [1160-26090](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-26090) | R2 | ✅ Bate |
| Álbuns - resetar progresso | [1160-27304](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-27304) | R3, R8 | ✅ Bate |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): nenhuma.
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): nenhum.
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R7 a mensagem de sucesso (L2); o estado do menu
  quando o álbum não tem carta marcada (L1).

## Fora do escopo

- "Remover da minha coleção", no mesmo menu — CCD011.
- Desmarcar uma carta só — CCD014–CCD018.
- Os anúncios do cliente: o reset não mexe em `listings`.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | A Pré-condição exige pelo menos uma carta marcada. Sem nenhuma, "Resetar progresso" some do menu, fica desabilitado ou abre um aviso? (proposta: desabilitado) | pendente | — |
| L2 | Texto e forma da mensagem de sucesso (FP 6), que o Figma não desenha | pendente | — |
| L3 | O texto da confirmação diz "Isso não pode ser desfeito", mas a remoção é lógica (ADR-015). Confirmar que nenhuma tela oferece desfazer, e que re-marcar restaura o registro com quantidade 1 | pendente | — |
| L4 | "Cliente" são os papéis `CUSTOMER` e `SELLER`? E o `ADMIN`? (proposta: `CUSTOMER` e `SELLER`; `ADMIN` recebe `403`, como na CCD103, L8) | pendente | — |
