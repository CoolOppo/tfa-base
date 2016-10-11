local l_CT = CurTime
local l_mathClamp = math.Clamp
local success, tanim
local CurrentCone, CurrentRecoil

SWEP.Akimbo_Inverted = false

function SWEP:InitializeAkimbo()
	if not self.Akimbo then return end

	if (self.Secondary.Ammo == "" or self.Secondary.Ammo == "none" or self.Secondary.Ammo == 0 or not self.Secondary.Ammo) then
		self.Secondary.Ammo = self.Primary.Ammo
		self.Secondary.AkimboStats = true
		self.Primary.RPM = self.Primary.RPM / 2
		self.Primary.ClipSize = self.Primary.ClipSize / 2
		self.Primary.DefaultClip = self.Primary.DefaultClip
		self.Secondary.Sound = self.Primary.Sound
		self.Secondary.RPM = self.Primary.RPM
		self.Secondary.ClipSize = self.Primary.ClipSize
		self.Secondary.DefaultClip = self.Primary.DefaultClip
		self.Secondary.KickUp = self.Primary.KickUp
		self.Secondary.KickDown = self.Primary.KickDown
		self.Secondary.KickHorizontal = self.Primary.KickHorizontal
		self.Secondary.Automatic = self.Primary.Automatic
		self.Secondary.Ammo = self.Primary.Ammo
		self.Secondary.NumShots = self.Primary.NumShots
		self.Secondary.Damage = self.Primary.Damage
		self.Secondary.Spread = self.Primary.Spread
		self.Secondary.IronAccuracy = self.Primary.IronAccuracy
	end

	self.AnimCycle = 0
	self.MuzzleAttachmentRaw = 1
end

function SWEP:DeployAkimbo()
	if not self.Akimbo then return end

	if (self.Secondary.Ammo == "" or self.Secondary.Ammo == "none" or self.Secondary.Ammo == 0 or not self.Secondary.Ammo or self.Secondary.AkimboStats) then
		self.Secondary.Sound = self.Primary.Sound
		self.Secondary.RPM = self.Primary.RPM
		self.Secondary.ClipSize = self.Primary.ClipSize
		self.Secondary.DefaultClip = self.Primary.DefaultClip
		self.Secondary.KickUp = self.Primary.KickUp
		self.Secondary.KickDown = self.Primary.KickDown
		self.Secondary.KickHorizontal = self.Primary.KickHorizontal
		self.Secondary.Automatic = self.Primary.Automatic
		self.Secondary.Ammo = self.Primary.Ammo
		self.Secondary.NumShots = self.Primary.NumShots
		self.Secondary.Damage = self.Primary.Damage
		self.Secondary.Spread = self.Primary.Spread
		self.Secondary.IronAccuracy = self.Primary.IronAccuracy
		local nabbedammo = math.max(0, self:Clip1() - self.Primary.ClipSize)
		self:SetClip1(self:Clip1() - nabbedammo)
		self:SetClip2(self:Clip2() + nabbedammo)
		self.Secondary.AkimboStats = false
	end
end

--[[
Function Name:  ToggleAkimbo
Syntax: self:ToggleAkimbo( secondary )
Returns:  Nothing
Notes: Prepares the gun to fire akimbo either primary or secondary
Purpose:  Main SWEP function
]]--
function SWEP:ToggleAkimbo(secondary)
	if self.Callback.ToggleAkimbo then
		local val = self.Callback.ToggleAkimbo(self)
		if val then return val end
	end

	if not self.Akimbo then return end

	if secondary == true then
		self.AnimCycle = 1
	elseif secondary == false then
		self.AnimCycle = 0
	end

	self:UpdateMuzzleAttachment()
end

--[[
Function Name:  CanSecondaryAttack
Syntax: self:CanSecondaryAttack()
Returns:  True/false can we shoot
Notes: Set clip to -1 to use reserve.
Purpose:  Main SWEP function
]]--
function SWEP:CanSecondaryAttack()
	if self.Secondary.NumShots > 1 then
		if (self:Clip2() < 1 and self.Secondary.ClipSize ~= -1) then
			if not self.HasPlayedEmptyClick2 then
				self:EmitSound("Weapon_Pistol.Empty")
				self.HasPlayedEmptyClick2 = true
			end

			self:SetNextSecondaryFire(l_CT() + 1 / (self:GetRPM() / 60))
			self:Reload()

			return false
		elseif (self.Secondary.ClipSize == -1 and self:Ammo1() < 1) then
			return false
		end
	else
		if (self:Clip2() < self.Secondary.AmmoConsumption and self.Secondary.ClipSize ~= -1) then
			if not self.HasPlayedEmptyClick2 then
				self:EmitSound("Weapon_Pistol.Empty")
				self.HasPlayedEmptyClick2 = true
			end

			self:SetNextSecondaryFire(l_CT() + 1 / (self:GetRPM() / 60))
			self:Reload()

			return false
		elseif (self.Secondary.ClipSize == -1 and self:Ammo1() < self.Secondary.AmmoConsumption) then
			return false
		end
	end

	self.HasPlayedEmptyClick2 = false

	return true
end

--[[
Function Name:  SecondaryAttack
Syntax: self:SecondaryAttack( ).
Returns:  Not sure that it returns anything.
Notes: Used on akimbo firing.
Purpose:  Main SWEP function
]]--
local seq

