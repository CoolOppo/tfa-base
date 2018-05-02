if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "ACOG"
--ATTACHMENT.ID = "base" -- normally this is just your filename
ATTACHMENT.Description = { TFA.AttachmentColors["="], "4x zoom", TFA.AttachmentColors["-"], "20% higher zoom time",  TFA.AttachmentColors["-"], "10% slower aimed walking" }
ATTACHMENT.Icon = "entities/tfa_si_acog.png" --Revers to label, please give it an icon though!  This should be the path to a png, like "entities/tfa_ammo_match.png"
ATTACHMENT.ShortName = "ACOG"

local fov = 90 / 4 / 2 -- Default FOV / Scope Zoom / screenscale

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["acog"] = {
			["active"] = true
		},
		["rtcircle_acog"] = {
			["active"] = true
		}
	},
	["WElements"] = {
		["acog"] = {
			["active"] = true
		}
	},
	["IronSightsPos"] = function( wep, val ) return wep.IronSightsPos_ACOG or val, true end,
	["IronSightsAng"] = function( wep, val ) return wep.IronSightsAng_ACOG or val, true end,
	["IronSightsSensitivity"] = function(wep,val) return TFA.CalculateSensitivtyScale( fov, wep:GetStat("Secondary.IronFOV"), wep.ACOGScreenScale ) end ,
	["Secondary"] = {
		["IronFOV"] = function( wep, val ) return val * 0.7 end
	},
	["IronSightTime"] = function( wep, val ) return val * 1.20 end,
	["IronSightMoveSpeed"] = function(stat) return stat * 0.9 end,
	["RTOpaque"] = true,
	["RTMaterialOverride"] = -1
}

local shadowborder = 256

local cd = {}

local myret
local myshad

function ATTACHMENT:Attach(wep)
	if not IsValid(wep) then return end
	wep.RTCodeOld = wep.RTCodeOld or wep.RTCode
	wep.RTCode = function( myself , rt, scrw, scrh)
		if not IsValid(myself:GetOwner()) then return end
		if not myret then
			myret = Material("scope/gdcw_scopesightonly")
		end
		if not myshad then
			myshad = Material( "vgui/scope_shadowmask_test")
		end

		render.OverrideAlphaWriteEnable(true, true)
		surface.SetDrawColor(color_white)
		surface.DrawRect(-512, -512, 1024, 1024)
		render.OverrideAlphaWriteEnable(true, true)
		local ang = myself:GetOwner():EyeAngles()
		cd.angles = ang
		cd.origin = myself:GetOwner():GetShootPos()
		local rtw, rth = 512, 512
		cd.x = 0
		cd.y = 0
		cd.w = rtw
		cd.h = rth
		cd.fov = fov
		cd.drawviewmodel = false
		cd.drawhud = false
		render.Clear(0, 0, 0, 255, true, true)
		render.SetScissorRect(0, 0, rtw, rth, true)

		if myself.CLIronSightsProgress > 0.005 then
			render.RenderView(cd)
		end

		render.SetScissorRect(0, 0, rtw, rth, false)
		render.OverrideAlphaWriteEnable(false, true)
		cam.Start2D()
		draw.NoTexture()
		surface.SetDrawColor(ColorAlpha(color_black, 255 * (1 - myself.CLIronSightsProgress)))
		surface.DrawRect(0, 0, rtw, rth)
		surface.SetMaterial(myret)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(128, 128, 256, 256)
		surface.SetMaterial(myshad)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(-shadowborder, -shadowborder, shadowborder * 2 + 512 , shadowborder * 2 + 512 )
		cam.End2D()
	end
end

function ATTACHMENT:Detach(wep)
	if not IsValid(wep) then return end
	wep.RTCode = wep.RTCodeOld
	wep.RTCodeOld = nil
end

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end
