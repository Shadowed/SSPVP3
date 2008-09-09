local Flag = SSPVP:NewModule("Flag", "AceEvent-3.0", "AceTimer-3.0")
Flag.activeIn = "bg"

local L = SSPVPLocals
local carriers = {["Alliance"] = {}, ["Horde"] = {}}
local allianceUpdate = -1
local hordeUpdate = -1
local partyUpdate = 0
local HEALTH_TIMEOUT = 10
local healthMonitor = CreateFrame("Frame")

function Flag:OnInitialize()
	self.defaults = {
		profile = {
			wsg = {
				enabled = true,
				color = true,
				health = true,
				respawn = true,
				capture = true,
				macro = "/targetexact *name",
			},
			eots = {
				enabled = true,
				color = true,
				health = true,
				respawn = true,
				capture = true,
				macro = "/targetexact *name",
			},
		},
	}
	
	self.db = SSPVP.db:RegisterNamespace("flag", self.defaults)	
	playerName = UnitName("player")
	healthMonitor:Hide()
end

function Flag:EnableModule(abbrev)
	-- Flags are only used inside EoTS and WSG currently
	if( ( abbrev ~= "eots" and abbrev ~= "wsg" ) or not self.db.profile[abbrev].enabled ) then
		self.isActive = nil
		return
	end
	
	self.activeBF = abbrev
		
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "ParseMessage")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "ParseMessage")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", "ParseMessage")
	self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
	self:RegisterEvent("UPDATE_BINDINGS")
	
	if( self.db.profile[abbrev].health ) then
		self:RegisterEvent("UNIT_HEALTH")
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	end
	
	-- Do we have to wait for UPDATE_WORLD_STATES to position?
	self:CreateButtons()
	if( not self.Alliance or not self.Horde ) then
		self:ScheduleRepeatingTimer("CheckButtons", 0.25)
	else
		self:UpdateAllAttributes()
	end
	
	-- Start checking for health updates
	healthMonitor:Show()
end

function Flag:DisableModule()
	-- Stop checking
	healthMonitor:Hide()

	-- Reset saved info
	for k in pairs(carriers["Alliance"]) do
		carriers["Alliance"][k] = nil
	end
	
	for k, v in pairs(carriers["Horde"]) do
		carriers["Horde"][k] = nil
	end

	self:UnregisterAllEvents()
	
	SSOverlay:RemoveCategory("timer")
	SSPVP:UnregisterOOCUpdate("UpdateAllAttributes")
	SSPVP:UnregisterOOCUpdate("UpdateStatus")

	if( not InCombatLockdown() ) then
		self:Hide("Horde")
		self:Hide("Alliance")
	else
		SSPVP:RegisterOOCUpdate(self, "UpdateStatus")
	end
end

function Flag:Reload()
	if( self.activeBF and self.db.profile[self.activeBF].health and self.isActive ) then
		self:RegisterEvent("UNIT_HEALTH")
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	else
		self:UnregisterEvent("UNIT_HEALTH")
		self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
	end
	
	if( self.isActive ) then
		self:UpdateCarrier("Alliance")
		self:UpdateCarrier("Horde")
	end
end

-- Update carriers incase we have class
function Flag:UPDATE_BATTLEFIELD_SCORE()
	if( carriers["Alliance"].name ) then
		self:UpdateCarrier("Alliance", true)
	end
	
	if( carriers["Horde"].name ) then
		self:UpdateCarrier("Horde", true)
	end
end

-- Check if it's time to do a position
function Flag:CheckButtons()
	self:CreateButtons()
	if( self.Alliance and self.Horde ) then
		self:UpdateAllAttributes()
		self:CancelTimer("CheckButtons", true)
	end
end

-- Scan unit updates
function Flag:UNIT_HEALTH(event, unit)
	self:UpdateHealth(unit)
end

function Flag:UPDATE_MOUSEOVER_UNIT()
	self:UpdateHealth("mouseover")
end

function Flag:PLAYER_TARGET_CHANGED()
	self:UpdateHealth("target")
end

