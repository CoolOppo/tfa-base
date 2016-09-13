DEFINE_BASECLASS("tfa_bash_base")

SWEP.WeaponLength = 8

SWEP.data = {}
SWEP.data.ironsights = 0

SWEP.Primary.Directional = false

SWEP.Primary.Attacks = {} --[[{
	{
		['act'] = ACT_VM_HITLEFT, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
		['src'] = Vector(20,10,0), -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
		['dir'] = Vector(-40,30,0), -- Trace direction/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
		['dmg'] = 60, --Damage
		['dmgtype'] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
		['delay'] = 0.2, --Delay
		['spr'] = true, --Allow attack while sprinting?
		['snd'] = "Swing.Sound", -- Sound ID
		["viewpunch"] = Angle(1,-10,0), --viewpunch angle
		['end'] = 1, --time before next attack
		['hull'] = 10, --Hullsize
		['direction'] = "L" --Swing direction
	},
	{
		['act'] = ACT_VM_HITRIGHT, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
		['src'] = Vector(-10,10,0), -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
		['dir'] = Vector(40,30,0), -- Trace direction/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
		['dmg'] = 60, --Damage
		['dmgtype'] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
		['delay'] = 0.2, --Delay
		['spr'] = true, --Allow attack while sprinting?
		['snd'] = "Swing.Sound", -- Sound ID
		["viewpunch"] = Angle(1,10,0), --viewpunch angle
		['end'] = 1, --time before next attack
		['hull'] = 10, --Hullsize
		['direction'] = "R" --Swing direction
	}
}

SWEP.Secondary.Attacks = {
	{
		['act'] = ACT_VM_MISSCENTER, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
		['src'] = Vector(0,5,0), -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
		['dir'] = Vector(0,50,0), -- Trace direction/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
		['dmg'] = 60, --Damage
		['dmgtype'] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
		['delay'] = 0.2, --Delay
		['spr'] = true, --Allow attack while sprinting?
		['snd'] = "Swing.Sound", -- Sound ID
		["viewpunch"] = Angle(5,0,0), --viewpunch angle
		['end'] = 1 --time before next attack
	}
}
]]--

SWEP.Secondary.CanBash = true

--[[ START OF BASE CODE ]]--

SWEP.Seed = 0

function SWEP:Deploy()

	self:SetNWBool("Attacking",false)
	self:SetNWFloat("AttackTime",-1)
	self:SetNWInt("AttackID", 1 )

	if SERVER then
		self:SetNWInt("Seed",self.Seed)
	end

	return BaseClass.Deploy( self )
end

local att = {}
local attack
local vm
local ind
local spos,ang,src,dst
local tr,traceres
tr = {}
local bul = {}
local srctbl

SWEP.hpf = false
SWEP.hpw = false

