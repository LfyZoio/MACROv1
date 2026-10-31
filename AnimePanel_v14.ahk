
#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir(A_ScriptDir)

; ============================================
; ANIME PANEL V14 - FOOL'S HUNT
; GUI, ENCAIXE, CARTAS E MATCHMAKING
; AutoHotkey v2.0
;
; Somente acompanhamento visual.
; Nao digita CAPTCHA, nao envia cliques
; nem controla o personagem no Roblox.
; ============================================

CoordMode("Pixel", "Screen")

global roboHwnd := 0
global encaixado := false
global pausado := false
global janelaOriginal := 0
global monitorAlvo := 0
global semBordaAplicado := false

global historico := []
global etapaGuia := 1

global imagemLobby := ""
global imagemPlay := ""
global imagemEntrada := ""
global imagemVotacao := ""
global imagemCaptcha := ""

global framesLobby := 0
global framesPlay := 0
global framesEntrada := 0
global framesVotacao := 0
global framesCaptcha := 0
global ausenciaVotacao := 0
global ausenciaCaptcha := 0

global lobbyDetectado := false
global playVisivel := false
global entradaVisivel := false
global votacaoAberta := false
global captchaAberto := false

global framesCartas := Map()
global avisosImagem := Map()
global estadoFila := "Nao confirmada"
global referenciasExtras := Map()
global framesExtras := Map()
global waveAtual := "?"
global efeitosManuais := []
global cartasEncontradas := Map()
global catalogo := []
global carregandoPerfil := false

global arquivoINI := A_ScriptDir "\anime_panel_v14.ini"
global arquivoCartas := A_ScriptDir "\cartas_fools_hunt.ini"

; ============================================
; INTERFACE
; ============================================

global painel := Gui(
    "-Caption +Border -DPIScale +AlwaysOnTop",
    "Anime Panel v14"
)

painel.BackColor := "111820"
painel.SetFont("s9 cE8EDF5", "Segoe UI")

global barra := painel.AddText(
    "x0 y0 w560 h38 Background1B2938"
)

painel.SetFont("s13 bold c63E2C5")

global titulo := painel.AddText(
    "x14 y7 w340 h26 Background1B2938",
    "ANIME PANEL V14"
)

painel.SetFont("s9 cE8EDF5")

global fechar := painel.AddButton(
    "x467 y6 w76 h26", "Fechar"
)

fechar.OnEvent("Click", (*) => ExitApp())

global status := painel.AddText(
    "x14 y45 w520 h20 cFFC46B",
    "DESCONECTADO"
)

global detectar := painel.AddButton(
    "x14 y71 w165 h30", "Detectar"
)

global encaixar := painel.AddButton(
    "x190 y71 w165 h30", "Encaixar (F8)"
)

global restaurar := painel.AddButton(
    "x366 y71 w176 h30", "Restaurar (F9)"
)

detectar.OnEvent("Click", DetectarRoblox)
encaixar.OnEvent("Click", EncaixarRoblox)
restaurar.OnEvent("Click", RestaurarRoblox)

global semBorda := painel.AddCheckbox(
    "x14 y106 w520 h22",
    "Ocultar borda do Roblox durante o encaixe"
)

; ============================================
; GUIA DO LOBBY
; ============================================

painel.SetFont("s11 bold c63E2C5")

global guiaTitulo := painel.AddText(
    "x14 y136 w520 h24",
    "ROTA - LOBBY ATE FOOL'S HUNT"
)

painel.SetFont("s9 cE8EDF5")

global instrucao := painel.AddText(
    "x14 y164 w520 h40", ""
)

global escolherLobby := painel.AddButton(
    "x14 y205 w165 h24", "Imagem lobby"
)

global escolherPlay := painel.AddButton(
    "x190 y205 w165 h24", "Imagem Play"
)

global escolherEntrada := painel.AddButton(
    "x366 y205 w176 h24", "Imagem da entrada"
)

escolherLobby.OnEvent(
    "Click", (*) => EscolherReferencia("Lobby")
)

escolherPlay.OnEvent(
    "Click", (*) => EscolherReferencia("Play")
)

escolherEntrada.OnEvent(
    "Click", (*) => EscolherReferencia("Entrada")
)

global confirmarLobbyBtn := painel.AddButton(
    "x14 y234 w165 h30", "Confirmar lobby"
)

global confirmarPlayBtn := painel.AddButton(
    "x190 y234 w165 h30", "Play clicado"
)

global avancarBtn := painel.AddButton(
    "x366 y234 w176 h30", "Cheguei a sala"
)

confirmarLobbyBtn.OnEvent(
    "Click", (*) => ConfirmarLobby("manual")
)

confirmarPlayBtn.OnEvent("Click", ConfirmarPlay)
avancarBtn.OnEvent("Click", AvancarGuia)

; ============================================
; UNIDADES
; ============================================

painel.SetFont("s11 bold c63E2C5")

global unidadesTitulo := painel.AddText(
    "x14 y278 w520 h22",
    "UNIDADES - PREFERENCIAS"
)

painel.SetFont("s9 cAFC4D6")

global cabNome := painel.AddText(
    "x14 y302 w63 h19", "Unidade"
)

global cabQtd := painel.AddText(
    "x80 y302 w52 h19", "Qtd."
)

global cabPrior := painel.AddText(
    "x144 y302 w56 h19", "Prior."
)

global cabHab := painel.AddText(
    "x216 y302 w110 h19", "Habilidade"
)

global cabUp := painel.AddText(
    "x398 y302 w110 h19", "Upgrade"
)

painel.SetFont("s9 cE8EDF5")

global listaUnidades := []

Loop 6 {
    i := A_Index
    y := 325 + (i - 1) * 26

    unidade := {
        nome: painel.AddEdit(
            "x14 y" (y + 3) " w62 h22",
            "Unit " i
        ),

        qtd: painel.AddEdit(
            "x80 y" y " w46 h23 Number", "1"
        ),

        prio: painel.AddDropDownList(
            "x144 y" y " w56 Choose" i,
            ["1", "2", "3", "4", "5", "6"]
        ),

        hab: painel.AddCheckbox(
            "x216 y" y " w100 h23", "Auto"
        ),

        upgrade: painel.AddCheckbox(
            "x398 y" y " w94 h23", "Ativar"
        )
    }

    listaUnidades.Push(unidade)
}

global labelPadrao := painel.AddText(
    "x14 y493 w112 h22", "Padrao"
)

