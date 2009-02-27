local YRDDetails = {
	Author = "Yury (EU-Turalyon)",
	Version = "1.4",
	Last_Change = "26 February 2009"
}

local Errors = {
	NO_DEATHKNIGHT = "Not a Death Knight, Yury's RuneDisplay disabled.",
	WRONG_SCALE = "Scale not in range 0.1 - 3.5",
	NO_SCALE = "No scale given",
	WRONG_OOCA = "Alpha not in range 0 - 1",
	NO_OOCA = "No alpha given",
	WRONG_OPTION = "Unknown option",
	NO_CD_OPTION = "No numcd option given",
	WRONG_CD_OPTION = "numcd option must be either 'on' or 'off'",
	NO_BLIZ_OPTION = "No bliz option given",
	WRONG_BLIZ_OPTION = "bliz option must be either 'on' or 'off'",
	NO_CDCLR_OPTION = "No cdclr option given",
	WRONG_CDCLR_OPTION = "cdclr option must be either 'default' or 'rune'",
	NO_ARC_OPTION = "No arc option given",
	WRONG_ARC_OPTION = "arc option must be 'happy', 'sad' or 'straight'"
}

local Arcs = {
	happy =    {0, -8, -4, 0,  4,  8},
	straight = {0,  0,  0, 0,  0,  0},
	sad =      {0,  8,  4, 0, -4, -8}
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
};

function YurysRuneDisplay()
	-- Disable YRD if not a death knight.
	local _, class = UnitClass("player");

	if ( class ~= "DEATHKNIGHT" ) then
		YRD_Error("NO_DEATHKNIGHT", true);
		return;
	end

	--  Register events --
	this:RegisterEvent("ADDON_LOADED");
	
	-- Register /yrd command --
	SlashCmdList["YRD"] = function(arg) YRD_SlashCmd(arg); end;
	SLASH_YRD1 = "/yrd";
	
	-- Disable default RuneFrame --
	RuneFrame:Hide();
end

