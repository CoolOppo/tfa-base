--[[
Function Name:  DetectMuzzleForward
Syntax: self:DetectMuzzleForward().
Returns:  Nothing.
Notes: Only runs when not in draw animation!  This prevents serious glitches
Purpose:  Sets the forward muzzle direction.
]]--
function SWEP:DetectMuzzleForward()
	if not self:OwnerIsValid() then return end
	local vm = self.Owner:GetViewModel()

	if self.MZFwDir == nil and not self:GetDrawing() then
		local refvec = self.Owner:GetAimVector()
		local att = self.MuzzleAttachmentRaw or vm:LookupAttachment(self.MuzzleAttachment)

		if not att then
			att = 1
		end

		local angpos = vm:GetAttachment(att)

		if not angpos then
			self.MZFwDir = "nil"
			--ready comparison vectors
			--compare player view angle to muzzle angle using vector dot product
			--find which is closes out of forward, right,and up
			--Now we've got it, but we need something to compare to
			--Set reference angle
			--nfwvec:Angle() - refvec:Angle()
		else
			local nfwvec
			local fwvec = angpos.Ang:Forward()
			local upvec = angpos.Ang:Up()
			local rivec = angpos.Ang:Right()
			local curdist = -2
			local refval = fwvec:Dot(refvec)

			if refval > curdist then
				nfwvec = fwvec
				curdist = refval
				self.MZFwDir = "fw"
			end

			refval = upvec:Dot(refvec)

			if refval > curdist then
				nfwvec = upvec
				curdist = refval
				self.MZFwDir = "up"
			end

			refval = rivec:Dot(refvec)

			if refval > curdist then
				nfwvec = rivec
				curdist = refval
				self.MZFwDir = "ri"
			end

			self.MZReferenceAngle = vm:WorldToLocalAngles(nfwvec:Angle())
			self.MZReferenceAngle:Normalize()
		end

		if game.SinglePlayer() and SERVER then
			self:SetNWString("MZFwDir", self.MZFwDir)
		end
	end
end

--[[
Function Name:  AutoDetectMuzzle
Syntax: self:AutoDetectMuzzle().  Call only once, or it's redundant.
Returns:  Nothing.
Notes:  Detects the proper muzzle flash effect if you haven't specified one.
Purpose:  Autodetection
]]--
function SWEP:AutoDetectMuzzle()
	if not self.MuzzleFlashEffect then
		local a = string.lower(self.Primary.Ammo)
		local cat = string.lower(self.Category and self.Category or "")

		if self.Silenced or self:GetSilenced() then
			self.MuzzleFlashEffect = "tfa_muzzleflash_silenced"
		elseif string.find(a, "357") or self.Revolver or string.find(cat, "revolver") then
			self.MuzzleFlashEffect = "tfa_muzzleflash_revolver"
		elseif self.Shotgun or a == "buckshot" or a == "slam" or a == "airboatgun" or string.find(cat, "shotgun") then
			self.MuzzleFlashEffect = "tfa_muzzleflash_shotgun"
		elseif string.find(a, "smg") or string.find(cat, "smg") or string.find(cat, "submachine") or string.find(cat, "sub-machine") then
			self.MuzzleFlashEffect = "tfa_muzzleflash_smg"
		elseif string.find(a, "sniper") or string.find(cat, "sniper") then
			self.MuzzleFlashEffect = "tfa_muzzleflash_sniper"
		elseif string.find(a, "pistol") or string.find(cat, "pistol") then
			self.MuzzleFlashEffect = "tfa_muzzleflash_pistol"
		elseif string.find(a, "ar2") or string.find(a, "rifle") or (string.find(cat, "revolver") and not string.find(cat, "rifle")) then
			self.MuzzleFlashEffect = "tfa_muzzleflash_rifle"
		else
			self.MuzzleFlashEffect = "tfa_muzzleflash_generic"
		end
	end
end

