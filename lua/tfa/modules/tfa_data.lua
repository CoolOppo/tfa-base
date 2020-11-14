
-- Copyright (c) 2018-2020 TFA Base Devs

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

-- This file is holding seamless translation of older versions of data to newer
-- versions of data

TFA.LatestDataVersion = 1

TFA.DataVersionMapping = {
	[0] = {
		{
			old_path = "DrawCrosshairIS",
			new_path = "DrawCrosshairIronSights",
			force = true,
		},

		{
			old_path = "FiresUnderwater",
			new_path = "Primary.FiresUnderwater",
			force = true,
		},

		{
			old_path = "PenetrationMaterials",
			new_path = "Primary.PenetrationMaterials",
			force = true,
		},

		{
			old_path = "MaxPenetrationCounter",
			new_path = "Primary.MaxSurfacePenetrationCount",
			force = true,
		},

		{
			old_path = "MaxPenetration",
			new_path = "Primary.MaxSurfacePenetrationCount",
			force = true,
		},

		{
			old_path = "IronRecoilMultiplier",
			new_path = "Primary.IronRecoilMultiplier",
			force = true,
		},

		{
			old_path = "MoveSpeed",
			new_path = "RegularMoveSpeedMultiplier",
			force = true,
		},

		{
			old_path = "IronSightsMoveSpeed",
			new_path = "AimingDownSightsSpeedMultiplier",
			force = true,
		},

		{
			old_path = "Shotgun",
			new_path = "LoopedReload",
			force = true,
		},

		{
			old_path = "ShellTime",
			new_path = "LoopedReloadInsertTime",
			force = true,
		},

		{
			old_path = "CrouchPos",
			new_path = "CrouchViewModelPosition",
			force = true,
		},

		{
			old_path = "CrouchAng",
			new_path = "CrouchViewModelAngle",
			force = true,
		},

		{
			old_path = "data.ironsights",
			new_path = "Secondary.IronSightsEnabled",
			translate = function(self, value) return tobool(value) end,
			force = true,
		},

		{
			old_path = "Secondary.IronFOV",
			new_path = "Secondary.OwnerFOV",
			force = true,
		},

		{
			old_path = "IronViewModelFOV",
			new_path = "Secondary.ViewModelFOV",
			force = true,
		},

		{
			old_path = "DoProceduralReload",
			new_path = "IsProceduralReloadBased",
			force = true,
		},

		{
			old_path = "ProceduralReloadEnabled",
			new_path = "IsProceduralReloadBased",
			force = true,
		},

		{
			old_path = "Akimbo",
			new_path = "IsAkimbo",
			force = true,
		},

		{
			old_path = "AkimboHUD",
			new_path = "EnableAkimboHUD",
			force = true,
		},

		{
			old_path = "IronInSound",
			new_path = "Secondary.IronSightsInSound",
			force = true,
		},

		{
			old_path = "IronOutSound",
			new_path = "Secondary.IronSightsOutSound",
			force = true,
		},

		{
			old_path = "DisableChambering",
			new_path = "Primary.DisableChambering",
			force = true,
		},

		{
			old_path = "DisplayFalloff",
			new_path = "Primary.DisplayFalloff",
			force = true,
		},

		{
			old_path = "SpreadPattern",
			new_path = "Primary.SpreadPattern",
			force = true,
		},

		{
			old_path = "SpreadBiasYaw",
			new_path = "Primary.SpreadBiasYaw",
			force = true,
		},

		{
			old_path = "SpreadBiasPitch",
			new_path = "Primary.SpreadBiasPitch",
			force = true,
		},
	}
}

TFA.HardDataMapping = {
	{
		old_path = "VMPos",
		new_path = "ViewModelPosition",
		force = true,
	},

	{
		old_path = "VMAng",
		new_path = "ViewModelAngle",
		force = true,
	},

	{
		old_path = "VMPos_Additive",
		new_path = "AdditiveViewModelPosition",
		force = true,
	},

	{
		old_path = "RunSightsPos",
		new_path = "SprintViewModelPosition",
		force = true,
	},

	{
		old_path = "RunSightsAng",
		new_path = "SprintViewModelAngle",
		force = true,
	},

	{
		old_path = "IronSightsPos",
		new_path = "IronSightsPosition",
		force = true,
	},

	{
		old_path = "IronSightsAng",
		new_path = "IronSightsAngle",
		force = true,
	},

	{
		old_path = "Bodygroups_V",
		new_path = "ViewModelBodygroups",
		backtrack = true,
		force_table = true,
		force = true,
	},

	{
		old_path = "Bodygroups_W",
		new_path = "WorldModelBodygroups",
		backtrack = true,
		force_table = true,
		force = true,
	},

	{
		old_path = "CenteredPos",
		new_path = "CenteredViewModelPosition",
		force = true,
	},

	{
		old_path = "CenteredAng",
		new_path = "CenteredViewModelAngle",
		force = true,
	},

	{
		old_path = "Offset",
		new_path = "WorldModelOffset",
		backtrack = true,
		force_table = true,
		force = true,
	},

	{
		old_path = "ProceduralHolsterPos",
		new_path = "ProceduralHolsterPosition",
		force = true,
	},

	{
		old_path = "ProceduralHolsterAng",
		new_path = "ProceduralHolsterAngle",
		force = true,
	},

	{
		old_path = "VElements",
		new_path = "ViewModelElements",
		backtrack = true,
		force_table = true,
		force = true,
	},

	{
		old_path = "WElements",
		new_path = "WorldModelElements",
		backtrack = true,
		force_table = true,
		force = true,
	},
}

