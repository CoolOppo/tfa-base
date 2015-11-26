DEFINE_BASECLASS("tfa_gun_base")

SWEP.Secondary.Damage = 25
SWEP.Secondary.BashSound = Sound("TFA.Bash2")
SWEP.Secondary.Sound = Sound("")
SWEP.Secondary.Sound_Flesh = Sound("TFA.BashFlesh")
SWEP.Secondary.BashLength = 54
SWEP.Secondary.BashDelay = 0.2	

function SWEP:AltAttack()
	if !self:OwnerIsValid() then return end

	if ( self:GetHolstering() ) then
		if (self.ShootWhileHolster==false) then
			return
		else
			self:SetHolsteringEnd(CurTime()-0.1)
			self:SetHolstering(false)
		end
	end
	
	if (self:GetReloading() and self.Shotgun and !self:GetShotgunPumping() and !self:GetShotgunNeedsPump()) then
		self:SetShotgunCancel( true )
		--[[
		self:SetShotgunInsertingShell(true)
		self:SetShotgunPumping(false)
		self:SetShotgunNeedsPump(true)
		self:SetReloadingEnd(CurTime()-1)
		]]--
		return
	end
	
	if self:IsSafety() then return end
	
	if (self:GetChangingSilence()) then return end
	
	if self:GetNextSecondaryFire()>CurTime() then return end
	
	if self:GetReloading() then
		self:CompleteReload()
	end
	
	local vm = self.Owner:GetViewModel()
	
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	
	self:SetNextPrimaryFire(CurTime()+vm:SequenceDuration())
	self:SetNextSecondaryFire(CurTime()+vm:SequenceDuration())
	
	if CLIENT then
		self:EmitSound(self.Secondary.BashSound )
	end
	
	timer.Simple(self.Secondary.BashDelay,function()
		if IsValid(self) and self.OwnerIsValid and self:OwnerIsValid() then
			if (SERVER) then
				local pos = self.Owner:GetShootPos()
				local av = self.Owner:EyeAngles():Forward()
				
				local slash = {}
				slash.start = pos
				slash.endpos = pos + (av * self.Secondary.BashLength)
				slash.filter = self.Owner
				slash.mins = Vector(-10, -5, 0)
				slash.maxs = Vector(10, 5, 5)
				local slashtrace = util.TraceHull(slash)
				local pain = self.Secondary.Damage
				
				
				
				if slashtrace.Hit then
					if slashtrace.Entity:GetClass() == "func_door_rotating" or slashtrace.Entity:GetClass() == "prop_door_rotating" then
						local ply = self.Owner
						ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(80, 120))
						
						ply.oldname = ply:GetName()
						
						ply:SetName( "bashingpl" .. ply:EntIndex() )
						
						slashtrace.Entity:SetKeyValue( "Speed", "500" )
						slashtrace.Entity:SetKeyValue( "Open Direction", "Both directions" )
						slashtrace.Entity:Fire( "unlock", "", .01 )
						slashtrace.Entity:Fire( "openawayfrom", "bashingpl" .. ply:EntIndex() , .01 )
						
						timer.Simple(0.02, function()
							if IsValid(ply) then
								ply:SetName(ply.oldname)
							end
						end)
						
						timer.Simple(0.3, function()
							if IsValid(slashtrace.Entity) then
								slashtrace.Entity:SetKeyValue( "Speed", "100" )
							end
						end)
						
					end
					self:EmitSound( (slashtrace.MatType == MAT_FLESH or slashtrace.MatType == MAT_ALIENFLESH) and self.Secondary.Sound_Flesh or self.Secondary.Sound  )
					if game.GetTimeScale()>0.99 then
						self.Owner:FireBullets({
							Attacker = self.Owner,
							Inflictor = self,
							Damage = pain,
							Force = pain,
							Distance = self.Secondary.BashLength + 10,
							HullSize = 10,
							Tracer = 0,
							Src = self.Owner:GetShootPos(),
							Dir = slashtrace.Normal,
							Callback = function(a,b,c)
								if c then c:SetDamageType(DMG_SLASH) end
							end
						})
					else
						local dmg = DamageInfo()
						dmg:SetAttacker(self.Owner)
						dmg:SetInflictor(self)
						dmg:SetDamagePosition(self.Owner:GetShootPos())
						dmg:SetDamageForce(self.Owner:GetAimVector()*(pain))
						dmg:SetDamage(pain)
						dmg:SetDamageType(DMG_SLASH)
						slashtrace.Entity:TakeDamageInfo(dmg)
					end		
				end
			end
		end
	end)