--[[
Function Name:  AutoDetectDamage
Syntax: self:AutoDetectDamage().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Fixes the damage for GDCW.
Purpose:  Autodetection
]]--
function SWEP:AutoDetectDamage()
	if self.Primary.Round then
		local rnd = string.lower(self.Primary.Round)

		if string.find(rnd, ".50bmg") then
			self.Primary.Damage = 185
		elseif string.find(rnd, "5.45x39") then
			self.Primary.Damage = 22
		elseif string.find(rnd, "5.56x45") then
			self.Primary.Damage = 30
		elseif string.find(rnd, "338_lapua") then
			self.Primary.Damage = 120
		elseif string.find(rnd, "338") then
			self.Primary.Damage = 100
		elseif string.find(rnd, "7.62x51") then
			self.Primary.Damage = 100
		elseif string.find(rnd, "9x39") then
			self.Primary.Damage = 32
		elseif string.find(rnd, "9mm") then
			self.Primary.Damage = 22
		elseif string.find(rnd, "9x19") then
			self.Primary.Damage = 22
		elseif string.find(rnd, "9x18") then
			self.Primary.Damage = 20
		end

		if string.find(rnd, "ap") then
			self.Primary.Damage = self.Primary.Damage * 1.2
		end
	end

	if (not self.Primary.Damage) or (self.Primary.Damage <= 0.01) and self.Velocity then
		self.Primary.Damage = self.Velocity / 5
	end

	if (not self.Primary.Damage) or (self.Primary.Damage <= 0.01) then
		self.Primary.Damage = (self.Primary.KickUp + self.Primary.KickUp + self.Primary.KickUp) * 10
	end
end

--[[
Function Name:  IconFix
Syntax: self:IconFix().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Fixes the icon.  Call this if you give it a texture path, or just nothing.
Purpose:  Autodetection
]]--
local selicon_final = {}

function SWEP:IconFix()
	self.Gun = self.ClassName
	local tselicon
	local proceed = true

	if selicon_final[self.Gun] then
		self.WepSelectIcon =  selicon_final[self.Gun]
		return
	end

	if self.WepSelectIcon then
		tselicon = type(self.WepSelectIcon)
	end

	if self.WepSelectIcon and tselicon == "string" then
		self.WepSelectIcon = surface.GetTextureID(self.WepSelectIcon)
		proceed = false
	end

	if proceed and file.Exists("materials/vgui/hud/" .. self.ClassName .. ".vmt", "GAME") then
		self.WepSelectIcon = surface.GetTextureID("vgui/hud/" .. self.ClassName)
	end

	selicon_final[self.Gun] = self.WepSelectIcon
end

--[[
Function Name:  CorrectScopeFOV
Syntax: self:CorrectScopeFOV( fov ).  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  If you're using scopezoom instead of FOV, this translates it.
Purpose:  Autodetection
]]--
function SWEP:CorrectScopeFOV(fov)
	if not self.Secondary.IronFOV or self.Secondary.IronFOV == 0 then
		if self.Scoped then
			self.Secondary.IronFOV = fov / (self.Secondary.ScopeZoom and self.Secondary.ScopeZoom or 2)
		else
			self.Secondary.IronFOV = 32
		end
	end
end

