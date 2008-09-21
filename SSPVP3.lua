--[[ 
	SSPVP by Mayen/Amarand Horde, Icecrown-US (PvE)
	
	1.x   Release: January 26th 2006
	2.x   Release: December 27th 2006
	3.x   Release: April 9th 2007
	2     Release: November 18th 2007
	3     Release: September 09th 2008
]]

SSPVP = LibStub("AceAddon-3.0"):NewAddon("SSPVP", "AceEvent-3.0", "AceTimer-3.0")

local L = SSPVPLocals

local teamTotals = {[2] = 0, [3] = 0, [5] = 0}
local statusInfo, queuedUpdates, confirmPortLeave, join, queueID = {}, {}, {}, {}, {}
local activeBF, activeID, screenTaken, zoneText

if( IS_WRATH_BUILD == nil ) then IS_WRATH_BUILD = (select(4, GetBuildInfo()) >= 30000) end

function SSPVP:OnInitialize()
	self.defaults = {
		profile = {
			general = {
				channel = "BATTLEGROUND",
			},
			priorities = {
				afk = 1,
				ratedArena = 2,
				skirmArena = 3,
				eots = 3,
				av = 3,
				ab = 3,
				wsg = 3,
				group = 4,
				instance = 5,
				none = 6,
			},
			join = {
				enabled = true,
				arena = 10,
				window = false,
				priority = "lseql",
				battleground = 10,
				afkBattleground = 10,
			},
			auto = {
				solo = true,
				group = false,
			},
			leave = {
				enabled = true,
				screen = false,
				portConfirm = true,
				delay = 10,
			},
			queue = {
				enabled = true,
				inBattle = false,
			},
		}
	}
	
	self.db = LibStub:GetLibrary("AceDB-3.0"):New("SSPVPDB", self.defaults)
		
	self.revision = tonumber(string.match("$Revision: 816 $", "(%d+)")) or 0
	self.revision = max(self.revision, SSPVPRevision)
		
	for i=1, MAX_BATTLEFIELD_QUEUES do
		queueID[i] = "queue" .. i
	end
	
	-- Try and make sure arena info is up to date
	for i=1, MAX_ARENA_TEAMS do
		ArenaTeamRoster(i)
	end
end

function SSPVP:OnEnable()
	self:RegisterEvent("BATTLEFIELDS_SHOW")
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

function SSPVP:OnDisable()
	self:UnregisterAllEvents()
end

function SSPVP:Reload()
	self:UPDATE_BATTLEFIELD_STATUS()
end

function SSPVP:DisableSuspense()
	if( self.suspend ) then
		self.suspend = nil
		self:Print(L["Suspension has been removed, you will now auto join and leave again."])
	end
end

function SSPVP:BATTLEFIELDS_SHOW()
	-- Disable auto join and such if shift is down
	if( IsShiftKeyDown() ) then
		return
	end

	local queued = 0
	for i=1, MAX_BATTLEFIELD_QUEUES do
		local status, map, _, _, _, isRegistered = GetBattlefieldStatus(i)
		
		if( status == "queued" or status == "confirm" ) then
			queued = queued + 1
		elseif( ( status ~= "none" and (GetBattlefieldInfo()) == map ) or isRegistered == 1 ) then
			return
		end
	end
		
	-- Max queues, don't bother trying
	if( queued == MAX_BATTLEFIELD_QUEUES ) then
		return
	end
	
	-- Auto select an option in arena queue depending on teammates
	if( IsBattlefieldArena() and IsPartyLeader() ) then
		for _, total in pairs(teamTotals) do
			total = 0
		end

		-- Figure out which team we're playing with
		for teamID=1, MAX_ARENA_TEAMS do
			local teamSize = select(2, GetArenaTeam(teamID))
			if( teamSize > 0 ) then
				teamTotals[teamSize] = 1

				-- Now check if we're in the same party as them
				for memberID=1, GetNumArenaTeamMembers(teamID, 1) do
					local playerName = GetArenaTeamRosterInfo(teamID, memberID)

					for partyID=1, GetNumPartyMembers() do
						if( UnitName("party" .. partyID) == playerName ) then
							teamTotals[teamSize] = teamTotals[teamSize] + 1
						end
					end
				end
			end
		end
		
		-- Auto select!
		if( teamTotals[5] == 5 ) then
			ArenaFrame.selection = 3
		elseif( teamTotals[3] == 3 ) then
			ArenaFrame.selection = 2
		elseif( teamTotals[2] == 2 ) then
			ArenaFrame.selection = 1
		end

		ArenaFrame_Update()
	end

	-- Auto queue
	if( self.db.profile.auto.solo and ( GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 or IsAltKeyDown() ) ) then
		JoinBattlefield(GetSelectedBattlefield())
	elseif( self.db.profile.auto.group and CanJoinBattlefieldAsGroup() and IsPartyLeader() ) then
		JoinBattlefield(GetSelectedBattlefield(), true)
	end