function SWEP:Think()

	if !self:OwnerIsValid() then return end
	if !IsFirstTimePredicted() then return end
	if !self:GetNWBool("Attacking") then return end

	ind = self:GetNWInt("AttackID",1)
	srctbl = (ind < 0 ) and self.Secondary.Attacks or self.Primary.Attacks
	attack = srctbl[ math.abs(ind) ]

	if CurTime()>self:GetNWFloat( "AttackTime", 0 ) then

		--Just attacked, so don't do it again

		self:SetNWBool("Attacking",false)

		--Prepare Data

		local eang = self.Owner:EyeAngles()

		tr.start = self.Owner:GetShootPos()
		tr.endpos = tr.start + eang:Forward() * attack.len
		tr.mask = MASK_SHOT
		tr.filter = function( ent ) if ent == self.Owner or ent == self then return false end return true end

		if attack.hull and attack.hull>0 then
			tr.mask = MASK_SHOT_HULL
			tr.mins = Vector( -attack.hull, -attack.hull, -attack.hull ) / 2
			tr.maxs = Vector( attack.hull, attack.hull, attack.hull ) / 2
			traceres = util.TraceHull(tr)
			--[[
			if IsValid(traceres.Entity) and !traceres.HitWorld and !traceres.HitSky then
				tr.start = traceres.HitPos
				tr.endpos = traceres.Entity.GetShootPos and traceres.Entity:GetShootPos() or traceres.Entity:GetPos()
				tr.mask = MASK_SHOT
				tr.mins = nil
				tr.maxs = nil
				traceres = util.TraceLine(tr)
				--debugoverlay.Line( tr.start ,tr.endpos,5,Color(255,0,0,255),false)
				--print("hullhit")
			end
			]]--
		else
			traceres = util.TraceLine(tr)
		end

		debugoverlay.Line( tr.start ,traceres.HitPos,5,Color(255,0,0,255),false)

		local dirvec = Vector(0,0,0)
		dirvec:Add( attack.dir.x * eang:Right() )
		dirvec:Add( attack.dir.y * eang:Forward() )
		dirvec:Add( attack.dir.z * eang:Up() )

		bul.Attacker = self.Owner or self
		bul.Inflictor = self
		bul.Damage = attack.dmg
		bul.Force = attack.force or attack.dmg/4

		bul.Dir = dirvec
		bul.Src = traceres.HitPos + eang:Forward()*16 - dirvec
		bul.Distance = attack.len
		bul.Range = attack.len
		bul.Tracer = 0
		bul.Num = 1
		bul.Spread = vector_origin
		bul.HullSize = 16 --attack.hull

		self.hpf = false
		self.hpw = false

		bul.Callback = function(a,b,c)
			c:SetDamageType( attack.dmgtype or DMG_SLASH )
			hitent = b.Entity
			if IsValid(self) then
				if b.MatType == MAT_FLESH and attack.hitflesh and !self.hpf then
					self:EmitSound(attack.hitflesh)
					hpf = true
				elseif attack.hitworld and !self.hpw then
					self:EmitSound(attack.hitworld)
					hpw = true
				end
			end
		end

		local tr2 = {}
		tr2.start = bul.Src
		tr2.endpos = bul.Src + bul.Dir
		tr2.mask = MASK_SHOT
		tr2.filter = tr.filter
		local traceres2 = util.TraceLine(tr2)

		if IsValid(traceres.Entity) then

			local ent = traceres.Entity

			local phys = traceres.Entity.GetPhysicsObjectNum and ent:GetPhysicsObjectNum(0)

			if  ( ( IsValid(phys) and phys:GetMaterial()=="flesh" ) or ent:IsNPC() or ent:IsPlayer() or ent:IsRagdoll() ) and !self.hpf then
				self:EmitSound(attack.hitflesh)
			elseif attack.hitworld and !self.hpw then
				self:EmitSound(attack.hitworld)
			end

		end

		if IsValid(traceres.Entity) and traceres.Entity != hitent then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker( bul.Attacker )
			dmginfo:SetInflictor( bul.Inflictor )
			dmginfo:SetDamage(  bul.Damage )
			dmginfo:SetDamageType( attack.dmgtype or DMG_SLASH )
			dmginfo:SetDamagePosition( traceres.HitPos )
			dmginfo:SetDamageForce( bul.Dir:GetNormalized() )

			local ent = traceres.Entity
			if IsValid(ent) and ent.TakeDamageInfo then
				ent:TakeDamageInfo(dmginfo)
			end
			if traceres.MatType == MAT_FLESH or traceres.MatType == MAT_ALIENFLESH then
				local fx = EffectData()
				fx:SetOrigin(traceres.HitPos)
				fx:SetNormal(traceres.HitNormal)
				fx:SetEntity(traceres.Entity)
				fx:SetColor( BLOOD_COLOR_RED or 0 )
				util.Effect("BloodImpact",fx)
			end
		end

		if traceres2.Hit and traceres2.Fraction<1 then
			self.Owner:FireBullets(bul)
		end

		--[[

		ang = self.Owner:EyeAngles()

		src = self.Owner:GetShootPos()

		src:Add( ang:Right() * attack.src.x )
		src:Add( ang:Forward() * attack.src.y )
		src:Add( ang:Forward() * attack.src.z )

		dst = src * 1
		dst:Add( ang:Right() * attack.dir.x )
		dst:Add( ang:Forward() * attack.dir.y )
		dst:Add( ang:Forward() * attack.dir.z )

		--Range check

		tr.start = src
		tr.endpos = dst
		tr.mask = MASK_SOLID
		tr.filter = function( ent ) if ent == self.Owner or ent == self then return false end return true end
		if attack.hull and attack.hull>0 then
			tr.mask = MASK_SHOT_HULL
			tr.mins = Vector( -attack.hull, -attack.hull, -attack.hull ) / 2
			tr.maxs = Vector( attack.hull, attack.hull, attack.hull ) / 2
			traceres = util.TraceHull(tr)
			if traceres.Hit and !traceres.HitWorld and !traceres.HitSky then
				tr.start = traceres.HitPos
				tr.endpos = traceres.Entity.GetShootPos and traceres.Entity:GetShootPos() or traceres.Entity:GetPos()
				tr.mask = MASK_SOLID
				tr.mins = nil
				tr.maxs = nil
				traceres = util.TraceLine(tr)
				--debugoverlay.Line( tr.start ,tr.endpos,5,Color(255,0,0,255),false)
				--print("hullhit")
			end
		else
			traceres = util.TraceLine(tr)
		end

		--debugoverlay.Line(src,dst,5,Color(255,255,0,255),false)
		--debugoverlay.Cross(dst,5,5,color_white,true)

		if traceres.Hit and traceres.Fraction<1 and traceres.Fraction>=0 then
			--Within range
			bul.Attacker = self.Owner or self
			bul.Inflictor = self
			bul.Damage = attack.dmg
			bul.Force = attack.force or attack.dmg/4
			bul.Dir = -traceres.HitNormal--( dst - src ):GetNormalized()
			bul.Src = traceres.HitPos - bul.Dir * 8
			bul.Distance = 32
			bul.Tracer = 0
			bul.Num = 1
			bul.Spread = vector_origin
			bul.HullSize = 0 --attack.hull

			if IsValid(traceres.Entity) and traceres.Entity:IsNPC() or traceres.Entity:IsPlayer() then
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker( bul.Attacker )
				dmginfo:SetInflictor( bul.Inflictor )
				dmginfo:SetDamage( bul.Damage )
				dmginfo:SetDamageType( attack.dmgtype or DMG_SLASH )
				dmginfo:SetDamagePosition( traceres.HitPos )
				dmginfo:SetDamageForce( bul.Dir:GetNormalized() * bul.Force )

				hook.Call("ScalePlayerDamage", ( GM or GAMEMODE ), traceres.Entity, HITGROUP_GENERIC, dmginfo )

				local ent = traceres.Entity
				if IsValid(ent) and ent.TakeDamageInfo then
					ent:TakeDamageInfo(dmginfo)
				end
				if traceres.MatType == MAT_FLESH or traceres.MatType == MAT_ALIENFLESH then
					local fx = EffectData()
					fx:SetOrigin(traceres.HitPos)
					fx:SetNormal(traceres.HitNormal)
					fx:SetEntity(traceres.Entity)
					fx:SetColor( BLOOD_COLOR_RED or 0 )
					util.Effect("BloodImpact",fx)
				end
			else
				bul.Callback = function(a,b,c)
					c:SetDamageType( attack.dmgtype or DMG_SLASH )
				end
				self.Owner:FireBullets(bul)
			end



		end

		]]--


	end

