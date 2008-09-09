local AB = SSPVP:NewModule("AB", "AceEvent-3.0")
AB.activeIn = "ab"

local L = SSPVPLocals

local timers = {}

function AB:OnInitialize()
	self.defaults = {
		profile = {
			timers = true,
		},
	}
	
	self.db = SSPVP.db:RegisterNamespace("ab", self.defaults)
end

function AB:EnableModule()
	if( self.db.profile.timers ) then
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "ParseCombat")
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "ParseCombat")
	end
end

function AB:DisableModule()
	self:UnregisterAllEvents()
	
	for k in pairs(timers) do
		SSOverlay:RemoveRow(k)
		timers[k] = nil
	end
end

function AB:Reload()
	if( self.isActive ) then
		self:UnregisterAllEvents()
		self:EnableModule()
	end
end

function AB:PrintTimer(node, captureTime, faction)
	if( faction == "CHAT_MSG_BG_SYSTEM_HORDE" ) then
		faction = L["Horde"]
	elseif( faction == "CHAT_MSG_BG_SYSTEM_ALLIANCE" ) then
		faction = L["Alliance"]
	end
	
	SSPVP:ChannelMessage(string.format(L["[%s] %s: %s"], faction, node, SecondsToTime(captureTime - GetTime())))
end

function AB:ParseCombat(event, msg)
	if( string.match(msg, L["claims the ([^!]+)"]) ) then
		local name = string.match(msg, L["claims the ([^!]+)"])
		local node = SSPVP:ParseNode(name)
		timers[name] = GetTime() + 62
		
		SSOverlay:RegisterTimer(name, "timer", node .. ": %s", 62, SSPVP:GetFactionColor(event))
		SSOverlay:RegisterOnClick(name, self, "PrintTimer", node, timers[name], event)
				
	elseif( string.match(msg, L["has assaulted the ([^!]+)"]) ) then
		local name = string.match(msg, L["has assaulted the ([^!]+)"])
		local node = SSPVP:ParseNode(name)
		timers[name] = GetTime() + 62
		
		SSOverlay:RegisterTimer(name, "timer", node .. ": %s", 62, SSPVP:GetFactionColor(event))
		SSOverlay:RegisterOnClick(name, self, "PrintTimer", node, timers[name], event)
	elseif( string.match(msg, L["has taken the ([^!]+)"]) ) then
		local name = string.match(msg, L["has taken the ([^!]+)"])
		
		timers[name] = nil
		SSOverlay:RemoveRow(name)
	elseif( string.match(msg, L["has defended the ([^!]+)"]) ) then
		local name = string.match(msg, L["has defended the ([^!]+)"])
		
		timers[name] = nil
		SSOverlay:RemoveRow(name)
	end
end