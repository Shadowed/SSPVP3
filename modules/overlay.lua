SSOverlay = SSPVP:NewModule("Overlay")

local L = SSPVPLocals

local MAX_ROWS = 20
local ACTIVE_ROWS = 0
local ACTIVE_CATS = 0

local longestText = 0
local timers, catCount = {}, {}

local categories = {
	["faction"] = { id = "catfaction", label = L["Faction Balance"], order = 0 },
	["timer"] = { id = "cattimer", label = L["Timers"], order = 20 },
	["match"] = { id = "catmatch", label = L["Match Info"], order = 30 },
	["mine"] = { id = "catmine", label = L["Mine Reinforcement"], order = 50 },
	["queue"] = { id = "catqueue", label = L["Battlefield Queue"], order = 60 },
}

function SSOverlay:OnInitialize()
	self.defaults = {
		profile = {
			locked = true,
			noClick = false,
			growUp = false,
			shortTime = true,
			x = 300,
			y = 600,
			opacity = 1.0,
			background = { r = 0, g = 0, b = 0 },
			border = { r = 0.75, g = 0.75, b = 0.75 },
			textColor = { r = 1, g = 1, b = 1 },
			categoryColor = { r = 0.75, g = 0.75, b = 0.75 },
			scale = 1.0,
		},
	}
	
	self.db = SSPVP.db:RegisterNamespace("overlay", self.defaults)
	
	-- Auto create rows as needed
	self.rows = setmetatable({}, {__index = function(t, k)
		local row = self:CreateRow()
		rawset(t, k, row)
		
		return row
	end})
end

function SSOverlay:Reload()
	if( not self.frame ) then
		return
	end
	
	self.frame:SetScale(self.db.profile.scale)
	self.frame:SetBackdropColor(self.db.profile.background.r, self.db.profile.background.g, self.db.profile.background.b, self.db.profile.opacity)
	self.frame:SetBackdropBorderColor(self.db.profile.border.r, self.db.profile.border.g, self.db.profile.border.b, self.db.profile.opacity)
	self.frame:EnableMouse(not self.db.profile.locked)
	self:UpdateOverlay()
	
	-- We reset the position before so if we swapped display modes it'll work
	self.frame:ClearAllPoints()
	for _, row in pairs(self.rows) do
		row:ClearAllPoints()
	end
	
	for id, row in pairs(self.rows) do
		-- If overlay is unlocked, disable mouse so we can move, If it's locked, then enable it if we're not disabling it
		if( not self.db.profile.locked ) then
			row:EnableMouse(false)
		else
			row:EnableMouse(not self.db.profile.noClick)
		end
		
		if( id > 1 ) then
			row:SetPoint("TOPLEFT", self.rows[id - 1], "TOPLEFT", 0, -12)
		else
			row:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 5, -5)
		end
	end

	local scale = self.frame:GetEffectiveScale()
	if( not self.db.profile.growUp ) then
		self.frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.profile.x / scale, self.db.profile.y / scale)
	else
		self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.profile.x / scale, self.db.profile.y / scale)
	end
end

local function safecall(func, ...)
	local success, result = pcall(func, ...)
	if( not success ) then
		geterrorhandler()(result)
	end
end

local function onClick(self)
	-- So you won't accidentally click the overlay, make sure we have an on click too
	if( not IsModifierKeyDown() or not self.data.func ) then
		return
	end
	
	-- Trigger it
	local row = self.data
	if( row.handler ) then
		safecall(row.handler[row.func], row.handler, row.arg)
	elseif( type(row.func) == "string" ) then
		safecall(getglobal(row.func), row.arg)
	else
		safecall(row.func, row.arg)
	end
end

local function formatShortTime(seconds)
	local hours = 0
	local minutes = 0
	if( seconds >= 3600 ) then
		hours = floor(seconds / 3600)
		seconds = mod(seconds, 3600)
	end

	if( seconds >= 60 ) then
		minutes = floor(seconds / 60)
		seconds = mod(seconds, 60)
	end
	
	if( seconds < 0 ) then
		seconds = 0
	end

	if( hours > 0 ) then
		return string.format("%d:%02d:%02d", hours, minutes, seconds)
	else
		return string.format("%02d:%02d", minutes, seconds)
	end
end

local function formatTime(seconds)
	if( SSOverlay.db.profile.shortTime ) then
		return formatShortTime(seconds)
	else
		local time = SecondsToTime(seconds)
		return time == "" and L["0 Sec"] or time
	end
end

