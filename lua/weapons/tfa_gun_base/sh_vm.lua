
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

local l_Lerp = function(t, a, b) return a + (b - a) * t end
--[[
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
]]
--
local vm_offset_pos = Vector()
local vm_offset_ang = Angle()
--local fps_max_cvar = GetConVar("fps_max")
local righthanded, shouldflip, cl_vm_flip_cv, cl_vm_nearwall, fovmod_add, fovmod_mult

local cv_fov = GetConVar("fov_desired")

function SWEP:CalculateViewModelFlip()
	local self2 = self:GetTable()

	if CLIENT and not cl_vm_flip_cv then
		cl_vm_flip_cv = GetConVar("cl_tfa_viewmodel_flip")
		fovmod_add = GetConVar("cl_tfa_viewmodel_offset_fov")
		fovmod_mult = GetConVar("cl_tfa_viewmodel_multiplier_fov")
	end

	if self2.ViewModelFlipDefault == nil then
		self2.ViewModelFlipDefault = self2.ViewModelFlip
	end

	righthanded = true

	if SERVER and self:GetOwner():GetInfoNum("cl_tfa_viewmodel_flip", 0) == 1 then
		righthanded = false
	end

	if CLIENT and cl_vm_flip_cv:GetBool() then
		righthanded = false
	end

	shouldflip = self2.ViewModelFlipDefault

	if not righthanded then
		shouldflip = not self2.ViewModelFlipDefault
	end

	if self2.ViewModelFlip ~= shouldflip then
		self2.ViewModelFlip = shouldflip
	end

	self2.ViewModelFOV_OG = self2.ViewModelFOV_OG or self2.ViewModelFOV

	local cam_fov = self2.LastTranslatedFOV or cv_fov:GetInt() or 90
	local iron_add = cam_fov * (1 - 90 / cam_fov) * math.max(1 - self2.GetStat(self, "Secondary.IronFOV", 90) / 90, 0)

	self2.ViewModelFOV = l_Lerp(self:GetNW2Float("IronSightsProgress"), self2.ViewModelFOV_OG, self2.GetStat(self, "IronViewModelFOV", self2.ViewModelFOV_OG)) * fovmod_mult:GetFloat() + fovmod_add:GetFloat() + iron_add * self:GetNW2Float("IronSightsProgress")
end

SWEP.WeaponLength = 0

function SWEP:UpdateWeaponLength()
	local self2 = self:GetTable()
	if not self:VMIV() then return end
	local vm = self2.OwnerViewModel
	local mzpos = self:GetMuzzlePos()
	if not mzpos then return end
	if not mzpos.Pos then return end
	if GetViewEntity and GetViewEntity() ~= self:GetOwner() then return end
	local mzVec = vm:WorldToLocal(mzpos.Pos)
	self2.WeaponLength = math.abs(mzVec.x)
end

SWEP.NearWallVector = Vector(0.1, -0.5, -0.2):GetNormalized() * 0.5
SWEP.NearWallVectorADS = Vector(0, 0, 0)

function SWEP:CalculateNearWall(p, a)
	local self2 = self:GetTable()
	if not self:OwnerIsValid() then return p, a end

	if not cl_vm_nearwall then
		cl_vm_nearwall = GetConVar("cl_tfa_viewmodel_nearwall")
	end

	if not cl_vm_nearwall or not cl_vm_nearwall:GetBool() then return p, a end

	local sp = self:GetOwner():GetShootPos()
	local ea = self:GetOwner():EyeAngles()
	local et = util.QuickTrace(sp,ea:Forward()*128,{self,self:GetOwner()})--self:GetOwner():GetEyeTrace()
	local dist = et.HitPos:Distance(sp)
	if dist<1 then
		et=util.QuickTrace(sp,ea:Forward()*128,{self,self:GetOwner(),et.Entity})
		dist = et.HitPos:Distance(sp)
	end

	self:UpdateWeaponLength()

	local nw_offset_vec = self:GetIronSights() and self2.NearWallVectorADS or self2.NearWallVector
	local off = self2.WeaponLength - dist

	if off > 0 then
		p = p + nw_offset_vec * off / 2
		local posCompensated = sp * 1
		posCompensated:Add(ea:Right() * nw_offset_vec.x * off / 2 * (self2.ViewModelFlip and -1 or 1))
		posCompensated:Add(ea:Forward() * nw_offset_vec.y * off / 2)
		posCompensated:Add(ea:Up() * nw_offset_vec.z * off / 2)
		local angleComp = (et.HitPos - posCompensated):Angle()
		a.x = a.x - math.AngleDifference(angleComp.p, ea.p) / 2
		a.y = a.y + math.AngleDifference(angleComp.y, ea.y) / 2
	end

	return p, a
