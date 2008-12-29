local SOTA = SSPVP:NewModule("SOTA", "AceEvent-3.0")
SOTA.activeIn = "sota"

local L = SSPVPLocals

function SOTA:OnInitialize()
	self.defaults = {
		profile = {
			bomb = true,
		},
	}
	
	self.db = SSPVP.db:RegisterNamespace("sota", self.defaults)
end

function SOTA:EnableModule()
	if( self.db.profile.bomb ) then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

function SOTA:DisableModule()
	self:UnregisterAllEvents()
end

function SOTA:Reload()
	if( self.isActive ) then
		self:UnregisterAllEvents()
		self:EnableModule()
	end
end

local COMBATLOG_OBJECT_REACTION_HOSTILE	= COMBATLOG_OBJECT_REACTION_HOSTILE
local events = {["SPELL_CREATE"] = true}
function SOTA:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	if( not events[eventType] or bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= COMBATLOG_OBJECT_REACTION_HOSTILE ) then
		return
	end
			
	if( eventType == "SPELL_CREATE" ) then
		local spellID, spellName, spellSchool = ...
		if( spellID == 52410 ) then
			SSOverlay:RegisterTimer("bomb" .. sourceGUID, "timer", L["Bomb: %s"], 10, SSPVP:GetFactionColor("Neutral"))
		end
	end
end

local Orig_WorldStateAlwaysUpFrame_Update = WorldStateAlwaysUpFrame_Update
function WorldStateAlwaysUpFrame_Update(...)
	Orig_WorldStateAlwaysUpFrame_Update(...)
	
	if( not SOTA.isActive or NUM_ALWAYS_UP_UI_FRAMES < 3 ) then
		return
	end
	
	AlwaysUpFrame1:Hide()
	AlwaysUpFrame2:Hide()
	AlwaysUpFrame3:ClearAllPoints()
	AlwaysUpFrame3:SetPoint("TOP", WorldStateAlwaysUpFrame, -23 , -20)
end