global campoPadrao := painel.AddDropDownList(
    "x140 y489 w400 Choose1",
    ["Manual", "Circle", "Line", "Default"]
)

global labelVel := painel.AddText(
    "x14 y524 w112 h22", "Velocidade"
)

global campoVel := painel.AddDropDownList(
    "x140 y520 w400 Choose1",
    ["Default", "1x", "1.5x", "2x"]
)

global prefRepetir := painel.AddCheckbox(
    "x14 y553 w220 h23",
    "Repeat Stage (preferencia)"
)

global prefFila := painel.AddCheckbox(
    "x264 y553 w255 h23",
    "Matchmaking (preferencia)"
)

global salvar := painel.AddButton(
    "x14 y585 w165 h29", "Salvar perfil"
)

global pausar := painel.AddButton(
    "x190 y585 w165 h29", "Pausar (F6)"
)

global catalogoBtn := painel.AddButton(
    "x366 y585 w176 h29", "Catalogo (F10)"
)

salvar.OnEvent("Click", SalvarPerfil)
pausar.OnEvent("Click", AlternarPausa)
catalogoBtn.OnEvent("Click", MostrarCatalogo)

; ============================================
; DETECTORES
; ============================================

global escolherVotacao := painel.AddButton(
    "x14 y625 w165 h28", "Imagem votacao"
)

global escolherCaptcha := painel.AddButton(
    "x190 y625 w165 h28", "Imagem CAPTCHA"
)

global escolherCarta := painel.AddButton(
    "x366 y625 w176 h28", "Imagem de carta"
)

escolherVotacao.OnEvent(
    "Click", (*) => EscolherReferencia("Votacao")
)

escolherCaptcha.OnEvent(
    "Click", (*) => EscolherReferencia("Captcha")
)

escolherCarta.OnEvent(
    "Click", AssociarImagemCarta
)

global detectorStatus := painel.AddText(
    "x14 y660 w520 h20 c63E2C5",
    "DETECTORES: AGUARDANDO REFERENCIAS"
)

painel.SetFont("s9 cE8EDF5", "Consolas")

global console := painel.AddEdit(
    "x14 y686 w520 h90 ReadOnly -Wrap "
    . "Background1B2938 cE8EDF5",
    ""
)

; ============================================
; INICIALIZACAO
; ============================================

painel.OnEvent("Close", (*) => ExitApp())
OnExit(AoSair)

Hotkey("F6", AlternarPausa)
Hotkey("F7", RegistrarObservacao)
Hotkey("F8", EncaixarRoblox)
Hotkey("F9", RestaurarRoblox)
Hotkey("F10", MostrarCatalogo)
Hotkey("F11", ConfirmarFilaManual)

painel.Show("w560 h790 Center")

AtualizarGuia()
CarregarPerfil()
CarregarCatalogo()

Log("INFO", "Anime Panel v14 iniciado.")
Log("INFO", "CAPTCHA deve ser preenchido manualmente.")
Log("INFO", "F11 confirma manualmente a entrada na fila.")

SetTimer(VerificarJanelas, 1500)
; Um unico ciclo evita confirmacoes de fila antes de verificar o CAPTCHA.
SetTimer(MonitorarVisual, 1500)
for tipo in ["Fila", "Partida"] {
    referenciasExtras[tipo] := IniRead(arquivoINI, "Deteccao", "Imagem" tipo, "")
    framesExtras[tipo] := 0
}
for unidade in listaUnidades {
    for controle in [unidade.nome, unidade.qtd, unidade.prio]
        controle.OnEvent("Change", AgendarSalvamento)
    for controle in [unidade.hab, unidade.upgrade]
        controle.OnEvent("Click", AgendarSalvamento)
}
for controle in [campoPadrao, campoVel]
    controle.OnEvent("Change", AgendarSalvamento)
for controle in [prefRepetir, prefFila, semBorda]
    controle.OnEvent("Click", AgendarSalvamento)
menuMonitor := Menu()
menuMonitor.Add("Referencia de fila publica", (*) => ConfigurarExtra("Fila"))
menuMonitor.Add("Referencia de inicio da partida", (*) => ConfigurarExtra("Partida"))
menuMonitor.Add("Wave / efeito / observacao (F7)", RegistrarObservacao)
menuMonitor.Add("Ver efeitos confirmados manualmente", MostrarEfeitos)
painel.OnEvent("ContextMenu", (*) => menuMonitor.Show())
Log("INFO", "Botao direito no painel: fila, partida e efeitos. F7 registra wave/efeito.")

; ============================================
; GUIA
; ============================================

AtualizarGuia() {
    global etapaGuia, instrucao, avancarBtn
    global playVisivel, entradaVisivel

    if etapaGuia = 1 {
        instrucao.Text :=
            "1. Aguarde o lobby ou confirme manualmente."
    }
    else if etapaGuia = 2 {
        aviso := playVisivel
            ? "Play identificado! "
            : "Procure Play. "

        instrucao.Text :=
            "2. " aviso "Clique no Roblox e confirme."
    }
    else if etapaGuia = 3 {
        aviso := entradaVisivel
            ? "Entrada identificada! "
            : "Siga ate a sala. "

        instrucao.Text :=
            "3. " aviso "Confirme a chegada."
    }
    else if etapaGuia = 4 {
        instrucao.Text :=
            "4. Clique em Play Here no Roblox."
    }
    else if etapaGuia = 5 {
        instrucao.Text :=
            "5. Matchmaking: resolva o CAPTCHA manualmente."
    }
    else {
        instrucao.Text :=
            "Rota concluida. Acompanhe cartas e waves."
    }

    if etapaGuia = 4
        avancarBtn.Text := "Play Here clicado"
    else if etapaGuia = 5
        avancarBtn.Text := "Fila confirmada"
    else if etapaGuia = 6
        avancarBtn.Text := "Nova rota"
    else
        avancarBtn.Text := "Cheguei a sala"
}

ConfirmarLobby(modo := "manual") {
    global etapaGuia, pausado
    global lobbyDetectado, playVisivel
    global entradaVisivel, framesPlay, framesEntrada

    if pausado
        return

    if etapaGuia = 2 && lobbyDetectado
        return
    ReiniciarDeteccao()
    etapaGuia := 2
    lobbyDetectado := true
    playVisivel := false
    entradaVisivel := false
    framesPlay := 0
    framesEntrada := 0

    AtualizarGuia()
    Log("INFO", "Lobby confirmado por " modo ".")
}

