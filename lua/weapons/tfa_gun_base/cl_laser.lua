local att
local col = Color(255,0,0,255)
local pc

local laserline
local laserlinetp
local laserdot
local lasernoise

local angpos
local traceres
local dot_sz

local trails_enabled_cv = GetConVar("cl_tfa_laser_trails")

function SWEP:DrawLaser( is_vm )
	if not laserline then
		laserline = Material( self.LaserLine or "effects/spark_noz")
	end
	if not laserlinetp then
		laserlinetp = Material( self.LaserLine or "cable/smoke")
	end
	if not laserdot then
		laserdot = Material( self.LaserDot or "sprites/light_glow02_add")
	end
	if not lasernoise then
		lasernoise = Material( self.LaserNoise or "effects/splash1")
	end
	pc = self:GetOwner():GetWeaponColor()
	col.r = pc.x * 255
	col.g = pc.y * 255
	col.b = pc.z * 255

	if is_vm then
		att = self:GetStat("LaserSightAttachment")
		if ( not att ) or att <= 0 then return end
		angpos = self.OwnerViewModel:GetAttachment( att )
		if not angpos then return end
		traceres = util.QuickTrace( self:GetOwner():GetShootPos(), angpos.Ang:Forward() * 999999, self:GetOwner())
		dot_sz = math.Rand( self.LaserDotMin or 1.5, self.LaserDotMax or 2 )

		render.SetMaterial(laserdot)
		render.DrawQuadEasy(traceres.HitPos, traceres.HitNormal, dot_sz, dot_sz, col, 0)
		render.SetMaterial(lasernoise)
		render.DrawQuadEasy(traceres.HitPos, traceres.HitNormal, dot_sz / 2 * math.Rand( 0.7, 1.3 ), dot_sz / 2 * math.Rand( 0.7, 1.3 ) , col, math.random(-180,180))
		if self.laserpos_old and trails_enabled_cv:GetBool() then
			render.SetMaterial(laserline)
			render.DrawBeam(self.laserpos_old, traceres.HitPos, dot_sz / 2, 0.2, 1, col )
		end
		self.laserpos_old = traceres.HitPos
	else
		att = self:GetStat("LaserSightAttachmentWorld")
		if ( not att ) or att <= 0 then
			att = self:GetStat("LaserSightAttachment")
		end
		if ( not att ) or att <= 0 then return end
		angpos = self:GetAttachment( att )
		if not angpos then
			angpos = self:GetAttachment( 1 )
		end
		if not angpos then return end
		--[[
		if not TFA.Enum.ReloadStatus[ self:GetStatus() ] and not TFA.Enum.HolsterStatus[ self:GetStatus() ] and self:GetStatus() ~= TFA.GetStatus("draw") then
			traceres = util.QuickTrace( self:GetOwner():GetShootPos(), ( self:GetOwner():EyeAngles() + self:GetOwner():GetViewPunchAngles() ) :Forward() * 999999, self:GetOwner())
		else
			traceres = util.QuickTrace( angpos.Pos, angpos.Ang:Forward() * 999999, self:GetOwner())
		end
		]]--
		traceres = util.QuickTrace( angpos.Pos, angpos.Ang:Forward() * 999999, self:GetOwner())
		dot_sz = math.Rand( self.LaserDotMin or 2, self.LaserDotMax or 4 )

		render.SetMaterial(laserlinetp)
		render.SetColorModulation(1,1,1)
		render.DrawBeam( angpos.Pos, traceres.HitPos, self.LaserBeamWidth or 0.25, 0, 8, col)
		render.SetMaterial(laserdot)
		render.DrawQuadEasy(traceres.HitPos, traceres.HitNormal, dot_sz, dot_sz, col, 0)
	end
end

local function GetScreenAspectRatio( )
	return ScrW() / ScrH()
end

local function ScaleFOVByWidthRatio( fovDegrees, ratio )
	local halfAngleRadians = fovDegrees * ( 0.5 * math.pi / 180.0 );
	local t = math.tan( halfAngleRadians );
	t = t * ratio;
	local retDegrees = ( 180.0 / math.pi ) * math.atan( t );
	return retDegrees * 2.0;
end

local default_fov_cv = GetConVar("default_fov")
local ply

local function GetTrueFOV()
	local fov = TFADUSKFOV or fov_cv:GetFloat()
	if not LocalPlayer():IsValid() then return fov end
	ply = LocalPlayer()
	if ply:GetFOV() < ply:GetDefaultFOV() - 1 then
		fov = ply:GetFOV()
	end
	if TFADUSKFOV_FINAL then
		fov = TFADUSKFOV_FINAL
	end
	return fov
end

function SWEP:GetViewModelFinalFOV()
	local fov_default = default_fov_cv:GetFloat()
	local fov = GetTrueFOV()
	local flFOVOffset = fov_default - fov
	local fov_vm = self.ViewModelFOV - flFOVOffset

	local aspectRatio = GetScreenAspectRatio() * 0.75	 -- (4/3)
	--local final_fov = ScaleFOVByWidthRatio( fov,  aspectRatio )
	local final_fovViewmodel = ScaleFOVByWidthRatio( fov_vm, aspectRatio )
	return final_fovViewmodel
end

hook.Add("PostDrawViewModel","TFA_LaserSight",function(vm,plyv,wep)
	if wep:IsTFA() then
		wep:DrawLaser(true)
	end
end)

hook.Add("PostPlayerDraw","TFA_LaserSight",function( plyv )
	local wep = plyv:GetActiveWeapon()
	if IsValid(wep) and wep:IsTFA() and ( plyv ~= LocalPlayer() or not wep:IsFirstPerson() ) then
		wep:DrawLaser(false)
	end
end)