end

-- For now this will be hard coded as Wintergrasp, can always make it anything later on if needed.
function SSPVP:ZONE_CHANGED_NEW_AREA()
	local zone = GetRealZoneText()
	if( zone ~= zoneText ) then
		if( zone == L["Wintergrasp"] ) then
			SSPVP.modules.WG:EnableModule("wg")
		elseif( zoneText == L["Wintergrasp"] ) then
			SSPVP.modules.WG:DisableModule()
		end
	end
	zoneText = zone
end

function SSPVP:UPDATE_BATTLEFIELD_STATUS()
	for i=1, MAX_BATTLEFIELD_QUEUES do
		local status, map, instanceID, _, _, teamSize, isRegistered = GetBattlefieldStatus(i)
		if( statusInfo[i] ~= status ) then
			-- Confirm to join
			if( status == "confirm" ) then
				local delay = 0
				local abbrev = self:GetAbbrev(map)
				
				-- Ready sound
				self:PlaySound()
				
				-- Figure out auto join delay
				if( abbrev == "arena" ) then
					delay = self.db.profile.join.arena
				elseif( UnitIsAFK("player") ) then
					delay = self.db.profile.join.afkBattleground
				else
					delay = self.db.profile.join.battleground
				end

				-- Figure out join priority
				local priority
				if( abbrev == "arena" and isRegistered ) then
					priority = self.db.profile.priorities.ratedArena
				elseif( abbrev == "arena" and not isRegistered ) then
					priority = self.db.profile.priorities.skirmArena
				else
					priority = self.db.profile.priorities[abbrev]
				end
								
				-- No queue timer going
				if( not join.id ) then
					join.id = i
					join.at = GetTime() + delay
					join.priority = priority
					
					self:ScheduleTimer("JoinBattlefield", delay)
					
				-- Check if priority is higher
				elseif( join.id ~= i and self.db.profile.join.enabled ) then
					if( ( self.db.profile.join.priority == "less" and join.priority < priority ) or ( self.db.profile.join.priority == "lseql" and join.priority <= priority ) ) then
						join.id = i
						join.at = GetTime() + delay
						join.priority = priority
						
						self:CancelTimer("JoinBattlefield", true)
						self:ScheduleTimer("JoinBattlefield", delay)
						
						self:Print(string.format(L["Higher priority battlefield ready, auto joining %s in %d seconds."], map, delay))
					end
				end
				
			-- Active match but we haven't set it up yet
			elseif( status == "active" and activeID ~= i ) then
				local abbrev = self:GetAbbrev(map)
				for name, module in pairs(self.modules) do
					-- Make sure the module is enabled, and that it can actually be enabled
					if( module.EnableModule ) then
						-- Some modules have to be disabled even if they're about to be re-enabled
						-- when switching battlefields, this is mostly to be safe
						if( module.isActive ) then
							module.isActive = nil
							module.DisableModule(module)
						end
						
						if( ( abbrev == module.activeIn ) or ( abbrev ~= "arena" and module.activeIn == "bg" ) or ( module.activeIn == "bf" ) ) then
							module.isActive = true
							module.EnableModule(module, abbrev)
						end
					end
				end

				-- No sense in requesting scores if you're in arena
				if( abbrev ~= "arena" ) then
					self:ScheduleRepeatingTimer(RequestBattlefieldScoreData, 15)
					RequestBattlefieldScoreData()
				end
				
				activeBF = map
				activeID = i
			
			-- This used to be an active match but isn't anymore
			elseif( status ~= "active" and activeID == i ) then
				activeID = nil
				activeBF = nil
				screenTaken = nil
	
				self:CancelTimer("RequestBattlefieldScoreData", true)

				for name, module in pairs(self.modules) do
					if( module.isActive ) then
						module.isActive = nil
						module.DisableModule(module)
					end
				end
				
			-- Been queued for less then 2 seconds so show stat data
			elseif( status == "queued" and GetBattlefieldTimeWaited(i) <= 2000 ) then
				-- Blizzards queued doesn't cover all battlefields, just arenas
				if( teamSize > 0 ) then
					if( isRegistered ) then
						self:Print(string.format(L["You are now in the queue for %s Arena (%dvs%d)."], L["Rated"], teamSize, teamSize))
					else
						self:Print(string.format(L["You are now in the queue for %s Arena (%dvs%d)."], L["Skirmish"], teamSize, teamSize))
					end
				else
					self:Print(string.format(L["You are now in the queue for %s."], map))
				end

				-- Hide the queue window
				if( (GetBattlefieldInfo()) == map and BattlefieldFrame:IsShown() ) then
					HideUIPanel(BattlefieldFrame)
				end
			end
		end

		-- We no longer have this battlefield as confirmation likely time ran out, we left queue or we joined it manually
		if( status ~= "confirm" and join.id == i ) then
			self:ResetJoin()
		end
		
		statusInfo[i] = status
	end
	
	-- Auto leave
	if( self.db.profile.leave.enabled and GetBattlefieldWinner() ) then
		if( self.db.profile.leave.screen ) then
			if( not screenTaken ) then
				-- It's possible to have for the battlefield ends and we take a screenshot before the score frame is shown
				if( not WorldStateScoreFrame:IsVisible() ) then
					ShowUIPanel(WorldStateScoreFrame)
				end
				
				self:RegisterEvent("SCREENSHOT_SUCCEEDED", "ScreenshotTaken")
				self:RegisterEvent("SCREENSHOT_FAILED", "ScreenshotTaken")

				screenTaken = true
				Screenshot()
			end
		elseif( self.db.profile.leave.delay <= 0 ) then
			self:LeaveBattlefield()
		else
			self:ScheduleTimer("LeaveBattlefield", self.db.profile.leave.delay)
		end
	end
	
	-- Queue overlay, we have to do it after the first check due to auto join
	if( self.db.profile.queue.enabled ) then
		if( activeID and not self.db.profile.queue.inBattle ) then
			SSOverlay:RemoveCategory("queue")
			return
		end
		
		for i=1, MAX_BATTLEFIELD_QUEUES do
			local status, map, instanceID, _, _, teamSize, isRegistered = GetBattlefieldStatus(i)
			if( not map or map == "" ) then
				map = L["Unknown"]
			end

			if( teamSize > 0 ) then
				-- Before arenas start you're queued for all arena maps once queues ready, they tell us specifically what map we're going into
				-- This is no longer the case as of 2.4.0, it'll always return Eastern Kingdoms
				if( map == L["All Arenas"] or map == L["Eastern Kingdoms"] ) then
					if( isRegistered ) then
						map = L["Rated Arena"]
					else
						map = L["Skirmish Arena"]
					end
				end
				
				map = string.format(L["%s (%dvs%d)"], map, teamSize, teamSize)
			end
			
			if( status == "active" and instanceID > 0 ) then
				SSOverlay:RegisterText(queueID[i], "queue", string.format("%s: #%d", map, instanceID))
			elseif( status == "confirm" ) then
				if( not self.db.profile.join.enabled ) then
					SSOverlay:RegisterTimer(queueID[i], "queue", string.format("%s: %s (%s)", map, "%s", L["Disabled"]), GetBattlefieldPortExpiration(i) / 1000)
				elseif( self.suspend and join.id == i ) then
					SSOverlay:RegisterTimer(queueID[i], "queue", string.format("%s: %s (%s)", map, "%s", L["Suspended"]), GetBattlefieldPortExpiration(i) / 1000)
				elseif( not self.suspend and join.id == i ) then
					SSOverlay:RegisterTimer(queueID[i], "queue", string.format("%s: %s %s", map, L["Joining"], "%s"), join.at - GetTime())
				else
					SSOverlay:RegisterTimer(queueID[i], "queue", string.format("%s: %s", map, "%s"), GetBattlefieldPortExpiration(i) / 1000)
				end
			
			elseif( status == "queued" ) then
				local etaTime = GetBattlefieldEstimatedWaitTime(i) / 1000
				if( etaTime > 0 ) then
					etaTime = SSOverlay:FormatTime(etaTime, true)
					if( etaTime == "" ) then
						etaTime = L["<1 Min"]
					end
				else
					etaTime = L["Unavailable"]
				end
								
				SSOverlay:RegisterElapsed(queueID[i], "queue", string.format("%s: %s (%s)", map, "%s", etaTime), GetBattlefieldTimeWaited(i) / 1000)
			else
				SSOverlay:RemoveRow(queueID[i])
			end
		end
	end
