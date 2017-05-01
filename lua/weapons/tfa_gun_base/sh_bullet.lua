local l_mathClamp = math.Clamp
SWEP.MainBullet = {}
SWEP.MainBullet.Spread = Vector()

local function DisableOwnerDamage(a, b, c)
	if b.Entity == a and c then
		c:ScaleDamage(0)
	end
end

local function DirectDamage(a, b, c)
	if c then
		c:SetDamageType(DMG_DIRECT)
	end
end

--[[
Function Name:  ShootBulletInformation
Syntax: self:ShootBulletInformation( ).
Returns:   Nothing.
Notes:    Used to generate a self.MainBullet table which is then sent to self:ShootBullet, and also to call shooteffects.
Purpose:  Bullet
]]
--
local cv_dmg_mult = GetConVar("sv_tfa_damage_multiplier")
local cv_dmg_mult_min = GetConVar("sv_tfa_damage_mult_min")
local cv_dmg_mult_max = GetConVar("sv_tfa_damage_mult_max")
local dmg, con, rec

function SWEP:ShootBulletInformation()
	self:UpdateConDamage()
	self.lastbul = nil
	self.lastbulnoric = false
	self.ConDamageMultiplier = cv_dmg_mult:GetFloat()
	if not IsFirstTimePredicted() then return end
	con, rec = self:CalculateConeRecoil()
	local tmpranddamage = math.Rand(cv_dmg_mult_min:GetFloat(), cv_dmg_mult_max:GetFloat())
	basedamage = self.ConDamageMultiplier * self:GetStat("Primary.Damage")
	dmg = basedamage * tmpranddamage
	local ns = self:GetStat("Primary.NumShots")
	local clip = (self:GetStat("Primary.ClipSize") == -1) and self:Ammo1() or self:Clip1()
	ns = math.Round(ns, math.min(clip / self:GetStat("Primary.NumShots"), 1))
	self:ShootBullet(dmg, rec, ns, con)
end