-- Scan raid targets
function Flag:ScanParty()
	for i=1, GetNumRaidMembers() do
		local unit = "raid" .. i
		self:UpdateHealth(unit)
		self:UpdateHealth(unit .. "target")
	end
end

-- Update health
function Flag:UpdateHealth(unit)
	if( not UnitExists(unit) or not UnitFactionGroup(unit) ) then
		return
	end

	local name = UnitName(unit)
	local faction = UnitFactionGroup(unit)
	if( carriers[faction].name == name ) then
		carriers[faction].health = floor((UnitHealth(unit) / UnitHealthMax(unit) * 100) + 0.5)
		
		self:UpdateCarrier(faction)
		
		if( faction == "Alliance" ) then
			allianceUpdate = HEALTH_TIMEOUT
		else
			hordeUpdate = HEALTH_TIMEOUT
		end
	end
end

-- Check if we can still get health updates from them
function Flag:IsTargeted(name)
	-- Check if it's our target or mouseover
	if( UnitName("target") == name or UnitName("mouseover") == name or UnitName("focus") == name ) then
		return true
	end
	
	-- Scan raid member targets, and raid member targets of target
	for i=1, GetNumRaidMembers() do
		local unit = "raid" .. i
		local target = unit .. "target"
		
		if( UnitExists(unit) and UnitName(unit) == name ) then
			return true
		elseif( UnitExists(target) and UnitName(target) == name ) then
			return true
		end
	end
	
	-- Scan party member targets, and party member targets of target
	for i=1, GetNumPartyMembers() do
		local unit = "party" .. i
		local target = unit .. "target"
		
		if( UnitExists(unit) and UnitName(unit) == name ) then
			return true
		elseif( UnitExists(target) and UnitName(target) == name ) then
			return true
		end
	end
	
	return nil
end

-- More then HEALTH_TIMEOUT seconds without updates means they're too far away
function Flag:ResetHealth(type)
	-- If we still have them targeted, don't reset timeout
	if( self:IsTargeted(carriers[type].name) ) then
		if( type == "Alliance" ) then
			allianceUpdate = HEALTH_TIMEOUT
		else
			hordeUpdate = HEALTH_TIMEOUT
		end
		return
	end

	if( carriers[type] and carriers[type].health) then
		carriers[type].health = nil
		self:UpdateCarrier(type)
	end
end

function Flag:UpdateAllAttributes()
	self:UpdateCarrierAttributes("Alliance")
	self:UpdateCarrierAttributes("Horde")
end

-- We split these into two different functions, so we can do color/text/health updates
-- while in combat, but update targeting when out of it
function Flag:UpdateCarrierAttributes(faction)
	-- Carrier changed but we can't update it yet
	local carrier = carriers[faction].name
	if( self[faction].carrier ~= carrier ) then
		self[faction]:SetAlpha(0.75)
	else
		self[faction]:SetAlpha(1.0)
	end
	
	-- In combat, can't change anything
	if( InCombatLockdown() ) then
		SSPVP:RegisterOOCUpdate(self, "UpdateAllAttributes")
		return
	end

	-- This should be changed later, to automatically position to the icon
	-- button if it's being used for PvP objectives
	local posFrame
	local posY = 0
	if( self.activeBF == "eots" ) then
		posY = 5
		if( faction == "Alliance" ) then
			posFrame = AlwaysUpFrame1Text
		else
			posFrame = AlwaysUpFrame2Text
		end
	elseif( self.activeBF == "wsg" ) then
		posY = 13
		
		-- If we're updating an Alliance carrier, then show it at the Horde button
		-- also, position at the dynamic icon instead of the text
		if( faction == "Alliance" ) then
			posFrame = AlwaysUpFrame1DynamicIconButton
		else
			posFrame = AlwaysUpFrame2DynamicIconButton
		end
	end
	
	-- Cannot position, it's likely this is due to the always up frames not being created yet
	if( not posFrame ) then
		return nil
	end
		
	self[faction].carrier = carrier
	self[faction]:ClearAllPoints()
	self[faction]:SetPoint("LEFT", UIParent, "BOTTOMLEFT", posFrame:GetRight() + 8, posFrame:GetTop() - posY)
	self[faction]:SetAttribute("type", "macro")
	self[faction]:SetAttribute("macrotext", string.gsub(self.db.profile[self.activeBF].macro, "*name", carrier or ""))