end

local target_pos, target_ang, adstransitionspeed, hls
local flip_vec = Vector(-1, 1, 1)
local flip_ang = Vector(1, -1, -1)
local cl_tfa_viewmodel_offset_x
local cl_tfa_viewmodel_offset_y, cl_tfa_viewmodel_offset_z, cl_tfa_viewmodel_centered
local intensityWalk, intensityRun, intensityBreath

if CLIENT then
	cl_tfa_viewmodel_offset_x = GetConVar("cl_tfa_viewmodel_offset_x")
	cl_tfa_viewmodel_offset_y = GetConVar("cl_tfa_viewmodel_offset_y")
	cl_tfa_viewmodel_offset_z = GetConVar("cl_tfa_viewmodel_offset_z")
	cl_tfa_viewmodel_centered = GetConVar("cl_tfa_viewmodel_centered")
end

target_pos = Vector()
target_ang = Vector()
local centered_sprintpos = Vector(0, -1, 1)
local centered_sprintang = Vector(-15, 0, 0)
local vmviewpunch_cv
local sv_tfa_recoil_legacy = GetConVar("sv_tfa_recoil_legacy")

function SWEP:CalculateViewModelOffset(delta)
	local self2 = self:GetTable()

	if self2.GetStat(self, "VMPos_Additive") then
		target_pos:Zero()
		target_ang:Zero()
	else
		target_pos = self2.GetStat(self, "VMPos") * 1
		target_ang = self2.GetStat(self, "VMAng") * 1
	end

	if cl_tfa_viewmodel_centered:GetBool() then
		if self2.GetStat(self, "CenteredPos") then
			target_pos.x = self2.GetStat(self, "CenteredPos").x
			target_pos.y = self2.GetStat(self, "CenteredPos").y
			target_pos.z = self2.GetStat(self, "CenteredPos").z

			if self2.GetStat(self, "CenteredAng") then
				target_ang.x = self2.GetStat(self, "CenteredAng").x
				target_ang.y = self2.GetStat(self, "CenteredAng").y
				target_ang.z = self2.GetStat(self, "CenteredAng").z
			end
		elseif self2.GetStat(self, "IronSightsPos") then
			target_pos.x = self2.GetStat(self, "IronSightsPos").x
			target_pos.z = target_pos.z - 3

			if self2.GetStat(self, "IronSightsAng") then
				target_ang:Zero()
				target_ang.y = self2.GetStat(self, "IronSightsAng").y
			end
		end
	end

	adstransitionspeed = 10
	local is = self:GetIronSights()
	local spr = self:GetSprinting()
	local stat = self:GetStatus()
	hls = (TFA.Enum.HolsterStatus[stat] and self2.ProceduralHolsterEnabled) or (TFA.Enum.ReloadStatus[stat] and self2.ProceduralReloadEnabled)

	if hls then
		target_pos = self2.GetStat(self, "ProceduralHolsterPos") * 1
		target_ang = self2.GetStat(self, "ProceduralHolsterAng") * 1

		if self2.ViewModelFlip then
			target_pos = target_pos * flip_vec
			target_ang = target_ang * flip_ang
		end

		adstransitionspeed = self2.GetStat(self, "ProceduralHolsterTime") * 15
	elseif is and (self2.Sights_Mode == TFA.Enum.LOCOMOTION_LUA or self2.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID) then
		target_pos = (self2.GetStat(self, "IronSightsPos", self2.SightsPos) or self2.GetStat(self, "SightsPos", vector_origin)) * 1
		target_ang = (self2.GetStat(self, "IronSightsAng", self2.SightsAng) or self2.GetStat(self, "SightsAng", vector_origin)) * 1
		adstransitionspeed = 15 / (self2.GetStat(self, "IronSightTime") / 0.3)
	elseif (spr or self:IsSafety()) and (self2.Sprint_Mode == TFA.Enum.LOCOMOTION_LUA or self2.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or (self:IsSafety() and not spr)) and stat ~= TFA.Enum.STATUS_FIDGET and stat ~= TFA.Enum.STATUS_BASHING then
		if cl_tfa_viewmodel_centered and cl_tfa_viewmodel_centered:GetBool() then
			target_pos = target_pos + centered_sprintpos
			target_ang = target_ang + centered_sprintang
		elseif self:IsSafety() and self2.GetStat(self, "SafetyPos") and not spr then
			target_pos = self2.GetStat(self, "SafetyPos") * 1
			target_ang = self2.GetStat(self, "SafetyAng") * 1
		else
			target_pos = self2.GetStat(self, "RunSightsPos") * 1
			target_ang = self2.GetStat(self, "RunSightsAng") * 1
		end

		adstransitionspeed = 7.5
	end

	if cl_tfa_viewmodel_offset_x and not is then
		target_pos.x = target_pos.x + cl_tfa_viewmodel_offset_x:GetFloat()
		target_pos.y = target_pos.y + cl_tfa_viewmodel_offset_y:GetFloat()
		target_pos.z = target_pos.z + cl_tfa_viewmodel_offset_z:GetFloat()
	end

	if self2.GetCustomizing(self) and self2.Customize_Mode ~= TFA.Enum.LOCOMOTION_ANI then
		if not self2.InspectPos then
			self2.InspectPos = self2.InspectPosDef * 1

			if self2.ViewModelFlip then
				self2.InspectPos.x = self2.InspectPos.x * -1
			end
		end

		if not self2.InspectAng then
			self2.InspectAng = self2.InspectAngDef * 1

			if self2.ViewModelFlip then
				self2.InspectAng.x = self2.InspectAngDef.x * 1
				self2.InspectAng.y = self2.InspectAngDef.y * -1
				self2.InspectAng.z = self2.InspectAngDef.z * -1
			end
		end

		target_pos = self2.GetStat(self, "InspectPos") * 1
		target_ang = self2.GetStat(self, "InspectAng") * 1
		adstransitionspeed = 10
	end

	target_pos, target_ang = self:CalculateNearWall(target_pos, target_ang)

	if self2.VMPos_Additive then
		target_pos.x = target_pos.x + self2.VMPos.x
		target_pos.y = target_pos.y + self2.VMPos.y
		target_pos.z = target_pos.z + self2.VMPos.z
		target_ang.x = target_ang.x + self2.VMAng.x
		target_ang.y = target_ang.y + self2.VMAng.y
		target_ang.z = target_ang.z + self2.VMAng.z
	end

	target_ang.z = target_ang.z + -7.5 * (1 - math.abs(0.5 - self:GetNW2Float("IronSightsProgress")) * 2) * (self:GetIronSights() and 1 or 0.5) * (self2.ViewModelFlip and 1 or -1)

	if self:GetHidden() then
		target_pos.z = target_pos.z - 5
	end

	if self2.GetStat(self, "BlowbackEnabled") and self2.BlowbackCurrentRoot > 0.01 then
		local bbvec = self2.GetStat(self, "BlowbackVector")
		target_pos = target_pos + bbvec * self2.BlowbackCurrentRoot
		local bbang = self2.GetStat(self, "BlowbackAngle") or angle_zero
		bbvec = bbvec * 1
		bbvec.x = bbang.p
		bbvec.y = bbang.y
		bbvec.z = bbang.r
		target_ang = target_ang + bbvec * self2.BlowbackCurrentRoot
		bbang = self2.BlowbackRandomAngle * (1 - math.max(0, self:GetNW2Float("IronSightsProgress")) * .8)
		bbvec.x = bbang.p
		bbvec.y = bbang.y
		bbvec.z = bbang.r
		target_ang = target_ang + bbvec * self2.BlowbackCurrentRoot
		adstransitionspeed = adstransitionspeed + 15 * math.pow(self2.BlowbackCurrentRoot, 2)
	end

	if vmviewpunch_cv and not vmviewpunch_cv:GetBool() then
		if sv_tfa_recoil_legacy:GetBool() then
			local vpa = self:GetOwner():GetViewPunchAngles()
			target_ang.x = target_ang.x + vpa.p
			target_ang.y = target_ang.y + vpa.y
			target_ang.z = target_ang.z + vpa.r
		else
			target_ang.x = target_ang.x + self:GetNW2Float("ViewPunchP")
			target_ang.y = target_ang.y + self:GetNW2Float("ViewPunchY")
		end
	elseif not vmviewpunch_cv then
		vmviewpunch_cv = GetConVar("cl_tfa_viewmodel_viewpunch")
	end

	vm_offset_pos.x = math.Approach(vm_offset_pos.x, target_pos.x, (target_pos.x - vm_offset_pos.x) * delta * adstransitionspeed)
	vm_offset_pos.y = math.Approach(vm_offset_pos.y, target_pos.y, (target_pos.y - vm_offset_pos.y) * delta * adstransitionspeed)
	vm_offset_pos.z = math.Approach(vm_offset_pos.z, target_pos.z, (target_pos.z - vm_offset_pos.z) * delta * adstransitionspeed)
	vm_offset_ang.p = math.ApproachAngle(vm_offset_ang.p, target_ang.x, math.AngleDifference(target_ang.x, vm_offset_ang.p) * delta * adstransitionspeed)
	vm_offset_ang.y = math.ApproachAngle(vm_offset_ang.y, target_ang.y, math.AngleDifference(target_ang.y, vm_offset_ang.y) * delta * adstransitionspeed)
	vm_offset_ang.r = math.ApproachAngle(vm_offset_ang.r, target_ang.z, math.AngleDifference(target_ang.z, vm_offset_ang.r) * delta * adstransitionspeed)

	intensityWalk = math.min(self:GetOwner():GetVelocity():Length2D() / self:GetOwner():GetWalkSpeed(), 1)

	if self2.WalkBobMult_Iron and self:GetNW2Float("IronSightsProgress") > 0.01 then
		intensityWalk = intensityWalk * self2.WalkBobMult_Iron * self:GetNW2Float("IronSightsProgress")
	else
		intensityWalk = intensityWalk * self2.WalkBobMult
	end

	intensityBreath = l_Lerp(self:GetNW2Float("IronSightsProgress"), self2.GetStat(self, "BreathScale", 0.2), self2.GetStat(self, "IronBobMultWalk", 0.5) * intensityWalk)
	intensityWalk = intensityWalk * (1 - self:GetNW2Float("IronSightsProgress"))
	intensityRun = l_Lerp(self:GetNW2Float("SprintProgress"), 0, self2.SprintBobMult)
	local velocity = math.max(self:GetOwner():GetVelocity():Length2D() * self:AirWalkScale() - self:GetOwner():GetVelocity().z * 0.5, 0)
	local rate = math.min(math.max(0.15, math.sqrt(velocity / self:GetOwner():GetRunSpeed()) * 1.75), self:GetSprinting() and 5 or 3)

	self2.pos_cached, self2.ang_cached = self:WalkBob(vm_offset_pos * 1, vm_offset_ang * 1, math.max(intensityBreath - intensityWalk - intensityRun, 0), math.max(intensityWalk - intensityRun, 0), rate, delta)
