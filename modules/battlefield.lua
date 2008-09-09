local BF = SSPVP:NewModule("Battlefield", "AceEvent-3.0")
BF.activeIn = "bf"

local L = SSPVPLocals
local joinedMatch, leftMatch

local joinedQueue = {}

function BF:OnInitialize()
	self.defaults = {
		profile = {
			release = true,
			whispers = true,
			soulstone = false,
			eots = false,
			av = false,
			wsg = false,
			ab = false,
		},
	}
	
	self.db = SSPVP.db:RegisterNamespace("battlefield", self.defaults)
end

function BF:EnableModule(abbrev)
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
	self.activeBF = abbrev
	
	-- May not want to auto release in arenas in case a team mates going to try and ressurect you
	if( abbrev ~= "arena" ) then
		self:RegisterEvent("PLAYER_DEAD")
	end
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.FilterSystemMessages)
end

function BF:DisableModule()
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.FilterSystemMessages)
	SSOverlay:RemoveRow("start")
	
	self:UnregisterAllEvents()
	self.activeBF = nil
	
	-- Blizzards code doesn't seem to hide it correctly, so will do it ourselves
	if( SHOW_BATTLEFIELD_MINIMAP == "1" and BattlefieldMinimap and BattlefieldMinimap:IsVisible() ) then
		BattlefieldMinimap:Hide()
	end
end

-- Filter spam
function BF.FilterSystemMessages(msg)
	if( string.match(msg, L["the raid group.$"]) ) then
		return true
	end
	
	return false
end


-- Start timers
function BF:CHAT_MSG_BG_SYSTEM_NEUTRAL(event, msg)
	if( string.match(msg, L["2 minute"]) ) then
		SSOverlay:RegisterTimer("start", "timer", L["Starting: %s"], 120)
	elseif( string.match(msg, L["1 minute"]) or string.match(msg, L["One minute"]) ) then
		SSOverlay:RegisterTimer("start", "timer", L["Starting: %s"], 60)
	elseif( string.match(msg, L["30 seconds"]) or string.match(msg, L["Thirty seconds"]) ) then
		SSOverlay:RegisterTimer("start", "timer", L["Starting: %s"], 30)
	elseif( string.match(msg, L["Fifteen seconds"]) ) then
		SSOverlay:RegisterTimer("start", "timer", L["Starting: %s"], 15)
	end
end

-- Auto release
function BF:PLAYER_DEAD()
	if( self.db.profile.release and not self.db.profile[self.activeBF] ) then
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
	
	elseif( self.db.profile[self.activeBF] ) then
		StaticPopupDialogs["DEATH"].text = TEXT(L["Auto release disabled, %d %s until release"])
	else
		StaticPopupDialogs["DEATH"].text = TEXT(DEATH_RELEASE_TIMER)
	end
end

-- Auto append server name
local Orig_SendChatMessage = SendChatMessage
function SendChatMessage(text, type, language, target, ...)
	-- See if we should try and find a match to the one we gave
	if( BF.isActive and type == "WHISPER" and target and BF.db.profile.whispers and not string.match(target, "-") ) then
		local results = 0
		local player

		-- Scan scores find match(es)
		for i=1, GetNumBattlefieldScores() do
			local name = GetBattlefieldScore(i)
			
			-- Make sure they're from another server
			if(  name and string.match(string.lower(name), "^" .. string.lower(target)) ) then
				player = name
				results = results + 1
			end
		end
		
		-- If we only found one match, set the new name, otherwise discard it
		if( results == 1 ) then
			target = player
		end
	end
	
	return Orig_SendChatMessage(text, type, language, target, ...)
end