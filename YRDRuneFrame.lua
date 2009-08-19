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