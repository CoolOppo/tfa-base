
-- Copyright (c) 2018-2020 TFA Base Devs

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

function SWEP:FixSprintAnimBob()
	local self2 = self:GetTable()

	if self2.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI then
		self2.SprintBobMult = 0
	end
end

function SWEP:FixWalkAnimBob()
	local self2 = self:GetTable()
	if self2.Walk_Mode == TFA.Enum.LOCOMOTION_ANI then
		self2.WalkBobMult_Iron = self2.WalkBobMult
		self2.WalkBobMult = 0
	end
end

function SWEP:PatchAmmoTypeAccessors()
	local self2 = self:GetTable()
	self2.GetPrimaryAmmoTypeOld = self2.GetPrimaryAmmoTypeOld or self2.GetPrimaryAmmoType
	self2.GetPrimaryAmmoType = function(myself, ...) return myself.GetPrimaryAmmoTypeC(myself, ...) end
	self2.GetSecondaryAmmoTypeOld = self2.GetSecondaryAmmoTypeOld or self2.GetSecondaryAmmoType
	self2.GetSecondaryAmmoType = function(myself, ...) return myself.GetSecondaryAmmoTypeC(myself, ...) end
end

function SWEP:FixProjectile()
	local self2 = self:GetTable()
	if self2.ProjectileEntity and self2.ProjectileEntity ~= "" then
		self2.Primary.Projectile = self2.ProjectileEntity
		self2.ProjectileEntity = nil
	end

	if self2.ProjectileModel and self2.ProjectileModel ~= "" then
		self2.Primary.ProjectileModel = self2.ProjectileModel
		self2.ProjectileModel = nil
	end

	if self2.ProjectileVelocity and self2.ProjectileVelocity ~= "" then
		self2.Primary.ProjectileVelocity = self2.ProjectileVelocity
		self2.ProjectileVelocity = nil
	end
end

function SWEP:AutoDetectRange()
	local self2 = self:GetTable()
	if self2.Primary.Range <= 0 then
		self2.Primary.Range = math.sqrt(self2.Primary.Damage / 32) * self:MetersToUnits(350) * self:AmmoRangeMultiplier()
	end

	if self2.Primary.RangeFalloff <= 0 then
		self2.Primary.RangeFalloff = 0.5
	end
end

function SWEP:FixProceduralReload()
	local self2 = self:GetTable()
	if self2.DoProceduralReload then
		self2.ProceduralReloadEnabled = true
	end
end

function SWEP:FixRPM()
	local self2 = self:GetTable()
	if not self2.Primary.RPM then
		if self2.Primary.Delay then
			self2.Primary.RPM = 60 / self2.Primary.Delay
		else
			self2.Primary.RPM = 120
		end
	end
end

function SWEP:FixCone()
	local self2 = self:GetTable()
	if self2.Primary.Cone then
		if (not self2.Primary.Spread) or self2.Primary.Spread < 0 then
			self2.Primary.Spread = self2.Primary.Cone
		end

		self2.Primary.Cone = nil
	end
end

--legacy compatibility
function SWEP:FixIdles()
	local self2 = self:GetTable()
	if self2.DisableIdleAnimations ~= nil and self2.DisableIdleAnimations == true then
		self2.Idle_Mode = TFA.Enum.IDLE_LUA
	end
end

function SWEP:FixIS()
	local self2 = self:GetTable()
	if self2.SightsPos and (not self2.IronSightsPos or (self2.IronSightsPos.x ~= self2.SightsPos.x and self2.SightsPos.x ~= 0)) then
		self2.IronSightsPos = self2.SightsPos or Vector()
		self2.IronSightsAng = self2.SightsAng or Vector()
	end
end

local legacy_spread_cv = GetConVar("sv_tfa_spread_legacy")