end

-- Actually leave the battlefield (if we can)
function SSPVP:LeaveBattlefield()
	-- We've had issues in the past if we don't specifically check this again can lead to deserter when switching battlefields
	if( not GetBattlefieldWinner() ) then
		return
	end
	
	-- Check for suspension
	if( self.suspend ) then
		self:Print(L["Suspension is still active, will not auto join or leave."])
		return
	end
	
	-- If we have another battlefield ready don't auto leave
	for i=1, MAX_BATTLEFIELD_QUEUES do
		local status, map, _, _, _, teamSize = GetBattlefieldStatus(i)
		if( status == "confirm" ) then
			if( teamSize > 0 ) then
				map = string.format(L["%s (%dvs%d)"], map, teamSize, teamSize)
			end
		
			self:Print(string.format(L["%s is ready to join, auto leave disabled."], map))
			return
		end
	end
	
	-- Theres a delay before the call to arms quest completes, sometimes it's within 0.5 seconds, sometimes it's within 1-3 seconds. If you have auto leave set to 0
	-- then you'll likely leave before you get credit, so delay the actual leave (if need be) until the quest is credited to us
	if( select(2, IsInInstance()) == "pvp" and activeBF ) then
		local playerFaction = 1
		if( UnitFactionGroup("player") == "Horde" ) then
			playerFaction = 0
		end
	
		if( GetBattlefieldWinner() == playerFaction ) then
			local callToArms = string.format(L["Call to Arms: %s"], activeBF)
			for i=1, GetNumQuestLogEntries() do
				local questName, _, _, _, _, _, isComplete = GetQuestLogTitle(i)

				-- Quest isn't complete yet, AND we have it. Meaning, schedule for a log update and auto leave once it's complete
				if( string.match(questName, callToArms) and not isComplete ) then
					self:Print(string.format(L["You currently have the battleground daily quest for %s, auto leave has been set to occure once the quest completes."], activeBF))
					self:RegisterEvent("QUEST_LOG_UPDATE")
					return
				end
			end
		end
	end

	LeaveBattlefield()
