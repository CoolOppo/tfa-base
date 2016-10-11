if SERVER then AddCSLuaFile() end

local do_load = true
local version = 3.001
local version_string = "3.0.0.1"
local changelog = [[
	* Shock damage no longer removes props
	* Fixed rendertargets
	* Further improved performance
]]

if TFA_BASE_VERSION then

	if TFA_BASE_VERSION > version then
		print("You have a newer, conflicting version of TFA Base.")
		do_load = false
	end

	if TFA_BASE_VERSION < version then
		print("You have an older, conflicting version of TFA Base.")
	end

end

if do_load then

	TFA_BASE_VERSION = version
	TFA_BASE_VERSION_STRING = version_string
	TFA_BASE_VERSION_CHANGES = changelog
	TFA_ATTACHMENTS_ENABLED = false
	local flist = file.Find("tfa/modules/*.lua","LUA")

	for fileid, filename in pairs(flist) do

		local typev = "SHARED"
		if string.find(filename,"cl_") then
			typev = "CLIENT"
		elseif string.find(filename,"sv_") then
			typev = SERVER
		end

		if SERVER and typev ~= "SERVER" then
			AddCSLuaFile( "tfa/modules/" .. filename )
		end

		if ( SERVER and typev ~= "CLIENT" ) or ( CLIENT and typev ~= "SERVER" ) then
			include( "tfa/modules/" .. filename )
			--print("Initialized " .. filename .. " || " .. fileid .. "/" .. #flist )
		end

	end

end