function SWEP:AutoDetectSpread()
	local self2 = self:GetTable()
	if legacy_spread_cv and legacy_spread_cv:GetBool() then
		self:SetUpSpreadLegacy()

		return
	end

	if self2.Primary.SpreadMultiplierMax == -1 or not self2.Primary.SpreadMultiplierMax then
		self2.Primary.SpreadMultiplierMax = math.Clamp(math.sqrt(math.sqrt(self2.Primary.Damage / 35) * 10 / 5) * 5, 0.01 / self2.Primary.Spread, 0.1 / self2.Primary.Spread)
	end

	if self2.Primary.SpreadIncrement == -1 or not self2.Primary.SpreadIncrement then
		self2.Primary.SpreadIncrement = self2.Primary.SpreadMultiplierMax * 60 / self2.Primary.RPM * 0.85 * 1.5
	end

	if self2.Primary.SpreadRecovery == -1 or not self2.Primary.SpreadRecovery then
		self2.Primary.SpreadRecovery = math.max(self2.Primary.SpreadMultiplierMax * math.pow(self2.Primary.RPM / 600, 1 / 3) * 0.75, self2.Primary.SpreadMultiplierMax / 1.5)
	end
end

--[[
Function Name:  AutoDetectMuzzle
Syntax: self:AutoDetectMuzzle().  Call only once, or it's redundant.
Returns:  Nothing.
Notes:  Detects the proper muzzle flash effect if you haven't specified one.
Purpose:  Autodetection
]]
--
function SWEP:AutoDetectMuzzle()
	local self2 = self:GetTable()
	if not self2.MuzzleFlashEffect then
		local a = string.lower(self2.Primary.Ammo)
		local cat = string.lower(self2.Category and self2.Category or "")

		if self2.Silenced or self:GetSilenced() then
			self2.MuzzleFlashEffect = "tfa_muzzleflash_silenced"
		elseif string.find(a, "357") or self2.Revolver or string.find(cat, "revolver") then
			self2.MuzzleFlashEffect = "tfa_muzzleflash_revolver"
		elseif self2.Shotgun or a == "buckshot" or a == "slam" or a == "airboatgun" or string.find(cat, "shotgun") then
			self2.MuzzleFlashEffect = "tfa_muzzleflash_shotgun"
		elseif string.find(a, "smg") or string.find(cat, "smg") or string.find(cat, "submachine") or string.find(cat, "sub-machine") then
			self2.MuzzleFlashEffect = "tfa_muzzleflash_smg"
		elseif string.find(a, "sniper") or string.find(cat, "sniper") then
			self2.MuzzleFlashEffect = "tfa_muzzleflash_sniper"
		elseif string.find(a, "pistol") or string.find(cat, "pistol") then
			self2.MuzzleFlashEffect = "tfa_muzzleflash_pistol"
		elseif string.find(a, "ar2") or string.find(a, "rifle") or (string.find(cat, "revolver") and not string.find(cat, "rifle")) then
			self2.MuzzleFlashEffect = "tfa_muzzleflash_rifle"
		else
			self2.MuzzleFlashEffect = "tfa_muzzleflash_generic"
		end
	end
end

--[[
Function Name:  AutoDetectDamage
Syntax: self:AutoDetectDamage().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Fixes the damage for GDCW.
Purpose:  Autodetection
]]
--
function SWEP:AutoDetectDamage()
	local self2 = self:GetTable()
	if self2.Primary.Damage and self2.Primary.Damage ~= -1 then return end

	if self2.Primary.Round then
		local rnd = string.lower(self2.Primary.Round)

		if string.find(rnd, ".50bmg") then
			self2.Primary.Damage = 185
		elseif string.find(rnd, "5.45x39") then
			self2.Primary.Damage = 22
		elseif string.find(rnd, "5.56x45") then
			self2.Primary.Damage = 30
		elseif string.find(rnd, "338_lapua") then
			self2.Primary.Damage = 120
		elseif string.find(rnd, "338") then
			self2.Primary.Damage = 100
		elseif string.find(rnd, "7.62x51") then
			self2.Primary.Damage = 100
		elseif string.find(rnd, "9x39") then
			self2.Primary.Damage = 32
		elseif string.find(rnd, "9mm") then
			self2.Primary.Damage = 22
		elseif string.find(rnd, "9x19") then
			self2.Primary.Damage = 22
		elseif string.find(rnd, "9x18") then
			self2.Primary.Damage = 20
		end

		if string.find(rnd, "ap") then
			self2.Primary.Damage = self2.Primary.Damage * 1.2
		end
	end

	if (not self2.Primary.Damage) or (self2.Primary.Damage <= 0.01) and self2.Velocity then
		self2.Primary.Damage = self2.Velocity / 5
	end

	if (not self2.Primary.Damage) or (self2.Primary.Damage <= 0.01) then
		self2.Primary.Damage = (self2.Primary.KickUp + self2.Primary.KickUp + self2.Primary.KickUp) * 10
	end