ConfirmarPlay(*) {
    global etapaGuia, pausado
    global entradaVisivel, framesEntrada

    if pausado
        return

    if etapaGuia != 2 {
        Log("AVISO", "Confirme o lobby primeiro.")
        return
    }

    etapaGuia := 3
    entradaVisivel := false
    framesEntrada := 0

    AtualizarGuia()
    Log("MANUAL", "Play confirmado.")
}

AvancarGuia(*) {
    global etapaGuia, pausado
    global lobbyDetectado, playVisivel
    global entradaVisivel, framesLobby

    if pausado
        return

    if etapaGuia = 3 {
        etapaGuia := 4
        Log("MANUAL", "Chegada a sala confirmada.")
    }
    else if etapaGuia = 4 {
        etapaGuia := 5
        Log("MANUAL", "Play Here confirmado.")
    }
    else if etapaGuia = 5 {
        ConfirmarFilaManual()
        return
    }
    else if etapaGuia = 6 {
        ReiniciarDeteccao()
        etapaGuia := 1
        lobbyDetectado := false
        playVisivel := false
        entradaVisivel := false
        framesLobby := 0
        Log("INFO", "Guia reiniciado.")
    }
    else {
        Log("AVISO", "Confirme lobby e Play primeiro.")
        return
    }

    AtualizarGuia()
}

ConfirmarFilaManual(*) {
    global etapaGuia, captchaAberto, framesCaptcha, estadoFila, pausado
    if pausado
        return
    if captchaAberto || framesCaptcha > 0 {
        Log("AVISO", "Aguarde o fim da verificacao manual antes de confirmar a fila.")
        return
    }
    if estadoFila = "Confirmada manualmente" || estadoFila = "Fila publica confirmada por imagem"
        || estadoFila = "Partida em andamento"
        return
    estadoFila := "Confirmada manualmente"
    etapaGuia := 6
    AtualizarDetectorStatus()

    Log(
        "MANUAL",
        "Entrada na fila confirmada pelo usuario."
    )

    AtualizarGuia()
}

; ============================================
; CONFIGURAR IMAGENS
; ============================================

EscolherReferencia(tipo) {
    global imagemLobby, imagemPlay, imagemEntrada
    global imagemVotacao, imagemCaptcha
    global arquivoINI, etapaGuia
    global lobbyDetectado, playVisivel, entradaVisivel
    global votacaoAberta, captchaAberto
    global framesVotacao, framesCaptcha

    imagem := FileSelect(
        1,
        A_ScriptDir,
        "Selecione imagem: " tipo,
        "Imagens (*.png; *.bmp)"
    )

    if imagem = ""
        return

    secao := (tipo = "Lobby" || tipo = "Play" || tipo = "Entrada") ? "Guia" : "Deteccao"
    if !ValidarReferencia(imagem) || !SalvarChave(imagem, arquivoINI, secao, "Imagem" tipo)
        return
    ReiniciarContagens()

    if tipo = "Lobby" {
        imagemLobby := imagem
        etapaGuia := 1
        lobbyDetectado := false
        ReiniciarDeteccao()
    }
    else if tipo = "Play" {
        imagemPlay := imagem
        playVisivel := false
    }
    else if tipo = "Entrada" {
        imagemEntrada := imagem
        entradaVisivel := false
    }
    else if tipo = "Votacao" {
        imagemVotacao := imagem
        votacaoAberta := false
        framesVotacao := 0
    }
    else if tipo = "Captcha" {
        imagemCaptcha := imagem
        ; Preservar verificacao pendente ate observar ausencias validas.
        framesCaptcha := 0
    }

    AtualizarGuia()
    AtualizarDetectorStatus()
    Log("OK", "Referencia configurada: " tipo)
}

ResolverImagem(caminho) {
    caminho := Trim(caminho)
    if caminho = "" || !RegExMatch(caminho, "i)\.(png|bmp)$")
        return ""
    if !RegExMatch(caminho, "i)^(?:[a-z]:\\|\\\\)")
        caminho := A_ScriptDir "\" caminho
    atributos := FileExist(caminho)
    return atributos != "" && !InStr(atributos, "D") ? caminho : ""
}

; ============================================
; LEITURA VISUAL DO ROBLOX
; ============================================

; Retorna somente o cliente totalmente visivel e em primeiro plano.
; Uma leitura indisponivel nunca conta como desaparecimento da interface.
AreaRoblox() {
    global roboHwnd
    if !roboHwnd || !WinExist("ahk_id " roboHwnd)
        return false
    try {
        if !WinActive("ahk_id " roboHwnd) || WinGetMinMax("ahk_id " roboHwnd) = -1
            return false
        WinGetClientPos(&x, &y, &w, &h, "ahk_id " roboHwnd)
        if w < 200 || h < 200
            return false
        if x < SysGet(76) || y < SysGet(77)
            || x + w > SysGet(76) + SysGet(78)
            || y + h > SysGet(77) + SysGet(79)
            return false
        ; Rejeita sobreposicoes de outras janelas, inclusive always-on-top.
        for hwnd in WinGetList() {
            if hwnd = roboHwnd
                break
            if !DllCall("IsWindowVisible", "Ptr", hwnd, "Int")
                continue
            try {
                if WinGetMinMax("ahk_id " hwnd) = -1
                    continue
                WinGetPos(&ox, &oy, &ow, &oh, "ahk_id " hwnd)
                if ow > 0 && oh > 0 && ox < x+w && oy < y+h && ox+ow > x && oy+oh > y
                    return false
            }
        }
        return {x:x, y:y, w:w, h:h}
    }
    catch
        return false
}

EncontrarImagem(caminho, variacao := 25) {
    global avisosImagem
    imagem := ResolverImagem(caminho)
    area := AreaRoblox()
    if imagem = "" || !IsObject(area) {
        if imagem = "" && caminho != "" && !avisosImagem.Has(caminho) {
            avisosImagem[caminho] := true
            Log("AVISO", "Referencia ausente: " caminho)
        }
        return -1
    }
    try {
        return ImageSearch(&fx, &fy, area.x, area.y,
            area.x + area.w - 1, area.y + area.h - 1, "*" variacao " " imagem)
    }
    catch as erro {
        if !avisosImagem.Has(caminho) {
            avisosImagem[caminho] := true
            Log("ERRO", "Busca indisponivel: " erro.Message)
        }
        return -1
    }
}

