local ATT_DIMENSION = 64
local ATT_MAX_SCREEN_RATIO = 1 / 3
SWEP.Attachments = {} --[MDL_ATTACHMENT] = = { offset = { 0, 0 }, atts = { "sample_attachment_1", "sample_attachment_2" }, sel = 1, order = 1 } --offset will move the offset the display from the weapon attachment when using CW2.0 style attachment display --atts is a table containing the visible attachments --sel allows you to have an attachment pre-selected, and is used internally by the base to show which attachment is selected in each category. --order is the order it will appear in the TFA style attachment menu
SWEP.AttachmentCache = {} --["att_name"] = true
SWEP.AttachmentTableCache = {}
SWEP.AttachmentDependencies = {} --{["si_acog"] = {"bg_rail"}}
SWEP.AttachmentExclusions = {} --{ ["si_iron"] = {"bg_heatshield"} }
local att_enabled_cv = GetConVar("sv_tfa_attachments_enabled")

function SWEP:RemoveUnusedAttachments()
	for k, v in pairs(self.Attachments) do
		if v.atts then
			local t = {}
			local i = 1

			for _, b in pairs(v.atts) do
				if TFA.Attachments.Atts[b] then
					t[i] = b
					i = i + 1
				end
			end

			v.atts = table.Copy(t)
		end

		if #v.atts <= 0 then
			self.Attachments[k] = nil
			continue
		end
	end
end

