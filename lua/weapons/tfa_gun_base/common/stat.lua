
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

local tableCopy = table.Copy

function SWEP:GetStatRecursive(srctbl, stbl, ...)
	stbl = tableCopy(stbl)

	for _ = 1, #stbl do
		if #stbl > 1 then
			if srctbl[stbl[1]] then
				srctbl = srctbl[stbl[1]]
				table.remove(stbl, 1)
			else
				return true, ...
			end
		end
	end

	local val = srctbl[stbl[1]]

	if val == nil then
		return true, ...
	end

	if istable(val) and val.functionTable then
		local currentStat, isFinal, nocache, nct
		nocache = false

		for i = 1, #val do
			local v = val[i]

			if isfunction(v) then
				if currentStat == nil then
					currentStat, isFinal, nct = v(self, ...)
				else
					currentStat, isFinal, nct = v(self, currentStat)
				end

				nocache = nocache or nct

				if isFinal then break end
			elseif v then
				currentStat = v
			end
		end

		if currentStat ~= nil then
			return false, currentStat, nocache
		end

		return true, ...
	end

	return false, val
end

SWEP.StatCache_Blacklist = {
	["ViewModelBoneMods"] = true,
	["WorldModelBoneMods"] = true,
	["MaterialTable"] = true,
	["MaterialTable_V"] = true,
	["MaterialTable_W"] = true,
	["Bodygroups_V"] = true,
	["Bodygroups_W"] = true,
	["Skin"] = true
}

SWEP.StatCache = {}
SWEP.StatCache2 = {}
SWEP.StatStringCache = {}

SWEP.LastClearStatCache = 0
SWEP.ClearStatCacheWarnCount = 0
SWEP.ClearStatCacheWarned = false

local IdealCSCDeltaTime = engine.TickInterval() * 2

function SWEP:ClearStatCache(vn)
	local self2 = self:GetTable()
	local getpath, getpath2

	if not vn and not self2.ClearStatCacheWarned then
		local ct = CurTime()
		local delta = ct - self2.LastClearStatCache

		if delta < IdealCSCDeltaTime and debug.traceback():find("Think2") then
			self2.ClearStatCacheWarnCount = self2.ClearStatCacheWarnCount + 1

			if self2.ClearStatCacheWarnCount >= 5 then
				self2.ClearStatCacheWarned = true

				print(("[TFA Base] Weapon %s (%s) is abusing ClearStatCache function from Think2! This will lead to really bad performance issues, tell weapon's author to fix it ASAP!"):format(self2.PrintName, self:GetClass()))
			end
		elseif self2.ClearStatCacheWarnCount > 0 then
			self2.ClearStatCacheWarnCount = 0
		end

		self2.LastClearStatCache = ct
	end

	if vn then
		self2.StatCache[vn] = nil
		self2.StatCache2[vn] = nil
		getpath2 = self2.GetStatPath(self, vn)
		getpath = getpath2[1]
	else
		table.Empty(self2.StatCache)
		table.Empty(self2.StatCache2)
	end

	if vn == "Primary" or not vn then
		table.Empty(self2.Primary)

		local temp = {}

		setmetatable(self2.Primary, {
			__index = function(self3, key)
				return self2.GetStat(self, "Primary." .. key)
			end,

			__newindex = function() end
		})

		for k in pairs(self2.Primary_TFA) do
			if isstring(k) then
				temp[k] = self2.GetStat(self, "Primary." .. k)
			end
		end

		setmetatable(self2.Primary, nil)

		for k, v in pairs(temp) do
			self2.Primary[k] = v
		end

		if self2.Primary_TFA.RangeFalloffLUT_IsConverted then
			self2.Primary_TFA.RangeFalloffLUT = nil
			self2.AutoDetectRange(self)
		end

		local getLUT = self2.GetStat(self, "Primary.RangeFalloffLUT", nil, true)

		if getLUT then
			self2.Primary.RangeFalloffLUTBuilt = self:BuildFalloffTable(getLUT)
		end

		if self2.Primary_TFA.RecoilLUT then
			if self2.Primary_TFA.RecoilLUT["in"] then
				self2.Primary_TFA.RecoilLUT["in"].points_p = {0}
				self2.Primary_TFA.RecoilLUT["in"].points_y = {0}

				for i, point in ipairs(self2.Primary_TFA.RecoilLUT["in"].points) do
					table.insert(self2.Primary_TFA.RecoilLUT["in"].points_p, point.p)
					table.insert(self2.Primary_TFA.RecoilLUT["in"].points_y, point.y)
				end
			end

			if self2.Primary_TFA.RecoilLUT["loop"] then
				self2.Primary_TFA.RecoilLUT["loop"].points_p = {}
				self2.Primary_TFA.RecoilLUT["loop"].points_y = {}

				for i, point in ipairs(self2.Primary_TFA.RecoilLUT["loop"].points) do
					table.insert(self2.Primary_TFA.RecoilLUT["loop"].points_p, point.p)
					table.insert(self2.Primary_TFA.RecoilLUT["loop"].points_y, point.y)
				end

				table.insert(self2.Primary_TFA.RecoilLUT["loop"].points_p, self2.Primary_TFA.RecoilLUT["loop"].points[1].p)
				table.insert(self2.Primary_TFA.RecoilLUT["loop"].points_y, self2.Primary_TFA.RecoilLUT["loop"].points[1].y)
			end

			if self2.Primary_TFA.RecoilLUT["out"] then
				self2.Primary_TFA.RecoilLUT["out"].points_p = {0}
				self2.Primary_TFA.RecoilLUT["out"].points_y = {0}

				for i, point in ipairs(self2.Primary_TFA.RecoilLUT["out"].points) do
					table.insert(self2.Primary_TFA.RecoilLUT["out"].points_p, point.p)
					table.insert(self2.Primary_TFA.RecoilLUT["out"].points_y, point.y)
				end

				table.insert(self2.Primary_TFA.RecoilLUT["out"].points_p, 0)
				table.insert(self2.Primary_TFA.RecoilLUT["out"].points_y, 0)
			end
		end
	elseif getpath == "Primary_TFA" and isstring(getpath2[2]) then
		self2.Primary[getpath[2]] = self2.GetStat(self, vn)
	end

	if vn == "Secondary" or not vn then
		table.Empty(self2.Secondary)

		local temp = {}

		setmetatable(self2.Secondary, {
			__index = function(self3, key)
				return self2.GetStat(self, "Secondary." .. key)
			end,

			__newindex = function() end
		})

		for k in pairs(self.Secondary_TFA) do
			if isstring(k) then
				temp[k] = self2.GetStat(self, "Secondary." .. k)
			end
		end

		setmetatable(self2.Secondary, nil)

		for k, v in pairs(temp) do
			self2.Secondary[k] = v
		end
	elseif getpath == "Secondary_TFA" and isstring(getpath2[2]) then
		self2.Secondary[getpath[2]] = self2.GetStat(self, vn)
	end

	if CLIENT then
		self:RebuildModsRenderOrder()
	end

	hook.Run("TFA_ClearStatCache", self)