VerificarGuiaVisual() {
    global pausado, etapaGuia
    global imagemLobby, imagemPlay, imagemEntrada
    global framesLobby, framesPlay, framesEntrada
    global lobbyDetectado, playVisivel, entradaVisivel

    if pausado
        return

    if etapaGuia = 1 {
        if imagemLobby = ""
            return

        achou := EncontrarImagem(imagemLobby)
        framesLobby := achou = 1 ? Min(framesLobby + 1, 2) : 0

        if framesLobby >= 2 && !lobbyDetectado
            ConfirmarLobby("imagem")
    }
    else if etapaGuia = 2 && !playVisivel {
        if imagemPlay = ""
            return

        achou := EncontrarImagem(imagemPlay)
        framesPlay := achou = 1 ? Min(framesPlay + 1, 2) : 0

        if framesPlay >= 2 {
            playVisivel := true
            AtualizarGuia()
            Log("VISUAL", "Play identificado.")
        }
    }
    else if etapaGuia = 3 && !entradaVisivel {
        if imagemEntrada = ""
            return

        achou := EncontrarImagem(imagemEntrada)
        framesEntrada := achou = 1 ? Min(framesEntrada + 1, 2) : 0

        if framesEntrada >= 2 {
            entradaVisivel := true
            AtualizarGuia()
            Log("VISUAL", "Entrada identificada.")
        }
    }
}

; ============================================
; CATALOGO DE CARTAS
; ============================================

CarregarCatalogo() {
    global catalogo, arquivoCartas, framesCartas

    catalogo := []
    framesCartas := Map()

    if !FileExist(arquivoCartas) {
        Log(
            "AVISO",
            "cartas_fools_hunt.ini nao encontrado."
        )
        return
    }

    try {
        totalTexto := IniRead(
            arquivoCartas, "Catalogo", "Total", "0"
        )

        if !RegExMatch(totalTexto, "^\d{1,3}$") || Integer(totalTexto) > 100
            throw Error("Total invalido.")

        total := Min(Integer(totalTexto), 100)

        Loop total {
            secao := "Carta" A_Index
            nome := Trim(IniRead(arquivoCartas, secao, "Nome", ""))
            if nome = "" {
                Log("AVISO", secao " ignorada: nome ausente.")
                continue
            }

            carta := {
                numero: A_Index,

                nome: nome,

                tipo: IniRead(
                    arquivoCartas, secao,
                    "Tipo", "Nao classificado"
                ),

                moedas: IniRead(
                    arquivoCartas, secao,
                    "AprilCoins", "?"
                ),

                efeito: IniRead(
                    arquivoCartas, secao,
                    "Efeito", "Nao informado"
                ),

                imagem: IniRead(
                    arquivoCartas, secao,
                    "Imagem", ""
                )
            }

            catalogo.Push(carta)
        }

        ; Um mesmo recorte nao pode identificar duas cartas diferentes.
        imagens := Map()
        imagens.CaseSense := false
        for carta in catalogo {
            caminho := ResolverImagem(carta.imagem)
            if caminho = ""
                continue
            if imagens.Has(caminho) {
                imagens[caminho].imagem := ""
                carta.imagem := ""
                Log("AVISO", "Referencia compartilhada por varias cartas; identificacao desativada: " caminho)
            }
            else
                imagens[caminho] := carta
        }

        Log(
            "OK",
            "Catalogo carregado: "
            catalogo.Length " cartas."
        )
    }
    catch as erro {
        Log("ERRO", "Catalogo: " erro.Message)
    }
}

MostrarCatalogo(*) {
    global catalogo

    CarregarCatalogo()

    if catalogo.Length = 0 {
        MsgBox(
            "Nenhuma carta encontrada no catalogo.",
            "Anime Panel v14"
        )
        return
    }

    texto := "CARTAS DO FOOL'S HUNT`n`n"

    for carta in catalogo {
        texto .= carta.numero ". " carta.nome "`n"
        texto .= "Tipo: " carta.tipo "`n"
        texto .= "AprilCoins: +" carta.moedas "%`n"
        texto .= "Efeito: " carta.efeito "`n"
        texto .= "Imagem: "
            . (ResolverImagem(carta.imagem) != ""
                ? "Configurada"
                : "Pendente")
            . "`n`n"
    }

    MsgBox(texto, "Anime Panel - Catalogo")
}

AssociarImagemCarta(*) {
    global catalogo, arquivoCartas

    CarregarCatalogo()

    if catalogo.Length = 0 {
        MsgBox("O catalogo esta vazio.")
        return
    }

    lista := ""

    for indice, carta in catalogo
        lista .= indice ". " carta.nome "`n"

    resposta := InputBox(
        "Digite o numero da carta:`n`n" lista,
        "Cadastrar imagem",
        "w430 h300"
    )

    if resposta.Result != "OK"
        return

    texto := Trim(resposta.Value)

    if !RegExMatch(texto, "^\d{1,3}$") {
        MsgBox("Digite um numero valido.")
        return
    }

    numero := Integer(texto)

    if numero < 1 || numero > catalogo.Length {
        MsgBox("Numero de carta invalido.")
        return
    }

    imagem := FileSelect(
        1,
        A_ScriptDir,
        "Imagem de " catalogo[numero].nome,
        "Imagens (*.png; *.bmp)"
    )

    if imagem = ""
        return

    if !ValidarReferencia(imagem) || !SalvarChave(imagem, arquivoCartas,
        "Carta" catalogo[numero].numero, "Imagem")
        return

    CarregarCatalogo()

    Log(
        "OK",
        "Imagem vinculada a " catalogo[numero].nome
    )
}

; ============================================
; DETECTOR DE CARTAS
; ============================================

