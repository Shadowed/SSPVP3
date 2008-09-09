SSOverlay = SSPVP:NewModule("Overlay")

local L = SSPVPLocals

local CREATED_ROWS = 0
local MAX_ROWS = 20
local ADDED_ENTRIES = 0
local longestText = 0
local growUp
local resortRows

local rows = {}
local catCount = {}
local categories = {
	["faction"] = { label = L["Faction Balance"], order = 0 },
	["timer"] = { label = L["Timers"], order = 20 },
	["match"] = { label = L["Match Info"], order = 30 },
	["mine"] = { label = L["Mine Reinforcement"], order = 50 },
	["queue"] = { label = L["Battlefield Queue"], order = 60 },
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
	growUp = self.db.profile.growUp
end

function SSOverlay:Reload()
	if( not self.frame ) then
		return
	end
	
	self.frame:SetScale(self.db.profile.scale)
	self.frame:SetBackdropColor(self.db.profile.background.r, self.db.profile.background.g, self.db.profile.background.b, self.db.profile.opacity)
	self.frame:SetBackdropBorderColor(self.db.profile.border.r, self.db.profile.border.g, self.db.profile.border.b, self.db.profile.opacity)
	self:UpdateOverlay()
	
	-- If overlay is unlocked, enable the mouse. If they're locked then disable it
	if( not self.db.profile.locked ) then
		self.frame:EnableMouse(true)
	else
		self.frame:EnableMouse(false)
	end
	
	
	for i=1, CREATED_ROWS do
		-- If overlay is unlocked, disable mouse so we can move
		-- If it's locked, then enable it if we're not disabling it
		if( not self.db.profile.locked ) then
			self.rows[i]:EnableMouse(false)
		else
			self.rows[i]:EnableMouse(not self.db.profile.noClick)
		end
	end
end

local function onClick(self)
	-- So you won't accidentally click the overlay, make sure we have an on click too
	if( not IsModifierKeyDown() or not rows[self.dataID].func ) then
		return
	end
	
	-- Trigger it
	local row = rows[self.dataID]
	if( row.handler ) then
		row.handler[row.func](row.handler, unpack(row.args))
	elseif( type(row.func) == "string" ) then
		getglobal(row.func)(unpack(row.args))
	elseif( type(row.func) == "function" ) then
		row.func(unpack(row.args))
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
		return SecondsToTime(seconds)
	end
end

local function onUpdate(self)
	local time = GetTime()
	local row = rows[self.dataID]
	
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
		
		-- Do a quick recheck incase the text got bigger in the update without
		-- something being removed/added
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
	-- Figure out total unique categories we're showing
	local activeCats = 0
	for _, total in pairs(catCount) do
		if( total > 0 ) then
			activeCats = activeCats + 1
		end
	end
			
	-- Now add category texts as required
	for name, total in pairs(catCount) do
		if( activeCats > 1 and total > 0 ) then
			self:RegisterRow("catText", "cat" .. name, name, categories[name].label, nil, nil, 1)
		else
			self:RemoveRow("cat" .. name)
		end
	end
end

function SSOverlay:UpdateOverlay()
	local totalRows = #(rows)
	if( totalRows == 0 ) then
		longestText = 0
		
		if( self.frame ) then
			self.frame:Hide()

		end
		return
	end
	
	if( not self.frame ) then
		self:CreateFrame()
	end
	

	if( resortRows ) then
		table.sort(rows, sortOverlay)
		resortRows = nil
	end
	
	for id, data in pairs(rows) do
		if( id > MAX_ROWS ) then
			break
		end
		
		local row = self.rows[id]
		if( not row ) then
			row = self:CreateRow()
		end
		
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
		
		row.dataID = id
		row:Show()
		
		if( longestText < (row.text:GetStringWidth() + 10) ) then
			longestText = row.text:GetStringWidth() + 20
		end
	end
	
	-- Hide anything unused, and adjust the row width to match the overlay
	for i=1, CREATED_ROWS do
		if( i > totalRows ) then
			self.rows[i].dataID = nil
			self.rows[i]:Hide()
		else
			self.rows[i]:SetWidth(longestText + 15)
		end
	end
	
	-- Resize
	self.frame:SetHeight(min(MAX_ROWS, totalRows) * (self.rows[1].text:GetHeight() + 2) + 9)
	self.frame:SetWidth(longestText)
	self.frame:Show()
end

-- Remove an entry by id or category
function SSOverlay:RemoveAll()
	longestText = 0
	

	for i=#(rows), 1, -1 do
		table.remove(rows, i)
	end
	
	for cat in pairs(catCount) do
		catCount[cat] = nil
	end
	
	if( self.frame ) then
		for i=1, CREATED_ROWS do
			self.rows[i]:Hide()
		end
		
		self.frame:Hide()
	end
end

function SSOverlay:RemoveRow(id)
	for i=#(rows), 1, -1 do
		local row = rows[i]
		if( row and row.id == id ) then
			longestText = 0
			table.remove(rows, i)
			
			if( row.type ~= "catText" ) then
				catCount[row.category] = catCount[row.category] - 1
				self:UpdateCategoryText()
			end

			
			self:UpdateOverlay()
		end
	end
end

function SSOverlay:RemoveCategory(category)
	local updated
	for i=#(rows), 1, -1 do
		if( rows[i].category == category ) then
			table.remove(rows, i)
			updated = true
		end
	end
	
	if( updated ) then
		longestText = 0
		catCount[category] = nil
		
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
	local row
	local newRow
	-- Grab an existing entry if we haven't deleted them yet
	for _, data in pairs(rows) do
		if( data.id == id ) then
			row = data
			break
		end
	end
	
	if( not row ) then
		row = {}
		newRow = true
	end
	
	row.type = type
	row.id = id
	row.category = category
	row.text = text
	row.color = color
	row.category = category
	row.addOrder = row.addOrder or ADDED_ENTRIES
	row.sortID = categories[category].order + priority
	
	-- Set start time and last update for timers
	if( type == "up" or type == "down" ) then
		row.seconds = seconds
		row.lastUpdate = GetTime()
	else
		row.seconds = nil
		row.lastUpdate = nil
	end

	-- New row time
	if( newRow ) then
		ADDED_ENTRIES = ADDED_ENTRIES + 1
		resortRows = true
		table.insert(rows, row)
		
		-- Infinite recusion is bad
		if( row.type ~= "catText" ) then
			catCount[category] = (catCount[category] or 0 ) + 1
			self:UpdateCategoryText()
		end

	end
	
	self:UpdateOverlay()
end

-- Associates something to run when we click on a row in the overlay
local noArgs = {}
function SSOverlay:RegisterOnClick(id, handler, func, ...)
	local row
	for _, data in pairs(rows) do
		if( data.id == id ) then
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
	
	if( select("#", ...) > 0 ) then
		row.args = { ... }
	else
		row.args = noArgs
	end
end

-- Create container frame
function SSOverlay:CreateFrame()
	self.rows = {}

	-- Setup the overlay frame
	self.frame = CreateFrame("Frame", nil, UIParent)
	self.frame:RegisterForDrag("LeftButton")
	self.frame:SetScale(self.db.profile.scale)
	self.frame:SetClampedToScreen(true)
	self.frame:SetMovable(true)
	self.frame:SetFrameStrata("BACKGROUND")

	-- Locky, Clocky, Blocky, Tocky, Mocky
	if( not self.db.profile.locked ) then
		self.frame:EnableMouse(true)
	else
		self.frame:EnableMouse(false)
	end
		
	-- Position to saved area
	local scale = self.frame:GetEffectiveScale()
	if( not growUp ) then
		self.frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.profile.x / scale, self.db.profile.y / scale)
	else
		self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.profile.x / scale, self.db.profile.y / scale)
	end

	self.frame:SetScript("OnMouseUp", function(self)
		if( self.isMoving ) then
			self:StopMovingOrSizing()

			local scale = self:GetEffectiveScale()
			SSOverlay.db.profile.x = self:GetLeft() * scale
			
			if( not growUp ) then
				SSOverlay.db.profile.y = self:GetTop() * scale
			else
				SSOverlay.db.profile.y = self:GetBottom() * scale
			end
		end
	end)

	self.frame:SetScript("OnMouseDown", function(self)
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

	self.frame:SetBackdropColor(self.db.profile.background.r, self.db.profile.background.g, self.db.profile.background.b, self.db.profile.opacity)
	self.frame:SetBackdropBorderColor(self.db.profile.border.r, self.db.profile.border.g, self.db.profile.border.b, self.db.profile.opacity)
end

-- Create a new row
function SSOverlay:CreateRow()
	if( CREATED_ROWS >= MAX_ROWS or not self.frame ) then
		return
	end

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
	if( growUp ) then
		local scale = self.frame:GetEffectiveScale()
		self.frame:ClearAllPoints()
		self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.profile.x / scale, self.db.profile.y / scale)
	end

	self.rows[CREATED_ROWS] = row
	return row
end