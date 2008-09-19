local WG = SSPVP:NewModule("WG", "AceEvent-3.0")
WG.activeIn = "wg"

local L = SSPVPLocals

function WG:OnInitialize()
	self.defaults = {
		profile = {
		},
	}
	
	self.db = SSPVP.db:RegisterNamespace("wg", self.defaults)
end

function WG:EnableModule()
	self:RegisterEvent("PLAYER_DEAD")
end

function WG:DisableModule()
	self:UnregisterAllEvents()
end

function WG:Reload()
	if( self.isActive ) then
		self:UnregisterAllEvents()
		self:EnableModule()
	end
end

-- Auto release, just stole it from Battlefield since it's simpler to do it this way, maybe I'll hack it in another way
function WG:PLAYER_DEAD()
	local self = SSPVP.modules.Battlefield
	if( self.db.profile.release.wg ) then
		-- No soul stone, release
		if( not HasSoulstone() ) then
			StaticPopupDialogs["DEATH"].text = L["Releasing..."]
			RepopMe()	
		
		-- Soul stone active, and we should auto use it
		elseif( HasSoulstone() and self.db.profile.soulstone ) then
			StaticPopupDialogs["DEATH"].text = string.format(L["Using %s..."], HasSoulstone())
			UseSoulstone()		
		
		-- Soul stone active, don't auto release
		else
			StaticPopupDialogs["DEATH"].text = HasSoulstone()	
		end
	
	elseif( not self.db.profile.release.wg ) then
		StaticPopupDialogs["DEATH"].text = TEXT(L["Auto release disabled, %d %s until release"])
	else
		StaticPopupDialogs["DEATH"].text = TEXT(DEATH_RELEASE_TIMER)
	end
end

--[[
local Orig_WorldStateAlwaysUpFrame_Update = WorldStateAlwaysUpFrame_Update
function WorldStateAlwaysUpFrame_Update(...)
	Orig_WorldStateAlwaysUpFrame_Update(...)
	
	if( not WG.isActive ) then
		return
	end
	
	AlwaysUpFrame1:Hide()
	AlwaysUpFrame2:Hide()
	AlwaysUpFrame3:ClearAllPoints()
	AlwaysUpFrame3:SetPoint("TOP", WorldStateAlwaysUpFrame, -23 , -20)
end
]]