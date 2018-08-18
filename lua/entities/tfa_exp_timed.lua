ENT.Base = "tfa_exp_base"
ENT.PrintName = "Timed Explosive"

function ENT:PhysicsCollide(data, phys)
	if data.Speed > 60 then
		self:EmitSound(Sound("HEGrenade.Bounce"))
		local impulse = (data.OurOldVelocity - 2 * data.OurOldVelocity:Dot(data.HitNormal) * data.HitNormal) * 0.25
		phys:ApplyForceCenter(impulse)
	end
end