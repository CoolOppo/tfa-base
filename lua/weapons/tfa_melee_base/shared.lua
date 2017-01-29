DEFINE_BASECLASS("tfa_bash_base")
SWEP.DrawCrosshair = false
SWEP.SlotPos = 72
SWEP.Slot = 0
SWEP.WeaponLength = 8
SWEP.data = {}
SWEP.data.ironsights = 0
SWEP.Primary.Directional = false
SWEP.Primary.Attacks = {}
SWEP.IsMelee = true

SWEP.Precision = 9 --Traces to use per attack

local l_CT = CurTime

--[[{
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
['direction'] = "L", --Swing direction
["combotime"] = 0.2 --If you hold attack down, attack this much earlier
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
['direction'] = "R", --Swing direction
["combotime"] = 0.2 --If you hold attack down, attack this much earlier
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
['end'] = 1, --time before next attack
['callback'] = function(tbl,wep,tr) end,
['kickback'] = nil--Recoil if u hit something with this activity
}
}
]]--

SWEP.Primary.MaxCombo = 3 --Max amount of times you'll attack by simply holding down the mouse; -1 to unlimit
SWEP.Secondary.MaxCombo = 3 --Max amount of times you'll attack by simply holding down the mouse; -1 to unlimit

SWEP.CanBlock = false
SWEP.BlockAnimation = {
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DEPLOY, --Number for act, String/Number for sequence
		["transition"] = true
	}, --Inward transition
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_IDLE_DEPLOYED, --Number for act, String/Number for sequence
		["is_idle"] = true
	},--looping animation
	["hit"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_RELOAD_DEPLOYED, --Number for act, String/Number for sequence
		["is_idle"] = true
	},--when you get hit and block it
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_UNDEPLOY, --Number for act, String/Number for sequence
		["transition"] = true
	} --Outward transition
}
SWEP.BlockDamageTypes = {
	DMG_SLASH,DMG_CLUB
}
SWEP.BlockCone = 135 --Think of the player's view direction as being the middle of a sector, with the sector's angle being this
SWEP.BlockDamageMaximum = 0.1 --Multiply damage by this for a maximumly effective block
SWEP.BlockDamageMinimum = 0.4 --Multiply damage by this for a minimumly effective block
SWEP.BlockTimeWindow = 0.5 --Time to absorb maximum damage
SWEP.BlockTimeFade = 1 --Time for blocking to do minimum damage.  Does not include block window
SWEP.BlockDamageCap = 100
SWEP.BlockSound = ""
SWEP.BlockFadeOut = nil --Override the length of the ["out"] block animation easily
SWEP.BlockFadeOutEnd = 0.2 --In absense of BlockFadeOut, shave this length off of the animation time
SWEP.BlockHoldType = "magic"
SWEP.BlockCanDeflect = true  --Can "bounce" bullets off a perfect parry?


SWEP.Secondary.Directional = true
SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = true
SWEP.ImpactDecal = "ManhackCut"
SWEP.Secondary.CanBash = false
SWEP.DefaultComboTime = 0.2

SWEP.AllowSprintAttack = true

--[[ START OF BASE CODE ]]--

SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = ""
SWEP.Seed = 0

SWEP.AttackSoundTime = -1
SWEP.VoxSoundTime = -1

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 30, "VP")
	self:NetworkVar("Float", 27, "VPTime")
	self:NetworkVar("Float", 28, "VPPitch")
	self:NetworkVar("Float", 29, "VPYaw")
	self:NetworkVar("Float", 30, "VPRoll")
	self:NetworkVar("Int", 30, "ComboCount")
	self:NetworkVar("Int", 31, "MelAttackID")
	self:SetMelAttackID(1)
	self:SetVP(false)
	self:SetVPPitch(0)
	self:SetVPYaw(0)
	self:SetVPRoll(0)
	self:SetVPTime(-1)
	self:SetComboCount( 0 )

	return BaseClass.SetupDataTables(self)
end

function SWEP:Deploy()
	self:SetMelAttackID(1)
	self:SetVP(false)
	self:SetVPPitch(0)
	self:SetVPYaw(0)
	self:SetVPRoll(0)
	self:SetVPTime(-1)
	self.up_hat = false
	self:SetComboCount(0)

	return BaseClass.Deploy(self)
end

function SWEP:CanInterruptShooting()
	return false
end

local att = {}
local attack
local ind
local tr = {}
local traceres = {}
local pos, ang, mdl, ski, prop
local fwd,eang,scl,dirv
local strikedir = Vector()

