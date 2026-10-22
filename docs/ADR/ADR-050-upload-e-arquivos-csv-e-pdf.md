# ADR-050 — Upload de imagens e arquivos CSV e PDF: `multer`, `csv-parse` e `pdfkit`

- **Status:** Aceito (validado pelo PO em 22/10/2026)
- **Data:** 2026-10-22
- **Decisores:** Daniel Andrade (PO), equipe CromoCard

## Contexto

As specs do Painel Administrador aprovadas em 22/10/2026 precisam de três tratamentos de arquivo que o esqueleto do
backend não tem:

- **upload de imagem** (`POST /api/v1/uploads`, plano da fundação do BackOffice): imagens de carta, capa de álbum e
  banner da Home, enviadas como `multipart/form-data` e guardadas pelo `StorageProvider` (ADR-009);
- **importar cartas por CSV** (CCD061, `61` FP 10–11);
- **exportar relatórios em CSV e PDF** (CCD063, `63` FP 6–9).

O Express 5 não lê `multipart/form-data`, e nenhum ADR escolhe biblioteca para CSV ou PDF.

## Decisão

1. Use **`multer`** com armazenamento em memória (`memoryStorage`) só na rota de upload, com limite de tamanho e de
   tipo (PNG, JPG ou WEBP, até 4 MB). O arquivo vai direto para o `StorageProvider`; o banco guarda a URL.
2. Use **`csv-parse`** (modo síncrono, `columns: true`, delimitador `;`) para ler o CSV de importação.
3. Gere o **CSV de exportação sem biblioteca**: UTF-8 com BOM, delimitador `;` e aspas duplas onde precisar, num
   `csv.exporter.ts` testado.
4. Use **`pdfkit`** para o PDF dos relatórios: cabeçalho com o título, o período e a data de geração, e a tabela dos
   dados, sem gráfico.

## Alternativas consideradas

- **`busboy` direto:** mais leve que o `multer`, mas exige montar o stream e os limites à mão.
- **`papaparse`:** funciona no navegador e no Node, mas o parse acontece no backend e o `csv-parse` é a opção nativa
  do ecossistema Node.
- **PDF por HTML (Puppeteer/Playwright):** permite usar CSS, mas sobe um Chromium na API, pesado para a imagem Docker.
- **`pdfmake`:** API declarativa boa, mas maior que o `pdfkit`, que já resolve cabeçalho e tabela.

## Consequências

- `package.json` do backend ganha `multer`, `csv-parse` e `pdfkit` (e os `@types` de `multer` e `pdfkit`).
- O limite de 4 MB fica na rota de upload; arquivos maiores respondem `413` com o envelope do ADR-011.
- O CSV de exportação abre no Excel em pt-BR por causa do BOM e do `;`.

## Referências

- ADR-009 (providers, storage), ADR-011 (envelope de erro)
- `specs/fundacao-backoffice/plano.md`, `specs/CCD061-gestao-de-catalogo/plano.md`,
  `specs/CCD063-exportar-relatorios-gerenciais/plano.md`
