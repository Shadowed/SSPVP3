local Config = SSPVP:NewModule("Config")

local L = SSPVPLocals
local OptionHouse
local HousingAuthority

function Config:OnInitialize()
	-- For UI work
	OptionHouse = SSPVP.OptionHouse
	HousingAuthority = LibStub("HousingAuthority-1.2")
	
	local OHObj = OptionHouse:RegisterAddOn("SSPVP2", nil, "Mayen", SSPVP.revision)
	OHObj:RegisterCategory(L["General"], self, "General", nil, 1)
	OHObj:RegisterCategory(L["Modules"], self, "Modules", nil, 2)
	OHObj:RegisterCategory(L["Battlefield"], self, "Battlefield", nil, 3)
	OHObj:RegisterCategory(L["Joining"], self, "Join", nil, 4)
	OHObj:RegisterCategory(L["Leaving"], self, "Leave", nil, 5)
	OHObj:RegisterCategory(L["Overlay"], self, "Overlay", nil, 6)
	OHObj:RegisterCategory(L["Warsong Gulch"], self, "WSG", nil, 7)
	OHObj:RegisterCategory(L["Alterac Valley"], self, "AV", nil, 8)
	OHObj:RegisterCategory(L["Arathi Basin"], self, "AB", nil, 9)
	OHObj:RegisterCategory(L["Eye of the Storm"], self, "EOTS", nil, 10)
end