tr = {}
local bul = {}
local srctbl
SWEP.hpf = false
SWEP.hpw = false

local lim_up_vec = Vector(1,1,0.05)

function SWEP:ApplyForce(ent, force, posv, now)
	if not IsValid(ent) or not ent.GetPhysicsObjectNum then return end

	if now then
		if ent.GetRagdollEntity then
			ent = ent:GetRagdollEntity() or ent
		end

		if not IsValid(ent) then return end
		local phys = ent:GetPhysicsObjectNum(0)

		if IsValid(phys) then
			if ent:IsPlayer() or ent:IsNPC() then
				ent:SetVelocity( force * 0.1 * lim_up_vec )
				phys:SetVelocity(phys:GetVelocity() + force * 0.1 * lim_up_vec )
			else
				phys:ApplyForceOffset(force, posv)
			end
		end
	else
		timer.Simple(0, function()
			if IsValid(self) and self:OwnerIsValid() and IsValid(ent) then
				self:ApplyForce(ent, force, posv, true)
			end
		end)
	end
end

function SWEP:MakeDoor(ent, dmginfo)
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
	prop:SetVelocity(dmginfo:GetDamageForce() * 48)
	prop:GetPhysicsObject():ApplyForceOffset(dmginfo:GetDamageForce() * 48, dmginfo:GetDamagePosition())
	prop:SetPhysicsAttacker(dmginfo:GetAttacker())
	prop:EmitSound("physics/wood/wood_furniture_break" .. tostring(math.random(1, 2)) .. ".wav", 110, math.random(90, 110))
end

function SWEP:BurstDoor(ent, dmginfo)
	if not ents.Create then return end
	if dmginfo:GetDamage() > 60 and ( dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:IsDamageType(DMG_CLUB) ) and ( ent:GetClass() == "func_door_rotating" or ent:GetClass() == "prop_door_rotating" ) then
		if dmginfo:GetDamage() > 150 then
			local ply = self.Owner
			self:MakeDoor(ent, dmginfo)
			ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(90, 110))
		else
			local ply = self.Owner
			ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(90, 110))
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

function SWEP:Think2()
	if not self:VMIV() then return end

	if ( not self.Owner:KeyDown( IN_ATTACK ) ) and ( not  self.Owner:KeyDown(IN_ATTACK2) ) then
		self:SetComboCount(0)
	end

	if self:GetVP() and CurTime() > self:GetVPTime() then
		self:SetVP(false)
		self:SetVPTime(-1)
		self.Owner:ViewPunch(Angle(self:GetVPPitch(), self:GetVPYaw(), self:GetVPRoll()))
	end
	if self.CanBlock then
		local stat = self:GetStatus()
		if self.Owner:KeyDown(IN_ZOOM) and TFA.Enum.ReadyStatus[stat] and not self.Owner:KeyDown(IN_USE) then
			self:SetStatus( TFA.GetStatus("blocking") )
			if self.BlockAnimation["in"] then
				self:PlayAnimation( self.BlockAnimation["in"] )
			elseif self.BlockAnimation["loop"] then
				self:PlayAnimation( self.BlockAnimation["loop"] )
			end
			self:SetStatusEnd( math.huge )
			self.BlockStart = CurTime()
		elseif stat == TFA.GetStatus("blocking") and not self.Owner:KeyDown(IN_ZOOM) then
			local _, tanim
			self:SetStatus( TFA.GetStatus("blocking_end") )
			if self.BlockAnimation["out"] then
				_,tanim = self:PlayAnimation( self.BlockAnimation["out"] )
			else
				_,tanim = self:ChooseIdleAnim()
			end
			self:SetStatusEnd( CurTime() + ( self.BlockFadeOut or ( self:GetActivityLength( tanim ) - self.BlockFadeOutEnd ) ) )
		elseif stat == TFA.GetStatus("blocking") and CurTime() > self:GetNextIdleAnim() then
			self:ChooseIdleAnim()
		end
	end
	self:StrikeThink()
	BaseClass.Think2(self)
end

function SWEP:ProcessHoldType( ... )
	if self:GetStatus() == TFA.GetStatus("blocking") then
		self:SetHoldType( self.BlockHoldType or "magic")
		return self.BlockHoldType or "magic"
	else
		return BaseClass.ProcessHoldType(self,...)
	end
end
function SWEP:GetBlockStart()
	return self.BlockStart or -1
end

