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
	self.lastUpdate = 0
	self.rune  = getglobal(name.."Rune")
	self.fill  = getglobal(name.."Fill");
	self.shine = getglobal(name.."ShineTexture")
	self.text  = getglobal(name.."CooldownText")
	self.cooldown = getglobal(name.."Cooldown")
	self.cooldown.noCooldownCount = true	-- disable OmniCC numbers --
	-- update --
	RuneButton_Update(self)
end

function YRDRuneButton_OnUpdate(self, elapsed)
	local start, duration, runeReady = GetRuneCooldown(self:GetID())
	local displayCooldown = (runeReady and 0) or 1;
	CooldownFrame_SetTimer(self.cooldown, start, duration, displayCooldown);
	if (YurysRuneDisplay:GetNumcd()) then
		local apply, time = YurysRuneDisplay:GetCooldownUpdate(self)
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
end