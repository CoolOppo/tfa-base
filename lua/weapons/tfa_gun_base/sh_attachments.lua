SWEP.Attachments = {
	--[MDL_ATTACHMENT] = = { offset = { 0, 0 }, atts = { "sample_attachment" }, sel = 1 }
	--Sorry for copying your syntax, Spy, but it makes it easier on the users and you did an excellent job.  The code's all mine anyways.
	--sel allows you to have an attachment pre-selected, and is used internally by the base to show which attachment is selected in each category.
}

SWEP.AttachmentCache = {
	--["att_name"] = true
}

SWEP.AttachmentDependencies = {}--{["si_acog"] = {"bg_rail"}}
SWEP.AttachmentExclusions = {}--{ ["si_iron"] = {"bg_heatshield"} }

local att_enabled_cv = GetConVar("sv_tfa_attachments_enabled")

function SWEP:BuildAttachmentCache(  )
	for k,v in pairs(self.Attachments) do
		if v.atts then
			for l,b in pairs(v.atts) do
				self.AttachmentCache[b] = v.sel == l
			end
		end
	end
end

function SWEP:IsAttached( attn )
	local v = self.AttachmentCache[ attn ]
	if v then return true else return false end
end

function SWEP:CanAttach( attn )
	if att_enabled_cv and ( not att_enabled_cv:GetBool() ) then
		return false
	end
	if self.AttachmentExclusions[ attn ] then
		for k,v in pairs( self.AttachmentExclusions[ attn ] ) do
			if self:IsAttached(v) then
				return false
			end
		end
	end
	if self.AttachmentDependencies[ attn ] then
		for k,v in pairs( self.AttachmentDependencies[ attn ] ) do
			if k ~= "BaseClass" and ( not self:IsAttached(v) ) then
				return false
			end
		end
	end
	return true
end

function SWEP:GetStatRecursive( srctbl, stbl, ... )
	stbl = table.Copy(stbl)
	for k,v in ipairs(stbl) do
		if #stbl > 1 then
			if srctbl[ stbl[1] ] then
				srctbl = srctbl[ stbl[1] ]
				table.remove(stbl,1)
			else
				return ...
			end
		end
	end
	local val = srctbl[ stbl[1] ]
	if type(val) == "function" then
		return val(self,...)
	elseif val ~= nil then
		return val
	else
		return ...
	end
end

SWEP.StatCache_Blacklist = {
	["ViewModelBoneMods"] = true,
	["MaterialTable"] = true,
	["Bodygroups_V"] = true,
	["Bodygroups_W"] = true,
	["Skin"] = true
}
SWEP.StatCache = {}
SWEP.StatCache2 = {}

local function mtbl( t1, t2 )
	local t = table.Copy(t1)
	for k,v in pairs(t2) do
		t[k] = v
	end
	return t
end

function SWEP:ClearStatCache(  )

	table.Empty( self.StatCache )
	table.Empty( self.StatCache2 )

end

function SWEP:GetStat( stat, default )
	if istable(default) then
		default = table.Copy( default )
	end
	if self.StatCache2[ stat ] ~= nil then
		return self.StatCache[ stat ]
	else
		--if default == nil then default = 1 end
		local stbl = string.Explode(".",stat,false)
		for k,v in pairs(stbl) do
			local tn = tonumber(v)
			if tn then stbl[k] = tn end
		end
		local cs = self:GetStatRecursive( self, stbl, default )
		for k,v in pairs(self.Attachments) do
			if v.atts and v.sel then
				local srctbl = TFA.Attachments[ v.atts[v.sel] ].WeaponTable
				local tstat, final = self:GetStatRecursive( srctbl, stbl, cs )
				if tstat ~= nil then
					if istable(tstat) and istable(cs) and ( not final ) then
						cs = mtbl( cs, tstat )
					else
						cs = tstat
					end
				end
				if final then break end
			end
		end
		if ( not self.StatCache_Blacklist[stat] ) and ( not self.StatCache_Blacklist[stbl[1]] ) then
			self.StatCache[stat] = cs
			self.StatCache2[stat] = true
		end
		return cs
	end