function SWEP:ChooseBlockAnimation()
	if self.BlockAnimation["hit"] then
		self:PlayAnimation( self.BlockAnimation["hit"] )
	elseif self.BlockAnimation["in"] then
		self:PlayAnimation( self.BlockAnimation["in"] )
	end
end

function SWEP:ChooseIdleAnim( ... )
	if self.CanBlock and self:GetStatus() == TFA.GetStatus("blocking") and self.BlockAnimation["loop"] then
		return self:PlayAnimation( self.BlockAnimation["loop"] )
	else
		return BaseClass.ChooseIdleAnim(self, ...)
	end
end

function SWEP:StrikeThink()
	if self:GetSprinting() and not self.AllowSprintAttack then
		self:SetComboCount(0)
		--return
	end
	if self:IsSafety() then
		self:SetComboCount(0)
		return
	end

	if not IsFirstTimePredicted() then return end
	if self:GetStatus() ~= TFA.Enum.STATUS_SHOOTING then return end
	if self.up_hat then return end

	if self.AttackSoundTime ~= -1 and CurTime() > self.AttackSoundTime then
		ind = self:GetMelAttackID() or 1
		srctbl = (ind < 0) and self.Secondary.Attacks or self.Primary.Attacks
		attack = srctbl[math.abs(ind)]
		self:EmitSound( attack.snd )
		if self.Owner.Vox then
			self.Owner:Vox("bash", 4)
		end
		self.AttackSoundTime = -1
	end

	if self.Owner.Vox and self.VoxSoundTime ~= -1 and CurTime() > self.VoxSoundTime - self.Owner:Ping() * 0.001 then
		if self.Owner.Vox then
			self.Owner:Vox("bash", 4)
		end
		self.VoxSoundTime = -1
	end

	if CurTime() > self:GetStatusEnd() then
		ind = self:GetMelAttackID() or 1
		srctbl = (ind < 0) and self.Secondary.Attacks or self.Primary.Attacks
		attack = srctbl[math.abs(ind)]
		self.DamageType = attack.dmgtype
		--Just attacked, so don't do it again
		self.up_hat = true
		self:SetStatus(TFA.Enum.STATUS_IDLE)
		self:SetStatusEnd( math.huge )
		if self:GetComboCount() > 0 then
			self:SetNextPrimaryFire( self:GetNextPrimaryFire() - ( attack.combotime or 0 ) )
			self:SetNextSecondaryFire( self:GetNextSecondaryFire() - ( attack.combotime or 0 ) )
		end

		self:Strike( attack, self.Precision )
	end
end

local totalResults = {}

local function TraceHitFlesh( b )
	return b.MatType == MAT_FLESH or b.MatType == MAT_ALIENFLESH or ( IsValid(b.Entity) and b.Entity.IsNPC and ( b.Entity:IsNPC() or b.Entity:IsPlayer() or b.Entity:IsRagdoll() )  )
end

local red = Color(255,0,0,255)

