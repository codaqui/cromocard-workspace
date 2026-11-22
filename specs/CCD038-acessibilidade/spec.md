# CCD038 — Acessibilidade

- **Status:** Rascunho
- **Fase:** Futuro
- **User story:** #141 `CCD038 - Acessibilidade`
- **Caso de uso:** [38-acessibilidade.md](../../docs/Casos-De-Uso/38-acessibilidade.md)
- **Atores:** Cliente · **Pré-condições:** o cliente navega na plataforma e acessa as configurações de acessibilidade
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso ativar recursos como narrador de tela, modo daltonismo e alto contraste para conseguir navegar, ouvir e visualizar as informações da plataforma com clareza.

A narrativa não está nas tabelas de `user-stories.md`: vem da Finalidade do caso de uso. A fase vem da linha "** - Futuro"
das Observações de `user-stories.md` ("Acessibilidade narrador, daltonismo, alto contraste"); o `CLAUDE.md` também cita
"acessibilidade avançada" como Futuro.

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

> **Fase Futuro** (`**` nas Observações de `user-stories.md`): esta spec existe para deixar a story pronta, mas não entra no
> MVP sem o PO puxá-la para uma sprint.

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | O bloco "Acessibilidade" ("Ajuste o tamanho do texto, o contraste e as animações.") fica nas configurações da conta do cliente | Tela | `38`, FP 1; Figma `1160-37708` (L1, L2) |
| R2 | O bloco oferece Narrador de Tela, Modo Daltonismo ("Filtro para Daltonismo") e Alto Contraste ("Modo de Alto Contraste") | Campo | `38`, FP 2; Figma `1160-37708` (L3) |
| R3 | O cliente ativa cada recurso de forma independente | Ação | `38`, FP 3 |
| R4 | "Filtro para Daltonismo" ("Otimiza as cores dos selos de raridade (Holo, Secret, Ultra Rare).") começa em "Nenhum (Visão Padrão)" e, escolhido um filtro, troca as cores da interface na hora | Regra | `38`, FP 4; Figma `1160-37708` (L4) |
| R5 | "Modo de Alto Contraste" ("Intensifica delineamento de bordas acrílicas") liga e desliga o contraste alto na hora, em todas as telas | Regra | `38`, FP 4; Figma `1160-37708` |
| R6 | Com o Narrador de Tela ligado, o texto do elemento focado é lido em voz alta | Regra | `38`, FP 5 (L3, L5) |
| R7 | Desativar todos os recursos volta ao tema visual padrão e encerra o narrador | Ação | `38`, FA 1–2 |
| R8 | As escolhas continuam valendo nas próximas visitas do cliente | Regra | `38`, FP 3–4 (L6) |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frame `1160-37708`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R1, R2) — **Dado** o cliente logado, **quando** abre o bloco "Acessibilidade", **então** vê Narrador de Tela,
  "Filtro para Daltonismo" em "Nenhum (Visão Padrão)" e "Modo de Alto Contraste" desligado.
- **CA2** (R3, R5) — **Dado** o alto contraste desligado, **quando** o cliente o liga, **então** a interface passa ao
  contraste alto sem recarregar, e as outras opções não mudam.
- **CA3** (R4) — **Dado** o filtro em "Nenhum (Visão Padrão)", **quando** o cliente escolhe um filtro de daltonismo,
  **então** as cores dos selos de raridade mudam na hora.
- **CA4** (R6) — **Dado** o narrador ligado, **quando** o cliente move o foco pelo teclado até um botão, **então** o texto do
  botão é lido em voz alta.
- **CA5** (R7) — **Dado** os três recursos ligados, **quando** o cliente desliga todos, **então** a interface volta ao tema
  padrão e o narrador para de falar.
- **CA6** (R8) — **Dado** o alto contraste ligado, **quando** o cliente sai e entra de novo, **então** o alto contraste
  continua ligado.
- **CA7** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-37708`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no bloco "Acessibilidade"; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra,
  corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| — | — | O DBML não tem onde guardar as preferências de acessibilidade (`profiles` só tem `bio`, `avatar_url`, `city` e `portfolio_privacy`) (L6) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Perfil - meu perfil — bloco "Acessibilidade" | [1160-37708](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-37708) | R1–R5, R7 | ❌ Não bate: fica em Perfil, não em Configurações (L1); sem Narrador de Tela (L3); escala tipográfica e redução de animações só no Figma (L7, L8) |

- Os outros frames de Perfil (`1160-38269`, `1160-38711`, `1160-39158`, `1160-39672`, `1160-40220`, `1160-40789`) repetem o
  bloco igual; os estados deles são da CCD048.
- **Diferenças com o Figma** (decisão em Lacunas e decisões): o FP 1 põe "Acessibilidade" no menu de configurações; o
  Figma põe o bloco na página Perfil (3.10), não em Configurações (3.11, `1160-41305`) (L1). O FP 2 pede Narrador de Tela,
  que o Figma não tem (L3).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Ajuste de Escala Tipográfica" ("Pequeno
  (85%)", "Padrão (100%)", "Grande (115%)", "Extra Grande (130%)") (L7); "Redução de Animações" ("Desativa os efeitos
  animados das cartas.") (L8).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R2 e R6 o controle do Narrador de Tela (L3).

## Fora do escopo

- Editar os dados pessoais, a foto e os endereços na mesma página — CCD048 e CCD091.
- Acessibilidade básica que todas as telas já devem ter (teclado, foco visível, textos alternativos): é critério de
  qualidade do frontend, não desta story.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O FP 1 põe "Acessibilidade" no menu de configurações; o Figma põe o bloco na página Perfil. Onde fica? | pendente | — |
| L2 | A Pré-condição diz "navegando na plataforma": o visitante, sem login, também ativa os recursos? E o administrador no BackOffice? | pendente | — |
| L3 | O Figma não tem o Narrador de Tela do FP 2 e FP 5. Desenhar o controle? O narrador é próprio do site (síntese de voz do navegador) ou basta a compatibilidade com os leitores de tela do sistema (NVDA, VoiceOver)? | pendente | — |
| L4 | Quais filtros de daltonismo o select oferece além de "Nenhum (Visão Padrão)" (ex.: protanopia, deuteranopia, tritanopia)? E, como diz o texto do Figma, mudam só os selos de raridade ou a interface toda? | pendente | — |
| L5 | O que o narrador lê além do elemento focado (título da página, mensagens de erro e de sucesso)? | pendente | — |
| L6 | Onde guardar as preferências? O DBML não tem coluna: no navegador do cliente (vale só naquele aparelho) ou numa coluna nova do perfil (mudança no DER e ADR)? | pendente | — |
| L7 | "Ajuste de Escala Tipográfica" só existe no Figma: faz sentido implementar? | pendente | — |
| L8 | "Redução de Animações" só existe no Figma: faz sentido implementar? Também respeita a preferência do sistema operacional? | pendente | — |
| L9 | As mudanças valem na hora (FP 4, "imediatamente") ou só depois de "Salvar alterações", o botão do bloco de informações pessoais na mesma página? (proposta: na hora, sem botão) | pendente | — |
