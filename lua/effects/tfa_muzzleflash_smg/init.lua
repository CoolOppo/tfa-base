local function rvec(vec)
	vec.x=math.Round(vec.x)
	vec.y=math.Round(vec.y)
	vec.z=math.Round(vec.z)
	return vec
end

local blankvec = Vector(0,0,0)

local dif = Vector(0,0,0)

function EFFECT:Init( data )
	
	self.StartPacket = data:GetStart()
	self.Attachment = data:GetAttachment()

	local AddVel = vector_origin
	
	if LocalPlayer then
		if IsValid(LocalPlayer()) then
			AddVel = LocalPlayer():GetVelocity()
		end
	end
	
	if game.SinglePlayer() then
		AddVel = Entity(1):GetVelocity()
	end
	
	self.Position = data:GetOrigin()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local wepent = Entity(math.Round(self.StartPacket.z))
	
	local ownerent = player.GetByID(math.Round(self.StartPacket.x))
	local serverside = false
	if math.Round(self.StartPacket.y)==1 then
		serverside = true
	end
	
	if IsValid(wepent) then
		if ( wepent.IsFirstPerson and !wepent:IsFirstPerson() ) or serverside then
			data:SetEntity(wepent)
			self.Position = blankvec
		end
	end
	
	--[[
	self.Forward = ownerent:EyeAngles():Forward()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	]]--
	
	if serverside then
		if IsValid(ownerent) then
			if LocalPlayer() == ownerent then
				return
			end
			AddVel = ownerent:GetVelocity()
		end
	end
	
	if (!self.Position) or ( rvec(self.Position) == blankvec ) then
		self.WeaponEnt = data:GetEntity()
		self.Attachment = data:GetAttachment()
		if self.WeaponEnt and IsValid(self.WeaponEnt) then
			local rpos = self.WeaponEnt:GetAttachment(self.Attachment)
			if rpos and rpos.Pos then
				self.Position = rpos.Pos
				if data:GetNormal()==vector_origin then
					self.Forward = rpos.Ang:Up()
					self.Angle = self.Forward:Angle()
					self.Right = self.Angle:Right()
				end
			end
		end
	end
	
	self.vOffset = self.Position
	dir = self.Forward
	AddVel = AddVel * 0.05
	
	local dot = dir:GetNormalized():Dot( EyeAngles():Forward() )
	local dotang = math.deg( math.acos( math.abs(dot) ) )	
	local halofac =  math.Clamp( 1 - (dotang/90), 0, 1)
	
	local emitter = ParticleEmitter( self.vOffset )
		
		local particle = emitter:Add( "effects/muzzleflashX_nemole", self.vOffset )
		
		if (particle) then
			particle:SetVelocity( dir*4 + 1.05 * AddVel )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( 0.08 )
			particle:SetStartAlpha( math.Rand( 200, 255 ) )
			particle:SetEndAlpha( 0 )
			--particle:SetStartSize( 8 * (halofac*0.8+0.2), 0, 1)
			--particle:SetEndSize( 0 )
			particle:SetStartSize( 2 * (halofac*0.8+0.2), 0, 1)
			particle:SetEndSize( 4 * (halofac*0.8+0.2), 0, 1 )
			local r = math.Rand(-10, 10) * 3.14/180
			particle:SetRoll( r )
			particle:SetRollDelta( r/5)
			particle:SetColor( 255 , 218 , 97 )
			particle:SetLighting(false)
			particle.FollowEnt = data:GetEntity()
			particle.Att = self.Attachment
			TFARegPartThink(particle,TFAMuzzlePartFunc)
				particle:SetPos(vector_origin)
		end
		
		for i=1,1 do
			particle = emitter:Add( "effects/scotchmuzzleflash"..math.random(1,4), self.vOffset )
			
			if (particle) then
				particle:SetVelocity( dir*4 + 1.05 * AddVel )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.10 )
				particle:SetStartAlpha( math.Rand( 225, 255 ) )
				particle:SetEndAlpha( 0 )
				--particle:SetStartSize( 7.5 * (halofac*0.8+0.2), 0, 1)
				--particle:SetEndSize( 0 )
				particle:SetStartSize( 1 * (halofac*0.8+0.2), 0, 1)
				particle:SetEndSize( 8 * (halofac*0.8+0.2) )
				particle:SetRoll( math.rad(math.Rand(0, 360)) )
				particle:SetRollDelta( math.rad(math.Rand(-40, 40)) )
				particle:SetColor( 255 , 218 , 97 )
				particle:SetLighting(false)
				particle.FollowEnt = data:GetEntity()
				particle.Att = self.Attachment
				TFARegPartThink(particle,TFAMuzzlePartFunc)
			end
		end
		
		for i=0, 5 do
			local particle = emitter:Add( "particles/flamelet"..math.random(1,5), self.vOffset + (dir * 0.6 * i))
			if (particle) then
				particle:SetVelocity((dir * 19 * i) + 1.05 * AddVel )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.075 )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				--particle:SetStartSize( math.max(5.4 - 0.55 * i,1) )
				--particle:SetEndSize( 0 )
				particle:SetStartSize( math.max(5.4 - 0.55 * i,1)*0.35 )
				particle:SetEndSize( math.max(5.4 - 0.55 * i,1)*0.65 )
				particle:SetRoll( math.rad(math.Rand(0, 360)) )
				particle:SetRollDelta( math.rad(math.Rand(-40, 40)) )
				particle:SetColor( 255 , 218 , 97 )
				particle:SetLighting(false)
				particle.FollowEnt = data:GetEntity()
				particle.Att = self.Attachment
				TFARegPartThink(particle,TFAMuzzlePartFunc)
				particle:SetPos(vector_origin)
			end
		end
		
		for i=0, 4 do
		
			local particle = emitter:Add( "particles/smokey", self.vOffset + dir * math.Rand(6, 10 ))
			if (particle) then
				particle:SetVelocity(VectorRand() * 10 + dir * math.Rand(15,20) + 1.05 * AddVel )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 0.6, 0.7 ) )
				particle:SetStartAlpha( math.Rand( 6, 10 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand(5,7) )
				particle:SetEndSize( math.Rand(12,14) )
				particle:SetRoll( math.rad(math.Rand(0, 360)) )
				particle:SetRollDelta( math.Rand(-0.8, 0.8) )
				particle:SetLighting(true)
				
				particle:SetAirResistance( 10 ) 
 				 
 				particle:SetGravity( Vector( 0, 0, 60 ) ) 
				
				particle:SetColor( 255 , 255 , 255 ) 
			end
			
		end
		
		if GetConVarNumber("cl_tfa_fx_gasblur",1)==1 then
			for i=0, 1 do
				local particle = emitter:Add( "sprites/heatwave", self.vOffset + (dir * i) )
				if (particle) then
					particle:SetVelocity((dir * 25 * i) + 1.05 * AddVel )
					particle:SetLifeTime( 0 )
					particle:SetDieTime( math.Rand( 0.05, 0.15 ) )
					particle:SetStartAlpha( math.Rand( 200, 225 ) )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( math.Rand(3,5) )
					particle:SetEndSize( math.Rand(8,10) )
					particle:SetRoll( math.Rand(0, 360) )
					particle:SetRollDelta( math.Rand(-2, 2) )
					
					particle:SetAirResistance( 5 )
					 
					particle:SetGravity( Vector( 0, 0, 40 ) ) 
					
					particle:SetColor( 255 , 255 , 255 ) 
				end
			end
		end
		
	emitter:Finish() 
end 

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end

 