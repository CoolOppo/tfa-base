local l_Lerp = function(t, a, b) return a + (b - a) * t end
local l_mathMin = function(a, b) return (a < b) and a or b end
local l_mathMax = function(a, b) return (a > b) and a or b end
local l_ABS = function(a) return (a < 0) and -a or a end
local l_mathClamp = function(t, a, b) return l_mathMax(l_mathMin(t, b), a) end

local l_mathApproach = function(a, b, delta)
	if a < b then
		return l_mathMin(a + l_ABS(delta), b)
	else
		return l_mathMax(a - l_ABS(delta), b)
	end
end
local l_NormalizeAngle = math.NormalizeAngle
local LerpAngle = LerpAngle

local function util_NormalizeAngles(a)
	a.p = l_NormalizeAngle(a.p)
	a.y = l_NormalizeAngle(a.y)
	a.r = l_NormalizeAngle(a.r)

	return a
end


local vm_offset_pos = Vector()
local vm_offset_ang = Angle()
local l_FT = FrameTime
local l_CT = CurTime
local ft = 0.01
local host_timescale_cv = GetConVar("host_timescale")
local sv_cheats_cv = GetConVar("sv_cheats")
--local fps_max_cvar = GetConVar("fps_max")

local righthanded,shouldflip,cl_vm_flip_cv

function SWEP:CalculateViewModelFlip()
	if CLIENT and not cl_vm_flip_cv then
		cl_vm_flip_cv = GetConVar("cl_tfa_viewmodel_flip")
	end
	if self.ViewModelFlipDefault == nil then
		self.ViewModelFlipDefault = self.ViewModelFlip
	end

	righthanded = true

	if SERVER and self:GetOwner():GetInfoNum("cl_tfa_viewmodel_flip", 0) == 1 then
		righthanded = false
	end

	if CLIENT and cl_vm_flip_cv:GetBool() then
		righthanded = false
	end

	shouldflip = self.ViewModelFlipDefault

	if not righthanded then
		shouldflip = not self.ViewModelFlipDefault
	end

	if self.ViewModelFlip ~= shouldflip then
		self.ViewModelFlip = shouldflip
	end
end

local target_pos,target_ang,adstransitionspeed, hls
local flip_vec = Vector(-1,1,1)
local flip_ang = Vector(1,-1,-1)
local cl_tfa_viewmodel_offset_x
local cl_tfa_viewmodel_offset_y,cl_tfa_viewmodel_offset_z, cl_tfa_viewmodel_centered, fovmod_add, fovmod_mult
if CLIENT then
	cl_tfa_viewmodel_offset_x = GetConVar("cl_tfa_viewmodel_offset_x")
	cl_tfa_viewmodel_offset_y = GetConVar("cl_tfa_viewmodel_offset_y")
	cl_tfa_viewmodel_offset_z = GetConVar("cl_tfa_viewmodel_offset_z")
	cl_tfa_viewmodel_centered = GetConVar("cl_tfa_viewmodel_centered")
	fovmod_add = GetConVar("cl_tfa_viewmodel_offset_fov")
	fovmod_mult = GetConVar("cl_tfa_viewmodel_multiplier_fov")
end
target_pos = Vector()
target_ang = Vector()

local centered_sprintpos = Vector(0,-1,1)
local centered_sprintang = Vector(-15,0,0)