--[[
Function Name:  ShootBullet
Syntax: self:ShootBullet(damage, recoil, number of bullets, spray cone, disable ricochet, override the generated self.MainBullet table with this value if you send it).
Returns:   Nothing.
Notes:    Used to shoot a self.MainBullet.
Purpose:  Bullet
]]
--
local TracerName
local cv_forcemult = GetConVar("sv_tfa_force_multiplier")

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
	if not IsFirstTimePredicted() and not game.SinglePlayer() then return end
	num_bullets = num_bullets or 1
	aimcone = aimcone or 0

	if self:GetStat("Primary.Projectile") then
		if SERVER then
			for i = 1, num_bullets do
				local ent = ents.Create(self:GetStat("Primary.Projectile"))
				local dir
				local ang = self:GetOwner():EyeAngles()
				ang:RotateAroundAxis(ang:Right(), -aimcone / 2 + math.Rand(0, aimcone))
				ang:RotateAroundAxis(ang:Up(), -aimcone / 2 + math.Rand(0, aimcone))
				dir = ang:Forward()
				ent:SetPos(self:GetOwner():GetShootPos())
				ent:SetOwner( self:GetOwner() )
				ent:SetAngles(self:GetOwner():EyeAngles())
				ent.damage = self:GetStat("Primary.Damage")
				ent.mydamage = self:GetStat("Primary.Damage")

				if self:GetStat("Primary.ProjectileModel") then
					ent:SetModel(self:GetStat("Primary.ProjectileModel"))
				end

				ent:Spawn()
				ent:SetVelocity(dir * self:GetStat("Primary.ProjectileVelocity"))
				local phys = ent:GetPhysicsObject()

				if IsValid(phys) then
					phys:SetVelocity(dir * self:GetStat("Primary.ProjectileVelocity"))
				end

				if self.ProjectileModel then
					ent:SetModel(self:GetStat("Primary.ProjectileModel"))
				end

				ent:SetOwner(self:GetOwner())
			end
		end
		-- Source
		-- Dir of self.MainBullet
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

		self.MainBullet.PCFTracer = nil

		if self.TracerName and self.TracerName ~= "" then
			if self.TracerPCF then
				TracerName = nil
				self.MainBullet.PCFTracer = self.TracerName
				self.MainBullet.Tracer = 0
			else
				TracerName = self.TracerName
			end
		end

		self.MainBullet.Attacker = self:GetOwner()
		self.MainBullet.Inflictor = self
		self.MainBullet.Num = num_bullets
		self.MainBullet.Src = self:GetOwner():GetShootPos()
		self.MainBullet.Dir = self:GetOwner():GetAimVector()
		self.MainBullet.HullSize = self:GetStat("Primary.HullSize") or 0
		self.MainBullet.Spread.x = aimcone
		self.MainBullet.Spread.y = aimcone
		if self.TracerPCF then
			self.MainBullet.Tracer = 0
		else
			self.MainBullet.Tracer = self.TracerCount and self.TracerCount or 3
		end
		self.MainBullet.TracerName = TracerName
		self.MainBullet.PenetrationCount = 0
		self.MainBullet.AmmoType = self:GetPrimaryAmmoType()
		self.MainBullet.Force = damage / 6 * math.sqrt(self:GetStat("Primary.KickUp") + self:GetStat("Primary.KickDown") + self:GetStat("Primary.KickHorizontal")) * cv_forcemult:GetFloat() * self:GetAmmoForceMultiplier()
		self.MainBullet.Damage = damage
		self.MainBullet.HasAppliedRange = false

		if self.CustomBulletCallback then
			self.MainBullet.Callback2 = self.CustomBulletCallback
		end

		self.MainBullet.Callback = function(a, b, c)
			if IsValid(self) then
				if self.MainBullet.Callback2 then
					self.MainBullet.Callback2(a, b, c)
				end

				self.MainBullet:Penetrate(a, b, c, self)

				self:PCFTracer( self.MainBullet, b.HitPos or vector_origin )
			end
		end

		self:GetOwner():FireBullets(self.MainBullet)
	end
end

sp = game.SinglePlayer()

function SWEP:Recoil(recoil, ifp)
	if sp and type(recoil) == "string" then
		local _, CurrentRecoil = self:CalculateConeRecoil()
		self:Recoil(CurrentRecoil, true)

		return
	end

	if ifp then
		self.SpreadRatio = l_mathClamp(self.SpreadRatio + self:GetStat("Primary.SpreadIncrement"), 1, self:GetStat("Primary.SpreadMultiplierMax"))
	end

	math.randomseed( self:GetSeed() + 1 )
	self:GetOwner():SetVelocity(-self:GetOwner():GetAimVector() * self:GetStat("Primary.Knockback") * cv_forcemult:GetFloat() * recoil / 5)
	local tmprecoilang = Angle(math.Rand(self:GetStat("Primary.KickDown"), self:GetStat("Primary.KickUp")) * recoil * -1, math.Rand(-self:GetStat("Primary.KickHorizontal"), self:GetStat("Primary.KickHorizontal")) * recoil, 0)
	local maxdist = math.min(math.max(0, 89 + self:GetOwner():EyeAngles().p - math.abs(self:GetOwner():GetViewPunchAngles().p * 2)), 88.5)
	local tmprecoilangclamped = Angle(math.Clamp(tmprecoilang.p, -maxdist, maxdist), tmprecoilang.y, 0)
	self:GetOwner():ViewPunch(tmprecoilangclamped * (1 - self:GetStat("Primary.StaticRecoilFactor")))

	if (game.SinglePlayer() and SERVER) or (CLIENT and ifp) then
		local neweyeang = self:GetOwner():EyeAngles() + tmprecoilang * self:GetStat("Primary.StaticRecoilFactor")
		--neweyeang.p = math.Clamp(neweyeang.p, -90 + math.abs(self:GetOwner():GetViewPunchAngles().p), 90 - math.abs(self:GetOwner():GetViewPunchAngles().p))
		self:GetOwner():SetEyeAngles(neweyeang)
	end