end

local ccv = GetConVar("cl_tfa_debug_cache")

function SWEP:GetStatPath(stat)
	local self2 = self:GetTable()

	if self2.StatStringCache[stat] ~= nil then return self2.StatStringCache[stat] end

	local t_stbl = string.Explode(".", stat, false)

	if t_stbl[1] == "Primary" then
		t_stbl[1] = "Primary_TFA"
	end

	if t_stbl[1] == "Secondary" then
		t_stbl[1] = "Secondary_TFA"
	end

	for k, v in ipairs(t_stbl) do
		t_stbl[k] = tonumber(v) or v
	end

	self2.StatStringCache[stat] = t_stbl

	return self2.StatStringCache[stat]
end

function SWEP:GetStat(stat, default, dontMergeTables)
	local self2 = self:GetTable()
	local statPath = self2.GetStatPath(self, stat)

	if self2.StatCache2[stat] ~= nil then
		local finalReturn

		if self2.StatCache[stat] ~= nil then
			finalReturn = self2.StatCache[stat]
		else
			local isDefault, retval = self2.GetStatRecursive(self, self2, statPath)

			if retval ~= nil then
				if not isDefault then
					self2.StatCache[stat] = retval
				end

				finalReturn = retval
			else
				finalReturn = istable(default) and tableCopy(default) or default
			end
		end

		local getstat = hook.Run("TFA_GetStat", self, stat, finalReturn)
		if getstat ~= nil then return getstat end

		return finalReturn
	end

	if not self2.OwnerIsValid(self) then
		local finalReturn = default

		if IsValid(self) then
			local _
			_, finalReturn = self2.GetStatRecursive(self, self2, statPath, istable(default) and tableCopy(default) or default)
		end

		local getstat = hook.Run("TFA_GetStat", self, stat, finalReturn)
		if getstat ~= nil then return getstat end
		return finalReturn
	end

	local isDefault, statSelf = self2.GetStatRecursive(self, self2, statPath, istable(default) and tableCopy(default) or default)
	local isDefaultAtt, statAttachment, noCache = self2.GetStatRecursive(self, self2.AttachmentTableCache, statPath, istable(statSelf) and tableCopy(statSelf) or statSelf)
	local shouldCache = not noCache and not self2.StatCache_Blacklist[stat] and not self2.StatCache_Blacklist[statPath[1]] and not (ccv and ccv:GetBool())

	if istable(statAttachment) and istable(statSelf) and not dontMergeTables then
		statSelf = table.Merge(tableCopy(statSelf), statAttachment)
	else
		statSelf = statAttachment
	end

	if shouldCache then
		if not isDefault or not isDefaultAtt then
			self2.StatCache[stat] = statSelf
		end

		self2.StatCache2[stat] = true
	end

	local getstat = hook.Run("TFA_GetStat", self, stat, statSelf)
	if getstat ~= nil then return getstat end

	return statSelf
end
