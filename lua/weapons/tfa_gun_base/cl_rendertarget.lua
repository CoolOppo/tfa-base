--[[
Example RT

local wepcol = Color(0,0,0,255)

local cd = {}

SWEP.RTMaterialOverride = 0

SWEP.RTOpaque = true

SWEP.RTCode = function( wep )

	render.OverrideAlphaWriteEnable( true, true)
	surface.SetDrawColor(color_white)
	surface.DrawRect(-512,-512,1024,1024)
	render.OverrideAlphaWriteEnable( true, true)

	local ang = EyeAngles()

	local AngPos = wep.Owner:GetViewModel():GetAttachment(1)

	if AngPos then

		ang = AngPos.Ang

		ang:RotateAroundAxis(ang:Right(),90)

	end

	cd.angles = ang
	cd.origin = wep.Owner:GetShootPos()

	cd.x = 0
	cd.y = 0
	cd.w = 512
	cd.h = 512
	cd.fov = 4
	cd.drawviewmodel = false
	cd.drawhud = false

	render.RenderView(cd)

	render.OverrideAlphaWriteEnable( false, true)


	cam.Start2D()
		draw.NoTexture()
		local plywepcol = wep.Owner:GetWeaponColor()
		wepcol.r = plywepcol.r*255
		wepcol.g = plywepcol.g*255
		wepcol.b = plywepcol.b*255
		surface.SetDrawColor(wepcol)
		drawFilledCircle(256,256,8,16)
		surface.DrawRect(64,256-4,128,8)
		surface.DrawRect(512-64-128,256-4,128,8)
		surface.DrawRect(256-4,512-64-128,8,128)
	cam.End2D()

end
]]--
local onevec = Vector(1, 1, 1)

function RBP(vm)
	local bc = vm:GetBoneCount()
	if not bc or bc <= 0 then return end

	for i = 0, bc do
		vm:ManipulateBoneScale(i, onevec)
		vm:ManipulateBoneAngles(i, angle_zero)
		vm:ManipulateBonePosition(i, vector_origin)
	end
end

if CLIENT then
	local props = {
		["$translucent"] = 1
	}

	local TFA_RTMat = CreateMaterial("tfa_rtmaterial", "UnLitGeneric", props) --Material("models/weapons/TFA/shared/optic")
	local TFA_RTScreen = GetRenderTargetEx("TFA_RT_Screen", 512, 512, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_ARGB8888)
	local TFA_RTScreenO = GetRenderTargetEx("TFA_RT_ScreenO", 512, 512, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGB888)
	local oldVmModel = ""
	local oldwepclass = ""

	local function TFARenderScreen()
	local lply = LocalPlayer()
	if not IsValid(lply) then return end
	local vm = lply:GetViewModel()
	if not IsValid(vm) then return end
	local wep = lply:GetActiveWeapon()

	if oldVmModel ~= vm:GetModel() or (IsValid(wep) and oldwepclass ~= wep:GetClass()) then
		RBP(vm)
		local matcount = #(vm:GetMaterials() or {})
		local i = 0

		while i <= matcount do
			vm:SetSubMaterial(i, "")
			i = i + 1
		end

		oldVmModel = vm:GetModel()

		if IsValid(wep) and IsValid(wep.Owner) then
			local ow = wep.Owner
			local owweps = ow:GetWeapons()

			for k, v in pairs(owweps) do
				if IsValid(v) and v:GetClass() == oldwepclass then
					v.MaterialCached = nil
				end
			end
		end

		return
	end

	oldwepclass = ""
	if not IsValid(wep) then return end
	oldwepclass = wep:GetClass()

	if wep.MaterialTable then

		if not wep.MaterialCached then
			wep.MaterialCached = {}

			if #wep.MaterialTable >= 1 and #wep:GetMaterials() <= 1 then
				wep:SetMaterial(wep.MaterialTable[1])
			else
				wep:SetMaterial("")
			end

			wep:SetSubMaterial(nil, nil)
			vm:SetSubMaterial(nil, nil)
		end

		for k, v in ipairs(wep.MaterialTable) do
			if not wep.MaterialCached[k] then
				wep:SetSubMaterial(k - 1, v)
				vm:SetSubMaterial(k - 1, v)
				wep.MaterialCached[k] = true
			end
		end
	end

	if not wep.RTMaterialOverride or not wep.RTCode then return end
	oldVmModel = vm:GetModel()
	local w, h = ScrW(), ScrH()
	local oldrt = render.GetRenderTarget()

	if not wep.RTOpaque then
		render.SetRenderTarget(TFA_RTScreen)
	else
		render.SetRenderTarget(TFA_RTScreenO)
	end

	render.Clear(0, 0, 0, 0, true, true)
	render.SetViewPort(0, 0, 512, 512)
	wep:RTCode(TFA_RTMat, w, h)
	render.SetRenderTarget(oldrt)
	render.SetViewPort(0, 0, w, h)

	if not wep.RTOpaque then
		TFA_RTMat:SetTexture("$basetexture", TFA_RTScreen)
	else
		TFA_RTMat:SetTexture("$basetexture", TFA_RTScreenO)
	end

	wep.Owner:GetViewModel():SetSubMaterial(wep.RTMaterialOverride, "!tfa_rtmaterial")
end

hook.Add("RenderScene", "TFASCREENS", TFARenderScreen)
end
