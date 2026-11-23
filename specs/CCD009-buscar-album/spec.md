# CCD009 — Buscar Álbum

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #115 `CCD009-Buscar Álbum`
- **Caso de uso:** [09-buscar-album.md](../../docs/Casos-De-Uso/09-buscar-album.md)
- **Atores:** Cliente · **Pré-condições:** na tela "Meus Álbuns", com a barra de pesquisa interna visível
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso buscar álbuns para localizar rapidamente uma coleção específica.

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
| R1 | Buscar exige login e procura só nos álbuns da coleção do próprio cliente: sem token, a API responde `401` | Permissão | `09`, Finalidade e Pré-condições; ADR-005, item 4; ADR-011 (papel `ADMIN`: L1) |
| R2 | A tela "Meus Álbuns" tem um campo de busca interno visível | Campo | `09`, Pré-condições (desenho: L2) |
| R3 | O cliente busca pelo nome (`albums.title`) ou pelo ano (`albums.year`) do álbum (como compara: L4) | Regra | `09`, Finalidade e FP 1 |
| R4 | A lista de álbuns é filtrada em tempo real, a cada caractere digitado | Ação | `09`, FP 2 |
| R5 | O cliente seleciona um álbum nos resultados e abre o detalhe dele (CCD013) | Ação | `09`, FP 3; `13`, FP 1 |
| R6 | Sem álbuns na coleção, a tela mostra uma mensagem informativa e um botão que leva ao Catálogo Global (o mesmo estado vazio da CCD008) | Estado | `09`, FA 1; `08`, FA 1 |
| R7 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados. O campo de busca, que o Figma ainda não desenha, segue o frame quando ele existir | Fidelidade | Figma (frames da seção Telas: `1160-23080`, `1160-29088`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R4) — **Dado** um cliente com os álbuns "Copa do Mundo 2026" e "Destinos Brilhantes", **quando** ele digita "cop" no campo de busca de "Meus Álbuns", **então** a lista mostra só "Copa do Mundo 2026", sem precisar confirmar a busca.
- **CA2** (R3, R4) — **Dado** um álbum de 2002 e outro de 2026 na coleção, **quando** o cliente digita "2002", **então** a lista mostra só o álbum de 2002.
- **CA3** (R4) — **Dado** a lista filtrada por "cop", **quando** o cliente apaga o texto do campo, **então** a lista volta a mostrar todos os álbuns.
- **CA4** (R5) — **Dado** a lista filtrada, **quando** o cliente seleciona um álbum do resultado, **então** vai para o detalhe desse álbum.
- **CA5** (R6) — **Dado** um cliente sem álbuns, **quando** abre "Meus Álbuns", **então** vê a mensagem informativa e o botão que leva ao Catálogo Global.
- **CA6** (R1) — **Dado** um álbum que só está na coleção de outro cliente, **quando** o cliente busca pelo nome dele, **então** o álbum não aparece; sem login, a API responde `401`.
- **CA7** (R7) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-23080` (com o campo de busca desenhado, L2), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA8** (R7) — **Dado** a tela implementada aberta em 1280 px sem álbuns, **quando** o print dela é comparado lado a lado com o print do frame `1160-29088`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `user_albums` | `collection_id`, `album_id`, `deleted_at` | só os álbuns ativos da coleção |
| `albums` | `title`, `year`, `deleted_at` | `title` obrigatório (`varchar(160)`); `year` `smallint`, opcional |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - Meus álbuns | [1160-23080](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23080) | R2–R5, R7 | ❌ Não bate: não tem o campo de busca (L2) |
| Álbuns - sem álbuns | [1160-29088](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-29088) | R6, R7 | ❌ Não bate: botão "Solicitar álbum" no lugar do botão para o Catálogo Global (L4 da CCD008) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): sem álbuns — o mesmo ponto da CCD008, L4.
- **Só no Figma**: nada específico da busca. As abas por categoria e "Ordenar por: Mais recentes" pertencem à CCD034 e à CCD008 (L8).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R2 campo de busca em "Meus álbuns" (L2).
  - Resultado vazio da busca (L3).

## Fora do escopo

- A lista de álbuns, os indicadores e os cartões — CCD008.
- Filtro por categoria (abas) — CCD034.
- Buscar álbuns no catálogo global, fora da coleção — CCD002 e CCD021.
- Detalhe do álbum — CCD013.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O `ADMIN` usa a busca do Painel Cliente? (proposta: não, como na CCD008, L1) | pendente | — |
| L2 | Falta o desenho do campo de busca em "Meus álbuns" (`1160-23080`): o caso de uso pede a barra de pesquisa interna. Onde e com qual texto de ajuda? (proposta: o Gabriel desenha o campo na linha das abas, à esquerda de "Ordenar por", com o texto "Buscar álbum pelo nome ou ano", no estilo de "Buscar carta na coleção" do Início) | pendente | — |
| L3 | O caso de uso não diz o que aparece quando nenhum álbum combina com o texto, e o Figma não desenha. (proposta: "Nenhum álbum encontrado para "<texto>"" e o bloco "Não encontrou a coleção que você coleciona?" com "Solicitar álbum") | pendente | — |
| L4 | Como compara o texto: trecho do nome, sem diferenciar maiúsculas e acentos? O ano precisa ser exato? A busca combina com a aba de categoria selecionada (CCD034)? (proposta: trecho do nome sem diferenciar maiúsculas e acentos; ano exato com 4 dígitos; combina com a aba) | pendente | — |
| L5 | O FA 1 do caso de uso (sem álbuns) repete o da CCD008 e não trata a busca. Manter ou trocar pelo resultado vazio (L3)? (proposta: manter o FA 1 e acrescentar o resultado vazio como FA 2) | pendente | — |