end

--[[
Function Name:  GetAmmoRicochetMultiplier
Syntax: self:GetAmmoRicochetMultiplier( ).
Returns:  The ricochet multiplier for our ammotype.  More is more chance to ricochet.
Notes:    Only compatible with default ammo types, unless you/I mod that.  BMG ammotype is detected based on name and category.
Purpose:  Utility
]]
--
function SWEP:GetAmmoRicochetMultiplier()
	local am = string.lower(self:GetStat("Primary.Ammo"))

	if (am == "pistol") then
		return 1.25
	elseif (am == "357") then
		return 0.75
	elseif (am == "smg1") then
		return 1.1
	elseif (am == "ar2") then
		return 0.9
	elseif (am == "buckshot") then
		return 2
	elseif (am == "slam") then
		return 1.5
	elseif (am == "airboatgun") then
		return 0.8
	elseif (am == "sniperpenetratedround") then
		return 0.5
	else
		return 1
	end
end

--[[
Function Name:  GetMaterialConcise
Syntax: self:GetMaterialConcise( ).
Returns:  The string material name.
Notes:    Always lowercase.
Purpose:  Utility
]]
--

function SWEP:GetAmmoForceMultiplier()
	-- pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, AirboatGun
	--AR2=Rifle ~= Caliber>.308
	--SMG1=SMG ~= Small/Medium Calber ~= 5.56 or 9mm
	--357=Revolver ~= .357 through .50 magnum
	--Pistol = Small or Pistol Bullets ~= 9mm, sometimes .45ACP but rarely.  Generally light.
	--Buckshot = Buckshot = Light, barely-penetrating sniper bullets.
	--Slam = Medium Shotgun Round
	--AirboatGun = Heavy, Penetrating Shotgun Round
	--SniperPenetratedRound = Heavy Large Rifle Caliber ~= .50 Cal blow-yer-head-off
	local am = string.lower(self:GetStat("Primary.Ammo"))

	if (am == "pistol") then
		return 0.4
	elseif (am == "357") then
		return 0.6
	elseif (am == "smg1") then
		return 0.475
	elseif (am == "ar2") then
		return 0.6
	elseif (am == "buckshot") then
		return 0.5
	elseif (am == "slam") then
		return 0.5
	elseif (am == "airboatgun") then
		return 0.7
	elseif (am == "sniperpenetratedround") then
		return 1
	else
		return 1
	end
end

--[[
Function Name:  GetMaterialConcise
Syntax: self:GetMaterialConcise( ).
Returns:  The string material name.
Notes:    Always lowercase.
Purpose:  Utility
]]
--
local matnamec = {
	[MAT_GLASS] = "glass",
	[MAT_GRATE] = "metal",
	[MAT_METAL] = "metal",
	[MAT_VENT] = "metal",
	[MAT_COMPUTER] = "metal",
	[MAT_CLIP] = "metal",
	[MAT_FLESH] = "flesh",
	[MAT_ALIENFLESH] = "flesh",
	[MAT_ANTLION] = "flesh",
	[MAT_FOLIAGE] = "foliage",
	[MAT_DIRT] = "dirt",
	[MAT_GRASS or MAT_DIRT] = "dirt",
	[MAT_EGGSHELL] = "plastic",
	[MAT_PLASTIC] = "plastic",
	[MAT_TILE] = "ceramic",
	[MAT_CONCRETE] = "ceramic",
	[MAT_WOOD] = "wood",
	[MAT_SAND] = "sand",
	[MAT_SNOW or 0] = "snow",
	[MAT_SLOSH] = "slime",
	[MAT_WARPSHIELD] = "energy",
	[89] = "glass",
	[-1] = "default"
}

function SWEP:GetMaterialConcise(mat)
	return matnamec[mat] or matnamec[-1]
end

