local SOTA = SSPVP:NewModule("SOTA", "AceEvent-3.0")
SOTA.activeIn = "sota"

local L = SSPVPLocals

function SOTA:OnInitialize()
	self.defaults = {
		profile = {
		},
	}
	
	self.db = SSPVP.db:RegisterNamespace("sota", self.defaults)
end

function SOTA:EnableModule()
end

function SOTA:DisableModule()
end

function SOTA:Reload()
	if( self.isActive ) then
		self:UnregisterAllEvents()
		self:EnableModule()
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