end

-- Check if it's time to auto leave yet
function SSPVP:QUEST_LOG_UPDATE()
	local callToArms = string.format(L["Call to Arms: %s"], activeBF)
	for i=1, GetNumQuestLogEntries() do
		local questName, _, _, _, _, _, isComplete = GetQuestLogTitle(i)
		if( string.match(questName, callToArms) and isComplete ) then
			self:UnregisterEvent("QUEST_LOG_UPDATE")
			self:LeaveBattlefield()
			return
		end
	end
end

-- Screenshot taken
function SSPVP:ScreenshotTaken()
	local format = GetCVar("screenshotFormat")
	-- jpeg format is used, jpg is the actual ext it's saved as
	if( format == "jpeg" ) then
		format = "jpg"
	end

	self:UnregisterEvent("SCREENSHOT_SUCCEDED")
	self:UnregisterEvent("SCREENSHOT_FAILED")
	self:Print(string.format(L["Screenshot saved as WoWScrnShot_%s.%s."], date("%m%d%y_%H%M%S"), format))

	if( self.db.profile.leave.delay <= 0 ) then
		self:LeaveBattlefield()
	else
		self:ScheduleTimer("LeaveBattlefield", self.db.profile.leave.delay)
	end
end

function SSPVP:ResetJoin()
	join.id = nil
	join.at = nil
	join.priority = nil
