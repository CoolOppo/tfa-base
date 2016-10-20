if SERVER then AddCSLuaFile() end

local do_load = true
local version = 3.011
local version_string = "3.01.1.0"
local changelog = [[
	* Added new cvars of mp_tfa_precach.  Enable these to increase loading times but reduce lag and weapon spawn time.
	* Use console autocomplete instead of bothering me for the exact names!
	* Bugfix in setupmove fixed
	* Conflict message improved, displaying exact filepath for a conflicting tfa_loader
	* Lua particle handling fixed on invalid viewmodels
	* Other misc. bugfixes
]]

local function testFunc()
end

local my_path = debug.getinfo(testFunc)
if my_path and type(my_path) == "table" and my_path.short_src then
	my_path = my_path["short_src"]
else
	my_path = "legacy"
end

if TFA_BASE_VERSION then

	if TFA_BASE_VERSION > version then
		print("You have a newer, conflicting version of TFA Base.")
		print("It's located at: " .. ( TFA_FILE_PATH or "" ) )
		do_load = false
	elseif TFA_BASE_VERSION < version then
		print("You have an older, conflicting version of TFA Base.")
		print("It's located at: " .. ( TFA_FILE_PATH or "" ) )
	elseif TFA_BASE_VERSION == version then
		print("You have an equal, conflicting version of TFA Base.")
		print("It's located at: " .. ( TFA_FILE_PATH or "" ) )
	end

end

if do_load then

	TFA_BASE_VERSION = version
	TFA_BASE_VERSION_STRING = version_string
	TFA_BASE_VERSION_CHANGES = changelog
	TFA_ATTACHMENTS_ENABLED = false
	TFA_FILE_PATH = my_path

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
