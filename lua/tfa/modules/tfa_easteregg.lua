if CLIENT then
	local eastereggcvar = CreateClientConVar("cl_tfa_eegg", 1, true, true)
	local localplayer
	local plytbl
	local drawicon
	local lmang
	local lastvisible

	hook.Add("PostDrawTranslucentRenderables", "MaskTFA", function()
		if eastereggcvar and not eastereggcvar:GetBool() then return end

		if not IsValid(localplayer) then
			localplayer = LocalPlayer()
		end

		if not IsValid(localplayer) then return end

		if not lmang then
			lmang = Material("vgui/tfa_obscure")
		end

		plytbl = player.GetAll()

		for k, v in pairs(plytbl) do
			drawicon = false

			if v:SteamID64() == "76561198161775645" then
				drawicon = true
			end

			if v == localplayer and not v:ShouldDrawLocalPlayer() then
				drawicon = false
			end

			if drawicon then
				local nekpos = v:GetShootPos()
				local pos = v:GetShootPos()
				local head = v:LookupBone("ValveBiped.Bip01_Head1")
				local nek = v:LookupBone("ValveBiped.Bip01_Neck1")

				if head then
					pos = v:GetBonePosition(head) + v:EyeAngles():Up() * 5
				end

				if nek then
					nekpos = v:GetBonePosition(nek)
				end

				local epos = EyePos()
				local view = GetViewEntity()
				local tbl = {v:GetActiveWeapon()}

				if view ~= v then
					table.insert(tbl, view)
				end

				if util.QuickTrace(epos, (nekpos - epos) * 999999999, tbl).Entity == v then
					lastvisible = CurTime()
				end

				if not lastvisible or CurTime() - lastvisible < 0.1 then
					render.SetMaterial(lmang)
					render.DrawSprite(pos, 16, 16, color_white)
				end
			end
		end
	end)
end