local function onUpdate(self)
	local time = GetTime()
	local row = self.data
	
	if( row.type == "up" ) then
		row.seconds = row.seconds + (time - row.lastUpdate)
	elseif( row.type == "down" ) then
		row.seconds = row.seconds - (time - row.lastUpdate)
	end
	
	row.lastUpdate = time
	
	if( floor(row.seconds) <= 0 and row.type == "down" ) then
		SSOverlay:RemoveRow(row.id)
	else
		self.text:SetFormattedText(row.text, formatTime(row.seconds))
		
		-- Do a quick recheck incase the text got bigger in the update without something being removed/added
		if( longestText < (self.text:GetStringWidth() + 10) ) then
			longestText = self.text:GetStringWidth() + 20
			SSOverlay.frame:SetWidth(longestText)
		end
	end
end

-- Update display
local function sortOverlay(a, b)
	if( not a ) then
		return true
	elseif( not b ) then
		return false
	end
	
	if( a.sortID ~= b.sortID ) then
		return a.sortID < b.sortID
	end

	return a.addOrder < b.addOrder
end

function SSOverlay:FormatTime(seconds, skipSeconds)
	if( self.db.profile.shortTime ) then
		return formatShortTime(seconds)
	else
		return SecondsToTime(seconds, skipSeconds)
	end
end

function SSOverlay:UpdateCategoryText()
	-- Now add category texts as required
	for name, total in pairs(catCount) do
		if( ACTIVE_CATS > 1 and total > 0 ) then
			self:RegisterRow("catText", categories[name].id, name, categories[name].label, nil, nil, 1)
		else
			self:RemoveRow(categories[name].id)
		end
	end
end

function SSOverlay:UpdateOverlay()
	if( ACTIVE_ROWS == 0 ) then
		longestText = 0
		if( self.frame ) then
			self.frame:Hide()
		end
		return

	elseif( not self.frame ) then
		self:CreateFrame()
	end
	
	table.sort(timers, sortOverlay)
	
	local rowsUsed = 0
	for _, data in pairs(timers) do
		if( data.enabled ) then
			rowsUsed = rowsUsed + 1
			if( rowsUsed > MAX_ROWS ) then
				break
			end

			local row = self.rows[rowsUsed]

			-- Text rows just need static text no fancy stuff timers and elapsed rows actually need an OnUpdate
			if( data.type == "text" or data.type == "catText" ) then
				row.text:SetText(data.text)
				row:SetScript("OnUpdate", nil)
			elseif( data.type == "up" or data.type == "down" ) then
				row.text:SetFormattedText(data.text, formatTime(data.seconds))
				row:SetScript("OnUpdate", onUpdate)
			end

			if( data.color ) then
				row.text:SetTextColor(data.color.r, data.color.g, data.color.b)
			elseif( data.type == "catText" ) then
				row.text:SetTextColor(self.db.profile.categoryColor.r, self.db.profile.categoryColor.g, self.db.profile.categoryColor.b)
			else
				row.text:SetTextColor(self.db.profile.textColor.r, self.db.profile.textColor.g, self.db.profile.textColor.b)
			end

			row.data = data
			row:Show()
			
			-- This makes sure we always have the overlay width set correctly, without having it jump around on every little minor change
			if( longestText < (row.text:GetStringWidth() + 10) ) then
				longestText = row.text:GetStringWidth() + 20
			end
		end
	end

	-- Hide anything unused, and adjust the row width to match the overlay
	for id, row in pairs(self.rows) do
		if( id > rowsUsed ) then
			row.data = nil
			row:Hide()
		else
			row:SetWidth(longestText + 15)
		end
	end
	
	-- Resize
	self.frame:SetHeight(min(MAX_ROWS, rowsUsed) * (self.rows[1].text:GetHeight() + 2) + 9)
	self.frame:SetWidth(longestText)
	self.frame:Show()
end

-- Remove an entry by id or category
function SSOverlay:RemoveAll()
	ACTIVE_ROWS = 0
	ACTIVE_CATS = 0
	longestText = 0
	
	for _, data in pairs(timers) do
		data.enabled = nil
	end
	
	for cat in pairs(catCount) do
		catCount[cat] = nil
	end
	
	if( self.frame ) then
		self.frame:Hide()
	end
end

function SSOverlay:RemoveRow(id)
	for _, data in pairs(timers) do
		if( data.enabled and data.id == id ) then
			ACTIVE_ROWS = ACTIVE_ROWS - 1
			
			data.enabled = nil
			longestText = 0
			
			if( data.type ~= "catText" ) then
				catCount[data.category] = catCount[data.category] - 1
				if( catCount[data.category] <= 0 ) then
					ACTIVE_CATS = ACTIVE_CATS - 1
				end
				
				self:UpdateCategoryText()
			end

			
			self:UpdateOverlay()
			break
		end
	end
end

function SSOverlay:RemoveCategory(category)
	local updated
	for _, data in pairs(timers) do
		if( data.category == category and data.enabled ) then
			data.enabled = nil
			ACTIVE_ROWS = ACTIVE_ROWS - 1
			
			updated = true
		end
	end

	if( updated ) then
		longestText = 0

		ACTIVE_CATS = ACTIVE_CATS - 1

		self:UpdateCategoryText()
		self:UpdateOverlay()
	end
