;=================================================================
;  PoE Svintus LIFE – all mouse moves use mouse_event (AHK v1)
;=================================================================
#SingleInstance Force
#Persistent
#NoEnv
CoordMode, Mouse, Screen
SetDefaultMouseSpeed, 0
SetKeyDelay, 0, 0

; ========= Global Variables =========
global borderThickness := 8
global minDelay := 30
global itemPrice := 120
global itemQty := 2
global league := "Keepers"
global apiURL := "https://poe.ninja/api/data/currencyoverview?league=" . league . "&type=Currency&language=en"
global ConfigINI := A_ScriptDir "\Config.ini"
global F1_Mode := 1
global AutoRunning := false
global AutoIndex := 1
global DeleteToggle := false
global SearchIndex := 1
global F11_State := -1
global BeastDeletedGood := 0
global BeastDeletedBad := 0
global BeastStoredGood := 0
global BeastStoredBad := 0
global StatsWindowVisible := false
global GuiHwnd
global StatsGuiHwnd
global MySlider
global StatsSlider
global StatusLabel
global StatusFunction
global BeastModeText
global BeastStatusText
global BeastStatsText
global DivineRate
global ItemPriceDIV
global DivineGet
global ChaosGet
global Return
global StatsDelGood
global StatsDelBad
global StatsStrGood
global StatsStrBad
global GoodBeasts
global BadBeast1
global BadBeast2

; GemSwap Variables
global GemSwapMode := 1  ; 1 = 2 gems, 2 = 3 gems
global GemSwapSetupState := -1
global Gem1InvX := 0
global Gem1InvY := 0
global Gem2InvX := 0
global Gem2InvY := 0
global Gem3InvX := 0
global Gem3InvY := 0
global Gem1SocketX := 0
global Gem1SocketY := 0
global Gem2SocketX := 0
global Gem2SocketY := 0
global Gem3SocketX := 0
global Gem3SocketY := 0

; Key Spam Variables (renamed from Detonate Dead)
global DetonateRunning := false
global DetonateDelay := 100
global SpamKey1 := "d"
global SpamKey2 := ""
global SpamDualMode := false
global SpamHoldMode := false  ; false = Spam, true = Hold

; Weapon Swap Variables
global WeaponSwapEnabled := false
global WeaponSwapHotkey := "q"
global WeaponSwapSkillKey := "q"
global WeaponSwapButton := "x"
global WeaponSwapBackButton := "x"
global WeaponSwapDelayAfter := 120
global WeaponSwapDelaySkill := 300

; Stash Variables
global StashSetupState := -1
global StashStartX := 0
global StashStartY := 0
global StashRows := 5
global StashCols := 12
global StashSlotWidth := 53
global StashSlotHeight := 53

; Scour + Alch Variables
global ScourAlchSetupState := -1
global ScourX := 0
global ScourY := 0
global AlchX := 0
global AlchY := 0
global MapX := 0
global MapY := 0
global ScourAlchLoopEnabled := false
global ScourAlchRunning := false

; Chaos Orb Variables
global ChaosX := 0
global ChaosY := 0
global ChaosMode := 1  ; 1 = Scour+Alch, 2 = Chaos Orb
global ChaosRunning := false
global ChaosDelay := 100
global RegexStopEnabled := true
global RegexStopColor := 0xe7b477  ; Yellow border color for regex match
global debugCounter := 0
global RegexCheckX1 := 0  ; Top-left corner of search area
global RegexCheckY1 := 0
global RegexCheckX2 := 0  ; Bottom-right corner of search area
global RegexCheckY2 := 0
global RegexAreaSetupState := -1

; Ensure INI file exists with required sections and defaults
if not FileExist(ConfigINI) {
    ; Key Spam settings
    IniWrite, d, %ConfigINI%, KeySpam, SpamKey1
    IniWrite, 0, %ConfigINI%, KeySpam, SpamDualMode
    IniWrite, 0, %ConfigINI%, KeySpam, SpamHoldMode
    IniWrite, 0, %ConfigINI%, GridPos,    gridposX1
    IniWrite, 0, %ConfigINI%, GridPos,    gridposY1
    IniWrite, 0, %ConfigINI%, BeastPos,   posX
    IniWrite, 0, %ConfigINI%, BeastPos,   posY
    IniWrite, 0, %ConfigINI%, DeletePos,  posX
    IniWrite, 0, %ConfigINI%, DeletePos,  posY
    IniWrite, 155, %ConfigINI%, Settings, DivineRate
    IniWrite, 100, %ConfigINI%, Settings, DetonateDelay
    IniWrite, k m|id w|cic c|id v|le m|s f|l pla|ld h|ul f|d bra|n f| cy|al f|c sp|l hy|e rhe|c ti|c l|f a|c v, %ConfigINI%, BeastStrings, GoodBeasts
    IniWrite, cic m|x ma|c fr|c san|c sav|l cru|e vu|d ab|c sh| sq|c wa|c a|rric c|c fl|c ga|c goa, %ConfigINI%, BeastStrings, BadBeast1
    IniWrite, c gol|ma h|c pi|ic ta|c u|mal d|l q|l sco|l scr|l w|ne b|ne ch|ne co|ne re|ine rho, %ConfigINI%, BeastStrings, BadBeast2
    ; GemSwap positions
    IniWrite, 0, %ConfigINI%, GemSwap, Gem1InvX
    IniWrite, 0, %ConfigINI%, GemSwap, Gem1InvY
    IniWrite, 0, %ConfigINI%, GemSwap, Gem2InvX
    IniWrite, 0, %ConfigINI%, GemSwap, Gem2InvY
    IniWrite, 0, %ConfigINI%, GemSwap, Gem3InvX
    IniWrite, 0, %ConfigINI%, GemSwap, Gem3InvY
    IniWrite, 0, %ConfigINI%, GemSwap, Gem1SocketX
    IniWrite, 0, %ConfigINI%, GemSwap, Gem1SocketY
    IniWrite, 0, %ConfigINI%, GemSwap, Gem2SocketX
    IniWrite, 0, %ConfigINI%, GemSwap, Gem2SocketY
    IniWrite, 0, %ConfigINI%, GemSwap, Gem3SocketX
    IniWrite, 0, %ConfigINI%, GemSwap, Gem3SocketY
    ; Stash positions
    IniWrite, 0, %ConfigINI%, Stash, StartX
    IniWrite, 0, %ConfigINI%, Stash, StartY
    IniWrite, 5, %ConfigINI%, Stash, Rows
    IniWrite, 12, %ConfigINI%, Stash, Cols
    IniWrite, 53, %ConfigINI%, Stash, SlotWidth
    IniWrite, 53, %ConfigINI%, Stash, SlotHeight
    ; Scour + Alch positions
    IniWrite, 0, %ConfigINI%, ScourAlch, ScourX
    IniWrite, 0, %ConfigINI%, ScourAlch, ScourY
    IniWrite, 0, %ConfigINI%, ScourAlch, AlchX
    IniWrite, 0, %ConfigINI%, ScourAlch, AlchY
    IniWrite, 0, %ConfigINI%, ScourAlch, MapX
    IniWrite, 0, %ConfigINI%, ScourAlch, MapY
    ; Chaos Orb positions
    IniWrite, 0, %ConfigINI%, ChaosOrb, ChaosX
    IniWrite, 0, %ConfigINI%, ChaosOrb, ChaosY
    IniWrite, 0, %ConfigINI%, ChaosOrb, RegexCheckX1
    IniWrite, 0, %ConfigINI%, ChaosOrb, RegexCheckY1
    IniWrite, 0, %ConfigINI%, ChaosOrb, RegexCheckX2
    IniWrite, 0, %ConfigINI%, ChaosOrb, RegexCheckY2
    IniWrite, 1, %ConfigINI%, Settings, ChaosMode
    IniWrite, 100, %ConfigINI%, Settings, ChaosDelay
    IniWrite, 1, %ConfigINI%, Settings, RegexStopEnabled
    ; Weapon Swap settings
    IniWrite, 0, %ConfigINI%, WeaponSwap, Enabled
    IniWrite, q, %ConfigINI%, WeaponSwap, Hotkey
    IniWrite, q, %ConfigINI%, WeaponSwap, SkillKey
    IniWrite, x, %ConfigINI%, WeaponSwap, SwapButton
    IniWrite, x, %ConfigINI%, WeaponSwap, SwapBackButton
    IniWrite, 120, %ConfigINI%, WeaponSwap, DelayAfter
    IniWrite, 300, %ConfigINI%, WeaponSwap, DelaySkill
}

; ─────────────────────────────────────────────────────────────────────────────
;  Helper: absolute teleport via mouse_event
; ─────────────────────────────────────────────────────────────────────────────
MoveCursor(xScr, yScr) {
    Static MOVE := 0x0001, ABS := 0x8000
    absX := Round(xScr * 65535 / A_ScreenWidth)
    absY := Round(yScr * 65535 / A_ScreenHeight)
    DllCall("mouse_event", "UInt", MOVE|ABS, "UInt", absX, "UInt", absY, "UInt", 0, "UInt", 0)
}

; === Functions ===
UpdateStatus(statusText) {
    GuiControl,, StatusFunction, %statusText%
}
FormatRate(rate) {
    rate := Round(rate, 1)
    return rate = Floor(rate) ? rate : RTrim(rate, "0")
}

GetCurrentFilterType() {
    global SearchIndex
    if (SearchIndex = 1) {
        return "Good"
    } else if (SearchIndex = 2 || SearchIndex = 3) {
        return "Bad"
    } else {
        return "Unknown"
    }
}

; Stats Functions
UpdateStatsDisplay() {
    global BeastDeletedGood, BeastDeletedBad, BeastStoredGood, BeastStoredBad, StatsWindowVisible
    statsText := "Del G:" . BeastDeletedGood . " B:" . BeastDeletedBad . " | Str G:" . BeastStoredGood . " B:" . BeastStoredBad
    GuiControl,, BeastStatsText, %statsText%
    
    if (StatsWindowVisible) {
        UpdateStatsWindow()
    }
}

