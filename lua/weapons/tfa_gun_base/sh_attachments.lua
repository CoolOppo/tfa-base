function SWEP:InitAttachments()
	if SERVER then self:CallOnClient("InitAttachments","") end
	for attid,v in pairs(self.Attachments) do
		if v.Attached then
			self:Detach(attid)			
		end
		v.Attached = false
	end
end

function SWEP:Attach( attid, nonetwork )
	local self_tbl = self.Attachments[attid]
	if self_tbl then
		if self_tbl.Attached then return end
		local tbl = TFA_ATT[attid]
		if tbl then
			if SERVER and !nonetwork then self:CallOnClient("Attach",attid) end
			tbl.AttachBase(tbl,self)
			tbl.Attach(tbl,self)
			self.Attachments[attid].Attached = true
		else
			print("That attachment isn't registered.  Please register it.")
		end
	else
		print("That attachment isn't supported.  Please add it to SWEP table.")
	end
end

function SWEP:Detach( attid, nonetwork )
	local self_tbl = self.Attachments[attid]
	if self_tbl then
		if !self_tbl.Attached then return end
		local tbl = TFA_ATT[attid]
		if tbl then
			if SERVER and !nonetwork then self:CallOnClient("Detach",attid) end
			tbl.DetachBase(tbl,self)
			tbl.Detach(tbl,self)
			self.Attachments[attid].Attached = false
		else
			print("That attachment isn't registered.  Please register it.")
		end
	else
		print("That attachment isn't supported.  Please add it to SWEP table.")
	end
end