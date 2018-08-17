local WEAPON = FindMetaTable("Weapon")
if WEAPON then
	function WEAPON:IsTFA()
		return self.IsTFAWeapon
	end
else
	print("[TFA Base] Can't find weapon metatable!")
end

local PLAYER = FindMetaTable("Player")
if PLAYER then
	function PLAYER:TFA_ZoomKeyDown()
		if not IsValid(self) then return false end

		return self:GetNW2Bool("TFA_ZoomKeyDown", false)
	end

	function PLAYER:TFA_SetZoomKeyDown(isdown)
		if not IsValid(self) then return end

		self:SetNW2Bool("TFA_ZoomKeyDown", isdown)
	end
else
	print("[TFA Base] Can't find player metatable!")
end