function SWEP:Strike( attk, precision )
	local hitWorld,hitFlesh,needsCB
	local distance, direction, maxhull
	distance = attk.len
	direction = attk.dir
	maxhull = attk.hull
	table.Empty( totalResults )
	eang = self.Owner:EyeAngles()
	fwd = self.Owner:EyeAngles():Forward()
	tr.start = self.Owner:GetShootPos()
	scl = direction:Length() / precision / 2
	tr.maxs = Vector(scl,scl,scl)
	tr.mins = -tr.maxs
	tr.mask = MASK_SHOT
	tr.filter = function(ent)
		if ent == self.Owner or ent == self then return false end

		return true
	end
	hitWorld = false
	hitFlesh = false
	if attk.callback then
		needsCB = true
	else
		needsCB = false
	end
	if maxhull then
		tr.maxs.x = math.min( tr.maxs.x, maxhull / 2 )
		tr.maxs.y = math.min( tr.maxs.y, maxhull / 2 )
		tr.maxs.z = math.min( tr.maxs.z, maxhull / 2 )
		tr.mins = -tr.maxs
	end
	strikedir:Zero()
	strikedir:Add(direction.x * eang:Right())
	strikedir:Add(direction.y * eang:Forward())
	strikedir:Add(direction.z * eang:Up())
	local strikedirfull = strikedir * 1
	debugoverlay.Line( tr.start + Vector(0,0,-1) + fwd * distance / 2 - strikedirfull / 2, tr.start + Vector(0,0,-1) + fwd * distance / 2 + strikedirfull / 2, 5, red )
	if SERVER and not game.SinglePlayer() then
		self.Owner:LagCompensation( true )
	end
	for i = 1, precision do
		dirv = LerpVector( ( i - 0.5 ) / precision, -direction / 2, direction / 2 )
		strikedir:Zero()
		strikedir:Add(dirv.x * eang:Right())
		strikedir:Add(dirv.y * eang:Forward())
		strikedir:Add(dirv.z * eang:Up())
		tr.endpos = tr.start + distance * fwd + strikedir
		traceres = util.TraceLine( tr )
		table.insert(totalResults, traceres)
	end
	if SERVER and not game.SinglePlayer() then
		self.Owner:LagCompensation( false )
	end

	local forcevec = strikedirfull:GetNormalized() * (attack.force or attack.dmg / 4) * 128
	bul.Damage = attk.dmg
	bul.Force = 1
	bul.Tracer = 0
	bul.Num = 1
	bul.HullSize = ( attk.hull / 2 ) or 4
	bul.Distance = 16
	bul.Callback = function(a, b, c)

		if b.Fraction >= 1 then
			c:ScaleDamage(0)

			return
		end

		if b.HitPos:Distance(b.StartPos) >= bul.Distance then
			c:ScaleDamage(0)

			return
		end

		c:SetDamageType(attack.dmgtype or DMG_SLASH)
		local hitent = b.Entity

		if c:IsDamageType(DMG_BURN) and hitent.Ignite then
			hitent:Ignite(bul.Damage / 10, 1)
		end

		if not IsValid(self) then return end

		if TraceHitFlesh(b) and not hitFlesh then
			if attk.callback and IsValid(self) and needsCB then
				attk.callback(attack,self,b)
				needsCB = false
			end
			if attk.hitflesh then
				self:EmitSound(attk.hitflesh)
			end
			hitFlesh = true
			self:DoImpactEffect(b, attack.dmgtype)
		elseif ( not TraceHitFlesh( b ) ) and b.Hit then
			if not hitWorld then
				if attk.hitworld and not hitFlesh then
					self:EmitSound(attack.hitworld)
				end
				hitWorld = true
				self:DoImpactEffect(b, attack.dmgtype)
			end
		end

		self:ApplyForce(hitent, forcevec, traceres.HitPos)
		self:BurstDoor(hitent, c)
	end
	local fleshHits = 0
	for k,v in ipairs(totalResults) do --Handle flesh
		if v.Hit and v.Fraction > 0 and v.Fraction < 1 and IsValid(v.Entity) and TraceHitFlesh( v ) and ( not v.Entity.HasMeleeHit ) then
			bul.Src = v.HitPos - strikedir:GetNormalized() * 1
			bul.Dir = strikedir:GetNormalized() * 2
			self.Owner:FireBullets(bul)
			v.Entity.HasMeleeHit = true
			fleshHits = fleshHits + 1
			if fleshHits >= ( attk.maxhits or 3 ) then
				break
			end
		end
		--debugoverlay.Sphere( v.HitPos, 5, 5, color_white )
	end
	for k,v in ipairs(totalResults) do --Handle world
		if v.Hit and ( not TraceHitFlesh( v ) ) and not hitWorld then
			if attk.callback and needsCB then
				attk.callback(attack,self,v)
				needsCB = false
			end
			bul.Src = v.HitPos + v.HitNormal
			bul.Dir = -v.HitNormal * 2
			self.Owner:FireBullets(bul)
		end
	end
	for k,v in ipairs(totalResults) do --Handle empty + cleanup
		if needsCB then
			attk.callback(attack,self,v)
			needsCB = false
		end
		if IsValid(v.Entity) then
			v.Entity.HasMeleeHit = false
		end
	end
	if attack.kickback and ( hitFlesh or hitWorld ) then
		self:SendViewModelAnim( attack.kickback, self:NZAnimationSpeed( ACT_VM_PRIMARYATTACK ) )
	end
end

function SWEP:PlaySwing(act)
	self:SendViewModelAnim(act, self:NZAnimationSpeed( ACT_VM_PRIMARYATTACK ) )
	return true, act
end

local lvec, ply, targ

lvec = Vector()

