if SERVER then
	AddCSLuaFile()
	return
end

TFA.ClientsideModels = TFA.ClientsideModels or {}

TFA.RemoveCliensideModel = function( ent )
	if ent and ent.Remove then
		ent.Remove(ent)
	end
	ent = nil
end

TFA.RegisterClientsideModel = function(cmdl,wepv)
	TFA.ClientsideModels[ #TFA.ClientsideModels + 1 ] = { ["mdl"] = cmdl, ["wep"] = wepv }
end

local t, i

timer.Create("TFA_UpdateClientsideModels",0.1,0,function()
	i = 1
	while i <= #TFA.ClientsideModels do
		t = TFA.ClientsideModels[i]
		if not t then
			table.remove( TFA.ClientsideModels, i )
		elseif not IsValid( t.wep ) then
			TFA.RemoveCliensideModel( t.mdl )
			table.remove( TFA.ClientsideModels, i )
		elseif IsValid( t.wep:GetOwner() ) and t.wep:GetOwner().GetActiveWeapon and t.wep ~= t.wep:GetOwner():GetActiveWeapon() then
			TFA.RemoveCliensideModel( t.mdl )
			table.remove( TFA.ClientsideModels, i )
		elseif t.wep.IsHidden and t.wep:IsHidden() then
			TFA.RemoveCliensideModel( t.mdl )
			table.remove( TFA.ClientsideModels, i )
		else
			i = i + 1
		end
	end
end)