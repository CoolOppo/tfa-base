if not matproxy then return end
matproxy.Add( {
	name = "PlayerWeaponColorStatic",

	init = function( self, mat, values )

		self.ResultTo = values.resultvar

	end,

	bind = function( self, mat, ent )

		if ( !IsValid( ent ) ) then return end

		local owner = ent:GetOwner()
		if ( !IsValid( owner ) or !owner:IsPlayer() ) then return end

		local col = owner:GetWeaponColor()
		if ( !isvector( col ) ) then return end

		mat:SetVector( self.ResultTo, col * 1)

	end
} )

local cvec = Vector()

matproxy.Add( {
	name = "TFALaserColor",

	init = function( self, mat, values )

		self.ResultTo = values.resultvar

	end,

	bind = function( self, mat, ent )

		if ( !IsValid( ent ) ) then return end

		local owner = ent:GetOwner()
		if !IsValid(owner) then
			owner = ent:GetParent()
		end
		if IsValid(owner) and owner:IsWeapon() then
			owner = owner:GetOwner() or owner:GetOwner()
		end
		if ( !IsValid( owner ) or !owner:IsPlayer() ) then return end

		local c = owner:GetWeaponColor()
		cvec.x = c.r
		cvec.y = c.g
		cvec.z = c.b
		mat:SetVector( self.ResultTo, cvec )
	end
} )