ShowStatsWindow() {
    global StatsWindowVisible, BeastDeletedGood, BeastDeletedBad, BeastStoredGood, BeastStoredBad, StatsGuiHwnd
    if (StatsWindowVisible) {
        return
    }
    
    Gui, Stats:New, +AlwaysOnTop +ToolWindow +HwndStatsGuiHwnd, Beast Statistics
    Gui, Stats:Color, 2B2B2B
    Gui, Stats:Font, s10 Bold, Segoe UI
    
    Gui, Stats:Add, Text, x10 y10 w150 h20 Center c0xFF69B4, Beast Statistics
    Gui, Stats:Font, s9 Normal
    
    Gui, Stats:Add, Text, x10 y40 w80 h20 c0xFFFF00, Del Good:
    Gui, Stats:Add, Text, x95 y40 w50 h20 c0xFFFFFF vStatsDelGood, 0
    
    Gui, Stats:Add, Text, x10 y60 w80 h20 c0xFFFF00, Del Bad:
    Gui, Stats:Add, Text, x95 y60 w50 h20 c0xFFFFFF vStatsDelBad, 0
    
    Gui, Stats:Add, Text, x10 y80 w80 h20 c0xFFFF00, Str Good:
    Gui, Stats:Add, Text, x95 y80 w50 h20 c0xFFFFFF vStatsStrGood, 0
    
    Gui, Stats:Add, Text, x10 y100 w80 h20 c0xFFFF00, Str Bad:
    Gui, Stats:Add, Text, x95 y100 w50 h20 c0xFFFFFF vStatsStrBad, 0
    
    ; Alpha slider for stats window
    Gui, Stats:Add, Text, x10 y125 w40 h20 c0xFFFFFF, Alpha:
    Gui, Stats:Add, Slider, x55 y125 w100 h25 vStatsSlider gUpdateStatsTransparency Range50-255 AltSubmit ToolTip, 200
    
    Gui, Stats:Add, Button, x10 y155 w60 h25 gResetSessionStats, Reset
    Gui, Stats:Add, Button, x80 y155 w60 h25 gCloseStatsWindow, Close
    
    Gui, Stats:Show, w160 h190
    StatsWindowVisible := true
    
    ; Set initial transparency
    WinSet, Transparent, 200, ahk_id %StatsGuiHwnd%
    
    UpdateStatsWindow()
}

UpdateStatsWindow() {
    global StatsWindowVisible, BeastDeletedGood, BeastDeletedBad, BeastStoredGood, BeastStoredBad
    if (!StatsWindowVisible) {
        return
    }
    GuiControl, Stats:, StatsDelGood, %BeastDeletedGood%
    GuiControl, Stats:, StatsDelBad, %BeastDeletedBad%
    GuiControl, Stats:, StatsStrGood, %BeastStoredGood%
    GuiControl, Stats:, StatsStrBad, %BeastStoredBad%
}

CloseStatsWindow() {
    global StatsWindowVisible
    Gui, Stats:Destroy
    StatsWindowVisible := false
}

ResetSessionStats() {
    global BeastDeletedGood, BeastDeletedBad, BeastStoredGood, BeastStoredBad, StatsWindowVisible
    MsgBox, 4,, Reset statistics?
    IfMsgBox Yes
    {
        BeastDeletedGood := 0
        BeastDeletedBad := 0
        BeastStoredGood := 0
        BeastStoredBad := 0
        UpdateStatsDisplay()
        if (StatsWindowVisible) {
            UpdateStatsWindow()
        }
    }
}

; ─────────────────────────────────────────────────────────────────────────────
;  Bestiary Functions
; ─────────────────────────────────────────────────────────────────────────────
UpdateBeastModeDisplay() {
    global F1_Mode
    modeText := (F1_Mode = 1) ? "Mode: Store" : "Mode: Delete"
    GuiControl,, BeastModeText, %modeText%
}

; ─────────────────────────────────────────────────────────────────────────────
;  GemSwap Functions
; ─────────────────────────────────────────────────────────────────────────────
UpdateGemSwapModeDisplay() {
    global GemSwapMode
    modeText := (GemSwapMode = 1) ? "Mode: 2 Gems" : "Mode: 3 Gems"
    GuiControl,, GemSwapModeText, %modeText%
}

LoadGemSwapPositions() {
    global ConfigINI, Gem1InvX, Gem1InvY, Gem2InvX, Gem2InvY, Gem3InvX, Gem3InvY
    global Gem1SocketX, Gem1SocketY, Gem2SocketX, Gem2SocketY, Gem3SocketX, Gem3SocketY
    
    IniRead, Gem1InvX, %ConfigINI%, GemSwap, Gem1InvX, 0
    IniRead, Gem1InvY, %ConfigINI%, GemSwap, Gem1InvY, 0
    IniRead, Gem2InvX, %ConfigINI%, GemSwap, Gem2InvX, 0
    IniRead, Gem2InvY, %ConfigINI%, GemSwap, Gem2InvY, 0
    IniRead, Gem3InvX, %ConfigINI%, GemSwap, Gem3InvX, 0
    IniRead, Gem3InvY, %ConfigINI%, GemSwap, Gem3InvY, 0
    IniRead, Gem1SocketX, %ConfigINI%, GemSwap, Gem1SocketX, 0
    IniRead, Gem1SocketY, %ConfigINI%, GemSwap, Gem1SocketY, 0
    IniRead, Gem2SocketX, %ConfigINI%, GemSwap, Gem2SocketX, 0
    IniRead, Gem2SocketY, %ConfigINI%, GemSwap, Gem2SocketY, 0
    IniRead, Gem3SocketX, %ConfigINI%, GemSwap, Gem3SocketX, 0
    IniRead, Gem3SocketY, %ConfigINI%, GemSwap, Gem3SocketY, 0
}

LoadStashPositions() {
    global ConfigINI, StashStartX, StashStartY, StashRows, StashCols, StashSlotWidth, StashSlotHeight
    
    IniRead, StashStartX, %ConfigINI%, Stash, StartX, 0
    IniRead, StashStartY, %ConfigINI%, Stash, StartY, 0
    IniRead, StashRows, %ConfigINI%, Stash, Rows, 5
    IniRead, StashCols, %ConfigINI%, Stash, Cols, 12
    IniRead, StashSlotWidth, %ConfigINI%, Stash, SlotWidth, 53
    IniRead, StashSlotHeight, %ConfigINI%, Stash, SlotHeight, 53
}

LoadScourAlchPositions() {
    global ConfigINI, ScourX, ScourY, AlchX, AlchY, MapX, MapY
    
    IniRead, ScourX, %ConfigINI%, ScourAlch, ScourX, 0
    IniRead, ScourY, %ConfigINI%, ScourAlch, ScourY, 0
    IniRead, AlchX, %ConfigINI%, ScourAlch, AlchX, 0
    IniRead, AlchY, %ConfigINI%, ScourAlch, AlchY, 0
    IniRead, MapX, %ConfigINI%, ScourAlch, MapX, 0
    IniRead, MapY, %ConfigINI%, ScourAlch, MapY, 0
    
    ; Debug: show loaded coordinates
    ; ToolTip, Loaded: Scour:%ScourX%,%ScourY% Alch:%AlchX%,%AlchY% Map:%MapX%,%MapY%
    ; SetTimer, RemoveToolTip, -2000
}

LoadChaosOrbPositions() {
    global ConfigINI, ChaosX, ChaosY, ChaosMode, ChaosDelay, RegexStopEnabled, RegexCheckX1, RegexCheckY1, RegexCheckX2, RegexCheckY2
    
    IniRead, ChaosX, %ConfigINI%, ChaosOrb, ChaosX, 0
    IniRead, ChaosY, %ConfigINI%, ChaosOrb, ChaosY, 0
    IniRead, RegexCheckX1, %ConfigINI%, ChaosOrb, RegexCheckX1, 0
    IniRead, RegexCheckY1, %ConfigINI%, ChaosOrb, RegexCheckY1, 0
    IniRead, RegexCheckX2, %ConfigINI%, ChaosOrb, RegexCheckX2, 0
    IniRead, RegexCheckY2, %ConfigINI%, ChaosOrb, RegexCheckY2, 0
    IniRead, ChaosMode, %ConfigINI%, Settings, ChaosMode, 1
    IniRead, ChaosDelay, %ConfigINI%, Settings, ChaosDelay, 100
    IniRead, RegexStopEnabled, %ConfigINI%, Settings, RegexStopEnabled, 1
}

LoadKeySpamSettings() {
    global ConfigINI, SpamKey1, SpamKey2, SpamDualMode, SpamHoldMode
    
    IniRead, SpamKey1, %ConfigINI%, KeySpam, SpamKey1, d
    IniRead, tempKey2, %ConfigINI%, KeySpam, SpamKey2, ERROR
    IniRead, SpamDualMode, %ConfigINI%, KeySpam, SpamDualMode, 0
    IniRead, SpamHoldMode, %ConfigINI%, KeySpam, SpamHoldMode, 0
    
    ; Check if SpamKey2 exists
    if (tempKey2 = "ERROR") {
        SpamKey2 := ""
    } else {
        SpamKey2 := tempKey2
    }
    
    ; Update button texts
    StringUpper, key1Upper, SpamKey1
    buttonText1 := "K1: " . key1Upper
    GuiControl,, Key1Button, %buttonText1%
    
    if (SpamKey2 != "" && SpamKey2 != "ERROR") {
        StringUpper, key2Upper, SpamKey2
        buttonText2 := "K2: " . key2Upper
        GuiControl,, Key2Button, %buttonText2%
    } else {
        GuiControl,, Key2Button, K2: -
    }
    
    if (SpamDualMode) {
        GuiControl,, DualSpamButton, Dual
    }
    
    if (SpamHoldMode) {
        GuiControl,, HoldModeButton, Hold
    } else {
        GuiControl,, HoldModeButton, Spam
    }
}

LoadWeaponSwapSettings() {
    global ConfigINI, WeaponSwapEnabled, WeaponSwapHotkey, WeaponSwapSkillKey
    global WeaponSwapButton, WeaponSwapBackButton, WeaponSwapDelayAfter, WeaponSwapDelaySkill
    
    IniRead, WeaponSwapEnabled, %ConfigINI%, WeaponSwap, Enabled, 0
    IniRead, WeaponSwapHotkey, %ConfigINI%, WeaponSwap, Hotkey, q
    IniRead, WeaponSwapSkillKey, %ConfigINI%, WeaponSwap, SkillKey, q
    IniRead, WeaponSwapButton, %ConfigINI%, WeaponSwap, SwapButton, x
    IniRead, WeaponSwapBackButton, %ConfigINI%, WeaponSwap, SwapBackButton, x
    IniRead, WeaponSwapDelayAfter, %ConfigINI%, WeaponSwap, DelayAfter, 120
    IniRead, WeaponSwapDelaySkill, %ConfigINI%, WeaponSwap, DelaySkill, 300
    
    ; Update button text
    StringUpper, keyUpper, WeaponSwapHotkey
    buttonText := "Key: " . keyUpper
    GuiControl,, WeaponSwapKeyButton, %buttonText%
    
    ; Update checkbox
    GuiControl,, WeaponSwapEnabledCheck, %WeaponSwapEnabled%
    
    ; Apply hotkey if enabled
    if (WeaponSwapEnabled) {
        try {
            Hotkey, *%WeaponSwapHotkey%, ExecuteWeaponSwapDown, On
            Hotkey, *%WeaponSwapHotkey% Up, ExecuteWeaponSwapUp, On
        }
    }
}

