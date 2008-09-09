local Score = SSPVP:NewModule("Score", "AceEvent-3.0")
Score.activeIn = "bf"

local L = SSPVPLocals

local enemies = {}
local friendlies = {}

local servers = {}
local classes = {}

local classColors = {}

local scoresRepositioned
local playerName

function Score:OnInitialize()
	self.defaults = {
		profile = {
			level = false,
			icon = true,
			color = true,
			sameServer = true,
		},
	}
	
	self.db = SSPVP.db:RegisterNamespace("score", self.defaults)	
	playerName = UnitName("player")
	
	for class, color in pairs(RAID_CLASS_COLORS) do
		classColors[class] = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
	end
end

function Score:EnableModule()
	if( self.db.profile.level ) then
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
		self:RegisterEvent("RAID_ROSTER_UPDATE")
	end
	
	self:CreateInfoButtons()
end

function Score:DisableModule()
	self:UnregisterAllEvents()
end

function Score:Reload()
	if( self.isActive ) then
		self:UnregisterAllEvents()
		self:EnableModule()
	end
end

-- Maintain a list of friendly players
function Score:RAID_ROSTER_UPDATE()
	for i=1, GetNumRaidMembers() do
		local unit = "raid" .. i
		local name, server = UnitName(unit)
		
		if( server and server ~= "" ) then
			friendlies[name .. "-" .. server] = UnitLevel(unit)
		else
			friendlies[name] = UnitLevel(unit)
		end
	end
end

-- Maintain a list of enemy players
function Score:UPDATE_MOUSEOVER_UNIT()
	self:CheckUnit("mouseover")
end

function Score:PLAYER_TARGET_CHANGED()
	self:CheckUnit("target")
end

function Score:CheckUnit(unit)
	if( UnitIsEnemy(unit, "player") and UnitIsPVP(unit) and UnitIsPlayer(unit) ) then	
		local name, server = UnitName(unit)
		if( server and server ~= "" ) then
			enemies[name .. "-" .. server] = UnitLevel(unit)
		else
			enemies[name] = UnitLevel(unit)
		end
	end	
end

-- Create our tooltip
local function sortTotals(a, b)
	if( not a ) then
		return true
	elseif( not b ) then
		return false
	end
	
	return a.total > b.total
end


function Score:AddClass(class)
	for _, row in pairs(classes) do
		if( row.class == class ) then
			row.total = row.total + 1
			return
		end
	end
	
	table.insert(classes, {total = 1, class = class})
end

function Score:AddServer(server)
	for _, row in pairs(servers) do
		if( row.server == server ) then
			row.total = row.total + 1
			return
		end
	end
	
	table.insert(servers, {total = 1, server = server})
end


function Score:GetTooltip(faction)
	-- Recycle
	for _, row in pairs(servers) do
		row.total = 0		
	end
	
	for _, row in pairs(classes) do
		row.total = 0
	end
	
	-- Base stuff
	local color, factionID
	if( faction == "Alliance" ) then
		color = "|cff0070dd"
		factionID = 1

	elseif( faction == "Horde" ) then
		color = RED_FONT_COLOR_CODE
		factionID = 0

	end
	
	local players = 0
	
	for i=1, GetNumBattlefieldScores() do
		local name, _, _, _, _, playerFaction, _, _, class = GetBattlefieldScore(i)
		if( playerFaction == factionID ) then
			local server
			if( string.match(name, "%-") ) then
				name, server = string.match(name, "(.-)%-(.*)$")
			else
				server = GetRealmName()
			end
		
			players = players + 1

			self:AddServer(server)
			self:AddClass(class)
		end
	end
	
	table.sort(servers, sortTotals)
	table.sort(classes, sortTotals)
	
	-- Parse it out
	local tooltip = string.format(L["%s (%d players)"], color .. L[faction] .. FONT_COLOR_CODE_CLOSE, players) .. "\n\n"
	
	-- Add server info
	tooltip = tooltip .. color .. L["Servers"] .. FONT_COLOR_CODE_CLOSE .. "\n"
	for _, row in pairs(servers) do
		if( row.total > 0 ) then
			tooltip = tooltip .. string.format("%s: %d", row.server, row.total) .. "\n"
		end
	end
	
	-- Add class info
	tooltip = tooltip .. "\n" .. color .. L["Classes"] .. FONT_COLOR_CODE_CLOSE .. "\n"
	for _, row in pairs(classes) do
		if( row.total > 0 ) then
			tooltip = tooltip .. string.format("%s: %d", row.class, row.total) .. "\n"
		end
	end
	
	return tooltip
end


-- Create the Alliance/Horde buttons on the score
local function hideTooltip()
	GameTooltip:Hide()
