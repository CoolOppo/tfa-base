
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

hook.Add("PlayerSwitchWeapon","TFA_Bodygroups_PSW",function(ply,oldwep,wep)
	if not IsValid(wep) then return end
	timer.Simple(0,function()
		if IsValid(ply) and ply:GetActiveWeapon() == wep then
			local vm = ply:GetViewModel()
			if not IsValid(vm) then
				vm = ply:GetViewModel()
				return
			end

			local bgcount = #(vm:GetBodyGroups() or {})
			local bgt = wep.Bodygroups_V or wep.Bodygroups or {}
			if wep.GetStat then
				bgt = wep:GetStat("Bodygroups_V",bgt)
			end
			for i = 0,bgcount-1 do
				vm:SetBodygroup(i, bgt[i] or 0)
			end
		end
	end)
end)

if CLIENT then
	TFA_RENDERTARGET = false

	local props = {
		["$translucent"] = 1
	}

	local TFA_RTMat = CreateMaterial("tfa_rtmaterial", "UnLitGeneric", props) --Material("models/weapons/TFA/shared/optic")
	local TFA_RTScreen, TFA_RTScreenO
	local oldVmModel = ""
	local oldWep = nil
	local tgt
	local old_bt

	local ply, vm, wep

	local function TFARenderScreen()
		ply = GetViewEntity()
		if not IsValid(ply) or not ply:IsPlayer() then
			ply = LocalPlayer()
			return
		end
		if not IsValid(vm) then
			vm = ply:GetViewModel()
			return
		end
		wep = ply:GetActiveWeapon()
		if oldVmModel ~= vm:GetModel() or ( wep ~= oldWep ) then
			old_bt = nil
			if IsValid(oldWep) then
				oldWep.MaterialCached = nil
			end
			oldWep = wep
			RBP(vm)
			vm:SetSkin(0)
			local matcount = #(vm:GetMaterials() or {})

			for i = 0,matcount do
				vm:SetSubMaterial(i, "")
				i = i + 1
			end

			local bgcount = #(vm:GetBodyGroups() or {})
			local bgt = wep.Bodygroups_V or wep.Bodygroups or {}
			if wep.GetStat then
				bgt = wep:GetStat("Bodygroups_V",bgt)
			end
			for i = 0,bgcount-1 do
				vm:SetBodygroup(i, bgt[i] or 0)
			end

			oldVmModel = vm:GetModel()

			if IsValid(wep) and IsValid(wep:GetOwner()) then
				local ow = wep:GetOwner()
				local owweps = ow:GetWeapons()

				for k, v in pairs(owweps) do
					if IsValid(v) and v:GetClass() == oldwepclass then
						v.MaterialCached = nil
					end
				end
			end

			return
		end


		if not IsValid(wep) or not wep.IsTFAWeapon then
			return
		end

		if wep:GetStat("Skin") and isnumber(wep:GetStat("Skin")) then
			vm:SetSkin(wep:GetStat("Skin"))
			wep:SetSkin(wep:GetStat("Skin"))
		end

		if wep:GetStat("MaterialTable") and not wep.MaterialCached then
			wep.MaterialCached = {}

			if #wep:GetStat("MaterialTable") >= 1 and #wep:GetMaterials() <= 1 then
				wep:SetMaterial(wep:GetStat("MaterialTable")[1])
			else
				wep:SetMaterial("")
			end

			wep:SetSubMaterial(nil, nil)
			vm:SetSubMaterial(nil, nil)
			for k, v in ipairs(wep:GetStat("MaterialTable")) do
				if not wep.MaterialCached[k] then
					wep:SetSubMaterial(k - 1, v)
					vm:SetSubMaterial(k - 1, v)
					wep.MaterialCached[k] = true
				end
			end
		end

		if not wep:GetStat("RTMaterialOverride") or not wep.RTCode then return end
		oldVmModel = vm:GetModel()
		local w, h = ScrW(), ScrH()

		if not TFA_RTScreen then
			TFA_RTScreen = {}
			TFA_RTScreenO = {}
			TFA_RTScreen[0] = GetRenderTargetEx("TFA_RT_Screen", 2048, 2048, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_ARGB8888)
			TFA_RTScreenO[0] = GetRenderTargetEx("TFA_RT_ScreenO",2048, 2048, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGB888)
			TFA_RTScreen[1] = GetRenderTargetEx("TFA_RT_Screen_1024", 1024, 1024, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_ARGB8888)
			TFA_RTScreenO[1] = GetRenderTargetEx("TFA_RT_ScreenO_1024",1024, 1024, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGB888)
			TFA_RTScreen[2] = GetRenderTargetEx("TFA_RT_Screen_512", 512, 512, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_ARGB8888)
			TFA_RTScreenO[2] = GetRenderTargetEx("TFA_RT_ScreenO_512",512, 512, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGB888)
			TFA_RTScreen[3] = GetRenderTargetEx("TFA_RT_Screen_256", 512, 512, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_ARGB8888)
			TFA_RTScreenO[3] = GetRenderTargetEx("TFA_RT_ScreenO_256",512, 512, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGB888)
		end

		if wep:GetStat("RTOpaque") then
			tgt = TFA_RTScreenO[ TFA.RTQuality() ] or TFA_RTScreenO[ 2 ]
		else
			tgt = TFA_RTScreen[ TFA.RTQuality() ] or TFA_RTScreen[ 2 ]
		end
		render.PushRenderTarget( tgt )


		render.Clear(0, 0, 0, 0, true, true)
		render.Clear(0, 0, 0, 255, true, true)
		TFA_RENDERTARGET = true
		render.CullMode(MATERIAL_CULLMODE_CCW )
		wep:RTCode(TFA_RTMat, w, h)
		TFA_RENDERTARGET = false
		render.PopRenderTarget()
		render.SetScissorRect(0, 0, ScrW(), ScrH(), false)
		if old_bt ~= tgt then
			TFA_RTMat:SetTexture("$basetexture", tgt)
			old_bt = tgt
		end
		wep:GetOwner():GetViewModel():SetSubMaterial(wep:GetStat("RTMaterialOverride"), "!tfa_rtmaterial")
	end

	hook.Add("PreRender", "TFASCREENS", function()
		if not TFA.RT_DRAWING then
			TFA.RT_DRAWING = true
			TFARenderScreen()
			TFA.RT_DRAWING = false
		end
	end)
	TFA.RT_DRAWING = false
	hook.Add("PreDrawViewModel", "TFASCREENS", function()
		--[[
		if not TFA_RT_DRAWING then
			TFA_RT_DRAWING = true
			TFARenderScreen()
			TFA_RT_DRAWING = false
		end
		]]--
	end)
	hook.Add("RenderScene", "TFASCREENS", function()
	end)
	--hook.Add("RenderScene", "TFASCREENS", TFARenderScreen)
end
