local bullet = {}
bullet.Spread = Vector()

local function DisableOwnerDamage(a,b,c)
	if b.Entity == a and c then
		c:ScaleDamage(0)
	end
end

local function DirectDamage(a,b,c)
	if c then
		c:SetDamageType(DMG_DIRECT)
	end
end

--[[
Function Name:  ToggleAkimbo
Syntax: self:ToggleAkimbo( ).
Returns:   Nothing.
Notes:    Used to toggle the akimbo value.
Purpose:  Bullet
]]--
function SWEP:ToggleAkimbo()
	if self.Callback.ToggleAkimbo then
		local val = self.Callback.ToggleAkimbo(self)
		if val then return val end
	end

	if self.Akimbo then
		self.AnimCycle = 1 - self.AnimCycle
	end

	self.MuzzleAttachmentRaw = 2 - self.AnimCycle
end

--[[
Function Name:  ShootBulletInformation
Syntax: self:ShootBulletInformation( ).
Returns:   Nothing.
Notes:    Used to generate a bullet table which is then sent to self:ShootBullet, and also to call shooteffects.
Purpose:  Bullet
]]--
local cv_dmg_mult = GetConVar("sv_tfa_damage_multiplier")
local cv_dmg_mult_min = GetConVar("sv_tfa_damage_mult_min")
local cv_dmg_mult_max = GetConVar("sv_tfa_damage_mult_max")

function SWEP:ShootBulletInformation(ifp)
	if self.Callback.ShootBulletInformation then
		local val = self.Callback.ShootBulletInformation(self, ifp)
		if val then return val end
	end

	self.lastbul = nil
	self.lastbulnoric = false
	self.ConDamageMultiplier = cv_dmg_mult:GetFloat()
	if (CLIENT and not game.SinglePlayer()) and not ifp then return end

	if SERVER and game.SinglePlayer() and self.Akimbo then
		self:CallOnClient("ToggleAkimbo", "")
	end

	self:ToggleAkimbo()
	local CurrentDamage
	local CurrentCone, CurrentRecoil = self:CalculateConeRecoil()
	local tmpranddamage = math.Rand( cv_dmg_mult_min:GetFloat(), cv_dmg_mult_max:GetFloat())
	basedamage = self.ConDamageMultiplier * self.Primary.Damage
	CurrentDamage = basedamage * tmpranddamage

	--[[
	if self.DoMuzzleFlash and ( (SERVER) or ( CLIENT and !self.AutoDetectMuzzleAttachment ) or (CLIENT and !self:IsFirstPerson() ) ) then
	self:ShootEffects()
end
]]--
if not self.AutoDetectMuzzleAttachment then
	self:ShootEffectsCustom(ifp)
end

local ns = self.Primary.NumShots
local clip = (self.Primary.ClipSize == -1) and self:Ammo1() or self:Clip1()
ns = math.Round(ns, math.min(clip / self.Primary.NumShots, 1))
self:ShootBullet(CurrentDamage, CurrentRecoil, ns, CurrentCone)
end