function SWEP:PrimaryAttack()
	if self:GetSprinting() and not self.AllowSprintAttack then return end
	if self:IsSafety() then return end
	if not self:VMIV() then return end
	if CurTime() <= self:GetNextPrimaryFire() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end
	if self:GetComboCount() >= self.Primary.MaxCombo and self.Primary.MaxCombo > 0 then return end
	table.Empty(att)
	local founddir = false
	if self.Primary.Directional then
		ply = self.Owner
		--lvec = WorldToLocal(ply:GetVelocity(), Angle(0, 0, 0), vector_origin, ply:EyeAngles()):GetNormalized()
		lvec.x = 0
		lvec.y = 0
		if ply:KeyDown(IN_MOVERIGHT) then lvec.y = lvec.y - 1 end
		if ply:KeyDown(IN_MOVELEFT) then lvec.y = lvec.y + 1 end
		if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_JUMP) then lvec.x = lvec.x + 1 end
		if ply:KeyDown(IN_BACK) or ply:KeyDown(IN_DUCK) then lvec.x = lvec.x - 1 end
		lvec.z = 0
		--lvec:Normalize()

		if lvec.y > 0.3 then
			targ = "L"
		elseif lvec.y < -0.3 then
			targ = "R"
		elseif lvec.x > 0.5 then
			targ = "F"
		elseif lvec.x < -0.1 then
			targ = "B"
		else
			targ = ""
		end

		for k, v in pairs(self.Primary.Attacks) do
			if (not self:GetSprinting() or v.spr) and v.direction and string.find(v.direction, targ) then
				if string.find(v.direction, targ) then
					founddir = true
				end

				table.insert(att, #att + 1, k)
			end
		end
	end

	if not self.Primary.Directional or #att <= 0 or not founddir then
		for k, v in pairs(self.Primary.Attacks) do
			if (not self:GetSprinting() or v.spr) and v.dmg then
				table.insert(att, #att + 1, k)
			end
		end
	end

	if #att <= 0 then return end

	ind = att[ self:SharedRandom( 1, #att, "PrimaryAttack" ) ]

	attack = self.Primary.Attacks[ind]
	vm = self.Owner:GetViewModel()
	--We have attack isolated, begin attack logic
	self:PlaySwing(attack.act)

	if not attack.snd_delay or attack.snd_delay <= 0 then
		if IsFirstTimePredicted() then
			self:EmitSound(attack.snd)

			if self.Owner.Vox then
				self.Owner:Vox("bash", 4)
			end
		end

		self.Owner:ViewPunch(attack.viewpunch)
	elseif attack.snd_delay then
		if IsFirstTimePredicted() then
			self.AttackSoundTime = CurTime() + attack.snd_delay * self:GetAnimationRate( ACT_VM_PRIMARYATTACK )
			self.VoxSoundTime = CurTime() + attack.snd_delay * self:GetAnimationRate( ACT_VM_PRIMARYATTACK )
		end
		--[[
		timer.Simple(attack.snd_delay, function()
			if IsValid(self) and self:IsValid() and SERVER then
				self:EmitSound(attack.snd)

				if self:OwnerIsValid() and self.Owner.Vox then
					self.Owner:Vox("bash", 4)
				end
			end
		end)
		]]--

		self:SetVP(true)
		self:SetVPPitch(attack.viewpunch.p)
		self:SetVPYaw(attack.viewpunch.y)
		self:SetVPRoll(attack.viewpunch.r)
		self:SetVPTime(CurTime() + attack.snd_delay * self:GetAnimationRate( ACT_VM_PRIMARYATTACK ) )
		self.Owner:ViewPunch(-Angle(attack.viewpunch.p / 2, attack.viewpunch.y / 2, attack.viewpunch.r / 2))
	end

	self.up_hat = false
	self:SetStatus(TFA.Enum.STATUS_SHOOTING)
	self:SetMelAttackID(ind)
	self:SetStatusEnd(CurTime() + attack.delay)
	self:SetNextPrimaryFire(CurTime() + attack["end"])
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SetComboCount(self:GetComboCount() + 1)
end

function SWEP:SecondaryAttack()
	if self:GetSprinting() and not self.AllowSprintAttack then return end
	if self:IsSafety() then return end
	if not self:VMIV() then return end
	if CurTime() <= self:GetNextPrimaryFire() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end
	if self:GetComboCount() >= self.Secondary.MaxCombo and self.Secondary.MaxCombo > 0 then return end
	table.Empty(att)
	local founddir = false

	if not self.Secondary.Attacks or #self.Secondary.Attacks == 0 then
		self.Secondary.Attacks = self.Primary.Attacks
	end

	if self.Secondary.Directional then
		ply = self.Owner
		--lvec = WorldToLocal(ply:GetVelocity(), Angle(0, 0, 0), vector_origin, ply:EyeAngles()):GetNormalized()
		lvec.x = 0
		lvec.y = 0
		if ply:KeyDown(IN_MOVERIGHT) then lvec.y = lvec.y - 1 end
		if ply:KeyDown(IN_MOVELEFT) then lvec.y = lvec.y + 1 end
		if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_JUMP) then lvec.x = lvec.x + 1 end
		if ply:KeyDown(IN_BACK) or ply:KeyDown(IN_DUCK) then lvec.x = lvec.x - 1 end
		lvec.z = 0
		--lvec:Normalize()

		if lvec.y > 0.3 then
			targ = "L"
		elseif lvec.y < -0.3 then
			targ = "R"
		elseif lvec.x > 0.5 then
			targ = "F"
		elseif lvec.x < -0.1 then
			targ = "B"
		else
			targ = ""
		end

		for k, v in pairs(self.Secondary.Attacks) do
			if (not self:GetSprinting() or v.spr) and v.direction and string.find(v.direction, targ) then
				if string.find(v.direction, targ) then
					founddir = true
				end

				table.insert(att, #att + 1, k)
			end
		end
	end

	if not self.Secondary.Directional or #att <= 0 or not founddir then
		for k, v in pairs(self.Secondary.Attacks) do
			if (not self:GetSprinting() or v.spr) and v.dmg then
				table.insert(att, #att + 1, k)
			end
		end
	end

	if #att <= 0 then return end

	ind = att[ self:SharedRandom( 1, #att, "SecondaryAttack" ) ]
	attack = self.Secondary.Attacks[ind]
	vm = self.Owner:GetViewModel()
	--We have attack isolated, begin attack logic
	self:PlaySwing(attack.act)

	if not attack.snd_delay or attack.snd_delay <= 0 then
		if IsFirstTimePredicted() then
			self:EmitSound(attack.snd)

			if self.Owner.Vox then
				self.Owner:Vox("bash", 4)
			end
		end

		self.Owner:ViewPunch(attack.viewpunch)
	elseif attack.snd_delay then
		if IsFirstTimePredicted() then
			self.AttackSoundTime = CurTime() + attack.snd_delay * self:GetAnimationRate( ACT_VM_PRIMARYATTACK )
			self.VoxSoundTime = CurTime() + attack.snd_delay * self:GetAnimationRate( ACT_VM_PRIMARYATTACK )
		end
		--[[
		timer.Simple(attack.snd_delay, function()
			if IsValid(self) and self:IsValid() and SERVER then
				self:EmitSound(attack.snd)

				if self:OwnerIsValid() and self.Owner.Vox then
					self.Owner:Vox("bash", 4)
				end
			end
		end)
		]]--

		self:SetVP(true)
		self:SetVPPitch(attack.viewpunch.p)
		self:SetVPYaw(attack.viewpunch.y)
		self:SetVPRoll(attack.viewpunch.r)
		self:SetVPTime(CurTime() + attack.snd_delay * self:GetAnimationRate( ACT_VM_PRIMARYATTACK ) )
		self.Owner:ViewPunch(-Angle(attack.viewpunch.p / 2, attack.viewpunch.y / 2, attack.viewpunch.r / 2))
	end

	self.up_hat = false
	self:SetStatus(TFA.Enum.STATUS_SHOOTING)
	self:SetMelAttackID(-ind)
	self:SetStatusEnd(CurTime() + attack.delay)
	self:SetNextPrimaryFire(CurTime() + attack["end"])
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SetComboCount(self:GetComboCount() + 1)
end

function SWEP:AltAttack()
	if self.CanBlock then
		if self.Secondary.CanBash and self.CanBlock and self.Owner:KeyDown(IN_USE) then
			BaseClass.AltAttack( self )
			return
		end
	else
		if not self:VMIV() then return end
		if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end
		if not self.Secondary.CanBash then return end
		if self:IsSafety() then return end

		return BaseClass.AltAttack(self)
	end
end

function SWEP:Reload( released, ovr, ... )
	if not self:VMIV() then return end
	if ovr then
		return BaseClass.Reload(self,released,...)
	end
	if (self.SequenceEnabled[ACT_VM_FIDGET] or self.InspectionActions) and self:GetStatus() == TFA.Enum.STATUS_IDLE then
		self:SetStatus(TFA.Enum.STATUS_FIDGET)
		succ,tanim = self:ChooseInspectAnim()
		self:SetStatusEnd( l_CT() + (self.SequenceLengthOverride[tanim] or self.OwnerViewModel:SequenceDuration()) )
	end
end

function SWEP:CycleSafety()
end