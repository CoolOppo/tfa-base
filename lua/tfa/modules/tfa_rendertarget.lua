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

hook.Add("PlayerSwitchWeapon", "TFA_Bodygroups_PSW", function(ply, oldwep, wep)
	if not IsValid(wep) then return end

	timer.Simple(0, function()
		if IsValid(ply) and ply:GetActiveWeapon() == wep then
			local vm = ply:GetViewModel()
			if not IsValid(vm) then return end
			local bgcount = #(vm:GetBodyGroups() or {})
			local bgt = wep.Bodygroups_V or wep.Bodygroups or {}

			if wep.GetStat then
				bgt = wep:GetStat("Bodygroups_V", bgt)
			end

			for i = 0, bgcount - 1 do
				vm:SetBodygroup(i, bgt[i] or 0)
			end
		end
	end)
end)

if CLIENT then
	TFA.DrawingRenderTarget = false

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

		if oldVmModel ~= vm:GetModel() or (wep ~= oldWep) then
			old_bt = nil

			if IsValid(oldWep) then
				oldWep.MaterialCached_V = nil
			end

			oldWep = wep
			RBP(vm)
			vm:SetSkin(0)
			local matcount = #(vm:GetMaterials() or {})

			for i = 0, matcount do
				vm:SetSubMaterial(i, "")
			end

			local bgcount = #(vm:GetBodyGroups() or {})
			local bgt = wep.Bodygroups_V or wep.Bodygroups or {}

			if wep.GetStat then
				bgt = wep:GetStat("Bodygroups_V", bgt)
			end

			for i = 0, bgcount - 1 do
				vm:SetBodygroup(i, bgt[i] or 0)
			end

			oldVmModel = vm:GetModel()
			oldWep = wep

			return
		end

		if not IsValid(wep) or not wep:IsTFA() then return end

		if not wep.MaterialCached then
			wep.MaterialCached = true
			wep.MaterialCached_V = nil
			wep.MaterialCached_W = nil
		end

		local skinStat = wep:GetStat("Skin")

		if skinStat and isnumber(skinStat) then
			if vm:GetSkin() ~= skinStat then
				vm:SetSkin(wep:GetStat("Skin"))
			end

			if wep:GetSkin() ~= skinStat then
				wep:SetSkin(wep:GetStat("Skin"))
			end
		end

		if wep:GetStat("MaterialTable_V") and not wep.MaterialCached_V then
			wep.MaterialCached_V = {}
			vm:SetSubMaterial()
			local collectedKeys = table.GetKeys(wep:GetStat("MaterialTable_V"))
			table.Merge(collectedKeys, table.GetKeys(wep:GetStat("MaterialTable")))

			for _, k in pairs(collectedKeys) do
				if (k == "BaseClass") then continue end
				local v = wep:GetStat("MaterialTable_V")[k]

				if not wep.MaterialCached_V[k] then
					vm:SetSubMaterial(k - 1, v)
					wep.MaterialCached_V[k] = true
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
			TFA_RTScreenO[0] = GetRenderTargetEx("TFA_RT_ScreenO", 2048, 2048, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGB888)
			TFA_RTScreen[1] = GetRenderTargetEx("TFA_RT_Screen_1024", 1024, 1024, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_ARGB8888)
			TFA_RTScreenO[1] = GetRenderTargetEx("TFA_RT_ScreenO_1024", 1024, 1024, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGB888)
			TFA_RTScreen[2] = GetRenderTargetEx("TFA_RT_Screen_512", 512, 512, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_ARGB8888)
			TFA_RTScreenO[2] = GetRenderTargetEx("TFA_RT_ScreenO_512", 512, 512, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGB888)
			TFA_RTScreen[3] = GetRenderTargetEx("TFA_RT_Screen_256", 256, 256, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_ARGB8888)
			TFA_RTScreenO[3] = GetRenderTargetEx("TFA_RT_ScreenO_256", 256, 256, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGB888)
		end

		if wep:GetStat("RTOpaque") then
			tgt = TFA_RTScreenO[TFA.RTQuality()] or TFA_RTScreenO[2]
		else
			tgt = TFA_RTScreen[TFA.RTQuality()] or TFA_RTScreen[2]
		end

		TFA.LastRTUpdate = UnPredictedCurTime() + 0.01
		render.PushRenderTarget(tgt)
		render.Clear(0, 0, 0, 0, true, true)
		render.Clear(0, 0, 0, 255, true, true)
		TFA.DrawingRenderTarget = true
		render.CullMode(MATERIAL_CULLMODE_CCW)
		ProtectedCall(function()
			wep:RTCode(TFA_RTMat, w, h)
		end)
		TFA.DrawingRenderTarget = false
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

	local rt_res_tbl = {
		[0] = 2048,
		[1] = 1024,
		[2] = 512,
		[3] = 256
	}

	local cv_rt = GetConVar("cl_tfa_3dscope_quality")

	local function checkConVar()
		if not cv_rt then
			cv_rt = GetConVar("cl_tfa_3dscope_quality")
		end

		if cv_rt:GetInt() < 0 then return end -- it's set to autodetect already
		local res = rt_res_tbl[math.Clamp(cv_rt:GetInt(), 0, 3)]

		if res and (ScrW() < res or ScrH() < res) then
			print("[TFA Base] Your screen resolution is too low for selected RT scope resolution, reverting to auto-detect.")
			cv_rt:SetInt(-1)
		end
	end

	hook.Add("InitPostEntity", "TFA_RT_ResolutionEnforcer", checkConVar)
	cvars.AddChangeCallback("cl_tfa_3dscope_quality", checkConVar, "TFA_RT_ResolutionEnforcer")
end