function SWEP:CalculateViewModelOffset( )

	ft = TFA.FrameTime()

	if self.Owner:IsNPC() then
		return
	end

	if self:GetStat("VMPos_Additive") then
		target_pos:Zero()
		target_ang:Zero()
	else
		target_pos = self:GetStat( "VMPos" ) * 1
		target_ang = self:GetStat( "VMAng" ) * 1
	end

	if cl_tfa_viewmodel_centered:GetBool() then
		if self:GetStat("CenteredPos") then
			target_pos.x = self:GetStat("CenteredPos").x
			target_pos.y = self:GetStat("CenteredPos").y
			target_pos.z = self:GetStat("CenteredPos").z
			if self:GetStat("CenteredAng") then
				target_ang.x = self:GetStat("CenteredAng").x
				target_ang.y = self:GetStat("CenteredAng").y
				target_ang.z = self:GetStat("CenteredAng").z
			end
		elseif self:GetStat("IronSightsPos") then
			target_pos.x = self:GetStat("IronSightsPos").x
			target_pos.z = target_pos.z - 3
			if self:GetStat("IronSightsAng") then
				target_ang:Zero()
				target_ang.y = self:GetStat("IronSightsAng").y
			end
		end
	end

	adstransitionspeed = 10

	is = self:GetIronSights()
	spr = self:GetSprinting()
	stat = self:GetStatus()
	hls = ( TFA.Enum.HolsterStatus[ stat ] and self.ProceduralHolsterEnabled ) or ( TFA.Enum.ReloadStatus[ stat ] and self.ProceduralReloadEnabled )
	if hls then
		target_pos = self:GetStat( "ProceduralHolsterPos" ) * 1
		target_ang = self:GetStat("ProceduralHolsterAng") * 1
		if self.ViewModelFlip then
			target_pos = target_pos * flip_vec
			target_ang = target_ang * flip_ang
		end
		adstransitionspeed = self:GetStat("ProceduralHolsterTime") * 15
	elseif is and ( self.Sights_Mode == TFA.Enum.LOCOMOTION_LUA or self.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID ) then
		target_pos = ( self:GetStat("IronSightsPos", self.SightsPos ) or self:GetStat("SightsPos",vector_origin) ) * 1
		target_ang = ( self:GetStat("IronSightsAng", self.SightsAng ) or self:GetStat("SightsAng",vector_origin) ) * 1
		adstransitionspeed = 15 / ( self:GetStat("IronSightTime") / 0.3 )
	elseif ( spr or self:IsSafety() ) and ( self.Sprint_Mode == TFA.Enum.LOCOMOTION_LUA or self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or ( self:IsSafety() and not spr ) ) and stat ~= TFA.Enum.STATUS_FIDGET and stat ~= TFA.Enum.STATUS_BASHING then
		if cl_tfa_viewmodel_centered and cl_tfa_viewmodel_centered:GetBool() then
			target_pos = target_pos + centered_sprintpos
			target_ang = target_ang + centered_sprintang
		else
			target_pos = self:GetStat("RunSightsPos") * 1
			target_ang = self:GetStat("RunSightsAng") * 1
		end
		adstransitionspeed = 7.5
	end
	if cl_tfa_viewmodel_offset_x and not is then
		target_pos.x = target_pos.x + cl_tfa_viewmodel_offset_x:GetFloat()
		target_pos.y = target_pos.y + cl_tfa_viewmodel_offset_y:GetFloat()
		target_pos.z = target_pos.z + cl_tfa_viewmodel_offset_z:GetFloat()
	end

	if self.Inspecting then
		if not self.InspectPos then
			self.InspectPos = self.InspectPosDef * 1

			if self.ViewModelFlip then
				self.InspectPos.x = self.InspectPos.x * -1
			end
		end

		if not self.InspectAng then
			self.InspectAng = self.InspectAngDef * 1

			if self.ViewModelFlip then
				self.InspectAng.x = self.InspectAngDef.x * 1
				self.InspectAng.y = self.InspectAngDef.y * -1
				self.InspectAng.z = self.InspectAngDef.z * -1
			end
		end

		target_pos = self:GetStat("InspectPos") * 1
		target_ang = self:GetStat("InspectAng") * 1
		adstransitionspeed = 10
	end

	vm_offset_pos.x = math.Approach(vm_offset_pos.x,target_pos.x, (target_pos.x - vm_offset_pos.x) * ft * adstransitionspeed )
	vm_offset_pos.y = math.Approach(vm_offset_pos.y,target_pos.y, (target_pos.y - vm_offset_pos.y) * ft * adstransitionspeed )
	vm_offset_pos.z = math.Approach(vm_offset_pos.z,target_pos.z, (target_pos.z- vm_offset_pos.z) * ft * adstransitionspeed )

	vm_offset_ang.p = math.ApproachAngle(vm_offset_ang.p,target_ang.x, math.AngleDifference( target_ang.x, vm_offset_ang.p ) * ft * adstransitionspeed )
	vm_offset_ang.y = math.ApproachAngle(vm_offset_ang.y,target_ang.y, math.AngleDifference( target_ang.y, vm_offset_ang.y ) * ft * adstransitionspeed )
	vm_offset_ang.r = math.ApproachAngle(vm_offset_ang.r,target_ang.z, math.AngleDifference( target_ang.z, vm_offset_ang.r ) * ft * adstransitionspeed )