end

function Flag:UpdateCarrier(faction, skipAttrib)
	if( not skipAttrib ) then
		self:UpdateCarrierAttributes(faction)
	end
	
	-- No carrier, hide it, this is bad
	local carrier = carriers[faction].name
	if( not carrier ) then
		self:Hide(faction)
		return
	end
		
	local health = ""
	if( carriers[faction].health and self.db.profile[self.activeBF].health and type(carriers[faction].health) == "number" ) then
		health = " |cffffffff[" .. carriers[faction].health .. "%]|r"
	end
	
	self[faction].text:SetText(carrier .. health)

	-- Carrier class color if enabled/not set
	if( self[faction].colorSet ~= carrier and self.db.profile[self.activeBF].color ) then
		for i=1, GetNumBattlefieldScores() do
			local name, _, _, _, _, _, _, _, _, classToken = GetBattlefieldScore(i)
			
			if( string.match(name, "^" .. carrier) ) then
				self[faction].text:SetTextColor(RAID_CLASS_COLORS[classToken].r, RAID_CLASS_COLORS[classToken].g, RAID_CLASS_COLORS[classToken].b)
				self[faction].colorSet = carrier
				break
			end
		end
	end
		
	-- Update the color to the default because we couldn't find one
	if( self[faction].colorSet ~= carrier ) then
		self[faction].text:SetTextColor(GameFontNormal:GetTextColor())
	end
end

-- Parse event for changes
function Flag:ParseMessage(event, msg)
	-- More sane for us to do it here
	local faction
	if( self.activeBF == "wsg" ) then
		-- Reverse the factions because Alliance found = Horde event
		-- Horde found = Alliance event
		if( string.match(msg, L["Alliance"]) ) then
			faction = "Horde"
		elseif( string.match(msg, L["Horde"]) ) then
			faction = "Alliance"
		end
	elseif( event == "CHAT_MSG_BG_SYSTEM_HORDE" ) then
		faction = "Horde"
	elseif( event == "CHAT_MSG_BG_SYSTEM_ALLIANCE" ) then
		faction = "Alliance"
	end
	
	-- WSG, pick up
	if( string.match(msg, L["was picked up by (.+)!"]) ) then
		self:PickUp(faction, string.match(msg, L["was picked up by (.+)!"]))
	
	-- EoTS, pick up
	elseif( string.match(msg, L["(.+) has taken the flag!"]) ) then
		self:PickUp(faction, string.match(msg, L["(.+) has taken the flag!"]))

	-- WSG, returned
	elseif( string.match(msg, L["was returned to its base"]) ) then
		self:Returned(faction)
	
	-- EOTS, returned
	elseif( string.match(msg, L["flag has been reset"]) ) then
		self:Returned("Horde")
		self:Returned("Alliance")
		
	-- WSG/EoTS, captured
	elseif( string.match(msg, L["captured the"]) ) then
		self:Captured(faction)
	
	-- EoTS/WSG, dropped
	elseif( string.match(msg, L["was dropped by (.+)!"]) or string.match(msg, L["The flag has been dropped"]) ) then
		self:Dropped(faction)
	end
end

-- Flag captured = time reset as well
function Flag:Captured(faction)
	if( self.db.profile[self.activeBF].respawn ) then
		if( self.activeBF == "eots" ) then
			SSOverlay:RegisterTimer("respawn", "timer", L["Flag Respawn: %s"], 10, SSPVP:GetFactionColor("Neutral"))
		else
			SSOverlay:RegisterTimer("respawn", "timer", L["Flag Respawn: %s"], 21, SSPVP:GetFactionColor("Neutral"))
		end
	end
	
	-- Remove held time, show time taken to capture
	SSOverlay:RemoveRow(faction .. "time")
	
	if( carriers[faction].time ) then
		SSOverlay:RegisterText(faction .. "capture", "timer", string.format(L["Capture Time: %s"], SecondsToTime(GetTime() - carriers[faction].time)), SSPVP:GetFactionColor(faction))
	end
	
	-- Clear out
	carriers[faction].time = nil
	carriers[faction].name = nil
	carriers[faction].health = nil
	self:Hide(faction)
