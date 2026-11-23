# CCD036 — Adicionar Carta ao Portfólio

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #139 `CCD036 - Adicionar Carta ao Portfólio`
- **Caso de uso:** [36-adicionar-carta-ao-portfolio.md](../../docs/Casos-De-Uso/36-adicionar-carta-ao-portfolio.md)
- **Atores:** Cliente · **Pré-condições:** cliente autenticado, com pelo menos um álbum na coleção
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso pesquisar e adicionar cartas soltas ao meu portfólio para controle pessoal.

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
| R1 | Adicionar ao portfólio exige login: sem token, `401` | Permissão | `36`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | O cliente chega à busca pela tela do álbum, em "+ Adicionar carta", que abre o modal "Adicionar carta" | Ação | `36`, FP 1; Figma `1160-23696`, `1160-28449` (L2) |
| R3 | O cliente localiza a carta por pesquisa (regras da CCD021) | Ação | `36`, FP 2; `21`, FP 1–4 |
| R4 | Cada carta encontrada mostra nome, número, coleção (álbum) e imagem | Tela | `36`, FP 3; Figma `1160-28449` |
| R5 | O cliente seleciona "Adicionar ao Portfólio" e informa a quantidade | Ação | `36`, FP 4 (L3, L4) |
| R6 | A carta entra na coleção com status `OWNED` e a quantidade informada | Regra | `36`, FP 5; DBML `collection_cards.status`, `quantity` |
| R7 | O progresso do álbum da carta é recalculado e a tela mostra uma mensagem de sucesso | Regra | `36`, FP 6; `19`, FP 2 (L6) |
| R8 | Carta que já está no portfólio: a tela informa que o item já existe e oferece atualizar a quantidade | Regra | `36`, FA 1 (L5) |
| R9 | Quando a carta não está no catálogo, a tela oferece "Solicitar Cadastro da Carta" (CCD023) | Ação | `36`, FA 2; Figma `1160-28449` ("Não encontrou a carta?" / "Solicitar cadastro da carta →") (L7) |
| R10 | Carta removida antes da coleção volta pelo mesmo registro, restaurado com o status e a quantidade novos | Regra | ADR-015, item 7 |
| R11 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `1160-23696`, `1160-28449`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R7) — **Dado** o detalhe da Copa do Mundo 2026 e a carta "Kylian Mbappé (Prizm Ouro)" fora da coleção,
  **quando** o cliente seleciona "+ Adicionar carta", busca "mbappé", adiciona a carta e informa a quantidade 2, **então**
  a carta é gravada como `OWNED` com quantidade 2, o progresso do álbum sobe e a tela mostra a mensagem de sucesso.
- **CA2** (R8) — **Dado** uma carta já no portfólio com quantidade 1, **quando** o cliente a encontra na busca, **então** a
  tela informa que ela já existe e oferece atualizar a quantidade; **quando** ele atualiza para 3, **então** a quantidade
  gravada passa a 3, sem outro registro.
- **CA3** (R9) — **Dado** um termo sem nenhuma carta no catálogo, **quando** o cliente busca, **então** vê a oferta
  "Solicitar cadastro da carta", que abre o formulário da CCD023.
- **CA4** (R10) — **Dado** uma carta removida antes da coleção, **quando** o cliente a adiciona com quantidade 1, **então** o
  registro antigo é restaurado como `OWNED` com quantidade 1.
- **CA5** (R5) — **Dado** a quantidade 0 ou negativa, **quando** o cliente confirma, **então** a tela recusa o valor e a API
  responde `422`.
- **CA6** (R1) — **Dado** um visitante sem login, **quando** chama a rota de adicionar ao portfólio, **então** recebe `401`.
- **CA7** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-23696`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no botão "+ Adicionar carta" e na barra de progresso; e em 375, 768 e 1024 px o mesmo
  design se adapta sem quebra, corte nem rolagem horizontal.
- **CA8** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-28449`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem
  horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `collection_cards` | `collection_id`, `card_id`, `status` (`OWNED`), `quantity`, `deleted_at` | `quantity` obrigatória, default 1; único por (`collection_id`, `card_id`), restaura ao re-adicionar (ADR-015) |
| `cards` | `name`, `number`, `album_id`, `front_image_url`, `status`, `deleted_at` | `album_id` nulo = "carta avulsa / portfólio" (L1) |
| `albums` | `title` | coleção da carta |
| `user_albums` | `collection_id`, `album_id`, `progress_percentage` | progresso recalculado (R7) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - detalhe do álbum ("+ Adicionar carta") | [1160-23696](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23696) | R2, R7 | ✅ Bate |
| Álbuns - adicionar carta | [1160-28449](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-28449) | R3, R4, R5, R8, R9 | ❌ Não bate: botão "Adicionar" sem quantidade (L3, L4); carta já existente sem opção de atualizar (L5); link de solicitar sempre visível (L7) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): modal — o FP 4 pede "Adicionar ao Portfólio" e a
  quantidade; o Figma tem só "Adicionar" (L3, L4). O FA 1 pede oferecer atualizar a quantidade; o Figma mostra "JÁ ESTÁ NA
  COLEÇÃO" sem ação (L5). O FA 2 oferece solicitar quando a carta não é encontrada; o Figma mostra o link sempre (L7).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): nenhum.
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R5 o campo de quantidade; R7 a mensagem de sucesso
  (L6); R8 a opção de atualizar a quantidade; a "tela Cadastro de Carta" do FP 1 (L2).

## Fora do escopo

- Escanear a carta por imagem ou código (FP 2) — fase Futuro ("Escanear Carta ou Código", `**`).
- O formulário de solicitar a carta — CCD023.
- Mudar a quantidade na grade do álbum — CCD017.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | "Portfólio" é a coleção inteira (`collection_cards`) ou só as cartas avulsas (`cards.album_id` nulo, "carta avulsa / portfólio" no DBML)? A story fala em "cartas soltas", mas a Pré-condição exige um álbum e o FP 6 recalcula o progresso do álbum | pendente | — |
| L2 | O FP 1 cita a "tela Cadastro de Carta", que não existe no Figma nem em outro caso de uso. Tirar do caso de uso ou desenhar a tela? | pendente | — |
| L3 | A CCD022 faz a mesma ação com quantidade 1 e incremento automático; a CCD036 pede a quantidade e oferece atualizar. Qual regra vale? Juntar as duas numa spec só (decisão do usuário)? | pendente | — |
| L4 | Onde o cliente informa a quantidade, se o modal só tem "Adicionar"? E o botão diz "Adicionar" (Figma) ou "Adicionar ao Portfólio" (FP 4)? | pendente | — |
| L5 | Carta já no portfólio: o Figma mostra "JÁ ESTÁ NA COLEÇÃO" sem ação; o FA 1 oferece atualizar a quantidade. Como fica o controle? | pendente | — |
| L6 | Texto e forma da mensagem de sucesso (FP 6), que o Figma não desenha | pendente | — |
| L7 | O link "Solicitar cadastro da carta →" aparece sempre (Figma) ou só quando a busca não encontra nada (FA 2)? | pendente | — |
| L8 | Adicionar uma carta de outro álbum (o modal mostra "Copa do Mundo 2022 • Nº 21") põe esse álbum na coleção? (mesma pergunta da L5 da CCD022) | pendente | — |
| L9 | "Cliente" são os papéis `CUSTOMER` e `SELLER`? E o `ADMIN`? (proposta: `CUSTOMER` e `SELLER`; `ADMIN` recebe `403`, como na CCD103, L8) | pendente | — |