end

--[[
Function Name:  Sway
Syntax: self:Sway( ang ).
Returns:  New angle.
Notes:  This is used for calculating the swep viewmodel sway.
Purpose:  Main SWEP function
]]--


local eyeAngles,viewPunch,eyeAnglesPunch,oldEyeAngles,delta,motion,counterMotion,compensation,fac,positionCompensation,swayRate,wiggleFactor,flipFactor
--swayRate = 10

local gunswaycvar = GetConVar("cl_tfa_gunbob_intensity")

function SWEP:Sway(pos, ang)
	--sanity check
	if self.Owner:IsNPC() then
		return
	end
	if not self:OwnerIsValid() then return pos, ang end
	--convar
	fac = gunswaycvar:GetFloat() * 3 * ( ( 1 - ( self.IronSightsProgress or 0 ) ) * 0.75 + 0.25 )
	flipFactor =  (self.ViewModelFlip and -1 or 1)
	--init vars
	delta = delta or Angle()
	motion = motion or Angle()
	counterMotion = counterMotion or Angle()
	compensation = compensation or Angle()
	--grab eye angles
	eyeAngles = self:GetOwner():EyeAngles()
	viewPunch = self:GetOwner():GetViewPunchAngles()
	eyeAngles.p = eyeAngles.p - viewPunch.p 
	eyeAngles.y = eyeAngles.y - viewPunch.y
	oldEyeAngles = oldEyeAngles or eyeAngles
	--calculate delta
	delta.p = math.AngleDifference(eyeAngles.p,oldEyeAngles.p) / ft * 0.0075
	delta.y = math.AngleDifference(eyeAngles.y,oldEyeAngles.y) / ft * 0.0075
	delta.r = math.AngleDifference(eyeAngles.r,oldEyeAngles.r) / ft * 0.0075
	oldEyeAngles = eyeAngles
	--calculate motions, based on Juckey's methods
	wiggleFactor = (1- self:GetStat("MoveSpeed") ) / 0.7 + 0.1
	swayRate = math.pow( self:GetStat("MoveSpeed"), 1.5 ) * 8
	counterMotion = LerpAngle(ft * ( swayRate * ( 0.75 + (0.5-wiggleFactor) ) ), counterMotion, -motion)
	compensation.p = math.AngleDifference(motion.p, -counterMotion.p)
	compensation.y = math.AngleDifference(motion.y, -counterMotion.y)
	motion = LerpAngle( ft * swayRate, motion, delta + compensation)
	--modify position/angle
	positionCompensation = 0.2 + 0.2 * ( self.IronSightsProgress or 0 )
	pos:Add( -motion.y * positionCompensation * 0.5 * fac * ang:Right() * flipFactor ) --compensate position for yaw
	pos:Add( -motion.p * positionCompensation * fac * ang:Up() ) --compensate position for pitch

	ang:RotateAroundAxis(ang:Right(),   motion.p * fac)
	ang:RotateAroundAxis(ang:Up(),      -motion.y * 0.5 * fac * flipFactor)
	ang:RotateAroundAxis(ang:Forward(), counterMotion.r * 0.5 * fac * flipFactor)

	return pos, ang
end