; ─────────────────────────────────────────────────────────────────────────────
;  Divine Rate Functions
; ─────────────────────────────────────────────────────────────────────────────
FetchDivineRate() {
    global apiURL
    tmp := A_Temp "\divine.json"
    UrlDownloadToFile, %apiURL%, %tmp%
    if ErrorLevel {
        FileDelete, %tmp%
        return 0
    }
    FileRead, json, %tmp%
    FileDelete, %tmp%
    if RegExMatch(json, "i)""currencyTypeName"":""Divine Orb"".*?""chaosEquivalent"":\s*([0-9\.]+)", m)
        return m1+0
    return 0
}

; === GUI ===
Gui, +AlwaysOnTop +ToolWindow -Caption +Border +HwndGuiHwnd
Gui, Color, 202020
Gui, Font, s9, Segoe UI

Gui, Add, Text, x0 y0 w280 h30 c0xFF69B4 Background0x2A2A2A Center, PoE Svintus LIFE
Gui, Add, Button, x223 y2 w25 h20 gMinimizeGUI, -
Gui, Add, Button, x252 y2 w25 h20 gExitProgram, X

; Hotkeys list
Gui, Add, Text, x50 y40  w40  h20 c0xFFFF00, F3
Gui, Add, Text, x95 y40  w185 h20 c0xFFFFFF, - Fast Fusing/Jew
Gui, Add, Text, x50 y65  w40  h20 c0xFFFF00, F2
Gui, Add, Text, x95 y65  w185 h20 c0xFFFFFF, - Move to stash
Gui, Add, Button, x205 y65 w42 h20 gStashSetup, Setup
Gui, Add, Text, x50 y90  w40  h20 c0xFFFF00, F4
Gui, Add, Text, x95 y90  w185 h20 c0xFFFFFF, - Gem Swap
Gui, Add, Text, x50 y115 w40  h20 c0xFFFF00, F7
Gui, Add, Text, x95 y115 w185 h20 c0xFFFFFF, - Spam Key
Gui, Add, Text, x10 y140 w40  h20 c0xFFFF00, F10
Gui, Add, Text, x55 y140 w155 h20 c0xFFFFFF, - Scour + Alch / Chaos Orb
Gui, Add, Text, x10 y165 w45 h20 c0xFFFFFF, Setup:
Gui, Add, Button, x55 y165 w38 h20 gScourAlchSetup, Main
Gui, Add, Button, x98 y165 w38 h20 gRegexAreaSetup, Area
Gui, Add, Button, x141 y165 w38 h20 gChaosModeToggle, Mode
Gui, Add, Button, x184 y165 w65 h20 gToggleScourLoop vScourLoopButton, Loop: OFF
Gui, Add, Text, x10 y190 w280 h20 c0xFFFFFF vScourAlchStatusText, Status: Ready
Gui, Add, Text, x10 y210 w280 h20 c0xFFFFFF vChaosModeText, Mode: Scour + Alch

; GemSwap controls
Gui, Add, Text, x10 y230 w60 h20 c0xFFFF00, GemSwap:
Gui, Add, Button, x70 y230 w42 h20 gGemSwapMode, Mode
Gui, Add, Button, x115 y230 w42 h20 gGemSwapSetup, Setup
Gui, Add, Button, x160 y230 w42 h20 gGemSwapHelp, Help
Gui, Add, Text, x10 y255 w100 h20 c0xFFFFFF vGemSwapModeText, Mode: 2 Gems
Gui, Add, Text, x115 y255 w160 h20 c0xFFFFFF vGemSwapStatusText, Status: Ready

; Key Spam controls
Gui, Add, Text, x10 y280 w60 h20 c0xFFFF00, Key Spam:
Gui, Add, Button, x10 y305 w58 h20 gPickKey1 vKey1Button, K1: D
Gui, Add, Button, x73 y305 w58 h20 gPickKey2 vKey2Button, K2: -
Gui, Add, Button, x136 y305 w48 h20 gToggleDualSpam vDualSpamButton, Single
Gui, Add, Button, x189 y305 w48 h20 gToggleHoldMode vHoldModeButton, Spam
Gui, Add, Text, x10 y330 w30 h20 c0xFFFFFF, Delay:
Gui, Add, Slider, x45 y330 w135 h20 vDetonateSlider gUpdateDetonateDelay Range50-200 AltSubmit ToolTip, 100
Gui, Add, Text, x185 y330 w25 h20 c0xFFFFFF vDetonateDelayText, 100

; Bestiary controls
Gui, Add, Text, x10 y355 w60 h20 c0xFFFF00, Bestiary:
Gui, Add, Button, x70 y355 w42 h20 gBeastMode, Mode
Gui, Add, Button, x115 y355 w42 h20 gBeastSetup, Setup
Gui, Add, Button, x160 y355 w42 h20 gBeastFilter, Regex
Gui, Add, Button, x205 y355 w42 h20 gBeastHelp, Help
Gui, Add, Text, x10 y380 w100 h20 c0xFFFFFF vBeastModeText, Mode: Store
Gui, Add, Text, x115 y380 w160 h20 c0xFFFFFF vBeastStatusText, Status: Ready

; Beast hotkeys info
Gui, Add, Text, x10 y405 w40  h20 c0xFFFF00, F1
Gui, Add, Text, x55 y405 w220 h20 c0xFFFFFF, - Beast Store/Delete
Gui, Add, Text, x10 y425 w40  h20 c0xFFFF00, F5
Gui, Add, Text, x55 y425 w220 h20 c0xFFFFFF, - Setup positions
Gui, Add, Text, x10 y445 w40  h20 c0xFFFF00, F6
Gui, Add, Text, x55 y445 w220 h20 c0xFFFFFF, - Change beast regex (Best/Rare/Bad)
Gui, Add, Text, x10 y465 w40  h20 c0xFFFF00, ^F6
Gui, Add, Text, x55 y465 w220 h20 c0xFFFFFF, - Switch Store/Delete mode

; Weapon Swap controls
Gui, Add, Text, x10 y490 w80 h20 c0xFFFF00, Weapon Swap:
Gui, Add, Button, x90 y490 w60 h20 gPickWeaponSwapKey vWeaponSwapKeyButton, Key: Q
Gui, Add, Button, x155 y490 w55 h20 gWeaponSwapSetup, Setup
Gui, Add, Button, x215 y490 w55 h20 gWeaponSwapHelp, Help
Gui, Add, CheckBox, x10 y515 w100 h20 vWeaponSwapEnabledCheck gToggleWeaponSwap, Enable
Gui, Add, Text, x115 y515 w160 h20 c0xFFFFFF vWeaponSwapStatusText, Status: Ready

; Beast statistics display
Gui, Add, Text, x10 y545 w150 h15 c0x90EE90 vBeastStatsText, Del G:0 B:0 | Str G:0 B:0
Gui, Add, Button, x165 y543 w50 h18 gResetStats, Reset
Gui, Add, Button, x220 y543 w50 h18 gToggleStatsWindow, Stats

; Status & Alpha
Gui, Add, Text, x60 y570 w70  h20 c0xFFFF00 vStatusLabel, Status:
Gui, Add, Text, x130 y570 w150 h20 c0xFFFFFF vStatusFunction, Idle
Gui, Add, Text, x10 y595 w40  h20 c0xFFFFFF, Alpha:
Gui, Add, Slider, x55 y595 w220 h25 vMySlider gUpdateTransparency Range50-255 AltSubmit ToolTip, 200

; Divine rate
Gui, Add, Text, x10 y630 w80  h20 c0xFFFFFF, Divine rate:
Gui, Add, Edit, x95 y630 w60 h20 vDivineRate
Gui, Add, Button, x160 y630 w60 h25 gRefreshRate, Refresh

; Load saved divine rate and detonate delay
IniRead, savedRate, %ConfigINI%, Settings, DivineRate, 155
GuiControl,, DivineRate, %savedRate%

IniRead, savedDelay, %ConfigINI%, Settings, DetonateDelay, 100
GuiControl,, DetonateSlider, %savedDelay%
GuiControl,, DetonateDelayText, %savedDelay%
DetonateDelay := savedDelay

; Quick Change Calculator
Gui, Add, Text, x0  y665 w280 h20 Center c0xFFFF00, Quick Change Calculator
Gui, Add, Text, x10 y690 w100 h20 c0xFFFFFF, Item Price DIV:
Gui, Add, Edit, x115 y690 w60 h20 vItemPriceDIV
Gui, Add, Text, x10 y715 w100 h20 c0xFFFFFF, Divine received:
Gui, Add, Edit, x115 y715 w60 h20 vDivineGet
Gui, Add, Button, x180 y690 w60 h25 gCalcDivine, Calc
Gui, Add, Text, x10 y740 w100 h20 c0xFFFFFF, Chaos received:
Gui, Add, Edit, x115 y740 w60 h20 vChaosGet
Gui, Add, Text, x10 y765 w100 h20 c0xFFFFFF, Change:
Gui, Add, Edit, x115 y765 w60 h20 vReturn

Gui, Show, x100 y100 w280 h845 NoActivate

; Load saved Alpha value
IniRead, savedAlpha, %ConfigINI%, Settings, Alpha, 200
GuiControl,, MySlider, %savedAlpha%
WinSet, Transparent, %savedAlpha%, ahk_id %GuiHwnd%

; Update mode displays
UpdateBeastModeDisplay()
UpdateGemSwapModeDisplay()
UpdateChaosModeDisplay()

; Load GemSwap positions
LoadGemSwapPositions()

; Load Stash positions
LoadStashPositions()

; Load Scour + Alch positions
LoadScourAlchPositions()

; Load Chaos Orb positions
LoadChaosOrbPositions()

; Load Key Spam settings
LoadKeySpamSettings()

; Load Weapon Swap settings
LoadWeaponSwapSettings()

; Настройка трея
Menu, Tray, NoStandard
Menu, Tray, Add, Show/Hide GUI, ToggleGUI
Menu, Tray, Add, Exit Program, ExitProgram
Menu, Tray, Default, Show/Hide GUI

; Draggable border
OnMessage(0x201, "StartDrag")
OnMessage(0x84,  "WM_NCHITTEST")
return

; === FIXED FUNCTIONS ===
MinimizeGUI:
    Gui, Hide
    TrayTip, PoE Svintus, Right-click tray icon to show GUI, 2
return

ExitProgram:
    ExitApp
return

ToggleGUI:
    DetectHiddenWindows, On
    if WinExist("ahk_id " . GuiHwnd) {
        WinGet, GuiState, MinMax, ahk_id %GuiHwnd%
        if (GuiState = -1) or !WinActive("ahk_id " . GuiHwnd) {
            Gui, Show
            WinActivate, ahk_id %GuiHwnd%
        } else {
            Gui, Hide
        }
    } else {
        Gui, Show
    }
    DetectHiddenWindows, Off
return

; ─────────────────────────────────────────────────────────────────────────────
;  Detonate Dead Functions
; ─────────────────────────────────────────────────────────────────────────────
UpdateDetonateDelay:
    GuiControlGet, DetonateSlider
    DetonateDelay := DetonateSlider
    GuiControl,, DetonateDelayText, %DetonateSlider%
    IniWrite, %DetonateSlider%, %ConfigINI%, Settings, DetonateDelay
