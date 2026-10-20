# ADR-044 — Estilos: CSS Modules + design tokens, sem biblioteca de componentes

- **Status:** Aceito
- **Data:** 2026-10-17
- **Decisores:** Equipe CromoCard

## Contexto

O visual do CromoCard vem do protótipo no Figma, feito pela equipe a partir da documentação. É
preciso escolher como escrever os estilos de forma que o código siga o Figma, que uma mudança de
cor ou espaçamento seja feita num lugar só e que estilos de um componente não vazem para outro.

## Decisão

- **CSS Modules:** cada componente tem seu `<Componente>.module.css` ao lado do `.tsx`, com classes
  locais. Para combinar classes, use `cn()` (`src/utils/cn.ts`).
- **Design tokens** como CSS custom properties em `src/styles/tokens.css`: cores, fonte, tamanhos de
  texto, espaçamentos, raios e sombras. O `reset.css`, o `tokens.css` e o `globals.css` são
  importados uma vez, no `main.tsx`.
- Os componentes usam **só tokens** (`var(--color-primary)`, `var(--space-4)`), nunca valores soltos
  de cor, fonte ou espaçamento.
- **Sem biblioteca de componentes** (MUI, Chakra, shadcn/ui) e sem Tailwind. Os componentes base
  ficam em `src/components/`, com variantes por prop (ex.: `Button variant="primary"`,
  `"secondary"` ou `"danger"`).
- Os tokens seguem as variáveis do Figma: quando o protótipo fechar a identidade visual, os valores
  do `tokens.css` passam a ser os do Figma, e os componentes não precisam mudar.

## Alternativas consideradas

- **Tailwind CSS:** produtivo, mas mistura estilo e marcação, e a equipe teria de aprender as
  convenções das classes utilitárias.
- **MUI ou Chakra UI:** trazem um visual pronto que brigaria com o Figma, e a customização para
  chegar no protótipo seria trabalhosa.
- **CSS-in-JS (styled-components, Emotion):** custo em tempo de execução, e o styled-components
  está em modo de manutenção.

## Consequências

- Mais CSS escrito à mão, mas cada estilo fica junto do seu componente, e o visual é todo do
  projeto.
- A acessibilidade dos componentes base (foco visível, `label` nos campos, contraste) é
  responsabilidade da equipe, porque nenhuma biblioteca a traz pronta.
- Componente novo do Figma vira uma pasta em `src/components/` (se for genérico) ou em
  `features/<feature>/components/` (se conhecer o domínio), conforme o ADR-040.

## Referências

- ADR-040
- `apps/cromocard-frontend/src/styles/tokens.css`, `src/components/`
- Protótipo: https://www.figma.com/design/43K7rTPJQNIOroQ4j09YTP