--[[
local oldang = Angle()
local anga = Angle()
local angb = Angle()
local angc = Angle()
local posfac = 0

local gunswaycvar = GetConVar("cl_tfa_gunbob_intensity")

function SWEP:Sway(pos, ang)
	if self.Owner:IsNPC() then
		return
	end
	if not self:OwnerIsValid() then return pos, ang end
	rft = (SysTime() - (self.LastSysT or SysTime())) * game.GetTimeScale()

	if rft > l_FT() then
		rft = l_FT()
	end

	rft = l_mathClamp(rft, 0, 1 / 30)

	if sv_cheats_cv:GetBool() and host_timescale_cv:GetFloat() < 1 then
		rft = rft * host_timescale_cv:GetFloat()
	end

	self.LastSysT = SysTime()
	ang:Normalize()
	--angrange = our availalbe ranges
	--rate = rate to restore our angle to the proper one
	--fac = factor to multiply by
	--each is interpolated from normal value to the ironsights value using iron sights ratio
	local angrange = l_Lerp(self.IronSightsProgress, 15, 2.5) * gunswaycvar:GetFloat()
	local rate = l_Lerp(self.IronSightsProgress, 15, 30)
	local fac = l_Lerp(self.IronSightsProgress, 0.6, 0.15)
	--calculate angle differences
	anga = self:GetOwner():EyeAngles() - oldang
	oldang = self:GetOwner():EyeAngles()
	angb.y = angb.y + (0 - angb.y) * rft * 5
	angb.p = angb.p + (0 - angb.p) * rft * 5

	--fix jitter
	if angb.y < 50 and anga.y > 0 and anga.y < 25 then
		angb.y = angb.y + anga.y / 5
	end

	if angb.y > -50 and anga.y < 0 and anga.y > -25 then
		angb.y = angb.y + anga.y / 5
	end

	if angb.p < 50 and anga.p < 0 and anga.p < 25 then
		angb.p = angb.p - anga.p / 5
	end

	if angb.p > -50 and anga.p > 0 and anga.p > -25 then
		angb.p = angb.p - anga.p / 5
	end

	--limit range
	angb.p = l_mathClamp(angb.p, -angrange, angrange)
	angb.y = l_mathClamp(angb.y, -angrange, angrange)
	--recover
	angc.y = angc.y + (angb.y / 15 - angc.y) * rft * rate
	angc.p = angc.p + (angb.p / 15 - angc.p) * rft * rate
	--finally, blend it into the angle
	ang:RotateAroundAxis(oldang:Up(), angc.y * 15 * (self.ViewModelFlip and -1 or 1) * fac)
	ang:RotateAroundAxis(oldang:Right(), angc.p * 15 * fac)
	ang:RotateAroundAxis(oldang:Forward(), angc.y * 10 * fac * (self.ViewModelFlip and -1 or 1))
	pos:Add(oldang:Right() * angc.y * posfac * (self.ViewModelFlip and -1 or 1))
	pos:Add(oldang:Up() * -angc.p * posfac)
	--extras
	pos:Add( oldang:Up() * math.sin( math.rad(angc.p) ) * -75 )
	pos:Add( oldang:Right() * math.sin( math.rad(angc.y) ) * 75  * (self.ViewModelFlip and -1 or 1) )

	return pos, util_NormalizeAngles(ang)
end
]]--

local gunbob_intensity_cvar = GetConVar("cl_tfa_gunbob_intensity")
local vmfov
local bbvec

function SWEP:AirWalkScale()
	return (( self:OwnerIsValid() and self:GetOwner():IsOnGround() ) and 1 or 0.2 )
end

local viewpunch_cv
local viewpunch_val