return

; ─────────────────────────────────────────────────────────────────────────────
;  GemSwap GUI Functions
; ─────────────────────────────────────────────────────────────────────────────
GemSwapMode:
    GemSwapMode := (GemSwapMode = 1) ? 2 : 1
    UpdateGemSwapModeDisplay()
    modeText := (GemSwapMode = 1) ? "2 Gems mode" : "3 Gems mode"
    GuiControl,, GemSwapStatusText, Switched to %modeText%
    SetTimer, ClearGemSwapStatus, -2000
return

ClearGemSwapStatus:
    GuiControl,, GemSwapStatusText, Status: Ready
return

GemSwapSetup:
    Gui, GemSwapSetup:Destroy
    Gui, GemSwapSetup:New, +AlwaysOnTop +ToolWindow, GemSwap Setup
    SetupText =
    (
GEMSWAP SETUP INSTRUCTIONS:

1. Click "Start Setup"
2. Hover cursor over GEM 1 in INVENTORY and press F9
3. Hover cursor over GEM 1 SOCKET and press F9
4. Hover cursor over GEM 2 in INVENTORY and press F9
5. Hover cursor over GEM 2 SOCKET and press F9

For 3 Gems mode:
6. Hover cursor over GEM 3 in INVENTORY and press F9
7. Hover cursor over GEM 3 SOCKET and press F9

Press F9 after each step!

Setup is required before use!
    )
    Gui, GemSwapSetup:Add, Text, w350, %SetupText%
    Gui, GemSwapSetup:Add, Button, gStartGemSwapSetup Default, Start Setup
    Gui, GemSwapSetup:Add, Button, gCancelGemSwapSetup, Cancel
    Gui, GemSwapSetup:Show, AutoSize Center
return

StartGemSwapSetup:
    Gui, GemSwapSetup:Destroy
    GemSwapSetupState := 0
    TrayTip, GEMSWAP SETUP, Hover cursor over GEM 1 in inventory and press F9, 5
    GuiControl,, GemSwapStatusText, Setup: Gem 1 inventory
return

CancelGemSwapSetup:
    Gui, GemSwapSetup:Destroy
return

GemSwapHelp:
    Gui, GemSwapHelp:Destroy
    Gui, GemSwapHelp:New, +AlwaysOnTop +ToolWindow, GemSwap Help
    
    HelpText =
    (
HOW TO USE GEMSWAP:

1. INITIAL SETUP (REQUIRED!):
   - Click "Setup" button
   - Follow instructions and press F9 for each position
   - Set up gem positions: Gem inventory -> Gem socket

2. OPERATING MODES:
   - F4 = Execute gem swap
   - "Mode" button = switch 2 Gems or 3 Gems mode

3. 2 GEMS MODE:
   - Swaps 2 gems between inventory and sockets
   - Default mode for most use cases

4. 3 GEMS MODE:
   - Swaps 3 gems between inventory and sockets
   - Good for complex gem configurations

IMPORTANT: Complete Setup before using!
Each gem has its own inventory position and socket position.
    )
    
    Gui, GemSwapHelp:Add, Text, w400, %HelpText%
    Gui, GemSwapHelp:Add, Button, gCloseGemSwapHelp Default, I'M READ
    Gui, GemSwapHelp:Show, AutoSize Center
return

CloseGemSwapHelp:
    Gui, GemSwapHelp:Destroy
return

StashSetup:
    Gui, StashSetup:Destroy
    Gui, StashSetup:New, +AlwaysOnTop +ToolWindow, Stash Setup
    SetupText =
    (
STASH SETUP INSTRUCTIONS:

1. Click "Start Setup"
2. Hover cursor over TOP-LEFT corner of first stash slot
3. Press F8 to save position

This will automatically calculate all other positions
based on slot size (53x53 pixels by default).

Setup is required before using Move to Stash!
    )
    Gui, StashSetup:Add, Text, w350, %SetupText%
    Gui, StashSetup:Add, Button, gStartStashSetup Default, Start Setup
    Gui, StashSetup:Add, Button, gCancelStashSetup, Cancel
    Gui, StashSetup:Show, AutoSize Center
return

StartStashSetup:
    Gui, StashSetup:Destroy
    StashSetupState := 0
    TrayTip, STASH SETUP, Hover cursor over TOP-LEFT corner of first stash slot and press F8, 5
return

CancelStashSetup:
    Gui, StashSetup:Destroy
return

; ─────────────────────────────────────────────────────────────────────────────
;  Scour + Alch Setup Functions
; ─────────────────────────────────────────────────────────────────────────────
ScourAlchSetup:
    Gui, ScourAlchSetup:Destroy
    Gui, ScourAlchSetup:New, +AlwaysOnTop +ToolWindow, Scour + Alch / Chaos Orb Setup
    SetupText =
    (
SCOUR + ALCH / CHAOS ORB SETUP INSTRUCTIONS:

1. Click "Start Setup"
2. Hover cursor over SCOUR orb in inventory and press F12
3. Hover cursor over ALCHEMIST orb in inventory and press F12
4. Hover cursor over MAP position (where to click) and press F12
5. Hover cursor over CHAOS ORB in inventory and press F12
6. Hover cursor over MAP in STASH (for regex check) and press F12

Press F12 after each step!

Setup is required before using Scour + Alch / Chaos Orb!
    )
    Gui, ScourAlchSetup:Add, Text, w350, %SetupText%
    Gui, ScourAlchSetup:Add, Button, gStartScourAlchSetup Default, Start Setup
    Gui, ScourAlchSetup:Add, Button, gCancelScourAlchSetup, Cancel
    Gui, ScourAlchSetup:Show, AutoSize Center
return

StartScourAlchSetup:
    Gui, ScourAlchSetup:Destroy
    ScourAlchSetupState := 0
    TrayTip, SCOUR + ALCH SETUP, Hover cursor over SCOUR orb and press F12, 5
    GuiControl,, ScourAlchStatusText, Setup: Scour orb
return

CancelScourAlchSetup:
    Gui, ScourAlchSetup:Destroy
return

ClearScourAlchStatus:
    GuiControl,, ScourAlchStatusText, Status: Ready
return

RegexAreaSetup:
    Gui, 1:Hide
    TrayTip, REGEX AREA SETUP, Click and drag to select area for yellow border detection, 3
    Sleep, 500
    
    ; Wait for left click
    KeyWait, LButton, D
    MouseGetPos, RegexCheckX1, RegexCheckY1
    
    ; Create selection GUI
    Gui, SelectArea:New, +AlwaysOnTop -Caption +ToolWindow +LastFound
    Gui, SelectArea:Color, 0x0000FF
    WinSet, Transparent, 80
    
    ; Track mouse movement
    SetTimer, TrackSelection, 10
    KeyWait, LButton
    SetTimer, TrackSelection, Off
    
    MouseGetPos, RegexCheckX2, RegexCheckY2
    Gui, SelectArea:Destroy
    
    ; Ensure X1,Y1 is top-left and X2,Y2 is bottom-right
    if (RegexCheckX1 > RegexCheckX2) {
        temp := RegexCheckX1
        RegexCheckX1 := RegexCheckX2
        RegexCheckX2 := temp
    }
    if (RegexCheckY1 > RegexCheckY2) {
        temp := RegexCheckY1
        RegexCheckY1 := RegexCheckY2
        RegexCheckY2 := temp
    }
    
    ; Calculate width and height
    areaWidth := RegexCheckX2 - RegexCheckX1
    areaHeight := RegexCheckY2 - RegexCheckY1
    
    ; Save to INI
    IniWrite, %RegexCheckX1%, %ConfigINI%, ChaosOrb, RegexCheckX1
    IniWrite, %RegexCheckY1%, %ConfigINI%, ChaosOrb, RegexCheckY1
    IniWrite, %RegexCheckX2%, %ConfigINI%, ChaosOrb, RegexCheckX2
    IniWrite, %RegexCheckY2%, %ConfigINI%, ChaosOrb, RegexCheckY2
    
    ; Restore main GUI
    Gui, 1:Show
    GuiControl,, ScourAlchStatusText, Area saved: %areaWidth%x%areaHeight%
    TrayTip, AREA SAVED!, Area: %areaWidth%x%areaHeight% pixels, 2
    SetTimer, ClearScourAlchStatus, -3000
return

TrackSelection:
    MouseGetPos, currentX, currentY
    w := Abs(currentX - RegexCheckX1)
    h := Abs(currentY - RegexCheckY1)
    x := (currentX < RegexCheckX1) ? currentX : RegexCheckX1
    y := (currentY < RegexCheckY1) ? currentY : RegexCheckY1
    Gui, SelectArea:Show, x%x% y%y% w%w% h%h% NoActivate
return

UpdateChaosModeDisplay() {
    global ChaosMode
    modeText := (ChaosMode = 1) ? "Mode: Scour + Alch" : "Mode: Chaos Orb"
    GuiControl,, ChaosModeText, %modeText%
}

ChaosModeToggle:
    ChaosMode := (ChaosMode = 1) ? 2 : 1
    UpdateChaosModeDisplay()
    IniWrite, %ChaosMode%, %ConfigINI%, Settings, ChaosMode
    modeText := (ChaosMode = 1) ? "Scour + Alch mode" : "Chaos Orb mode"
    GuiControl,, ScourAlchStatusText, Switched to %modeText%
    SetTimer, ClearScourAlchStatus, -2000
return

ToggleScourLoop:
    ScourAlchLoopEnabled := !ScourAlchLoopEnabled
    buttonText := ScourAlchLoopEnabled ? "Loop: ON" : "Loop: OFF"
    GuiControl,, ScourLoopButton, %buttonText%
    statusText := ScourAlchLoopEnabled ? "Loop enabled" : "Loop disabled"
    GuiControl,, ScourAlchStatusText, %statusText%
    SetTimer, ClearScourAlchStatus, -2000
return

; ─────────────────────────────────────────────────────────────────────────────
;  Key Spam Functions
; ─────────────────────────────────────────────────────────────────────────────
PickKey1:
    ToolTip, Press any key for Key 1...
    Input, key, L1 T5
    if (ErrorLevel = "Timeout") {
        ToolTip
        return
    }
    SpamKey1 := key
    IniWrite, %key%, %ConfigINI%, KeySpam, SpamKey1
    StringUpper, keyUpper, key
    buttonText := "K1: " . keyUpper
    GuiControl,, Key1Button, %buttonText%
    ToolTip, Key 1 set to: %key%
    SetTimer, RemoveToolTip, -1000
return