end

-- Now check priorities before we join the battlefield
function SSPVP:JoinBattlefield()
	if( not join.id or not join.priority or not self.db.profile.join.enabled ) then
		return
	end
	
	-- Not auto joining still for 5 minutes
	if( self.suspend ) then
		self:ResetJoin()
		self:Print(L["Suspension is still active, will not auto join or leave."])
		return
	end
	
	-- Disable auto join if the windows hidden
	if( self.db.profile.join.window and ( ( not StaticPopupDialogs["CONFIRM_NEW_BFENTRY"] and not StaticPopup_FindVisible("CONFIRM_BATTLEFIELD_ENTRY", join.id) ) or ( StaticPopupDialogs["CONFIRM_NEW_BFENTRY"] and not StaticPopup_FindVisible("CONFIRM_NEW_BFENTRY", join.id) ) ) ) then
		self:Print(string.format(L["You have the battlefield entry window hidden for %s, will not auto join."], (GetBattlefieldStatus(join.id))))
		self:ResetJoin()
		return
	end
	
	local priority = self.db.profile.priorities.none
	local instance, type = IsInInstance()
	
	-- Figure out our current priority
	if( UnitIsAFK("player" ) ) then
		priority = self.db.profile.priorities.afk
	elseif( activeBF and type == "arena" ) then
		if( select(2, IsActiveBattlefieldArena()) ) then
			priority = self.db.profile.priorities.ratedArena
		else
			priority = self.db.profile.priorities.skirmArena
		end
	elseif( activeBF and type == "pvp" ) then
		priority = self.db.profile.priorities[self:GetAbbrev(activeBF)] or self.db.profile.priorities.none
	elseif( instance ) then
		priority = self.db.profile.priorities.instance
	elseif( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 ) then
		priority = self.db.profile.priorities.group
	end
	
	-- Make sure we can auto join
	if( ( self.db.profile.join.priority == "less" and priority < join.priority ) or ( self.db.profile.join.priority == "lseql" and priority <= join.priority ) ) then
		self:Print(string.format(L["Your current activity is a higher priority than %s, not auto joining."], select(2, GetBattlefieldStatus(join.id))))
	else
		AcceptBattlefieldPort(join.id, true)
	end

	self:ResetJoin()
end

-- For playing sound
function SSPVP:PlaySound()
	if( not self.db.profile.general.sound ) then
		return
	end
	
	self:StopSound()
	
	-- MP3 files have to be played as music, everthing else as sound
	if( string.match(self.db.profile.general.sound, "mp3$") ) then
		PlayMusic("Interface\\AddOns\\SSPVP\\" .. self.db.profile.general.sound)
	else
		PlaySoundFile("Interface\\AddOns\\SSPVP\\" .. self.db.profile.general.sound)
	end
