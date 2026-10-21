# ADR-021 — Separação das aplicações cliente por plataforma (Web, Mobile, BackOffice)

- **Status:** Substituído parcialmente por ADR-038 (Web e BackOffice viram um único SPA; o mobile continua separado)
- **Data:** 2026-09-29
- **Decisores:** Equipe CromoCard

## Contexto

O Diagrama de Containers (`docs/Diagramas/Diagramas-C4/02-containers.puml`) define três
aplicações cliente distintas, todas consumindo a mesma API REST:

- **Aplicação Web** (React + Vite) — visitantes e clientes.
- **Aplicativo Mobile** (React Native) — visitantes e clientes, "mesmas funcionalidades da web".
- **Painel BackOffice** (React + Vite) — exclusivo para administradores.

Essa separação já está desenhada no C4, mas não há um registro do motivo da escolha nem das
alternativas descartadas.

## Decisão

Manter três aplicações cliente independentes (codebases separadas), cada uma como um SPA/app
próprio, todas consumindo a mesma API de Aplicação via REST/JSON.

## Alternativas consideradas

- **SPA único responsivo** (com PWA) cobrindo web e mobile, sem app nativo.
- **BackOffice como módulo** dentro do mesmo SPA do cliente, com rotas protegidas por papel
  (`role = ADMIN`).

## Consequências

**Positivas**
- Experiência nativa no mobile (React Native) e UI otimizada por público.
- Isolamento de risco e deploy: um incidente ou release do BackOffice não afeta o app do cliente.

**Negativas / riscos**
- Três codebases de frontend para manter em paridade funcional.
- Lógica de UI duplicada entre Web e Mobile (React e React Native não compartilham componentes
  de tela diretamente).
- Exige disciplina para manter contratos de API únicos servindo os três clientes.

## Referências

- `docs/Diagramas/Diagramas-C4/02-containers.puml`
- `CLAUDE.md` (seção "Arquitetura (C4)")