PickKey2:
    ToolTip, Press any key for Key 2 (or ESC to clear)...
    Input, key, L1 T5 E
    if (ErrorLevel = "Timeout") {
        ToolTip
        return
    }
    ; Check if ESC was pressed (EndKey)
    if (ErrorLevel = "EndKey:Escape") {
        SpamKey2 := ""
        IniDelete, %ConfigINI%, KeySpam, SpamKey2
        GuiControl,, Key2Button, K2: -
        ToolTip, Key 2 cleared
        SetTimer, RemoveToolTip, -1000
        return
    }
    ; Normal key pressed
    if (key != "") {
        SpamKey2 := key
        IniWrite, %key%, %ConfigINI%, KeySpam, SpamKey2
        StringUpper, keyUpper, key
        buttonText := "K2: " . keyUpper
        GuiControl,, Key2Button, %buttonText%
        ToolTip, Key 2 set to: %key%
    }
    SetTimer, RemoveToolTip, -1000
return

ToggleDualSpam:
    SpamDualMode := !SpamDualMode
    dualModeValue := SpamDualMode ? 1 : 0
    IniWrite, %dualModeValue%, %ConfigINI%, KeySpam, SpamDualMode
    buttonText := SpamDualMode ? "Dual" : "Single"
    GuiControl,, DualSpamButton, %buttonText%
return

ToggleHoldMode:
    SpamHoldMode := !SpamHoldMode
    holdModeValue := SpamHoldMode ? 1 : 0
    IniWrite, %holdModeValue%, %ConfigINI%, KeySpam, SpamHoldMode
    buttonText := SpamHoldMode ? "Hold" : "Spam"
    GuiControl,, HoldModeButton, %buttonText%
    
    ; If switching to Hold mode and spam is running, stop the spam timer
    if (SpamHoldMode && DetonateRunning) {
        SetTimer, KeySpam, Off
        ; Send key up events to release any held keys
        if (SpamDualMode && SpamKey2 != "") {
            Send, {%SpamKey1% up}
            Send, {%SpamKey2% up}
        } else {
            Send, {%SpamKey1% up}
        }
    }
    
    ToolTip, Key Spam mode: %buttonText%
    SetTimer, RemoveToolTip, -1000
return

; ─────────────────────────────────────────────────────────────────────────────
;  Weapon Swap Functions
; ─────────────────────────────────────────────────────────────────────────────
PickWeaponSwapKey:
    ToolTip, Press any key for Weapon Swap hotkey...
    Input, key, L1 T5
    if (ErrorLevel = "Timeout") {
        ToolTip
        return
    }
    
    ; Disable old hotkey
    if (WeaponSwapEnabled && WeaponSwapHotkey != "") {
        try {
            Hotkey, *%WeaponSwapHotkey%, Off
        }
    }
    
    WeaponSwapHotkey := key
    WeaponSwapSkillKey := key
    IniWrite, %key%, %ConfigINI%, WeaponSwap, Hotkey
    IniWrite, %key%, %ConfigINI%, WeaponSwap, SkillKey
    
    StringUpper, keyUpper, key
    buttonText := "Key: " . keyUpper
    GuiControl,, WeaponSwapKeyButton, %buttonText%
    ToolTip, Hotkey set to: %key%
    SetTimer, RemoveToolTip, -1000
    
    ; Re-enable hotkey if enabled
    if (WeaponSwapEnabled) {
        try {
            Hotkey, *%WeaponSwapHotkey%, ExecuteWeaponSwap, On
        }
    }
return

ToggleWeaponSwap:
    Gui, Submit, NoHide
    WeaponSwapEnabled := WeaponSwapEnabledCheck
    IniWrite, %WeaponSwapEnabled%, %ConfigINI%, WeaponSwap, Enabled
    
    if (WeaponSwapEnabled) {
        try {
            Hotkey, *%WeaponSwapHotkey%, ExecuteWeaponSwapDown, On
            Hotkey, *%WeaponSwapHotkey% Up, ExecuteWeaponSwapUp, On
            GuiControl,, WeaponSwapStatusText, Status: Enabled
            SetTimer, ClearWeaponSwapStatus, -2000
        } catch {
            MsgBox, 16, Error, Failed to create hotkey!
            WeaponSwapEnabled := 0
            GuiControl,, WeaponSwapEnabledCheck, 0
        }
    } else {
        try {
            Hotkey, *%WeaponSwapHotkey%, Off
            Hotkey, *%WeaponSwapHotkey% Up, Off
        }
        GuiControl,, WeaponSwapStatusText, Status: Disabled
        SetTimer, ClearWeaponSwapStatus, -2000
    }
return

WeaponSwapSetup:
    Gui, WeaponSwapSetup:Destroy
    Gui, WeaponSwapSetup:New, +AlwaysOnTop +ToolWindow, Weapon Swap Setup
    
    SetupText =
    (
WEAPON SWAP SETUP:

1. Select activation key using "Key" button
2. Configure swap buttons and delays below:

    )
    
    Gui, WeaponSwapSetup:Add, Text, w350, %SetupText%
    Gui, WeaponSwapSetup:Add, Text, x10 y120 w150, Swap button BEFORE skill:
    Gui, WeaponSwapSetup:Add, Edit, x170 y120 w50 vSetupSwapButton, %WeaponSwapButton%
    
    Gui, WeaponSwapSetup:Add, Text, x10 y150 w150, Swap button AFTER skill:
    Gui, WeaponSwapSetup:Add, Edit, x170 y150 w50 vSetupSwapBackButton, %WeaponSwapBackButton%
    
    Gui, WeaponSwapSetup:Add, Text, x10 y180 w150, Delay after swap (ms):
    Gui, WeaponSwapSetup:Add, Edit, x170 y180 w50 vSetupDelayAfter, %WeaponSwapDelayAfter%
    
    Gui, WeaponSwapSetup:Add, Text, x10 y210 w150, Delay after skill (ms):
    Gui, WeaponSwapSetup:Add, Edit, x170 y210 w50 vSetupDelaySkill, %WeaponSwapDelaySkill%
    
    Gui, WeaponSwapSetup:Add, Button, x10 y250 w100 gSaveWeaponSwapSetup Default, Save
    Gui, WeaponSwapSetup:Add, Button, x120 y250 w100 gCancelWeaponSwapSetup, Cancel
    Gui, WeaponSwapSetup:Show, AutoSize Center
return

SaveWeaponSwapSetup:
    Gui, WeaponSwapSetup:Submit, NoHide
    WeaponSwapButton := SetupSwapButton
    WeaponSwapBackButton := SetupSwapBackButton
    WeaponSwapDelayAfter := SetupDelayAfter
    WeaponSwapDelaySkill := SetupDelaySkill
    
    IniWrite, %WeaponSwapButton%, %ConfigINI%, WeaponSwap, SwapButton
    IniWrite, %WeaponSwapBackButton%, %ConfigINI%, WeaponSwap, SwapBackButton
    IniWrite, %WeaponSwapDelayAfter%, %ConfigINI%, WeaponSwap, DelayAfter
    IniWrite, %WeaponSwapDelaySkill%, %ConfigINI%, WeaponSwap, DelaySkill
    
    Gui, WeaponSwapSetup:Destroy
    GuiControl,, WeaponSwapStatusText, Setup saved!
    SetTimer, ClearWeaponSwapStatus, -2000
return

CancelWeaponSwapSetup:
    Gui, WeaponSwapSetup:Destroy
return

WeaponSwapHelp:
    Gui, WeaponSwapHelp:Destroy
    Gui, WeaponSwapHelp:New, +AlwaysOnTop +ToolWindow, Weapon Swap Help
    
    HelpText =
    (
HOW TO USE WEAPON SWAP:

1. SETUP:
   - Click "Key" to select activation hotkey
   - Click "Setup" to configure swap buttons and delays
   - Check "Enable" checkbox

2. HOW IT WORKS:
   When you press selected key, it will:
   1) Weapon swap (X button by default)
   2) Delay (120ms by default)
   3) Use skill (ONLY after swap!)
   4) Delay (300ms by default)
   5) Weapon swap back (TRIPLE SEND for reliability!)

3. SETTINGS:
   - Activation key: the key you will press
   - Swap button BEFORE: usually X (swap before skill)
   - Swap button AFTER: usually X (swap back)
   - Delay after swap: time to wait after swap before skill
   - Delay after skill: time to wait before swapping back
   
4. COMBAT RELIABILITY:
   - Swap back command sent 3 times with small delays
   - This prevents "missed" swap back in laggy combat
   - Increase delays if actions still don't work reliably

IMPORTANT: 
- Skill activates ONLY after weapon swap!
- Original key press is blocked
- Triple swap back ensures reliability in combat!
    )
    
    Gui, WeaponSwapHelp:Add, Text, w400, %HelpText%
    Gui, WeaponSwapHelp:Add, Button, gCloseWeaponSwapHelp Default, OK
    Gui, WeaponSwapHelp:Show, AutoSize Center
return

CloseWeaponSwapHelp:
    Gui, WeaponSwapHelp:Destroy
return

ClearWeaponSwapStatus:
    GuiControl,, WeaponSwapStatusText, Status: Ready
return

    global WeaponSwapButton, WeaponSwapBackButton, WeaponSwapSkillKey
    global WeaponSwapDelayAfter, WeaponSwapDelaySkill
    
    ; Check if Path of Exile is active
    IfWinNotActive, Path of Exile
    {
        return
    }
    
    ; 1. Weapon swap BEFORE skill
    Send, {%WeaponSwapButton%}
    Sleep, %WeaponSwapDelayAfter%
    
    ; 2. Use skill (instant cast)
    Send, {%WeaponSwapSkillKey%}
    Sleep, %WeaponSwapDelaySkill%
    
    ; 3. Weapon swap back (MULTIPLE sends for reliability during movement)
    Loop, 3
    {
        Send, {%WeaponSwapBackButton%}
        Sleep, 30
    }
return

; Dummy function to prevent errors
ExecuteWeaponSwapUp:
return

; ─────────────────────────────────────────────────────────────────────────────
;  Calculator Functions
; ─────────────────────────────────────────────────────────────────────────────
CalcDivine:
Gui, Submit, NoHide
ItemPriceDIV := ItemPriceDIV ? ItemPriceDIV : 0
DivineGet := DivineGet ? DivineGet : 0
ChaosGet := ChaosGet ? ChaosGet : 0
rate := DivineRate ? DivineRate : 0

; Calculate total item cost in chaos
totalItemCost := ItemPriceDIV * rate

; Calculate total received in chaos
totalReceived := (DivineGet * rate) + ChaosGet

; Calculate change
change := totalReceived - totalItemCost

GuiControl,, Return, %change%
return

