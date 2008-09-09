-- Übersetzung von Warkiller102(Server: Terrodar Char: Hinatahyuuga)
-- Translation by Warkiller102(Server: Terrodar Char: Hinatahyuuga)
if( GetLocale() ~= "deDE" ) then
	return
end

SSPVPLocals = setmetatable({
	-- Battlefield names
	["Warsong Gulch"] = "Kriegshymnenschlucht",
	["Arathi Basin"] = "Arathibecken",
	["Alterac Valley"] = "Alteractal",
	["Eye of the Storm"] = "Auge des Sturms",

	["Blade's Edge Arena"] = "Arena des Schergrats",
	["Nagrand Arena"] = "Arena von Nagrand",
	["Ruins of Lordaeron"] = "Ruinen von Lordaeron",
	
	["Rated"] = "Gewertet",
	["Skirmish"] = "Nicht gewertet",
	["Arena"] = "Arena",
	["All Arenas"] = "Alle Arenen",
	["%s (%dvs%d)"] = "%s (%dvs%d)",
	["Rated Arena"] = "Gewertete Arena",
	["Skirmish Arena"] = "Nicht gewertete Arena",

	["You are now in the queue for %s Arena (%dvs%d)."] = "Du bist jetzt in der Warteschlange f\195\188r %s Arena (%dvs%d).",
	["You are now in the queue for %s."] = "Du bist jetzt in der Warteschlange f\195\188r %s.",
	
	["Higher priority battlefield ready, auto joining %s in %d seconds."] = "Schlachtfeld mit h\195\182herer Priorit\195\164t gefunden, Auto-Beitreten zu %s in %d Sekunden.",
	["Your current activity is a higher priority then %s, not auto joining."] = "Ihr macht gerade etwas mit h\195\182herer Priorit\195\164t als %s, Auto-Beitreten deaktiviert.",
	["You have the battlefield entry window hidden for %s, will not auto join."] = "Du hast das Schlachtfeld Fenster versteckt f\195\188r %s, es wird nicht automatisch beigetreten.",
	
	["%s %d points (%d rating)"] = "%s %d Punkte (%d Wertung)",
	["/ %d personal (%d rating)"] = "/ %d pers\195\182nlich (%d Wertung)",
	
	["You are about to leave the active or queued arena %s (%dvs%d), are you sure?"] = "Ihr seid gerade dabei, die aktive oder angemeldete Arena %s (%d vs %d) zu verlassen, seid Ihr sicher?",
	["You are about to leave the active or queued battleground %s, are you sure?"] = "Ihr seid gerade dabei, das aktive oder angemeldete Schlachtfeld %s zu verlassen, seid Ihr sicher?",
	
	["Horde"] = "Horde",
	["Alliance"] = "Allianz",
	["Screenshot saved as %s."] = "Screenshot gespeichert als WoWScrnShot_%s.%s.",
	
	["(L) %s"] = "(L) %s",
	["Rating"] = "Wertung",
	
	["Releasing..."] = "Freilassen...",
	["Using %s..."] = "Benutze %s...",
	
	["Starting: %s"] = "Beginnt in: %s",
	
	["the raid group.$"] = "Die Schlachtgruppe.$",
	
	["The"] = "Die",
	
	["Alliance"] = "Allianz",
	["Horde"] = "Horde",
	
	["[%s] %s: %s"] = "[%s] %s: %s",
	
	["Unavailable"] = "nicht vorhanden",
	["<1 Min"] = "<1 Min",
	["Join Suspended"] = "Beitritt aufgeschoben",
	["Join Disabled"] = "Beitritt abgebrochen",
	["Joining"] = "Beitritt",
	["(.+) Mark of Honor"] = "(.+) Ehrenmarke",
	["%s |cffffffff(%dvs%d)|r"] = "%s |cffffffff(%dvs%d)|r",
	["Flag Respawn: %s"] = "Flaggen-Respawn: %s",
	["Auto release disabled, %d %s until release"] = "Automatische Freilassung abgeschaltet, %d %s bis zur Freilassung",
	
	["%d personal rating in %s (%dvs%d)"] = "%d pers\195\182nliche Wertung in %s (%dvs%d)",
	["%s is ready to join, auto leave disabled."] = "%s ist zum Betritt bereit, automatisch Verlassen abgeschaltet.",
	
	-- Modified queue window
	["You are now eligible to enter %s. %s left to join."] = "Du kannst jetzt %s beitreten. %s noch zum beitreten Zeit.",
	
	-- Mover
	["PvP Objectives Anchor"] = "PvP Ziele Anker",
	["Score Objectives Anchor"] = "Ergebnis Objekte Anker",
	["Left Click + Drag to move the frame, Right Click + Drag to reset it to it's original position."] = "Linksklick und verschieben um das Fenster zu verschieben, Rechtsklick und verschieben um es an die Ursprungsposition zur\195\188ck zu setzen.",
	
	-- Win API is broken /wrist
	["The Horde wins"] = "Die Horde gewinnt",
	["The Alliance wins"] = "Die Allianz gewinnt",
	
	-- So we don't auto leave before completing
	["Call to Arms: %s"] = "Ruf zu den Waffen: %s",
	["You currently have the battleground daily quest for %s, auto leave has been set to occure once the quest completes."] = "Du hast zur Zeit den t\195\164glichen Schlachtfeldquest f\195\188r %s, automatisches Verlassen wird so lange ausgesetzt bis die Quest abgeschlossen ist.",
	
	-- Modified arena info
	["Season"] = "Saison",
	["Week"] = "Woche",
	
	-- Flags
	["%s flag carrier %s, held for %s."] = "Flaggentr\195\164ger der %s %s, gehalten f\195\188r %s.",
	
	["was picked up by (.+)!"] = "(.+) hat die Flagge der (.+) aufgenommen!",
	["captured the"] = "(.+) hat die Flagge der (.+) errungen",
	["was dropped by (.+)!"] = "(.+) hat die Flagge der (.+) fallen lassen!",
	["was returned to its base"] = "Die Flagge der (.+) wurde von (.+) zu ihrem St\195\188tzpunkt zur\195\188ckgebracht!",
	
	["(.+) has taken the flag!"] = "(.+) hat die Flagge aufgenommen.",
	["The flag has been dropped"] = "Die Flagge wurde fallengelassen.",
	
	["Held Time: %s"] = "Gehalten: %s",
	["Capture Time: %s"] = "Eroberungszeit: %s",
	
	["Cannot target %s, in combat"] = "Kann %s nicht ins Ziel nehmen, da er im Kampf ist",
	["Targetting %s"] = "Ziel: %s",
	["%s is out of range"] = "%s ist au\195\159er Reichweite",
	
	-- Sync queuing for AV
	["You must be in a raid or party to do this."] = "Du musst in einer Schlachgruppe oder Gruppe sein um das zu tun.",
	["You must be group leader, or assist to do this."] = "Du musst der Gruppenanf\195\188hrer oder Assistent sein, um das zu tun.",
	["You have been queued for Alterac Valley by %s."] = "Du bist in der Warteschlange f\195\188r das Alteractal seit %s.",
	["You provided an invalid instance ID to join."] = "Du hast eine unzul\195\164ssige Instanz ID gew\195\164hlt um beizutreten.",
	
	["Queuing %d seconds."] = "Wartezeit %d Sekunden.",
	["Queuing %d second."] = "Wartezeit %d Sekunde.",
	["Queue for Alterac Valley!"] = "Warteschlange f\195\188r Alterac!",

	["Battlemaster window ready check started, you have 10 seconds to get the window open."] = "Kampfmeiser-Fenster \195\188berpr\195\188fung gestartet, du hast 10 Sekunden, um das Fenster zu \195\182ffnen.",
	["Leaving Alterac Valley queues."] = "Verlassen der Alterac Warteschlange.",
	
	["Alterac Valley sync queue has been stopped by %s."] = "Alterac Synchronisierungs Warteschlange wurde gestoppt von %s.",
	["Alterac Valley queue stopped."] = "Alteractal Warteschlange gestoppt.",
	["Alterac Valley queue has been dropped by %s."] = "Alterac Synchronisierungs Warteschlange wurde abgebrochen von %s.",
	
	["Forcing join on instance #%d."] = "Versuche der Instanz beizutreten #%d.",
	["Invalid number entered for sync queue."] = "Ung\195\188ltige Nummer eingegeben f\195\188r Synchronisierungs Warteschlange.",
	["Joining Alterac Valley #%d at the request of %s"] = "Betrete das Alterac #%d auf Anfrage von %s",
	["%s has requested you join Alterac Valley #%d, but you have force join disabled."] = "%s fragt ob du dem Alterac #%d beitreten willst, aber du hast schnelles Beitreten ausgeschaltet.",
	
	["Ready: %s"] = "Bereit: %s",
	["Not Ready: %s"] = "Nicht Bereit: %s",
	["Everyone is ready to go!"] = "Jeder ist bereit zu gehen!",
	
	-- Queue status GUI for AV
	["Queue Status"] = "Warteschlangen Status",
	["Name"] = "Name",
	["Status"] = "Status",
	["Queue"] = "Warteschlange",
	["Version"] = "Version",
	
	["Unknown"] = "Unbekannt",
	["Not queued"] = "Nicht wartend",
	["Inside #%d"] = "Innen #%d",
	["Confirm #%d"] = "Best\195\164tigt #%d",
	["Queued Any"] = "Jeder wartet",
	["Queued #%d"] = "Wartet #%d",
	["Offline"] = "Offline",
	["Online"] = "Online",
	["Ready"] = "Bereit",
	["Not ready"] = "Nicht Bereit",
	
	["Total Players"] = "Gesamtspieler",
	["Ready"] = "Bereit",
	["Not Ready"] = "Nicht Bereit",
	
	["Ready Check"] = "Pr\195\188fung vorbereiten",
	["Sync Queue"] = "Synchronisiere Warteschlange",
	["Drop Queue"] = "Warteschlange abgebrochen",
	
	["New version available!"] = "Neue Version erh\195\164ltlich!",
	["AFK"] = "AFK",
	["Next Update"] = "N\195\164chstes Update",
	["You are about to send a queue drop request, are you sure?"] = "Du bist dabei einen Abbruchantrag f\195\188r die Warteschlange durchzuf\195\188hren, bist du sicher?",
	
	-- CT support / CT Hilfe
	["-%d Reinforcements"] = "-%d Verst\195\164rkung",
	["+%d Points"] = "+%d Punkte",
	
	-- Score tooltip
	["%s (%d players)"] = "%s (%d Spieler)",
	["Servers"] = "Server",
	["Classes"] = "Klassen",
	
	-- Arathi basin / Arathibecken
	["claims the ([^!]+)"] = "hat ([^!]+) besetzt!",
	["has taken the ([^!]+)"] = "hat ([^!]+) eingenommen!",
	["has assaulted the ([^!]+)"] = "hat ([^!]+) angegriffen!",
	["has defended the ([^!]+)"] = "hat ([^!]+) verteidigt!",
	
	["Bases: ([0-9]+)  Resources: ([0-9]+)/2000"] = "Basen: ([0-9]+)  Ressourcen: ([0-9]+)/2000",
	["Final Score: %d"] = "Endstand: %d",
	["Time Left: %s"] = "Verbleibende Zeit: %s",
	["Bases to win: %d"] = "Basen zum Sieg: %d",
	["Base Final: %d"] = "Basen am Ende: %d",
	
	-- Alterac valley / Alteractal
	["Herald"] = "Herold",
	["Snowfall Graveyard"] = "Der Schneewehenfriedhof",
	["claims the Snowfall graveyard"] = "hat den Schneewehenfriedhof besetzt",
	["(.+) is under attack"] = "(.+) wird angegriffen!",
	["(.+) was taken"] = "(.+) wurde von der (.+) erobert",
	["(.+) was destroyed"] = "(.+) wurde von der (.+) zerst\195\182rt",
	
	["Reinforcements: ([0-9]+)"] = "Verst\195\164rkung: ([0-9]+)",
	["%s will be captured by the %s in %s"] = "%s wird von der %s in %s erobert!",
	
	-- Eye of the Storm / Auge des Sturms
	["Bases: ([0-9]+)  Victory Points: ([0-9]+)/2000"] = "Basen: ([0-9]+)  Siegespunkte: ([0-9]+)%/2000",
	["Bases %d  Points %d/2000"] = "Basen %d  Punkte %d/2000",
	["flag has been reset"] = "Die Flagge wurde zur\195\188ckgesetzt.",
	
	-- Gods / Götter
	["Ivus the Forest Lord"] = "Ivus der Waldf\195\188rst",
	["Lokholar the Ice Lord"] = "Lokholar der Eislord",
	
	["Ivus Moving: %s"] = "Ivus der Waldf\195\188rst in Bewegung: %s",
	["Lokholar Moving: %s"] = "Lokholar der Eislord in Bewegung: %s",
	
	["Wicked, wicked, mortals"] = "Gemeine, Gemeine, Sterbliche",
	["WHO DARES SUMMON LOKHOLA"] = "WER WAGT ES LOKHOLA HERBEIZURUFEN?",

	-- Captain Galvangar / Hauptmann Galvangar
	["Captain Galvangar"] = "Hauptmann Galvangar",
	
	["The Alliance has slain Captain Galvangar."] = "Die Allianz hat Hauptmann Galvangar get\195\182tet.",
	["The Alliance has engaged Captain Galvangar."] = "Die Allianz hat Hauptmann Galvangar angegriffen.",
	["The Alliance has reset Captain Galvangar."] = "Die Allianz hat Hauptmann Galvangar zur\195\188ckgesetzt.",
	
	["Your kind has no place in Alterac Valley"] = "F\195\188r Eure Art ist kein Platz im Alteractal!",
	["I'll never fall for that, fool!"] = "Ich werde niemals fallen, Dummkopf!",
	
	-- Captain Balinda / Hauptmann Balinda Steinbruch
	["Captain Balinda Stonehearth"] = "Hauptmann Balinda Steinbruch",
	
	["The Horde has slain Captain Balinda Stonehearth."] = "Die Horde hat Hauptmann Balinda Steinbruch get\195\182tet.",
	["The Horde has engaged Captain Balinda Stonehearth."] = "Die Horde hat Hauptmann Balinda Steinbruch angegriffen.",
	["The Horde has reset Captain Balinda Stonehearth."] = "Die Horde hat Hauptmann Balinda Steinbruch zur\195\188ckgesetzt.",
	
	["Begone, uncouth scum!"] = "Verschwinde, dreckiger Abschaum!",
	["Filthy Frostwolf cowards"] = "R\195\164udige Frostwolf-Feiglinge",
	
	-- Drek'Thar / Drek'Thar
	["Drek'Thar"] = "Drek'Thar",
	
	["The Alliance has engaged Drek'Thar."] = "Die Allianz hat Drek'Thar angegriffen.",
	["The Alliance has reset Drek'Thar."] = "Die Allianz hat Drek'Thar zur\195\188ckgesetzt.",
	
	["Stormpike weaklings"] = "Sturmlanzenschw\195\164chlinge",
	["Stormpike filth!"] = "Sturmlanzenabschaum!",
	["You seek to draw the General of the Frostwolf"] = "Ihr versucht, den General der Frostwolf Armee aus seinem Bunker zu locken? PAH das ich nicht Lache!",
	
	-- Vanndar Stormpike / Vanndar Sturmlanze
	["Vanndar Stormpike"] = "Vanndar Sturmlanze",
	
	["The Horde has reset Vanndar Stormpike."] = "Die Horde hat Vanndar Sturmlanze zur\195\188ckgesetzt.",
	["The Horde has engaged Vanndar Stormpike."] = "Die Horde hat Vanndar Sturmlanze angegriffen.",
	
	["Why don't ya try again"] = "Warum versucht Ihr es nicht nochmal",
	["Soldiers of Stormpike, your General is under attack"] = "Soldaten des Sturmlanzenklans, euer General wird angegriffen!",	
	["You'll never get me out of me"] = "Ihr werdet mich niemals aus meinem Bunker locken!",	

	-- Text for catching time until match starts / Zeiten bevor das Spiel startet
	["2 minute"] = "2 Minuten",
	["1 minute"] = "1 Minute",
	["30 seconds"] = "30 Sekunden",
	["Fifteen seconds"] = "f\195\188nfzehn Sekunden",
	["Thirty seconds"] = "drei\195\159ig Sekunden",
	["One minute"] = "Eine Minute",
	
	-- Slash commands / Slash Befehle
	["SSPVP Arena slash commands"] = "SSPVP Arena slash('/') Befehle",
	[" - rating <rating> - Calculates points given from the passed rating."] = " - rating <rating> - Errechnet die gegebenen Punkte von der letzten Wertung.",
	[" - points <points> - Calculates rating required to reach the passed points."] = " - points <points> - Errechnet die Bewertung, die erfordert wird, um die gebrauchten Punkte zu erreichen.",
	[" - attend <played> <team> - Calculates games required to reach 30% using the passed games <played> out of the <team> games played."] = " - attend <played> <team> - Errechnet die Spiele, die erfordert werden, um 30% mit den gef\195\188hrten <gespielten> Spielen zu erreichen aus den <Mannschaft> Spielen herraus..",
	[" - change <winner rating> <loser rating> - Calculates points gained/lost assuming the <winner rating> beats <loser rating>."] = " - change <winner rating> <loser rating> - Errechnet die gewonnenen/verlorenen Punkte der <Siegerbewertung> gegen die <Verliererwertung> aus.",
	
	["SSPVP Alterac Valley slash commands"] = "SSPVP Alterac slash('/') Befehle",
	[" - sync <seconds> - Starts a count down for an Alterac Valley sync queue."] = " - sync <seconds> - Starten einen Countdown f\195\188r eine Alterac Synchronisierungs Warteschlange.",
	[" - cancel - Cancels a running sync."] = " - cancel - Beendet alle Synchronisierungen.",
	[" - drop - Drops all Alterac Valley queues."] = " - drop - Beendet alle Alterac Warteschlangen.",
	[" - update - Forces a status update on everyones Alterac Valley queues."] = " - update - Erzwingt ein Statusupdate auf jede Alterac Warteschlange.",
	[" - ready - Does a check to see who has the battlemaster window open and is ready to queue."] = " - ready - Pr\195\188ft das Kampfmeister-Fenster ob es ge\195\182ffnet ist und ob die Warteschlange bereit ist.",
	[" - join <instanceID> - Forces everyone with the specified instance id to join Alterac Valley."] = " - join <instanceID> - Versucht jeden, mit der spezifizierten Instanz ID, mit dem Alterac zu betreten.",
	[" - status - Shows the status list of everyone regarding queue or window."] = " - status - Zeigt die Statuslise von jeder betreffenden Warteschlange oder jedem Fenster an.",

	["You do not have Alterac Valley syncing enabled, and cannot use any of the slash commands yourself."] = "Du hast das Alterac Synchronisieren nicht an, deshalb kannst du keine slash Befehle benutzen.",
	
	["SSPVP slash commands"] = "SSPVP slash('/') Befehle",
	[" - suspend - Suspends auto join and leave for 5 minutes, or until you log off."] = " - suspend - Verschiebt das automatische beitreten um 5 Minuten oder wenn du ausloggst.",
	[" - ui - Opens the OptionHouse configuration for SSPVP."] = " - ui - Das OptionHouse wird ge\195\182ffnet um SSPVP zu konfigurieren.",
	[" - Other slash commands"] = " - Andere slash('/') Befehle",
	[" - /av - Alterac Valley sync queuing."] = " - /av - Alterac Synchronisierungs Warteschlange.",
	[" - /arena - Easy Arena calculations and conversions"] = " - /arena - Einfache Arenaberechnungen und -umwandlungen",
	
	
	["Auto join and leave has been suspended for the next 5 minutes, or until you log off."] = "Automatisches beitreten und verlassen verschiebt sich um 5 Minuten oder auf wenn du ausloggst.",
	["Suspension has been removed, you will now auto join and leave again."] = "Die Verschiebung wurde gel\195\182scht, du kannst nun wieder automatisch beitreten und verlassen.",
	["Suspension is still active, will not auto join or leave."] = "Verschiebung ist aktiv, kein automatischen beitreten und verlassen m\195\182glich.",
	
	["[%d vs %d] %d rating = %d points"] = "[%d vs %d] %d Wertung = %d Punkte",
	["[%d vs %d] %d rating = %d points - %d%% = %d points"] = "[%d vs %d] %d Wertung = %d Punkte - %d%% = %d Punkte",
	["[%d vs %d] %d points = %d rating"] = "[%d vs %d] %d Punkte = %d Wertung",
	
	["%d games out of %d total is already above 30%% (%.2f%%)."] = "%d Spiele aus %d Gesamt ist bereits \195\188ber 30%% (%.2f%%).",
	["%d more games have to be played (%d total) to reach 30%%."] = "%d mehr Spiele m\195\188ssen noch gespielt werden (%d Gesamt) um 30%% zu erreichen.",
	
	["+%d points (%d rating) / %d points (%d rating)"] = "+%d Punkte (%d Wertung) / %d Punkte (%d Wertung)",

	-- Overlay categories / Übersichts Kategorien
	["Faction Balance"] = "Fraktionsverteilung",
	["Timers"] = "Timer",
	["Match Info"] = "Spiel Info",
	["Bases to win"] = "Basen zum Sieg",
	["Mine Reinforcement"] = "Mine Reinforcement",
	["Battlefield Queue"] = "Schlachtfeld-Warteschlange",
	["Frame Moving"] = "Fenster bewegen",
	["Alterac Valley sync queuing"] = "Alterac Synchronisierungs Warteschlange",
	
	-- GOOEY / GOOEY
	["General"] = "Allgemein",
	["Auto Queue"] = "Auto-Warteschlange",
	["Battlefield"] = "Schlachtfeld",
	["Overlay"] = "Info-Fenster",
	["Auto Join"] = "Auto-Beitreten",
	["Display"] = "Anzeige",

	-- GENERAL / Allgeimein
	["Play"] = "Spielen",
	["Stop"] = "Stoppen",
	
	["Sound file"] = "Sounddatei",
	["Timer channel"] = "Timer Channel",
	["Show team summary after rated arena ends"] = "Zeigt die Mannschaftszusammenfassung nach dem Ende einer bewerteten Arenarunde",
	["Auto append server name while in battlefields for whispers"] = "Automatisch den Servername an ihre Fl\195\188sternachrichten eingef\195\188gen",
	["Auto queue when inside of a group and leader"] = "Automatische Warteschlange wenn du innerhalb einer Gruppe bist oder der Anf\195\188hrer",
	["Battleground"] = "Schlachtfeld",
	["Party"] = "Gruppe",
	["Raid"] = "Schlachtgruppe",
	
	["Shows how much personal rating you gain/lost, will only show up if it's no the same amount of points as your actual team got."] = "Zeigt wie viel pers\195\182nliche Wertung man bekommen/verloren hat, wird nur angezeit wenn es nicht die gleiche Wertung wie die Teamwertung ist.",

	["Show personal rating change after arena ends"] = "Zeige pers\195\182nliche Wertung, nachdem die Arena beendet ist.",
	
	["Automatically append \"-server\" to peoples names when you whisper them, if multiple people are found to match the same name then it won't add the server."] = "F\195\188gt automatisch \"-server\" zu den Charakternamen hinzu, wenn du fl\195\188sterst, wenn mehrere Charakter gefunden werden, die die gleichen Namen haben, wird der Server nicht hinzugef\195\188gt.",
	["Shows team names, points change and the new ratings after the arena ends."] = "Zeigt die Namen, die Punkte\195\164nderung und die neue Wertung nachdem die Arena beendet ist.",
	["Channel to output to when you send timers out from the overlay."] = "Channel wo die Zeiten ausgegeben werden vom \195\156bersichtsfenster.",
	["Sound file to play when a queue is ready, file must be inside Interface/AddOns/SSPVP before you started the game."] = "Sounddatei zum Abspielen wenn Warteschlange bereit ist, die Datei muss im Ordner x:\World of Warcraft\Interface\AddOns\SSPVP2 (x = Laufwerksbuchstabe) sein, noch bevor Ihr das Spiel gestartet habt.",
	
	["Auto queue when outside of a group"] = "Automatische Warteschlange wenn du au\195\159erhalb einer Gruppe bist",
	["Auto queue when inside a group and leader"] = "Automatische Warteschlange wenn du innerhalb einer Gruppe bist oder der Anf\195\188hrer",
	
	["Queue Overlay"] = "Warteschlangen-Info",
	["Enable battlefield queue status"] = "Aktiviere Warteschlangen-Info",
	["Show inside an active battlefield"] = "Stelle innerhalb eines aktiven Schlachtfelds dar",
	
	["Entry Window"] = "Eintragungs Fenster",
	["Enable modified battlefield join window"] = "Erm\195\182gliche, dass das Schlachtfeld Fenster modifiziert werden darf",
	["Shows time left to join the battlefield, also required for disabling the battlefield window from reshowing again."] = "Zeigt die restliche Zeit um dem Schlachtfeld beizutreten, ebenfals wird dies gebraucht um das Schlachtfeld Fenster zum wiederholten Anzeigen zu unterdr\195\188cken.",
	
	["Show battlefield window after it's hidden"] = "Zeigt das Schlachtfeld Fenster, nachdem es versteckt wurde",
	["Reshows the battlefield window even if it's been hidden, requires modified window to be enabled."] = "Zeigt nochmals das Schlachtfeld Fenster, selbst wenn es versteckt wurde, erfordert die \195\132nderungsfreigabe des Fensters.",
	
	["Lock PvP objectives"] = "Fixiere Outdoor-PvP-Ziele",
	["Lock scoreboard"] = "Fixiere Schlachtfeld-Punkteanzeige",
	["Lock capture bar"] = "Fixiere Eroberungsbalken",
	["Shows an anchor above the frame that lets you move it, the frame you're trying to move may have to be visible to actually move it."] = "Zeigt einen Anker \195\188ber dem Rahmen, mit dem sich das Fenster verschieben l\195\164\195\159t, der Rahmen muss daf\195\188r Sichtbar sein.",
	
	-- BATTLEFIELD / Schlachtfeld
	["Death"] = "Tod",
	["Scoreboard"] = "Punkteanzeige",
	["Color player name by class"] = "F\195\164rbe Spielernamen nach Klasse",
	["Hide class icon next to names"] = "Verberge Klassenicon neben dem Namen",
	["Show player levels next to name"] = "Zeige Spielerlevel neben dem Namen",
	["Release from corpse when inside an active battleground"] = "Automatisches Akzeptieren von Wiederbelebungen innerhalb eines aktiven Schlachtfelds",
	["Release even with a soul stone active"] = "Automatische Geist-Freigabe auch mit einem aktiven Seelenstein",
	
	-- AUTO JOIN / Automatisch Beitreten
	["Delay"] = "Verz\195\182gerung",
	["Join priorities"] = "Beitritts Priorit\195\164ten",
	["Enable auto join"] = "Aktiviere Auto-Beitreten",
	["Priority check mode"] = "Priorit\195\164ts pr\195\188f Modus",
	["Less than"] = "Kleiner als",
	["Less than/equal"] = "Kleiner als/gleich",
	["Battleground join delay"] = "Verz\195\182gerung beim Beitreten von Schlachtfeldern",
	["AFK battleground join delay"] = "Verz\195\182gerung beim Beitreten von Schlachtfeldern wenn AFK",
	["Arena join delay"] = "Verz\195\182gerung beim Beitreten von Arenen",
	["Don't auto join a battlefield if the queue window is hidden"] = "Nicht automatisch beitreten, wenn das Warteschlangen Fenster versteckt wird.",
	
	-- AUTO LEAVE / Automatisch Verlassen
	["Auto Leave"] = "Auto-Verlassen",
	["Confirmation"] = "Best\195\164tigung",
	["Confirm when leaving a battlefield queue through minimap list"] = "Best\195\164tige, wenn du eine Schlachtfeld Warteschlange \195\188ber die Minimap Liste verlassen willst",
	["Confirm when leaving a finished battlefield through score"] = "Best\195\164tige, wenn du ein beendetes Schlachtfeld \195\188ber die Anzeigetafel verlassen willst",
		
	["Battlefield leave delay"] = "Verz\195\182gerung zum verlassen des Schlachtfeldes",
	["Enable auto leave"] = "Auto-Verlassen",
	["Screenshot score board when game ends"] = "Screenshot der Punkteanzeige bei Spielende",
	
	-- OVERLAY / Übersichtstafel
	["Frame"] = "Rahmen",
	["Color"] = "Farbe",
	["Lock overlay"] = "Fixiere Info-Fenster",
	["Background opacity: %d%%"] = "Hintergrund-Transparenz: %d%%",
	["Scale: %d%%"] = "Gr\195\182\195\159e: %d%%",
	["Background color"] = "Hintergrundfarbe",
	["Border color"] = "Rahmenfarbe",
	["Category text color"] = "Kategorie-Textfarbe",
	["Text color"] = "Textfarbe",
	["Grow up"] = "Gro\195\159 machen",
	["The overlay will grow up instead of down when new rows are added, a reloadui maybe required for this to take affect."] = "Die \195\156bersichtstafel w\195\164chst nach unten wenn neue Zeilen hinzugef\195\188gt werden, ein ReloadUI k\195\182nnte daf\195\188r von n\195\182ten sein.",

	["Disable overlay clicking"] = "Sperre das Klicken auf die \195\156bersichtstafel",
	["Removes the ability to click on the overlay, allowing you to interact with the 3D world instead. While the overlay is unlocked, this option is ignored."] = "Entfernt die F\195\164higkeit, auf die \195\156bersichtstafel zu klicken und erlaubt dir mit der 3D Welt zu interagieren. W\195\164hrend die \195\156bersichtstafel entriegelt wird, wird die diese Wahl ignoriert.",
	
	["Use short time format"] = "Benutze kurzes Zeitformat",
	["Shows timers as HH:MM:SS instead of X Minutes, X Seconds"] = "Zeigt die Zeit als HH:MM:SS anstelle von den X Minuten, X Sekunden",
	
	-- AV / AV
	["Alerts"] = "Alarme",
	["Timers"] = "Zeiten",
	["Enable capture timers"] = "Aktiviere Eroberungstimer",
	["Enable interval capture messages"] = "Aktiviere Intervall f\195\188r Eroberungsnachrichten",
	["Seconds between capture messages"] = "Intervall in Sekunden zwischen den Nachrichten",
	["Show resources gained through mines"] = "Zeigt die Ressourcen, die durch die Minen gewonnen wurden",
	["Show resources lost from captains and towers in MSBT/SCT/FCT"] = "Zeigt die verloren Ressourcen von Kommandanten und T\195\188rmen in MSBT/SCT/FCT an",
	["None"] = "Nichts",
	["25%"] = "25%",
	["50%"] = "50%",
	["75%"] = "75%",
	
	["Sync Queue"] = "Synchronisierungs Warteschlange",
	["Enable sync queuing"] = "Aktiviere Synchronisierung der Warteschlange",
	["Allows you to sync queue with other SSPVP2, StinkyQueue or LightQueue users at the same time increasing your chance of getting into the same match."] = "Erlaubt die Synchronisierung der Warteschlange mit anderen SSPVP2, StinkyQueue oder LightQueue Spielern um die Wahrscheinlichkeit zu erh\195\182hen in das selbe Spiel zu kommen.",
	["Allow group leader or assist to force join you into a specific Alterac Valley"] = "Erlaubt den Anf\195\188hrer oder dem Assistent zum schnellen Beitreten eines speziellen Alteracs",
		
	["Show player queue status in overlay"] = "Zeigt Spieler Warteschlangen Status in der \195\156bersichtstafel",
	["Displays how many people are queued, number of people who have confirmation for specific instance id's and the instance id's that people are currently playing inside."] = "Zeigt an, wie viele Leute in der Warteschlange sind, Zahl der Leute, die Best\195\164tigung f\195\188r eine spezielle Instanz ID haben und die Instanz ID, auf welcher die Leute derzeit Spielen.",
	["When the leader is ready for the group to join an Alterac Valley, he can force everyone into it with the required instance id. You will still be shown the instance id to join even if you disable this."] = "Wenn der Anf\195\188hrer der Gruppe bereit ist dem Alterac beizutreten, kann er jeder schnell in die gleiche Instanz ID bringen. Du bekommst die Instanz ID nochmals angezeigt, auch wenn du das Fenster ausgeschaltet hast.",
	
	-- EOTS/AB/WSG / EOTS/AB/WSG
	["Flag Carrier"] = "Flaggentr\195\164ger",
	["Match Info"] = "Spiel Info",
	
	["Show flag carrier"] = "Zeige Flaggentr\195\164ger",
	["Show carrier health when available"] = "Zeige die Gesundheit von dem Flaggentr\195\164ger, wenn verf\195\188gbar",
	["Color carrier name by class color"] = "F\195\164rbe den Name des Flaggentr\195\164gers in die Klassenfarben",
	["Time until flag respawns"] = "Zeit bis die Flaggen zur\195\188ckgesetzt werden",
	
	["Show basic match information"] = "Zeigt allgemeine Spiel Informationen",
	["Show bases to win"] = "Zeigt ben\195\182tigte Basen zum gewinnen",
	["Show flag held time and time taken to capture"] = "Zeige die Haltezeit der Flagge und die Zeit die zum holen gebraucht wurde",
	
	["Show points gained from flag captures in MSBT/SCT/FCT"] = "Zeigt die Punkte die von den eroberten Flaggen an in MSBT/SCT/FCT",
	
	["Macro Text"] = "Makro Text",
	["Text to execute when clicking on the flag carrier button"] = "Beim Klicken auszugebender Text, wenn man auf den Flaggentr\195\164ger klickt",
	
	-- Disable modules / Deaktiviere Module
	["Modules"] = "Module",
	["Disable %s"] = "Deaktiviere %s",
	["match information"] = "Spielinformationen",
	["Time left in match, final scores and bases to win for Eye of the Storm and Arathi Basin."] = "Vergangene Zeit im Spiel, Finales Spielergebnis und Basen zum gewinnen vom Auge des Sturms und Arathibecken.",
	
	["flag carrier"] = "Flaggentr\195\164ger",
	["Who's holding the flag currently for Eye of the Storm and Warsong Gulch."] = "Wer hat die Flagge derzeit vom Auge des Sturms und der Kriegshymnenschlucht.",

	["Timers for Arathi Basin when capturing nodes."] = "Zeiten f\195\188r das Arathibecken, als die Flaggen erorert wurden.",

	["Timers for Alterac Valley when capturing nodes, as well interval alerts on time left before capture."] = "Zeiten f\195\188r das Alterac, als T\195\188rme oder Friedh\195\182fe erobert wurden, au\195\159erdem kommen in intervallen Alarme welche die Zeiten bis zur Eroberung anzeigen.",
	["Cleaning up the text in the PvP objectives along with points gained from captures in Eye of the Storm."] = "S\195\164ubern des Textes der PvP Ziele, die von den erworbenen Punkten durch das Erobern im Auge des Sturms erhalten wurden.",
	
	["battleground"] = "Schlachtfeld",
	["General battleground specific changes like auto release."] = "Spezifische \195\132nderungen des allgemeinen Schlachtfeldes wie automatische Geist-Freigabe.",
	
	["score"] = "Punkteanzeige",
	["General scoreboard changes like coloring by class or hiding the class icons."] = "Allgemeine \195\156bersichtstafel \195\132nderungen wie die F\195\164rbung der Klassen oder das Verstecken der Klassen Icons.",
	
	["Disable auto release"] = "Deaktiviere automatische Geist-Freigabe",
	["Disables auto release for this specific battleground."] = "Deaktivierung automatischer Geist-Freigabe f\195\188r dieses spezielle Schlachtfeld.",
	
	-- Priorities / Prioritäten
	["afk"] = "Nicht an der Tastatur",
	["ratedArena"] = "Gewertete Arena",
	["skirmArena"] = "Ungewertete Arena",
	["eots"] = "Auge des Sturms",
	["av"] = "Alteractal",
	["ab"] = "Arathibecken",
	["wsg"] = "Kriegshymnenschlucht",
	["group"] = "In Gruppe oder Raid",
	["instance"] = "Instanz",
	["none"] = "Alles andere",
}, {__index = SSPVPLocals})

BINDING_HEADER_SSPVP = "SSPVP";
BINDING_NAME_ETARFLAG = "Ziel feindlicher Flaggentr\195\164ger";
BINDING_NAME_FTARFLAG = "Ziel verb\195\188ndeter Flaggentr\195\164ger";