--[[
Function Name:  ShootBullet
Syntax: self:ShootBullet(damage, recoil, number of bullets, spray cone, disable ricochet, override the generated bullet table with this value if you send it).
Returns:   Nothing.
Notes:    Used to shoot a bullet.
Purpose:  Bullet
]]--
local TracerName
local cv_forcemult = GetConVar("sv_tfa_force_multiplier")

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
	if self.Callback.ShootBullet then
		local val = self.Callback.ShootBullet(self, damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
		if val then return val end
	end

	if (CLIENT and not game.SinglePlayer()) and not IsFirstTimePredicted() then return end
	num_bullets = num_bullets or 1
	aimcone = aimcone or 0

	if self.ProjectileEntity then
		if SERVER then

			for i = 1, num_bullets do
				local ent = ents.Create(self.ProjectileEntity)
				local dir
				local ang = self.Owner:EyeAngles()
				ang:RotateAroundAxis(ang:Right(), -aimcone / 2 + math.Rand(0, aimcone))
				ang:RotateAroundAxis(ang:Up(), -aimcone / 2 + math.Rand(0, aimcone))
				dir = ang:Forward()
				ent:SetPos(self.Owner:GetShootPos())
				ent.Owner = self.Owner
				ent:SetAngles(self.Owner:EyeAngles())
				ent.damage = self.Primary.Damage
				ent.mydamage = self.Primary.Damage

				if self.ProjectileModel then
					ent:SetModel(self.ProjectileModel)
				end

				ent:Spawn()
				ent:SetVelocity(dir * self.ProjectileVelocity)
				local phys = ent:GetPhysicsObject()

				if IsValid(phys) then
					phys:SetVelocity(dir * self.ProjectileVelocity)
				end

				if self.ProjectileModel then
					ent:SetModel(self.ProjectileModel)
				end

				ent:SetOwner(self.Owner)
				ent.Owner = self.Owner
			end
		end
		-- Source
		-- Dir of bullet
		-- Aim Cone X
		-- Aim Cone Y
		-- Show a tracer on every x bullets
		-- Amount of force to give to phys objects
	else
		if self.Tracer == 1 then
			TracerName = "Ar2Tracer"
		elseif self.Tracer == 2 then
			TracerName = "AirboatGunHeavyTracer"
		else
			TracerName = "Tracer"
		end

		if self.TracerName and self.TracerName ~= "" then
			TracerName = self.TracerName
		end

		bullet.Attacker = self.Owner
		bullet.Inflictor = self
		bullet.Num = num_bullets
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.HullSize = self.Primary.HullSize or 0
		bullet.Spread.x = aimcone
		bullet.Spread.y = aimcone
		bullet.Tracer = self.TracerCount and self.TracerCount or 3
		bullet.TracerName = TracerName
		bullet.PenetrationCount = 0
		bullet.AmmoType = self:GetPrimaryAmmoType()
		bullet.Force = self.Primary.Force * cv_forcemult:GetFloat()
		bullet.Damage = damage
		bullet.HasAppliedRange = false

		if self.CustomBulletCallback then
			bullet.Callback2 = self.CustomBulletCallback
		end

		bullet.Callback = function(a, b, c)
			if IsValid(self) then

				DisableOwnerDamage(a,b,c)

				if bullet.Callback2 then
					bullet.Callback2(a, b, c)
				end

				bullet:Penetrate(a, b, c, self)
			end
		end

		self.Owner:FireBullets(bullet)
	end
end

function SWEP:Recoil(recoil, ifp)
	math.randomseed(CurTime() + 1)

	self.Owner:SetVelocity( -self.Owner:GetAimVector() * self.Primary.Knockback * cv_forcemult:GetFloat() * recoil / 5  )

	local tmprecoilang = Angle(math.Rand(self.Primary.KickDown, self.Primary.KickUp) * recoil * -1, math.Rand(-self.Primary.KickHorizontal, self.Primary.KickHorizontal) * recoil, 0)
	local maxdist = math.min(math.max(0, 89 + self.Owner:EyeAngles().p - math.abs(self.Owner:GetViewPunchAngles().p * 2)), 88.5)
	local tmprecoilangclamped = Angle(math.Clamp(tmprecoilang.p, -maxdist, maxdist), tmprecoilang.y, 0)
	self.Owner:ViewPunch(tmprecoilangclamped * (1 - self.Primary.StaticRecoilFactor))

	if (game.SinglePlayer() and SERVER) or (CLIENT and ifp) then
		local neweyeang = self.Owner:EyeAngles() + tmprecoilang * self.Primary.StaticRecoilFactor
		--neweyeang.p = math.Clamp(neweyeang.p, -90 + math.abs(self.Owner:GetViewPunchAngles().p), 90 - math.abs(self.Owner:GetViewPunchAngles().p))
		self.Owner:SetEyeAngles(neweyeang)
	end
end

local decalbul = {
	Num = 1,
	Spread = vector_origin,
	Tracer = 0,
	Force = 0.5,
	Damage = 0.1
}

local maxpen
local penetration_max_cvar = GetConVar("sv_tfa_penetration_limit")
local penetration_cvar = GetConVar("sv_tfa_bullet_penetration")
local ricochet_cvar = GetConVar("sv_tfa_bullet_ricochet")
local cv_rangemod = GetConVar("sv_tfa_range_modifier")
local cv_decalbul = GetConVar("sv_tfa_fx_penetration_decal")
local rngfac
local mfac

function bullet:Penetrate(ply, traceres, dmginfo, weapon)
	if not IsValid(weapon) then return end
	local hitent = traceres.Entity
	self:HandleDoor(ply, traceres, dmginfo, weapon)

	if not self.HasAppliedRange then
		local bulletdistance = (traceres.HitPos - traceres.StartPos):Length()
		local damagescale = bulletdistance / weapon.Primary.Range
		damagescale = math.Clamp(damagescale - weapon.Primary.RangeFalloff, 0, 1)
		damagescale = math.Clamp(damagescale / math.max(1 - weapon.Primary.RangeFalloff, 0.01), 0, 1)
		damagescale = (1 - cv_rangemod:GetFloat() ) + (math.Clamp(1 - damagescale, 0, 1) * cv_rangemod:GetFloat() )
		dmginfo:ScaleDamage(damagescale)
		self.HasAppliedRange = true
	end

	dmginfo:SetDamageType(weapon.Primary.DamageType)

	if SERVER and IsValid(ply) and ply:IsPlayer() and IsValid(hitent) and (hitent:IsPlayer() or hitent:IsNPC()) then
		net.Start("tfaHitmarker")
		net.Send(ply)
	end

	if weapon.Primary.DamageType ~= DMG_BULLET then
		if ( dmginfo:IsDamageType(DMG_SHOCK) or dmginfo:IsDamageType(DMG_BLAST) ) and traceres.Hit and IsValid(hitent) and hitent:GetClass() == "npc_strider" then
			hitent:SetHealth(math.max(hitent:Health() - dmginfo:GetDamage(), 2))

			if hitent:Health() <= 3 then
				hitent:Extinguish()
				hitent:Fire("sethealth", "-1", 0.01)
				dmginfo:ScaleDamage(0)
			end
		end

		if dmginfo:IsDamageType(DMG_BURN) and traceres.Hit and IsValid(hitent) and not traceres.HitWorld and not traceres.HitSky and dmginfo:GetDamage() > 1 and hitent.Ignite then
			hitent:Ignite(dmginfo:GetDamage() / 2, 1)
		end

		if dmginfo:IsDamageType(DMG_BLAST) and traceres.Hit and not traceres.HitSky then
			local tmpdmg = dmginfo:GetDamage()
			util.BlastDamage(weapon, weapon.Owner, traceres.HitPos, tmpdmg / 2, tmpdmg)
			local fx = EffectData()
			fx:SetOrigin(traceres.HitPos)
			fx:SetNormal(traceres.HitNormal)

			if tmpdmg > 90 then
				util.Effect("Explosion", fx)
			elseif tmpdmg > 45 then
				util.Effect("cball_explode", fx)
			else
				util.Effect("ManhackSparks", fx)
			end

			dmginfo:ScaleDamage(0.15)
		end
	end

	if penetration_cvar and not penetration_cvar:GetBool() then return end
	if self:Ricochet(ply, traceres, dmginfo, weapon) then return end
	maxpen = math.min(penetration_max_cvar and penetration_max_cvar:GetInt() - 1 or 1, weapon.MaxPenetrationCounter)
	if self.PenetrationCount > maxpen then return end
	local mult = weapon:GetPenetrationMultiplier(traceres.MatType)
	penetrationoffset = traceres.Normal * math.Clamp(self.Force * mult, 0, 32)
	local pentrace = {}
	pentrace.endpos = traceres.HitPos
	pentrace.start = traceres.HitPos + penetrationoffset
	pentrace.mask = MASK_SHOT
	pentrace.filter = {}
	pentraceres = util.TraceLine(pentrace)
	if (pentraceres.StartSolid or pentraceres.Fraction >= 1.0 or pentraceres.Fraction <= 0.0) then return end
	self.Src = pentraceres.HitPos

	if (self.Num or 0) <= 1 then
		self.Spread = Vector(0, 0, 0)
	end

	self.Tracer = 0 --weapon.TracerName and 0 or 1
	self.TracerName = ""
	rngfac = math.pow(pentraceres.HitPos:Distance(traceres.HitPos) / penetrationoffset:Length(), 2)
	mfac = math.pow(mult / 10, 0.35)
	self.Force = Lerp(rngfac, self.Force, self.Force * mfac)
	self.Damage = Lerp(rngfac, self.Damage, self.Damage * mfac)
	self.Spread = self.Spread / math.sqrt(mfac)
	self.PenetrationCount = self.PenetrationCount + 1
	self.HullSize = 0
	decalbul.Dir = -traceres.Normal * 64

	if IsValid(ply) and ply:IsPlayer() then
		decalbul.Dir = self.Attacker:EyeAngles():Forward() * (-64)
	end

	decalbul.Src = pentraceres.HitPos - decalbul.Dir * 4
	decalbul.Damage = 0.1
	decalbul.Force = 0.1
	decalbul.Tracer = 0
	decalbul.TracerName = ""
	decalbul.Callback = DirectDamage
	local fx = EffectData()
	fx:SetOrigin(self.Src)
	fx:SetNormal(self.Dir + VectorRand() * self.Spread)
	fx:SetMagnitude(1)
	fx:SetEntity(weapon)
	util.Effect("tfa_penetrate", fx)

	if IsValid(ply) then
		if ply:IsPlayer() then
			self.Dir = self.Attacker:EyeAngles():Forward()
		end

		timer.Simple(0, function()
			if IsValid(ply) then
				if cv_decalbul:GetBool() then
					ply:FireBullets(decalbul)
				end
				ply:FireBullets(self)
			end
		end)
	end
end

function bullet:Ricochet(ply, traceres, dmginfo, weapon)
	if ricochet_cvar and not ricochet_cvar:GetBool() then return end
	maxpen = math.min(penetration_max_cvar and penetration_max_cvar:GetInt() - 1 or 1, weapon.MaxPenetrationCounter)
	if self.PenetrationCount > maxpen then return end
	--[[
	]]
	--
	local matname = weapon:GetMaterialConcise(traceres.MatType)
	local ricochetchance = 1
	local dir = traceres.HitPos - traceres.StartPos
	dir:Normalize()
	local dp = dir:Dot(traceres.HitNormal * -1)

	if matname == "glass" then
		ricochetchance = 0
	elseif matname == "plastic" then
		ricochetchance = 0.01
	elseif matname == "dirt" then
		ricochetchance = 0.01
	elseif matname == "grass" then
		ricochetchance = 0.01
	elseif matname == "sand" then
		ricochetchance = 0.01
	elseif matname == "ceramic" then
		ricochetchance = 0.15
	elseif matname == "metal" then
		ricochetchance = 0.7
	elseif matname == "default" then
		ricochetchance = 0.5
	else
		ricochetchance = 0
	end

	ricochetchance = ricochetchance * 0.5 * weapon:GetAmmoRicochetMultiplier()
	local riccbak = ricochetchance / 0.7
	local ricothreshold = 0.6
	ricochetchance = math.Clamp(ricochetchance + ricochetchance * math.Clamp(1 - (dp + ricothreshold), 0, 1) * 0.5, 0, 1)

	if dp <= ricothreshold and math.Rand(0, 1) < ricochetchance then
		self.Damage = self.Damage * 0.5
		self.Force = self.Force * 0.5
		self.Num = 1
		self.Spread = vector_origin
		self.Src = traceres.HitPos
		self.Dir = ((2 * traceres.HitNormal * dp) + traceres.Normal) + (VectorRand() * 0.02)
		self.Tracer = 0

		if TFA.GetRicochetEnabled() then
			local fx = EffectData()
			fx:SetOrigin(self.Src)
			fx:SetNormal(self.Dir)
			fx:SetMagnitude(riccbak)
			util.Effect("tfa_ricochet", fx)
		end

		timer.Simple(0, function()
			if IsValid(ply) then
				ply:FireBullets(self)
			end
		end)

		self.PenetrationCount = self.PenetrationCount + 1

		return true
	end
end

local defaultdoorhealth = 250
local ohp = 250

local cv_doorres = GetConVar("sv_tfa_door_respawn")
function bullet:MakeDoor(ent, dmginfo)
	pos = ent:GetPos()
	ang = ent:GetAngles()
	mdl = ent:GetModel()
	ski = ent:GetSkin()
	ent:SetNotSolid(true)
	ent:SetNoDraw(true)
	prop = ents.Create("prop_physics")
	prop:SetPos(pos)
	prop:SetAngles(ang)
	prop:SetModel(mdl)
	prop:SetSkin(ski or 0)
	prop:Spawn()
	prop:SetVelocity(dmginfo:GetDamageForce())
	prop:GetPhysicsObject():ApplyForceOffset(dmginfo:GetDamageForce(), dmginfo:GetDamagePosition())
	prop:SetPhysicsAttacker(dmginfo:GetAttacker())
	prop:EmitSound("physics/wood/wood_furniture_break" .. tostring(math.random(1, 2)) .. ".wav", 110, math.random(90, 110))

	if cv_doorres:GetInt() ~= -1 then
		timer.Simple(cv_doorres:GetFloat(), function()
			if IsValid(prop) then
				prop:Remove()
			end

			if IsValid(ent) then
				ent.TFADoorHealth = defaultdoorhealth
				ent:SetNotSolid(false)
				ent:SetNoDraw(false)
			end
		end)
	end
end

function bullet:HandleDoor(ply, traceres, dmginfo, wep)
	local ent = traceres.Entity
	if not IsValid(ent) then return end
	if not ents.Create then return end
	ent.TFADoorHealth = ent.TFADoorHealth or defaultdoorhealth
	if bit.band(wep.Primary.DamageType or 0, DMG_AIRBOAT) == DMG_AIRBOAT and (ent:GetClass() == "func_door_rotating" or ent:GetClass() == "prop_door_rotating") then
		ohp = ent.TFADoorHealth
		ent.TFADoorHealth = ent.TFADoorHealth - dmginfo:GetDamage()

		if ent.TFADoorHealth <= 0 then
			if ( (self.Damage * self.Num > 150) or ent.TFADoorHealth < -defaultdoorhealth * 0.66 or not IsValid(ply) or not ply.SetName ) then
				self:MakeDoor(ent, dmginfo)
				ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(90, 110))
			elseif math.random( math.max(1, 3 - wep.Primary.NumShots ) ) == 1 then
				if ohp > 0 then
					ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(90, 110))
				end
				ply.oldname = ply:GetName()
				ply:SetName("bashingpl" .. ply:EntIndex())
				ent:SetKeyValue("Speed", "500")
				ent:SetKeyValue("Open Direction", "Both directions")
				ent:SetKeyValue("opendir", "0")
				ent:Fire("unlock", "", .01)
				ent:Fire("openawayfrom", "bashingpl" .. ply:EntIndex(), .01)

				timer.Simple(0.02, function()
					if IsValid(ply) then
						ply:SetName(ply.oldname)
					end
				end)

				timer.Simple(0.3, function()
					if IsValid(ent) then
						ent:SetKeyValue("Speed", "100")
					end
				end)
			end
		end
	end
end