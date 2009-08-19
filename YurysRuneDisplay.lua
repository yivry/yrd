-- only load this addon on a Death Knight --
if ( select(2, UnitClass("player")) == "DEATHKNIGHT" ) then
	YurysRuneDisplay = LibStub("AceAddon-3.0"):NewAddon("YurysRuneDisplay", "AceEvent-3.0")
	local L = LibStub("AceLocale-3.0"):GetLocale("YurysRuneDisplay", true)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("YurysRuneDisplay", YurysRuneDisplay:GetOptionsTable(), {L["yrd"]})
	-- Fix some bliz thing --
	local FirstTime = true
end

-- General Handlers --
function YurysRuneDisplay:OnDisable()
	-- No need to UnRegister events, AceEvent does it for us --
	-- Hide our runeframe --
	YRDRuneFrame:Hide()
	-- Turn on Blizzard's runeframe --
	RuneFrame:Show() 
end

function YurysRuneDisplay:OnDragStart()
	YRDRuneFrame:StartMoving()
end

function YurysRuneDisplay:OnDragStop()
	YRDRuneFrame:StopMovingOrSizing()
	local pos = {}
	pos["POINT"], _, pos["RELATIVE"], pos["XCOORD"], pos["YCOORD"] = YRDRuneFrame:GetPoint()
	YurysRuneDisplay:SetPosition(pos)
end

function YurysRuneDisplay:OnEnable()
	-- Register events --
	YurysRuneDisplay:RegisterEvent("PLAYER_ENTERING_WORLD")
	YurysRuneDisplay:RegisterEvent("PLAYER_REGEN_ENABLED")
	YurysRuneDisplay:RegisterEvent("PLAYER_REGEN_DISABLED")
	YurysRuneDisplay:RegisterEvent("RUNE_POWER_UPDATE")
	YurysRuneDisplay:RegisterEvent("RUNE_TYPE_UPDATE")
	-- Apply settings that might have been disabled --
	YurysRuneDisplay:ApplyBliz()
	-- Turn on our frame, if needed --
	if (YurysRuneDisplay:GetOoca() > 0) then
		YRDRuneFrame:Show()
	end
	print(L["Yury's RuneDisplay enabled. For options: /"]..L["yrd"])
end

function YurysRuneDisplay:OnFrameFade(self)
	local ready = true
	for rune in next, self.runes do
		_, _, isReady = GetRuneCooldown(rune)
		if (not isReady) then
			ready = false
		end
	end
	if (ready) then
		YurysRuneDisplay:ApplyOoca()
	end
end

function YurysRuneDisplay:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("YurysRuneDisplayDB", YurysRuneDisplay:GetDefaults())
	YurysRuneDisplay:ApplySettings()
end

-- Event Handlers --
function YurysRuneDisplay:PLAYER_ENTERING_WORLD()
	if (FirstTime) then
		RuneFrame_FixRunes(YRDRuneFrame)
		FirstTime = false
	end
	for rune in next, YRDRuneFrame.runes do
		RuneButton_Update(YRDRuneFrame.runes[rune], rune, true)
	end
end

function YurysRuneDisplay:PLAYER_REGEN_ENABLED()
	if (YurysRuneDisplay:GetOoca() < 1) then
		YRDRuneFrame:SetScript("OnUpdate", YurysRuneDisplay.OnFrameFade)
	end
end

function YurysRuneDisplay:PLAYER_REGEN_DISABLED()
	YRDRuneFrame:SetAlpha(1)
	YRDRuneFrame:Show()
end

function YurysRuneDisplay:RUNE_POWER_UPDATE(event, rune, usable)
	local r = YRDRuneFrame.runes
	if ( not usable and rune and r[rune] ) then
		r[rune]:SetScript("OnUpdate", YRDRuneButton_OnUpdate)
	elseif ( usable and rune and r[rune] ) then
		r[rune].shine:SetVertexColor(1, 1, 1)
		RuneButton_ShineFadeIn(r[rune].shine)
	end
end

function YurysRuneDisplay:RUNE_TYPE_UPDATE(event, rune)
	if (rune) then
		RuneButton_Update(YRDRuneFrame.runes[rune], rune);
	end
end

-- Applyers --
function YurysRuneDisplay:ApplyArc()
	local arcs = { 
		happy =    {0, -8, -4, 0,  4,  8},
		sad =      {0,  8,  4, 0, -4, -8},
		straight = {0,  0,  0, 0,  0,  0}
	}
	arcs = arcs[YurysRuneDisplay:GetArc()]
	for i = 1, 6 do
		local Rune = getglobal("YRDRuneButtonIndividual"..i)
		local p,f,r,x,_ = Rune:GetPoint()
		Rune:SetPoint(p,f,r,x,arcs[i])
	end