--[[
Function Name:  DetectValidAnimations
Syntax: self:DetectValidAnimations( ).  Call as much as you like.
Returns:  Nothing.
Notes:  This is what autodetects animations for the SWEP.SequenceEnabled and SWEP.SequenceLength tables.
Purpose:  Autodetection
]]--
function SWEP:DetectValidAnimations()
	if not IsValid(self) then return end

	if self.CanBeSilenced and self.SequenceEnabled[ACT_VM_IDLE_SILENCED] == nil then
		self.SequenceEnabled[ACT_VM_IDLE_SILENCED] = true
	end

	if not self:OwnerIsValid() then return end
	local vm = self.Owner:GetViewModel()

	if IsValid(vm) then
		local seq

		for k, v in pairs(self.actlist) do
			seq = vm:SelectWeightedSequence(v)

			if seq ~= -1 then
				self.SequenceEnabled[v] = true
				self.SequenceLength[v] = vm:SequenceDuration(seq)
			else
				self.SequenceEnabled[v] = false
				self.SequenceLength[v] = 0.3
			end

			if (v == ACT_VM_IDLE_SILENCED or v == ACT_VM_RELOAD_SILENCED or v == ACT_VM_PRIMARYATTACK_SILENCED) and self.CanBeSilenced then
				self.SequenceEnabled[v] = true
				self.SequenceLength[v] = vm:SequenceDuration(seq)

				if not self.SequenceLength[v] or self.SequenceLength[v] <= 0.01 then
					self.SequenceLength[v] = 0.3
				end
			end
		end

		seq = vm:SelectWeightedSequence(ACT_VM_DRYFIRE)

		if seq ~= -1 and seq ~= vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK) then
			self.SequenceEnabled[ACT_VM_DRYFIRE] = true
		end

		seq = vm:SelectWeightedSequence(ACT_VM_DRYFIRE_SILENCED)

		if seq ~= -1 and seq ~= vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK_SILENCED) then
			self.SequenceEnabled[ACT_VM_DRYFIRE_SILENCED] = true
		end
	else
		return false
	end

	if self.CanBeSilenced and self.SequenceEnabled[ACT_VM_IDLE_SILENCED] == nil then
		self.SequenceEnabled[ACT_VM_IDLE_SILENCED] = true
	end

	return true
end