TFA.PathParseCache = {}
TFA.StatPathRemap = {}
TFA.PathParseCacheDirect = {}

local PathParseCache = TFA.PathParseCache
local PathParseCacheDirect = TFA.PathParseCacheDirect
local string_Explode = string.Explode
local ipairs = ipairs
local tonumber = tonumber

function TFA.GetStatPath(path)
	local get_cache = PathParseCache[path]
	if get_cache ~= nil then return get_cache end

	get_cache = string_Explode(".", path, false)

	if get_cache[1] == "Primary" then
		get_cache[1] = "Primary_TFA"
	elseif get_cache[1] == "Secondary" then
		get_cache[1] = "Secondary_TFA"
	end

	for k, v in ipairs(get_cache) do
		get_cache[k] = tonumber(v) or v
	end

	PathParseCache[path] = get_cache
	return get_cache
end

function TFA.GetStatPathDirect(path)
	local get_cache = PathParseCacheDirect[path]
	if get_cache ~= nil then return get_cache end

	local t_stbl = string_Explode(".", path, false)

	for k, v in ipairs(t_stbl) do
		t_stbl[k] = tonumber(v) or v
	end

	PathParseCacheDirect[path] = t_stbl
	return t_stbl
end

local GetStatPathDirect = TFA.GetStatPathDirect
local istable = istable
local table_Copy = table.Copy

for _, info in ipairs(TFA.HardDataMapping) do
	if info.force then
		local new_path = table_Copy(GetStatPathDirect(info.new_path))

		if new_path[1] == "Primary" then
			new_path[1] = "Primary_TFA"
		elseif new_path[1] == "Secondary" then
			new_path[1] = "Secondary_TFA"
		end

		PathParseCache[info.old_path] = new_path
	end

	TFA.StatPathRemap[info.old_path] = info.new_path
end

for version, data in SortedPairs(TFA.DataVersionMapping) do
	for _, info in ipairs(data) do
		if info.force then
			local new_path = table_Copy(GetStatPathDirect(info.new_path))

			if new_path[1] == "Primary" then
				new_path[1] = "Primary_TFA"
			elseif new_path[1] == "Secondary" then
				new_path[1] = "Secondary_TFA"
			end

			PathParseCache[info.old_path] = new_path
		end

		TFA.StatPathRemap[info.old_path] = info.new_path
	end
end

--PrintTable(PathParseCache)

local retrieve, push
function retrieve(struct, path, depth, limit)
	if depth > limit then return end

	local load = struct[path[depth]]

	if load == nil then return end
	if depth == limit then return load end
	if istable(load) then return retrieve(load, path, depth + 1, limit) end
	-- not found
end

function push(struct, path, value, depth, limit, force)
	if depth > limit then return false end

	local load = struct[path[depth]]

	if depth == limit then
		if force or load == nil then
			struct[path[depth]] = value
			--print("pushed", value, " to ", path[depth])
		end

		--print("depth == limit", path[depth], value)

		return true
	end

	if load == nil and limit < depth then
		load = {}
		struct[path[depth]] = load
	end

	if istable(load) then
		return push(load, path, value, depth + 1, limit, force)
	end

	--print("failed to push", value, "to", path[depth])
	return false
end

local function apply(struct, info, self, backtrack, ...)
	local old_path = GetStatPathDirect(info.old_path)
	local new_path = GetStatPathDirect(info.new_path)

	local load = retrieve(struct, old_path, 1, #old_path)

	if load == nil then
		if info.force_table then
			load = {}
		else
			return false
		end
	end

	if isfunction(info.translate) then
		load = info.translate(self, load, struct, ...)
	end

	--print("pushing", load, "to", info.new_path, "from", info.old_path)

	if info.backtrack and backtrack then
		push(struct, old_path, load, 1, #old_path, false)
	end

	return push(struct, new_path, load, 1, #new_path, info.force)
end

function TFA.MigrateStructure(self, struct, classname, backtrack, ...)
	local migrations = #TFA.HardDataMapping

	local currentVersion = struct.TFADataVersion or 0

	for _, info in ipairs(TFA.HardDataMapping) do
		if apply(struct, info, self, backtrack and currentVersion == 0, ...) then
			migrations = migrations + 1
		end
	end

	if currentVersion == 0 then
		-- remove old default value since we were ignoring it already
		if struct.MaxPenetrationCounter == 4 then
			struct.MaxPenetrationCounter = nil
		end

		if struct.MaxPenetration == 4 then
			struct.MaxPenetration = nil
		end
	end

	for version, data in SortedPairs(TFA.DataVersionMapping) do
		if currentVersion <= version then
			for _, info in ipairs(data) do
				if apply(struct, info, self, backtrack and currentVersion == 0, ...) then
					migrations = migrations + 1
				end
			end
		end
	end

	-- print("[TFA Base] Migrated " .. classname .. " (applied " .. migrations .. " migrations)")

	return migrations
end
