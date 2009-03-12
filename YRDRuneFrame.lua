-- Readability == win --
local FirstTime = true
local RUNETYPE_BLOOD  = 1
local RUNETYPE_UNHOLY = 2
local RUNETYPE_FROST  = 3
local RUNETYPE_DEATH  = 4

local iconTextures = {}
iconTextures[RUNETYPE_BLOOD]  = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood"
iconTextures[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy"
iconTextures[RUNETYPE_FROST]  = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost"
iconTextures[RUNETYPE_DEATH]  = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death"

local runeTextures = {
	[RUNETYPE_BLOOD]  = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Blood-Off.tga",
	[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Death-Off.tga",
	[RUNETYPE_FROST]  = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Frost-Off.tga",
	[RUNETYPE_DEATH]  = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Chromatic-Off.tga",
}

local runeColors = {
	[RUNETYPE_BLOOD]  = {1,   0,   0},
	[RUNETYPE_UNHOLY] = {0,   0.5, 0},
	[RUNETYPE_FROST]  = {0,   1,   1},
	[RUNETYPE_DEATH]  = {0.8, 0.1, 1},
}

runeMapping = {
	[1] = "BLOOD",
	[2] = "UNHOLY",
	[3] = "FROST",
	[4] = "DEATH",
}

function YRDRuneButton_OnLoad (self)
	-- Disable rune frame if not a death knight --
	local _, class = UnitClass("player")

	if ( class ~= "DEATHKNIGHT" ) then
		self:Hide()
		return
	end
	
	RuneFrame_AddRune(YRDRuneFrame, self)

	self.rune = getglobal(self:GetName().."Rune")
	self.shine = getglobal(self:GetName().."ShineTexture")
	self.lastUpdate = 0
	self:SetFrameStrata("HIGH")
	self.text = self:CreateFontString(nil, "OVERLAY")
	local t = self.text
	t:SetPoint("CENTER", 0, 0)
	t:SetTextColor(1, 1, 0)
	t:SetJustifyH("CENTER")
	t:SetShadowOffset(1, -1)
	t:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
	RuneButton_Update(self)
end

function YRDRuneButton_OnUpdate (self, elapsed)  
	local cooldown = getglobal(self:GetName().."Cooldown")
	local start, duration, runeReady = GetRuneCooldown(self:GetID())

	local displayCooldown = (runeReady and 0) or 1

	CooldownFrame_SetTimer(cooldown, start, duration, displayCooldown)
	if (YRDSettings["NUMCD"] ~= "off") then
		YRDRuneCooldown(self)
	end

	if ( runeReady ) then
		self:SetScript("OnUpdate", nil)
	end
end

function YRDRuneCooldown(Rune)
	local start, duration, ready = GetRuneCooldown(Rune:GetID())
	local now = GetTime()
	local Freq = 0.5
	if (ready or (now - start) >= duration) then
		YRDRuneCdLeft(Rune, 0)
	elseif (now >= Rune.lastUpdate + Freq) then
		Rune.lastUpdate = now
		YRDRuneCdLeft(Rune, duration - floor(now - start))
	end
end

function YRDRuneCdLeft(Rune, sec)
	local t = Rune.text
	local color = {1,1,0}
	if (sec <= 0) then
		sec = ""
	elseif (YRDSettings["CDCLR"] == "rune") then
		color = runeColors[GetRuneType(Rune:GetID())]
	elseif (sec < 3) then
		local _,g,_ = t:GetTextColor()
		if (g < 0.5) then color = {1,0,0} end
	end
	t:SetTextColor(unpack(color))
	t:SetText(sec)
end

function YRDRuneFrame_OnLoad (self)
	-- Disable rune frame if not a death knight --
	local _, class = UnitClass("player")

	if ( class ~= "DEATHKNIGHT" ) then
		self:Hide()
		return
	end

	self:RegisterEvent("RUNE_POWER_UPDATE")
	self:RegisterEvent("RUNE_TYPE_UPDATE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")

	self:SetScript("OnEvent", YRDRuneFrame_OnEvent)

	self.runes = {}
end

function YRDRuneFrame_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( FirstTime ) then
			RuneFrame_FixRunes(self)
			FirstTime = false
		end
		for rune in next, self.runes do
			RuneButton_Update(self.runes[rune], rune, true)
		end
	elseif ( event == "RUNE_POWER_UPDATE" ) then
		local rune, usable = ...
		if ( not usable and rune and self.runes[rune] ) then
			self.runes[rune]:SetScript("OnUpdate", YRDRuneButton_OnUpdate)
		elseif ( usable and rune and self.runes[rune] ) then
			self.runes[rune].shine:SetVertexColor(1, 1, 1)
			RuneButton_ShineFadeIn(self.runes[rune].shine)
		end
	elseif ( event == "RUNE_TYPE_UPDATE" ) then
		local rune = ...
		if ( rune ) then
			RuneButton_Update(self.runes[rune], rune)
		end
	elseif (event == "PLAYER_REGEN_ENABLED") then
		YRDRuneFrame:SetAlpha(YRDSettings["OOCA"])
		if (YRDSettings["OOCA"] == 0) then
			YRDRuneFrame:Hide()
		end
	elseif (event == "PLAYER_REGEN_DISABLED") then
		YRDRuneFrame:Show()
		YRDRuneFrame:SetAlpha(1)
	end
end