end

--[[
Function Name:  AutoDetectDamageType
Syntax: self:AutoDetectDamageType().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Sets a damagetype
Purpose:  Autodetection
]]
--
function SWEP:AutoDetectDamageType()
	local self2 = self:GetTable()
	if self2.Primary.DamageType == -1 or not self2.Primary.DamageType then
		if self2.DamageType and not self2.Primary.DamageType then
			self2.Primary.DamageType = self2.DamageType
		else
			self2.Primary.DamageType = DMG_BULLET
		end
	end
end

--[[
Function Name:  AutoDetectForce
Syntax: self:AutoDetectForce().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Detects force from damage
Purpose:  Autodetection
]]
--
function SWEP:AutoDetectForce()
	local self2 = self:GetTable()
	if self2.Primary.Force == -1 or not self2.Primary.Force then
		self2.Primary.Force = self2.Force or (math.sqrt(self2.Primary.Damage / 16) * 3 / math.sqrt(self2.Primary.NumShots))
	end
end

--[[
Function Name:  AutoDetectKnockback
Syntax: self:AutoDetectKnockback().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Detects knockback from force
Purpose:  Autodetection
]]
--
function SWEP:AutoDetectKnockback()
	local self2 = self:GetTable()
	if self2.Primary.Knockback == -1 or not self2.Primary.Knockback then
		self2.Primary.Knockback = self2.Knockback or math.max(math.pow(self2.Primary.Force - 3.25, 2), 0) * math.pow(self2.Primary.NumShots, 1 / 3)
	end
end

--[[
Function Name:  IconFix
Syntax: self:IconFix().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Fixes the icon.  Call this if you give it a texture path, or just nothing.
Purpose:  Autodetection
]]
--
local selicon_final = {}

function SWEP:IconFix()
	local self2 = self:GetTable()
	if not surface then return end
	self2.Gun = self2.ClassName or self2.Folder
	local tselicon
	local proceed = true

	if selicon_final[self2.Gun] then
		self2.WepSelectIcon = selicon_final[self2.Gun]

		return
	end

	if self2.WepSelectIcon then
		tselicon = type(self2.WepSelectIcon)
	end

	if self2.WepSelectIcon and tselicon == "string" then
		self2.WepSelectIcon = surface.GetTextureID(self2.WepSelectIcon)
		proceed = false
	end

	if proceed and file.Exists("materials/vgui/hud/" .. self2.ClassName .. ".vmt", "GAME") then
		self2.WepSelectIcon = surface.GetTextureID("vgui/hud/" .. self2.ClassName)
	end

	selicon_final[self2.Gun] = self2.WepSelectIcon
end

--[[
Function Name:  CorrectScopeFOV
Syntax: self:CorrectScopeFOV( fov ).  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  If you're using scopezoom instead of FOV, this translates it.
Purpose:  Autodetection
]]
--
function SWEP:CorrectScopeFOV(fov)
	local self2 = self:GetTable()
	fov = fov or self2.DefaultFOV

	if not self2.Secondary.IronFOV or self2.Secondary.IronFOV <= 0 then
		if self2.Scoped then
			self2.Secondary.IronFOV = fov / (self2.Secondary.ScopeZoom and self2.Secondary.ScopeZoom or 2)
		else
			self2.Secondary.IronFOV = 32
		end
	end