--[[
Function Name:  GetPenetrationMultiplier
Syntax: self:GetPenetrationMultiplier( concise material name).
Returns:  The multilier for how much you can penetrate through a material.
Notes:    Should be used with GetMaterialConcise.
Purpose:  Utility
]]
--
local matfacs = {
	["metal"] = 2.5, --Since most is aluminum and stuff
	["wood"] = 8,
	["plastic"] = 5,
	["flesh"] = 8,
	["ceramic"] = 1.0,
	["glass"] = 10,
	["energy"] = 0.05,
	["sand"] = 0.7,
	["slime"] = 0.7,
	["dirt"] = 2.0, --This is plaster, not dirt, in most cases.
	["foliage"] = 6.5,
	["default"] = 4
}

local mat
local fac

function SWEP:GetPenetrationMultiplier(matt)
	mat = isstring(matt) and matt or self:GetMaterialConcise(matt)
	fac = matfacs[mat or "default"] or 4

	return fac * (self:GetStat("Primary.PenetrationMultiplier") and self:GetStat("Primary.PenetrationMultiplier") or 1)
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
local penetration_hitmarker_cvar = GetConVar("sv_tfa_penetration_hitmarker")
local ricochet_cvar = GetConVar("sv_tfa_bullet_ricochet")
local cv_rangemod = GetConVar("sv_tfa_range_modifier")
local cv_decalbul = GetConVar("sv_tfa_fx_penetration_decal")
local rngfac
local mfac
local atype

function SWEP:SetBulletTracerName( nm )
	self.BulletTracerName = nm or self.BulletTracerName or ""
end