function SWEP:SecondaryAttack()
	if self.Callback.SecondaryAttack then
		local val = self.Callback.SecondaryAttack(self)
		if val then return val end
	end

	if not self:OwnerIsValid() then return end
	if not self.Akimbo then return end
	self:UpdateConDamage()

	if (self:GetHolstering()) then
		if (self.ShootWhileHolster == false) then
			return
		else
			self:SetHolsteringEnd(l_CT() - 0.1)
			self:SetHolstering(false)
			self:SetUnpredictedHolstering(false)
		end
	end

	if (self:GetReloading() and self.Shotgun and not self:GetShotgunPumping() and not self:GetShotgunNeedsPump()) then
		self:SetShotgunCancel(true)
		--[[
		self:SetShotgunInsertingShell(true)
		self:SetShotgunPumping(false)
		self:SetShotgunNeedsPump(true)
		self:SetReloadingEnd(l_CT()-1)
		]]
		--

		return
	end

	if self:IsSafety() then
		self:EmitSound("Weapon_AR2.Empty")
		self.LastSafetyShoot = self.LastSafetyShoot or 0

		if l_CT() < self.LastSafetyShoot + 0.2 then
			self:CycleSafety()
		end

		self.LastSafetyShoot = l_CT()

		return
	end

	if (self:GetChangingSilence()) then return end
	if (self:GetNearWallRatio() > 0.05) then return end
	if not self:OwnerIsValid() then return end

	if self.FiresUnderwater == false and self.Owner:WaterLevel() >= 3 then
		if self:CanSecondaryAttack() then
			self:SetNextSecondaryFire(l_CT() + 0.5)
			self:EmitSound("Weapon_AR2.Empty")
		end

		return
	end

	if (self.Owner:KeyDown(IN_USE) and self.CanBeSilenced and self.Owner:KeyPressed(IN_ATTACK2)) then
		if (self:CanSecondaryAttack() and not self:GetChangingSilence()) then
			--self:SetSilenced(!self:GetSilenced())
			success, tanim = self:ChooseSilenceAnim(not self:GetSilenced())
			self:SetChangingSilence(true)
			self:SetNextSilenceChange(l_CT() + success and self.SequenceLength[tanim] or 1 )
			self:SetNextSecondaryFire(l_CT() + 1 / (self:GetRPM() / 60))
		end

		return
	end

	if self:GetNextSecondaryFire() > l_CT() then return end

	if self:GetReloading() then
		self:CompleteReload()
	end

	if not self:CanSecondaryAttack() then return end

	--if self.Owner:IsPlayer() then
	if self:GetRunSightsRatio() < 0.1 then
		self.ProceduralHolsterFactor = 0
		self:SetHolstering(false)
		self:SetUnpredictedHolstering(false)
		self:ResetEvents()
		self:SetInspecting(false)
		self:SetInspectingRatio(0)
		self:SetInspectingRatio(0)
		--self:SendWeaponAnim(0)
		self:ToggleAkimbo(true)
		self:ShootBulletInformation(SERVER or (CLIENT and IsFirstTimePredicted()))
		success, tanim = self:ChooseShootAnim(SERVER or (CLIENT and IsFirstTimePredicted())) -- View model animation

		if self:OwnerIsValid() and self.Owner.SetAnimation then
			self.Owner:SetAnimation(PLAYER_ATTACK1) -- 3rd Person Animation
		end

		self:TakeSecondaryAmmo(math.min(self.Secondary.AmmoConsumption, self:Clip2()))
		self.PenetrationCounter = 0
		self:SetShooting(true)
		self:SetShootingEnd(l_CT() + self.OwnerViewModel:SequenceDuration())

		if self.BoltAction then
			self:SetBoltTimer(true)
			local t1, t2
			t1 = l_CT() + self.BoltTimerOffset
			t2 = l_CT() + (self.SequenceLengthOverride[tanim] or self.OwnerViewModel:SequenceDuration(seq))

			if t1 < t2 then
				self:SetBoltTimerStart(t1)
				self:SetBoltTimerEnd(t2)
			else
				self:SetBoltTimerStart(t2)
				self:SetBoltTimerEnd(t1)
			end
		end

		CurrentCone, CurrentRecoil = self:CalculateConeRecoil()
		self:Recoil(CurrentRecoil + CurrentCone * 0, SERVER or (CLIENT and IsFirstTimePredicted()))
		self:SetSpreadRatio(l_mathClamp(self:GetSpreadRatio() + self.Primary.SpreadIncrement, 1, self.Primary.SpreadMultiplierMax))

		if (CLIENT or sp) and IsFirstTimePredicted() then
			self.CLSpreadRatio = l_mathClamp(self.CLSpreadRatio + self.Primary.SpreadIncrement, 1, self.Primary.SpreadMultiplierMax)
		end

		self:SetBursting(true)
		self:SetNextBurst(l_CT() + 1 / (self:GetRPM() / 60))
		self:SetBurstCount(self:GetBurstCount() + 1)
		self:SetNextSecondaryFire(l_CT() + 1 / (self:GetRPM() / 60))

		if self.Akimbo then
			self:SetNextPrimaryFire(math.max(self:GetNextPrimaryFire(), l_CT() + 0.01))
		end

		if not self:GetSilenced() then
			if self.Primary.Sound then
				self:PlaySound(self.Primary.SoundTable and self.Primary.SoundTable or self.Primary.Sound)
			end
		else
			if self.Primary.SilencedSound then
				self:PlaySound(self.Primary.SilencedSound)
			elseif self.Primary.Sound then
				self:PlaySound(self.Primary.SoundTable and self.Primary.SoundTable or self.Primary.Sound)
			end
		end

		if self.EjectionSmoke and (SERVER or (CLIENT and IsFirstTimePredicted())) and not (self.LuaShellEject and self.LuaShellEjectDelay > 0) then
			self:EjectionSmoke()
		end

		self:DoAmmoCheck()
	end
end