function YRD_SlashCmd(arg)
	-- If no option given, show help --
	if (arg == "") then
		YRD_ShowHelp();
		return;
	end

	-- Process given option --
	arg = explode(" ", arg);
	if (arg[1] == "help") then
		YRD_ShowHelp();
	elseif (arg[1] == "scale") then
		if (# arg < 2) then
			YRD_Error("NO_SCALE");
		elseif (tonumber(arg[2]) >= 0.1 and tonumber(arg[2]) <= 3.5) then
			YRD_ScaleFrame(tonumber(arg[2]));
		else
			YRD_Error("WRONG_SCALE");
		end
	elseif (arg[1] == "ooca") then
		if (# arg < 2) then
			YRD_Error("NO_OOCA");
		elseif (tonumber(arg[2]) >= 0 and tonumber(arg[2]) <= 1) then
			YRD_SetOoca(tonumber(arg[2]));
		else
			YRD_Error("WRONG_OOCA");
		end
	elseif (arg[1] == "lock") then
		YRD_LockFrame();
	elseif (arg[1] == "unlock") then
		YRD_UnlockFrame();
	elseif (arg[1] == "reset") then
		YRD_ResetFrame();
	elseif (arg[1] == "about") then
		YRD_About();
	elseif (arg[1] == "numcd") then
		if (# arg < 2) then
			YRD_Error("NO_CD_OPTION");
		elseif (arg[2] == "on") then
			YRD_ShowNumCd();
		elseif (arg[2] == "off") then
			YRD_HideNumCd();
		else
			YRD_Error("WRONG_CD_OPTION");
		end
	elseif (arg[1] == "bliz") then
		if (# arg < 2) then
			YRD_Error("NO_BLIZ_OPTION");
		elseif (arg[2] == "on") then
			YRD_ShowBlizFrame();
		elseif (arg[2] == "off") then
			YRD_HideBlizFrame();
		else
			YRD_Error("WRONG_BLIZ_OPTION");
		end
	elseif (arg[1] == "cdclr") then
		if (# arg < 2) then
			YRD_Error("NO_CDCLR_OPTION");
		elseif (arg[2] == "rune" or arg[2] == "default") then
			YRD_SetCdClr(arg[2]);
		else
			YRD_Error("WRONG_CDCLR_OPTION");
		end
	elseif (arg[1] == "arc") then
		if (# arg < 2) then
			YRD_Error("NO_ARC_OPTION");
		elseif (arg[2] == "happy" or arg[2] == "sad" or arg[2] == "straight") then
			YRD_SetArc(arg[2]);
		else
			YRD_Error("WRONG_ARC_OPTION");
		end
	else
		YRD_Error("WRONG_OPTION", false, arg[1]);
	end
end

function YRD_Error(err, hide_usage, option)
	if (option) then
		Errors["WRONG_OPTION"] = "Unknown option: "..option;
	end
	YRD_PrintMessage("|r|cFFFF0000Error|r|cFF00E000: " .. Errors[err]);
	if (not hide_usage) then
		YRD_ShowUsage();
	end
end

function YRD_ShowHelp()
	YRD_ShowUsage();
	YRD_PrintMessage(" |r|cFF00FFFFscale #|r|cFF00E000: scales the frame, range 0.1 to 3.5 (|r|cFF00FFFF"..YRDSettings["SCALE"].."|r|cFF00E000)");
	YRD_PrintMessage(" |r|cFF00FFFFlock|r|cFF00E000: locks the frame, preventing movement");
	YRD_PrintMessage(" |r|cFF00FFFFunlock|r|cFF00E000: unlocks the frame, click to drag");
	YRD_PrintMessage(" |r|cFF00FFFFreset|r|cFF00E000: resets the frame to default scale/position");
	YRD_PrintMessage(" |r|cFF00FFFFhelp|r|cFF00E000: displays this help");
	YRD_PrintMessage(" |r|cFF00FFFFabout|r|cFF00E000: shows info about this addon");
	YRD_PrintMessage(" |r|cFF00FFFFnumcd _|r|cFF00E000 (|r|cFF00FFFF"..YRDSettings["NUMCD"].."|r|cFF00E000): sets numerical cooldown on or off");
	YRD_PrintMessage(" |r|cFF00FFFFcdclr _|r|cFF00E000 (|r|cFF00FFFF"..YRDSettings["CDCLR"].."|r|cFF00E000): sets the cooldown color to default (yellow/red) or rune (the color of the rune");
	YRD_PrintMessage(" |r|cFF00FFFFbliz _|r|cFF00E000 (|r|cFF00FFFF"..YRDSettings["BLIZ"].."|r|cFF00E000): sets blizzard default frame on or off");
	YRD_PrintMessage(" |r|cFF00FFFFarc _|r|cFF00E000 (|r|cFF00FFFF"..YRDSettings["ARC"].."|r|cFF00E000): sets the arc happy/sad/straight)");
	YRD_PrintMessage(" |r|cFF00FFFFooca #|r|cFF00E000: sets the OOC-Alphavalue of the frame, range 0 to 1 (|r|cFF00FFFF"..YRDSettings["OOCA"].."|r|cFF00E000)");
end

function YRD_About()
	YRD_PrintMessage("About Yury's RuneDisplay:");
	YRD_PrintMessage("Author: "..YRDDetails["Author"]);
	YRD_PrintMessage("Version: "..YRDDetails["Version"]);
	YRD_PrintMessage("Last Change: "..YRDDetails["Last_Change"]);
end

function YRD_PrintMessage(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFFCC19FFYRD|r|cFF00E000: " .. msg.."|r");
end

function YRD_ShowUsage()
	YRD_PrintMessage("Usage: |r|cFF00FFFF/yrd|r|cFF00E000 {|r|cFF00FFFFscale #|r|cFF00E000 | |r|cFF00FFFFlock|r|cFF00E000 | |r|cFF00FFFFunlock|r|cFF00E000 | |r|cFF00FFFFreset|r|cFF00E000 | |r|cFF00FFFFhelp|r|cFF00E000 | |r|cFF00FFFFabout|r|cFF00E000 | |r|cFF00FFFFnumcd {on | off} |r|cFF00E000 | |r|cFF00FFFFcdclr {default | rune} |r|cFF00E000 | |r|cFF00FFFFbliz {on | off} |r|cFF00E000 | |r|cFF00FFFFarc {happy | sad | straight} |r|cFF00E000 | |r|cFF00FFFFooca #|r|cFF00E000}");
end

function YRD_SetOoca(alpha)
	if (alpha == nil) then alpha = 1 end;
	YRDSettings["OOCA"] = alpha;
	if (not UnitAffectingCombat("player")) then
		YRDRuneFrame:SetAlpha(alpha);
	end
	YRD_PrintMessage("OOC-Alphavalue set to |r|cFF00FFFF"..alpha.."|r");
end

function YRD_SetArc(arc)
	if (arc == nil) then
		arc = "happy";
		YRDSettings["ARC"] = arc;
	end
	YRDSettings["ARC"] = arc;
	local array = Arcs[arc];
	for i = 1, 6 do
		local Rune = getglobal("YRDRuneButtonIndividual"..i);
		local p,f,r,x,_ = Rune:GetPoint();
		Rune:SetPoint(p,f,r,x,array[i]);
	end
	YRD_PrintMessage("Arc is set to |r|cFF00FFFF"..arc.."|r");
end

function YRD_UnlockFrame()
	if (not YRDSettings["LOCKED"]) then return end;
	YRDSettings["LOCKED"] = false;
	for i = 1, 6 do
		local Rune = getglobal("YRDRuneButtonIndividual"..i);
		Rune:RegisterForDrag("LeftButton");
		Rune:SetScript("OnDragStart", YRD_Drag);
		Rune:SetScript("OnDragStop", YRD_Drop);
	end
	YRD_PrintMessage("Frame is now |r|cFF00FFFFunlocked|r");
end

function YRD_ShowBlizFrame()
	YRDSettings["BLIZ"] = "on";
	RuneFrame:Show();
	YRD_PrintMessage("Blizzard Frame is now |r|cFF00FFFFon|r");
end

function YRD_HideBlizFrame()
	if (YRDSettings["BLIZ"] == "off") then return end;
	YRDSettings["BLIZ"] = "off";
	RuneFrame:Hide();
	YRD_PrintMessage("Blizzard Frame is now |r|cFF00FFFFoff|r");
end

function YRD_SetCdClr(clr)
	if (YRDSettings["CDCLR"] == clr) then return end;
	YRDSettings["CDCLR"] = clr;
	YRD_PrintMessage("Cooldown color is now |r|cFF00FFFF"..clr.."|r");
end

function YRD_ShowNumCd()
	if (YRDSettings["NUMCD"] == "on") then return end;
	YRDSettings["NUMCD"] = "on";
	YRD_PrintMessage("Numerical cooldown is now |r|cFF00FFFFon|r");
end

function YRD_HideNumCd()
	if (YRDSettings["NUMCD"] == "off") then return end;
	YRDSettings["NUMCD"] = "off";
	for i = 1, 6 do
		local rune = getglobal("YRDRuneButtonIndividual"..i);
		rune.text:SetText("");
	end
	YRD_PrintMessage("Numerical cooldown is now |r|cFF00FFFFoff|r");
end

function YRD_Drag()
	YRDRuneFrame:StartMoving();
end

function YRD_Drop()
	YRDRuneFrame:StopMovingOrSizing();
	YRDSettings["POINT"], _, YRDSettings["RELATIVE"], YRDSettings["XCOORD"], YRDSettings["YCOORD"] = YRDRuneFrame:GetPoint()
end

function YRD_LockFrame()
	if (YRDSettings["LOCKED"]) then return end;
	YRDSettings["LOCKED"] = true;

	for i = 1, 6 do
		local Rune = getglobal("YRDRuneButtonIndividual"..i);
		-- Registering nothing effectively disables dragging --
		Rune:RegisterForDrag();
	end
	YRD_PrintMessage("Frame is now |r|cFF00FFFFlocked|r");
end

function YRD_ScaleFrame(Scale)
	YRDSettings["SCALE"] = Scale;
	YRDRuneFrame:SetScale(Scale);
	YRD_PrintMessage("Scale set to |r|cFF00FFFF"..Scale.."|r");
end

function YRD_OnEvent(self, event, ...)
   if ( event == "ADDON_LOADED" ) then
		local addon = select(1, ...);
		if ( addon == "YurysRuneDisplay" ) then
			YRD_Init();
			if ( YRDSettings["LOCKED"] ) then
				YRD_PrintMessage("Frame is now |r|cFF00FFFFlocked|r");
			end
			if ( YRDSettings["NUMCD"] ~= "off" ) then
				YRD_PrintMessage("Numerical cooldown is |r|cFF00FFFFon|r");
			end
			if ( YRDSettings["BLIZ"] ~= "on" ) then
				YRD_PrintMessage("Blizzard Frame is |r|cFF00FFFFoff|r");
			end
			YRD_PrintMessage("Yury's RuneDisplay loaded ('/yrd' for help)...");
		end
	end
end

function YRD_ResetFrame()
	-- Initial values --
	YRD_InitVals();
	
	-- Lock the frame --
	YRD_LockFrame();
	
	-- Re-initialise --
	YRD_ScaleFrame(YRDSettings["SCALE"]);
	YRD_SetOoca(YRDSettings["OOCA"]);
	YRDRuneFrame:SetPoint(YRDSettings["POINT"], "UIParent", YRDSettings["RELATIVE"], YRDSettings["XCOORD"], YRDSettings["YCOORD"]);
	YRD_ShowNumCd();
	YRD_HideBlizFrame();
	YRD_SetArc(YRDSettings["ARC"]);
	YRD_PrintMessage("Reset to defaults");
end

function YRD_InitVals()
	YRDSettings = defaultSettings;
end

function YRD_Init()
	if (YRDSettings == nil) then
		-- There are no settings yet --
		YRD_InitVals();
	end

	--  Apply settings --
	YRD_ScaleFrame(YRDSettings["SCALE"]);
	YRD_SetOoca(YRDSettings["OOCA"]);
	YRDRuneFrame:SetMovable();
	YRDRuneFrame:SetPoint(YRDSettings["POINT"], "UIParent", YRDSettings["RELATIVE"], YRDSettings["XCOORD"], YRDSettings["YCOORD"]);
	if (YRDSettings["LOCKED"] == false) then
		YRD_UnlockFrame();
	end
	if (YRDSettings["NUMCD"] == "off") then
		YRD_HideNumCd();
	end
	if (YRDSettings["BLIZ"] == "on") then
		YRD_ShowBlizFrame();
	end
	if (YRDSettings["ARC"] == "sad" or YRDSettings["ARC"] == "straight") then
		YRD_SetArc(YRDSettings["ARC"]);
	end
	if (YRDSettings["CDCLR"] == nil) then
		YRD_SetCdClr(defaultSettings["CDCLR"]);
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