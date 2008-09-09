local AV = SSPVP:NewModule("AV", "AceEvent-3.0", "AceTimer-3.0")
AV.activeIn = "av"

local L = SSPVPLocals
local timers = {}

local allianceGain = 0
local allianceReinf = 0

local hordeGain = 0
local hordeReinf = 0

function AV:OnInitialize()
	self.defaults = {
		profile = {
			timer = true,
			announce = false,
			mine = false,
			speed = 0.50,
			interval = 60,
			combat = true,
		},
	}

	self.db = SSPVP.db:RegisterNamespace("av", self.defaults)
end

function AV:EnableModule()
	self:RegisterEvent("UPDATE_WORLD_STATES")

	if( self.db.profile.timer or self.db.profile.announce ) then
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
	end
end

function AV:DisableModule()
	self:UnregisterAllEvents()
	
	allianceGain = 0
	allianceReinf = 0

	hordeGain = 0
	hordeReinf = 0
	
	for k in pairs(timers) do
		timers[k] = nil
	end
	
	SSOverlay:RemoveCategory("timer")
	SSOverlay:RemoveCategory("mine")
end

function AV:Reload()
	if( self.isActive ) then
		self:UnregisterAllEvents()
		self:EnableModule()
	end
end

function AV:Message(alert)
	-- AceTimer-3.0 doesn't let us unregister a timer easly for this kind of case
	-- so we have to do extra checks here to be safe
	if( not timers[alert.name] or not self.db.profile.announce ) then
		return
	end
	

	SSPVP:ChatMessage(string.format(L["%s will be captured by the %s in %s"], alert.name, L[alert.faction], SecondsToTime(alert.seconds)), alert.faction)
end

function AV:PrintTimer(node, captureTime, faction)
	if( not node or not captureTime or not faction ) then
		return
	end
	
	SSPVP:ChannelMessage(string.format(L["[%s] %s: %s"], faction, node, SecondsToTime(captureTime - GetTime())))
end

function AV:StartAnnounce(name, faction)
	for seconds=1, 244 do
		local interval
		if( seconds <= 120 and self.db.profile.speed > 0 ) then
			interval = self.db.profile.interval * self.db.profile.speed
		else
			interval = self.db.profile.interval
		end
		
		if( mod(seconds, interval) == 0 ) then
			self:ScheduleTimer("Message", 245 - seconds, {name = name, seconds = seconds, faction = faction})
		end
	end
end