function SWEP.MainBullet:Penetrate(ply, traceres, dmginfo, weapon)

	if self.TracerName and self.TracerName ~= "" then
		weapon.BulletTracerName = self.TracerName
		if game.SinglePlayer() then
			weapon:CallOnClient("SetBulletTracerName",weapon.BulletTracerName)
		end
	end

	DisableOwnerDamage(ply,traceres,dmginfo)
	if not IsValid(weapon) then return end
	local hitent = traceres.Entity
	self:HandleDoor(ply, traceres, dmginfo, weapon)

	if not self.HasAppliedRange then
		local bulletdistance = (traceres.HitPos - traceres.StartPos):Length()
		local damagescale = bulletdistance / weapon:GetStat("Primary.Range")
		damagescale = math.Clamp(damagescale - weapon:GetStat("Primary.RangeFalloff"), 0, 1)
		damagescale = math.Clamp(damagescale / math.max(1 - weapon:GetStat("Primary.RangeFalloff"), 0.01), 0, 1)
		damagescale = (1 - cv_rangemod:GetFloat()) + (math.Clamp(1 - damagescale, 0, 1) * cv_rangemod:GetFloat())
		dmginfo:ScaleDamage(damagescale)
		self.HasAppliedRange = true
	end

	atype = weapon:GetStat("Primary.DamageType")

	dmginfo:SetDamageType( atype )

	if SERVER and penetration_hitmarker_cvar:GetBool() and IsValid(ply) and ply:IsPlayer() and IsValid(hitent) and (hitent:IsPlayer() or hitent:IsNPC()) then
		net.Start("tfaHitmarker")
		net.Send(ply)
	end

	if IsValid(traceres.Entity) and traceres.Entity:GetClass() == "npc_sniper" then
		traceres.Entity.TFAHP = ( traceres.Entity.TFAHP or 100 ) - dmginfo:GetDamage()
		if traceres.Entity.TFAHP <= 0 then
			traceres.Entity:Fire("SetHealth","",-1)
		end
	end

	if atype ~= DMG_BULLET then
		if (dmginfo:IsDamageType(DMG_SHOCK) or dmginfo:IsDamageType(DMG_BLAST)) and traceres.Hit and IsValid(hitent) and hitent.Fire then
			local cl = hitent:GetClass()
			if cl == "npc_strider" then
				hitent:SetHealth(math.max(hitent:Health() - dmginfo:GetDamage(), 2))

				if hitent:Health() <= 3 then
					hitent:Extinguish()
					hitent:Fire("sethealth", "-1", 0.01)
					dmginfo:ScaleDamage(0)
				end

			end
		end

		if dmginfo:IsDamageType(DMG_BURN) and weapon.Primary.DamageTypeHandled and traceres.Hit and IsValid(hitent) and not traceres.HitWorld and not traceres.HitSky and dmginfo:GetDamage() > 1 and hitent.Ignite then
			hitent:Ignite(dmginfo:GetDamage() / 2, 1)
		end

		if dmginfo:IsDamageType(DMG_BLAST) and weapon.Primary.DamageTypeHandled and traceres.Hit and not traceres.HitSky then
			local tmpdmg = dmginfo:GetDamage()
			dmginfo:SetDamageForce( dmginfo:GetDamageForce() / 2)
			util.BlastDamageInfo(dmginfo,traceres.HitPos,tmpdmg / 2)
			--util.BlastDamage(weapon, weapon:GetOwner(), traceres.HitPos, tmpdmg / 2, tmpdmg)
			local fx = EffectData()
			fx:SetOrigin(traceres.HitPos)
			fx:SetNormal(traceres.HitNormal)

			if weapon.Primary.ImpactEffect then
				util.Effect( weapon.Primary.ImpactEffect, fx)
			elseif tmpdmg > 90 then
				util.Effect("HelicopterMegaBomb", fx)
				util.Effect("Explosion", fx)
			elseif tmpdmg > 45 then
				util.Effect("cball_explode", fx)
			else
				util.Effect("MuzzleEffect", fx)
			end

			dmginfo:ScaleDamage(0.15)
		end
	end

	if self:Ricochet(ply, traceres, dmginfo, weapon) then return end
	if penetration_cvar and not penetration_cvar:GetBool() then return end
	maxpen = math.min(penetration_max_cvar and (penetration_max_cvar:GetInt() - 1) or 1, weapon.Primary.MaxPenetration)
	if self.PenetrationCount > maxpen then return end
	local mult = weapon:GetPenetrationMultiplier(traceres.MatType)
	penetrationoffset = traceres.Normal * math.Clamp(self.Force * mult, 0, 32)
	local pentrace = {}
	pentrace.endpos = traceres.HitPos
	pentrace.start = traceres.HitPos + penetrationoffset
	pentrace.mask = MASK_SHOT
	pentrace.filter = {}
	pentraceres = util.TraceLine(pentrace)
	if IsValid(pentraceres.Entity) and pentraceres.Entity.IsNPC and ( pentraceres.Entity:IsNPC() or pentraceres.Entity:IsPlayer() ) then
		if IsValid(ply) and ply:IsPlayer() then
			self.Dir = self.Attacker:EyeAngles():Forward()
		end
		self.Src = traceres.HitPos + self.Dir * ( pentraceres.Entity:OBBMaxs() - pentraceres.Entity:OBBMins() ):Length2D()
		pentraceres.HitPos = self.Src
		pentraceres.Normal = self.Dir
		--debugoverlay.Sphere( self.Src, 5, 5, color_white, true)
	else
		if (pentraceres.StartSolid or pentraceres.Fraction >= 1.0 or pentraceres.Fraction <= 0.0) then return end
		self.Src = pentraceres.HitPos
	end

	if (self.Num or 0) <= 1 then
		self.Spread = Vector(0, 0, 0)
	end
	self.Tracer = 0 --weapon.TracerName and 0 or 1
	self.TracerName = ""
	rngfac = math.pow(pentraceres.HitPos:Distance(traceres.HitPos) / penetrationoffset:Length(), 2)
	mfac = math.pow(mult / 10, 0.35)
	self.Force = Lerp(rngfac, self.Force, self.Force * mfac)
	self.Damage = Lerp(rngfac, self.Damage, self.Damage * mfac)
	--self.Spread = self.Spread / math.sqrt(mfac)
	self.PenetrationCount = self.PenetrationCount + 1
	--self.HullSize = 0
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


	if self.PenetrationCount <= 1 and IsValid(weapon) then
	--	local tmpres = util.QuickTrace( pentraceres.HitPos or traceres.HitPos, self.Dir * 9999999, pentraceres.Entity )
	--	weapon:PCFTracer( self, tmpres.HitPos or traceres.HitPos, true )
		weapon:PCFTracer( self, pentraceres.HitPos or traceres.HitPos, true )
	end
	--else
		local fx = EffectData()
		fx:SetOrigin(self.Src)
		fx:SetNormal(self.Dir)
		if IsValid(ply) then
			fx:SetNormal( ply:EyeAngles():Forward() )
		end
		fx:SetMagnitude( ( self.PenetrationCount + 1 ) * 1000 )
		fx:SetEntity( weapon )
		if IsValid(pentraceres.Entity) and pentraceres.Entity.EntIndex then
			fx:SetScale( pentraceres.Entity:EntIndex() )
		end
		fx:SetRadius( self.Damage / 32 )
		util.Effect("tfa_penetrate", fx)
	--end
	if IsValid(ply) then
		timer.Simple(0, function()
			if IsValid(ply) and cv_decalbul:GetBool() then
				ply:FireBullets(decalbul)
			end
		end)

		ply:FireBullets(self)
	end
