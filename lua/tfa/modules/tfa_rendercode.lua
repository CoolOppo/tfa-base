if CLIENT then
	local doblur = CreateClientConVar("cl_tfa_inspection_bokeh", 0, true, false)
	local tfablurintensity = 0
	local blur_mat = Material("pp/bokehblur")
	local tab = {}
	tab["$pp_colour_addr"] = 0
	tab["$pp_colour_addg"] = 0
	tab["$pp_colour_addb"] = 0
	tab["$pp_colour_brightness"] = 0
	tab["$pp_colour_contrast"] = 1
	tab["$pp_colour_colour"] = 1
	tab["$pp_colour_mulr"] = 0
	tab["$pp_colour_mulg"] = 0
	tab["$pp_colour_mulb"] = 0

	local function MyDrawBokehDOF()
		if TFA_RENDERTARGET then return end
		if not ( doblur and doblur:GetBool() ) then return end
		render.UpdateScreenEffectTexture()
		render.UpdateFullScreenDepthTexture()
		blur_mat:SetTexture("$BASETEXTURE", render.GetScreenEffectTexture())
		blur_mat:SetTexture("$DEPTHTEXTURE", render.GetResolvedFullFrameDepth())
		blur_mat:SetFloat("$size", tfablurintensity * 6)
		blur_mat:SetFloat("$focus", 0)
		blur_mat:SetFloat("$focusradius", 0.1)
		render.SetMaterial(blur_mat)
		render.DrawScreenQuad()
	end

	local function Render()
		tfablurintensity = 0
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) then return end
		tfablurintensity = wep.InspectingProgress or 0
		local its = tfablurintensity * 10

		if its > 0.01 then
			if doblur and doblur:GetBool() then
				MyDrawBokehDOF()
			end

			tab["$pp_colour_brightness"] = -tfablurintensity * 0.02
			tab["$pp_colour_contrast"] = 1 - tfablurintensity * 0.1
			if not TFA_RENDERTARGET then
				DrawColorModify(tab)
			end
			cam.IgnoreZ(true)
		end
	end

	local function InitTFABlur()
		local cv = GetConVar("cl_tfa_unreal_dof_enabled")
		hook.Add("PreDrawViewModel", "PreDrawViewModel_TFA_INSPECT", function()
			if cv and cv:GetBool() then return end
			Render()
		end)
		hook.Add("PostDrawTranslucentRenderables", "PreDrawViewModel_TFA_INSPECT", function()
			if not ( cv and cv:GetBool() ) then return end
			Render()
		end)

		local pp_bokeh = GetConVar( "pp_bokeh" )
		hook.Remove("NeedsDepthPass","NeedsDepthPass_Bokeh")
		hook.Add("NeedsDepthPass", "aaaaaaaaaaaaaaaaaaNeedsDepthPass_TFA_Inspect", function()
			if not ( doblur and doblur:GetBool() ) then return end

			if tfablurintensity > 0.01 or ( pp_bokeh and pp_bokeh:GetBool() ) then
				DOFModeHack(true)

				return true
			end
		end)
	end

	hook.Add("InitPostEntity","InitTFABlur",InitTFABlur)

	InitTFABlur()
end

hook.Add("PreDrawOpaqueRenderables", "tfaweaponspredrawopaque", function()
	for k, v in pairs(player.GetAll()) do
		local wep = v:GetActiveWeapon()

		if IsValid(wep) and wep.PreDrawOpaqueRenderables then
			wep:PreDrawOpaqueRenderables()
		end
	end
end)