end

--[[
Function Name:  Sway
Syntax: self:Sway( ang ).
Returns:  New angle.
Notes:  This is used for calculating the swep viewmodel sway.
Purpose:  Main SWEP function
]]
--
local rft, eyeAngles, viewPunch, oldEyeAngles, delta, motion, counterMotion, compensation, fac, positionCompensation, swayRate, wiggleFactor, flipFactor
--swayRate = 10
local gunswaycvar = GetConVar("cl_tfa_gunbob_intensity")

function SWEP:Sway(pos, ang, ftv)
	local self2 = self:GetTable()
	--sanity check
	if not self:OwnerIsValid() then return pos, ang end
	--convar
	fac = gunswaycvar:GetFloat() * 3 * ((1 - (self:GetNW2Float("IronSightsProgress") or 0)) * 0.85 + 0.15)
	flipFactor = (self2.ViewModelFlip and -1 or 1)
	--init vars
	delta = delta or Angle()
	motion = motion or Angle()
	counterMotion = counterMotion or Angle()
	compensation = compensation or Angle()

	if ftv then
		--grab eye angles
		eyeAngles = self:GetOwner():EyeAngles()
		viewPunch = self:GetOwner():GetViewPunchAngles()
		eyeAngles.p = eyeAngles.p - viewPunch.p
		eyeAngles.y = eyeAngles.y - viewPunch.y
		oldEyeAngles = oldEyeAngles or eyeAngles
		--calculate delta
		wiggleFactor = (1 - self2.GetStat(self, "MoveSpeed")) / 0.6 + 0.15
		swayRate = math.pow(self2.GetStat(self, "MoveSpeed"), 1.5) * 10
		rft = math.Clamp(ftv, 0.001, 1 / 20)
		local clampFac = 1.1 - math.min((math.abs(motion.p) + math.abs(motion.y) + math.abs(motion.r)) / 20, 1)
		delta.p = math.AngleDifference(eyeAngles.p, oldEyeAngles.p) / rft / 120 * clampFac
		delta.y = math.AngleDifference(eyeAngles.y, oldEyeAngles.y) / rft / 120 * clampFac
		delta.r = math.AngleDifference(eyeAngles.r, oldEyeAngles.r) / rft / 120 * clampFac
		oldEyeAngles = eyeAngles
		--calculate motions, based on Juckey's methods
		counterMotion = LerpAngle(rft * (swayRate * (0.75 + math.max(0, 0.5 - wiggleFactor))), counterMotion, -motion)
		compensation.p = math.AngleDifference(motion.p, -counterMotion.p)
		compensation.y = math.AngleDifference(motion.y, -counterMotion.y)
		motion = LerpAngle(rft * swayRate, motion, delta + compensation)
	end

	--modify position/angle
	positionCompensation = 0.2 + 0.2 * (self:GetNW2Float("IronSightsProgress") or 0)
	pos:Add(-motion.y * positionCompensation * 0.66 * fac * ang:Right() * flipFactor) --compensate position for yaw
	pos:Add(-motion.p * positionCompensation * fac * ang:Up()) --compensate position for pitch
	ang:RotateAroundAxis(ang:Right(), motion.p * fac)
	ang:RotateAroundAxis(ang:Up(), -motion.y * 0.66 * fac * flipFactor)
	ang:RotateAroundAxis(ang:Forward(), counterMotion.r * 0.5 * fac * flipFactor)

	return pos, ang
