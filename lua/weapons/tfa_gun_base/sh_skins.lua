SWEP.MaterialTable = {}
SWEP.MaterialTable_V = {}
SWEP.MaterialTable_W = {}

function SWEP:InitializeMaterialTable()
	if not self.HasSetMaterialMeta then
		setmetatable(self.MaterialTable_V,{ ["__index"] = self:GetStat("MaterialTable") } )
		setmetatable(self.MaterialTable_W,{ ["__index"] = self:GetStat("MaterialTable") } )
		self.HasSetMaterialMeta = true
	end
end