SWEP.MaterialTable = {}
SWEP.MaterialTable_V = {}
SWEP.MaterialTable_W = {}

function SWEP:InitializeMaterialTable()
	if not self.HasSetMaterialMeta then
		setmetatable(self.MaterialTable_V, {
			["__index"] = function(t,k) return self:GetStat("MaterialTable")[k] end
		})

		setmetatable(self.MaterialTable_W, {
			["__index"] = function(t,k) return self:GetStat("MaterialTable")[k] end
		})

		self.HasSetMaterialMeta = true
	end
end

--if both nil then we can just clear it all
function SWEP:ClearMaterialCache(view, world)
	if view == nil and world == nil then
		self.MaterialCached_V = nil
		self.MaterialCached_W = nil
		self.MaterialCached = nil
	else
		if view then
			self.MaterialCached_V = nil
		end

		if world then
			self.MaterialCached_W = nil
		end
	end
	self:ClearStatCache()
end