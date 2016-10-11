DEFINE_BASECLASS("tfa_gun_base")
SWEP.Primary.RPM = 120 --Primary Slashs per minute
SWEP.Secondary.RPM = 60 --Secondary stabs per minute
SWEP.SlashDelay = 0.15 --Delay for hull (primary)
SWEP.StabDelay = 0.33 --Delay for hull (secondary)
SWEP.SlashLength = 32
SWEP.StabLength = 24
SWEP.Primary.Sound = Sound("Weapon_Knife.hull") --Sounds
SWEP.KnifeShink = "Weapon_Knife.HitWall" --Sounds
SWEP.KnifeSlash = "Weapon_Knife.Hit" --Sounds
SWEP.KnifeStab = "Weapon_Knife.hull" --Sounds
SWEP.SlashTable = {"midslash1", "midslash2"} --Table of possible hull sequences
SWEP.StabTable = {"hull"} --Table of possible hull sequences
SWEP.StabMissTable = {"stab_miss"} --Table of possible hull sequences
SWEP.DisableIdleAnimations = false --Enable idles
--[[ Don't Edit Below ]]--
SWEP.DamageType = DMG_SLASH
SWEP.MuzzleFlashEffect = "" --No muzzle
SWEP.DoMuzzleFlash = false --No muzzle
SWEP.WeaponLength = 1 --No nearwall
SWEP.Primary.Ammo = "" -- pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, AirboatGun
SWEP.Primary.ClipSize = 1 -- Size of a clip
SWEP.Primary.DefaultClip = 1 -- Bullets you start with
SWEP.data = {} --No ironsights
SWEP.data.ironsights = 0 --No ironsights
SWEP.Callback = {}

SWEP.Callback.Deploy = function(self)
	self.Stab = math.random(1, #self.SlashTable)
	self.StabIndex = math.random(1, #self.SlashTable)
	self.StabMiss = math.random(1, #self.SlashTable)
end

local hull = {}

function SWEP:PrimaryAttack()
	vm = self.Owner:GetViewModel()
	if SERVER and self:GetNextPrimaryFire() < CurTime() and self.Owner:IsPlayer() then
		self:SendWeaponAnim(ACT_VM_IDLE)

		if not self.Owner:KeyDown(IN_SPEED) and not self.Owner:KeyDown(IN_RELOAD) then
			self.hull = self.hull + 1

			if self.hull > #self.SlashTable then
				self.hull = 1
			end

			vm:SendViewModelMatchingSequence(vm:LookupSequence(self.SlashTable[self.hull]))

			if game.SinglePlayer() then
				self:CallOnClient("AnimForce", self.SlashTable[self.hull])
			end

			self:EmitSound(self.Primary.Sound) --hull in the wind sound here

			timer.Create("cssslash" .. self:EntIndex(), self.SlashDelay, 1, function()
				if self then self:PrimarySlash() end
			end)

			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self:SetNextPrimaryFire(CurTime() + 1 / (self.Primary.RPM / 60))
			self:SetNextSecondaryFire(CurTime() + 1 / (self.Primary.RPM / 60))
			self:SetShooting(true)
			self:SetShootingEnd(CurTime() + 1 / (self.Primary.RPM / 60) * 3)
		end
	end
end

function SWEP:PrimarySlash()
	if not self:OwnerIsValid() then return end
	pos = self.Owner:GetShootPos()
	ang = self.Owner:GetAimVector()
	damagedice = math.Rand(.85, 1.25)
	dmgval = self.Primary.Damage * damagedice

	if not dmgval or dmgval <= 1 then
		dmgval = 40 * damagedice
	end

	self.Owner:LagCompensation(true)

	hull.start = pos
	hull.endpos = pos + (ang * self.SlashLength)
	hull.filter = self.Owner
	hull.mins = Vector(-10, -5, 0)
	hull.maxs = Vector(10, 5, 5)
	local slashtrace = util.TraceHull(hull)

	if slashtrace.Hit then
		if slashtrace.Entity == nil then return end

		if game.GetTimeScale() > 0.99 then
			self.Owner:FireBullets({
				Attacker = self.Owner,
				Inflictor = self,
				Damage = dmgval,
				Force = dmgval * 0.15,
				Distance = self.SlashLength + 10,
				HullSize = 12.5,
				Tracer = 0,
				Src = self.Owner:GetShootPos(),
				Dir = slashtrace.Normal,
				Callback = function(a, b, c)
					if c then
						c:SetDamageType(DMG_SLASH)
					end
				end
			})
		else
			local dmg = DamageInfo()
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self)
			dmg:SetDamagePosition(self.Owner:GetShootPos())
			dmg:SetDamageForce(self.Owner:GetAimVector() * (dmgval * 0.25))
			dmg:SetDamage(dmgval)
			dmg:SetDamageType(DMG_SLASH)
			slashtrace.Entity:TakeDamageInfo(dmg)
		end

		targ = slashtrace.Entity

		if slashtrace.MatType == MAT_FLESH or slashtrace.MatType == MAT_ALIENFLESH then
			self:EmitSound(self.KnifeSlash)
		else
			self:EmitSound(self.KnifeShink)
		end
	end

	self.Owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
	pos = self.Owner:GetShootPos()
	ang = self.Owner:GetAimVector()
	vm = self.Owner:GetViewModel()

	if self:GetNextSecondaryFire() < CurTime() and self.Owner:IsPlayer() then
		self:SendWeaponAnim(ACT_VM_IDLE)

		if not self.Owner:KeyDown(IN_SPEED) and not self.Owner:KeyDown(IN_RELOAD) then
			self:EmitSound(self.Primary.Sound)
			hull.start = pos
			hull.endpos = pos + (ang * self.StabLength)
			hull.filter = self.Owner
			hull.mins = Vector(-10, -5, 0)
			hull.maxs = Vector(10, 5, 5)
			local stabtrace = util.TraceHull(hull)

			if stabtrace.Hit then
				self.StabIndex = self.StabIndex + 1

				if self.StabIndex > #self.StabTable then
					self.StabIndex = 1
				end

				vm:SendViewModelMatchingSequence(vm:LookupSequence(self.StabTable[self.StabIndex]))

				if game.SinglePlayer() then
					self:CallOnClient("AnimForce", self.StabTable[self.StabIndex])
				end
			else
				self.StabMiss = self.StabMiss + 1

				if self.StabMiss > #self.StabMissTable then
					self.StabMiss = 1
				end

				vm:SendViewModelMatchingSequence(vm:LookupSequence(self.StabMissTable[self.StabMiss]))

				if game.SinglePlayer() then
					self:CallOnClient("AnimForce", self.StabMissTable[self.StabMiss])
				end
			end

			timer.Create("cssstab" .. self:EntIndex(), self.StabDelay, 1, function()
				if not IsValid(self) then return end

				if self.Owner and self then
					self:Stab()
				end
			end)

			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self:SetNextPrimaryFire(CurTime() + 1 / (self.Secondary.RPM / 60))
			self:SetNextSecondaryFire(CurTime() + 1 / (self.Secondary.RPM / 60))
			self:SetShooting(true)
			self:SetShootingEnd(CurTime() + 1.24)
		end
	end
end

function SWEP:Stab()
	if not self:OwnerIsValid() then return end
	pos2 = self.Owner:GetShootPos()
	ang2 = self.Owner:GetAimVector()
	damagedice = math.Rand(.85, 1.25)
	dmgval = self.Secondary.Damage * damagedice

	if not dmgval or dmgval <= 1 then
		dmgval = 100 * damagedice
	end

	self.Owner:LagCompensation(true)
	local stab2 = {}
	stab2.start = pos2
	stab2.endpos = pos2 + (ang2 * 24)
	stab2.filter = self.Owner
	stab2.mins = Vector(-10, -5, 0)
	stab2.maxs = Vector(10, 5, 5)
	local stabtrace2 = util.TraceHull(stab2)
	if stabtrace2.Hit then
		if stabtrace2.Entity == nil then return end

		if game.GetTimeScale() > 0.99 then
			self.Owner:FireBullets({
				Attacker = self.Owner,
				Inflictor = self,
				Damage = dmgval,
				Force = dmgval * 0.15,
				Distance = self.StabLength + 10,
				HullSize = 12.5,
				Tracer = 0,
				Src = self.Owner:GetShootPos(),
				Dir = stabtrace2.Normal,
				Callback = function(a, b, c)
					if c then
						c:SetDamageType(DMG_SLASH)
					end
				end
			})
		else
			local dmg = DamageInfo()
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self)
			dmg:SetDamagePosition(self.Owner:GetShootPos())
			dmg:SetDamageForce(self.Owner:GetAimVector() * (dmgval * 0.25))
			dmg:SetDamage(dmgval)
			dmg:SetDamageType(DMG_SLASH)
			stabtrace2.Entity:TakeDamageInfo(dmg)
		end

		targ = stabtrace2.Entity

		if stabtrace2.MatType == MAT_FLESH or stabtrace2.MatType == MAT_ALIENFLESH then
			self:EmitSound(self.KnifeSlash)
		else
			self:EmitSound(self.KnifeShink)
		end
	end


	self.Owner:LagCompensation(false)
end

function SWEP:ThrowKnife()
	if not IsFirstTimePredicted() then return end
	self:EmitSound(self.Primary.Sound)

	if SERVER then
		local knife = ents.Create("tfa_thrown_blade")

		if IsValid(knife) then
			knife:SetAngles(self.Owner:EyeAngles())
			knife:SetPos(self.Owner:GetShootPos())
			knife:SetOwner(self.Owner)
			knife:SetModel(self.WorldModel)
			knife:SetPhysicsAttacker(self.Owner)
			knife:Spawn()
			knife:Activate()
			knife:SetNWString("Wep", self.Gun)
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			local phys = knife:GetPhysicsObject()
			phys:SetVelocity(self.Owner:GetAimVector() * 1500)
			phys:AddAngleVelocity(Vector(0, 500, 0))
			self.Owner:StripWeapon(self.Gun)
		end
	end
end

function SWEP:Reload()
	if not self:OwnerIsValid() and self.Owner:KeyDown(IN_RELOAD) then return end
	self:ThrowKnife()
end

SWEP.IsKnife = true
SWEP.WeaponLength = 8
