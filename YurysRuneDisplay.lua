local YRDDetails = {
	Author = "Yury (EU-Turalyon)",
	Version = "1.4@project-version@",
	Last_Change = " @project-date-iso@"
}

local Arcs = {
	happy =    {0, -8, -4, 0,  4,  8},
	straight = {0,  0,  0, 0,  0,  0},
	sad =      {0,  8,  4, 0, -4, -8}
}

local txtColors = {
	e = "FF0000", -- error
	h = "00FFFF", -- highlight
	n = "00E000", -- normal
	y = "CC19FF"  -- yrd
}

local defaultSettings = {
	LOCKED = true,
	SCALE = 1,
	XCOORD = 100,
	YCOORD = -150,
	RELATIVE = "TOPLEFT",
	POINT = "TOPLEFT",
	NUMCD = "on",
	OOCA = 1,
	BLIZ = "off",
	ARC = "happy",
	CDCLR = "default"
}

function eclr(msg) return colorize(msg,"e") end
function hclr(msg) return colorize(msg,"h") end
function nclr(msg) return colorize(msg,"n") end
function yclr(msg) return colorize(msg,"y") end

function colorize(msg, color)
	return "|cFF"..txtColors[color]..msg.."|r"
end

function YurysRuneDisplay()
	-- Disable YRD if not a death knight --
	local _, class = UnitClass("player")

	if ( class ~= "DEATHKNIGHT" ) then
		YRD_Error("NO_DEATHKNIGHT", true)
		return
	end

	--  Register events --
	this:RegisterEvent("ADDON_LOADED")
	
	-- Register /yrd command --
	SlashCmdList["YRD"] = function(arg) YRD_SlashCmd(arg) end
	SLASH_YRD1 = "/yrd"
	
	-- Disable default RuneFrame --
	RuneFrame:Hide()
end