end

--local vmfov
--local bbvec
function SWEP:AirWalkScale()
	return (self:OwnerIsValid() and self:GetOwner():IsOnGround()) and 1 or 0.2
end

function SWEP:GetViewModelPosition(pos, ang)
	local self2 = self:GetTable()
	if not self2.pos_cached then return pos, ang end
	ang:RotateAroundAxis(ang:Right(), self2.ang_cached.p)
	ang:RotateAroundAxis(ang:Up(), self2.ang_cached.y)
	ang:RotateAroundAxis(ang:Forward(), self2.ang_cached.r)
	pos:Add(ang:Right() * self2.pos_cached.x)
	pos:Add(ang:Forward() * self2.pos_cached.y)
	pos:Add(ang:Up() * self2.pos_cached.z)
	pos, ang = self:Sway(pos, ang)
	return self:SprintBob(pos, ang, l_Lerp(self:GetNW2Float("SprintProgress"), 0, self2.SprintBobMult))
end

local onevec = Vector(1, 1, 1)

local function RBP(vm)
	local bc = vm:GetBoneCount()
	if not bc or bc <= 0 then return end

	for i = 0, bc do
		vm:ManipulateBoneScale(i, onevec)
		vm:ManipulateBoneAngles(i, angle_zero)
		vm:ManipulateBonePosition(i, vector_origin)
	end
end

function SWEP:ResetViewModelModifications()
	local self2 = self:GetTable()
	if not self:VMIV() then return end

	local vm = self2.OwnerViewModel

	RBP(vm)

	vm:SetSkin(0)

	local matcount = #(vm:GetMaterials() or {})

	for i = 0, matcount do
		vm:SetSubMaterial(i, "")
	end

	for i = 0, #(vm:GetBodyGroups() or {}) - 1 do
		vm:SetBodygroup(i, 0)
	end
end
