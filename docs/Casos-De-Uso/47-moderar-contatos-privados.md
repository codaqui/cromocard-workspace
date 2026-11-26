| Nome do Caso de Uso | Moderar Contatos Privados |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário bloqueie ou denuncie, pelo chat pessoal, um contato com comportamento inadequado, e desbloqueie quem bloqueou. |
| Atores | Cliente, Vendedor |
| Pré Condições | O usuário deve estar autenticado como Cliente ou Vendedor e ter uma conversa pessoal com o contato. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário abre a conversa com o contato e seleciona o escudo no topo. |  |
|  | 2. O sistema abre o modal "Bloquear ou denunciar @<usuário>" ("Escolha o que fazer com este contato.") com o contato: iniciais, nome, @ e "conversa desde <mês> de <ano>". |
|  | 3. O sistema apresenta "O que você quer fazer?" com três opções: "Somente bloquear" ("Ele não poderá mais te enviar mensagens"), "Bloquear e denunciar" ("A moderação analisa a conversa") e "Somente denunciar" ("A conversa continua aberta"). |
| 4. O usuário escolhe uma opção. |  |
|  | 5. Nas opções com denúncia, o sistema pede "Motivo da denúncia" (um entre "Golpe / pagamento externo", "Assédio", "Spam" e "Perfil falso"), "Conte o que aconteceu" (opcional, até 500 caracteres) e de 1 a 3 prints da conversa como evidência (PNG, JPG ou WEBP, até 4 MB cada). |
| 6. O usuário preenche o que a opção pede. |  |
|  | 7. O sistema mostra o rodapé "Você pode desbloquear em Configurações.", "Cancelar" e o botão da opção: "Bloquear", "Bloquear e denunciar" ou "Denunciar". |
| 8. O usuário seleciona o botão da opção. |  |
|  | 9. Ao bloquear, o sistema registra o bloqueio; com bloqueio ativo, nenhum dos dois envia mensagem na conversa. |
|  | 10. Ao denunciar, o sistema registra a denúncia com o motivo, a descrição e os prints, pendente de análise na Fila de moderação do BackOffice. |
|  | 11. O sistema fecha o modal e confirma: "Contato bloqueado" ("Ele não poderá mais te enviar mensagens."), "Contato bloqueado e denunciado" ("A moderação vai analisar a conversa.") ou "Denúncia enviada" ("A moderação vai analisar a conversa."). |
|  | 12. Com o contato bloqueado, a conversa continua na lista, e o campo de digitação dá lugar a "Você bloqueou @<usuário>. Para conversar de novo, desbloqueie em Configurações › Privacidade." com o botão "Desbloquear". |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário seleciona "Cancelar" ou o "✕" do modal. |  |
|  | 2. O sistema fecha o modal sem bloquear nem denunciar. |
| 3. O usuário confirma uma denúncia sem motivo ou sem print. |  |
|  | 4. O sistema não registra nada e indica o que falta: "Escolha o motivo da denúncia." ou "Envie pelo menos um print da conversa." |
| 5. O usuário envia um print com formato ou tamanho fora do permitido, ou mais de 3. |  |
|  | 6. O sistema recusa o arquivo e informa o limite. |
| 7. O usuário denuncia de novo um contato que ele já denunciou e cuja denúncia ainda está pendente. |  |
|  | 8. O sistema não registra outra denúncia e informa: "Você já denunciou este contato. A moderação está analisando." |
| 9. O usuário seleciona "Desbloquear" no aviso da conversa, ou no modal aberto pelo escudo com o contato já bloqueado. |  |
|  | 10. O sistema remove o bloqueio e a conversa volta a aceitar mensagens. |
|  | 11. Para o contato bloqueado, o campo de digitação da conversa dá lugar a "@<usuário> bloqueou você. Vocês não podem mais trocar mensagens.", e quem o bloqueou não aparece no "Nova conversa" dele. |
|  | 12. Se o envio do bloqueio ou da denúncia falhar, o sistema mantém o modal aberto com o que foi preenchido e informa o erro. |
