# ADR-070 — Fidelidade ao Figma obrigatória na spec

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-11-22
- **Decisores:** Daniel Andrade (proposta, no PR #51); validação: Felipe Consulim (PO)
- **Complementa:** ADR-060 (itens 1 e 5)

## Contexto

O ADR-060 pede a maior fidelidade possível ao Figma e a validação de cada tela no navegador, mas a fidelidade não aparecia
na spec: nenhum requisito nem critério de aceite dizia que a tela tem que ficar igual ao frame. No PR #51, que cria as
specs das user stories que ainda não tinham uma, o modelo da spec (`specs/template/spec.md`) e a regra
`.claude/rules/specs.md` passaram a exigir a seção **Fidelidade ao Figma (obrigatória)**. A mudança é de processo e vale
para toda spec, por isso fica registrada aqui.

## Decisão

1. **Seção obrigatória.** Toda spec tem a seção **Fidelidade ao Figma (obrigatória)**, copiada do modelo. Os frames da
   seção **Telas** são o contrato visual da user story: layout, medidas, espaçamentos, cores, tipografia, ícones, imagens,
   textos e estados seguem o frame.
2. **Requisito e critério de aceite.** Toda spec tem um requisito do tipo `Fidelidade` e um critério de aceite de
   fidelidade para cada frame desenhado: o print da tela em 1280 px, lado a lado com o print do frame, não mostra
   diferença, e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
3. **Documentação continua a fonte principal.** Diferença entre o Figma e a documentação vira lacuna e é decidida antes do
   código, como no item 1 do ADR-060. Até a decisão, vale a documentação.
4. **Tela sem frame.** A spec diz isso em **Telas**, abre uma lacuna pedindo o desenho e segue o estilo da própria tela. O
   requisito de fidelidade vale quando o frame existir.

## Alternativas consideradas

- **Deixar a fidelidade só na revisão (`/cromocard-revisor`):** a exigência ficaria fora da spec, e quem desenvolve só
  descobriria na revisão o que precisava ser igual.
- **Seguir sempre o Figma, sem lacuna:** a documentação deixaria de ser a referência do projeto, o que o ADR-060 já
  recusou.

## Consequências

- Cada spec ganha um requisito e um critério de aceite por frame, e a tela só fica pronta com a comparação lado a lado.
- As 72 specs do PR #51 já seguem o modelo. As specs anteriores ganham a seção quando forem revistas.
- As larguras do critério de aceite (375, 768, 1024 e 1280 px) não são as mesmas da referência de responsividade das
  skills `/cromocard-desenvolver` e `/cromocard-revisor`. É preciso alinhar as duas listas.
- Se o PO recusar este ADR, o modelo e a regra voltam à versão anterior, e a seção sai das specs que ainda estiverem em
  `Rascunho`.

## Referências

- ADR-047, ADR-060
- `specs/template/spec.md`, `.claude/rules/specs.md`
- PR #51 do workspace
