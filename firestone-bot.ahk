; Deaeth85 Firestone Bot.ahk

#SingleInstance Force
#Include %A_ScriptDir%\Gui.ahk
#Include %A_ScriptDir%\Functions\Alchemist.ahk
#Include %A_ScriptDir%\Functions\Arena.ahk
#Include %A_ScriptDir%\Functions\CheckMail.ahk
#Include %A_ScriptDir%\Functions\ClaimBeer.ahk
#Include %A_ScriptDir%\Functions\subFunctions\ScarabToken.ahk
#Include %A_ScriptDir%\Functions\Scarab.ahk
#Include %A_ScriptDir%\Functions\ClaimEngineer.ahk
#Include %A_ScriptDir%\Functions\ClaimEvents.ahk
#Include %A_ScriptDir%\Functions\ClaimRituals.ahk
#Include %A_ScriptDir%\Functions\ExoticMerchant.ahk
#Include %A_ScriptDir%\Functions\Guardian.ahk
#Include %A_ScriptDir%\Functions\Guild.ahk
#Include %A_ScriptDir%\Functions\HeroUpgrade.ahk
#Include %A_ScriptDir%\Functions\MapRedeem.ahk
#Include %A_ScriptDir%\Functions\OpenChests.ahk
#Include %A_ScriptDir%\Functions\Quests.ahk
#Include %A_ScriptDir%\Functions\Research.ahk
#Include %A_ScriptDir%\Functions\Shop.ahk
#Include %A_ScriptDir%\Functions\SendHeartbeat.ahk
#Include %A_ScriptDir%\Functions\subFunctions\BigClose.ahk
#Include %A_ScriptDir%\Functions\subFunctions\GetColor.ahk
#Include %A_ScriptDir%\Functions\subFunctions\GoMap.ahk
#Include %A_ScriptDir%\Functions\subFunctions\MainMenu.ahk
#Include %A_ScriptDir%\Functions\subFunctions\MapClose.ahk
#Include %A_ScriptDir%\Functions\subFunctions\OpenTown.ahk
#Include %A_ScriptDir%\Functions\RestartGameRoutine.ahk

SetWorkingDir %A_ScriptDir%
#NoEnv
SetBatchLines, -1
Global FSBotGuiHwnd

