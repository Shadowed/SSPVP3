local Window = SSPVP:NewModule("Window", "AceEvent-3.0")
local L = SSPVPLocals

local entryDialog
local lastStatus = {}

function Window:OnInitialize()
	self.defaults = {
		profile = {
			enabled = true,
			remind = false,
		},
	}
	
	self.db = SSPVP.db:RegisterNamespace("window", self.defaults)
	

	if( self.db.profile.enabled ) then
		-- We nil this out because it's the cleanest way to prevent it from ever showing
		-- over hooking Blizzard functions or calling StaticPopup_Hide when it's shown
		entryDialog = StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"]
		StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] = nil
	end
end

function Window:OnEnable()
	if( self.db.profile.enabled ) then
		self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	end
end

function Window:Reload()
	self:UnregisterAllEvents()
	self:OnEnable()
	
	-- Restore the original entry
	if( self.db.profile.enabled ) then
		if( StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] and not entryDialog ) then
			entryDialog = StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"]
			StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] = nil
		end
	else
		if( not StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] and entryDialog ) then
			StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] = entryDialog
			entryDialog = nil
		end
	end
end

function Window:PopupWindow(statusID, instanceID, map, teamSize, isRegistered)
	local name
	if( map == L["All Arenas"] or map == L["Eastern Kingdoms"] ) then
		if( isRegistered ) then
			map = L["Rated Arena"]
		else
			map = L["Skirmish Arena"]
		end
	end

	if( teamSize > 0 ) then
		name = string.format(L["%s (%dvs%d)"], map, teamSize, teamSize)
	else
		name = string.format("%s #%d", map, instanceID)
	end

	local frame = StaticPopup_Show("CONFIRM_NEW_BFENTRY", name, SecondsToTime(GetBattlefieldPortExpiration(statusID) / 1000), statusID)
	if( frame ) then
		frame.data = statusID
		frame.text_arg1 = name
		frame.portExpiration = GetBattlefieldPortExpiration(statusID) / 1000 + GetTime()
	end
end

function Window:UPDATE_BATTLEFIELD_STATUS()
	for i=1, MAX_BATTLEFIELD_QUEUES do
		local status, map, instanceID, _, _, teamSize, isRegistered = GetBattlefieldStatus(i)
		
		if( status ~= lastStatus[i] ) then
			-- Fresh confirmation, show it up
			if( status == "confirm" ) then
				self:PopupWindow(i, instanceID, map, teamSize, isRegistered)
			
			-- Used to be a confirm, no longer is
			elseif( lastStatus[i] == "confirm" ) then
				StaticPopup_Hide("CONFIRM_NEW_BFENTRY", i)
			end

		-- Nag the user about the queue
		elseif( status == "confirm" and self.db.profile.remind ) then
			self:PopupWindow(i, instanceID, map, teamSize)
		end
		
		lastStatus[i] = status	
	end
end

StaticPopupDialogs["CONFIRM_NEW_BFENTRY"] = {
	text = L["You are now eligible to enter %s. %s left to join."],
	button1 = ENTER_BATTLE,
	button2 = HIDE,
	OnAccept = function(data)
		AcceptBattlefieldPort(data, true)
	end,
	OnUpdate = function(elapsed, dialog)
		if( not dialog.portExpiration ) then
			return
		end
		
		local seconds = floor(dialog.portExpiration - GetTime())
		if( seconds <= 0 ) then
			dialog.portExpiration = nil
			return
		end
		
		getglobal(dialog:GetName() .. "Text"):SetFormattedText(L["You are now eligible to enter %s. %s left to join."], dialog.text_arg1, SecondsToTime(seconds))
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	multiple = 1
}