end

local lvec,ply,targ

function SWEP:PrimaryAttack()

	if !self:OwnerIsValid() then return end

	if CurTime()<=self:GetNextPrimaryFire() then return end

	table.Empty(att)

	if self.Primary.Directional then
		ply = self.Owner
		lvec = WorldToLocal( ply:GetVelocity(),Angle(0,0,0),vector_origin,ply:EyeAngles()):GetNormalized()
		if lvec.y>0.5 then targ="L" elseif lvec.y<-0.5 then targ="R" elseif lvec.x>0.5 then targ = "F" elseif lvec.x<-0.5 then targ="B" else targ="" end

		for k,v in pairs(self.Primary.Attacks) do
			if ( !self:GetSprinting() or v.spr ) and v.direction and v.direction==targ then
				table.insert(att,#att+1,k)
			end
		end
	end

	if !self.Primary.Directional or #att<=0 then
		for k,v in pairs(self.Primary.Attacks) do
			if ( !self:GetSprinting() or v.spr ) and v.dmg then
				table.insert(att,#att+1,k)
			end
		end
	end

	if #att<=0 then return end

	if SERVER then
		self.Seed = math.random(-99999,99999)
		self:SetNWInt("Seed",self.Seed)
	elseif IsFirstTimePredicted() then
		self.Seed = self:GetNWInt( "Seed" )
	end

	math.randomseed( CurTime() + self.Seed)
	ind = att[ math.random(1,#att) ]
	attack = self.Primary.Attacks[ ind ]

	vm = self.Owner:GetViewModel()

	--We have attack isolated, begin attack logic

	self:SendWeaponAnim( attack.act )

	if !attack.snd_delay or attack.snd_delay<=0 then
		if IsFirstTimePredicted() then
			self:EmitSound( attack.snd )
		end
	elseif attack.snd_delay then
		if SERVER then
			timer.Simple(attack.snd_delay, function()
				if IsValid(self) and self:IsValid() then
					self:EmitSound( attack.snd )
				end
			end)
		end
	end

	self:SetShooting(true)
	self:SetShootingEnd( CurTime() + vm:SequenceDuration() )
	self:SetNextIdleAnim( CurTime() + vm:SequenceDuration() )

	self:SetNWBool("Attacking",true)
	self:SetNWInt("AttackID", ind )
	self:SetNWFloat("AttackTime", CurTime() + attack.delay )

	self.Owner:ViewPunch( attack.viewpunch )
	self:SetNextPrimaryFire( CurTime() + attack['end'] )

end

function SWEP:SecondaryAttack()

	if !self:OwnerIsValid() then return end

	if CurTime()<=self:GetNextPrimaryFire() then return end

	table.Empty(att)

	for k,v in pairs(self.Secondary.Attacks) do
		if ( !self:GetSprinting() or v.spr ) and v.dmg then
			table.insert(att,#att+1,k)
		end
	end

	if #att<=0 then return end

	if SERVER then
		self.Seed = math.random(-99999,99999)
		self:SetNWInt("Seed",self.Seed)
	elseif IsFirstTimePredicted() then
		self.Seed = self:GetNWInt( "Seed" )
	end

	math.randomseed( CurTime() + self.Seed)
	ind = att[ math.random(1,#att) ]
	attack = self.Secondary.Attacks[ ind ]

	vm = self.Owner:GetViewModel()

	--We have attack isolated, begin attack logic

	self:SendWeaponAnim( attack.act )

	if !attack.snd_delay or attack.snd_delay<=0 then
		if IsFirstTimePredicted() then
			self:EmitSound( attack.snd )
		end
	elseif attack.snd_delay then
		if SERVER then
			timer.Simple(attack.snd_delay, function()
				if IsValid(self) and self:IsValid() then
					self:EmitSound( attack.snd )
				end
			end)
		end
	end

	self:SetShooting(true)
	self:SetShootingEnd( CurTime() + vm:SequenceDuration() )
	self:SetNextIdleAnim( CurTime() + vm:SequenceDuration() )

	self:SetNWBool("Attacking",true)
	self:SetNWInt("AttackID", -ind )
	self:SetNWFloat("AttackTime", CurTime() + attack.delay )

	self.Owner:ViewPunch( attack.viewpunch )
	self:SetNextPrimaryFire( CurTime() + attack['end'] )

end

function SWEP:AltAttack()
	if !self.Secondary.CanBash then return end
	return BaseClass.AltAttack( self )
end
