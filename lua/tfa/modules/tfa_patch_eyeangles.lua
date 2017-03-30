if SERVER then AddCSLuaFile() return end

local SHOULDPATCH = true

if not SHOULDPATCH then return end
local ply

function TFA.PatchEyeAngles()
	TFA.EYEANGLES_HASPATCHED = true
	EyeAngles_TFABase_Old = EyeAngles_TFABase_Old or EyeAngles
	function EyeAngles( ... )
		if TFA.RT_DRAWING then
			if not IsValid(ply) then
				ply = LocalPlayer()
				if not IsValid(ply) then return angle_zero end
			end
			return ply:EyeAngles()
		else
			return EyeAngles_TFABase_Old( ... )
		end
	end
end

hook.Add("InitPostEntity","TFA_Patch_EyeAngles",function()
	TFA.PatchEyeAngles()
end)

TFA.EYEANGLES_HASPATCHED = true

if TFA.EYEANGLES_HASPATCHED then
	TFA.PatchEyeAngles()
end