--[[
Function Name:  CreateFireModes
Syntax: self:CreateFireModes( is first draw).  Call as much as you like.  isfirstdraw controls whether the default fire mode is set.
Returns:  Nothing.
Notes:  Autodetects fire modes depending on what params you set up.
Purpose:  Autodetection
]]--
function SWEP:CreateFireModes(isfirstdraw)
	local thasbeencreated = false

	if not self.FireModes then
		self.FireModes = {}
		local burstcnt = self:FindEvenBurstNumber()

		if self.SelectiveFire then
			if self.OnlyBurstFire then
				if burstcnt then
					self.FireModes[1] = burstcnt .. "Burst"
					self.FireModes[2] = "Single"
				else
					self.FireModes[1] = "Single"
				end
			else
				self.FireModes[1] = "Automatic"

				if self.DisableBurstFire then
					self.FireModes[2] = "Single"
				else
					if burstcnt then
						self.FireModes[2] = burstcnt .. "Burst"
						self.FireModes[3] = "Single"
					else
						self.FireModes[2] = "Single"
					end
				end
			end
		else
			if self.Primary.Automatic then
				self.FireModes[1] = "Automatic"

				if self.OnlyBurstFire and burstcnt then
					self.FireModes[1] = burstcnt .. "Burst"
				end
			else
				self.FireModes[1] = "Single"
			end
		end

		thasbeencreated = true
	end

	if isfirstdraw or thasbeencreated and self.DefaultFireMode then
		for k, v in ipairs(self.FireModes) do
			if v == self.DefaultFireMode then
				self:SetFireMode(k)
			end
		end
	end

	if not self:GetFireMode() or self:GetFireMode() == 0 then
		if self.Primary.Automatic then
			self:SetFireMode(1)
		else
			self:SetFireMode(#self.FireModes)
		end
	end

	if not table.HasValue(self.FireModes, "Safe") then
		table.insert(self.FireModes, #self.FireModes + 1, "Safe")
	end
end

--[[
Function Name:  AutoDetectRange
Syntax: self:AutoDetectRange().  Really only necessary to call once, but w/e.
Returns:  Nothing.
Notes:  Autodetects weapon range.  This is further affect in the shoot code by a convar.  See sh_bullet.lua.
Purpose:  Autodetection
]]--
function SWEP:AutoDetectRange()
	if self.Primary.Range == -1 then
		self.Primary.Range = 18240 * self.Primary.Damage / 30 * (math.abs(self.Primary.KickUp) + math.abs(self.Primary.KickDown) + math.abs(self.Primary.KickHorizontal)) * 0.888
		self.Primary.Range = (self.Primary.Range * 3 + self.Primary.Range / (self.Primary.RPM / 400)) / 4
		local ht = self.DefaultHoldType and self.DefaultHoldType or self.HoldType

		if ht == "pistol" then
			self.Primary.Range = self.Primary.Range * 0.3
		end

		if ht == "revolver" or ht == "357" then
			self.Primary.Range = self.Primary.Range * 0.35
		end

		if ht == "smg" or ht == "smg" then
			self.Primary.Range = self.Primary.Range * 0.9
		end

		if self.Shotgun or ht == "shotgun" or ht == "crossbow" or string.find(string.lower(self.ViewModel), "shotgun") or string.find(string.lower(self.Base), "shotgun") or string.find(string.lower(self.Category), "shotgun") then
			self.Primary.Range = self.Primary.Range * 1.2
		end

		if self.Scoped then
			self.Primary.Range = self.Primary.Range * 1.5
		end

		self.Primary.Range = self.Primary.Range / self.Primary.NumShots
	end

	if self.Primary.RangeFalloff == -1 then
		self.Primary.RangeFalloff = math.Clamp(math.pow(math.abs(self.Primary.KickUp) + math.abs(self.Primary.KickDown) + math.abs(self.Primary.KickHorizontal), 2) / 3, 0.3, 0.9)
	end
end

--[[
Function Name:  SetUpSpread
Syntax: self:SetUpSpread().  Really only necessary to call once, but w/e.
Returns:  Nothing.
Notes:  Autodetects weapon spraycone.  Does nothing after you set them, either in SWEP code or by calling this function once.
Purpose:  Autodetection
]]--
function SWEP:SetUpSpread()
	local ht = self.DefaultHoldType and self.DefaultHoldType or self.HoldType

	if not self.Primary.SpreadMultiplierMax or self.AutoDetectSpreadMultiplierMax then
		self.Primary.SpreadMultiplierMax = 2.5 * math.max(self.Primary.RPM, 400) / 600 * math.sqrt(self.Primary.Damage / 30 * self.Primary.NumShots) --How far the spread can expand when you shoot.

		if ht == "smg" then
			self.Primary.SpreadMultiplierMax = self.Primary.SpreadMultiplierMax * 0.8
		end

		if ht == "revolver" then
			self.Primary.SpreadMultiplierMax = self.Primary.SpreadMultiplierMax * 2
		end

		if self.Scoped then
			self.Primary.SpreadMultiplierMax = self.Primary.SpreadMultiplierMax * 1.5
		end

		self.AutoDetectSpreadMultiplierMax = true
	end

	if not self.Primary.SpreadIncrement or self.AutoDetectSpreadIncrement then
		self.AutoDetectSpreadIncrement = true
		self.Primary.SpreadIncrement = 1 * math.Clamp(math.sqrt(self.Primary.RPM) / 24.5, 0.7, 3) * math.sqrt(self.Primary.Damage / 30 * self.Primary.NumShots) --What percentage of the modifier is added on, per shot.

		if ht == "revolver" then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 2
		end

		if ht == "pistol" then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 1.35
		end

		if ht == "ar2" or ht == "rpg" then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 0.65
		end

		if ht == "smg" then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 1.75
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * (math.Clamp((self.Primary.RPM - 650) / 150, 0, 1) + 1)
		end

		if ht == "pistol" and self.Primary.Automatic == true then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 1.5
		end

		if self.Scoped then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * 1.25
		end

		self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * math.sqrt(self.Primary.Recoil * (self.Primary.KickUp + self.Primary.KickDown + self.Primary.KickHorizontal)) * 0.8
	end

	if not self.Primary.SpreadRecovery or self.AutoDetectSpreadRecovery then
		self.AutoDetectSpreadRecovery = true
		self.Primary.SpreadRecovery = math.sqrt(math.max(self.Primary.RPM, 300)) / 29 * 4 --How much the spread recovers, per second.

		if ht == "smg" then
			self.Primary.SpreadRecovery = self.Primary.SpreadRecovery * (1 - math.Clamp((self.Primary.RPM - 600) / 200, 0, 1) * 0.33)
		end
	end
end
