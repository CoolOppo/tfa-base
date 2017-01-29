if SERVER then
	AddCSLuaFile()
end

WEAPON_NONE = WEAPON_NONE or 0
WEAPON_MELEE = WEAPON_MELEE or 1
WEAPON_PISTOL = WEAPON_PISTOL or 2
WEAPON_HEAVY = WEAPON_HEAVY or 3
WEAPON_NADE = WEAPON_NADE or 4
WEAPON_CARRY = WEAPON_CARRY or 5
WEAPON_EQUIP1 = WEAPON_EQUIP1 or 6
WEAPON_EQUIP2 = WEAPON_EQUIP2 or 7
WEAPON_ROLE = WEAPON_ROLE or 8
WEAPON_EQUIP = WEAPON_EQUIP or WEAPON_EQUIP1
WEAPON_UNARMED = WEAPON_UNARMED or -1
ROLE_INNOCENT = ROLE_INNOCENT or 0
ROLE_TRAITOR = ROLE_TRAITOR or 1
ROLE_DETECTIVE = ROLE_DETECTIVE or 2
ROLE_NONE = ROLE_NONE or ROLE_INNOCENT

local KindTable = {
	[0] = WEAPON_MELEE,
	[1] = WEAPON_PISTOL,
	[2] = WEAPON_HEAVY,
	[3] = WEAPON_HEAVY,
	[4] = WEAPON_HEAVY,
	[5] = WEAPON_EQUIP1,
	[6] = WEAPON_EQUIP2
}

local TypeStrings = {
	[WEAPON_NONE] = "Invalid",
	[WEAPON_MELEE] = "Melee",
	[WEAPON_PISTOL] = "Pistol",
	[WEAPON_HEAVY] = "Heavy",
	[WEAPON_NADE] = "Grenade",
	[WEAPON_CARRY] = "Carry",
	[WEAPON_CARRY] = "Equipment",
	[WEAPON_EQUIP2] = "Equipment",
	[WEAPON_ROLE] = "Role"
}

local function PatchWep(wep)
	local tbl = weapons.GetStored(wep)
	if not tbl then return end
	if not tbl.Base then return end
	if (not tbl.ISTFAWeapon) and (not string.find(tbl.Base, "tfa")) and (not string.find(tbl.Category or "", "TFA")) then return end

	if (not tbl.Kind) or (not isnumber(tbl.Kind)) then
		tbl.Kind = KindTable[tbl.Slot or 2] or WEAPON_HEAVY

		if (tbl.ProjectileVelocity and tbl.ProjectileVelocity < 1000 and tbl.ProjectileVelocity > 0) or string.find(tbl.Base or "", "nade") then
			tbl.Kind = WEAPON_NADE
		end

		if not tbl.Spawnable then
			tbl.Kind = WEAPON_NONE
		end
	end

	--if not tbl.Icon then
	--	tbl.Icon = nil--"vgui/entities/" .. wep
	--end
	tbl.model = tbl.model or tbl.WorldModel

	if not tbl.CanBuy then
		--if tbl.Spawnable then
		--	tbl.CanBuy = { ROLE_TRAITOR, ROLE_DETECTIVE }
		--else
		tbl.CanBuy = {}
		--end
	end

	for k, v in pairs(tbl.CanBuy) do
		if v ~= ROLE_TRAITOR and v ~= ROLE_DETECTIVE then
			table.RemoveByValue(tbl.CanBuy, v)
		end
	end

	if (not tbl.Icon) or (string.len(tbl.Icon) <= 0) then
		tbl.Icon = nil
		if file.Exists("materials/entities/" .. wep .. ".png", "GAME") then
			tbl.Icon = "entities/" .. wep .. ".png"
		elseif file.Exists("materials/vgui/entities/" .. wep .. ".vmt", "GAME") then
			tbl.Icon = "vgui/entities/" .. wep
		end
	end

	if tbl.LimitedStock == nil then
		tbl.LimitedStock = false
	end

	if not tbl.EquipMenuData then
		tbl.EquipMenuData = {
			["type"] = TypeStrings[tbl.Kind],
			["desc"] = tbl.PrintName or wep
		}
	end

	if tbl.IsSilent == nil then
		tbl.IsSilent = false
	end

	if tbl.NoSights == nil then
		if tbl.data then
			tbl.NoSights = tbl.data.ironsights ~= 0
		end

		if tbl.NoSights == nil then
			tbl.NoSights = false
		end
	end

	if tbl.AutoSpawnable == nil then
		tbl.AutoSpawnable = tbl.Spawnable
	end
end

local function Patch()
	if engine.ActiveGamemode() == "terrortown" then
		for k, v in pairs(weapons.GetList()) do
			wep = v.ClassName

			if wep then
				PatchWep(wep)
			end
		end

		if SERVER then
			RunConsoleCommand("sv_tfa_sprint_enabled", "0")
		end
	end
end

if SERVER then
	hook.Add("InitPostEntity", "TFAPatchTTT", Patch)
end
if CLIENT then
	hook.Add("HUDPaint", "TFAPatchTTT", function()
		if IsValid(LocalPlayer()) then
			Patch()
			hook.Remove("HUDPaint","TFAPatchTTT")
		end
	end)
end