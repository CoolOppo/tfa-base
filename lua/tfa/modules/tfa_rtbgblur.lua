--YuRaNnNzZZ's work at play here
if SERVER then return end

local FT = FrameTime

local tfablurintensity = 0

local cv_mode = CreateClientConVar("cl_tfa_fx_rtscopeblur_mode", "1", true, false)
local funcs = {}

local cv_blur_passes = CreateClientConVar("cl_tfa_fx_rtscopeblur_passes", "3", true, false)
local cv_blur_intensity = CreateClientConVar("cl_tfa_fx_rtscopeblur_intensity", "4", true, false)
local blurTex = Material("pp/blurscreen")
funcs[1] = function()
	surface.SetDrawColor(color_white)
	render.SetMaterial(blurTex)
	local passes = cv_blur_passes:GetInt()

	for i = 1, passes do
		render.UpdateScreenEffectTexture()

		blurTex:SetFloat("$blur", tfablurintensity * cv_blur_intensity:GetFloat() / math.sqrt(passes) )
		blurTex:Recompute()

		render.DrawScreenQuad()
	end
end

local blur_mat = Material("pp/bokehblur")
funcs[2] = function()
	render.UpdateScreenEffectTexture()
	render.UpdateFullScreenDepthTexture()

	blur_mat:SetTexture("$BASETEXTURE", render.GetScreenEffectTexture())
	blur_mat:SetTexture("$DEPTHTEXTURE", render.GetResolvedFullFrameDepth())

	blur_mat:SetFloat("$size", tfablurintensity * cv_blur_intensity:GetFloat() * 1.5 )
	blur_mat:SetFloat("$focus", 0)
	blur_mat:SetFloat("$focusradius", 0.25)

	render.SetMaterial(blur_mat)
	render.DrawScreenQuad()
end

hook.Add("PostDrawTranslucentRenderables", "tfa_draw_rt_blur", function()
	if TFA_RENDERTARGET then return end

	local mode = cv_mode:GetInt()
	if not isfunction(funcs[mode]) then return end

	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) or not wep.IsTFAWeapon or (not wep:GetStat("RTMaterialOverride") or not wep.RTCode) then return end

	if wep.GLDeployed and wep:GLDeployed() then
		tfablurintensity = Lerp(FT() * 12.5, tfablurintensity, 0)
	else
		local progress = math.Clamp(wep.CLIronSightsProgress or 0, 0, 1)
		tfablurintensity = Lerp(FT() * 25, tfablurintensity, progress)
	end

	if tfablurintensity > 0.05 then
		funcs[mode]()
	end
end)

hook.Add("NeedsDepthPass", "aaaaaaaaaaaaaaaaaaNeedsDepthPass_TJA_IronSight", function()
	if tfablurintensity > 0.05 and cv_mode:GetInt() == 2 then
		DOFModeHack(true)

		return true
	end
end)