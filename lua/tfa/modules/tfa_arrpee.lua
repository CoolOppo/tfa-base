if SERVER then AddCSLuaFile() end

local cv = CreateConVar("rp_tfa_into_m9k","1",FCVAR_ARCHIVE,"Convert TFA weapons into m9k?")

local BaseReplacements = {
	["tfa_3dscoped_base"] = "bobs_scoped_base",
	["tfa_3dbash_base"] = "bobs_scoped_base",
	["tfa_scoped_base"] = "bobs_scoped_base",
	["tfa_shotty_base"] = "bobs_shotty_base",
	["tfa_bash_base"] = "bobs_gun_base",
	["tfa_gun_base"] = "bobs_gun_base"
}

local function CleanModels( wep )
	if wep.VElements then
		local remCache = {}
		for l,b in pairs( wep.VElements ) do
			if b.active == false then
				table.insert(remCache,l)
			end
		end
		for l,b in pairs(remCache) do
			 wep.VElements[b] = nil
		end
	end
	if wep.WElements then
		local remCache = {}
		for l,b in pairs( wep.WElements ) do
			if b.active == false then
				table.insert(remCache,l)
			end
		end
		for l,b in pairs(remCache) do
			 wep.VElements[b] = nil
		end
	end
end

hook.Add("InitPostEntity","TFA_Into_M9K",function()

	if ( not darkrp ) and ( not DarkRP ) and ( not DARKRP ) then return end

	local M9K = false
	if weapons.GetStored("bobs_gun_base") then
		M9K = true
	end

	if not M9K then return end

	if not cv:GetBool() then return end
	print("Converting TFA into M9K for RP purposes")
	for k,v in pairs( weapons.GetList() ) do
		local cl = v.ClassName
		local wep = weapons.GetStored(cl)
		if wep then
			if string.find(wep.Base,"nmrih") then
				wep.UseHands = true
			end
			wep.Base = BaseReplacements[ wep.Base ] or wep.Base
			if string.find(wep.Base,"tfa_") then
				wep.Base = "bobs_gun_base"
				if ( wep.Scoped or string.find(wep.Base,"scope") or string.find(wep.Base,"3d") ) and wep.Base == "bobs_gun_base" then
					wep.Base = "bobs_scoped_base"
				end
				if ( wep.Shotgun or string.find(wep.Base,"shotgun") or string.find(wep.Base,"shotty") ) and wep.Base == "bobs_gun_base" then
					wep.Base = "bobs_shotty_base"
					wep.ShellTime = 0.4
				end
			end
			wep.SightsPos = wep.IronSightsPos or wep.SightsPos
			wep.SightsAng = wep.IronSightsAng or wep.SightsAng
			wep.Gun = wep.ClassName
			CleanModels(wep)
		end
	end
end)

hook.Add("PlayerSwitchWeapon","M9KForceCSSHands",function(ply,oldWep,newWep)
	if string.find( newWep.Base or "", "bobs_" ) then
		ply:GetHands().OldModel = ply:GetHands().OldModel or ply:GetHands():GetModel()
		ply:GetHands():SetModel("models/weapons/c_arms_cstrike.mdl")
	else
		ply:GetHands():SetModel( ply:GetHands().OldModel or ply:GetHands():GetModel() )
		ply:GetHands().OldModel = nil
	end
end)