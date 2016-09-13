TFAFlareParts = {}
TFAVMAttachments = {}

if CLIENT  then
	hook.Add("PreDrawEffects", "TFAMuzzleUpdate", function()
		if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and IsValid(LocalPlayer():GetViewModel()) then
			local wep = LocalPlayer():GetActiveWeapon()
			local vm = LocalPlayer():GetViewModel()
			local tbl = vm:GetAttachments()
			if tbl then
				local i = 1
				while i<=#tbl do
					TFAVMAttachments[i] = vm:GetAttachment(i)
					i=i+1
				end
			end
		end
		for k,v in pairs(TFAFlareParts) do
			if v and v.ThinkFunc then
				v:ThinkFunc()
			end
		end
	end)
end

function TFARegPartThink( particle, partfunc )
	if !particle or !partfunc then return end
	particle.ThinkFunc = partfunc
	if IsValid(particle.FollowEnt) and particle.Att then
		local angpos = particle.FollowEnt:GetAttachment(particle.Att)
		if angpos and angpos.Pos then
			particle.OffPos = WorldToLocal(particle:GetPos(),particle:GetAngles(),angpos.Pos,angpos.Ang)
		end
	end
	table.insert(TFAFlareParts,#TFAFlareParts+1,particle)
	timer.Simple( particle:GetDieTime(), function()
		if particle then
			table.RemoveByValue(TFAFlareParts,particle)
		end
	end)

end

function TFAMuzzlePartFunc(self,first)
	if self.isfirst==nil then
		self.isfirst = false
		first = true
	end
	local vm = LocalPlayer():GetViewModel()
	local wep = LocalPlayer():GetActiveWeapon()
	if IsValid(wep) and wep.IsCurrentlyScoped and wep:IsCurrentlyScoped() then return end
	if IsValid(self.FollowEnt) then
		local owent = self.FollowEnt.Owner or self.FollowEnt

		if !IsValid(owent) then return end

		local firvel

		if first then
			firvel = owent:GetVelocity() * FrameTime() * 1.1
		else
			firvel = vector_origin
		end

		if self.Att and self.OffPos then
			if self.FollowEnt == vm then
				local angpos = TFAVMAttachments[self.Att]
				if angpos and angpos.Pos then
					local tmppos = LocalToWorld(self.OffPos,self:GetAngles(),angpos.Pos,angpos.Ang)
					local npos = tmppos+self:GetVelocity()*FrameTime()
					self.OffPos = WorldToLocal(npos + firvel * 0.5,self:GetAngles(),angpos.Pos,angpos.Ang)
					self:SetPos( npos + firvel)
				end
			else
				local angpos =self.FollowEnt:GetAttachment(self.Att)
				if angpos and angpos.Pos then
					local tmppos = LocalToWorld(self.OffPos,self:GetAngles(),angpos.Pos,angpos.Ang)
					local npos = tmppos+self:GetVelocity()*FrameTime()
					self.OffPos = WorldToLocal(npos + firvel * 0.5,self:GetAngles(),angpos.Pos,angpos.Ang)
					self:SetPos( npos + firvel)
				end
			end
		end
	end
end
