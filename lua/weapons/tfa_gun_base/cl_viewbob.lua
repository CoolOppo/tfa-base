--[[
Function Name:  CalcView
Syntax: Don't ever call this manually.
Returns:  Nothing.
Notes:  Used to calculate view angles.
Purpose:  Feature
]]--

SWEP.ViewHolProg = 0
SWEP.AttachmentViewOffset = Angle(0, 0, 0)
SWEP.ProceduralViewOffset = Angle(0, 0, 0)
local procedural_fadeout = 0.6
local procedural_vellimit = 5
local l_Lerp = Lerp
local l_mathApproach = math.Approach
local l_mathClamp = math.Clamp
local viewbob_intensity_cvar, viewbob_drawing_cvar, viewbob_reloading_cvar
viewbob_intensity_cvar = GetConVar("cl_tfa_viewbob_intensity")
viewbob_drawing_cvar = GetConVar("cl_tfa_viewbob_drawing")
viewbob_reloading_cvar = GetConVar("cl_tfa_viewbob_reloading")
local oldangtmp, oldpostmp
local mzang_fixed
local mzang_fixed_last
local mzang_velocity = Angle()
local progress = 0

function SWEP:CalcView(ply, pos, ang, fov)
	if not ang then return end
	if ply ~= LocalPlayer() then return end
	local vm = ply:GetViewModel()
	if not IsValid(vm) then return end
	if not CLIENT then return end
	local ftv = math.max(FrameTime(), 0.001)
	local viewbobintensity = 0.2 * viewbob_intensity_cvar:GetFloat()
	local holprog = self.ProceduralHolsterFactor

	if self.lastact == ACT_VM_HOLSTER or self.lastact == ACT_VM_HOLSTER_EMPTY then
		holprog = math.max(holprog, vm:GetCycle())
	end

	if self.lastact == ACT_VM_DRAW or self.lastact == ACT_VM_DRAW_EMPTY or self.lastact == ACT_VM_DRAW_SILENCED then
		holprog = math.max(holprog, math.Clamp(0.2 - vm:GetCycle(), 0, 1) * 5)
	end

	self.ViewHolProg = math.Approach(self.ViewHolProg, holprog, ftv * 15)
	oldpostmp = pos * 1
	oldangtmp = ang * 1
	pos, ang = self:CalculateBob(pos, ang, -viewbobintensity * (1 - self.ViewHolProg), true)
	if not ang or not pos then return oldangtmp, oldpostmp end

	if self.CameraAngCache then
		self.CameraAttachmentScale = self.CameraAttachmentScale or 1
		ang:RotateAroundAxis(ang:Right(), (self.CameraAngCache.p + self.CameraOffset.p) * viewbobintensity * 5 * self.CameraAttachmentScale)
		ang:RotateAroundAxis(ang:Up(), (self.CameraAngCache.y + self.CameraOffset.y) * viewbobintensity * 5 * self.CameraAttachmentScale)
		ang:RotateAroundAxis(ang:Forward(), (self.CameraAngCache.r + self.CameraOffset.r) * viewbobintensity * 3 * self.CameraAttachmentScale)
		-- - self.MZReferenceAngle--WorldToLocal( angpos.Pos, angpos.Ang, angpos.Pos, oldangtmp + self.MZReferenceAngle )
		--* progress )
		--self.ProceduralViewOffset.p = l_mathApproach(self.ProceduralViewOffset.p, 0 , l_mathClamp( procedural_pitchrestorefac - math.min( math.abs( self.ProceduralViewOffset.p ), procedural_pitchrestorefac ) ,1,procedural_pitchrestorefac)*ftv/5 )
		--self.ProceduralViewOffset.y = l_mathApproach(self.ProceduralViewOffset.y, 0 , l_mathClamp( procedural_pitchrestorefac - math.min( math.abs( self.ProceduralViewOffset.y ), procedural_pitchrestorefac ) ,1,procedural_pitchrestorefac)*ftv/5 )
		--self.ProceduralViewOffset.r = l_mathApproach(self.ProceduralViewOffset.r, 0 , l_mathClamp( procedural_pitchrestorefac - math.min( math.abs( self.ProceduralViewOffset.r ), procedural_pitchrestorefac ) ,1,procedural_pitchrestorefac)*ftv/5 )
	else
		local vb_d, vb_r, idraw, ireload, ihols
		idraw = self:GetDrawing()
		ihols = self:GetHolstering()
		ireload = self:GetReloading()
		vb_d = viewbob_drawing_cvar:GetBool()
		vb_r = viewbob_reloading_cvar:GetBool()

		if vb_d and idraw then
			progress = l_Lerp(ftv * 15, progress, l_mathClamp((self:GetDrawingEnd() - CurTime()) / procedural_fadeout, 0, 1))
		elseif vb_d and ihols then
			progress = l_Lerp(ftv * 15, progress, l_mathClamp((self:GetHolsteringEnd() - CurTime()) / procedural_fadeout, 0, 1))
		elseif vb_r and ireload then
			progress = l_Lerp(ftv * 15, progress, l_mathClamp((self:GetReloadingEnd() - CurTime()) / procedural_fadeout, 0, 1))
		elseif self.GetBashing then
			if self:GetBashing() then
				local ceil = 0.65
				progress = l_Lerp(ftv * 15, progress, l_mathClamp(ceil - vm:GetCycle(), 0, ceil) / (1 - ceil))
			else
				progress = l_Lerp(ftv * 10, progress, 0)
			end
		elseif self:GetShooting() and self.ViewBob_Shoot then
			progress = l_Lerp(ftv * 15, progress, l_mathClamp((self:GetShootingEnd() - CurTime()) / procedural_fadeout, 0, 1))
		end

		local att = self.MuzzleAttachmentRaw or vm:LookupAttachment(self.MuzzleAttachment)

		if not att then
			att = 1
		end

		local angpos = vm:GetAttachment(att)

		if angpos then
			mzang_fixed = vm:WorldToLocalAngles(angpos.Ang)
			mzang_fixed:Normalize()
		end

		self.ProceduralViewOffset:Normalize()

		if mzang_fixed_last then
			local delta = mzang_fixed - mzang_fixed_last
			delta:Normalize()
			mzang_velocity = mzang_velocity + delta * (2 * (1 - self.ViewHolProg))
			mzang_velocity.p = l_mathApproach(mzang_velocity.p, -self.ProceduralViewOffset.p * 2, ftv * 20)
			mzang_velocity.p = l_mathClamp(mzang_velocity.p, -procedural_vellimit, procedural_vellimit)
			self.ProceduralViewOffset.p = self.ProceduralViewOffset.p + mzang_velocity.p * ftv
			self.ProceduralViewOffset.p = l_mathClamp(self.ProceduralViewOffset.p, -90, 90)
			mzang_velocity.y = l_mathApproach(mzang_velocity.y, -self.ProceduralViewOffset.y * 2, ftv * 20)
			mzang_velocity.y = l_mathClamp(mzang_velocity.y, -procedural_vellimit, procedural_vellimit)
			self.ProceduralViewOffset.y = self.ProceduralViewOffset.y + mzang_velocity.y * ftv
			self.ProceduralViewOffset.y = l_mathClamp(self.ProceduralViewOffset.y, -90, 90)
			mzang_velocity.r = l_mathApproach(mzang_velocity.r, -self.ProceduralViewOffset.r * 2, ftv * 20)
			mzang_velocity.r = l_mathClamp(mzang_velocity.r, -procedural_vellimit, procedural_vellimit)
			self.ProceduralViewOffset.r = self.ProceduralViewOffset.r + mzang_velocity.r * ftv
			self.ProceduralViewOffset.r = l_mathClamp(self.ProceduralViewOffset.r, -90, 90)
		end

		self.ProceduralViewOffset.p = l_mathApproach(self.ProceduralViewOffset.p, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.p)
		self.ProceduralViewOffset.y = l_mathApproach(self.ProceduralViewOffset.y, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.y)
		self.ProceduralViewOffset.r = l_mathApproach(self.ProceduralViewOffset.r, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.r)
		mzang_fixed_last = mzang_fixed
		local ints = viewbob_intensity_cvar:GetFloat()
		ang:RotateAroundAxis(ang:Right(), l_Lerp(progress, 0, -self.ProceduralViewOffset.p) * ints)
		ang:RotateAroundAxis(ang:Up(), l_Lerp(progress, 0, self.ProceduralViewOffset.y / 2) * ints)
		ang:RotateAroundAxis(ang:Forward(), Lerp(progress, 0, self.ProceduralViewOffset.r / 3) * ints)
	end

	return pos, LerpAngle(self.ViewHolProg, ang, oldangtmp), fov
end
