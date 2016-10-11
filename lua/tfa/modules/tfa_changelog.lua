if CLIENT then
	local TFA_DISPLAY_CHANGELOG = false
	local changes = TFA_BASE_VERSION_CHANGES or ""

	if not file.Exists("tfa_base_version.txt", "DATA") then
		local f = file.Open("tfa_base_version.txt", "w", "DATA")
		f:Write(TFA_BASE_VERSION)
		f:Flush()
		f:Close()
		TFA_DISPLAY_CHANGELOG = true
	end

	local f = file.Open("tfa_base_version.txt", "r", "DATA")

	if f then
		local fileversion = f:ReadLine()
		local fileversionnumber = tonumber(fileversion or "")

		if fileversionnumber and fileversionnumber < TFA_BASE_VERSION then
			TFA_DISPLAY_CHANGELOG = true
			local f2 = file.Open("tfa_base_version.txt", "w", "DATA")
			f2:Write(TFA_BASE_VERSION)
			f2:Flush()
			f2:Close()
		end
	end

	hook.Add("HUDPaint", "TFA_DISPLAY_CHANGELOG", function()
		if IsValid(LocalPlayer()) then
			if TFA_DISPLAY_CHANGELOG then
				chat.AddText("Updated to TFA Base Version: ")
				chat.AddText(TFA_BASE_VERSION_STRING)
				chat.AddText(changes)
			end

			hook.Remove("HUDPaint", "TFA_DISPLAY_CHANGELOG")
		end
	end)
end