; start of main script
MainScript(){
    currentTime := A_TickCount
    global lastExecutionTimeArena := 0
    global MapPoints :=
    global lastRestartTime := A_TickCount
    IniRead, RestartGameTime, settings.ini, OtherOptions, RestartGameTime, 0
    RestartGameTimeMs := RestartGameTime * 3600000
    loop:
    GuiControlGet, Checked, , RestartGame
    If (Checked = 1){
        currentTime := A_TickCount
        GuiControlGet, CheckedRestartGameTest, , RestartGameTest
        If (CheckedRestartGameTest = 1 || currentTime - lastRestartTime >= RestartGameTimeMs){
            SendHeartbeat("Initiating 24h Game Restart", false, true)
            RestartGameRoutine()
        }
    }
    ControlFocus,, ahk_exe Firestone.exe
    ; do main screen sections
    SendHeartbeat("Starting Bot", false, true)
    MsgBox, , Main Menu Check, Checking to ensure we are on main screen at loop start, 2
    MainMenu()
    ControlFocus,, ahk_exe Firestone.exe
    GuiControlGet, Checked, , Events,
    If (Checked = 1){
        ClaimEvents()
    }
    ; check if Claim Quests is checked
    GuiControlGet, Checked, , Quests,
    If (Checked = 1){
        SendHeartbeat("ClaimQuests", false)
        ClaimQuests()
    }
    MsgBox, , Main Menu Check, Checking to ensure we are on main screen after claiming quests, 2
    MainMenu()
    ControlFocus,, ahk_exe Firestone.exe
    ;~ ; check if Claim Free Gift and Check-in is checked
    GuiControlGet, Checked, , Shop,
    If (Checked = 1){
        SendHeartbeat("Shop", false)
        Shop()
    }
    ; check if Check Mail is checked
    GuiControlGet, Checked, , Mail
    If (Checked = 1){
        SendHeartbeat("CheckMail", false)
        CheckMail()
    }
    ; check if Open Chests is checked
    GuiControlGet, Checked, , Chests,
    If (Checked = 1){
        SendHeartbeat("OpenChests", false)
        OpenChests()
    } Else {
        ;check if Upgrade Blessings is checked
        GuiControlGet, Checked, , Bless,
        If (Checked = 1){
            SendHeartbeat("OpenBlessChests", false)
            OpenBlessChests()
        }
    }
    ; start town section
    OpenTown()
    ; check for guardian upgrade
    SendHeartbeat("Guardian", false)
    Guardian()
    ; tavern
    SendHeartbeat("ClaimBeer", false)
    ClaimBeer()
    SendHeartbeat("ScarabToken", false)
    ScarabToken()
    SendHeartbeat("Scarab", false)
    Scarab()
    ; claim rituals
    GuiControlGet, Checked, , SkipOracle,
    If (Checked = 1){
        Goto, Engineer
    }
    SendHeartbeat("ClaimRituals", false)
    ClaimRituals()
    Engineer:
    ; check if skip engineer is checked
    GuiControlGet, Checked, , NoEng,
    If (Checked = 1){
        Goto, ExoticSection
    }
    SendHeartbeat("ClaimEngineer", false)
    ClaimEngineer()
    ExoticSection:
    ; check if sell exotic is checked (sell all check is internal to sell exotic script)
    GuiControlGet, Checked, , SellEx,
    If (Checked = 1){
        SendHeartbeat("ExoticMerchant", false)
        ExoticMerchant()
    }
    ; check if do arena is checked
    GuiControlGet, Checked, , PVP,
    If (Checked = 1){
        ; get current time
        currentTimeArena := A_TickCount
        ;check if it's been 24 hours since last execution
        If (lastExecutionTimeArena <= 0 || currentTimeArena - lastExecutionTimeArena >= 6 * 60 * 60 * 1000){
            SendHeartbeat("Arena", false)
            Arena()
            lastExecutionTimeArena := currentTimeArena
        }
    }
    ; check if we are skipping alchemy
    GuiControlGet, Checked, , Alch,
    If (Checked = 1){
        Goto, ResearchStart
    } Else {
        SendHeartbeat("Alchemist", false)
        Alchemist()
    }
    ; check if we are skipping research
    ResearchStart:
    GuiControlGet, Checked, , Research,
    If (Checked = 1){
        Goto, FinishTown
    } Else {
        SendHeartbeat("GoResearch", false)
        GoResearch()
    }
    FinishTown:
    BigClose()
    GuiControlGet, Checked, , NoGuild,
    If (Checked = 1){
        Goto, MapStartUp
    }
    Guild()
    MapStartUp:
    GoMap()
    SendHeartbeat("MapRedeem", false)
    MapRedeem()
    UpgradeHero:
    GuiControlGet, Checked, , NoHero,
    If (Checked = 1){
        Goto, EndingMouseMove
    }
    SendHeartbeat("HeroUpgrade", false)
    HeroUpgrade()
    EndingMouseMove:
    SendHeartbeat("Delay ending bot", false)
    GuiControlGet, SelectedItem, ,Delay,
    If (SelectedItem="0"){
        Goto, Loop
    }
    GuiControlGet, SelectedItem, ,Delay,
    If (SelectedItem="30"){
        MouseMove, 947, 755
        Sleep, 30000
        Goto, Loop
    }
    GuiControlGet, SelectedItem, ,Delay,
    If (SelectedItem="60"){
        MouseMove, 947, 755
        Sleep, 60000
        Goto, Loop
    }
    GuiControlGet, SelectedItem, ,Delay,
    If (SelectedItem="90"){
        MouseMove, 947, 755
        Sleep, 90000
        Goto, Loop
    }
    GuiControlGet, SelectedItem, ,Delay,
    If (SelectedItem="120"){
        MouseMove, 947, 755
        Sleep, 120000
        Goto, Loop
    }
    GuiControlGet, SelectedItem, ,Delay,
    If (SelectedItem="300"){
        MouseMove, 947, 755
        Sleep, 300000
        Goto, Loop
    }
    GuiControlGet, SelectedItem, ,Delay,
    If (SelectedItem="600"){
        MouseMove, 947, 755
        Sleep, 600000
        Goto, Loop
    }
}

GuiEscape:
GuiClose:
;    *#$Esc::    ; Escape
    ;~*#$Esc::    ; Windows Key + Escape
    *#$Esc::    ; Windows Key + Escape
      ; Key      Function
      ;  ~       Passes the normal key's action, so if you do ~Esc, it will capture the hotkey, but also still send the Esc key sequence to the system/current app.
      ;  *       Fires the hotkey even if extra modifiers are begin held down.
      ;  #       Windows Key
      ;  $       Only necessary if the script uses the Send command.  We use ~ and *, which are keyboard modifiers, so we technically don't need the $.
      ; ~*#$Esc  This is Windows Key + Esc
    SendHeartbeat("Exit Bot", true, true)
    ExitApp
;~Esc::Return