end

function Flag:Dropped(faction)
	carriers[faction].name = nil
	carriers[faction].health = nil
	SSOverlay:RemoveRow(faction .. "time")
	
	self:Hide(faction)
end

-- Return = time reset
function Flag:Returned(faction)
	carriers[faction].time = nil
	carriers[faction].name = nil
	SSOverlay:RemoveRow(faction .. "time")
end

function Flag:PickUp(faction, name)
	carriers[faction].name = name

	-- If the flags dropped then picked up, we don't want to reset time
	if( not carriers[faction].time ) then
		carriers[faction].time = GetTime()
	end
	
	SSOverlay:RegisterElapsed(faction .. "time", "timer", L["Held Time: %s"], GetTime() - carriers[faction].time, SSPVP:GetFactionColor(faction))
		
	self:Show(faction)
end

-- Update everything, we do this here instead of specifics
-- so if we drop the flag, then pick it up in combat it won't show it, then hide
function Flag:UpdateStatus()
	if( carriers["Alliance"].name ) then
		self:Show("Alliance")
	else
		self:Hide("Alliance")
	end
	
	if( carriers["Horde"].name ) then
		self:Show("Horde")
	else
		self:Hide("Horde")
	end
end

-- Show flag
function Flag:Show(faction)
	if( not faction or not self[faction] ) then
		return
	end
	
	-- Just because flag changes in combat, doesn't mean 
	-- we can't change name and such information
	self:UpdateCarrier(faction)
		
	if( InCombatLockdown() ) then
		self[faction]:SetAlpha(0.75)
		SSPVP:RegisterOOCUpdate(self, "UpdateStatus")
	else
		self[faction]:SetAlpha(1.0)
		self[faction]:Show()
	end
end

-- Hide flag
function Flag:Hide(faction)
	if( not faction or not self[faction] ) then
		return
	end

	if( InCombatLockdown() ) then
		self[faction]:SetAlpha(0.75)
		SSPVP:RegisterOOCUpdate(self, "UpdateStatus")
	else
		self[faction].carrier = nil
		self[faction]:Hide()
	end
end

-- Update bindings
function Flag:UPDATE_BINDINGS()
	if( InCombatLockdown() ) then
		SSPVP:RegisterOOCUpdate(self, "UPDATE_BINDINGS")
		return
	end
	

	local friendlyFaction, enemyFaction
	if( UnitFactionGroup("player") == "Alliance" ) then
		enemyFaction = "Horde"
		friendlyFaction = "Alliance"
	else
		enemyFaction = "Alliance"
		friendlyFaction = "Horde"
	end
	
	-- Enemy carrier
	local bindKey = GetBindingKey("ETARFLAG")
	if( bindKey ) then
		SetOverrideBindingClick(getglobal("SSFlag" .. friendlyFaction), false, bindKey, "SSFlag" .. friendlyFaction)
	else
		ClearOverrideBindings(getglobal("SSFlag" .. friendlyFaction))
	end
	
	-- Friendly carrier
	bindKey = GetBindingKey("FTARFLAG")
	if( bindKey ) then
		SetOverrideBindingClick(getglobal("SSFlag" .. enemyFaction), false, bindKey, "SSFlag" .. enemyFaction)
	else
		ClearOverrideBindings(getglobal("SSFlag" .. enemyFaction))
	end
end