function SWEP:GetViewModelPosition( pos, ang )
	if self.Owner:IsNPC() then
		return
	end
	if not IsValid(self:GetOwner()) then return end

	--[[if GetViewEntity().EyeAngles and GetViewEntity()==self:GetOwner() then
		ang = GetViewEntity():EyeAngles()
	end]] -- NO!

	if not viewpunch_cv then
		viewpunch_cv = GetConVar("cl_tfa_viewmodel_viewpunch")
	end
	if not viewpunch_val then
		viewpunch_val = ( 1-viewpunch_cv:GetInt())
	else
		local targ = math.Clamp( ( 1-viewpunch_cv:GetInt()) * ( 1 - ( self.IronSightsProgress or 0 ) ), 0, 1)
		viewpunch_val = math.Approach(viewpunch_val, targ, (targ - viewpunch_val) * TFA.FrameTime() * 10)
	end

	local vpa = self:GetOwner():GetViewPunchAngles()
	ang:RotateAroundAxis(ang:Right(), vpa.p * viewpunch_val )
	ang:RotateAroundAxis(ang:Up(), -vpa.y * viewpunch_val )
	ang:RotateAroundAxis(ang:Forward(), -vpa.r * viewpunch_val )

	--Bobscale
	if self.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI then
		self.SprintBobMult = 0
	end
	self.BobScaleCustom = l_Lerp(self.IronSightsProgress, l_Lerp( math.min( self:GetOwner():GetVelocity():Length() / self:GetOwner():GetWalkSpeed(), 1 ),0.2,0.4), l_Lerp( math.min( self:GetOwner():GetVelocity():Length() / self:GetOwner():GetWalkSpeed(), 1 ), self:GetStat("IronBobMult") / 4, self:GetStat("IronBobMultWalk") / 4))
	self.BobScaleCustom = l_Lerp(self.SprintProgress, self.BobScaleCustom, self.SprintBobMult )
	--Start viewbob code
	local gunbobintensity = gunbob_intensity_cvar:GetFloat()
	if not ang then ang = EyeAngles() end
	--ang:RotateAroundAxis(ang:Forward(), -Qerp(self.IronSightsProgress and self.IronSightsProgress or 0, qerp1, 0))
	--End viewbob code

	if not self.ogviewmodelfov then
		self.ogviewmodelfov = self.ViewModelFOV
	end

	vmfov = l_Lerp( self.IronSightsProgress, self.ogviewmodelfov * fovmod_mult:GetFloat(), self.ogviewmodelfov )
	vmfov = l_Lerp( self.IronSightsProgress, vmfov + fovmod_add:GetFloat(), vmfov )
	self.ViewModelFOV = vmfov

	if self:GetStat("VMPos_Additive") then
		pos:Add(ang:Right() * self.VMPos.x)
		pos:Add(ang:Forward() * self.VMPos.y)
		pos:Add(ang:Up() * self.VMPos.z)
		ang:RotateAroundAxis(ang:Right(), self.VMAng.x)
		ang:RotateAroundAxis(ang:Up(), self.VMAng.y)
		ang:RotateAroundAxis(ang:Forward(), self.VMAng.z)
	end

	pos, ang = self:Sway(pos, ang)
	ang:RotateAroundAxis(ang:Right(), vm_offset_ang.p)
	ang:RotateAroundAxis(ang:Up(), vm_offset_ang.y)
	ang:RotateAroundAxis(ang:Forward(), vm_offset_ang.r)
	self.IronSightsProgress = self.IronSightsProgress * 1
	--print(self.IronSightsProgress)
	ang:RotateAroundAxis(ang:Forward(), -7.5 * ( 1 - math.abs( 0.5 - self.IronSightsProgress  ) * 2 ) * ( self:GetIronSights() and 1 or 0.5 ) * ( self.ViewModelFlip and 1 or -1 ) )

	pos:Add(ang:Right() * vm_offset_pos.x)
	pos:Add(ang:Forward() * vm_offset_pos.y)
	pos:Add(ang:Up() * vm_offset_pos.z)

	if self.BlowbackEnabled and self.BlowbackCurrentRoot > 0.01 then
		--if !(  self.Blowback_PistolMode and !( self:Clip1()==-1 or self:Clip1()>0 ) ) then
		bbvec = self:GetStat("BlowbackVector")
		pos:Add(ang:Right() * bbvec.x * self.BlowbackCurrentRoot)
		pos:Add(ang:Forward() * bbvec.y * self.BlowbackCurrentRoot)
		pos:Add(ang:Up() * bbvec.z * self.BlowbackCurrentRoot)
		--end
	end

	if self.Idle_Mode == TFA.Enum.IDLE_LUA or self.Idle_Mode == TFA.Enum.IDLE_BOTH then
		pos, ang = self:CalculateBob(pos, ang, gunbobintensity * self.BobScaleCustom * 0.5, math.min( math.max( 0.25, math.sqrt( ( math.max(self:GetOwner():GetVelocity():Length2D() * self:AirWalkScale() - self:GetOwner():GetVelocity().z * 0.5,0) ) / self:GetOwner():GetRunSpeed() ) * 1.75 ), self:GetSprinting() and 5 or 3) )
	end

	if self:GetHidden() then
		pos = pos - ang:Up() * 5
	end

	return pos, ang
end
