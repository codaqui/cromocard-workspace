# Fidelidade ao Figma e responsividade

Vale para toda spec com tela. As duas validações rodam no navegador, com o app de verdade.

## Preparar o ambiente

- Use o app se já estiver rodando. Senão: no backend `docker compose up -d`, `npm run db:migrate`, `npm run db:seed` e
  `npm run dev`; no frontend `npm run dev` (http://localhost:5173). As contas de teste estão no README do frontend, seção
  "Entrar no app".
- Use o servidor MCP `playwright` (Chrome isolado). O `playwright-figma` é só para o Figma.
- Chame as ferramentas uma por vez, para o print não sair antes de a tela carregar.
- Endpoint que ainda não existe: simule as respostas do contrato do plano com `page.route` no
  `browser_run_code_unsafe`, sem mudar o código do app, e diga no relatório que aquela validação foi simulada.
- Guarde prints e snapshots em `.playwright-mcp/`, que o git ignora.

## Fidelidade

Para cada frame e cada estado que ele mostra (filtro aberto, modal, erro, vazio):

1. `browser_resize` com a largura e a altura do frame, medidas na Fase 2.
2. Abra a rota, leve a tela ao mesmo estado e faça `browser_snapshot` com `boxes: true` e `browser_take_screenshot`
   com `fullPage: true`.
3. Compare com o snapshot e o print do Figma, região por região, de cima para baixo:

| O que conferir | Como | Aceita |
|---|---|---|
| Textos, títulos, rótulos, placeholders, botões | Snapshot do app × snapshot do Figma | Idênticos, com acentos e pontuação |
| Presença e ordem dos elementos | Listar um a um | Nada a mais, nada a menos |
| Posição e tamanho | `box` das camadas × `box` do app | Até 2 px, por renderização de fonte |
| Cor, fundo, borda, sombra, raio, gradiente | Print lado a lado, recortando a região em tamanho real | Sem diferença visível |
| Fonte, peso, tamanho, espaçamento entre letras | Print e `getComputedStyle` | Iguais |
| Ícones e imagens | Print | Os mesmos, no mesmo tamanho |

Os valores dos dados de exemplo (nomes, totais) podem vir do seed. Formato, máscara, tamanho da lista e aparência têm
que bater.

Hover, foco e desabilitado sem frame próprio seguem o estilo dos componentes de `components/`.

Diferença decidida na Fase 3 é a única aceita. Registre cada uma no relatório.

## Responsividade

O índice de telas não traz frames de celular nem de tablet. Se existir frame para um tamanho, ele manda e a validação de
fidelidade vale também ali. Se não existir, a adaptação preserva conteúdo, ordem de leitura e identidade visual do frame
de desktop, reorganizando o layout.

### Como construir

- Breakpoints do projeto, com largura máxima: `@media (max-width: 64rem)` e `@media (max-width: 48rem)`. Variável CSS
  não funciona dentro de `@media`, então estes são os únicos valores literais aceitos ao lado dos tokens.
- Use `flex-wrap`, `grid` com `minmax(0, 1fr)` e `auto-fit`, e `min-width: 0` em filhos de flex e grid.
- Tamanho fixo vira limite: `width: min(var(--size-x), 100%)`. Os tokens `--size-dialog`, `--size-drawer` e
  `--size-side-card` são maiores que um celular.
- Tabela larga rola dentro do próprio contêiner, como o `DataTable`, ou vira lista de cartões quando o Figma pedir.
- Conteúdo escondido num tamanho precisa continuar acessível por outro caminho (menu, aba, drawer). `display: none` sem
  alternativa é reprovação.
- Prefira `min-height` a `height` fixo em áreas com texto.

### Matriz obrigatória

| Dispositivo | Largura × altura | Por quê |
|---|---|---|
| Celular pequeno | 320 × 640 | Limite inferior |
| Celular | 360 × 800 | Tamanho mais comum |
| Tablet retrato | 768 × 1024 | Último ponto do breakpoint `48rem` |
| Tablet paisagem | 1024 × 768 | Último ponto do breakpoint `64rem` |
| Laptop | 1366 × 768 | Tela de notebook, altura curta |
| Desktop | 1920 × 1080 | Monitor grande |
| Frame do Figma | A largura medida no frame | Onde vale a fidelidade; pule se já for uma das larguras acima |

Se a tela tiver `@media` própria em outro valor, teste também 1 px abaixo e 1 px acima dele.

Em cada tamanho, para cada tela: `browser_resize`, abrir a rota, rodar o script abaixo com `browser_evaluate` e ler o
`browser_take_screenshot` com `fullPage: true`. Repita com menus, drawers, modais e filtros abertos, e em pelo menos um
tamanho de celular com os estados carregando, erro e vazio.

```js
() => {
  const viewport = document.documentElement.clientWidth;
  const isVisible = (el) => {
    const box = el.getBoundingClientRect();
    return box.width > 1 && box.height > 1 && getComputedStyle(el).visibility !== 'hidden';
  };
  const scrollsInside = (el) => {
    for (let p = el.parentElement; p; p = p.parentElement) {
      if (['auto', 'scroll'].includes(getComputedStyle(p).overflowX)) return true;
    }
    return false;
  };
  const describe = (el) => {
    const box = el.getBoundingClientRect();
    const name = (el.innerText || el.getAttribute('aria-label') || '').trim().slice(0, 40);
    return `${el.tagName} "${name}" ${Math.round(box.width)}x${Math.round(box.height)} x=${Math.round(box.left)}`;
  };
  const all = [...document.querySelectorAll('body *')].filter(isVisible);
  const controls = all.filter((el) =>
    el.matches('button, a[href], input, select, textarea, [role="button"], [role="tab"]'),
  );
  const fields = all.filter((el) => el.matches('input, select, textarea'));
  return {
    viewport,
    pageScrollWidth: document.documentElement.scrollWidth,
    overflowing: all
      .filter((el) => !scrollsInside(el))
      .filter((el) => {
        const box = el.getBoundingClientRect();
        return box.right > viewport + 1 || box.left < -1;
      })
      .slice(0, 15)
      .map(describe),
    smallTargets: controls
      .filter((el) => el.parentElement?.tagName !== 'P')
      .filter((el) => {
        const box = el.getBoundingClientRect();
        return Math.min(box.width, box.height) < 40;
      })
      .slice(0, 15)
      .map(describe),
    smallFieldText: fields
      .filter((el) => parseFloat(getComputedStyle(el).fontSize) < 16)
      .slice(0, 15)
      .map(describe),
  };
};
```

### Critérios de aprovação

| Critério | Vale em | Reprova quando |
|---|---|---|
| Sem rolagem horizontal da página | Todos | `pageScrollWidth > viewport` ou `overflowing` com itens |
| Nada cortado ou sobreposto | Todos | O print mostra texto cortado, elementos encavalados ou conteúdo atrás da topbar |
| Conteúdo completo | Todos | Algo do desktop some sem caminho alternativo |
| Sobreposições cabem na tela | Todos | Modal ou drawer maior que a tela, sem rolagem interna ou sem o botão de fechar visível |
| Área de toque | 320, 360, 768, 1024 | `smallTargets` tem controle real menor que 40 px, o tamanho de `--size-control`. Confira antes de corrigir: `input` escondido de checkbox personalizado não conta |
| Texto de campo | 320, 360 | `smallFieldText` com itens, porque o iOS dá zoom em campo com menos de 16 px |
| Laptop com altura curta | 1366 | Ação principal inalcançável, ou menu lateral cortado sem rolagem |
| Fidelidade | Largura do frame | Diferença em relação ao frame |

Depois de qualquer correção de layout, refaça a matriz inteira da tela e a fidelidade na largura do frame.