end

function SSPVP:StopSound()
	-- Things played as music can be stopped using StopMusic() sound file ones can only be stopped by toggling it
	if( string.match(self.db.profile.general.sound, "mp3$") ) then
		StopMusic()
	else
		local old = GetCVar("Sound_EnableAllSound")
		SetCVar("Sound_EnableAllSound", 0)
		SetCVar("Sound_EnableAllSound", old)
	end
end

-- Lets us do quick and easy checks for battleground
function SSPVP:GetAbbrev(map)
	if( map == L["Warsong Gulch"] ) then
		return "wsg"
	elseif( map == L["Arathi Basin"] ) then
		return "ab"
	elseif( map == L["Alterac Valley"] ) then
		return "av"
	elseif( map == L["Eye of the Storm"] ) then
		return "eots"
	elseif( map == L["Eastern Kingdoms"] or map == L["Blade's Edge Arena"] or map == L["Nagrand Arena"] or map == L["Ruins of Lordaeron"] ) then
		return "arena"
	elseif( map == L["Wintergrasp"] ) then
		return "wg"
	elseif( map == L["Strand of the Ancients"] ) then
		return "sota"
	end
	
	return ""
end

-- Stylish!
function SSPVP:ParseNode(node)
	node = string.gsub(node, "^" .. L["The"], "")
	node = string.trim(node)
	
	-- Mostly for looks
	if( GetLocale() == "enUS" ) then
		node = string.upper(string.sub(node, 0, 1)) .. string.sub(node, 2)
	end

	return node
end

function SSPVP:GetFactionColor(faction)
	faction = string.lower(faction or "")
	if( faction == "alliance" or faction == "chat_msg_bg_system_alliance" ) then
		return ChatTypeInfo["BG_SYSTEM_ALLIANCE"]
	elseif( faction == "horde" or faction == "chat_msg_bg_system_horde" ) then
		return ChatTypeInfo["BG_SYSTEM_HORDE"]
	end
	
	return ChatTypeInfo["BG_SYSTEM_NEUTRAL"]
end

function SSPVP:Echo(msg, color)
	if( color ) then
		DEFAULT_CHAT_FRAME:AddMessage(msg, color.r, color.g, color.b)	
	else
		DEFAULT_CHAT_FRAME:AddMessage(msg)
	end
end

function SSPVP:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF99SSPVP|r: " .. msg)
end

-- Sends it to the correct chat frames
function SSPVP:ChatMessage(msg, faction)
	local event, color
	if( faction == "Alliance" ) then
		event = "CHAT_MSG_BG_SYSTEM_ALLIANCE"
		color = ChatTypeInfo["BG_SYSTEM_ALLIANCE"]
	elseif( faction == "Horde" ) then
		event = "CHAT_MSG_BG_SYSTEM_HORDE"
		color = ChatTypeInfo["BG_SYSTEM_HORDE"]
	else
		return
	end
	
	local foundFrame
	for i=1, 7 do
		local frame = getglobal("ChatFrame" .. i)
		if( frame and frame:IsEventRegistered(event) ) then
			frame:AddMessage(msg, color.r, color.g, color.b)
			foundFrame = true
		end
	end
	
	-- No frames registering it, default to the main one
	if( not foundFrame ) then
		DEFAULT_CHAT_FRAME:AddMessage(msg, color.r, color.g, color.b)
	end
end

function SSPVP:ChannelMessage(msg)
	if( GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0 ) then
		return
	end

	-- Limit it to 10 "to be safe"
	for i=1, 10 do
		local num = string.match(msg, "(%d+) |4")
		if( not num ) then break end
		if( tonumber(num) <= 1 ) then
			msg = string.gsub(msg, "|4(.-):.-;", "%1")
		else
			msg = string.gsub(msg, "|4.-:(.-);", "%1")
		end
	end
	
	SendChatMessage(msg, self.db.profile.general.channel)