VerificarVotacao() {
    global pausado, imagemVotacao
    global votacaoAberta, framesVotacao
    global ausenciaVotacao
    global cartasEncontradas, catalogo, framesCartas
    global detectorStatus

    if pausado || imagemVotacao = ""
        return

    if !IsObject(AreaRoblox()) {
        framesVotacao := 0
        ausenciaVotacao := 0
        framesCartas := Map()
        return
    }

    achou := EncontrarImagem(imagemVotacao, 25)
    if achou = -1 {
        framesVotacao := 0
        ausenciaVotacao := 0
        framesCartas := Map()
        return
    }

    if achou {
        framesVotacao := Min(framesVotacao + 1, 2)
        ausenciaVotacao := 0
    }
    else {
        framesVotacao := 0
        framesCartas := Map()

        if votacaoAberta
            ausenciaVotacao += 1
    }

    if framesVotacao >= 2 && !votacaoAberta {
        votacaoAberta := true
        cartasEncontradas := Map()
        framesCartas := Map()
        Log("AVISO", "Opcoes ainda nao identificadas. Somente referencias conhecidas podem ser reconhecidas.")

        AtualizarDetectorStatus()

        Log(
            "VISUAL",
            "Choose a card detectado."
        )
    }

    if votacaoAberta && ausenciaVotacao >= 3 {
        Log("INFO", "Fim da votacao nao confirma a carta escolhida. Registre o efeito com F7.")
        votacaoAberta := false
        ausenciaVotacao := 0

        AtualizarDetectorStatus()

        Log(
            "VISUAL",
            "Tela de votacao nao esta mais visivel."
        )

        return
    }

    if !votacaoAberta || !achou
        return

    for carta in catalogo {
        if carta.imagem = ""
            continue

        if cartasEncontradas.Has(carta.numero)
            continue

        resultado := EncontrarImagem(carta.imagem, 25)
        framesCartas[carta.numero] := resultado = 1
            ? (framesCartas.Has(carta.numero) ? framesCartas[carta.numero] + 1 : 1) : 0
        if framesCartas[carta.numero] >= 2 {
            cartasEncontradas[carta.numero] := true

            Log("CARTA", carta.nome)
            Log("EFEITO", carta.efeito)

            Log(
                "MOEDAS",
                "+" carta.moedas "% AprilCoins"
            )
        }
    }
}

; ============================================
; DETECTOR DE CAPTCHA / MATCHMAKING
; ============================================

VerificarCaptcha() {
    global pausado, imagemCaptcha
    global captchaAberto, framesCaptcha
    global ausenciaCaptcha
    global detectorStatus, estadoFila

    if pausado || imagemCaptcha = ""
        return

    if !IsObject(AreaRoblox()) {
        framesCaptcha := 0
        ausenciaCaptcha := 0
        return
    }

    achou := EncontrarImagem(imagemCaptcha, 25)
    if achou = -1 {
        framesCaptcha := 0
        ausenciaCaptcha := 0
        return
    }

    if achou {
        framesCaptcha := Min(framesCaptcha + 1, 2)
        ausenciaCaptcha := 0
    }
    else {
        framesCaptcha := 0

        if captchaAberto
            ausenciaCaptcha += 1
    }

    if framesCaptcha >= 2 && !captchaAberto {
        captchaAberto := true
        estadoFila := "Verificacao manual pendente"

        AtualizarDetectorStatus()

        Log(
            "MATCH",
            "CAPTCHA detectado. Preencha no Roblox."
        )

        Log(
            "MATCH",
            "O painel nao le nem digita os numeros."
        )
    }

    if captchaAberto && ausenciaCaptcha >= 3 {
        captchaAberto := false
        estadoFila := "Aguardando confirmacao independente"
        ausenciaCaptcha := 0

        AtualizarDetectorStatus()

        Log(
            "MATCH",
            "CAPTCHA nao esta mais visivel."
        )

        Log(
            "MATCH",
            "Confirme a entrada na fila com F11."
        )
    }
}

; ============================================
; PAUSA
; ============================================

AlternarPausa(*) {
    global pausado, pausar

    pausado := !pausado
    ReiniciarContagens()
    AtualizarDetectorStatus()

    pausar.Text := pausado
        ? "Retomar (F6)"
        : "Pausar (F6)"

    Log(
        "INFO",
        pausado
            ? "Monitoramento pausado."
            : "Monitoramento retomado."
    )
}

; ============================================
; LOCALIZAR ROBLOX
; ============================================

ProcurarRoblox() {
    melhor := 0
    maiorArea := 0

    try {
        for hwnd in WinGetList(
            "ahk_exe RobloxPlayerBeta.exe"
        ) {
            if !DllCall(
                "user32\IsWindowVisible",
                "Ptr", hwnd, "Int"
            )
                continue

            try {
                WinGetPos(
                    &x, &y, &w, &h,
                    "ahk_id " hwnd
                )

                if w * h > maiorArea {
                    maiorArea := w * h
                    melhor := hwnd
                }
            }
        }
    }

    return melhor
}

DetectarRoblox(*) {
    global roboHwnd, status

    if roboHwnd && WinExist("ahk_id " roboHwnd)
        return

    DesconectarRoblox()
    roboHwnd := ProcurarRoblox()

    if !roboHwnd {
        status.Text := "ROBLOX NAO ENCONTRADO"
        Log("AVISO", "Abra o Roblox em modo janela.")
        return
    }

    status.Text := "ROBLOX DETECTADO"

    Log(
        "OK",
        "Janela do Roblox encontrada."
    )
}

LocalizarMonitor(hwnd) {
    WinGetPos(
        &x, &y, &w, &h,
        "ahk_id " hwnd
    )

    cx := x + w / 2
    cy := y + h / 2

    Loop MonitorGetCount() {
        MonitorGet(A_Index, &l, &t, &r, &b)

        if cx >= l && cx < r && cy >= t && cy < b
            return A_Index
    }

    return MonitorGetPrimary()
}

; ============================================
; ENCAIXAR ROBLOX
; ============================================

EncaixarRoblox(*) {
    global roboHwnd, encaixado
    global janelaOriginal, monitorAlvo
    global status, semBorda, semBordaAplicado

    if !roboHwnd || !WinExist("ahk_id " roboHwnd)
        DetectarRoblox()

    if !roboHwnd
        return

    alvo := "ahk_id " roboHwnd

    try {
        Critical("On")
        if !encaixado {
            estado := WinGetMinMax(alvo)
            estilo := WinGetStyle(alvo)
            exEstilo := WinGetExStyle(alvo)
            posicionamento := Buffer(44, 0)
            NumPut("UInt", 44, posicionamento)
            if !DllCall("user32\GetWindowPlacement", "Ptr", roboHwnd, "Ptr", posicionamento, "Int")
                throw OSError()

            ; Capturar antes de modificar a janela, inclusive minimizada/maximizada.
            janelaOriginal := {
                hwnd:roboHwnd, pid:WinGetPID(alvo), placement:posicionamento,
                style:estilo, exstyle:exEstilo
            }
            encaixado := true

            if estado != 0
                WinRestore(alvo)

            monitorAlvo := LocalizarMonitor(roboHwnd)

            if semBorda.Value {
                WinSetStyle(
                    WinGetStyle(alvo) & ~0x00C40000, alvo
                )
                semBordaAplicado := true

                DllCall(
                    "user32\SetWindowPos",
                    "Ptr", roboHwnd,
                    "Ptr", 0,
                    "Int", 0, "Int", 0,
                    "Int", 0, "Int", 0,
                    "UInt", 0x27,
                    "Int"
                )

            }
        }

        if !AjustarLayout() {
            RestaurarRoblox()
            return
        }

        status.Text := "CONECTADO - ENCAIXADO"

        Log(
            "OK",
            "Roblox encaixado ao lado do painel."
        )
    }
    catch as erro {
        Log("ERRO", "Encaixe: " erro.Message " (" erro.What ", linha " erro.Line ")")
        RestaurarRoblox()
    }
    finally
        Critical("Off")
}

