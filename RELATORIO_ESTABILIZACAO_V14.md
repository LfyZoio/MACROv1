# Revisão e estabilização do Anime Panel v14

Data: 25/10/2026. Escopo: revisar os recursos existentes, corrigir falhas e preparar a validação real. Nenhuma funcionalidade nova de jogo foi iniciada.

## Resultado

O arquivo principal é `AnimePanel_v14.ahk`. A validação de sintaxe e a regressão automatizada passaram com **143 verificações**, usando **AutoHotkey 2.0.30 de 64 bits**.

**Não foram realizados testes dentro do Roblox.** Os testes de janela utilizaram GUIs nativas criadas pelo próprio teste. As sequências de correspondências dos detectores foram simuladas. Os diálogos de observação e catálogo foram substituídos por respostas controladas no teste; o pressionamento físico dos atalhos no jogo ainda precisa ser verificado.

## Cópia preservada

Pasta: `backups/v14-antes-estabilizacao-20261025-131111/`.

Contém o script anterior, perfil INI, catálogo e instruções anteriores. O utilitário antigo `upgrade_panel.py` também foi arquivado nessa pasta, pois sua execução sobrescreveria as correções com uma geração antiga.

- SHA-256 do script anterior: `E0BC6CA0DBEAC22A8F8382A93FED7F54402F05DE938C327E1BF938F4AA589265`.
- SHA-256 do script revisado: `2BBB7FB9796F1CD91E6428365F2D7BBE9EADC86570C68761B65FF8FDC9ACEA3C`.
- O perfil e o catálogo reais permaneceram idênticos às cópias preservadas, conforme comparação de SHA-256. Os testes gravaram apenas em suas próprias pastas.

Para reverter, feche o painel e copie o script da pasta de backup sobre o principal. Restaure os INIs somente se também quiser reverter as preferências e o catálogo. Não execute duas versões simultaneamente.

## Correções

### Encaixe e restauração

- A posição e o estado originais agora são capturados antes de qualquer alteração, usando `GetWindowPlacement` e restaurados com `SetWindowPlacement`. Isso preserva também a condição “minimizado depois de maximizado”.
- Estilo e estilo estendido são preservados. Os bits de maximização/minimização são restaurados pelo posicionamento da janela, evitando misturar estados com a alteração de borda.
- F8 repetido não substitui a captura original pela posição já encaixada.
- A restauração verifica HWND e PID. Em caso de falha, mantém os dados para uma nova tentativa por F9, em vez de apagá-los e informar sucesso.
- Se a restauração falhar ao fechar o painel, a saída é cancelada e o console informa que F9 deve ser tentado novamente. Uma finalização forçada pelo sistema não permite essa recuperação.
- O fechamento do Roblox limpa os estados mesmo quando ele foi apenas detectado e não encaixado.
- O layout usa o tamanho do cliente do painel e ajusta a largura para preservar o espaço mínimo do jogo. Espaço insuficiente provoca restauração, sem deixar alterações parciais.
- Não há uso de `SetParent`.

A escolha de manter o posicionamento no formato nativo do Windows evita misturar coordenadas da área de trabalho e da tela, conforme a [documentação de WINDOWPLACEMENT](https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-windowplacement).

### Detectores e matchmaking

- Um único ciclo de monitoramento verifica o CAPTCHA antes dos demais detectores.
- Lobby, Play, entrada, votação, cartas, fila e partida exigem duas correspondências consecutivas. Falta de foco, indisponibilidade da área, pausa ou erro de leitura interrompem a contagem.
- Ausência válida, leitura indisponível e correspondência são estados distintos. Três ausências válidas encerram a votação ou a presença detectada do CAPTCHA; erros e janelas ocultas não contam como ausência.
- A contagem de uma carta também é interrompida quando o título da votação desaparece ou sua leitura falha.
- Confirmações persistentes não repetem mensagens a cada ciclo. Oscilações da imagem da fila não repetem uma confirmação já registrada. F11 e confirmação do lobby também evitam registros duplicados.
- Uma nova rota, confirmação de um novo lobby ou desconexão limpa os estados antigos de detecção. O histórico manual de efeitos permanece como histórico da sessão.
- O estado de verificação manual tem prioridade no texto do painel.
- O desaparecimento do CAPTCHA mantém `Aguardando confirmacao independente`. A confirmação depende de imagem própria de fila ou de F11. F11 fica bloqueado enquanto há CAPTCHA confirmado ou uma correspondência pendente de confirmação.
- Cartas oferecidas não são registradas automaticamente como efeitos ativos ou como cartas escolhidas.

