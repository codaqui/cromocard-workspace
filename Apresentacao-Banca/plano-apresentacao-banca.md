# Plano de Geração dos Slides — 1ª Banca de TCC (CromoCard)

> **Para quem:** equipe CromoCard. **Não suba este arquivo no NotebookLM**; ele é o guia de trabalho.
> **Base da análise:** repositório `CROMOCARD-WORKSPACE`, branch `development`, commit `6d3d0bd`, lido em 25/09/2026.
> **Entregável final da task:** o slide pronto. Este documento é a etapa 1 (plano, validação e prompt).

---

## 1. Visão geral do fluxo

```
[1] Corrigir inconsistências (seção 3)      → artefatos validados
[2] Preencher os [PENDENTE] (seção 4)       → fonte completa
[3] Montar o notebook no NotebookLM (seção 6)
[4] Gerar com o prompt (seção 7)            → versão 1 do deck
[5] Revisar slide a slide (seção 8)         → exportar PPTX
[6] Inserir diagramas reais + checklist (seção 9) → deck final para a banca
```

Arquivos criados junto com este plano (pasta `Apresentacao-Banca/`):

| Arquivo | Função |
|---|---|
| `plano-apresentacao-banca.md` | Este guia (não vai para o NotebookLM) |
| `fonte-notebooklm-cromocard.md` | **Fonte principal do NotebookLM**: fatos validados + roteiro de 17 slides |

---

## 2. Inventário e validação dos artefatos

