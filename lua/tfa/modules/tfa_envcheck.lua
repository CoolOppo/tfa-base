local EmptyFunc = function() end

local debugInfoTbl = debug.getinfo(EmptyFunc)

local function checkEnv(plyIn)
	if game.SinglePlayer() then
		if chat and chat.AddText
				and debugInfoTbl.short_src:StartWith("addons") -- unpacked version
				and not file.Exists(debugInfoTbl.short_src:GetPathFromFilename():Replace("lua/tfa/modules/", "") .. ".git", "GAME") then -- non-git
			chat.AddText("[TFA Base] You are using unpacked version of TFA Base.\nWe only provide support for Workshop and Git versions.")
		end
	else
		local activeGamemode = engine.ActiveGamemode()
		local isRP = activeGamemode:find("rp")
				or activeGamemode:find("roleplay")
				or activeGamemode:find("serious")

		if isRP and (SERVER or (IsValid(plyIn) and (plyIn:IsAdmin() or plyIn:IsSuperAdmin()))) then
			print("[TFA Base] You are running the base on DarkRP or DarkRP-derived gamemode. We can't guarantee that it will work correctly with any possible addons the server might have installed (especially the paid ones), so we don't provide support for RP gamemodes/servers. If you've encountered a conflict error with another addon, it's most likely that addon's fault. DO NOT CONTACT US ABOUT THAT!")

			if TFA_BASE_VERSION <= 4.034 then -- seems to be common problem with SWRP servers
				local printFunc = chat and chat.AddText or print

				printFunc("[TFA Base] You have installed both SV/SV2 and Reduxed versions of the base. Make sure you are using only one version at the same time.")
			end
		end
	end
end

if CLIENT then
	hook.Add("HUDPaint", "TFA_CheckEnv", function()
		local ply = LocalPlayer()

		if not IsValid(ply) then return end

		hook.Remove("HUDPaint", "TFA_CheckEnv")

		checkEnv(ply)
	end)
else
	hook.Add("InitPostEntity", "TFA_CheckEnv", checkEnv)
end