Essas medidas reduzem falsos positivos, mas não comprovam a precisão de recortes reais. `ImageSearch` continua dependente de resolução, escala e aparência; a tolerância permanece 25.

### Catálogo e arquivos de imagem

- As quatro cartas existentes foram preservadas, sem novos nomes, valores ou interpretações de resistência.
- Seções sem nome são ignoradas; os números originais são mantidos para associar uma imagem à seção correta mesmo com lacunas no INI.
- Total malformado ou acima de 100 é informado como inválido. Catálogo ausente ou inválido não interrompe o programa.
- Caminhos relativos são resolvidos a partir da pasta do script. Diretórios não são aceitos como imagens.
- Novas referências PNG/BMP são verificadas antes de serem associadas. Arquivos ausentes ou corrompidos durante o monitoramento produzem leitura indisponível, sem encerrar votação ou CAPTCHA.
- Avisos de imagem ausente ou erro são limitados por caminho na sessão. Usar o mesmo caminho de imagem para cartas distintas desativa essas identificações em memória para evitar atribuições ambíguas.
- Erros de gravação de referências e de associação de cartas são tratados no console.

### Preferências e atalhos

- Mantidos os eventos corretos: `Change` para campos/listas e `Click` para caixas de seleção.
- Salvamento automático com atraso de 800 ms e salvamento na saída preservados.
- O perfil é preparado em arquivo temporário antes de substituir o destino. Chaves desconhecidas e referências existentes são preservadas.
- Valores inválidos de uma preferência não impedem o carregamento das demais. Quantidades aceitam 0 a 999999 para armazenamento; entradas inválidas voltam a 1. Isso não define limites de unidades do jogo.
- Carregar preferências não agenda gravações durante o preenchimento dos controles. Opções desconhecidas nas listas voltam ao primeiro item.
- Mantidos F6, F7, F8, F9, F10 e F11, com as funções existentes preservadas. A regressão também verifica que nenhuma função da cópia anterior foi removida.

## Evidências e reprodução

- `tests/startup-smoke.ps1`: inicialização com painel oculto, registro de eventos, seleção de preferência e layout.
- `tests/regression.ps1`: validação de sintaxe do script principal com `/ErrorStdOut /Validate`, seguida da regressão executada pelo AutoHotkey.
- `tests/regression.ahk`: casos de regressão usados na cópia de teste.
- Resultado final: `tests/run-20261025-131859-138/results.txt`.

Comando para repetir a regressão no PowerShell, a partir da pasta do projeto:

```powershell
& .\tests\regression.ps1
```

O teste cria arquivos isolados e janelas sintéticas temporárias, que podem aparecer brevemente. Não procura nem modifica a janela real do Roblox. Os atalhos são registrados em um contexto inativo de teste; suas funções são invocadas diretamente.

Foram exercitados: gravação/leitura das seis unidades e opções gerais, caracteres acentuados, autosave, preservação de chaves desconhecidas, INI malformado, falha de gravação, catálogo ausente/com lacunas, imagem válida/ausente/corrompida, referência compartilhada, deduplicação, interrupção de contagens, CAPTCHA sem aceitação implícita e transições de fila/partida.

Em janelas nativas sintéticas foram exercitados: F8/F9 por suas funções, encaixe com e sem remoção de borda, repetição de F8, restauração normal/maximizada/minimizada/minimizada após maximização, preservação do retângulo original e dos estilos, falha de identidade com nova tentativa, restauração pela função de saída e fechamento de janela não encaixada.

## Pendências para validação real

Seguir `ROTEIRO_TESTE_ROBLOX.md`. Ainda não estão comprovados: renderização do Roblox após encaixe, comportamento em outros monitores/DPI, precisão das referências reais, conflitos dos atalhos com outros programas e comportamento durante matchmaking real. A v14 está revisada e passou nos ensaios descritos; a aprovação dentro do jogo depende desse roteiro.