end

local function showFactionTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:SetText(Score:GetTooltip(self.faction))
	GameTooltip:Show()
end

local function outputServerInfo(self, mouse)
	if( mouse == "RightButton" ) then
		Score:GetTooltip(self.faction)
		
		-- Servers
		local parsedServers = {}
		for _, row in pairs(servers) do
			if( row.total >= 3 ) then
				table.insert(parsedServers, row.server .. ": " .. row.total)
			end
		end
		
		SSPVP:ChannelMessage(table.concat(parsedServers, ", "))
		
		-- Classes
		local parsedClasses = {}
		for _, row in pairs(classes) do
			if( row.total > 0 ) then
				table.insert(parsedClasses, row.class .. ": " .. row.total)
			end
		end
		
		SSPVP:ChannelMessage(table.concat(parsedClasses, ", "))
	end
end

function Score:CreateInfoButtons()
	if( not self.allianceButton ) then
		local button = CreateFrame("Button", nil, WorldStateScoreFrame, "GameMenuButtonTemplate")
		button:SetFont(GameFontHighlightSmall:GetFont())
		button:SetText(L["Alliance"])
		button:SetHeight(19)
		button:SetWidth(button:GetFontString():GetStringWidth() + 10)
		button:SetPoint("TOPRIGHT", WorldStateScoreFrame, "TOPRIGHT", -190, -18)

		button:SetScript("OnLeave", hideTooltip)
		button:SetScript("OnEnter", showFactionTooltip)
		button:SetScript("OnMouseUp", outputServerInfo)
		button.faction = "Alliance"
		
		self.allianceButton = button
	end
	
	if( not self.hordeButton ) then
		local button = CreateFrame("Button", nil, WorldStateScoreFrame, "GameMenuButtonTemplate")
		button:SetFont(GameFontHighlightSmall:GetFont())
		button:SetText(L["Horde"])
		button:SetHeight(19)
		button:SetWidth(button:GetFontString():GetStringWidth() + 10)
		button:SetPoint("TOPRIGHT", WorldStateScoreFrame, "TOPRIGHT", -140, -18)

		button:SetScript("OnLeave", hideTooltip)
		button:SetScript("OnEnter", showFactionTooltip)
		button:SetScript("OnMouseUp", outputServerInfo)
		button.faction = "Horde"
		
		self.hordeButton = button
	end
end

-- Battlefield score changes
hooksecurefunc("WorldStateScoreFrame_Update", function()
	local isArena = IsActiveBattlefieldArena()
	local dataFailure
	
	-- Sometimes will get a bad arena game, and we need to
	-- verify that we got good data before showing a rating change
	-- or else you'll see a large number like -39594134 rating lost
	if( isArena ) then
		for i=0, 1 do
			if( select(2, GetBattlefieldTeamInfo(i)) == 0 ) then
				dataFailure = true
			end
		end
	end

	for i=1, MAX_WORLDSTATE_SCORE_BUTTONS do
		local name, _, _, _, _, faction, _, _, _, classToken = GetBattlefieldScore(FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame) + i)
		if( name ) then
			local nameText = getglobal("WorldStateScoreButton" .. i .. "NameText")

			-- Hide class icons
			if( Score.db.profile.icon ) then
				getglobal("WorldStateScoreButton" .. i .. "ClassButtonIcon"):Hide()
			end

			-- Show level next to the name
			local level = ""
			if( Score.db.profile.level ) then
				if( enemies[name] ) then
					level = "[" .. enemies[name] .. "] "
				elseif( friendlies[name] ) then
					level = "[" .. friendlies[name] .. "] "
				end
			end

			-- Show new rating next to the rating change
			if( isArena ) then
				local teamName, oldRating, newRating = GetBattlefieldTeamInfo(faction)
				if( not dataFailure ) then
					getglobal("WorldStateScoreButton" .. i .. "HonorGained"):SetText(newRating - oldRating .. " (" .. newRating .. ")")
				else
					getglobal("WorldStateScoreButton" .. i .. "HonorGained"):SetText("----")
				end
			end

			-- Append server name to everyone even if they're from the same server
			local server
			if( string.match(name, "-") ) then
				name, server = string.match(name, "(.-)%-(.*)$")
			elseif( Score.db.profile.sameServer ) then
				server = GetRealmName()	
			end
			
			-- Add class color
			local color = ""
			if( Score.db.profile.color and classColors[classToken] ) then
				color = classColors[classToken]
			end
			
			-- Server provided, so show it!
			if( server ) then
				nameText:SetFormattedText("%s%s%s|r - %s", level, color, name, server)
			else
				nameText:SetFormattedText("%s%s%s|r", level, color, name)
			end
		end
	end
end)