local function CloneTableRecursive(source, target)
	for k, v in pairs(source) do
		if istable(v) then
			if istable(target[k]) and target[k].functionTable then
				local baseTable = target[k]
				local t, index
				for l,b in pairs(baseTable) do
					if istable(b) then
						t = b
						index = l
					end
				end
				if not t then t = {} end
				CloneTableRecursive(v,t)
				if index then
					baseTable[index] = t
				else
					table.insert(baseTable, 1, t)
				end
			else
				target[k] = istable(target[k]) and target[k] or {}
				CloneTableRecursive(v, target[k])
			end
		elseif isfunction(v) then
			local temp
			if target[k] and not istable(target[k]) then
				temp = target[k]
			end
			target[k] = target[k] or {}
			local t = target[k]
			t.functionTable = true
			if temp then
				t[#t + 1] = temp
			end
			t[#t + 1] = v
		else
			if istable(target[k]) and target[k].functionTable then
				table.insert(target[k], 1, v)
			else
				target[k] = v
			end
		end
	end
end

function SWEP:BuildAttachmentCache()
	for _, v in pairs(self.Attachments) do
		if v.atts then
			for l, b in pairs(v.atts) do
				self.AttachmentCache[b] = v.sel == l
			end
		end
	end
	table.Empty(self.AttachmentTableCache)
	for attName,sel  in pairs(self.AttachmentCache) do
		if not sel then continue end
		if not TFA.Attachments.Atts[attName] then continue end
		local srctbl = TFA.Attachments.Atts[attName].WeaponTable
		if not srctbl then continue end
		CloneTableRecursive(srctbl,self.AttachmentTableCache)
	end
end

function SWEP:IsAttached(attn)
	local v = self.AttachmentCache[attn]

	if v then
		return true
	else
		return false
	end
end

local tc

function SWEP:CanAttach(attn)
	if not self.HasBuiltMutualExclusions then
		tc = table.Copy(self.AttachmentExclusions)

		for k, v in pairs(tc) do
			if k ~= "BaseClass" then
				for _, b in pairs(v) do
					self.AttachmentExclusions[b] = self.AttachmentExclusions[b] or {}

					if not table.HasValue(self.AttachmentExclusions[b]) then
						self.AttachmentExclusions[b][#self.AttachmentExclusions[b] + 1] = k
					end
				end
			end
		end

		self.HasBuiltMutualExclusions = true
	end

	if att_enabled_cv and (not att_enabled_cv:GetBool()) then return false end

	if self.AttachmentExclusions[attn] then
		for _, v in pairs(self.AttachmentExclusions[attn]) do
			if self:IsAttached(v) then return false end
		end
	end

	if self.AttachmentDependencies[attn] then
		for k, v in pairs(self.AttachmentDependencies[attn]) do
			if k ~= "BaseClass" and (not self:IsAttached(v)) then return false end
		end
	end

	return true
end

function SWEP:GetStatRecursive(srctbl, stbl, ...)
	stbl = table.Copy(stbl)

	for _ = 1, #stbl do
		if #stbl > 1 then
			if srctbl[stbl[1]] then
				srctbl = srctbl[stbl[1]]
				table.remove(stbl, 1)
			else
				return ...
			end
		end
	end

	local val = srctbl[stbl[1]]

	if istable(val) and val.functionTable then
		local t, final, nocache
		final = false
		nocache = false
		for i = 1, table.Count(val) do
			local v = val[i]
			if isfunction(v) then
				local nct
				if not t then
					t, final, nct = v(self,...)
				else
					t, final, nct = v(self,t)
				end
				nocache = nocache or nct
				if final then break end
			elseif v then
				t = v
			end
		end
		if t then
			return t, nocache
		else
			return ...
		end
	elseif val ~= nil then
		return val
	else
		return ...
	end
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

local retval
SWEP.StatCache = {}
SWEP.StatCache2 = {}
SWEP.StatStringCache = {}

--[[
local function mtbl(t1, t2)
	local t = table.Copy(t1)

	for k, v in pairs(t2) do
		t[k] = v
	end

	return t
end
]]--

function SWEP:ClearStatCache(vn)
	if vn then
		self.StatCache[vn] = nil
		self.StatCache2[vn] = nil
	else
		table.Empty(self.StatCache)
		table.Empty(self.StatCache2)
	end
end

local ccv = GetConVar("cl_tfa_debug_cache")

function SWEP:GetStat(stat, default)
	if self.StatStringCache[stat] == nil then
		local t_stbl = string.Explode(".", stat, false)

		for k, v in ipairs(t_stbl) do
			t_stbl[k] = tonumber(v) or v
		end

		self.StatStringCache[stat] = t_stbl
	end

	local stbl = self.StatStringCache[stat]

	if self.StatCache2[stat] ~= nil then
		local finalReturn

		if self.StatCache[stat] ~= nil then
			finalReturn = self.StatCache[stat]
		else
			retval = self:GetStatRecursive(self, stbl)

			if retval ~= nil then
				self.StatCache[stat] = retval
				finalReturn = retval
			else
				finalReturn = istable(default) and table.Copy(default) or default
			end
		end

		finalReturn = hook.Run("TFA_GetStat", self, stat, finalReturn) or finalReturn

		return finalReturn
	else
		if not self:OwnerIsValid() then
			if IsValid(self) then
				local finalReturn = self:GetStatRecursive(self, stbl, istable(default) and table.Copy(default) or default)
				hook.Run("TFA_GetStat", stat, finalReturn)

				return finalReturn
			end

			local finalReturn = default
			finalReturn = hook.Run("TFA_GetStat", self, stat, finalReturn) or finalReturn

			return finalReturn
		end

		local cs = self:GetStatRecursive(self, stbl, istable(default) and table.Copy(default) or default)
		local nc = false
		cs,nc = self:GetStatRecursive(self.AttachmentTableCache, stbl, cs)

		if (not self.StatCache_Blacklist[stat]) and (not self.StatCache_Blacklist[stbl[1]]) and (not nc) and not (ccv and ccv:GetBool()) then
			self.StatCache[stat] = cs
			self.StatCache2[stat] = true
		end

		local finalReturn = cs
		finalReturn = hook.Run("TFA_GetStat", self, stat, finalReturn) or finalReturn

		return finalReturn
	end
end

function SWEP:SetTFAAttachment(cat, id, nw)
	if (not self.Attachments[cat]) then return false end
	if SERVER and (not self:CanAttach(self.Attachments[cat].atts[id] or "")) then return false end

	if id ~= self.Attachments[cat].sel then
		local att_old = TFA.Attachments.Atts[self.Attachments[cat].atts[self.Attachments[cat].sel] or -1]

		if att_old then
			att_old:Detach(self)
		end

		local att_neue = TFA.Attachments.Atts[self.Attachments[cat].atts[id] or -1]

		if att_neue then
			att_neue:Attach(self)
		end
	end

	self:ClearStatCache()

	if id > 0 then
		self.Attachments[cat].sel = id
	else
		self.Attachments[cat].sel = nil
	end

	self:BuildAttachmentCache()

	if nw then
		net.Start("TFA_Attachment_Set")
		net.WriteEntity(self)
		net.WriteInt(cat, 8)
		net.WriteInt(id or -1, 7)

		if SERVER then
			net.Broadcast()
		elseif CLIENT then
			net.SendToServer()
		end
	end

	return true
end

local attachments_sorted_alphabetically = GetConVar("sv_tfa_attachments_alphabetical")

function SWEP:InitAttachments()
	if self.HasInitAttachments then return end
	hook.Run("TFA_PreInitAttachments", self)
	self.HasInitAttachments = true

	for k, v in pairs(self.Attachments) do
		if type(k) == "string" then
			local tatt = self:VMIV() and self.OwnerViewModel:LookupAttachment(k) or self:LookupAttachment(k)

			if tatt > 0 then
				self.Attachments[tatt] = v
			end

			self.Attachments[k] = nil
		elseif (not attachments_sorted_alphabetically) and attachments_sorted_alphabetically:GetBool() then
			local sval = v.atts[v.sel]

			table.sort(v.atts, function(a, b)
				local aname = ""
				local bname = ""
				local att_a = TFA.Attachments.Atts[a]

				if att_a then
					aname = att_a.Name or a
				end

				local att_b = TFA.Attachments.Atts[b]

				if att_b then
					bname = att_b.Name or b
				end

				return aname < bname
			end)

			if sval then
				v.sel = table.KeyFromValue(v.atts, sval) or v.sel
			end
		end
	end

	for k, v in pairs(self.Attachments) do
		if v.sel then
			local vsel = v.sel
			v.sel = nil

			timer.Simple(0, function()
				if IsValid(self) and self.SetTFAAttachment then
					self:SetTFAAttachment(k, vsel, false)
				end
			end)

			if SERVER and game.SinglePlayer() then
				timer.Simple(0.05, function()
					if IsValid(self) and self.SetTFAAttachment then
						self:SetTFAAttachment(k, vsel, true)
					end
				end)
			end
		end
	end

	hook.Run("TFA_PostInitAttachments", self)
	self:RemoveUnusedAttachments()
	self:BuildAttachmentCache()
	hook.Run("TFA_FinalInitAttachments", self)
end

function SWEP:GenerateVGUIAttachmentTable()
	self.VGUIAttachments = {}
	local keyz = table.GetKeys(self.Attachments)
	table.RemoveByValue(keyz, "BaseClass")

	table.sort(keyz, function(a, b)
		--A and B are keys
		local v1 = self.Attachments[a]
		local v2 = self.Attachments[b]

		if v1 and v2 and (v1.order or v2.order) then
			return (v1.order or a) < (v2.order or b)
		else
			return a < b
		end
	end)

	for i, k in ipairs(keyz) do
		local v = self.Attachments[k]
		self.VGUIAttachments[i] = table.Copy(v)
		self.VGUIAttachments[i].cat = k
		self.VGUIAttachments[i].offset = nil
		self.VGUIAttachments[i].order = nil
	end

	local max_row_atts = math.floor(ScrW() * ATT_MAX_SCREEN_RATIO / ATT_DIMENSION)
	local i = 1

	while true do
		local v = self.VGUIAttachments[i]
		if not v then break end
		i = i + 1

		for l, b in pairs(v.atts) do
			if not istable(b) then
				v.atts[l] = {b, l} --name, ID
			end
		end

		if (#v.atts > max_row_atts) then
			while (#v.atts > max_row_atts) do
				local t = table.Copy(v)

				for _ = 1, max_row_atts do
					table.remove(t.atts, 1)
				end

				for _ = 1, #v.atts - max_row_atts do
					table.remove(v.atts)
				end

				table.insert(self.VGUIAttachments, i, t)
			end
		end
	end
end

local bgt
SWEP.Bodygroups_V = {}
SWEP.Bodygroups_W = {}

function SWEP:ProcessBodygroups()
	if not self.HasFilledBodygroupTables then
		if self:VMIV() then
			for i = 0, #(self.OwnerViewModel:GetBodyGroups() or self.Bodygroups_V) do
				self.Bodygroups_V[i] = self.Bodygroups_V[i] or 0
			end
		end

		for i = 0, #(self:GetBodyGroups() or self.Bodygroups_W) do
			self.Bodygroups_W[i] = self.Bodygroups_W[i] or 0
		end

		self.HasFilledBodygroupTables = true
	end

	if self:VMIV() then
		bgt = self:GetStat("Bodygroups_V", self.Bodygroups_V)

		for k, v in pairs(bgt) do
			if type(k) == "string" then
				k = tonumber(k)
			end

			if k and self.OwnerViewModel:GetBodygroup(k) ~= v then
				self.OwnerViewModel:SetBodygroup(k, v)
			end
		end
	end

	bgt = self:GetStat("Bodygroups_W", self.Bodygroups_W)

	for k, v in pairs(bgt) do
		if type(k) == "string" then
			k = tonumber(k)
		end

		if k and self:GetBodygroup(k) ~= v then
			self:SetBodygroup(k, v)
		end
	end
end