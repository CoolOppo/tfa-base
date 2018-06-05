if SERVER then AddCSLuaFile() end 

TFA = TFA or {}

local do_load = true
local version = 4.381
local version_string = "4.3.8.1"
local changelog = [[
	* Attachment UI now allows rows to affect the same category, and will break apart exceedingly large rows
	* Legacy attachment UI removed
	* Reticules/lasers now colorable in context menu
	* Hold E as you hit your inspection key to access the context menu as normal
	* PATCH - Exploit regarding new C-Menu fix, viewmodel viewpunch made into a cvar ( it'll go down with recoil if disabled )
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
		print("Contact the author of that pack, not TFA.")
		do_load = false
	elseif TFA_BASE_VERSION < version then
		print("You have an older, conflicting version of TFA Base.")
		print("It's located at: " .. ( TFA_FILE_PATH or "" ) )
		print("Contact the author of that pack, not TFA.")
	elseif TFA_BASE_VERSION == version then
		print("You have an equal, conflicting version of TFA Base.")
		print("It's located at: " .. ( TFA_FILE_PATH or "" ) )
		print("Contact the author of that pack, not TFA.")
	end

end

if do_load then

	TFA_BASE_VERSION = version
	TFA_BASE_VERSION_STRING = version_string
	TFA_BASE_VERSION_CHANGES = changelog
	TFA_ATTACHMENTS_ENABLED = true
	TFA_FILE_PATH = my_path

	TFA.Enum = TFA.Enum or {}

	local flist = file.Find("tfa/enums/*.lua","LUA")

	for fileid, filename in pairs(flist) do

		local typev = "SHARED"
		if filename:StartWith("cl_") then
			typev = "CLIENT"
		elseif filename:StartWith("sv_") then
			typev = "SERVER"
		end

		if SERVER and typev ~= "SERVER" then
			AddCSLuaFile( "tfa/enums/" .. filename )
		end

		if ( SERVER and typev ~= "CLIENT" ) or ( CLIENT and typev ~= "SERVER" ) then
			include( "tfa/enums/" .. filename )
			--print("Initialized " .. filename .. " || " .. fileid .. "/" .. #flist )
		end

	end

	flist = file.Find("tfa/modules/*.lua","LUA")

	for fileid, filename in pairs(flist) do

		local typev = "SHARED"
		if filename:StartWith("cl_") then
			typev = "CLIENT"
		elseif filename:StartWith("sv_") then
			typev = "SERVER"
		end

		if SERVER and typev ~= "SERVER" then
			AddCSLuaFile( "tfa/modules/" .. filename )
		end

		if ( SERVER and typev ~= "CLIENT" ) or ( CLIENT and typev ~= "SERVER" ) then
			include( "tfa/modules/" .. filename )
			--print("Initialized " .. filename .. " || " .. fileid .. "/" .. #flist )
		end

	end

	flist = file.Find("tfa/external/*.lua","LUA")

	for fileid, filename in pairs(flist) do

		local typev = "SHARED"
		if filename:StartWith("cl_") then
			typev = "CLIENT"
		elseif filename:StartWith("sv_") then
			typev = "SERVER"
		end

		if SERVER and typev ~= "SERVER" then
			AddCSLuaFile( "tfa/external/" .. filename )
		end

		if ( SERVER and typev ~= "CLIENT" ) or ( CLIENT and typev ~= "SERVER" ) then
			include( "tfa/external/" .. filename )
			--print("Initialized " .. filename .. " || " .. fileid .. "/" .. #flist )
		end

	end

end