end

--[[
Function Name:  CreateFireModes
Syntax: self:CreateFireModes( is first draw).  Call as much as you like.  isfirstdraw controls whether the default fire mode is set.
Returns:  Nothing.
Notes:  Autodetects fire modes depending on what params you set up.
Purpose:  Autodetection
]]
--
SWEP.FireModeCache = {}

function SWEP:CreateFireModes(isfirstdraw)
	local self2 = self:GetTable()
	if not self2.FireModes then
		self2.FireModes = {}
		local burstcnt = self:FindEvenBurstNumber()

		if self2.SelectiveFire then
			if self2.OnlyBurstFire then
				if burstcnt then
					self2.FireModes[1] = burstcnt .. "Burst"
					self2.FireModes[2] = "Single"
				else
					self2.FireModes[1] = "Single"
				end
			else
				self2.FireModes[1] = "Automatic"

				if self2.DisableBurstFire then
					self2.FireModes[2] = "Single"
				else
					if burstcnt then
						self2.FireModes[2] = burstcnt .. "Burst"
						self2.FireModes[3] = "Single"
					else
						self2.FireModes[2] = "Single"
					end
				end
			end
		else
			if self2.Primary.Automatic then
				self2.FireModes[1] = "Automatic"

				if self2.OnlyBurstFire and burstcnt then
					self2.FireModes[1] = burstcnt .. "Burst"
				end
			else
				self2.FireModes[1] = "Single"
			end
		end
	end

	if self2.FireModes[#self2.FireModes] ~= "Safe" then
		self2.FireModes[#self2.FireModes + 1] = "Safe"
	end

	if not self2.FireModeCache or #self2.FireModeCache <= 0 then
		for k, v in ipairs(self2.FireModes) do
			self2.FireModeCache[v] = k
		end

		if type(self2.DefaultFireMode) == "number" then
			self:SetFireMode(self2.DefaultFireMode or (self2.Primary.Automatic and 1 or #self2.FireModes - 1))
		else
			self:SetFireMode(self2.FireModeCache[self2.DefaultFireMode] or (self2.Primary.Automatic and 1 or #self2.FireModes - 1))
		end
	end
end

--[[
Function Name:  CacheAnimations
Syntax: self:CacheAnimations( ).  Call as much as you like.
Returns:  Nothing.
Notes:  This is what autodetects animations for the SWEP.SequenceEnabled and SWEP.SequenceLength tables.
Purpose:  Autodetection
]]
--
--SWEP.actlist = {ACT_VM_DRAW, ACT_VM_DRAW_EMPTY, ACT_VM_DRAW_SILENCED, ACT_VM_DRAW_DEPLOYED, ACT_VM_HOLSTER, ACT_VM_HOLSTER_EMPTY, ACT_VM_IDLE, ACT_VM_IDLE_EMPTY, ACT_VM_IDLE_SILENCED, ACT_VM_PRIMARYATTACK, ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_EMPTY, ACT_VM_PRIMARYATTACK_SILENCED, ACT_VM_SECONDARYATTACK, ACT_VM_RELOAD, ACT_VM_RELOAD_EMPTY, ACT_VM_RELOAD_SILENCED, ACT_VM_ATTACH_SILENCER, ACT_VM_RELEASE, ACT_VM_DETACH_SILENCER, ACT_VM_FIDGET, ACT_VM_FIDGET_EMPTY, ACT_VM_FIDGET_SILENCED, ACT_SHOTGUN_RELOAD_START, ACT_VM_DRYFIRE, ACT_VM_DRYFIRE_SILENCED }
--If you really want, you can remove things from SWEP.actlist and manually enable animations and set their lengths.
SWEP.SequenceEnabled = {}
SWEP.SequenceLength = {}
SWEP.SequenceLengthOverride = {} --Override this if you want to change the length of a sequence but not the next idle
SWEP.ActCache = {}
local vm, seq

function SWEP:CacheAnimations()
	local self2 = self:GetTable()
	table.Empty(self2.ActCache)

	if self2.CanBeSilenced and self2.SequenceEnabled[ACT_VM_IDLE_SILENCED] == nil then
		self2.SequenceEnabled[ACT_VM_IDLE_SILENCED] = true
	end

	if not self:VMIV() then return end
	vm = self2.OwnerViewModel

	if IsValid(vm) then
		self:BuildAnimActivities()

		for _, v in ipairs(table.GetKeys(self2.AnimationActivities)) do
			if isnumber(v) then
				seq = vm:SelectWeightedSequence(v)

				if seq ~= -1 and vm:GetSequenceActivity(seq) == v and not self2.ActCache[seq] then
					self2.SequenceEnabled[v] = true
					self2.SequenceLength[v] = vm:SequenceDuration(seq)
					self2.ActCache[seq] = v
				else
					self2.SequenceEnabled[v] = false
					self2.SequenceLength[v] = 0.0
				end
			else
				local s = vm:LookupSequence(v)

				if s and s > 0 then
					self2.SequenceEnabled[v] = true
					self2.SequenceLength[v] = vm:SequenceDuration(s)
					self2.ActCache[s] = v
				else
					self2.SequenceEnabled[v] = false
					self2.SequenceLength[v] = 0.0
				end
			end
		end
	else
		return false
	end

	if self2.ProceduralHolsterEnabled == nil then
		if self2.SequenceEnabled[ACT_VM_HOLSTER] then
			self2.ProceduralHolsterEnabled = false
		else
			self2.ProceduralHolsterEnabled = true
		end
	end

	self2.HasDetectedValidAnimations = true

	return true
end

function SWEP:GetType()
	local self2 = self:GetTable()
	if self2.Type then return self2.Type end
	local at = string.lower(self2.Primary.Ammo or "")
	local ht = string.lower((self2.DefaultHoldType or self2.HoldType) or "")
	local rpm = self2.Primary.RPM_Displayed or self2.Primary.RPM or 600

	if self2.Primary.ProjectileEntity or self2.ProjectileEntity then
		if (self2.ProjectileVelocity or self2.Primary.ProjectileVelocity) > 400 then
			self2.Type = "Launcher"
		else
			self2.Type = "Grenade"
		end
		return
	end

	if at == "buckshot" then
		self2.Type = "Shotgun"

		return self:GetType()
	end

	if self2.Pistol or (at == "pistol" and ht == "pistol") then
		self2.Type = "Pistol"

		return self:GetType()
	end

	if self2.SMG or (at == "smg1" and (ht == "smg" or ht == "pistol" or ht == "357")) then
		self2.Type = "Sub-Machine Gun"

		return self:GetType()
	end

	if self2.Revolver or (at == "357" and ht == "revolver") then
		self2.Type = "Revolver"

		return self:GetType()
	end

	--Detect Sniper Type
	if ( (self2.Scoped or self2.Scoped_3D) and rpm < 600 ) or at == "sniperpenetratedround" then
		if rpm > 180 and (self2.Primary.Automatic or self2.Primary.SelectiveFire) then
			self2.Type = "Designated Marksman Rifle"

			return self:GetType()
		else
			self2.Type = "Sniper Rifle"

			return self:GetType()
		end
	end

	--Detect based on holdtype
	if ht == "pistol" then
		if self2.Primary.Automatic then
			self2.Type = "Machine Pistol"
		else
			self2.Type = "Pistol"
		end

		return self:GetType()
	end

	if ht == "duel" then
		if at == "pistol" then
			self2.Type = "Dual Pistols"

			return self:GetType()
		elseif at == "357" then
			self2.Type = "Dual Revolvers"

			return self:GetType()
		elseif at == "smg1" then
			self2.Type = "Dual Sub-Machine Guns"

			return self:GetType()
		else
			self2.Type = "Dual Guns"

			return self:GetType()
		end
	end

	--If it's using rifle ammo, it's a rifle or a carbine
	if at == "ar2" then
		if self2.Primary.ClipSize >= 60 then
			self2.Type = "Light Machine Gun"

			return self:GetType()
		elseif ht == "rpg" or ht == "revolver" then
			self2.Type = "Carbine"

			return self:GetType()
		else
			self2.Type = "Rifle"

			return self:GetType()
		end
	end

	--Check SMG one last time
	if ht == "smg" or at == "smg1" then
		self2.Type = "Sub-Machine Gun"

		return self:GetType()
	end

	--Fallback to generic
	self2.Type = "Weapon"

	return self:GetType()
end

function SWEP:SetUpSpreadLegacy()
	local self2 = self:GetTable()
	local ht = self2.DefaultHoldType and self2.DefaultHoldType or self2.HoldType

	if not self2.Primary.SpreadMultiplierMax or self2.Primary.SpreadMultiplierMax <= 0 or self2.AutoDetectSpreadMultiplierMax then
		self2.Primary.SpreadMultiplierMax = 2.5 * math.max(self2.Primary.RPM, 400) / 600 * math.sqrt(self2.Primary.Damage / 30 * self2.Primary.NumShots) --How far the spread can expand when you shoot.

		if ht == "smg" then
			self2.Primary.SpreadMultiplierMax = self2.Primary.SpreadMultiplierMax * 0.8
		end

		if ht == "revolver" then
			self2.Primary.SpreadMultiplierMax = self2.Primary.SpreadMultiplierMax * 2
		end

		if self2.Scoped then
			self2.Primary.SpreadMultiplierMax = self2.Primary.SpreadMultiplierMax * 1.5
		end

		self2.AutoDetectSpreadMultiplierMax = true
	end

	if not self2.Primary.SpreadIncrement or self2.Primary.SpreadIncrement <= 0 or self2.AutoDetectSpreadIncrement then
		self2.AutoDetectSpreadIncrement = true
		self2.Primary.SpreadIncrement = 1 * math.Clamp(math.sqrt(self2.Primary.RPM) / 24.5, 0.7, 3) * math.sqrt(self2.Primary.Damage / 30 * self2.Primary.NumShots) --What percentage of the modifier is added on, per shot.

		if ht == "revolver" then
			self2.Primary.SpreadIncrement = self2.Primary.SpreadIncrement * 2
		end

		if ht == "pistol" then
			self2.Primary.SpreadIncrement = self2.Primary.SpreadIncrement * 1.35
		end

		if ht == "ar2" or ht == "rpg" then
			self2.Primary.SpreadIncrement = self2.Primary.SpreadIncrement * 0.65
		end

		if ht == "smg" then
			self2.Primary.SpreadIncrement = self2.Primary.SpreadIncrement * 1.75
			self2.Primary.SpreadIncrement = self2.Primary.SpreadIncrement * (math.Clamp((self2.Primary.RPM - 650) / 150, 0, 1) + 1)
		end

		if ht == "pistol" and self2.Primary.Automatic == true then
			self2.Primary.SpreadIncrement = self2.Primary.SpreadIncrement * 1.5
		end

		if self2.Scoped then
			self2.Primary.SpreadIncrement = self2.Primary.SpreadIncrement * 1.25
		end

		self2.Primary.SpreadIncrement = self2.Primary.SpreadIncrement * math.sqrt(self2.Primary.Recoil * (self2.Primary.KickUp + self2.Primary.KickDown + self2.Primary.KickHorizontal)) * 0.8
	end

	if not self2.Primary.SpreadRecovery or self2.Primary.SpreadRecovery <= 0 or self2.AutoDetectSpreadRecovery then
		self2.AutoDetectSpreadRecovery = true
		self2.Primary.SpreadRecovery = math.sqrt(math.max(self2.Primary.RPM, 300)) / 29 * 4 --How much the spread recovers, per second.

		if ht == "smg" then
			self2.Primary.SpreadRecovery = self2.Primary.SpreadRecovery * (1 - math.Clamp((self2.Primary.RPM - 600) / 200, 0, 1) * 0.33)
		end
	end
end