end

function SWEP:SetTFAAttachment( cat, id, nw )

	if ( not self.Attachments[cat] ) then return false end
	if not self:CanAttach( self.Attachments[cat].atts[ id ] or "" ) then return false end

	if id ~= self.Attachments[cat].sel then
		local att_old = TFA.Attachments[ self.Attachments[cat].atts[ self.Attachments[cat].sel ] or -1 ]
		if att_old then
			att_old:Detach( self )
		end

		local att_neue = TFA.Attachments[ self.Attachments[cat].atts[ id ] or -1 ]
		if att_neue then
			att_neue:Attach( self )
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
		net.WriteInt(cat,4)
		net.WriteInt( id or -1 ,5)
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
	self.HasInitAttachments = true
	for k,v in pairs(self.Attachments) do
		if type(k) == "string" then
			local tatt = self:VMIV() and self.OwnerViewModel:LookupAttachment(k) or self:LookupAttachment(k)
			if tatt > 0 then
				self.Attachments[ tatt ] = v
			end
			self.Attachments[k] = nil
		elseif ( not attachments_sorted_alphabetically ) and attachments_sorted_alphabetically:GetBool() then
			local sval = v.atts[ v.sel ]
			print(sval)
			table.sort( v.atts , function(a,b)
				local aname = ""
				local bname = ""
				local att_a = TFA.Attachments[ a ]
				if att_a then
					aname = att_a.Name or a
				end
				local att_b = TFA.Attachments[ b ]
				if att_b then
					bname = att_b.Name or b
				end
				return aname < bname
			end)
			if sval then
				v.sel = table.KeyFromValue( v.atts, sval ) or v.sel
			end
		end
	end
	for k,v in pairs(self.Attachments) do
		if v.atts then
			for l,b in pairs( v.atts ) do
				if not TFA.Attachments[b] then
					table.RemoveByValue(v.atts,b)
				end
			end
		end
		if v.sel then
			local vsel = v.sel
			v.sel = nil
			timer.Simple(0, function()
				if IsValid(self) and self.SetTFAAttachment then
					self:SetTFAAttachment(k,vsel,false)
				end
			end)
			if SERVER and game.SinglePlayer() then
				timer.Simple(0.05, function()
					if IsValid(self) and self.SetTFAAttachment then
						self:SetTFAAttachment(k,vsel,true)
					end
				end)
			end
		end
	end

	self:BuildAttachmentCache()
end

local bgt

SWEP.Bodygroups_V = {}
SWEP.Bodygroups_W = {}

function SWEP:ProcessBodygroups()
	if not self.HasFilledBodygroupTables then
		if self:VMIV() then
			for i = 0, #( self.OwnerViewModel:GetBodyGroups() or self.Bodygroups_V  ) do
				self.Bodygroups_V[i] = self.Bodygroups_V[i] or 0
			end
		end

		for i = 0, #( self:GetBodyGroups() or self.Bodygroups_W  ) do
			self.Bodygroups_W[i] = self.Bodygroups_W[i] or 0
		end

		self.HasFilledBodygroupTables = true
	end

	if self:VMIV() then
		bgt = self:GetStat("Bodygroups_V", self.Bodygroups_V )

		for k, v in pairs(bgt) do
			if type(k) == "string" then
				k = tonumber(k)
			end
			if k and self.OwnerViewModel:GetBodygroup(k) ~= v then
				self.OwnerViewModel:SetBodygroup(k, v)
			end
		end
	end

	bgt = self:GetStat("Bodygroups_W", self.Bodygroups_W )

	for k, v in pairs(bgt) do
		if type(k) == "string" then
			k = tonumber(k)
		end
		if k and self:GetBodygroup(k) ~= v then
			self:SetBodygroup(k, v)
		end
	end
end