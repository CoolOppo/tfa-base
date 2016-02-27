local blankvec = Vector(0,0,0)
local AddVel = Vector()
local dif = Vector(0,0,0)
local ang

function EFFECT:Init( data )
	
	self.WeaponEnt = data:GetEntity()
	if !IsValid(self.WeaponEnt) then return end
	self.Attachment = data:GetAttachment()
	
	self.Position = self:GetTracerShootPos( data:GetOrigin(), self.WeaponEnt, self.Attachment )
	
	if IsValid(self.WeaponEnt.Owner) then
		if self.WeaponEnt.Owner:ShouldDrawLocalPlayer() then
			ang = self.WeaponEnt.Owner:GetAimVector():Angle()
ang:Normalize()
			--ang.p = math.Clamp(ang.p,-55,55)
			self.Forward = ang:Forward()
		else
			self.WeaponEnt = self.WeaponEnt.Owner:GetViewModel()
		end
	end
	
	self.Forward = self.Forward or data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	self.vOffset = self.Position
	dir = self.Forward
	
	if IsValid(LocalPlayer()) then
		AddVel = LocalPlayer():GetVelocity()
	end
	
	AddVel = AddVel * 0.05
	
	self.vOffset = self.Position
	dir = self.Forward
	AddVel = AddVel * 0.05
	
	local dot = dir:GetNormalized():Dot( EyeAngles():Forward() )
	local dotang = math.deg( math.acos( math.abs(dot) ) )	
	local halofac =  math.Clamp( 1 - (dotang/90), 0, 1)
	
	if CLIENT and !IsValid(ownerent) then ownerent = LocalPlayer() end
	
	local dlight = DynamicLight( ownerent:EntIndex() )
	if ( dlight ) then
		dlight.pos = self.vOffset - ownerent:EyeAngles():Right()*5 + 1.05 * ownerent:GetVelocity() * FrameTime()
		dlight.r = 255
		dlight.g = 192
		dlight.b = 64
		dlight.brightness = 4
		dlight.Decay = 1750
		dlight.Size = 45
		dlight.DieTime = CurTime() + 0.3
	end
	
	local emitter = ParticleEmitter( self.vOffset )
		
		particle = emitter:Add( "effects/scotchmuzzleflash"..math.random(1,4), self.vOffset )
			
			if (particle) then
				particle:SetVelocity( dir*4 + 1.05 * AddVel )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.15 )
				particle:SetStartAlpha( math.Rand( 32, 48 ) )
				particle:SetEndAlpha( 0 )
				--particle:SetStartSize( 7.5 * (halofac*0.8+0.2), 0, 1)
				--particle:SetEndSize( 0 )
				particle:SetStartSize( 3 * (halofac*0.8+0.2), 0, 1)
				particle:SetEndSize( 8 * (halofac*0.8+0.2) )
				particle:SetRoll( math.rad(math.Rand(0, 360)) )
				particle:SetRollDelta( math.rad(math.Rand(-40, 40)) )
				particle:SetColor( 255 , 218 , 97 )
				particle:SetLighting(false)
				particle.FollowEnt = self.WeaponEnt
				particle.Att = self.Attachment
				TFARegPartThink(particle,TFAMuzzlePartFunc)
			end
		
		for i=0, 12 do
		
			local particle = emitter:Add( "particles/smokey", self.vOffset + dir * math.Rand(6, 10 ))
			if (particle) then
				particle:SetVelocity(VectorRand() * 10 + dir * math.Rand(15,20) + 1.05 * AddVel )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 0.6, 0.7 ) )
				particle:SetStartAlpha( math.Rand( 12, 24 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand(5,7) )
				particle:SetEndSize( math.Rand(13,15) )
				particle:SetRoll( math.rad(math.Rand(0, 360)) )
				particle:SetRollDelta( math.Rand(-0.8, 0.8) )
				particle:SetLighting(true)
				
				particle:SetAirResistance( 10 ) 
 				 
 				particle:SetGravity( Vector( 0, 0, 60 ) ) 
				
				particle:SetColor( 255 , 255 , 255 ) 
			end
			
		end
		
		if GetTFAGasEnabled() then
			for i=0, 3 do
				local particle = emitter:Add( "sprites/heatwave", self.vOffset + (dir * i) )
				if (particle) then
					particle:SetVelocity((dir * 25 * i) + 1.05 * AddVel )
					particle:SetLifeTime( 0 )
					particle:SetDieTime( math.Rand( 0.05, 0.15 ) )
					particle:SetStartAlpha( math.Rand( 200, 225 ) )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( math.Rand(3,5) )
					particle:SetEndSize( math.Rand(11,14) )
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