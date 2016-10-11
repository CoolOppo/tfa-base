DEFINE_BASECLASS("tfa_gun_base")
SWEP.MuzzleFlashEffect = ""
SWEP.data = {}
SWEP.data.ironsights = 0
SWEP.Delay = 0.3 -- Delay to fire entity
SWEP.Primary.Round = "" -- Nade Entity
SWEP.Velocity = 550 -- Entity Velocity

local success, tanim

function SWEP:Initialize()

	self.ProjectileEntity = self.ProjectileEntity or self.Primary.Round --Entity to shoot
	self.ProjectileVelocity = self.ProjectileVelocity or self.Velocity and self.Velocity or 550 --Entity to shoot's velocity

	BaseClass.Initialize(self)
end

function SWEP:ChooseShootAnim()
	if not self:OwnerIsValid() then return end
	--self:ResetEvents()
	tanim = ACT_VM_THROW
	success = true
	self:SendWeaponAnim(ACT_VM_THROW)

	if game.SinglePlayer() then
		self:CallOnClient("AnimForce", tanim)
	end

	self.lastact = tanim

	return success, tanim
end

function SWEP:DoAmmoCheck()
	if IsValid(self) and SERVER then
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end

		if self:Clip1() <= 0 and self.Owner:GetAmmoCount(self:GetPrimaryAmmoType()) == 0 then
			timer.Simple(vm:SequenceDuration(), function()
				if SERVER and IsValid(self) and IsValid(self.Owner) then
					self.Owner:StripWeapon(self.Gun)
				end
			end)
		elseif self:Clip1() == 0 and self.Owner:GetAmmoCount(self:GetPrimaryAmmoType()) > 0 then
			self:TakePrimaryAmmo(1)
			self:SetClip1(1)

			timer.Simple(vm:SequenceDuration(), function()
				if IsValid(self) then
					self:ChooseDrawAnim()
				end
			end)
		end
	end
end

function SWEP:PrimaryAttack()
	if (self:GetHolstering()) then
		if (self.ShootWhileHolster == false) then
			return
		else
			self:SetHolsteringEnd(CurTime() - 0.1)
			self:SetHolstering(false)
		end
	end

	if (self:GetReloading() and self.Shotgun and not self:GetShotgunPumping() and not self:GetShotgunNeedsPump()) then
		self:SetShotgunCancel(true)
		--[[
		self:SetShotgunInsertingShell(true)
		self:SetShotgunPumping(false)
		self:SetShotgunNeedsPump(true)
		self:SetReloadingEnd(CurTime()-1)
		]]
		--

		return
	end

	if self:IsSafety() then
		self:EmitSound("Weapon_AR2.Empty")
		return
	end

	if (self:GetChangingSilence()) then return end
	if (self:GetNearWallRatio() > 0.05) then return end
	if not self:OwnerIsValid() then return end

	if self.FiresUnderwater == false and self.Owner:WaterLevel() >= 3 then
		if self:CanPrimaryAttack() then
			self:SetNextPrimaryFire(CurTime() + 0.5)
			self:EmitSound("Weapon_AR2.Empty")
		end

		return
	end

	if (self.Owner:KeyDown(IN_USE) and self.CanBeSilenced and self.Owner:KeyPressed(ACT_VM_PRIMARYATTACK)) then
		if (self:CanPrimaryAttack() and not self:GetChangingSilence()) then
			--self:SetSilenced(!self:GetSilenced())
			success, tanim = self:ChooseSilenceAnim(not self:GetSilenced())
			self:SetChangingSilence(true)
			self:SetNextSilenceChange(CurTime() + self.SequenceLength[tanim])
			self:SetNextPrimaryFire(CurTime() + 1 / (self:GetRPM() / 60))
		end

		return
	end

	if self:GetNextPrimaryFire() > CurTime() then return end

	if self:GetReloading() then
		self:CompleteReload()
	end

	if not self:CanPrimaryAttack() then return end

	if self:CanPrimaryAttack() and self.Owner:IsPlayer() and self:GetRunSightsRatio() < 0.1 then
		self:ResetEvents()
		self:SetInspecting(false)
		self:SetInspectingRatio(0)
		self:SetInspectingRatio(0)
		self:SendWeaponAnim(0)

		timer.Simple(self.Delay and self.Delay or 0.3, function()
			if IsValid(self) then
				self:ShootBulletInformation()
			end
		end)

		success, tanim = self:ChooseShootAnim() -- View model animation

		if self:OwnerIsValid() and self.Owner.SetAnimation then
			self.Owner:SetAnimation(PLAYER_ATTACK1) -- 3rd Person Animation
		end

		self:TakePrimaryAmmo(1)
		self.PenetrationCounter = 0
		self:SetShooting(true)
		local vm = self.Owner:GetViewModel()

		if tanim then
			local seq = vm:SelectWeightedSequence(tanim)
			self:SetShootingEnd(CurTime() + vm:SequenceDuration(seq))
		else
			self:SetShootingEnd(CurTime() + vm:SequenceDuration())
		end

		if self.BoltAction then
			self:SetBoltTimer(true)
			local t1, t2
			t1 = CurTime() + self.BoltTimerOffset
			t2 = CurTime() + vm:SequenceDuration(seq)

			if t1 < t2 then
				self:SetBoltTimerStart(t1)
				self:SetBoltTimerEnd(t2)
			else
				self:SetBoltTimerStart(t2)
				self:SetBoltTimerEnd(t1)
			end
		end

		self:SetSpreadRatio(math.Clamp(self:GetSpreadRatio() + self.Primary.SpreadIncrement, 1, self.Primary.SpreadMultiplierMax))

		if (CLIENT or game.SinglePlayer()) and IsFirstTimePredicted() then
			self.CLSpreadRatio = math.Clamp(self.CLSpreadRatio + self.Primary.SpreadIncrement, 1, self.Primary.SpreadMultiplierMax)
		end

		self:SetBursting(true)
		self:SetNextBurst(CurTime() + 1 / (self:GetRPM() / 60))
		self:SetBurstCount(self:GetBurstCount() + 1)
		self:SetNextPrimaryFire(CurTime() + 1 / (self:GetRPM() / 60))

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

		self:DoAmmoCheck()
	end
end