AjustarLayout() {
    global painel, roboHwnd, monitorAlvo

    if !roboHwnd || !WinExist("ahk_id " roboHwnd)
        return false

    MonitorGetWorkArea(
        monitorAlvo, &l, &t, &r, &b
    )

    sw := r - l
    sh := b - t

    pw := Min(Max(560, Min(610, Round(sw * 0.38))), sw - 532)
    jw := sw - pw - 2

    if pw < 560 || jw < 530 || sh < 750 {
        Log(
            "AVISO",
            "Espaco insuficiente para a interface."
        )
        return false
    }

    WinMove(
        l, t, jw, sh,
        "ahk_id " roboHwnd
    )

    WinMove(
        l + jw + 2, t, pw, sh,
        "ahk_id " painel.Hwnd
    )

    WinGetClientPos(, , &cw, &ch, "ahk_id " painel.Hwnd)
    AjustarControles(cw, ch)
    return true
}

AjustarControles(w, h) {
    global barra, titulo, fechar
    global status, detectar, encaixar, restaurar
    global semBorda, guiaTitulo, instrucao
    global escolherLobby, escolherPlay, escolherEntrada
    global confirmarLobbyBtn, confirmarPlayBtn, avancarBtn
    global unidadesTitulo, cabNome, cabQtd
    global cabPrior, cabHab, cabUp, listaUnidades
    global labelPadrao, campoPadrao
    global labelVel, campoVel, prefRepetir, prefFila
    global salvar, pausar, catalogoBtn
    global escolherVotacao, escolherCaptcha
    global escolherCarta, detectorStatus, console

    area := w - 28
    bw := Floor((area - 18) / 3)

    barra.Move(0, 0, w, 38)
    titulo.Move(14, 7, w - 110, 26)
    fechar.Move(w - 92, 6, 76, 26)
    status.Move(14, 45, area, 20)

    detectar.Move(14, 71, bw, 30)
    encaixar.Move(14 + bw + 9, 71, bw, 30)
    restaurar.Move(14 + (bw + 9) * 2, 71, bw, 30)

    semBorda.Move(14, 106, area, 22)
    guiaTitulo.Move(14, 136, area, 24)
    instrucao.Move(14, 164, area, 40)

    escolherLobby.Move(14, 205, bw, 24)
    escolherPlay.Move(14 + bw + 9, 205, bw, 24)
    escolherEntrada.Move(
        14 + (bw + 9) * 2, 205, bw, 24
    )

    confirmarLobbyBtn.Move(14, 234, bw, 30)
    confirmarPlayBtn.Move(14 + bw + 9, 234, bw, 30)
    avancarBtn.Move(
        14 + (bw + 9) * 2, 234, bw, 30
    )

    unidadesTitulo.Move(14, 278, area, 22)

    cabNome.Move(14, 302, 63, 19)
    cabQtd.Move(80, 302, 52, 19)
    cabPrior.Move(144, 302, 56, 19)
    cabHab.Move(216, 302, 110, 19)
    cabUp.Move(w - 110, 302, 100, 19)

    for i, unidade in listaUnidades {
        y := 325 + (i - 1) * 26

        unidade.nome.Move(14, y + 3, 62, 22)
        unidade.qtd.Move(80, y, 46, 23)
        unidade.prio.Move(144, y, 56, 23)
        unidade.hab.Move(216, y, 100, 23)
        unidade.upgrade.Move(w - 110, y, 94, 23)
    }

    labelPadrao.Move(14, 493, 112, 22)
    campoPadrao.Move(140, 489, w - 154, 25)

    labelVel.Move(14, 524, 112, 22)
    campoVel.Move(140, 520, w - 154, 25)

    prefRepetir.Move(14, 553, Floor(area / 2), 23)

    prefFila.Move(
        14 + Floor(area / 2),
        553, Ceil(area / 2), 23
    )

    salvar.Move(14, 585, bw, 29)
    pausar.Move(14 + bw + 9, 585, bw, 29)
    catalogoBtn.Move(
        14 + (bw + 9) * 2, 585, bw, 29
    )

    escolherVotacao.Move(14, 625, bw, 28)
    escolherCaptcha.Move(14 + bw + 9, 625, bw, 28)
    escolherCarta.Move(
        14 + (bw + 9) * 2, 625, bw, 28
    )

    detectorStatus.Move(14, 660, area, 20)

    console.Move(
        14, 686, area, Max(40, h - 700)
    )
}

; ============================================
; RESTAURAR ROBLOX
; ============================================

RestaurarRoblox(*) {
    global roboHwnd, encaixado
    global janelaOriginal, status
    global semBordaAplicado

    if (
        roboHwnd
        && IsObject(janelaOriginal)
        && WinExist("ahk_id " roboHwnd)
    ) {
        alvo := "ahk_id " roboHwnd

        try {
            Critical("On")
            if janelaOriginal.hwnd != roboHwnd || WinGetPID(alvo) != janelaOriginal.pid
                throw Error("A janela mudou; restauracao cancelada para proteger outro processo.")
            WinRestore(alvo)
            ; Estado min/max e aplicado por SetWindowPlacement, nao pelos bits de estilo.
            WinSetStyle(janelaOriginal.style & ~0x21000000, alvo)
            WinSetExStyle(janelaOriginal.exstyle, alvo)

            if !DllCall(
                    "user32\SetWindowPos",
                    "Ptr", roboHwnd,
                    "Ptr", 0,
                    "Int", 0, "Int", 0,
                    "Int", 0, "Int", 0,
                    "UInt", 0x27,
                    "Int"
            )
                throw OSError()
            if !DllCall("user32\SetWindowPlacement", "Ptr", roboHwnd,
                "Ptr", janelaOriginal.placement, "Int")
                throw OSError()
        }
        catch as erro {
            Log("ERRO", "Restaurar: " erro.Message)
            status.Text := "RESTAURACAO PENDENTE - TENTE F9"
            ; Manter snapshot e HWND para permitir uma nova tentativa.
            return false
        }
        finally
            Critical("Off")
    }

    DesconectarRoblox()
    status.Text := "DESCONECTADO"
    Log("INFO", "Restauracao/desconexao concluida.")
    return true
}