end

function SWEP:GetBashing()
	if !self:OwnerIsValid() then return false end
	local bash,vm,seq,actid
	
	vm = self.Owner:GetViewModel()
	seq = vm:GetSequence()
	actid = vm:GetSequenceActivity(seq)
	bash = (actid==ACT_VM_HITCENTER) and vm:GetCycle()>0 and vm:GetCycle()<0.65
	return bash
end

function SWEP:IronsSprint()

	if !self:OwnerIsValid() then return end

	if self.Callback.IronsSprint then
		local val = self.Callback.IronsSprint(self)
		if val then return val end
	end
	
	local is,oldis,spr, rld, dr, hl, nw, isbolttimer, insp, bash
	spr=self:GetSprinting()
	is=self:GetIronSights()
	oldis=self.OldIronsights
	rld=self:GetReloading()
	dr=self:GetDrawing()
	hl=self:GetHolstering()
	insp = self:GetInspecting()
	ischangingsilence = self:GetChangingSilence()
	isbolttimer = self:GetBoltTimer()
	bash = self:GetBashing()
	nw = false
	
	if self:Clip1() ==  0 and (GetConVarNumber("sv_tfa_allow_dryfire",1)==0) then
		if self:GetBursting() then
			self:SetBursting(false)
			self:SetNextBurst(CurTime() - 1)
			self:SetBurstCount(0)
		end
	elseif self:Clip1() < 0 and IsValid(self.Owner) and self:GetAmmoReserve()<=0 and (GetConVarNumber("sv_tfa_allow_dryfire",1)==0) then
		if self:GetBursting() then
			self:SetBursting(false)
			self:SetNextBurst(CurTime() - 1)
			self:SetBurstCount(0)
		end
	end
		
	if self:GetNearWallRatio()>0.01 then
		nw = true
	end
	
	if (isbolttimer) and (CurTime()>self:GetBoltTimerStart()) and (CurTime()<self:GetBoltTimerEnd()) then
		is=false	
	end
	
	if (bash) then
		spr=false
		is=false
		insp = false
		self:SetInspecting(false)
		self:SetBursting(false)
		self:SetNearWall(false)
		self:SetNextBurst(CurTime() - 1)
		self:SetBurstCount(0)
	end
	
	if (spr) then
		is=false
		insp = false
		self:SetInspecting(false)
		self:SetBursting(false)
		self:SetNextBurst(CurTime() - 1)
		self:SetBurstCount(0)
	end
	
	if (insp) then
		is = false
	end
	
	if ( self:IsSafety() ) then
		is=false
		self:SetInspecting(false)
		self:SetBursting(false)
		self:SetNextBurst(CurTime() - 1)
		self:SetBurstCount(0)
	end
	
	if (ischangingsilence) then
		is=false
		self:SetBursting(false)
		self:SetNextBurst(CurTime() - 1)
		self:SetBurstCount(0)
	end
	
	if self.UnSightOnReload then
		if (rld) then
			is=false
			self:SetInspecting(false)
			self:SetInspectingRatio(0)
		end
	end
		
	if (dr) then
		if !self.SightWhileDraw then
			self:SetInspecting(false)
			self:SetInspectingRatio(0)
			is=false
		end
	end
		
	if (hl) then
		self:SetInspecting(false)
		self:SetInspectingRatio(0)
		self:SetBursting(false)
		if !self.SightWhileHolster then
			is=false
		end
	end
	
	if (nw) then
		is=false
		self:SetInspecting(false)
		self:SetBursting(false)
	end
	
	if (oldis!=is) and ( ( CLIENT and IsFirstTimePredicted() ) or ( SERVER and game.SinglePlayer() ) ) then
		if (is==false) then
			self:EmitSound("TFA.IronOut")
		else
			self:EmitSound("TFA.IronIn")
		end
	end
	
	self:SetIronSights(is)
	self:SetSprinting(spr)
	if ( (CLIENT and GetConVarNumber("cl_tfa_ironsights_resight",0)==0) or ( SERVER and self.Owner:GetInfoNum("cl_tfa_ironsights_resight",0)==0) ) then
		self:SetIronSightsRaw(is)
	end
