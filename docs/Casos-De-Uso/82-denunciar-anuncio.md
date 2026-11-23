| Nome do Caso de Uso | Denunciar Anúncio |
|---|---|
| Finalidade/Objetivo | Como Cliente preciso denunciar um anúncio para informar à plataforma possíveis irregularidades. |
| Atores | Cliente |
| Pré Condições | O cliente deve estar autenticado e na página de detalhes do anúncio que deseja denunciar. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente seleciona a opção '⚑ Denunciar anúncio', ao lado do vendedor no detalhe do anúncio |  |
|  | 2. O sistema apresenta um formulário/modal solicitando o motivo da denúncia |
| 3. O cliente seleciona um motivo (Fraude ou tentativa de golpe, Item falso ou falsificado, Anúncio enganoso (fotos ou descrição) ou Outro motivo), adiciona uma observação opcional e confirma (Figma, 22/11/2026) |  |
|  | 4. O sistema registra a denúncia e mostra a confirmação "Denúncia enviada": a equipe vai analisar o anúncio, e o vendedor não sabe quem denunciou |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente tenta enviar a denúncia sem selecionar um motivo |  |
|  | 2. O sistema bloqueia o envio, destaca os motivos e mostra a mensagem "Escolha um motivo para enviar a denúncia." |