VerificarJanelas() {
    global roboHwnd, encaixado, status

    if roboHwnd && !WinExist("ahk_id " roboHwnd) {
        DesconectarRoblox()
        status.Text := "ROBLOX FECHADO"
        Log("AVISO", "Janela do Roblox fechada.")
    }
}

; ============================================
; SALVAR E CARREGAR PERFIL
; ============================================

SalvarPerfil(*) {
    global arquivoINI, listaUnidades
    global campoPadrao, campoVel
    global prefRepetir, prefFila, semBorda, carregandoPerfil
    if carregandoPerfil
        return false
    temporario := arquivoINI ".tmp"

    try {
        Critical("On")
        if FileExist(arquivoINI)
            FileCopy(arquivoINI, temporario, true)
        else {
            if FileExist(temporario)
                FileDelete(temporario)
        }
        IniWrite(semBorda.Value, temporario, "Geral", "SemBorda")
        IniWrite(
            campoPadrao.Text,
            temporario, "Geral", "Padrao"
        )

        IniWrite(
            campoVel.Text,
            temporario, "Geral", "Velocidade"
        )

        IniWrite(
            prefRepetir.Value,
            temporario, "Geral", "Repetir"
        )

        IniWrite(
            prefFila.Value,
            temporario, "Geral", "Fila"
        )

        for i, unidade in listaUnidades {
            secao := "Unit" i
            IniWrite(unidade.nome.Value, temporario, secao, "Nome")

            IniWrite(
                QuantidadeValida(unidade.qtd.Value),
                temporario, secao, "Quantidade"
            )

            IniWrite(
                unidade.prio.Text,
                temporario, secao, "Prioridade"
            )

            IniWrite(
                unidade.hab.Value,
                temporario, secao, "Habilidade"
            )

            IniWrite(
                unidade.upgrade.Value,
                temporario, secao, "Upgrade"
            )
        }

        FileMove(temporario, arquivoINI, true)
        Log("OK", "Perfil salvo.")
        return true
    }
    catch as erro {
        Log("ERRO", "Salvar: " erro.Message)
        return false
    }
    finally
        Critical("Off")
}

CarregarPerfil() {
    global arquivoINI
    global imagemLobby, imagemPlay, imagemEntrada
    global imagemVotacao, imagemCaptcha
    global listaUnidades, campoPadrao, campoVel
    global prefRepetir, prefFila, semBorda, carregandoPerfil

    if !FileExist(arquivoINI) {
        for versao in ["v13", "v12", "v11"] {
            anterior := A_ScriptDir "\anime_panel_" versao ".ini"

            if FileExist(anterior) {
                try FileCopy(anterior, arquivoINI, true)
                break
            }
        }
    }

    if !FileExist(arquivoINI)
        return

    try {
        carregandoPerfil := true
        semBorda.Value := IniRead(arquivoINI, "Geral", "SemBorda", "0") = "1"
        imagemLobby := IniRead(
            arquivoINI, "Guia", "ImagemLobby", ""
        )

        imagemPlay := IniRead(
            arquivoINI, "Guia", "ImagemPlay", ""
        )

        imagemEntrada := IniRead(
            arquivoINI, "Guia", "ImagemEntrada", ""
        )

        imagemVotacao := IniRead(
            arquivoINI, "Deteccao", "ImagemVotacao", ""
        )

        imagemCaptcha := IniRead(
            arquivoINI, "Deteccao", "ImagemCaptcha", ""
        )

        EscolherItem(
            campoPadrao,
            IniRead(
                arquivoINI, "Geral", "Padrao", "Manual"
            )
        )

        EscolherItem(
            campoVel,
            IniRead(
                arquivoINI, "Geral", "Velocidade", "Default"
            )
        )

        prefRepetir.Value := BooleanoValido(
            IniRead(
                arquivoINI, "Geral", "Repetir", "0"
            )
        )

        prefFila.Value := BooleanoValido(
            IniRead(
                arquivoINI, "Geral", "Fila", "0"
            )
        )

        for i, unidade in listaUnidades {
            secao := "Unit" i

            unidade.nome.Value := IniRead(arquivoINI, secao, "Nome", "Unit " i)
            unidade.qtd.Value := QuantidadeValida(IniRead(
                arquivoINI, secao, "Quantidade", "1"
            ))

            EscolherItem(
                unidade.prio,
                IniRead(
                    arquivoINI, secao,
                    "Prioridade", String(i)
                )
            )

            unidade.hab.Value := BooleanoValido(
                IniRead(
                    arquivoINI, secao, "Habilidade", "0"
                )
            )

            unidade.upgrade.Value := BooleanoValido(
                IniRead(
                    arquivoINI, secao, "Upgrade", "0"
                )
            )
        }

        Log("OK", "Preferencias carregadas.")
    }
    catch as erro {
        Log("ERRO", "Carregar: " erro.Message)
    }
    finally
        carregandoPerfil := false
}

EscolherItem(controle, texto) {
    controle.Choose(1)
    try controle.Choose(String(texto))
}

; ============================================
; CONSOLE
; ============================================

Log(tipo, mensagem) {
    global historico, console

    historico.Push(
        "[" FormatTime(, "HH:mm:ss")
        . "] [" tipo "] " mensagem
    )

    if historico.Length > 100
        historico.RemoveAt(1)

    texto := ""

    for linha in historico
        texto .= linha "`r`n"

    console.Value := texto
}

AoSair(*) {
    global roboHwnd
    SalvarPerfil()

    if roboHwnd && !RestaurarRoblox()
        return 1
}

AgendarSalvamento(*) {
    global carregandoPerfil
    if carregandoPerfil
        return
    SetTimer(SalvarPerfil, -800)
}

ConfigurarExtra(tipo) {
    global referenciasExtras, framesExtras, arquivoINI
    imagem := FileSelect(1, A_ScriptDir, "Elemento fixo: " tipo, "Imagens (*.png; *.bmp)")
    if imagem = ""
        return
    if !ValidarReferencia(imagem) || !SalvarChave(imagem, arquivoINI, "Deteccao", "Imagem" tipo)
        return
    referenciasExtras[tipo] := imagem
    framesExtras[tipo] := 0
    Log("OK", "Referencia independente configurada: " tipo)
}

