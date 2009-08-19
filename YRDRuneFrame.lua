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

function YRDRuneButton_OnLoad(self)
	-- Disable rune if not a death knight --
	if ( select(2, UnitClass("player")) ~= "DEATHKNIGHT" ) then
		self:Hide()
		return
	end
	-- add the rune to the frame --
	RuneFrame_AddRune(YRDRuneFrame, self)
	-- define some extra settings --
	local name = self:GetName()
	self.cooldown = getglobal(name.."Cooldown")
	self.cooldown.noCooldownCount = true	-- disable OmniCC numbers --
	self.lastUpdate = 0
	self.rune = getglobal(name.."Rune")
	self.shine = getglobal(name.."ShineTexture")
	self.text = getglobal(name.."Text")
	-- update --
	RuneButton_Update(self)
end

function YRDRuneButton_OnUpdate(self, elapsed)
	local start, duration, runeReady = GetRuneCooldown(self:GetID())
	CooldownFrame_SetTimer(self.cooldown, start, duration, true);
	if (YurysRuneDisplay:getNumcd()) then
		apply, time = YurysRuneDisplay:GetCooldownUpdate(self)
		if (apply) then
			YurysRuneDisplay:ApplyCooldown(self, time)
		end
	end
	if (runeReady) then
		self:SetScript("OnUpdate", nil)
	end
end

function YRDRuneFrame_OnLoad(self)
	-- Disable rune frame if not a death knight --
	if ( select(2, UnitClass("player")) ~= "DEATHKNIGHT" ) then
		self:Hide()
		return
	end
	self.runes = {}
end