# Tarefas — CCD038 Acessibilidade

- **Plano:** [plano.md](plano.md) · **User story:** AB#141
- **Fase MVP** desde 22/11/2026 (ADR-068).
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Só frontend (depende da L6). O lugar do bloco depende da L1 (CCD051 ou CCD048).

## Frontend — `apps/cromocard-frontend`, branch `feature/141-acessibilidade`

- [ ] **T1** · Criar tipos, textos e armazenamento das preferências de acessibilidade — R2, R8 · CA6 · AB# a criar
  - Pronto quando: `accessibility.storage.spec.ts` cobre gravar, ler e o armazenamento indisponível.
- [ ] **T2** · Criar provider de acessibilidade com alto contraste e filtro de daltonismo — R3–R5, R7, R8 · CA2, CA3, CA5, CA6 · AB# a criar
  - Pronto quando: `AccessibilityProvider.spec.tsx` cobre ligar, desligar e restaurar cada preferência, sem recarregar.
- [ ] **T3** · Criar tokens de alto contraste e de filtros de cor dos selos — R4, R5 · CA2, CA3 · AB# a criar
  - Pronto quando: os atributos mudam as cores das telas e dos selos de raridade, coberto em `Badge.spec.tsx`.
- [ ] **T4** [P] · Criar narrador de tela com síntese de voz do navegador — R6, R7 · CA4, CA5 · AB# a criar
  - Pronto quando: `screen-reader.spec.ts` cobre ler o elemento focado, parar ao desligar e o navegador sem suporte.
- [ ] **T5** · Criar bloco Acessibilidade nas configurações da conta — R1–R5, R7, R9 · CA1, CA7 · AB# a criar
  - Pronto quando: `AccessibilitySettings.spec.tsx` cobre o padrão e as mudanças; print em 1280 px igual ao frame `1160-37708` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T6** · Atualizar o ponteiro `apps/cromocard-frontend` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: o PR do frontend está mergeado em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T5 |
| R2 | T1, T5 |
| R3 | T2, T5 |
| R4, R5 | T2, T3, T5 |
| R6 | T4 |
| R7 | T2, T4, T5 |
| R8 | T1, T2 |
| R9 | T5 |