end

-- Adding new rows
function SSOverlay:RegisterText(id, category, text, color)
	self:RegisterRow("text", id, category, text, color, nil, 2)
end

function SSOverlay:RegisterTimer(id, category, text, seconds, color)
	self:RegisterRow("down", id, category, text, color, seconds, 3)
end

function SSOverlay:RegisterElapsed(id, category, text, seconds, color)
	self:RegisterRow("up", id, category, text, color, seconds, 4)
end

-- Generic register, only used internally
function SSOverlay:RegisterRow(type, id, category, text, color, seconds, priority)
	-- Check if we can grab a table
	local disabledRow, idRow
	for _, data in pairs(timers) do
		if( data.id == id ) then
			idRow = data
			break
		elseif( not data.enabled ) then
			disabledRow = data
		end
	end
	
	local row = idRow or disabled
	if( not row ) then
		row = {}
		table.insert(timers, row)

		ACTIVE_ROWS = ACTIVE_ROWS + 1
	end
	
	-- Set up the basic stuff
	row.enabled = true
	row.type = type
	row.id = id
	row.category = category
	row.text = text
	row.color = color
	row.category = category
	row.addOrder = row.addOrder or ACTIVE_ROWS
	row.sortID = categories[category].order + priority
	row.seconds = nil
	row.lastUpdate = nil
	
	-- Set start time and last update for timers
	if( type == "up" or type == "down" ) then
		row.seconds = seconds
		row.lastUpdate = GetTime()
	end

	-- Infinite recusion is bad
	if( row.type ~= "catText" ) then
		catCount[category] = (catCount[category] or 0 ) + 1
		
		if( catCount[category] == 1 ) then
			ACTIVE_CATS = ACTIVE_CATS + 1
		end
		
		self:UpdateCategoryText()
	end
	
	self:UpdateOverlay()
end

-- Associates something to run when we click on a row in the overlay
function SSOverlay:RegisterOnClick(id, handler, func, arg)
	local row
	for _, data in pairs(timers) do
		if( data.id == id and data.enabled ) then
			row = data
			break
		end
	end

	if( not row ) then
		return
	end
	
	if( type(handler) == "function" or type(handler) == "string" ) then
		row.func = handler
	elseif( type(handler) == "table" and type(func) == "string" ) then
		row.handler = handler
		row.func = func
	end
	
	row.arg = arg
end

-- Create container frame
function SSOverlay:CreateFrame()
	-- Setup the overlay frame
	self.frame = CreateFrame("Frame", nil, UIParent)
	self.frame:RegisterForDrag("LeftButton")
	self.frame:SetScale(self.db.profile.scale)
	self.frame:SetClampedToScreen(true)
	self.frame:SetMovable(true)
	self.frame:SetFrameStrata("BACKGROUND")
		
	self.frame:SetScript("OnDragStop", function(self)
		if( self.isMoving ) then
			self:StopMovingOrSizing()

			local scale = self:GetEffectiveScale()
			SSOverlay.db.profile.x = self:GetLeft() * scale
			
			if( not SSOverlay.db.profile.growUp ) then
				SSOverlay.db.profile.y = self:GetTop() * scale
			else
				SSOverlay.db.profile.y = self:GetBottom() * scale
			end
		end
	end)

	self.frame:SetScript("OnDragStart", function(self)
		if( not SSOverlay.db.profile.locked ) then
			self.isMoving = true
			self:StartMoving()
		end
	end)

	self.frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				tile = true,
				tileSize = 9,
				edgeSize = 9,
				insets = { left = 2, right = 2, top = 2, bottom = 2 }})	
				
	self:Reload()
end

-- Create a new row
local CREATED_ROWS = 0
function SSOverlay:CreateRow()
	CREATED_ROWS = CREATED_ROWS + 1

	local row = CreateFrame("Frame", nil, self.frame)
	row:SetScript("OnMouseUp", onClick)
	row:SetFrameStrata("LOW")
	row:SetHeight(13)
	row:SetWidth(250)
	
	if( not self.db.profile.locked ) then
		row:EnableMouse(false)
	else
		row:EnableMouse(not self.db.profile.noClick)
	end
	
	local text = row:CreateFontString(nil, "BACKGROUND")
	text:SetJustifyH("LEFT")
	text:SetFontObject(GameFontNormalSmall)
	text:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
	row.text = text

	if( CREATED_ROWS > 1 ) then
		row:SetPoint("TOPLEFT", self.rows[CREATED_ROWS - 1], "TOPLEFT", 0, -12)
	else
		row:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 5, -5)
	end
	
	-- Reposition it if we're growing up
	if( self.db.profile.growUp ) then
		local scale = self.frame:GetEffectiveScale()
		self.frame:ClearAllPoints()
		self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.profile.x / scale, self.db.profile.y / scale)
	end

	return row
end