local function carrierPostClick(self)
	local faction = self.type
	if( not carriers[faction].name ) then
		return
	end
	
	if( IsAltKeyDown() and carriers[faction].name ) then
		SSPVP:ChannelMessage(string.format(L["%s flag carrier %s, held for %s."], L[faction], carriers[faction].name, SecondsToTime(GetTime() - carriers[faction].time)))
	end

	if( self:GetAlpha() ~= 1.0 ) then
		UIErrorsFrame:AddMessage(string.format(L["Cannot target %s, in combat"], carriers[faction].name), 1.0, 0.1, 0.1, 1.0)
	elseif( UnitExists("target") and UnitName("target") == carriers[faction].name ) then
		UIErrorsFrame:AddMessage(string.format(L["Targetting %s"], carriers[faction].name), 1.0, 0.1, 0.1, 1.0)
	elseif( carriers[faction].name ) then
		UIErrorsFrame:AddMessage(string.format(L["%s is out of range"], carriers[faction].name), 1.0, 0.1, 0.1, 1.0)
	end
end

-- Create our target buttons
function Flag:CreateButtons()
	if( not self.Alliance and AlwaysUpFrame1Text ) then
		self.Alliance = CreateFrame("Button", "SSFlagAlliance", UIParent, "SecureActionButtonTemplate")
		self.Alliance:SetHeight(25)
		self.Alliance:SetWidth(150)
		self.Alliance:SetPoint("LEFT", UIParent, "BOTTOMLEFT", AlwaysUpFrame1Text:GetRight() + 8, AlwaysUpFrame1Text:GetTop() - 5)
		self.Alliance:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp", "Button4Up", "Button5Up")
		self.Alliance.type = "Alliance"
		self.Alliance:SetScript("PostClick", carrierPostClick)

		self.Alliance.text = self.Alliance:CreateFontString(nil, "BACKGROUND")
		self.Alliance.text:SetPoint("TOPLEFT", self.Alliance, "TOPLEFT", 0, 0)
		self.Alliance.text:SetFont((GameFontNormal:GetFont()), 11)
		self.Alliance.text:SetShadowOffset(1, -1)
		self.Alliance.text:SetShadowColor(0, 0, 0, 1)
		self.Alliance.text:SetJustifyH("LEFT")
		self.Alliance.text:SetHeight(25)
		self.Alliance.text:SetWidth(150)
	end
	
	if( not self.Horde and AlwaysUpFrame2Text ) then
		self.Horde = CreateFrame("Button", "SSFlagHorde", UIParent, "SecureActionButtonTemplate")
		self.Horde:SetHeight(25)
		self.Horde:SetWidth(150)
		self.Horde:ClearAllPoints()
		self.Horde:SetPoint("LEFT", UIParent, "BOTTOMLEFT", AlwaysUpFrame2Text:GetRight() + 8, AlwaysUpFrame2Text:GetTop() - 5)
		self.Horde:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp", "Button4Up", "Button5Up")
		self.Horde.type = "Horde"
		self.Horde:SetScript("PostClick", carrierPostClick)

		self.Horde.text = self.Horde:CreateFontString(nil, "BACKGROUND")
		self.Horde.text:SetPoint("TOPLEFT", self.Horde, "TOPLEFT", 0, 0)
		self.Horde.text:SetFont((GameFontNormal:GetFont()), 11)
		self.Horde.text:SetShadowOffset(1, -1)
		self.Horde.text:SetShadowColor(0, 0, 0, 1)
		self.Horde.text:SetJustifyH("LEFT")
		self.Horde.text:SetHeight(25)
		self.Horde.text:SetWidth(150)
	end
	
	if( self.Alliance and self.Horde ) then
		self:UPDATE_BINDINGS()
	end
end

-- Handle health time outs + party scan
healthMonitor:SetScript("OnUpdate", function(self, elapsed)
	partyUpdate = partyUpdate + elapsed
	if( partyUpdate >= 0.50 ) then
		partyUpdate = 0
		Flag:ScanParty()
	end
	
	if( allianceUpdate >= 0 ) then
		allianceUpdate = allianceUpdate - elapsed
		
		if( allianceUpdate <= 0 ) then
			allianceUpdate = -1
			Flag:ResetHealth("Alliance")
		end
	end
	
	if( hordeUpdate >= 0 ) then
		hordeUpdate = hordeUpdate - elapsed
		
		if( hordeUpdate <= 0 ) then
			hordeUpdate = -1
			Flag:ResetHealth("Horde")
		end
	end
end)
