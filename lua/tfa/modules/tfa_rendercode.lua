hook.Add("PreDrawOpaqueRenderables", "tfaweaponspredrawopaque", function()
	for _, v in pairs(player.GetAll()) do
		local wep = v:GetActiveWeapon()

		if IsValid(wep) and wep.PreDrawOpaqueRenderables then
			wep:PreDrawOpaqueRenderables()
		end
	end
end)
