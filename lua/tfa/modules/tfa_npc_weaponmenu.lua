AddCSLuaFile()

-- AI Options
hook.Add("PopulateMenuBar", "NPCOptions_MenuBar_TFA", function(menubarV)
	local m = menubarV:AddOrGetMenu("NPCs")
	local wpns = m:AddSubMenu("TFA Weapon Override")
	wpns:SetDeleteSelf(false)
	local weaponCats = {}

	for k, wep in pairs(weapons.GetList()) do
		if wep and wep.Spawnable and weapons.IsBasedOn(wep.ClassName, "tfa_gun_base") then
			local cat = wep.Category or "Other"
			weaponCats[cat] = weaponCats[cat] or {}

			table.insert(weaponCats[cat], {
				["class"] = wep.ClassName,
				["title"] = wep.PrintName or wep.ClassName
			})
		end
	end

	local catKeys = table.GetKeys(weaponCats)
	table.sort(catKeys, function(a, b) return a < b end)

	for _, k in ipairs(catKeys) do
		local v = weaponCats[k]
		local wpnSub = wpns:AddSubMenu(k)
		wpnSub:SetDeleteSelf(false)
		table.SortByMember(v, "title", true)

		for l, b in ipairs(v) do
			wpnSub:AddCVar(b.title, "gmod_npcweapon", b.class)
		end
	end
end)

--I'm not trying to "Trick you" garry see: -- Check if this is a valid entity from the list, or the user is trying to fool us.
hook.Add("PlayerSpawnedNPC", "TFAForceWeaponNPC", function(ply, ent)
	local cv = GetConVar("gmod_npcweapon")

	if ent.Give and cv and cv:GetString():sub(1, 3) == "tfa" then
		ent:Give(cv:GetString())
	end
end)