-- GENERAL
function Config:General()
	local config = {
		{ group = L["General"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["General"], text = L["Show team summary after rated arena ends"], help = L["Shows team names, points change and the new ratings after the arena ends."], type = "check", var = {"Arena", "score"}},
		{ order = 2, group = L["General"], text = L["Show personal rating change after arena ends"], help = L["Shows how much personal rating you gain/lost, will only show up if it's no the same amount of points as your actual team got."], type = "check", var = {"Arena", "personal"}},
		{ order = 3, group = L["General"], text = L["Timer channel"], help = L["Channel to output to when you send timers out from the overlay."], type = "dropdown", list = {{"BATTLEGROUND", L["Battleground"]}, {"RAID", L["Raid"]}, {"PARTY", L["Party"]}},  var = {"general", "channel"}},
		{ order = 4, group = L["General"], text = L["Sound file"], help = L["Sound file to play when a queue is ready, file must be inside Interface/AddOns/SSPVP before you started the game."], type = "input", width = 150, var = {"general", "sound"}}, 
		{ order = 5, group = L["General"], text = L["Play"], type = "button",  onSet = "PlaySound"},
 		
 		{ group = L["Auto Queue"], type = "groupOrder", order = 2 },
		{ order = 1, group = L["Auto Queue"], text = L["Auto queue when outside of a group"], type = "check", var = {"auto", "solo"}},
		{ order = 2, group = L["Auto Queue"], text = L["Auto queue when inside of a group and leader"], type = "check", var = {"auto", "group"}},

 		{ group = L["Queue Overlay"], type = "groupOrder", order = 3 },
		{ order = 1, group = L["Queue Overlay"], text = L["Enable battlefield queue status"], type = "check", var = {"queue", "enabled"}},
		{ order = 2, group = L["Queue Overlay"], text = L["Show inside an active battlefield"], type = "check", var = {"queue", "inBattle"}},

 		{ group = L["Entry Window"], type = "groupOrder", order = 4 },
		{ order = 1, group = L["Entry Window"], text = L["Enable modified battlefield join window"], help = L["Shows time left to join the battlefield, also required for disabling the battlefield window from reshowing again."], type = "check", var = {"Window", "enabled"}},
		{ order = 2, group = L["Entry Window"], text = L["Show battlefield window after it's hidden"], help = L["Reshows the battlefield window even if it's been hidden, requires modified window to be enabled."], type = "check", var = {"Window", "remind"}},

 		{ group = L["Frame Moving"], type = "groupOrder", order = 5 },
		{ order = 1, group = L["Frame Moving"], text = L["Lock PvP objectives"], help = L["Shows an anchor above the frame that lets you move it, the frame you're trying to move may have to be visible to actually move it."], type = "check", var = {"Move", "pvp"}},
		{ order = 2, group = L["Frame Moving"], text = L["Lock scoreboard"], help = L["Shows an anchor above the frame that lets you move it, the frame you're trying to move may have to be visible to actually move it."], type = "check", var = {"Move", "score"}},
		{ order = 3, group = L["Frame Moving"], text = L["Lock capture bar"], help = L["Shows an anchor above the frame that lets you move it, the frame you're trying to move may have to be visible to actually move it."], type = "check", var = {"Move", "capture"}},
	}
	
	return HousingAuthority:CreateConfiguration(config, {onSet = "Reload", set = "Set", get = "Get", handler = Config})
end

-- BATTLEFIELD
function Config:Battlefield()
	local config = {
		{ group = L["General"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["General"], text = L["Auto append server name while in battlefields for whispers"], help = L["Automatically append \"-server\" to peoples names when you whisper them, if multiple people are found to match the same name then it won't add the server."], type = "check", var = {"Battlefield", "whispers"}},
 		
		{ group = L["Scoreboard"], type = "groupOrder", order = 2 },
 		{ order = 1, group = L["Scoreboard"], text = L["Color player name by class"], type = "check", var = {"Score", "color"}},
 		{ order = 2, group = L["Scoreboard"], text = L["Hide class icon next to names"], type = "check", var = {"Score", "icon"}},
 		{ order = 3, group = L["Scoreboard"], text = L["Show player levels next to name"], type = "check", var = {"Score", "level"}},
		
		{ group = L["Death"], type = "groupOrder", order = 3 },
		{ order = 1, group = L["Death"], text = L["Release from corpse when inside an active battleground"], type = "check", var = {"Battlefield", "release"}},
 		{ order = 2, group = L["Death"], text = L["Automatically use soul stone, if any on death"], type = "check", var = {"Battlefield", "soulstone"}},
 	}

	return HousingAuthority:CreateConfiguration(config, {onSet = "Reload", set = "Set", get = "Get", handler = Config})
end

-- AUTO JOIN
local function sortPriorities(a, b)
	if( a[1] == b[1] ) then
		return ( a[3] > b[3] )
	end

	return ( a[1] < b[1] )
end

-- Update everything in the list
local function updatePriorityList(self, noSort)
	if( not noSort ) then
		table.sort(self.list, sortPriorities)
	end

	
	for id, row in pairs(self.list) do
		-- #1, can't move it up anymore
		if( row[1] <= 1 ) then
			self.rows[id].up:Disable()
			self.rows[id].down:Enable()
		
		-- last of list, can't move it down anymore
		elseif( row[1] >= #(self.list) ) then
			self.rows[id].down:Disable()
			self.rows[id].up:Enable()
		
		-- still can move it around
		else
			self.rows[id].up:Enable()
			self.rows[id].down:Enable()
		end
		
		self.rows[id].rowID = id
		self.rows[id].text:SetText(row[3])
		self.rows[id].priority:SetText(row[1])
		self.rows[id]:Show()
	end
end

local key = {"priorities"}
local function movePriorityUp(self)
	local row = self:GetParent()
	local frame = row:GetParent()

	key[2] = frame.list[row.rowID][2]

	frame.list[row.rowID][1] = frame.list[row.rowID][1] - 1
	

	Config:Set(key, frame.list[row.rowID][1])
	updatePriorityList(frame, true)
end

local function movePriorityDown(self)
	local row = self:GetParent()
	local frame = row:GetParent()
	local listRow = frame.list[row.rowID]
	
	key[2] = frame.list[row.rowID][2]
	frame.list[row.rowID][1] = frame.list[row.rowID][1] + 1
	
	Config:Set(key, frame.list[row.rowID][1])
	updatePriorityList(frame, true)
end

function Config:Join()
	local configFrame = CreateFrame("Frame", nil, OptionHouse:GetFrame("addon"))
	

	-- Config -> priority format
	local priorityList = {}
	for key, num in pairs(SSPVP.db.profile.priorities) do
		table.insert(priorityList, {num, key, L[key]})
	end

	-- Create the base frame
	local frame = CreateFrame("Frame", nil, configFrame)
	frame:SetScript("OnShow", updatePriorityList)
	frame:SetFrameStrata("MEDIUM")
	frame:SetWidth(250)
	frame:SetHeight(#(priorityList) * 23)
	frame:EnableMouse(true)
	frame:Hide()
	
	frame.list = priorityList
	frame.rows = {}
		
	-- Create all our little button things
	for i=1, #(priorityList) do
		local row = CreateFrame("Frame", nil, frame)
		row:SetHeight(20)
		row:SetWidth(250)
		row:Hide()
		
		-- Create movement buttons
		row.up = CreateFrame("Button", nil, row, "UIPanelScrollUpButtonTemplate")
		row.up:SetScript("OnClick", movePriorityUp)
		row.up:SetPoint("TOPRIGHT", row, "TOPRIGHT", -60, -3)
		
		row.down = CreateFrame("Button", nil, row, "UIPanelScrollDownButtonTemplate")
		row.down:SetScript("OnClick", movePriorityDown)
		row.down:SetPoint("TOPRIGHT", row.up, "TOPRIGHT", 40, 0)
		
		-- Label/priority #
		row.priority = row:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
		row.priority:SetPoint("CENTER", row.up, "CENTER", 20, 0)

		row.text = row:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall" )
		row.text:SetPoint("TOPLEFT", row, "TOPLEFT", 5, -5)
		frame.rows[i] = row
		
		-- Position (of course)
		if( i > 1 ) then
			row:SetPoint("TOPLEFT", frame.rows[i - 1], "TOPLEFT", 0, -25)
		else
			row:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
		end
	end
	 	
	local config = {
		{ group = L["General"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["General"], text = L["Enable auto join"], type = "check", var = {"join", "enabled"}},
		{ order = 2, group = L["General"], text = L["Don't auto join a battlefield if the queue window is hidden"], type = "check", var = {"join", "window"}},
		{ order = 3, group = L["General"], text = L["Priority check mode"], type = "dropdown", list = {{"less", L["Less than"]}, {"lseql", L["Less than/equal"]}},  var = {"join", "priority"}},
		
		{ group = L["Delay"], type = "groupOrder", order = 2 },
		{ order = 1, group = L["Delay"], text = L["Battleground join delay"], type = "input", numeric = true, width = 30, var = {"join", "battleground"}},
		{ order = 2, group = L["Delay"], text = L["AFK battleground join delay"], type = "input", numeric = true, width = 30, var = {"join", "afkBattleground"}},
		{ order = 3, group = L["Delay"], text = L["Arena join delay"], type = "input", numeric = true, width = 30, var = {"join", "arena"}},
		
		{ group = L["Join priorities"], type = "groupOrder", order = 3 },
		{ group = L["Join priorities"], type = "inject", widget = frame, yPos = 0, xPos = 0 },
	}
	
	return HousingAuthority:CreateConfiguration(config, {onSet = "Reload", frame = configFrame, set = "Set", get = "Get", handler = Config})
end

-- AUTO LEAVE
function Config:Leave()
	local config = {
 		{ group = L["General"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["General"], text = L["Enable auto leave"], type = "check", var = {"leave", "enabled"}},
 		{ order = 2, group = L["General"], text = L["Screenshot score board when game ends"], type = "check", var = {"leave", "screen"}},
		
		{ group = L["Delay"], type = "groupOrder", order = 2 },
 		{ order = 1, group = L["Delay"], text = L["Battlefield leave delay"], type = "input", numeric = true, width = 30, var = {"leave", "delay"}},

		{ group = L["Confirmation"], type = "groupOrder", order = 3 },
		{ order = 1, group = L["Confirmation"], text = L["Confirm when leaving a battlefield queue through minimap list"], type = "check", var = {"leave", "portConfirm"}},
 		{ order = 2, group = L["Confirmation"], text = L["Confirm when leaving a finished battlefield through score"], type = "check", var = {"leave", "leaveConfirm"}},
	}
	
	return HousingAuthority:CreateConfiguration(config, {onSet = "Reload", set = "Set", get = "Get", handler = Config})
end

-- OVERLAY
function Config:Overlay()
	local config = {
		{ group = L["Frame"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["Frame"], text = L["Lock overlay"], type = "check", var = {"Overlay", "locked"}},
		{ order = 2, group = L["Frame"], format = L["Background opacity: %d%%"], type = "slider", var = {"Overlay", "opacity"}},
		{ order = 4, group = L["Frame"], format = L["Scale: %d%%"], min = 0.0, max = 2.0, type = "slider", var = {"Overlay", "scale"}},

		{ group = L["Display"], type = "groupOrder", order = 2 },
		{ order = 1, group = L["Display"], text = L["Grow up"], help = L["The overlay will grow up instead of down when new rows are added, a reloadui maybe required for this to take affect."], type = "check", var = {"Overlay", "growUp"}},
		{ order = 2, group = L["Display"], text = L["Disable overlay clicking"], help = L["Removes the ability to click on the overlay, allowing you to interact with the 3D world instead. While the overlay is unlocked, this option is ignored."], type = "check", var = {"Overlay", "noClick"}},
		{ order = 3, group = L["Display"], text = L["Use short time format"], help = L["Shows timers as HH:MM:SS instead of X Minutes, X Seconds"], type = "check", var = {"Overlay", "shortTime"}},
		
		{ group = L["Color"], type = "groupOrder", order = 3 },
		{ order = 1, group = L["Color"], text = L["Background color"], type = "color", var = {"Overlay", "background"}},
		{ order = 2, group = L["Color"], text = L["Border color"], type = "color", var = {"Overlay", "border"}},
		{ order = 3, group = L["Color"], text = L["Text color"], type = "color", var = {"Overlay", "textColor"}},
		{ order = 4, group = L["Color"], text = L["Category text color"], type = "color", var = {"Overlay", "categoryColor"}},
	}
	
	return HousingAuthority:CreateConfiguration(config, {onSet = "Reload", onSet = "Reload", set = "Set", get = "Get", handler = Config})
end

-- AV
function Config:AV()
	local config = {
		{ group = L["Timers"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["Timers"], text = L["Enable capture timers"], type = "check", var = {"AV", "timer"}},
		{ order = 2, group = L["Timers"], text = L["Show resources gained through mines"], type = "check", var = {"AV", "mine"}},
		{ order = 3, group = L["Timers"], text = L["Show resources lost from captains and towers in MSBT/SCT/FCT"], type = "check", var = {"AV", "combat"}},

		{ group = L["Alerts"], type = "groupOrder", order = 2 },
		{ order = 2, group = L["Alerts"], text = L["Enable interval capture messages"], type = "check", var = {"AV", "announce"}},
		{ order = 3, group = L["Alerts"], text = L["Seconds between capture messages"], type = "input", numeric = true, width = 30, var = {"AV", "interval"}},
		{ order = 4, group = L["Alerts"], text = L["Interval frequency increase"], type = "dropdown", list = {{0, L["None"]}, {0.75, L["25%"]}, {0.50, L["50%"]}, {0.25, L["75%"]}},  var = {"AV", "speed"}},

		{ group = L["Death"], type = "groupOrder", order = 4 },
		{ order = 1, group = L["Death"], text = L["Disable auto release"], help = L["Disables auto release for this specific battleground."], type = "check", var = {"Battlefield", "av"}},
 	}

	return HousingAuthority:CreateConfiguration(config, {onSet = "Reload", set = "Set", get = "Get", handler = Config})
end

-- EOTS
function Config:EOTS()
	local config = {
		{ group = L["Flag Carrier"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["Flag Carrier"], text = L["Show flag carrier"], type = "check", var = {"Flag", "eots", "enabled"}},
		{ order = 2, group = L["Flag Carrier"], text = L["Show carrier health when available"], type = "check", var = {"Flag", "eots", "health"}},
		{ order = 3, group = L["Flag Carrier"], text = L["Color carrier name by class color"], type = "check", var = {"Flag", "eots", "color"}},
		{ order = 4, group = L["Flag Carrier"], text = L["Time until flag respawns"], type = "check", var = {"Flag", "eots", "respawn"}},
		{ order = 5, group = L["Flag Carrier"], text = L["Show flag held time and time taken to capture"], type = "check", var = {"Flag", "eots", "capture"}},
		{ order = 1, group = L["Macro Text"], text = L["Text to execute when clicking on the flag carrier button"], type = "editbox", default = "/targetexact *name", var = {"Flag", "eots", "macro"}},
				
		{ group = L["Match Info"], type = "groupOrder", order = 2 },
		{ order = 1, group = L["Match Info"], text = L["Show basic match information"], type = "check", var = {"Match", "eots", "matchInfo"}},
		{ order = 2, group = L["Match Info"], text = L["Show bases to win"], type = "check", var = {"Match", "eots", "bases"}},

		{ group = L["Death"], type = "groupOrder", order = 2 },
		{ order = 1, group = L["Death"], text = L["Disable auto release"], help = L["Disables auto release for this specific battleground."], type = "check", var = {"Battlefield", "eots"}},
 	}

	return HousingAuthority:CreateConfiguration(config, {onSet = "Reload", set = "Set", get = "Get", handler = Config})
end

-- AB
function Config:AB()
	local config = {
		{ group = L["Match Info"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["Match Info"], text = L["Show basic match information"], type = "check", var = {"Match", "ab", "matchInfo"}},
		{ order = 2, group = L["Match Info"], text = L["Show bases to win"], type = "check", var = {"Match", "ab", "bases"}},

		{ group = L["Death"], type = "groupOrder", order = 2 },
		{ order = 1, group = L["Death"], text = L["Disable auto release"], help = L["Disables auto release for this specific battleground."], type = "check", var = {"Battlefield", "ab"}},
 	}

	return HousingAuthority:CreateConfiguration(config, {onSet = "Reload", set = "Set", get = "Get", handler = Config})
end

-- WSG
function Config:WSG()
	local config = {
		{ group = L["Flag Carrier"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["Flag Carrier"], text = L["Show flag carrier"], type = "check", var = {"Flag", "wsg", "enabled"}},
		{ order = 2, group = L["Flag Carrier"], text = L["Show carrier health when available"], type = "check", var = {"Flag", "wsg", "health"}},
		{ order = 3, group = L["Flag Carrier"], text = L["Color carrier name by class color"], type = "check", var = {"Flag", "wsg", "color"}},
		{ order = 4, group = L["Flag Carrier"], text = L["Time until flag respawns"], type = "check", var = {"Flag", "wsg", "respawn"}},
		{ order = 5, group = L["Flag Carrier"], text = L["Show flag held time and time taken to capture"], type = "check", var = {"Flag", "wsg", "capture"}},

		{ group = L["Death"], type = "groupOrder", order = 2 },
		{ order = 1, group = L["Death"], text = L["Disable auto release"], help = L["Disables auto release for this specific battleground."], type = "check", var = {"Battlefield", "wsg"}},

		{ group = L["Macro Text"], type = "groupOrder", order = 3 },
		{ order = 1, group = L["Macro Text"], text = L["Text to execute when clicking on the flag carrier button"], type = "editbox", default = "/targetexact *name", var = {"Flag", "eots", "macro"}},
 	}

	return HousingAuthority:CreateConfiguration(config, {onSet = "Reload", set = "Set", get = "Get", handler = Config})
end

-- Disable modules
function Config:Modules()
	local config = {{ group = L["Modules"], type = "groupOrder", order = 1 }}
	local modules = {
		["Battlegrouynd"] = { order = 1, label = L["battleground"], help = L["General battleground specific changes like auto release."] },
		["Score"] = { order = 2, label = L["score"], help = L["General scoreboard changes like coloring by class or hiding the class icons."] },
		["Flag"] = { order = 3, label = L["flag carrier"], help = L["Who's holding the flag currently for Eye of the Storm and Warsong Gulch."] },
		["Match"] = { order = 4, label = L["match information"], help = L["Time left in match, final scores and bases to win for Eye of the Storm and Arathi Basin."] },
		["AV"] = { order = 5, label = L["Alterac Valley"], help = L["Timers for Alterac Valley when capturing nodes, as well interval alerts on time left before capture."] },
		["AB"] = { order = 6, label = L["Arathi Basin"], help = L["Timers for Arathi Basin when capturing nodes."] },
		["EOTS"] = { order = 7, label = L["Eye of the Storm"], help = L["Cleaning up the text in the PvP objectives along with points gained from captures in Eye of the Storm."] },
	}
	
	for module, data in pairs(modules) do
		data.type = "check"
		data.text = string.format(L["Disable %s"], data.label)
		data.var = {"modules", module}
		data.group = L["Modules"]
		data.label = nil
		
		table.insert(config, data)
	end

	return HousingAuthority:CreateConfiguration(config, {set = "Set", get = "Get", handler = Config})
end


-- Sound demo
function Config:PlaySound()
	if( self.soundPlaying ) then
		self:SetText(L["Play"])

		SSPVP:StopSound()
		self.soundPlaying = nil
	else
		self:SetText(L["Stop"])

		SSPVP:PlaySound()
		self.soundPlaying = true
	end
end

-- Set things
function Config:Reload(var, val)
	local module = SSPVP.modules[var[1]]
	if( module and module.Reload ) then
		module.Reload(module)
	else
		SSPVP.Reload(SSPVP)
	end
end

-- Certainly not the most clean way of doing it, will improve it later
function Config:Set(var, val)
	-- Figure out which DB to modify
	local db
	local start = 1
	if( SSPVP.modules[var[1]] ) then
		db = SSPVP.modules[var[1]].db.profile
		start = 2
	else
		db = SSPVP.db.profile
	end
	
	if( #(var) == (2 + start) ) then
		db[var[0 + start]][var[1 + start]][var[2 + start]] = val
	elseif( #(var) == (1 + start) ) then
		db[var[0 + start]][var[1 + start]] = val
	elseif( #(var) == start ) then
		db[var[start]] = val
	else
		db[var] = val
	end
end

function Config:Get(var)
	-- Figure out which DB to modify
	local db
	local start = 1
	if( SSPVP.modules[var[1]] ) then
		db = SSPVP.modules[var[1]].db.profile
		start = 2
	else
		db = SSPVP.db.profile
	end
	
	if( #(var) == (2 + start) ) then
		return db[var[0 + start]][var[1 + start]][var[2 + start]]
	elseif( #(var) == (1 + start) ) then
		return db[var[0 + start]][var[1 + start]]
	elseif( #(var) == start ) then
		return db[var[start]]
	else
		return db[var]
	end
end