end

--[[ 
Function Name:  CalculateNearWallSH
Syntax: self:CalculateNearWallSH().
Returns:  Nothing.  However, calculates nearwall for the server.
Notes:  This is the server/shared equivalent of CalculateNearWallCLF.
Purpose:  Feature
]]--

function SWEP:CalculateNearWallSH()

	if !IsValid(self.Owner) then return end

	if self.Callback.CalculateNearWallSH then
		local val = self.Callback.CalculateNearWallSH(self)
		if val then return val end
	end
	
	local vnearwall
	
	vnearwall=false
	
	local tracedata = {}
	tracedata.start=self.Owner:GetShootPos()
	tracedata.endpos=tracedata.start+self.Owner:EyeAngles():Forward()*self.WeaponLength
	tracedata.mask=MASK_SHOT
	tracedata.ignoreworld=false
	tracedata.filter=self.Owner
	local traceres=util.TraceLine(tracedata)
	
	if !self:GetBashing() then
		if traceres.Hit then
			if traceres.Fraction>0 and traceres.Fraction<1 then
				if traceres.MatType!=MAT_FLESH and traceres.MatType!=MAT_GLASS and !( IsValid(traceres.Entity) and traceres.Entity:IsNPC() )then
					vnearwall = true
				end
			end
		end
	end
	
	if GetConVarNumber("sv_tfa_near_wall",1)==0 then
		vnearwall = false
	end
	
	self:SetNearWallRatio( math.Approach( self:GetNearWallRatio(), vnearwall and 1 or 0 , FrameTime() / self.NearWallTime ) )
	
end

--[[ 
Function Name:  CalculateNearWallCLF
Syntax: self:CalculateNearWallCLF().  This is called per-frame.
Returns:  Nothing.  However, calculates nearwall for the client.
Notes:  This is clientside only.
Purpose:  Feature
]]--

function SWEP:CalculateNearWallCLF()

	if !( CLIENT or game.SinglePlayer() ) then return end
	if !IsValid(self.Owner) then return end

	if self.Callback.CalculateNearWallCLF then
		local val = self.Callback.CalculateNearWallCLF(self)
		if val then return val end
	end
	
	local vnearwall
	
	vnearwall=false
	local tracedata = {}
	tracedata.start=self.Owner:GetShootPos()
	tracedata.endpos=tracedata.start+self.Owner:EyeAngles():Forward()*self.WeaponLength
	tracedata.mask=MASK_SHOT
	tracedata.ignoreworld=false
	tracedata.filter=self.Owner
	local traceres=util.TraceLine(tracedata)
	
	if !self:GetBashing() then
		if traceres.Hit then
			if traceres.Fraction>0 and traceres.Fraction<1 then
				if traceres.MatType!=MAT_FLESH and traceres.MatType!=MAT_GLASS and !( IsValid(traceres.Entity) and traceres.Entity:IsNPC() )then
					vnearwall = true
				end
			end
		end
	end
	
	if GetConVarNumber("sv_tfa_near_wall",1)==0 then
		vnearwall = false
	end
	
	self.CLNearWallProgress =  math.Approach( self.CLNearWallProgress, vnearwall and 1 or 0 , FrameTime() / self.NearWallTime )
end