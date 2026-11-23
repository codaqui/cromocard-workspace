# Plano — CCD038 Acessibilidade

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

> **Fase MVP** desde 22/11/2026 (ADR-069).

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L9 pendentes)
- **Repositórios:** frontend (lido da branch `feature/336-remove-tipo-categoria`); backend só se a L6 pedir o banco
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Tudo no frontend. Um `AccessibilityProvider` guarda as três preferências (narrador, filtro de daltonismo e alto
contraste), aplica cada uma na hora como atributo no `<html>` (`data-contrast="high"`, `data-color-filter="<filtro>"`) e
as grava no navegador, para valerem nas próximas visitas (depende da L6). Os tokens de `styles/tokens.css` ganham as
variações de alto contraste e as cores dos selos de raridade por filtro. O narrador usa a síntese de voz do navegador
(`speechSynthesis`) e lê o nome acessível do elemento que recebe o foco (depende da L3). O bloco "Acessibilidade" é um
componente próprio, posto na página que a L1 decidir (até lá, Configurações, como diz o FP 1).

## Dependências

- **CCD051** — página de Configurações (`/configuracoes`, hoje "em construção") ou **CCD048** — página Perfil (frame
  `1160-37708`), onde o bloco entra (depende da L1).
- **ADR-042 / tokens** — `src/styles/tokens.css`, onde ficam as variações de cor.
- **Selos de raridade** — o componente `Badge` usado nas cartas, que passa a ler as cores por token.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| — | — | — | as preferências ficam no `localStorage` do navegador (depende da L6). Se a L6 pedir o perfil, o DBML não tem a coluna: PR de docs no DBML e ADR antes do código, e o plano ganha a rota |

## Regras

- **Padrão** (R2, R4): narrador desligado, filtro "Nenhum (Visão Padrão)", alto contraste desligado.
- **Independentes** (R3): cada preferência muda sem mexer nas outras.
- **Na hora** (R4, R5, depende da L9): aplicar ao mudar, sem botão de salvar e sem recarregar.
- **Filtros** (R4, depende da L4): "Nenhum (Visão Padrão)", "Protanopia", "Deuteranopia" e "Tritanopia", trocando as cores
  dos selos de raridade.
- **Narrador** (R6, depende da L3 e da L5): ao `focusin`, lê o nome acessível do elemento (`aria-label`, `<label>` ou o
  texto); para ao desligar (R7). Sem `speechSynthesis` no navegador, o controle aparece desabilitado.
- **Persistência** (R8): chave `cromocard.a11y` no `localStorage`, com `try/catch`; sem armazenamento, vale o padrão.
- **Quem usa** (R1, depende da L2): o cliente logado; o provider fica na raiz, para o visitante também, se a L2 aceitar.

## Contrato da API

Nenhuma rota (depende da L6).

## Frontend — `apps/cromocard-frontend`

Nova feature `src/features/accessibility/`, no modelo de `src/features/users/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `accessibility.types.ts` · `accessibility.labels.ts` | preferências e textos ("Acessibilidade", "Ajuste o tamanho do texto, o contraste e as animações.", "Filtro para Daltonismo", "Otimiza as cores dos selos de raridade (Holo, Secret, Ultra Rare).", "Modo de Alto Contraste", "Intensifica delineamento de bordas acrílicas", Narrador de Tela) | R1, R2, R4, R5 |
| `accessibility.storage.ts` + `.spec.ts` | ler e gravar no `localStorage` com `try/catch` | R8 |
| `contexts/AccessibilityProvider.tsx` + `.spec.tsx` · `hooks/useAccessibility.ts` | estado, atributos no `<html>` e persistência | R3–R5, R7, R8 |
| `screen-reader.ts` + `.spec.ts` | narrador com `speechSynthesis` no `focusin`; `cancel()` ao desligar | R6, R7 |
| `components/AccessibilitySettings/` | bloco com o narrador (sem frame, L3, no estilo do bloco), o select do filtro e o interruptor de alto contraste — frame `1160-37708` | R1–R5, R7, R9 |
| `src/styles/tokens.css` | `[data-contrast="high"]` e `[data-color-filter="…"]` com as cores, incluindo as dos selos de raridade | R4, R5 |
| `src/app/App.tsx` | envolve o app no `AccessibilityProvider` | R5, R8 |
| página de Configurações (CCD051) ou Perfil (CCD048) | mostra o `AccessibilitySettings` (depende da L1) | R1 |

- **Componentes reaproveitados de `src/components/`:** `Select`, `Checkbox` (interruptor), `FormField`, `Badge`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | padrão: narrador e alto contraste desligados, filtro "Nenhum (Visão Padrão)" | `AccessibilitySettings.spec.tsx` |
| CA2 | alto contraste: `data-contrast="high"` na hora, outras opções iguais | `AccessibilityProvider.spec.tsx` |
| CA3 | filtro: `data-color-filter` muda e o selo usa a cor do token | `AccessibilityProvider.spec.tsx` · `Badge.spec.tsx` |
| CA4 | narrador: foco num botão chama `speechSynthesis.speak` com o texto | `screen-reader.spec.ts` (com `speechSynthesis` falso) |
| CA5 | desligar tudo: atributos removidos e `cancel()` chamado | `AccessibilityProvider.spec.tsx` · `screen-reader.spec.ts` |
| CA6 | sair e entrar: alto contraste continua (lido do armazenamento) | `accessibility.storage.spec.ts` · `AccessibilityProvider.spec.tsx` |
| CA7 | print em 1280 px igual ao frame `1160-37708`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- As preferências ficam no navegador, e não no banco, porque o DBML não tem coluna e a FP 3–4 só pede que valham nas
  próximas visitas: é preferência local, não dado do usuário. O `localStorage` aqui não guarda credencial (o ADR-043 só
  proíbe o token). Se a L6 pedir que valham em qualquer aparelho, vira coluna nova no perfil, com PR de docs e ADR.
- O alto contraste e os filtros mudam tokens CSS por atributo no `<html>`, sem tema novo em cada componente: as telas que
  já usam os tokens mudam juntas.
- "Ajuste de Escala Tipográfica" e "Redução de Animações" (L7, L8) não entram: viram requisitos se o PO aceitar.
