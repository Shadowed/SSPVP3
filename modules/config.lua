local Config = SSPVP:NewModule("Config")

local L = SSPVPLocals

local registered, options, config, dialog

-- GUI
local function set(info, value)
	local cat = info[#(info) - 1]
	local key = info[#(info)]
	if( info.attribute ) then
		if( SSPVP.modules[info.attribute].db[cat] and SSPVP.modules[info.attribute].db[cat][key] ) then
			SSPVP.modules[info.attribute].db[cat][key] = value
		else
			SSPVP.modules[info.attribute].db[key] = value
		end
		return
	end
	
	SSPVP.db.profile[cat][key] = value
end

local function get(info)
	local cat = info[#(info) - 1]
	local key = info[#(info)]
	if( info.attribute ) then
		
		if( SSPVP.modules[info.attribute].db[cat] and SSPVP.modules[info.attribute].db[cat][key] ) then
			return SSPVP.modules[info.attribute].db[cat][key]
		end
		
		return SSPVP.modules[info.attribute].db[key]
	end

	return SSPVP.db.profile[cat][key]
end

-- Set/Get colors
local function setColor(info, r, g, b)
	set(info, {r = r, g = g, b = b})
end

local function getColor(info)
	local value = get(info)
	if( type(value) == "table" ) then
		return value.r, value.g, value.b
	end
	
	return value
end


-- FLAG OPTIONS
local function createFlagOptions(text, bg)
	return {
		order = 1,
		type = "group",
		name = text,
		get = get,
		set = set,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["Show flag carrier"],
				width = "full",
				attribute = "Flag",
			},
			respawn = {
				order = 2,
				type = "toggle",
				name = L["Show flag respawn time on overlay"],
				width = "full",
				attribute = "Flag",
			},
			capture = {
				order = 3,
				type = "toggle",
				name = L["Show flag capture times on overlay"],
				width = "full",
				attribute = "Flag",
			},
			color = {
				order = 4,
				type = "toggle",
				name = L["Color carrier name by class"],
				width = "full",
				attribute = "Flag",
			},
			health = {
				order = 5,
				type = "toggle",
				name = L["Show carrier health when available"],
				width = "full",
				attribute = "Flag",
			},
			macro = {
				order = 6,
				type = "input",
				multiline = true,
				name = L["Text to execute when clicking the carrier button"],
				width = "full",
				attribute = "Flag",
			},
		},
	}
end

function loadOptions()
	-- If options weren't loaded yet, then do so now
	SSPVP3.options = {
		type = "group",
		name = "SSPVP3",
		args = {}
	}
	
	--[[ FLAGS ]]--
	SSPVP3.options.args.flags = {
		type = "group",
		order = 1,
		name = L["Flags"],
		get = get,
		set = set,
		args = {
			wsg = createFlagOptions(L["Warsong Gulch"], "wsg"),
			eots = createFlagOptions(L["Eye of the Storm"], "eots"),
		},
	}
	
--[[
		{ group = L["General"], type = "groupOrder", order = 1 },
		{ order = 1, group = L["General"], text = L["Auto append server name while in battlefields for whispers"], help = L["Automatically append \"-server\" to peoples names when you whisper them, if multiple people are found to match the same name then it won't add the server."], type = "check", var = {"Battlefield", "whispers"}},
 		
		{ group = L["Scoreboard"], type = "groupOrder", order = 2 },
 		{ order = 1, group = L["Scoreboard"], text = L["Color player name by class"], type = "check", var = {"Score", "color"}},
 		{ order = 2, group = L["Scoreboard"], text = L["Hide class icon next to names"], type = "check", var = {"Score", "icon"}},
 		{ order = 3, group = L["Scoreboard"], text = L["Show player levels next to name"], type = "check", var = {"Score", "level"}},
		
		{ group = L["Death"], type = "groupOrder", order = 3 },
		{ order = 1, group = L["Death"], text = L["Release from corpse when inside an active battleground"], type = "check", var = {"Battlefield", "release"}},
 		{ order = 2, group = L["Death"], text = L["Automatically use soul stone, if any on death"], type = "check", var = {"Battlefield", "soulstone"}},
]]

	--[[ OVERLAY ]]--
	SSPVP3.options.args.overlay = {
		type = "group",
		order = 1,
		name = L["Overlay"],
		get = get,
		set = set,
		handler = Overlay,
		args = {
			growUp = {
				order = 1,
				type = "toggle",
				name = L["Grow display up"],
				width = "full",
				attribute = "Overlay",
			},
			noClick = {
				order = 2,
				type = "toggle",
				name = L["Disable overlay clicking"],
				width = "full",
				attribute = "Overlay",
			},
			shortTime = {
				order = 3,
				type = "toggle",
				name = L["Use HH:MM:SS short time format"],
				width = "full",
				attribute = "Overlay",
			},
			frame = {
				type = "group",
				order = 4,
				inline = true,
				name = L["Frame"],
				args = {
					locked = {
						order = 1,
						type = "toggle",
						name = L["Lock overlay"],
						width = "full",
						attribute = "Overlay",
					},
					opacity = {
						order = 2,
						type = "range",
						name = L["Background opacity"],
						min = 0, max = 1.0, step = 0.01,
						attribute = "Overlay",
					},
					scale = {
						order = 2,
						type = "range",
						name = L["Scale"],
						min = 0.1, max = 2.0, step = 0.01,
						attribute = "Overlay",
					},
				},
			},
			color = {
				type = "group",
				order = 5,
				inline = true,
				name = L["Color"],
				set = setColor,
				get = getColor,
				args = {
					background = {
						order = 1,
						type = "color",
						name = L["Background color"],
						attribute = "Overlay",
					},
					border = {
						order = 1,
						type = "color",
						name = L["Border color"],
						attribute = "Overlay",
					},
					textColor = {
						order = 1,
						type = "color",
						name = L["Text color"],
						attribute = "Overlay",
					},
					categoryColor = {
						order = 1,
						type = "color",
						name = L["Category text color"],
						attribute = "Overlay",
					},
				},
			},
		},
	}
end

function Config:Open()
	if( not config and not dialog ) then
		config = LibStub("AceConfig-3.0")
		dialog = LibStub("AceConfigDialog-3.0")

		loadOptions()

		config:RegisterOptionsTable("SSPVP3", SSPVP3.options)
		dialog:SetDefaultSize("SSPVP3", 625, 575)
	end

	dialog:Open("SSPVP3")
end