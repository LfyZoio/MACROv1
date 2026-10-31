# MACROv1

# Anime Panel v14

Execute `AnimePanel_v14.ahk` com AutoHotkey v2. O arquivo experimental
`AnimePanel_v14_FoolsHunt_Visual.ahk` foi preservado. Nao execute ambos juntos.

## Configuracao

1. Abra o Roblox em modo janela e pressione Detectar e Encaixar (F8).
2. Configure recortes PNG/BMP de lobby, Play, entrada, titulo de votacao e
   elemento fixo do CAPTCHA. Nunca use os numeros aleatorios como referencia.
3. Associe imagens das cartas pelo botao Imagem de carta.
4. Clique com o botao direito no painel para configurar referencias independentes
   de fila publica e inicio da partida. Use elementos exclusivos de cada estado.
5. Resolva o CAPTCHA dentro do Roblox. F11 confirma a fila manualmente depois
   que a verificacao deixar de estar detectada. A ausencia do CAPTCHA nao confirma a fila.

F6 pausa, F7 registra observacoes, F8 encaixa, F9 restaura, F10 abre o catalogo.
F7 aceita `wave: 12`, `efeito: +50% vida inimiga` ou texto livre.
O menu de contexto mostra o historico manual de efeitos da sessao.
As preferencias de seis unidades, incluindo seus nomes, sao salvas automaticamente.

## Limites atuais

- Sem imagens de referencia, o reconhecimento correspondente fica indisponivel.
- O Roblox deve estar em primeiro plano, totalmente dentro da area virtual de
  tela e sem janelas sobrepostas. O monitoramento retoma quando estiver visivel.
- Duas correspondencias consecutivas confirmam titulos e cartas; tres ausencias
  validas encerram a votacao/verificacao. Erros nao contam como ausencia.
- ImageSearch nao fornece probabilidade de confianca. As correspondencias sao
  aproximacoes visuais com tolerancia 25; confirme os recortes na sua resolucao.
- Waves e efeitos ativos sao registros manuais. Nao ha OCR nem leitura automatica
  de Current Effects. Cartas oferecidas nunca sao contabilizadas como escolhidas.
- O historico manual de efeitos nao verifica expiracao, acumulo ou troca de partida.
  Ele permanece apenas na memoria durante esta sessao do painel.
- Nenhum clique, escolha de carta, movimentacao ou preenchimento de CAPTCHA e automatizado.
- Para encaixar, a area de trabalho deve ter ao menos 1092 x 750 pixels.

## Catalogo e pesquisa (25/10/2026)

O catalogo inclui somente as quatro cartas documentadas no texto fornecido pelo
usuario. Spellproof Enemies I foi adicionada com +30% AprilCoins e +75 de
resistencia magica. Resistencia nao foi convertida para porcentagem.
Os dados sao provenientes do relato fornecido; as capturas originais nao estavam
disponiveis nesta pasta para verificacao independente.

As paginas Events, Update_Log, Enemy_Mechanics e Effects da wiki Fandom nao
puderam ser consultadas devido ao bloqueio de acesso. Nao foi localizada uma
lista verificavel de cartas adicionais nesta pesquisa. Os artigos abaixo descrevem
o evento e modificadores, mas nao confirmam nomes e valores de novas cartas:

- https://www.ginx.tv/en/anime-adventures-update-patch-notes
- https://roonby.com/2025/04/02/anime-adventures-20-4-update-guide-new-units-codes-more/

Para ampliar, adicione secoes CartaN e atualize Catalogo/Total (limite atual: 100).
Imagem e opcional. Mantenha a codificacao UTF-16 do INI ao editar.

## Verificacao

Revisao de estabilidade concluida com validacao de sintaxe e 143 verificacoes
automatizadas no AutoHotkey 2.0.30 (64 bits). O encaixe e a restauracao foram
exercitados com janelas sinteticas do Windows. Os detectores foram testados com
sequencias simuladas; nao houve teste dentro do Roblox.

Consulte `RELATORIO_ESTABILIZACAO_V14.md` para correcoes e evidencias e
`ROTEIRO_TESTE_ROBLOX.md` para a validacao real. A copia anterior esta em
`backups/v14-antes-estabilizacao-20261025-131111/`.

Execute `tests/regression.ps1` para repetir os ensaios isolados. O utilitario
antigo `upgrade_panel.py` foi arquivado no backup; nao o use para regerar a v14.