end

-- Quick access to whatever combat text mod is being used
function SSPVP:CombatText(text, color)	
	-- SCT
	if( IsAddOnLoaded("sct") ) then
		SCT:DisplayText(text, color, nil, "event", 1)
	
	-- MSBT
	elseif( IsAddOnLoaded("MikScrollingBattleText") ) then
		MikSBT.DisplayMessage(text, MikSBT.DISPLAYTYPE_NOTIFICATION, false, color.r * 255, color.g * 255, color.b * 255)		
	
	-- Blizzard Combat Text
	elseif( IsAddOnLoaded("Blizzard_CombatText") ) then
		-- Haven't cached the movement function yet
		if( not COMBAT_TEXT_SCROLL_FUNCTION ) then
			CombatText_UpdateDisplayedMessages()
		end
		
		CombatText_AddMessage(text, COMBAT_TEXT_SCROLL_FUNCTION, color.r, color.g, color.b)
	end
end

-- Queuing things to run when we leave combat
function SSPVP:PLAYER_REGEN_ENABLED()
	for func, handler in pairs(queuedUpdates) do
		if( type(handler) == "table" ) then
			handler[func](handler)
		elseif( type(func) == "string" ) then
			getglobal(func)()
		else
			func()	
		end
	end
	
	for func in pairs(queuedUpdates) do
		queuedUpdates[func] = nil
	end
end

function SSPVP:UnregisterOOCUpdate(func)
	queuedUpdates[func] = nil
end

function SSPVP:RegisterOOCUpdate(self, func)
	if( type(func) == "string" ) then
		queuedUpdates[func] = self
	else
		queuedUpdates[self] = true
	end
end

-- Battlefield list
local list
function SSPVP:GetBattlefieldList()
	if( not list ) then
		list = {["arena"] = L["Arena"], ["eots"] = L["Eye of the Storm"], ["wsg"] = L["Warsong Gulch"], ["ab"] = L["Arathi Basin"], ["av"] = L["Alterac Valley"]}
	end
	
	-- Add WoTLK battlegrounds here eventually
	if( IS_WRATH_BUILD ) then
		list["sota"] = L["Strand of the Ancients"]
		list["wg"] = L["Wintergrasp"]
	end
	
	return list
end

-- Hook for confirmations on leaving
-- Leaving queues, or hitting leave battlefield through minimap
local Orig_AcceptBattlefieldPort = AcceptBattlefieldPort
function AcceptBattlefieldPort(id, accept, ...)
	if( (not accept or accept == 0) and SSPVP.db.profile.leave.portConfirm and not confirmPortLeave[id] ) then
		local _, map, _, _, _, teamSize = GetBattlefieldStatus(id)
		if( teamSize > 0 ) then
			StaticPopupDialogs["CONFIRM_PORT_LEAVE"].text = string.format(L["You are about to leave the active or queued arena %s (%dvs%d), are you sure?"], map, teamSize, teamSize)
		else
			StaticPopupDialogs["CONFIRM_PORT_LEAVE"].text = string.format(L["You are about to leave the active or queued battleground %s, are you sure?"], map)
		end
		
		local dialog = StaticPopup_Show("CONFIRM_PORT_LEAVE")
		if( dialog ) then
			dialog.data = id
		end
		return
	end
	
	confirmPortLeave[id] = nil
	StaticPopup_Hide("CONFIRM_PORT_LEAVE", id)
	
	Orig_AcceptBattlefieldPort(id, accept, ...)
end

-- Confirmation popups
StaticPopupDialogs["CONFIRM_PORT_LEAVE"] = {
	text = "",
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function(id)
		confirmPortLeave[id] = true
		AcceptBattlefieldPort(id, nil)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	multiple = 1,
}