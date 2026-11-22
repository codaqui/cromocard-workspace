# CCD079 — Visualizar Quantidade Disponível

- **Status:** Rascunho
- **Fase:** MVP (fatia mínima do marketplace, ADR-027; a user story perdeu a marca `***` em 18/11/2026)
- **User story:** não encontrada no board
- **Caso de uso:** [79-visualizar-quantidade-disponivel.md](../../docs/Casos-De-Uso/79-visualizar-quantidade-disponivel.md)
- **Atores:** Visitante, Cliente · **Pré-condições:** o ator está no detalhe de um anúncio
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar a quantidade disponível para saber quantas unidades podem ser adquiridas.

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
| R1 | O detalhe do anúncio abre sem login, para o visitante e para o cliente; o cliente logado vê a mesma tela, com o menu da Área do Cliente | Permissão | `79-visualizar-quantidade-disponivel.md`, Atores; Figma `1122-18861` |
| R2 | O sistema busca a quantidade disponível da carta no anúncio (`listings.available_quantity`) | Regra | `79`, FP 2; DBML `listings.available_quantity` |
| R3 | O bloco de compra mostra a quantidade disponível com o rótulo "Disponível", ao lado de "Preço" e "Condição" | Campo | `79`, FP 3; Figma `1112-5772` |
| R4 | Com quantidade zero ou anúncio pausado (`listing_status = PAUSED`), a tela mostra o botão "Indisponível" (desabilitado) no lugar de "Comprar" | Regra | `79`, FA 1; `72-comprar.md`, FA 3; Figma `1112-6152` |
| R5 | No estado indisponível, a tela mostra o aviso "Este anúncio está esgotado ou pausado pelo vendedor. Veja os outros anúncios desta carta abaixo." no lugar do texto sobre o pagamento retido | Mensagem | `79`, FA 1; Figma `1112-6152` |
| R6 | No estado indisponível, a tela mostra os outros anúncios da mesma carta ("Outros anúncios desta carta (<n>)"), cada um com vendedor, condição, preço e "Ver anúncio" | Tela | `79`, FA 1; Figma `1112-6152` |
| R7 | Enquanto carrega, a tela mostra o estado de carregamento; se a API falha, mostra a mensagem de erro que a API devolve | Estado | ADR-041 (erros e estado do servidor) |
| R8 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1112-5772`, `1112-6152`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R1–R3) — **Dado** um anúncio ativo com 3 unidades, **quando** um visitante sem login abre o detalhe dele,
  **então** a API responde `200` e a tela mostra "Disponível" com o número 3 ao lado de "Preço" e "Condição", e o botão
  "Comprar" habilitado.
- **CA2** (R1) — **Dado** um cliente logado, **quando** ele abre o mesmo anúncio, **então** vê a mesma tela, com o menu da
  Área do Cliente no lugar de "Entrar" e "Criar conta grátis".
- **CA3** (R4–R6) — **Dado** um anúncio ativo com `available_quantity = 0`, **quando** o ator abre o detalhe, **então** vê
  "Disponível" com 0, o botão "Indisponível" desabilitado no lugar de "Comprar", o aviso "Este anúncio está esgotado ou
  pausado pelo vendedor. Veja os outros anúncios desta carta abaixo." e a lista "Outros anúncios desta carta".
- **CA4** (R4–R6) — **Dado** um anúncio com `status = PAUSED` e quantidade maior que zero, **quando** o ator abre o
  detalhe, **então** vê o mesmo estado indisponível do CA3.
- **CA5** (R7) — **Dado** a API lenta, **quando** o ator abre o detalhe, **então** a tela mostra o carregamento; **dado** a
  API fora do ar, **então** a tela mostra a mensagem de erro, sem quebrar o layout.
- **CA6** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1112-5772` (Detalhe do anúncio), **então** não há diferença de layout,
  medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra,
  corte nem rolagem horizontal.
- **CA7** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1112-6152` (Detalhe do anúncio - indisponível), **então** não há diferença
  de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta
  sem quebra, corte nem rolagem horizontal.

- **CA8** (R8) — **Dado** cada tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame correspondente (`1122-18861`), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `listings` | `id`, `card_id`, `seller_id`, `condition_id`, `price`, `available_quantity`, `status` (`listing_status`: `ACTIVE`, `PAUSED`, `CLOSED`), `deleted_at` | `available_quantity` obrigatória, default `1`; `status` obrigatório, default `ACTIVE`; soft delete (ADR-015) |
| `card_conditions` | `name` | Nome da condição exibido ao lado da quantidade |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Detalhe do anúncio | [1112-5772](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-5772) | R1–R3, R8 | ✅ Bate |
| Público - Detalhe do anúncio - indisponível | [1112-6152](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-6152) | R4–R6, R8 | ✅ Bate |
| Referência - Marketplace (cliente logado) | [1122-18861](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1122-18861) | R1 | ✅ Bate (tela de referência: "O cliente logado usa o mesmo Explorar marketplace, perfil da carta e detalhe do anúncio da Área Pública") |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): nenhuma no que o caso de uso pede.
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): Detalhe do anúncio `1112-5772` — a lista
  "Outros anúncios desta carta (3)", com "Compare com os outros vendedores" e "Ordenar: Menor preço", aparece também no
  anúncio disponível; o caso de uso só a pede no estado indisponível (L4).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R7 carregando e erro; o estado sem outros
  anúncios da carta (L3); o anúncio encerrado ou excluído (L1).

## Fora do escopo

- Botão "Comprar" e o checkout — CCD072.
- "Favoritar" — CCD056 (Favoritar Carta).
- Fotos e miniaturas do anúncio — CCD074.
- Nome, cidade e estado do vendedor no anúncio — CCD080.
- Dados de identificação da carta (número, coleção, categoria, raridade, idioma) — CCD031.
- Texto "Pagamento retido pela CromoCard até você receber a carta. O frete (Correios ou Jadlog) é calculado no checkout." — CCD072.
- Pausar, reativar e repor estoque do anúncio — CCD087, CCD088 e CCD085.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O que a tela mostra para um anúncio encerrado (`CLOSED`) ou excluído (`deleted_at` preenchido)? O caso de uso só fala de quantidade zero e de pausado (proposta: encerrado mostra o mesmo estado indisponível; excluído responde `404` com "Anúncio não encontrado") | pendente | — |
| L2 | A quantidade reservada por um checkout em andamento (30 minutos, CCD072 FP 6) sai da quantidade exibida? (proposta: sim, a tela mostra só o que está livre para comprar) | pendente | — |
| L3 | Quais anúncios entram em "Outros anúncios desta carta" e o que a tela mostra se não houver nenhum? Não há frame para a lista vazia (proposta: só anúncios `ACTIVE` com quantidade maior que zero, de outros vendedores ou não, sem o atual, por menor preço; sem nenhum, a seção some) | pendente | — |
| L4 | O Figma mostra "Outros anúncios desta carta" também no anúncio disponível (`1112-5772`), com "Ordenar: Menor preço"; o caso de uso só pede a lista no estado indisponível. Faz sentido implementar no anúncio disponível? E a ordenação, é desta story? | pendente | — |
| L5 | O dono do anúncio vê o próprio anúncio com "Disponível"? A CCD072 (FA 3) diz que, no próprio anúncio, o botão "Comprar" não aparece, mas não há frame dessa versão (proposta: vê a quantidade e não vê "Comprar") | pendente | — |