end

function SWEP.MainBullet:Ricochet(ply, traceres, dmginfo, weapon)
	DisableOwnerDamage(ply,traceres,dmginfo)
	if ricochet_cvar and not ricochet_cvar:GetBool() then return end
	maxpen = math.min(penetration_max_cvar and penetration_max_cvar:GetInt() - 1 or 1, weapon.Primary.MaxPenetration)
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

function SWEP.MainBullet:MakeDoor(ent, dmginfo)
	local dir = dmginfo:GetDamageForce():GetNormalized()
	local force = dir * math.max( math.sqrt( dmginfo:GetDamageForce():Length() / 1000 ), 1 ) * 1000
	pos = ent:GetPos()
	ang = ent:GetAngles()
	mdl = ent:GetModel()
	ski = ent:GetSkin()
	ent:SetNotSolid(true)
	ent:SetNoDraw(true)
	prop = ents.Create("prop_physics")
	prop:SetPos(pos + dir * 16 )
	prop:SetAngles(ang)
	prop:SetModel(mdl)
	prop:SetSkin(ski or 0)
	prop:Spawn()
	prop:SetVelocity( force )
	prop:GetPhysicsObject():ApplyForceOffset( force , dmginfo:GetDamagePosition())
	prop:SetPhysicsAttacker(dmginfo:GetAttacker())
	prop:EmitSound("physics/wood/wood_furniture_break" .. tostring(math.random(1, 2)) .. ".wav", 110, math.random(90, 110))

	if cv_doorres and cv_doorres:GetInt() ~= -1 then
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

function SWEP.MainBullet:HandleDoor(ply, traceres, dmginfo, wep)
	local ent = traceres.Entity
	if not IsValid(ent) then return end
	if not ents.Create then return end
	ent.TFADoorHealth = ent.TFADoorHealth or defaultdoorhealth

	if ent:GetClass() == "func_door_rotating" or ent:GetClass() == "prop_door_rotating" then
		ohp = ent.TFADoorHealth
		ent.TFADoorHealth = ent.TFADoorHealth - dmginfo:GetDamage() * self.Num

		if ent.TFADoorHealth <= 0 then
			if ((self.Damage * self.Num > 100) or ent.TFADoorHealth < -defaultdoorhealth * 0.66 or not IsValid(ply) or not ply.SetName) and ohp > 0 then
				self:MakeDoor(ent, dmginfo)
				ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(90, 110))
			elseif math.random(math.max(1, 5 + math.Round( math.max( 32 - wep.Primary.Damage, 0 ) / 4 ) - wep.Primary.NumShots)) == 1 and ohp > 0  then
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