function YRD_SlashCmd(arg)
	-- If no option given, show help --
	if (arg == "") then
		YRD_ShowHelp()
		return
	end

	-- Process given option --
	arg = explode(" ", arg)
	if (arg[1] == "help") then
		YRD_ShowHelp()
	elseif (arg[1] == "scale") then
		if (# arg < 2) then
			YRD_Error("NO_SCALE")
		elseif (tonumber(arg[2]) >= 0.1 and tonumber(arg[2]) <= 3.5) then
			YRD_ScaleFrame(tonumber(arg[2]))
		else
			YRD_Error("WRONG_SCALE")
		end
	elseif (arg[1] == "ooca") then
		if (# arg < 2) then
			YRD_Error("NO_OOCA")
		elseif (tonumber(arg[2]) >= 0 and tonumber(arg[2]) <= 1) then
			YRD_SetOoca(tonumber(arg[2]))
		else
			YRD_Error("WRONG_OOCA")
		end
	elseif (arg[1] == "lock") then
		YRD_LockFrame()
	elseif (arg[1] == "unlock") then
		YRD_UnlockFrame()
	elseif (arg[1] == "reset") then
		YRD_ResetFrame()
	elseif (arg[1] == "about") then
		YRD_About()
	elseif (arg[1] == "numcd") then
		if (# arg < 2) then
			YRD_Error("NO_CD_OPTION")
		elseif (arg[2] == "on") then
			YRD_ShowNumCd()
		elseif (arg[2] == "off") then
			YRD_HideNumCd()
		else
			YRD_Error("WRONG_CD_OPTION")
		end
	elseif (arg[1] == "bliz") then
		if (# arg < 2) then
			YRD_Error("NO_BLIZ_OPTION")
		elseif (arg[2] == "on") then
			YRD_ShowBlizFrame()
		elseif (arg[2] == "off") then
			YRD_HideBlizFrame()
		else
			YRD_Error("WRONG_BLIZ_OPTION")
		end
	elseif (arg[1] == "cdclr") then
		if (# arg < 2) then
			YRD_Error("NO_CDCLR_OPTION")
		elseif (arg[2] == "rune" or arg[2] == "default") then
			YRD_SetCdClr(arg[2])
		else
			YRD_Error("WRONG_CDCLR_OPTION")
		end
	elseif (arg[1] == "arc") then
		if (# arg < 2) then
			YRD_Error("NO_ARC_OPTION")
		elseif (arg[2] == "happy" or arg[2] == "sad" or arg[2] == "straight") then
			YRD_SetArc(arg[2])
		else
			YRD_Error("WRONG_ARC_OPTION")
		end
	else
		YRD_Error("WRONG_OPTION")
	end
end

function YRD_Error(err, hide_usage)
	YRD_PrintMessage(eclr(L["Error"])..nclr(": "..L[err]))
	if (not hide_usage) then
		YRD_ShowUsage()
	end
end

function YRD_ShowHelp()
	YRD_ShowUsage()
	YRD_PrintMessage(hclr(" scale #")..nclr(": "..L["HELP_SCALE"].." (")..hclr(YRDSettings["SCALE"])..nclr(")"))
	YRD_PrintMessage(hclr(" ooca #") ..nclr(": "..L["HELP_OOCA"].." (")..hclr(YRDSettings["OOCA"])..nclr(")"))
	YRD_PrintMessage(hclr(" lock")   ..nclr(": "..L["HELP_LOCK"]))
	YRD_PrintMessage(hclr(" unlock") ..nclr(": "..L["HELP_UNLOCK"]))
	YRD_PrintMessage(hclr(" reset")  ..nclr(": "..L["HELP_RESET"]))
	YRD_PrintMessage(hclr(" help")   ..nclr(": "..L["HELP_HELP"]))
	YRD_PrintMessage(hclr(" about")  ..nclr(": "..L["HELP_ABOUT"]))
	YRD_PrintMessage(hclr(" numcd _")..nclr(" (")..hclr(YRDSettings["NUMCD"])..nclr("): "..L["HELP_NUMCD"]))
	YRD_PrintMessage(hclr(" cdclr _")..nclr(" (")..hclr(YRDSettings["CDCLR"])..nclr("): "..L["HELP_CDCLR"]))
	YRD_PrintMessage(hclr(" bliz _") ..nclr(" (")..hclr(YRDSettings["BLIZ"]) ..nclr("): "..L["HELP_BLIZ"]))
	YRD_PrintMessage(hclr(" arc _")  ..nclr(" (")..hclr(YRDSettings["ARC"])  ..nclr("): "..L["HELP_ARC"]))
end

function YRD_About()
	YRD_PrintMessage(L["About"]		.." Yury's RuneDisplay:")
	YRD_PrintMessage(L["Author"]		..": "..YRDDetails["Author"])
	YRD_PrintMessage(L["Version"]	..": "..YRDDetails["Version"])
	YRD_PrintMessage(L["Last Change"]..": "..YRDDetails["Last_Change"])
end

function YRD_PrintMessage(msg)
	DEFAULT_CHAT_FRAME:AddMessage(yclr("YRD")..nclr(": "..msg))
end

function YRD_ShowUsage()
	YRD_PrintMessage(L["Usage"]..": "..hclr("/yrd")..nclr(" {scale # | lock | unlock | reset | help | about | numcd ")..hclr("{on | off}")..nclr(" | cdclr ")..hclr("{default | rune}")..nclr(" | bliz ")..hclr("{on | off}")..nclr(" | arc ")..hclr("{happy | sad | straight}")..nclr(" | ooca #}"))
end

function YRD_SetOoca(alpha)
	if (alpha == nil) then alpha = 1 end
	YRDSettings["OOCA"] = alpha
	if (not UnitAffectingCombat("player")) then
		YRDRuneFrame:SetAlpha(alpha)
	end
	YRD_PrintMessage(L["MSG_OOCA"].." "..hclr(alpha))
end

function YRD_SetArc(arc)
	if (arc == nil) then
		arc = "happy"
		YRDSettings["ARC"] = arc
	end
	YRDSettings["ARC"] = arc
	local array = Arcs[arc]
	for i = 1, 6 do
		local Rune = getglobal("YRDRuneButtonIndividual"..i)
		local p,f,r,x,_ = Rune:GetPoint()
		Rune:SetPoint(p,f,r,x,array[i])
	end
	YRD_PrintMessage(L["MSG_ARC"].." "..hclr(arc))
end

function YRD_UnlockFrame()
	if (not YRDSettings["LOCKED"]) then return end
	YRDSettings["LOCKED"] = false
	for i = 1, 6 do
		local Rune = getglobal("YRDRuneButtonIndividual"..i)
		Rune:RegisterForDrag("LeftButton")
		Rune:SetScript("OnDragStart", YRD_Drag)
		Rune:SetScript("OnDragStop", YRD_Drop)
	end
	YRD_PrintMessage(L["MSG_FRAME"]..hclr(" unlocked"))
end

function YRD_ShowBlizFrame()
	YRDSettings["BLIZ"] = "on"
	RuneFrame:Show()
	YRD_PrintMessage(L["MSG_BLIZ"]..hclr(" on"))
end

function YRD_HideBlizFrame()
	if (YRDSettings["BLIZ"] == "off") then return end
	YRDSettings["BLIZ"] = "off"
	RuneFrame:Hide()
	YRD_PrintMessage(L["MSG_BLIZ"]..hclr(" off"))
end

function YRD_SetCdClr(clr)
	if (YRDSettings["CDCLR"] == clr) then return end
	YRDSettings["CDCLR"] = clr
	YRD_PrintMessage(L["MSG_CDCLR"].." "..hclr(clr))
end

function YRD_ShowNumCd()
	if (YRDSettings["NUMCD"] == "on") then return end
	YRDSettings["NUMCD"] = "on"
	YRD_PrintMessage(L["MSG_NUMCD"]..hclr(" on"))
end

function YRD_HideNumCd()
	if (YRDSettings["NUMCD"] == "off") then return end
	YRDSettings["NUMCD"] = "off"
	for i = 1, 6 do
		local rune = getglobal("YRDRuneButtonIndividual"..i)
		rune.text:SetText("")
	end
	YRD_PrintMessage(L["MSG_NUMCD"]..hclr(" off"))
end

function YRD_Drag()
	YRDRuneFrame:StartMoving()
end

function YRD_Drop()
	YRDRuneFrame:StopMovingOrSizing()
	YRDSettings["POINT"], _, YRDSettings["RELATIVE"], YRDSettings["XCOORD"], YRDSettings["YCOORD"] = YRDRuneFrame:GetPoint()
end

function YRD_LockFrame()
	if (YRDSettings["LOCKED"]) then return end
	YRDSettings["LOCKED"] = true

	for i = 1, 6 do
		local Rune = getglobal("YRDRuneButtonIndividual"..i)
		-- Registering nothing effectively disables dragging --
		Rune:RegisterForDrag()
	end
	YRD_PrintMessage(L["MSG_FRAME"]..hclr(" locked"))
end

function YRD_ScaleFrame(Scale)
	YRDSettings["SCALE"] = Scale
	YRDRuneFrame:SetScale(Scale)
	YRD_PrintMessage(L["MSG_SCALE"].." "..hclr(Scale))
end

function YRD_OnEvent(self, event, ...)
   if ( event == "ADDON_LOADED" ) then
		local addon = select(1, ...)
		if ( addon == "YurysRuneDisplay" ) then
			YRD_Init()
			YRD_PrintMessage(L["MSG_LOADED"])
		end
	end
end

function YRD_ResetFrame()
	-- Initial values --
	YRD_InitVals()
	
	-- Lock the frame --
	YRD_LockFrame()
	
	-- Re-initialise --
	YRD_ScaleFrame(YRDSettings["SCALE"])
	YRD_SetOoca(YRDSettings["OOCA"])
	YRDRuneFrame:SetPoint(YRDSettings["POINT"], "UIParent", YRDSettings["RELATIVE"], YRDSettings["XCOORD"], YRDSettings["YCOORD"])
	YRD_ShowNumCd()
	YRD_HideBlizFrame()
	YRD_SetArc(YRDSettings["ARC"])
	YRD_PrintMessage(L["MSG_RESET"])
end

function YRD_InitVals()
	YRDSettings = defaultSettings
end

function YRD_Init()
	if (YRDSettings == nil) then
		-- There are no settings yet --
		YRD_InitVals()
	end

	--  Apply settings --
	YRD_ScaleFrame(YRDSettings["SCALE"])
	YRD_SetOoca(YRDSettings["OOCA"])
	YRDRuneFrame:SetMovable()
	YRDRuneFrame:SetPoint(YRDSettings["POINT"], "UIParent", YRDSettings["RELATIVE"], YRDSettings["XCOORD"], YRDSettings["YCOORD"])
	if (YRDSettings["LOCKED"] == false) then
		YRD_UnlockFrame()
	end
	if (YRDSettings["NUMCD"] == "off") then
		YRD_HideNumCd()
	end
	if (YRDSettings["BLIZ"] == "on") then
		YRD_ShowBlizFrame()
	end
	if (YRDSettings["ARC"] == "sad" or YRDSettings["ARC"] == "straight") then
		YRD_SetArc(YRDSettings["ARC"])
	end
	if (YRDSettings["CDCLR"] == nil) then
		YRD_SetCdClr(defaultSettings["CDCLR"])
	end
end

-- Shamelessly copied from http://luanet.net/lua/function/explode --
function explode ( seperator, str ) 
 	local pos, arr = 0, {}
	for st, sp in function() return string.find( str, seperator, pos, true ) end do -- for each divider found
		table.insert( arr, string.sub( str, pos, st-1 ) ) -- Attach chars left of current divider
		pos = sp + 1 -- Jump past current divider
	end
	table.insert( arr, string.sub( str, pos ) ) -- Attach chars right of last divider
	return arr
end