end

function YurysRuneDisplay:ApplyBliz()
	if (YurysRuneDisplay:GetBliz()) then
		RuneFrame:Show()
	else
		RuneFrame:Hide()
	end
end

function YurysRuneDisplay:ApplyCooldown(rune, time)
	rune.lastUpdate = GetTime()
	local color = {1,1,0}
	if (time == 0) then
		time = ""
	elseif (YurysRuneDisplay:GetCdclr()) then
		color = runeColors[GetRuneType(rune)]
	elseif (time < 3) then
		local _,g,_ = t:GetTextColor()
		if (g > 0.5) then color = {1,0,0} end
	end
	rune.text:SetTextColor(unpack(color))
	rune.text:SetText(time)	
end

function YurysRuneDisplay:ApplyLock()
	if (YurysRuneDisplay:GetUnlock()) then
		YurysRuneDisplay:ApplyUnlock()
	else
		for i = 1, 6 do
			local Rune = getglobal("YRDRuneButtonIndividual"..i)
			-- Registering nothing effectively disables dragging --
			Rune:RegisterForDrag()
			Rune:EnableMouse(false)
		end
	end
end

function YurysRuneDisplay:ApplyOoca()
	if (not UnitAffectingCombat("player")) then
		local alpha = YurysRuneDisplay:GetOoca() 
		YRDRuneFrame:SetAlpha(alpha)
		if (alpha == 0) then
			YRDRuneFrame:Hide()
		else
			YRDRuneFrame:Show()
		end
	end
end

function YurysRuneDisplay:ApplyPosition()
	local pos = YurysRuneDisplay:GetPosition()
	YRDRuneFrame:SetMovable()
	YRDRuneFrame:SetPoint(pos["POINT"], "UIParent", pos["RELATIVE"], pos["XCOORD"], pos["YCOORD"])
end

function YurysRuneDisplay:ApplyScale()
	YRDRuneFrame:SetScale(YurysRuneDisplay:GetScale())
end

function YurysRuneDisplay:ApplySettings()
	YurysRuneDisplay:ApplyArc()
	YurysRuneDisplay:ApplyBliz()
	YurysRuneDisplay:ApplyLock()
	YurysRuneDisplay:ApplyOoca()
	YurysRuneDisplay:ApplyPosition()
	YurysRuneDisplay:ApplyScale()
end

function YurysRuneDisplay:ApplyUnlock()
	if (YurysRuneDisplay:GetLock()) then
		YurysRuneDisplay:ApplyLock()
	else
		for i = 1, 6 do
			local Rune = getglobal("YRDRuneButtonIndividual"..i)
			Rune:EnableMouse(true)
			Rune:RegisterForDrag("LeftButton")
			Rune:SetScript("OnDragStart", YurysRuneDisplay.OnDragStart)
			Rune:SetScript("OnDragStop", YurysRuneDisplay.OnDragStop)
		end
	end
end

-- Getters --
function YurysRuneDisplay:GetArc()
	return self.db.char.ARC
end

function YurysRuneDisplay:GetBliz()
	return self.db.char.BLIZ
end

function YurysRuneDisplay:GetCdclr()
	return self.db.char.CDCLR
end

function YurysRuneDisplay:GetCooldownUpdate(rune)
	local start, duration, ready = GetRuneCooldown(rune)
	local now = GetTime()
	local FREQ = 0.5
	if (ready or (now - start) >= duration) then
		return true, 0
	elseif (now >= Rune.lastUpdate + FREQ) then
		return true, duration - floor(now - start)
	end
	return false, nil
end

function YurysRuneDisplay:GetDefaults()
	local defaultValues = {
		ARC = "happy",
		BLIZ = false,
		CDCLR = "default",
		LOCKED = true,
		NUMCD = true,
		OOCA = 0.5,
		POSITION = {
			POINT = "CENTER",
			RELATIVE = "CENTER",
			XCOORD = 0,
			YCOORD = 1,
		},
		SCALE = 1
	}
	return defaultValues
end

function YurysRuneDisplay:GetLock()
	return self.db.char.LOCKED
end

function YurysRuneDisplay:GetNumcd()
	return self.db.char.NUMCD
end

function YurysRuneDisplay:GetOoca()
	return self.db.char.OOCA
end