RefreshRate:
rate := FetchDivineRate()
if (rate) {
    formattedRate := FormatRate(rate)
    GuiControl,, DivineRate, %formattedRate%
    ; Save to INI file
    IniWrite, %formattedRate%, %ConfigINI%, Settings, DivineRate
} else {
    MsgBox, 16, Error, Failed to retrieve Divine Orb rate.`nCheck connection or enter rate manually.
}
return

ToggleStatsWindow:
    if (StatsWindowVisible) {
        CloseStatsWindow()
    } else {
        ShowStatsWindow()
    }
return

ResetStats:
ResetSessionStats()
return

StatsClose:
CloseStatsWindow()
return

BeastMode:
    F1_Mode := (F1_Mode = 1) ? 2 : 1
    UpdateBeastModeDisplay()
    modeText := (F1_Mode = 1) ? "Beast STORING" : "Beast DELETING"
    GuiControl,, BeastStatusText, Switched to %modeText%
    SetTimer, ClearBeastStatus, -2000
return

BeastHelp:
    Gui, BeastHelp:Destroy
    Gui, BeastHelp:New, +AlwaysOnTop +ToolWindow, Bestiary Help
    
    HelpText =
    (
HOW TO USE BESTIARY:

1. INITIAL SETUP (REQUIRED!):
   - Click "Setup" button
   - Follow instructions and press F5 to save positions 
   - PRESS F5 EACH TIME FOR EACH POSITION AND EACH STEP
   - Set up 2 positions: Delete button, Beast center

2. OPERATING MODES:
   - F1 = start/stop beast deletion
   - "Mode" button = switch between modes (currently only Delete mode available)

3. DELETE MODE (beast deletion):
   - Quickly deletes beasts from bestiary
   - Press F1 to start/stop deletion process
   - Automatically clicks delete button with random delays
   - Processes beasts based on current filter

4. SEARCH FILTERS:
   - F6 = Change filters (Best/Rare/Bad) + STOP current process
   - Ctrl+F6 = Switch mode + STOP current process
   - "Filter" button = edit REGEX patterns
   - Filters help find specific beasts in bestiary
   - F6 will stop any running deletion process

5. CONTROLS:
   - F1 = Start/Stop deletion
   - F5 = Save positions during setup
   - F6 = Change filter + Stop process
   - Ctrl+F6 = Switch mode + Stop process

IMPORTANT: Complete Setup before using!
F6 and Ctrl+F6 will automatically stop any running processes.
    )
    
    Gui, BeastHelp:Add, Text, w400, %HelpText%
    Gui, BeastHelp:Add, Button, gCloseBeastHelp Default, I'M READ
    Gui, BeastHelp:Show, AutoSize Center
return

CloseBeastHelp:
    Gui, BeastHelp:Destroy
return

BeastSetup:
    Gui, BeastSetup:Destroy
    Gui, BeastSetup:New, +AlwaysOnTop +ToolWindow, Bestiary Setup
    SetupText =
    (
SETUP INSTRUCTIONS:

1. Click "Start Setup"
2. Hover cursor over "release X" button of first beast (DELETE)
3. Hover cursor over center of first beast (for pickup)

Press F5 after each step!

Setup is required before use!
    )
    Gui, BeastSetup:Add, Text, w350, %SetupText%
    Gui, BeastSetup:Add, Button, gStartBeastSetup Default, Start Setup
    Gui, BeastSetup:Add, Button, gCancelBeastSetup, Cancel
    Gui, BeastSetup:Show, AutoSize Center
return

StartBeastSetup:
    Gui, BeastSetup:Destroy
    F11_State := 0
    TrayTip, DELETE SETUP, Hover cursor over "release X" of first beast and press F5, 5
    GuiControl,, BeastStatusText, Setup: Delete position
return

CancelBeastSetup:
    Gui, BeastSetup:Destroy
return

BeastFilter:
    Gui, BeastFilter:Destroy
    Gui, BeastFilter:New, +AlwaysOnTop +ToolWindow, Beast Regex Strings
    Gui, BeastFilter:Add, Text,, Best beast:
    Gui, BeastFilter:Add, Edit, vGoodBeasts w300
    Gui, BeastFilter:Add, Text,, Rare beast:
    Gui, BeastFilter:Add, Edit, vBadBeast1 w300
    Gui, BeastFilter:Add, Text,, Bad beast:
    Gui, BeastFilter:Add, Edit, vBadBeast2 w300
    Gui, BeastFilter:Add, Button, gSaveBeastStr Default, Save
    Gui, BeastFilter:Add, Button, gCancelBeastStr, Cancel

    IniRead, tmp, %ConfigINI%, BeastStrings, GoodBeasts
    GuiControl, BeastFilter:, GoodBeasts, %tmp%
    IniRead, tmp, %ConfigINI%, BeastStrings, BadBeast1
    GuiControl, BeastFilter:, BadBeast1, %tmp%
    IniRead, tmp, %ConfigINI%, BeastStrings, BadBeast2
    GuiControl, BeastFilter:, BadBeast2, %tmp%

    Gui, BeastFilter:Show, AutoSize Center
return

SaveBeastStr:
    Gui, BeastFilter:Submit, NoHide
    IniWrite, %GoodBeasts%, %ConfigINI%, BeastStrings, GoodBeasts
    IniWrite, %BadBeast1%, %ConfigINI%, BeastStrings, BadBeast1
    IniWrite, %BadBeast2%, %ConfigINI%, BeastStrings, BadBeast2
    Gui, BeastFilter:Destroy
    GuiControl,, BeastStatusText, Filters saved
    SetTimer, ClearBeastStatus, -2000
return

CancelBeastStr:
    Gui, BeastFilter:Destroy
return

ClearBeastStatus:
    GuiControl,, BeastStatusText, Status: Ready
return

; ─────────────────────────────────────────────────────────────────────────────
;  Window dragging helpers
; ─────────────────────────────────────────────────────────────────────────────
StartDrag() {
    PostMessage, 0xA1, 2,,, A
}
WM_NCHITTEST(wParam, lParam) {
    global borderThickness
    MouseGetPos, mx, my
    WinGetPos, wx, wy, ww, wh, A
    dx := mx - wx, dy := my - wy
    if (dx<=borderThickness && dy<=borderThickness)
        return 13
    if (dx>=ww-borderThickness && dy<=borderThickness)
        return 14
    if (dx<=borderThickness && dy>=wh-borderThickness)
        return 16
    if (dx>=ww-borderThickness && dy>=wh-borderThickness)
        return 17
    if (dx<=borderThickness)
        return 10
    if (dx>=ww-borderThickness)
        return 11
    if (dy<=borderThickness)
        return 12
    if (dy>=wh-borderThickness)
        return 15
    return 2
}

; Обновление прозрачности главного окна
UpdateTransparency:
GuiControlGet, MySlider
WinSet, Transparent, %MySlider%, ahk_id %GuiHwnd%
IniWrite, %MySlider%, %ConfigINI%, Settings, Alpha
; Также обновляем прозрачность окна статистики, если оно открыто
if (StatsWindowVisible) {
    WinSet, Transparent, %MySlider%, ahk_id %StatsGuiHwnd%
}
return

; Обновление прозрачности окна статистики
UpdateStatsTransparency:
GuiControlGet, StatsSlider, Stats:
WinSet, Transparent, %StatsSlider%, ahk_id %StatsGuiHwnd%
return

; ─────────────────────────────────────────────────────────────────────────────
;  Bestiary Hotkeys
; ─────────────────────────────────────────────────────────────────────────────
F1::
    if (F1_Mode = 1) {
        ; Beast STORING
        if (!AutoRunning) {
            AutoRunning := true
            AutoIndex := 1
            ; Open inventory once at the start
            Send, {i}
            Sleep, 20
            SetTimer, DoCycle, 1500
            GuiControl,, BeastStatusText, Beast storing started
            UpdateStatus("Beast storing")
        } else {
            SetTimer, DoCycle, Off
            AutoRunning := false
            GuiControl,, BeastStatusText, Beast storing stopped
            UpdateStatus("Idle")
        }
    } else {
        ; Beast DELETING
        DeleteToggle := !DeleteToggle
        if (DeleteToggle) {
            GuiControl,, BeastStatusText, Beast deleting started
            UpdateStatus("Beast deleting")
            SetTimer, BeastDelSpam, 100
        } else {
            SetTimer, BeastDelSpam, Off
            GuiControl,, BeastStatusText, Beast deleting stopped
            UpdateStatus("Idle")
        }
    }
return

BeastDelSpam:
    if (!DeleteToggle)
        return
    Random, delay, 100, 150
    IniRead, dX, %ConfigINI%, DeletePos, posX, 0
    IniRead, dY, %ConfigINI%, DeletePos, posY, 0
    if (dX && dY) {
        MoveCursor(dX, dY)
        Sleep, 50
        Click
        
        ; Update statistics
        filterType := GetCurrentFilterType()
        if (filterType = "Good") {
            BeastDeletedGood++
        } else if (filterType = "Bad") {
            BeastDeletedBad++
        }
        UpdateStatsDisplay()
    }
    Sleep, %delay%
    Send, {Enter}
    Sleep, %delay%
return

F5::
    ; Setup mode - handle F5 during setup
    ; Setup mode - handle F5 during setup
    if (F11_State >= 0) {
        if (F11_State = 0) {
            MouseGetPos, dX, dY
            IniWrite, %dX%, %ConfigINI%, DeletePos, posX
            IniWrite, %dY%, %ConfigINI%, DeletePos, posY
            F11_State := 1
            TrayTip, Saved, Now hover cursor over center of first beast and press F5, 3
            GuiControl,, BeastStatusText, Setup: Beast pickup
            return
        }
        if (F11_State = 1) {
            MouseGetPos, bX, bY
            IniWrite, %bX%, %ConfigINI%, BeastPos, posX
            IniWrite, %bY%, %ConfigINI%, BeastPos, posY
            F11_State := -1
            GuiControl,, BeastStatusText, Setup complete!
            TrayTip, SETUP COMPLETE, Beast positions saved (Delete + Pickup), 3
            SetTimer, ClearBeastStatus, -3000
            return
        }
    }
return

F6::
    ; Остановить все активные процессы Bestiary при нажатии F6
    if (AutoRunning) {
        SetTimer, DoCycle, Off
        AutoRunning := false
        AutoIndex := 1
        GuiControl,, BeastStatusText, Beast storing stopped (F6)
        UpdateStatus("Idle")
    }
    if (DeleteToggle) {
        SetTimer, BeastDelSpam, Off
        DeleteToggle := false
        GuiControl,, BeastStatusText, Beast deleting stopped (F6)
        UpdateStatus("Idle")
    }
    
    ; Cycle search filters
    TrayTip  ; clear old
    Send, ^f
    Sleep, 100
    if (SearchIndex = 1) {
        key := "GoodBeasts", msg := "Good beasts"
    } else if (SearchIndex = 2) {
        key := "BadBeast1", msg := "Bad beasts 1"
    } else if (SearchIndex = 3) {
        key := "BadBeast2", msg := "Bad beasts 2"
    } else {
        Send, {Delete}
        GuiControl,, BeastStatusText, Filter: None
        SearchIndex := 1
        SetTimer, ClearBeastStatus, -2000
        return
    }
    IniRead, str, %ConfigINI%, BeastStrings, %key%
    Clipboard := str
    ClipWait, 1
    Send, ^v
    GuiControl,, BeastStatusText, Filter: %msg%
    SearchIndex := (SearchIndex = 4) ? 1 : SearchIndex + 1
    SetTimer, ClearBeastStatus, -2000
return

^F6::
    ; Остановить все активные процессы Bestiary при переключении режима
    if (AutoRunning) {
        SetTimer, DoCycle, Off
        AutoRunning := false
        AutoIndex := 1
        GuiControl,, BeastStatusText, Beast storing stopped (Mode switch)
        UpdateStatus("Idle")
    }
    if (DeleteToggle) {
        SetTimer, BeastDelSpam, Off
        DeleteToggle := false
        GuiControl,, BeastStatusText, Beast deleting stopped (Mode switch)
        UpdateStatus("Idle")
    }
    
    ; Switch between Store/Delete mode
    F1_Mode := (F1_Mode = 1) ? 2 : 1
    UpdateBeastModeDisplay()
    modeText := (F1_Mode = 1) ? "Beast STORING" : "Beast DELETING"
    GuiControl,, BeastStatusText, Switched to %modeText%
    SetTimer, ClearBeastStatus, -2000
return

; Beast storing cycle
DoCycle:
    if (AutoIndex > 50) {
        SetTimer, DoCycle, Off
        AutoRunning := false
        AutoIndex := 1
        GuiControl,, BeastStatusText, Beast storing finished
        UpdateStatus("Idle")
        SetTimer, ClearBeastStatus, -3000
        return
    }
    ; 1) Beast pickup + Shift + left-click
    IniRead, bX, %ConfigINI%, BeastPos, posX, 0
    IniRead, bY, %ConfigINI%, BeastPos, posY, 0
    if (bX && bY) {
        MoveCursor(bX, bY)
        Sleep, 200
        Send, +{Click}
        Sleep, 200
    }
    ; 2) Grid slot (1-50) + left-click
    IniRead, gx, %ConfigINI%, GridPos, gridposX%AutoIndex%, 0
    IniRead, gy, %ConfigINI%, GridPos, gridposY%AutoIndex%, 0
    if (gx && gy) {
        MoveCursor(gx, gy)
        Sleep, 200
        Click, Left
        Sleep, 200
        
        ; Update statistics
        filterType := GetCurrentFilterType()
        if (filterType = "Good") {
            BeastStoredGood++
        } else if (filterType = "Bad") {
            BeastStoredBad++
        }
        UpdateStatsDisplay()
    }
    AutoIndex++
return

; ─────────────────────────────────────────────────────────────────────────────
;  Detonate Dead Hotkeys
; ─────────────────────────────────────────────────────────────────────────────
F7::
    DetonateRunning := !DetonateRunning
    if (DetonateRunning) {
        if (SpamHoldMode) {
            ; HOLD mode - hold keys down
            if (SpamDualMode && SpamKey2 != "") {
                Send, {%SpamKey1% down}
                Send, {%SpamKey2% down}
            } else {
                Send, {%SpamKey1% down}
            }
            statusText := SpamDualMode ? "Hold: " . SpamKey1 . "+" . SpamKey2 : "Hold: " . SpamKey1
        } else {
            ; SPAM mode - start timer
            SetTimer, KeySpam, 1
            statusText := SpamDualMode ? "Spam: " . SpamKey1 . "+" . SpamKey2 : "Spam: " . SpamKey1
        }
        UpdateStatus(statusText)
    } else {
        if (SpamHoldMode) {
            ; HOLD mode - release keys
            if (SpamDualMode && SpamKey2 != "") {
                Send, {%SpamKey1% up}
                Send, {%SpamKey2% up}
            } else {
                Send, {%SpamKey1% up}
            }
        } else {
            ; SPAM mode - stop timer
            SetTimer, KeySpam, Off
        }
        UpdateStatus("Idle")
    }
return

DetonateSpam:
    ; Old function, kept for compatibility
return

KeySpam:
    if (!DetonateRunning)
        return
    
    IfWinNotActive, Path of Exile
    {
        return
    }
    
    GuiControlGet, currentDelay, , DetonateSlider
    
    if (SpamDualMode && SpamKey2 != "") {
        ; Dual key mode - press both keys
        Send, {%SpamKey1% down}
        Send, {%SpamKey2% down}
        Sleep, 10
        Send, {%SpamKey1% up}
        Send, {%SpamKey2% up}
    } else {
        ; Single key mode
        Send, {%SpamKey1%}
    }
    Sleep, %currentDelay%
return

; ─────────────────────────────────────────────────────────────────────────────
;  GemSwap Hotkeys
; ─────────────────────────────────────────────────────────────────────────────
F4::
    UpdateStatus("Gem Swap")
    SwapAllGems()
    UpdateStatus("Idle")
return

F9::
    ; Setup mode - handle F9 during GemSwap setup
    if (GemSwapSetupState >= 0) {
        if (GemSwapSetupState = 0) {
            MouseGetPos, Gem1InvX, Gem1InvY
            IniWrite, %Gem1InvX%, %ConfigINI%, GemSwap, Gem1InvX
            IniWrite, %Gem1InvY%, %ConfigINI%, GemSwap, Gem1InvY
            GemSwapSetupState := 1
            TrayTip, Saved, Now hover cursor over GEM 1 SOCKET and press F9, 3
            GuiControl,, GemSwapStatusText, Setup: Gem 1 socket
            return
        }
        if (GemSwapSetupState = 1) {
            MouseGetPos, Gem1SocketX, Gem1SocketY
            IniWrite, %Gem1SocketX%, %ConfigINI%, GemSwap, Gem1SocketX
            IniWrite, %Gem1SocketY%, %ConfigINI%, GemSwap, Gem1SocketY
            GemSwapSetupState := 2
            TrayTip, Saved, Now hover cursor over GEM 2 in inventory and press F9, 3
            GuiControl,, GemSwapStatusText, Setup: Gem 2 inventory
            return
        }
        if (GemSwapSetupState = 2) {
            MouseGetPos, Gem2InvX, Gem2InvY
            IniWrite, %Gem2InvX%, %ConfigINI%, GemSwap, Gem2InvX
            IniWrite, %Gem2InvY%, %ConfigINI%, GemSwap, Gem2InvY
            GemSwapSetupState := 3
            TrayTip, Saved, Now hover cursor over GEM 2 SOCKET and press F9, 3
            GuiControl,, GemSwapStatusText, Setup: Gem 2 socket
            return
        }
        if (GemSwapSetupState = 3) {
            MouseGetPos, Gem2SocketX, Gem2SocketY
            IniWrite, %Gem2SocketX%, %ConfigINI%, GemSwap, Gem2SocketX
            IniWrite, %Gem2SocketY%, %ConfigINI%, GemSwap, Gem2SocketY
            ; Check if we need 3 gems mode
            if (GemSwapMode = 2) {
                GemSwapSetupState := 4
                TrayTip, Saved, Now hover cursor over GEM 3 in inventory and press F9, 3
                GuiControl,, GemSwapStatusText, Setup: Gem 3 inventory
                return
            } else {
                GemSwapSetupState := -1
                GuiControl,, GemSwapStatusText, Setup complete! (2 gems)
                TrayTip, GEMSWAP SETUP COMPLETE, 2 gem positions saved!, 3
                SetTimer, ClearGemSwapStatus, -3000
                return
            }
        }
        if (GemSwapSetupState = 4) {
            MouseGetPos, Gem3InvX, Gem3InvY
            IniWrite, %Gem3InvX%, %ConfigINI%, GemSwap, Gem3InvX
            IniWrite, %Gem3InvY%, %ConfigINI%, GemSwap, Gem3InvY
            GemSwapSetupState := 5
            TrayTip, Saved, Now hover cursor over GEM 3 SOCKET and press F9, 3
            GuiControl,, GemSwapStatusText, Setup: Gem 3 socket
            return
        }
        if (GemSwapSetupState = 5) {
            MouseGetPos, Gem3SocketX, Gem3SocketY
            IniWrite, %Gem3SocketX%, %ConfigINI%, GemSwap, Gem3SocketX
            IniWrite, %Gem3SocketY%, %ConfigINI%, GemSwap, Gem3SocketY
            GemSwapSetupState := -1
            GuiControl,, GemSwapStatusText, Setup complete! (3 gems)
            TrayTip, GEMSWAP SETUP COMPLETE, 3 gem positions saved!, 3
            SetTimer, ClearGemSwapStatus, -3000
            return
        }
    }
return

F8::
    ; Setup mode - handle F8 during Stash setup
    if (StashSetupState >= 0) {
        if (StashSetupState = 0) {
            MouseGetPos, StashStartX, StashStartY
            IniWrite, %StashStartX%, %ConfigINI%, Stash, StartX
            IniWrite, %StashStartY%, %ConfigINI%, Stash, StartY
            StashSetupState := -1
            GuiControl,, BeastStatusText, Stash setup complete!
            TrayTip, STASH SETUP COMPLETE, Stash position saved!, 3
            SetTimer, ClearBeastStatus, -3000
            return
        }
    }
return

F12::
    ; Setup mode - handle F12 during Scour + Alch setup
    if (ScourAlchSetupState >= 0) {
        if (ScourAlchSetupState = 0) {
            MouseGetPos, ScourX, ScourY
            IniWrite, %ScourX%, %ConfigINI%, ScourAlch, ScourX
            IniWrite, %ScourY%, %ConfigINI%, ScourAlch, ScourY
            ScourAlchSetupState := 1
            TrayTip, Saved Scour: %ScourX%,%ScourY%, Now hover cursor over ALCHEMIST orb and press F12, 3
            GuiControl,, ScourAlchStatusText, Setup: Alchemist orb
            return
        }
        if (ScourAlchSetupState = 1) {
            MouseGetPos, AlchX, AlchY
            IniWrite, %AlchX%, %ConfigINI%, ScourAlch, AlchX
            IniWrite, %AlchY%, %ConfigINI%, ScourAlch, AlchY
            ScourAlchSetupState := 2
            TrayTip, Saved Alch: %AlchX%,%AlchY%, Now hover cursor over MAP position and press F12, 3
            GuiControl,, ScourAlchStatusText, Setup: Map position
            return
        }
        if (ScourAlchSetupState = 2) {
            MouseGetPos, MapX, MapY
            IniWrite, %MapX%, %ConfigINI%, ScourAlch, MapX
            IniWrite, %MapY%, %ConfigINI%, ScourAlch, MapY
            ScourAlchSetupState := 3
            TrayTip, Saved Map: %MapX%,%MapY%, Now hover cursor over CHAOS ORB and press F12, 3
            GuiControl,, ScourAlchStatusText, Setup: Chaos Orb
            return
        }
        if (ScourAlchSetupState = 3) {
            MouseGetPos, ChaosX, ChaosY
            IniWrite, %ChaosX%, %ConfigINI%, ChaosOrb, ChaosX
            IniWrite, %ChaosY%, %ConfigINI%, ChaosOrb, ChaosY
            ScourAlchSetupState := 4
            TrayTip, Saved Chaos: %ChaosX%,%ChaosY%, Now hover cursor over MAP in STASH for regex check and press F12, 3
            GuiControl,, ScourAlchStatusText, Setup: Map in Stash
            return
        }
        if (ScourAlchSetupState = 4) {
            MouseGetPos, RegexCheckX, RegexCheckY
            IniWrite, %RegexCheckX%, %ConfigINI%, ChaosOrb, RegexCheckX
            IniWrite, %RegexCheckY%, %ConfigINI%, ChaosOrb, RegexCheckY
            ScourAlchSetupState := -1
            TrayTip, Saved Regex Check: %RegexCheckX%,%RegexCheckY% - SETUP COMPLETE!, All positions saved!, 3
            GuiControl,, ScourAlchStatusText, Setup complete!
            SetTimer, ClearScourAlchStatus, -3000
            return
        }
    }
return

; ИСПРАВЛЕННАЯ ФУНКЦИЯ - автоматическое открытие/закрытие инвентаря
SwapAllGems() {
    IfWinNotActive, Path of Exile
    {
        ToolTip, [ERROR] Activate Path of Exile window first!
        SetTimer, RemoveToolTip, -2000
        return
    }
    
    ; Открыть инвентарь
    Send, {i}
    Sleep, 200
    
    SwapSingleGem(1)
    Sleep, 200
    SwapSingleGem(2)
    
    if (GemSwapMode = 2) {
        Sleep, 200
        SwapSingleGem(3)
    }
    
    ; Закрыть инвентарь
    Sleep, 200
    Send, {i}
}

; ИСПРАВЛЕННАЯ ФУНКЦИЯ - правильная логика свапа
SwapSingleGem(gemNum) {
    global minDelay, Gem1InvX, Gem1InvY, Gem2InvX, Gem2InvY, Gem3InvX, Gem3InvY
    global Gem1SocketX, Gem1SocketY, Gem2SocketX, Gem2SocketY, Gem3SocketX, Gem3SocketY
    
    clickDelay := 50
    
    if (gemNum = 1) {
        invX := Gem1InvX
        invY := Gem1InvY
        socketX := Gem1SocketX
        socketY := Gem1SocketY
    } 
    else if (gemNum = 2) {
        invX := Gem2InvX
        invY := Gem2InvY
        socketX := Gem2SocketX
        socketY := Gem2SocketY
    }
    else if (gemNum = 3) {
        invX := Gem3InvX
        invY := Gem3InvY
        socketX := Gem3SocketX
        socketY := Gem3SocketY
    }
    
    ; Check if positions are set
    if (invX = 0 || invY = 0 || socketX = 0 || socketY = 0) {
        ToolTip, [ERROR] Gem %gemNum% positions not set! Use Setup first!
        SetTimer, RemoveToolTip, -2000
        return
    }
    
    MoveCursor(invX, invY)
    Sleep, %minDelay%
    Click
    Sleep, %clickDelay%
    
    MoveCursor(socketX, socketY)
    Sleep, %minDelay%
    Click
    Sleep, %clickDelay%
    
    MoveCursor(invX, invY)
    Sleep, %minDelay%
    Click
    Sleep, %clickDelay%
}

; ─────────────────────────────────────────────────────────────────────────────
;  Other Functions
; ─────────────────────────────────────────────────────────────────────────────
F2::
UpdateStatus("Move to stash")
; Check if stash positions are configured
if (StashStartX = 0 || StashStartY = 0) {
    ToolTip, [ERROR] Stash positions not set! Use Setup first!
    SetTimer, RemoveToolTip, -2000
    UpdateStatus("Idle")
    return
}

; Use configured positions
rows := StashRows, cols := StashCols, startX := StashStartX, startY := StashStartY, cw := StashSlotWidth, ch := StashSlotHeight
Loop %rows% {
    r := A_Index-1
    Loop %cols% {
        c := A_Index-1
        if (c=11 && r<=4)
            continue
        x := startX + c*cw, y := startY + r*ch
        MoveCursor(x, y)
        Sleep, 5
        Send, ^{Click}
        Sleep, 5
    }
}
UpdateStatus("Idle")
return

+F3::
UpdateStatus("Fast Fusing/Jew")
SetTimer, FastClick, 1
return
+F3 up::
SetTimer, FastClick, Off
UpdateStatus("Idle")
return
FastClick:
IfWinActive, Path of Exile
    Click
Sleep, minDelay
return

F10::
UpdateStatus("Scour + Alch / Chaos Orb")
LoadChaosOrbPositions()
if (ChaosMode = 1) {
    ; Scour + Alch mode
    if (ScourAlchLoopEnabled) {
        ; Loop mode - toggle on/off
        ScourAlchRunning := !ScourAlchRunning
        if (ScourAlchRunning) {
            UpdateStatus("Scour + Alch Loop")
            SetTimer, ScourAlchLoop, 1
        } else {
            SetTimer, ScourAlchLoop, Off
            UpdateStatus("Idle")
        }
    } else {
        ; Single execution mode
        RunScourAlch()
        UpdateStatus("Idle")
    }
} else {
    ; Chaos Orb mode
    ChaosRunning := !ChaosRunning
    if (ChaosRunning) {
        UpdateStatus("Chaos Orb Spam")
        SetTimer, ChaosSpamLoop, 1
    } else {
        SetTimer, ChaosSpamLoop, Off
        UpdateStatus("Idle")
    }
}
return
RunScourAlch() {
    global minDelay, ScourX, ScourY, AlchX, AlchY, MapX, MapY, ConfigINI
    clickDelay := 50
    dropDelay := 100
    
    ; Load positions from INI file
    LoadScourAlchPositions()
    
    ; Check if positions are configured
    if (ScourX = 0 || ScourY = 0 || AlchX = 0 || AlchY = 0 || MapX = 0 || MapY = 0) {
        ToolTip, [ERROR] Scour + Alch positions not set! Use Setup first!
        SetTimer, RemoveToolTip, -2000
        return
    }
    
    ; Scour + Alch sequence
    MoveCursor(ScourX, ScourY)
    Sleep, minDelay
    Click, Right
    Sleep, clickDelay
    
    MoveCursor(MapX, MapY)
    Sleep, minDelay
    Click, Left
    Sleep, dropDelay
    
    MoveCursor(AlchX, AlchY)
    Sleep, minDelay
    Click, Right
    Sleep, clickDelay
    
    MoveCursor(MapX, MapY)
    Sleep, minDelay
    Click, Left
    Sleep, dropDelay
}

ScourAlchLoop:
    if (!ScourAlchRunning)
        return
    
    global minDelay, ScourX, ScourY, AlchX, AlchY, MapX, MapY, RegexStopEnabled, RegexCheckX1, RegexCheckY1, RegexCheckX2, RegexCheckY2
    clickDelay := 50
    dropDelay := 100
    
    ; Check for regex match (yellow border) if enabled
    if (RegexStopEnabled && RegexCheckX1 != 0 && RegexCheckY1 != 0 && RegexCheckX2 != 0 && RegexCheckY2 != 0) {
        ; Search for the yellow border color in the user-defined area
        PixelSearch, foundX, foundY, %RegexCheckX1%, %RegexCheckY1%, %RegexCheckX2%, %RegexCheckY2%, 0xe7b477, 0, Fast RGB
        
        if (ErrorLevel = 0) {
            ; Yellow color found!
            SetTimer, ScourAlchLoop, Off
            ScourAlchRunning := false
            ToolTip, [STOP] Yellow border found! Stopping Scour+Alch...
            Sleep, 2000
            ToolTip
            UpdateStatus("Idle")
            return
        }
    }
    
    ; Scour + Alch sequence
    MoveCursor(ScourX, ScourY)
    Sleep, minDelay
    Click, Right
    Sleep, clickDelay
    
    MoveCursor(MapX, MapY)
    Sleep, minDelay
    Click, Left
    Sleep, dropDelay
    
    MoveCursor(AlchX, AlchY)
    Sleep, minDelay
    Click, Right
    Sleep, clickDelay
    
    MoveCursor(MapX, MapY)
    Sleep, minDelay
    Click, Left
    Sleep, dropDelay
return

RunChaosOrb() {
    global minDelay, ChaosX, ChaosY, MapX, MapY, ChaosDelay, RegexStopEnabled, RegexStopColor
    clickDelay := 50
    
    ; Load positions from INI file
    LoadScourAlchPositions()
    LoadChaosOrbPositions()
    
    ; Check if positions are configured
    if (ChaosX = 0 || ChaosY = 0 || MapX = 0 || MapY = 0) {
        ToolTip, [ERROR] Chaos Orb positions not set! Use Setup first!
        SetTimer, RemoveToolTip, -2000
        return
    }
    
    ; Check for regex match (yellow border) if enabled
    if (RegexStopEnabled) {
        PixelGetColor, mapColor, %MapX%, %MapY%
        if (mapColor = RegexStopColor) {
            ToolTip, [STOP] Regex match found! Yellow border detected.
            SetTimer, RemoveToolTip, -2000
            return
        }
    }
    
    ; Chaos Orb sequence
    MoveCursor(ChaosX, ChaosY)
    Sleep, minDelay
    Click, Right
    Sleep, clickDelay
    
    MoveCursor(MapX, MapY)
    Sleep, minDelay
    Click, Left
    Sleep, ChaosDelay
}

ChaosSpamLoop:
    if (!ChaosRunning)
        return
    
    global minDelay, ChaosX, ChaosY, MapX, MapY, ChaosDelay, RegexStopEnabled, RegexStopColor, RegexCheckX1, RegexCheckY1, RegexCheckX2, RegexCheckY2
    clickDelay := 50
    
    ; Check for regex match (yellow border) if enabled
    if (RegexStopEnabled && RegexCheckX1 != 0 && RegexCheckY1 != 0 && RegexCheckX2 != 0 && RegexCheckY2 != 0) {
        ; Search for the yellow border color in the user-defined area
        PixelSearch, foundX, foundY, %RegexCheckX1%, %RegexCheckY1%, %RegexCheckX2%, %RegexCheckY2%, 0xe7b477, 0, Fast RGB
        
        if (ErrorLevel = 0) {
            ; Yellow color found!
            SetTimer, ChaosSpamLoop, Off
            ChaosRunning := false
            ToolTip, [STOP] Yellow border found! Stopping...
            Sleep, 2000
            ToolTip
            UpdateStatus("Idle")
            return
        }
    }
    
    ; Chaos Orb sequence
    MoveCursor(ChaosX, ChaosY)
    Sleep, minDelay
    Click, Right
    Sleep, clickDelay
    
    MoveCursor(MapX, MapY)
    Sleep, minDelay
    Click, Left
    Sleep, ChaosDelay
return


RemoveToolTip:
    ToolTip
return

MinimizeWindow:
Gui, Minimize
return
GuiClose:
ExitApp