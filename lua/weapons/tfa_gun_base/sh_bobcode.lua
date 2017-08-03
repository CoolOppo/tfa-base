
SWEP.ti = 0
SWEP.LastCalcBob = 0

local rate_up = 12
local scale_up = 0.3
local rate_right = 6
local scale_right = 0.3
local rate_forward_view = 6
local scale_forward_view = 0.35
local rate_right_view = 6
local scale_right_view = -1

local rate_p = 12
local scale_p = 3
local rate_y = 6
local scale_y = 6
local rate_r = 6
local scale_r = -3



local pist_rate = 6
local pist_scale = 8

local rate_clamp = 2


local sv_cheats_cv = GetConVar("sv_cheats")
local host_timescale_cv = GetConVar("host_timescale")

function SWEP:CalculateBob(pos, ang, intensity, rate )
	if not self:OwnerIsValid() then return end
	rate = math.min( rate, rate_clamp )

	local ea = self.Owner:EyeAngles()
	local up = ang:Up()
	local ri = ang:Right()
	local fw = ang:Forward()
	local delta = math.min( SysTime() - self.LastCalcBob, FrameTime() )
	if sv_cheats_cv:GetBool() then
		delta = delta * host_timescale_cv:GetFloat()
	end
	local flip_v =  self.ViewModelFlip and -1 or 1
	delta = delta * game.GetTimeScale()
	self.LastCalcBob = SysTime()

	self.ti = self.ti + delta * rate

	if self.SprintStyle == nil then
		if self.RunSightsAng and self.RunSightsAng.x > 5 then
			self.SprintStyle = 1
		else
			self.SprintStyle = 0
		end
	end

	if self.SprintStyle == 1 then
		local intensity2 = math.Clamp( intensity, 0.0, 0.2 )
		local intensity3 = math.max(intensity-0.3,0) / ( 1 - 0.3 )

		pos:Add( up * math.sin( self.ti * rate_up ) * scale_up * intensity2 )
		pos:Add( ri * math.sin( self.ti * rate_right ) * scale_right * intensity2 )
		pos:Add( ea:Forward()  * math.sin( self.ti * rate_forward_view ) * scale_forward_view * intensity2 )
		pos:Add( ea:Right() * math.sin( self.ti * rate_right_view ) * scale_right_view * intensity2 )

		ang:RotateAroundAxis( ri, math.sin( self.ti * rate_p ) * scale_p * intensity2 )
		pos:Add( -up * math.sin( self.ti * rate_p ) * scale_p * 0.1 * intensity2 )
		pos:Add( -fw * math.sin( self.ti * rate_p ) * scale_p * 0.1 * intensity2 )

		ang:RotateAroundAxis( ang:Up(), math.sin( self.ti * rate_y ) * scale_y * intensity2 )
		pos:Add( ri * math.sin( self.ti * rate_y ) * scale_y * 0.1 * intensity2 )
		pos:Add( fw * math.sin( self.ti * rate_y ) * scale_y * 0.1 * intensity2 )

		ang:RotateAroundAxis( ang:Forward(), math.sin( self.ti * rate_r ) * scale_r * intensity2 )
		pos:Add( ri * math.sin( self.ti * rate_r ) * scale_r * 0.1 * intensity2 )
		pos:Add( -up * math.sin( self.ti * rate_r ) * scale_r * 0.1 * intensity2)

		ang:RotateAroundAxis( ang:Up(), math.sin( self.ti * pist_rate ) * pist_scale * intensity3 )
		pos:Add( ri * math.sin( self.ti * pist_rate ) * pist_scale * 0.1 * intensity3 )
		pos:Add( fw * math.sin( self.ti * pist_rate * 2 ) * pist_scale * 0.1 * intensity3)
		--pos:Add( fw * math.sin( self.ti * pist_rate ) * pist_scale * 0.1 * intensity )

	else
		pos:Add( up * math.sin( self.ti * rate_up ) * scale_up * intensity )
		pos:Add( ri * math.sin( self.ti * rate_right ) * scale_right * intensity * flip_v )
		pos:Add( ea:Forward()  * math.max( math.sin( self.ti * rate_forward_view ), 0 ) * scale_forward_view * intensity  )
		pos:Add( ea:Right() * math.sin( self.ti * rate_right_view ) * scale_right_view * intensity * flip_v  )

		ang:RotateAroundAxis( ri, math.sin( self.ti * rate_p ) * scale_p * intensity )
		pos:Add( -up * math.sin( self.ti * rate_p ) * scale_p * 0.1 * intensity )
		pos:Add( -fw * math.sin( self.ti * rate_p ) * scale_p * 0.1 * intensity )

		ang:RotateAroundAxis( ang:Up(), math.sin( self.ti * rate_y ) * scale_y * intensity * flip_v  )
		pos:Add( ri * math.sin( self.ti * rate_y ) * scale_y * 0.1 * intensity * flip_v  )
		pos:Add( fw * math.sin( self.ti * rate_y ) * scale_y * 0.1 * intensity )

		ang:RotateAroundAxis( ang:Forward(), math.sin( self.ti * rate_r ) * scale_r * intensity * flip_v  )
		pos:Add( ri * math.sin( self.ti * rate_r ) * scale_r * 0.1 * intensity * flip_v  )
		pos:Add( -up * math.sin( self.ti * rate_r ) * scale_r * 0.1 * intensity )

	end

	return pos, ang
end

function SWEP:CalculateViewBob( pos, ang, intensity )
	if not self:OwnerIsValid() then return end
	local up = ang:Up()
	local ri = ang:Right()
	local opos = pos * 1
	local ldist = self:GetOwner():GetEyeTraceNoCursor().HitPos:Distance(pos)
	if ldist <= 0 then
		ldist = util.QuickTrace( pos, ang:Forward() * 999999, { self:GetOwner(), self:GetOwner():GetEyeTraceNoCursor().Entity } ).HitPos:Distance( pos )
	end
	pos:Add( up * math.sin( ( self.ti + 0.5 ) * rate_up ) * scale_up * intensity * -3 )
	pos:Add( ri * math.sin( ( self.ti + 0.5 ) * rate_right ) * scale_right * intensity * -3 )

	--ang = ang + vpa

	local tpos = opos + ldist * ang:Forward()
	local oang = ang * 1
	local nang = (tpos - opos):GetNormalized():Angle()
	ang:Normalize()
	nang:Normalize()
	local vfac = math.Clamp( 1 - math.pow( math.abs( oang.p ) / 90, 3  ), 0, 1 )
	ang.y = ang.y - math.Clamp( math.AngleDifference(ang.y,nang.y), -2, 2 ) * vfac
	ang.p = ang.p - math.Clamp( math.AngleDifference(ang.p,nang.p), -2, 2 ) * vfac
	--ang:Normalize()
	--ang.r = oang.r
	--print(ang)

	return pos, ang
end