-- Captain death, or reinforcements gained through mines
function AV:UPDATE_WORLD_STATES()
	local _, _, allianceText = GetWorldStateUIInfo(1)
	local _, _, hordeText = GetWorldStateUIInfo(2)
	
	-- No text found (shouldn't happen)
	if( not allianceText or not hordeText ) then
		return
	end
	
	-- Figure out points changed for Alliance
	local reinf = string.match(allianceText, L["Reinforcements: ([0-9]+)"])
	reinf = tonumber(reinf) or 0
	
	if( allianceReinf > 0 ) then
		local diff = allianceReinf - reinf
		if( diff == 100 ) then
			SSPVP:ChatMessage(L["The Horde has slain Captain Balinda Stonehearth."], "Horde")
			
			if( self.db.profile.combat ) then
				SSPVP:CombatText(string.format(L["-%d Reinforcements"], 100), SSPVP:GetFactionColor("Alliance"))
			end
			
		elseif( diff < 0 ) then
			allianceGain = allianceGain - diff
			
			if( self.db.profile.mine ) then
				SSOverlay:RegisterText("alliancemine", "mine", L["Alliance"] .. ": " .. allianceGain, SSPVP:GetFactionColor("Alliance"))
			end
		end
	end
	
	allianceReinf = reinf
	
	-- Figure out points changed for Horde
	local reinf = string.match(hordeText, L["Reinforcements: ([0-9]+)"])
	reinf = tonumber(reinf) or 0

	if( hordeReinf > 0 ) then
		local diff = hordeReinf - reinf
		if( diff == 100 ) then
			SSPVP:ChatMessage(L["The Alliance has slain Captain Galvangar."], "Alliance")

			if( self.db.profile.combat ) then
				SSPVP:CombatText(string.format(L["-%d Reinforcements"], 100), SSPVP:GetFactionColor("Horde"))
			end
		elseif( diff < 0 ) then
			hordeGain = hordeGain - diff
			
			if( self.db.profile.mine ) then
				SSOverlay:RegisterText("hordemine", "mine", L["Horde"] .. ": " .. hordeGain, SSPVP:GetFactionColor("Horde"))
			end
		end
	end
	
	hordeReinf = reinf
end

-- Tower/GY timers
function AV:CHAT_MSG_MONSTER_YELL(event, msg, npc)
	if( npc == L["Herald"] ) then
		-- Monster yells don't give us specific faction, so have to check it
		local faction
		if( string.match(msg, L["Alliance"]) ) then
			faction = "Alliance"
		elseif( string.match(msg, L["Horde"]) ) then
			faction = "Horde"
		end
		
		-- Tower or GY assaulted
		if( string.match(msg, L["(.+) is under attack"]) ) then
			local name = string.match(msg, L["(.+) is under attack"])
			name = SSPVP:ParseNode(name)
			timers[name] = GetTime() + 245
			
			if( self.db.profile.timer ) then
				SSOverlay:RegisterTimer(name, "timer", name .. ": %s", 245, SSPVP:GetFactionColor(faction))
				SSOverlay:RegisterOnClick(name, self, "PrintTimer", name, timers[name], L[faction])
			end

			if( self.db.profile.announce ) then
				self:StartAnnounce(name, faction, timers[name])
			end

		-- Tower or GY either defended, or captured
		elseif( string.match(msg, L["(.+) was taken"]) ) then
			local name = string.match(msg, L["(.+) was taken"])
			name = SSPVP:ParseNode(name)
			
			timers[name] = nil
			SSOverlay:RemoveRow(name)

		-- Tower burned
		elseif( string.match(msg, L["(.+) was destroyed"]) ) then
			local name = string.match(msg, L["(.+) was destroyed"])
			name = SSPVP:ParseNode(name)
			
			timers[name] = nil
			SSOverlay:RemoveRow(name)
			
			-- Show reinforcement lost on CT
			if( self.db.profile.combat ) then
				local revFaction
				if( faction == "Alliance" ) then
					revFaction = "Horde"
				else
					revFaction = "Alliance"
				end
				
				SSPVP:CombatText(string.format(L["-%d Reinforcements"], 75), SSPVP:GetFactionColor(revFaction))
			end
		end
	
	-- Ivus the Forest Lord was summoned successfully
	elseif( self.db.profile.timer and npc == L["Ivus the Forest Lord"] and string.match(msg, L["Wicked, wicked, mortals"]) ) then
		timers[L["Ivus the Forest Lord"]] = GetTime() + 600
		
		SSOverlay:RegisterTimer(npc, "timer", L["Ivus Moving: %s"], 600, SSPVP:GetFactionColor("Horde"))
		SSOverlay:RegisterOnClick(name, self, "PrintTimer", L["Ivus the Forest Lord"], timers[L["Ivus the Forest Lord"]], L["Horde"])
	
	-- Lokholar the Ice Lord was summoned successfully
	elseif( self.db.profile.timer and npc == L["Lokholar the Ice Lord"] and string.match(msg, L["WHO DARES SUMMON LOKHOLA"]) ) then
		timers[L["Lokholar the Ice Lord"]] = GetTime() + 600

		SSOverlay:RegisterTimer(npc, "timer", L["Lokholar Moving: %s"], 600, SSPVP:GetFactionColor("Alliance"))
		SSOverlay:RegisterOnClick(name, self, "PrintTimer", L["Lokholar the Ice Lord"], timers[L["Lokholar the Ice Lord"]], L["Alliance"])
	end
end

-- For some god knows why reason, SF GY being claimed triggers the "correct" events
-- so we have to add specific checks for it which is sadface
function AV:CHAT_MSG_BG_SYSTEM_HORDE(event, msg)
	if( string.match(msg, L["claims the Snowfall graveyard"]) ) then
		timers[L["Snowfall Graveyard"]] = GetTime() + 304

		if( self.db.profile.timer ) then
			SSOverlay:RegisterTimer(L["Snowfall Graveyard"], "timer", L["Snowfall Graveyard"] .. ": %s", 304, SSPVP:GetFactionColor("Horde"))
			SSOverlay:RegisterOnClick(L["Snowfall Graveyard"], self, "PrintTimer", L["Snowfall Graveyard"], timers[name], L["Horde"])
		end

		if( self.db.profile.announce ) then
			self:StartAnnounce(L["Snowfall Graveyard"], "Horde", timers[L["Snowfall Graveyard"]])
		end
	end
end

function AV:CHAT_MSG_BG_SYSTEM_ALLIANCE(event, msg)
	if( string.match(msg, L["claims the Snowfall graveyard"]) ) then
		timers[L["Snowfall Graveyard"]] = GetTime() + 304

		if( self.db.profile.timer ) then
			SSOverlay:RegisterTimer(L["Snowfall Graveyard"], "timer", L["Snowfall Graveyard"] .. ": %s", 304, SSPVP:GetFactionColor("Alliance"))
			SSOverlay:RegisterOnClick(L["Snowfall Graveyard"], self, "PrintTimer", L["Snowfall Graveyard"], timers[name], L["Alliance"])
		end
		
		if( self.db.profile.announce ) then
			self:StartAnnounce(L["Snowfall Graveyard"], "Alliance", timers[L["Snowfall Graveyard"]])
		end
	end
end

-- Block spammy messages and clarify them
local Orig_ChatFrame_OnEvent = ChatFrame_OnEvent
function ChatFrame_OnEvent(event, ...)
	if( event == "CHAT_MSG_MONSTER_YELL" ) then
		if( arg2 == L["Herald"] ) then
			if( string.match(arg1, L["Alliance"]) ) then
				SSPVP:ChatMessage(arg1, "Alliance")
				return
				
			elseif( string.match(arg1, L["Horde"]) ) then
				SSPVP:ChatMessage(arg1, "Horde")
				return
			end
			
		elseif( arg2 == L["Vanndar Stormpike"] ) then
			if( string.match(arg1, L["Soldiers of Stormpike, your General is under attack"]) ) then
				SSPVP:ChatMessage(L["The Horde has engaged Vanndar Stormpike."], "Horde")
				return
			
			elseif( string.match(arg1, L["Why don't ya try again"]) ) then
				SSPVP:ChatMessage(L["The Horde has reset Vanndar Stormpike."], "Horde")
				return

			elseif( string.match(arg1, L["You'll never get me out of me"]) ) then
				return
			end
		
		elseif( arg2 == L["Drek'Thar"] ) then
			if( string.match(arg1, L["Stormpike filth!"]) ) then
				SSPVP:ChatMessage(L["The Alliance has engaged Drek'Thar."], "Alliance")
				return
				
			elseif( string.match(arg1, L["You seek to draw the General of the Frostwolf"]) ) then
				SSPVP:ChatMessage(L["The Alliance has reset Drek'Thar."], "Alliance")
				return

			elseif( string.match(arg1, L["Stormpike weaklings"]) ) then
				return
			end
			
		elseif( arg2 == L["Captain Balinda Stonehearth"] ) then
			if( string.match(arg1, L["Begone, uncouth scum!"]) ) then
				SSPVP:ChatMessage(L["The Horde has engaged Captain Balinda Stonehearth."], "Horde")
				return
			
			elseif( string.match(arg1, L["Filthy Frostwolf cowards"]) ) then
				SSPVP:ChatMessage(L["The Horde has reset Captain Balinda Stonehearth."], "Horde")
				return
			end
		
		elseif( arg2 == L["Captain Galvangar"] ) then
			if( string.match(arg1, L["Your kind has no place in Alterac Valley"]) ) then
				SSPVP:ChatMessage(L["The Alliance has engaged Captain Galvangar."], "Alliance")
				return
				
			elseif( string.match(arg1, L["I'll never fall for that, fool!"]) ) then
				SSPVP:ChatMessage(L["The Alliance has reset Captain Galvangar."], "Alliance")
				return
			end
		end
	end
	
	return Orig_ChatFrame_OnEvent(event, ...)
end
