hook.Add("EntityTakeDamage","TFA_TurretPhysics", function(ent,dmg)
	if ent:GetClass() == "npc_turret_floor" then
		ent:TakePhysicsDamage( dmg )
	end
end)