VerificarExtras() {
    global pausado, captchaAberto, framesCaptcha, referenciasExtras, framesExtras
    global estadoFila, detectorStatus, etapaGuia
    if pausado || captchaAberto || framesCaptcha > 0 {
        for tipo in framesExtras
            framesExtras[tipo] := 0
        return
    }
    for tipo, imagem in referenciasExtras {
        if imagem = ""
            continue
        resultado := EncontrarImagem(imagem)
        framesExtras[tipo] := resultado = 1 ? Min(framesExtras[tipo] + 1, 2) : 0
        if framesExtras[tipo] != 2
            continue
        if tipo = "Fila" {
            if estadoFila = "Partida em andamento" || estadoFila = "Fila publica confirmada por imagem"
                || estadoFila = "Confirmada manualmente"
                continue
            estadoFila := "Fila publica confirmada por imagem"
            etapaGuia := 6
        }
        else {
            if estadoFila = "Partida em andamento"
                continue
            estadoFila := "Partida em andamento"
            etapaGuia := 6
        }
        AtualizarDetectorStatus()
        Log("VISUAL", estadoFila)
        AtualizarGuia()
    }
}

RegistrarObservacao(*) {
    global waveAtual, efeitosManuais
    resposta := InputBox("Digite wave: NUMERO, efeito: TEXTO ou uma observacao livre."
        . "`nRegistre apenas o que voce confirmou no jogo.", "Registro manual (F7)", "w490 h160")
    if resposta.Result != "OK" || Trim(resposta.Value) = ""
        return
    texto := Trim(resposta.Value)
    if RegExMatch(texto, "i)^wave:\s*(\d+)$", &m) {
        waveAtual := Integer(m[1])
        Log("WAVE MANUAL", String(waveAtual))
    }
    else if RegExMatch(texto, "i)^efeito:\s*(.+)$", &m) {
        efeitosManuais.Push(m[1])
        Log("EFEITO MANUAL", m[1])
    }
    else
        Log("MANUAL", texto)
}

MostrarEfeitos(*) {
    global efeitosManuais, waveAtual
    texto := "Wave registrada manualmente: " waveAtual "`n`nHistorico manual de efeitos (nao verifica Current Effects):`n"
    for efeito in efeitosManuais
        texto .= efeito "`n"
    MsgBox(texto, "Efeitos da sessao")
}

; Funcoes de estabilizacao: nenhum dado do jogo e lido fora da tela.
MonitorarVisual() {
    global pausado, captchaAberto, framesCaptcha, framesVotacao, ausenciaVotacao, framesCartas
    if pausado || !IsObject(AreaRoblox()) {
        ReiniciarContagens()
        return
    }
    VerificarCaptcha()
    if captchaAberto || framesCaptcha > 0 {
        framesVotacao := 0
        ausenciaVotacao := 0
        framesCartas := Map()
        VerificarExtras() ; Apenas zera os contadores durante verificacao manual.
        return
    }
    VerificarGuiaVisual()
    VerificarVotacao()
    VerificarExtras()
}

ReiniciarContagens() {
    global framesLobby, framesPlay, framesEntrada, framesVotacao, framesCaptcha
    global ausenciaVotacao, ausenciaCaptcha, framesCartas, framesExtras
    framesLobby := framesPlay := framesEntrada := framesVotacao := framesCaptcha := 0
    ausenciaVotacao := ausenciaCaptcha := 0
    framesCartas := Map()
    for tipo in framesExtras
        framesExtras[tipo] := 0
}

ReiniciarDeteccao() {
    global etapaGuia, lobbyDetectado, playVisivel, entradaVisivel
    global votacaoAberta, captchaAberto, cartasEncontradas, estadoFila
    ReiniciarContagens()
    etapaGuia := 1
    lobbyDetectado := playVisivel := entradaVisivel := false
    votacaoAberta := captchaAberto := false
    cartasEncontradas := Map()
    estadoFila := "Nao confirmada"
    AtualizarGuia()
    AtualizarDetectorStatus()
}

DesconectarRoblox() {
    global roboHwnd, encaixado, janelaOriginal, monitorAlvo, semBordaAplicado
    roboHwnd := 0
    encaixado := false
    janelaOriginal := 0
    monitorAlvo := 0
    semBordaAplicado := false
    ReiniciarDeteccao()
}

AtualizarDetectorStatus() {
    global detectorStatus, pausado, captchaAberto, votacaoAberta, estadoFila
    if pausado
        detectorStatus.Text := "MONITORAMENTO PAUSADO (F6)"
    else if captchaAberto
        detectorStatus.Text := "AGUARDANDO VERIFICACAO MANUAL"
    else if estadoFila = "Aguardando confirmacao independente"
        detectorStatus.Text := "CAPTCHA SAIU DA TELA - VERIFIQUE A FILA"
    else if votacaoAberta
        detectorStatus.Text := "VOTACAO ABERTA - CHOOSE A CARD!"
    else
        detectorStatus.Text := "MATCHMAKING: " estadoFila
}

BooleanoValido(valor) {
    return Trim(String(valor)) = "1" ? 1 : 0
}

QuantidadeValida(valor) {
    ; Limite de armazenamento, nao limite de unidades do jogo.
    texto := Trim(String(valor))
    return RegExMatch(texto, "^\d{1,6}$") ? Integer(texto) : 1
}

SalvarChave(valor, arquivo, secao, chave) {
    try {
        IniWrite(valor, arquivo, secao, chave)
        return true
    }
    catch as erro {
        Log("ERRO", "Nao foi possivel salvar " chave ": " erro.Message)
        return false
    }
}

ValidarReferencia(caminho) {
    global avisosImagem
    imagem := ResolverImagem(caminho)
    try {
        if imagem = ""
            throw Error("Selecione um arquivo PNG/BMP existente.")
        bitmap := LoadPicture(imagem)
        if !bitmap
            throw Error("Imagem invalida ou corrompida.")
        DllCall("gdi32\DeleteObject", "Ptr", bitmap)
        if avisosImagem.Has(caminho)
            avisosImagem.Delete(caminho)
        return true
    }
    catch as erro {
        Log("AVISO", "Referencia nao configurada: " erro.Message)
        return false
    }
}
