# CCD074 — Visualizar Fotos

- **Status:** Rascunho
- **Fase:** MVP (fatia mínima do marketplace, ADR-027)
- **User story:** não encontrada no board
- **Caso de uso:** [74-visualizar-fotos.md](../../docs/Casos-De-Uso/74-visualizar-fotos.md)
- **Atores:** Visitante, Cliente · **Pré-condições:** visualizando o detalhe de um anúncio
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar fotos da carta para verificar visualmente o item antes da compra.

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
| R1 | As fotos do anúncio são públicas: visitante e cliente veem sem login | Permissão | `74`, Atores e Pré-condições |
| R2 | O detalhe do anúncio mostra a primeira foto do anúncio em destaque e as miniaturas das demais, até 4 fotos, na ordem de `listing_photos.sort_order` | Tela | `74`, FP 2; DBML `listing_photos` (L4) |
| R3 | Selecionar uma miniatura mostra aquela foto em destaque | Ação | `74`, FP 3–4 |
| R4 | Setas navegam entre as fotos | Ação | `74`, FP 3 (L1) |
| R5 | A foto em destaque tem a opção de ampliar | Ação | `74`, FP 4 (L1, L2) |
| R6 | Anúncio sem fotos mostra a imagem da carta no catálogo | Regra | `74`, FA 1 (L3) |
| R7 | Fotos excluídas (`listing_photos.deleted_at` preenchido) não aparecem | Regra | ADR-015, itens 1 e 5 |
| R8 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R1, R2) — **Dado** um anúncio com 3 fotos e um visitante sem login, **quando** ele abre o detalhe do anúncio, **então** vê a foto de `sort_order` mais baixo em destaque e as miniaturas das 3 fotos.
- **CA2** (R3) — **Dado** o detalhe aberto, **quando** o ator seleciona a terceira miniatura, **então** a terceira foto fica em destaque e a miniatura dela fica marcada.
- **CA3** (R4) — **Dado** a primeira foto em destaque, **quando** o ator usa a seta para a frente, **então** a segunda foto fica em destaque.
- **CA4** (R5) — **Dado** uma foto em destaque, **quando** o ator seleciona ampliar, **então** a foto abre ampliada e pode ser fechada.
- **CA5** (R6) — **Dado** um anúncio sem fotos, **quando** o detalhe abre, **então** a imagem da carta do catálogo aparece no lugar das fotos.
- **CA6** (R7) — **Dado** um anúncio com 2 fotos, uma excluída, **quando** o detalhe abre, **então** só a foto não excluída aparece.
- **CA7** (R2) — **Dado** uma foto que não carrega, **quando** o detalhe abre, **então** o espaço da foto continua com o tamanho do frame, sem quebrar o layout.
- **CA8** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-5772`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA9** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-6152`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `listing_photos` | `listing_id`, `url`, `sort_order`, `deleted_at` | `url` obrigatória; `sort_order` default 0 |
| `cards` | `front_image_url` | imagem do catálogo (L3) |
| `card_photos` | `url`, `sort_order` | outra fonte possível da imagem do catálogo (L3) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público — Detalhe do anúncio | [1112-5772](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-5772) | R2, R3 | ⚠️ Foto em destaque e uma miniatura; sem setas nem ampliar (L1) |
| Público — Detalhe do anúncio — indisponível | [1112-6152](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-6152) | R2, R3 | ⚠️ Igual ao anterior |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): o caso de uso pede setas e a opção de ampliar; o frame não desenha nenhum dos dois (L1). A miniatura do frame mostra uma imagem diferente da foto em destaque, que parece ser a arte da carta do catálogo (L3).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R4 as setas; R5 ampliar e a foto ampliada; R6 o anúncio sem fotos.

## Fora do escopo

- Preço, condição, quantidade, vendedor e "Comprar" — CCD079, CCD080 e CCD072; "Favoritar" — CCD056 (L3 de lá); outros anúncios da carta — CCD030.
- Enviar, trocar e ordenar as fotos — CCD084 e CCD085.
- As imagens do perfil da carta (frente, verso e detalhe) — CCD030.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Falta o desenho das setas, da opção de ampliar e da foto ampliada no detalhe do anúncio. Como ficam? As setas voltam da última para a primeira? | pendente | — |
| L2 | Ampliar a foto (FP 4) também é a user story "Ampliar Carta" (`**`, fase Futuro). Entra agora, com esta story, ou fica para a fase Futuro? | pendente | — |
| L3 | Qual é a "imagem da carta no catálogo": `cards.front_image_url` ou `card_photos`? A miniatura do frame mistura a imagem do catálogo com as fotos do anúncio, ou é uma foto do anúncio? | pendente | — |
| L4 | Anúncio com mais de 4 fotos gravadas (o limite é de quem cria o anúncio, CCD084): mostra as 4 primeiras? | pendente | — |
