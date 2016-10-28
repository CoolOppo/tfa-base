if SERVER then
	util.AddNetworkString("TFAJoinGroupPopup")

	hook.Add("PlayerSay", "TFAJoinGroupChat", function(ply, text, tc)
		if string.Trim(text) == "!jointfa" then
			net.Start("TFAJoinGroupPopup")
			net.Send(ply)
		end
	end)
end

local function comma_value(amount) --Credit to the lua-user.org wiki
	local formatted = amount

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if (k == 0) then break end
	end

	return formatted
end

if CLIENT then

	local TFA_NAGCOUNT = 0

	hook.Add("TFA_ClientLoad", "TFA_NAG", function()
		TFA.GetGroupMembers("tfa-mods", function(members)
			if not table.HasValue(members,LocalPlayer():SteamID64()) then --They're not a member

				if file.Exists("tfa_nag_v3.txt", "DATA") then
					TFA_NAGCOUNT = tonumber( file.Read("tfa_nag_v3.txt","DATA") )
				end

				local f = file.Open("tfa_nag_v3.txt", "w", "DATA")
				f:Write( tostring( TFA_NAGCOUNT + 1 ) )
				f:Flush()
				f:Close()

				if TFA_NAGCOUNT < 5 then
					chat.AddText(TFA.GetLangString("nag_1"), LocalPlayer():Nick(), TFA.GetLangString("nag_2") .. comma_value( #members + 1 ) .. TFA.GetLangString("nag_3") .. tostring( TFA_NAGCOUNT + 1 ) .. ".")
				end
			else
				if file.Exists("tfa_nag_v3.txt","DATA") then
					file.Delete("tfa_nag_v3.txt")
					chat.AddText(TFA.GetLangString("thank_1"), LocalPlayer():Nick(), TFA.GetLangString("thank_2") .. comma_value( #members ) .. "." )
				end
			end
		end)
	end)

	net.Receive("TFAJoinGroupPopup", function()
		gui.OpenURL("http://steamcommunity.com/groups/tfa-mods")
	end)


end