| Artefato | Caminho | Status | Uso no deck |
|---|---|---|---|
| 93 casos de uso (CCD001–CCD093) | `Casos-De-Uso/*.md` | ✅ Completo, com 7 ajustes (seção 3) | Slides 8, 10 |
| Planilha de casos de uso | `Casos-De-Uso/CromoCard 1.xlsx` | ✅ Fonte mestre da numeração CCD | Referência |
| User stories (111) | `Casos-De-Uso/user-stories.md` e `resumo-user-stories.md` | ✅ Arquivos idênticos no conteúdo | Slide 9 |
| C4 níveis 1, 2 e 3 | `Diagramas-C4/*.puml` + `.svg` | ✅ Completo, 1 ajuste (ator Vendedor) | Slides 11–13 |
| DER (43 tabelas, 76 FKs, 22 enums) | `DER/` (PlantUML, DBML, SQL) | ✅ Completo e com rastreabilidade | Slide 14 |
| Organização do board | `Azure-Devops/organizacao-board-cromocard.md` | ⚠️ Desatualizado (28/08; cita planilha só até CCD066) | Slide 7 |
| Visualização do board | `Azure-Devops/board-cromocard.html` | ✅ | Opcional |
| Problema, justificativa, objetivos | — | ❌ Não existe no repositório | Slides 3, 4 |
| Pesquisa de mercado (#202) | só no Azure DevOps | ❌ Não está no repositório | Slide 6 |
| ADRs (#150) | só no Azure DevOps | ❌ Não está no repositório | Slide 16 (opcional 12) |
| Protótipos / wireframes | — | ❌ Não existe | Slide 15 |
| Requisitos não funcionais | — | ❌ Não existe | Opcional (slide extra) |
| Cronograma das próximas sprints | — | ❌ Não existe | Slide 16 |
| Referências bibliográficas | — | ❌ Não existe | Slide extra, se a banca exigir |

---

## 3. Inconsistências encontradas (corrigir antes de gerar)

| # | Onde | Problema | Correção sugerida |
|---|---|---|---|
| 1 | `10-buscar-album.md` | O nome do arquivo e o título dizem "Buscar Álbum", mas o conteúdo é **Solicitar Álbum** (CCD010 na planilha) | Renomear para `10-solicitar-album.md` e corrigir o título |
| 2 | `80-visualizar-quantidade-disponivel.md` | Duplica o nome do 79, mas o conteúdo é **Visualizar Dados do Vendedor** (CCD080 na planilha) | Renomear para `80-visualizar-dados-do-vendedor.md` e corrigir o título |
| 3 | `03-criar-conta.md` | Pré-condição ("barra de busca visível") e fluxo alternativo ("busca sem resultado") foram copiados do Buscar Global | Reescrever: e-mail já cadastrado, campos inválidos, termos não aceitos |
| 4 | `01`, `30`, `31` | Sem fluxo alternativo | Preencher ou escrever "Não se aplica" |
| 5 | `31` × `30` | "Visualizar Informações da Carta" é duplicata de "Visualizar Detalhes" (a própria planilha marca "duplicado") | Decidir: remover o CCD031 ou manter e justificar |
| 6 | `33` × `67` | Dois casos "Buscar por Vendedor" | Manter um só (o 67, no bloco Marketplace) ou diferenciar |
| 7 | Atores | Os casos de uso usam 5 nomes (Visitante, Cliente, **Usuário**, Vendedor, Administrador); o C4 tem só 3 pessoas (não tem **Vendedor**); o DER tem CLIENTE/VENDEDOR/ADMINISTRADOR | Padronizar "Usuário" → "Cliente" (45–57) e incluir **Vendedor** no C4 Nível 1 e 2 |
| 8 | Escopo do Marketplace | As user stories marcam o Marketplace comprador como `***` (futuro), mas o Painel do Vendedor (10 US) não tem marcador, e o C4 já traz gateway e transportadora | **Decisão da equipe:** o marketplace entra no MVP ou não? A resposta muda os slides 9, 12 e 16 |
| 9 | `organizacao-board-cromocard.md` | Datado de 28/08, fala em Sprint 02 como atual e em CCD045–066 "faltando" | Atualizar ou não usar como fonte |

> **Por que isso importa na banca:** a banca costuma cruzar números entre slides. Se o slide 8 diz 93 casos
> de uso e o repositório tem dois arquivos com o mesmo nome, ou o C4 não mostra o Vendedor que aparece no
> slide 5, isso vira pergunta.

---

## 4. Pendências a preencher (checklist)

Substituir cada [PENDENTE] em `fonte-notebooklm-cromocard.md` **antes** de subir no NotebookLM:

- [ ] Instituição, curso, disciplina, orientador, integrantes, data (slides 1 e 17)
- [ ] Problema e justificativa com 1–2 dados reais da pesquisa de mercado (slide 3)
- [ ] Confirmar ou ajustar objetivo geral e específicos (slide 4)
- [ ] Pesquisa de mercado: 3–4 concorrentes e o diferencial do CromoCard (slide 6)
- [ ] Datas das sprints 03 em diante e marco da entrega final (slides 7 e 16)
- [ ] Decisão sobre o marketplace no MVP (item 8 da seção 3)
- [ ] Protótipos: pelo menos 3 telas (Home, Álbum, Marketplace) exportadas em PNG (slide 15)
- [ ] ADRs principais (ex.: por que Node/Prisma, PostgreSQL, SPA único sem app mobile — ADR-038 e ADR-058) — opcional, fortalece o slide 12
- [ ] Modelo institucional de slides e tempo exato da banca (confirmar com o orientador)

Se algum item não ficar pronto a tempo, o slide sai com **[PENDENTE]** visível. Na banca, é melhor mostrar
"em andamento" do que inventar.

---

## 5. Padrão de entrega da banca

**Estrutura:** segue o padrão acadêmico de TCC em TI: identificação → problema → objetivos → metodologia →
escopo/requisitos → arquitetura → dados → status/próximos passos → encerramento.

**Matriz de cobertura (cada item do escopo aparece em pelo menos um slide):**

| Item do escopo | Slide(s) | Fonte validada |
|---|---|---|
| Identificação do trabalho | 1, 17 | [PENDENTE] |
| Problema e justificativa | 3 | [PENDENTE] / Pesquisa #202 |
| Objetivos | 4 | C4 Contexto |
| Atores | 5 | Casos de uso + DER (enum tipo_usuario) |
| Mercado e concorrentes | 6 | [PENDENTE] |
| Metodologia e gestão | 7 | Board Azure DevOps |
| Requisitos funcionais (93 UC, 9 módulos) | 8, 10 | `Casos-De-Uso/` + planilha |
| Priorização MVP × futuro | 9 | `user-stories.md` |
| Arquitetura (C4 1, 2, 3) | 11, 12, 13 | `Diagramas-C4/` |
| Tecnologias | 12 | C4 Nível 2 |
| Modelo de dados | 14 | `DER/` |
| Interfaces | 15 | Board (28 telas) + protótipos [PENDENTE] |
| Status, cronograma, próximos passos | 16 | Board + [PENDENTE] |

**Regras visuais e de conteúdo:**

- 17 slides para **15 a 20 minutos** (cerca de 1 minuto por slide; ajuste quando souber o tempo exato).
- Título de cada slide como afirmação ("93 casos de uso em 9 módulos"), não como rótulo ("Casos de uso").
- No máximo 4 tópicos por slide, até 12 palavras cada. O detalhe vai na fala, não no slide.
- Números iguais em todos os slides: **93** casos de uso, **111** user stories (76/16/19), **9** módulos,
  **43** tabelas, **8** módulos de dados, **28** telas.
- Diagramas C4 e DER **reais**, inseridos depois da exportação (o NotebookLM desenha ilustrações próprias,
  que não servem como diagrama técnico).
- Numeração de página e rodapé com o nome do projeto (conferir se a instituição exige o modelo dela).

---

## 6. Montagem do notebook no NotebookLM

1. Crie um notebook novo só para esta apresentação (um tema por notebook).
2. Suba como fontes:

   | Fonte | Obrigatória? | Observação |
   |---|---|---|
   | `fonte-notebooklm-cromocard.md` | ✅ Sim | Fonte principal, já traz o roteiro |
   | `Casos-De-Uso/resumo-user-stories.md` | Recomendada | Dá contexto às narrativas |
   | `DER/README.md` | Recomendada | Rastreabilidade entidade → caso de uso |
   | Documento de pesquisa de mercado | Quando existir | Alimenta os slides 3 e 6 |
   | PNGs das telas / protótipos | Quando existirem | O NotebookLM aceita PNG/JPG, **não aceita SVG** |

3. **Não subir:** este plano, `organizacao-board-cromocard.md` (desatualizado e com críticas ao board),
   `user-stories.md` (duplica o resumo), arquivos `.sql`, `.dbml`, `.puml` e os SVGs.
4. No painel **Studio**, clique no lápis ao lado de **Slide Deck** para abrir a personalização.
5. Configure: formato **Presenter Slides**, idioma **Português**, tamanho **Padrão**.
   Se a banca pedir material impresso ou para leitura, gere uma segunda versão em **Detailed Deck**.
6. Cole o prompt da seção 7 e gere. A geração pode levar alguns minutos.

---

## 7. Prompt de geração (copiar e colar)

Mantido curto de propósito: prompts longos demais fazem o NotebookLM ignorar as instruções finais.
O detalhe está na fonte, e o prompt manda segui-la.

```
Crie a apresentação da primeira banca de TCC do projeto CromoCard com exatamente 17 slides, seguindo a seção "3. Roteiro slide a slide" da fonte "fonte-notebooklm-cromocard", na mesma ordem e com os mesmos títulos.

Público: banca avaliadora acadêmica de TI. Tom formal e objetivo, em português do Brasil.

Regras:
- No máximo 4 tópicos por slide, com até 12 palavras cada.
- Use apenas nomes e números que estão nas fontes. Não invente dados, métricas, datas, concorrentes ou nomes de pessoas.
- Onde a fonte trouxer [PENDENTE], escreva [PENDENTE] no slide.
- Nos slides 11, 12, 13 e 14, reserve metade do slide para o diagrama e escreva "Diagrama inserido na versão final". Não desenhe diagramas.
- Visual limpo e acadêmico: fundo claro, uma cor de destaque, sem clip-art.
```

---

## 8. Revisão slide a slide

Depois da primeira geração:

1. **Exporte o PPTX antes de revisar.** Cada revisão gera um deck novo e não há histórico de versões.
2. Abra o deck → **Revise** → escreva instruções nos slides que precisam de ajuste → **Generate revised deck**.
   Junte todas as correções numa só rodada, porque há cota de revisões.
3. Atenção: na revisão o NotebookLM **não consulta as fontes**. Se um número estiver errado, escreva o valor
   correto na própria instrução.

Instruções de revisão prontas:

| Situação | Texto para colar no slide |
|---|---|
| Número errado | `Corrija para: 93 casos de uso, 9 módulos, 111 user stories (76 MVP, 16 futuro, 19 futuro marketplace).` |
| Texto demais | `Reduza para no máximo 4 tópicos de até 12 palavras. Mantenha o título.` |
| Dado inventado | `Remova qualquer informação que não esteja no roteiro. Use [PENDENTE] no lugar.` |
| Diagrama desenhado pela IA | `Remova o desenho. Deixe metade do slide em branco com o texto "Diagrama inserido na versão final".` |
| Título genérico | `Troque o título por: "<título da seção 3 da fonte>".` |

---

## 9. Finalização e checklist de qualidade

**No PowerPoint (ou Google Slides, importando o PPTX):**

1. Insira os diagramas reais convertidos para PNG:
   - Slide 11: `Diagramas-C4/diagrama_C4_1.svg`
   - Slide 12: `Diagramas-C4/diagrama_c4_2.svg`
   - Slide 13: `Diagramas-C4/diagrama_C4_3.svg`
   - Slide 14: `DER/02-diagrama-relacionamentos.png` (a visão só com chaves é a mais legível projetada)
2. Aplique o modelo institucional, se houver.
3. Escreva as notas do apresentador e divida os slides entre os integrantes.

**Checklist antes da banca:**

- [ ] Nenhum [PENDENTE] sobrou no deck final
- [ ] Os números batem entre slides e com o repositório (93 / 111 / 9 / 43 / 8 / 28)
- [ ] Os diagramas estão legíveis quando projetados (teste em tela cheia)
- [ ] Os 4 atores aparecem de forma igual nos slides 5, 11 e 12
- [ ] A decisão sobre o marketplace no MVP está coerente nos slides 9, 12 e 16
- [ ] Ensaio cronometrado cabe no tempo da banca
- [ ] PPTX e PDF salvos na pasta `Apresentacao-Banca/` e versionados no GitHub
