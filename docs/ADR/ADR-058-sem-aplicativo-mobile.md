# ADR-058 — Sem aplicativo mobile: o CromoCard é só web

- **Status:** Aceito (validado pelo PO em 07/11/2026)
- **Data:** 2026-10-31
- **Decisores:** Daniel Andrade (proposta e validação como PO)
- **Substitui:** ADR-023 (stack do aplicativo mobile: React Native)
- **Substitui parcialmente:** ADR-021 (o Aplicativo Mobile como terceira aplicação cliente) e ADR-038 (a linha
  "o Aplicativo Mobile continua sendo um app separado")

## Contexto

O C4 nível 2 (`docs/Diagramas/Diagramas-C4/02-containers.puml`) desenhava um **Aplicativo Mobile** em React
Native, com "as mesmas funcionalidades da web", consumindo a mesma API e o mesmo serviço de tempo real. O
ADR-021 o manteve como uma das três aplicações cliente, o ADR-023 propôs a stack React Native e o ADR-038, ao
juntar Web e BackOffice num SPA único, deixou o mobile como um app à parte.

O app mobile nunca teve repositório, código, tela no Figma nem Task no Azure: os dois apps do workspace são o
`cromocard-backend` e o `cromocard-frontend` (ADR-026). A equipe decidiu não fazer mais o aplicativo mobile.

## Decisão

1. **Não desenvolva aplicativo mobile** (nem React Native, nem nativo por plataforma). O CromoCard tem um único
   cliente: o SPA `cromocard-frontend` (ADR-038), com as áreas Pública, Cliente e BackOffice.
2. Quem usa celular acessa o CromoCard pelo navegador, no mesmo SPA.
3. Remova o container "Aplicativo Mobile" e as relações dele dos diagramas C4 (níveis 2 e 3) e da visão C4 do
   diagrama de atividades (`docs/Diagramas/Diagrama-Atividades/Diagrama_Atividades.c4`), e as menções ao mobile
   como cliente da plataforma no `CLAUDE.md`, nas rules e nos READMEs.
4. **Notificação push no celular fica fora do escopo.** As notificações são as da central dentro da plataforma
   (`notifications`) e, onde o caso de uso pede, o e-mail (CCD095, CCD101). Isso confirma o que o ADR-053
   (alternativa "Push no `channels`") e a spec da CCD101 (lacuna L1) já tinham decidido.

## Alternativas consideradas

- **Manter o app mobile como Futuro:** deixaria nos diagramas um container que ninguém vai construir, e o C4
  deixaria de descrever o sistema que existe.
- **PWA instalável:** daria ícone na tela inicial e, mais tarde, push pelo navegador, mas nenhum caso de uso pede
  isso hoje. Se for preciso, entra num ADR próprio, sem mudar a stack do frontend.

## Consequências

- Um cliente só para manter: não há paridade de funcionalidades entre web e mobile nem segunda codebase de UI.
- O SPA precisa funcionar no navegador do celular. O `index.html` já tem a meta `viewport`; o layout das telas
  segue o Figma, e a adaptação a telas pequenas é decidida tela a tela.
- O backend não muda: a API REST (ADR-011), a autenticação (ADR-005) e o Socket.IO (ADR-012) atendem o SPA. As
  menções ao mobile nos ADRs aceitos (ADR-005: refresh token no armazenamento seguro do app; ADR-007, ADR-008 e
  ADR-012: cliente React Native e reconexão no mobile; ADR-030: login único para Web, Mobile e BackOffice;
  ADR-043) ficam como registro histórico e não valem mais. Esses ADRs não são editados (`docs/ADR/README.md`).
- User stories que citavam "celular" ou "push" (CCD041 Silenciar Notificações de Grupo, CCD060 Disparar
  Notificação Global e "Configurar Alertas de Preço", Futuro) passam a falar das notificações da plataforma.
- Quando este ADR for aceito: o ADR-023 passa a `Substituído por ADR-058`, e as notas de substituição parcial
  do ADR-021 e do ADR-038 passam a citar também este ADR.

## Referências

- ADR-021, ADR-023, ADR-026, ADR-038, ADR-053
- `docs/Diagramas/Diagramas-C4/02-containers.puml`, `03-componentes.puml`
- `docs/Diagramas/Diagrama-Atividades/Diagrama_Atividades.c4`
- `specs/CCD101-segmentar-notificacao-global/spec.md` (lacuna L1)