function YurysRuneDisplay:GetOptionsTable()
	local optionsTable = {
		name = L["Yury's RuneDisplay"],
		handler = "YurysRuneDisplay",
		type = "group",
		args = {
			lock = {
				name = L["Lock"],
				desc = L["Locks Yury's RuneDisplay, preventing moving it"],
				type = "toggle",
				set = "SetLock",
				get = "GetLock"
			},
			unlock = {
				name = L["Unlock"],
				desc = L["Unlocks Yury's RuneDisplay, allowing it to be moved"],
				type = "toggle",
				set = "SetUnlock",
				get = "GetUnlock",
				hidden = true
			},
			numcd = {
				name = L["Numerical Cooldown"],
				desc = L["Enable/disable the numerical cooldown"],
				type = "toggle",
				set = "SetNumcd",
				get = "GetNumcd"
			},
			cdclr = {
				name = L["Cooldown color"],
				desc = L["Color of the numerical cooldown"],
				type = "select",
				values = {
					default = L["Default"],
					rune = L["Rune"]
				},
				set = "SetCdclr",
				get = "GetCdclr"
			},
			scale = {
				name = L["Scale"],
				desc = L["Scale Yury's RuneDisplay; make it bigger (>1) or smaller (<1)"],
				type = "range",
				min = 0.1,
				max = 3,
				bigStep = 0.1,
				get = "GetScale",
				set = "SetScale"
			},
			ooca = {
				name = L["Out Of Combat Alpha-value"],
				desc = L["Sets the OOCA of Yury's RuneDisplay, to make it less visible when not in combat"],
				type = "range",
				min = 0,
				max = 1,
				bigStep = 0.1,
				get = "GetOoca",
				set = "SetOoca"
			},
			bliz = {
				name = L["Blizzard frame"],
				desc = L["Shows/hides Blizzard's default runebar"],
				type = "toggle",
				get = "GetBliz",
				set = "SetBliz"
			},
			arc = {
				name = L["Arc"],
				desc = L["Sets the arc-type of Yury's RuneDisplay"],
				type = "select",
				values = {
					happy = L["Happy mouth"],
					sad = L["Sad mouth"],
					straight = L["Straight line"]
				},
				get = "GetArc",
				set = "SetArc"
			},
			reset = {
				name = L["Reset"],
				desc = L["Resets all options to default values"],
				type = "execute",
				func = "SetDefaults"
			}
		}
	}
	return optionsTable
end

function YurysRuneDisplay:GetPosition()
	return self.db.char.POSITION
end

function YurysRuneDisplay:GetScale()
	return self.db.char.SCALE
end

function YurysRuneDisplay:GetUnlock()
	return not self.db.char.LOCKED
end

-- Setters --
function YurysRuneDisplay:SetArc(info, value)
	-- set the variable --
	self.db.char.ARC = value
	-- apply settings to the frame --
	YurysRuneDisplay:ApplyArc()
end

function YurysRuneDisplay:SetBliz(info, value)
	-- set the variable --
	self.db.char.BLIZ = value
	-- apply settings to the frame --
	YurysRuneDisplay:ApplyBliz()
end

function YurysRuneDisplay:SetCdclr(info, value)
	-- set the variable --
	self.db.char.CDCLR = value
end

function YurysRuneDisplay:SetDefaults()
	-- set the variables --
	self.db.char = YurysRuneDisplay:GetDefaults()
	-- apply settings --
	YurysRuneDisplay:ApplySettings()
end

function YurysRuneDisplay:SetLock(info, value)
	-- set the variable --
	self.db.char.LOCKED = value
	-- apply settings to the frame --
	YurysRuneDisplay:ApplyLock()
end

function YurysRuneDisplay:SetNumcd(info, value)
	-- set the variable --
	self.db.char.NUMCD = value
end

function YurysRuneDisplay:SetOoca(info, value)
	-- set the variable --
	self.db.char.OOCA = value
	-- apply settings to the frame --
	YurysRuneDisplay:ApplyOoca()
end

function YurysRuneDisplay:SetPosition(value)
	-- set the variable --
	self.db.char.POSITION = value
end

function YurysRuneDisplay:SetScale(info, value)
	-- set the variable --
	self.db.char.SCALE = value
	-- apply settings to the frame --
	YurysRuneDisplay:ApplyScale()
end

function YurysRuneDisplay:SetUnlock(info, value)
	-- set the variable --
	self.db.char.LOCKED = not value
	-- apply settings to the frame --
	YurysRuneDisplay:ApplyUnlock()
end