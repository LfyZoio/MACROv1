# Roteiro de teste real — Anime Panel v14

Status inicial: **pendente de execução no Roblox**.

Antes de começar, feche outras versões do painel. Abra `AnimePanel_v14.ahk` com AutoHotkey v2 e o Roblox em modo janela. Anote resolução, escala do Windows, monitor utilizado e versão do AutoHotkey. O encaixe exige área de trabalho disponível de pelo menos 1092 × 750 pixels, descontando a barra de tarefas.

Use recortes exclusivos da interface, feitos na mesma resolução/escala do jogo. Para o CAPTCHA, recorte somente título/elemento fixo, sem os números. As verificações humanas e escolhas no jogo continuam manuais.

| Etapa | Ação | Resultado esperado |
|---|---|---|
| 1. Inicialização | Abrir o painel. | Sem caixa de erro; console informa início e catálogo com quatro cartas. |
| 2. Catálogo — F10 | Pressionar F10 e conferir nomes, recompensas e efeitos. | Quatro cartas preservadas; resistências sem símbolo de porcentagem. Imagem não configurada aparece pendente. |
| 3. Preferências | Alterar nomes, quantidades, prioridades, habilidade e upgrade das seis unidades; padrão, velocidade, fila, repetição e opção de borda. Aguardar 1 segundo, fechar e abrir o painel. | Valores reaparecem. Não há erro de gravação. |
| 4. Detectar | Com o Roblox aberto, usar Detectar. | Janela encontrada, sem movimentação até pedir encaixe. |
| 5. Encaixe normal — F8/F9 | Anotar posição/tamanho da janela. Pressionar F8 duas vezes e depois F9. Repetir com a opção de borda ligada e desligada. | Roblox à esquerda e painel à direita; jogo continua renderizando. F9 devolve posição, tamanho e bordas originais. |
| 6. Estados da janela | Repetir F8/F9 a partir de Roblox maximizado, minimizado e minimizado depois de maximizado. | Estado original retorna. No último caso, ao restaurar o Roblox pela barra de tarefas, ele volta maximizado. |
| 7. Fechamento | Encaixar e fechar o painel pelo botão Fechar. Depois repetir fechando o Roblox antes do painel. | Primeiro caso restaura o Roblox; segundo informa janela fechada e limpa detecções. Nenhuma exceção. |
| 8. Lobby | Configurar as referências de lobby, Play e entrada. Deixar o Roblox em primeiro plano e observar a rota, confirmando manualmente os passos indicados. | Cada reconhecimento exige duas verificações; mensagens não se repetem continuamente. Elementos parecidos fora do contexto não devem avançar a rota. |
| 9. Pausa — F6 | Durante monitoramento, pressionar F6; alterar a tela do jogo; aguardar mais de 5 segundos; pressionar F6 outra vez. | Nenhuma detecção avança durante a pausa. Ao retomar, é preciso obter novas correspondências consecutivas. |
| 10. Visibilidade | Durante votação ou CAPTCHA detectado, alternar para outro aplicativo, cobrir o jogo ou minimizá-lo por mais de 5 segundos. Voltar ao jogo. | A indisponibilidade não é anunciada como fim da votação/CAPTCHA e não confirma fila. A leitura retoma com o jogo visível e ativo. |
| 11. Votação | Configurar título “Choose a card!” e imagens de cartas conhecidas. Aguardar votação real e escolher manualmente. | Abertura confirmada após duas leituras; cada carta conhecida exige duas correspondências e é registrada uma vez por votação. Cartas desconhecidas não recebem nomes inventados. Três ausências válidas encerram a tela. |
| 12. Referência ausente | Com o painel fechado, copiar o INI e apontar uma referência para PNG inexistente; abrir e tentar monitorar. Depois restaurar a configuração. | Programa continua aberto; aviso limitado por caminho. Falha da imagem não conta como fim de votação/verificação. |
| 13. CAPTCHA | Configurar referência fixa, entrar no matchmaking pelo jogo e aguardar detecção. Pressionar F11 enquanto a verificação está detectada. | “AGUARDANDO VERIFICACAO MANUAL”; F11 não confirma a fila. Nenhum número é lido ou preenchido pelo painel. |
| 14. Desaparecimento sem aceitação | Sem referência visual de fila configurada, fechar/cancelar a verificação pelo fluxo normal do jogo, se permitido. Caso não seja possível cancelar, observar o mesmo estado após resolução manual. | Após três ausências válidas, “CAPTCHA SAIU DA TELA - VERIFIQUE A FILA”. Nenhuma confirmação automática apenas por desaparecer. |
| 15. Fila — F11 | Resolver a verificação no Roblox e confirmar visualmente que entrou na fila. Só então usar F11, após o painel deixar de detectar CAPTCHA. Pressionar F11 novamente. | Primeira ação registra confirmação manual; a repetição não duplica a mensagem. |
| 16. Referências extras | Pelo botão direito no painel, configurar imagens exclusivas de fila e início da partida. Observar uma entrada real. | Cada estado é confirmado por duas correspondências próprias. Oscilações da mesma imagem não geram confirmações repetidas. |
| 17. Nova rota | Depois da fila/partida, clicar Nova rota ou confirmar um novo lobby. | Estados anteriores de fila, partida e detecção deixam de contaminar a nova rota. |
| 18. Observações — F7 | Registrar `wave: 12`, `efeito: exemplo confirmado` e uma observação livre; abrir o histórico de efeitos pelo menu. | Registros manuais aparecem corretamente. Reconhecer uma carta oferecida não adiciona efeito ativo automaticamente. |
| 19. Monitor/DPI | Se houver outro monitor ou escala diferente, repetir encaixe/restauração e validar referências novas. | Sem perda de janela ou controles inacessíveis. Recortes antigos que deixarem de corresponder precisam ser refeitos. |

Durante cada teste, marque **passou**, **falhou** ou **não executado**. Se houver falha, registre a etapa, mensagem completa, linha indicada, últimas mensagens do console e estado do Roblox. Não considere uma etapa aprovada apenas porque o script abriu.

Critério de conclusão: nenhuma exceção; restauração correta nos estados utilizados; preferências preservadas; atalhos funcionando no ambiente real; detecções sem identificação indevida nas telas observadas; desaparecimento do CAPTCHA jamais tratado isoladamente como fila aceita. Casos não executados continuam pendentes.
