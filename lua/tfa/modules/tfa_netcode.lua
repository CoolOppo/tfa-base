if SERVER then
	--Pool netstrings
	util.AddNetworkString("tfaSoundEvent")
	util.AddNetworkString("tfa_base_muzzle_mp")
	util.AddNetworkString("tfaShotgunInterrupt")
	util.AddNetworkString("tfaRequestFidget")
	util.AddNetworkString("tfaSDLP")
	util.AddNetworkString("tfaArrowFollow")
	util.AddNetworkString("tfaTracerSP")
	util.AddNetworkString("tfaBaseShellSV")
	--util.AddNetworkString("tfaAltAttack")

	--Enable CKey Inspection

	net.Receive("tfaRequestFidget",function(length,client)
		local wep = client:GetActiveWeapon()
		if IsValid(wep) and wep.CheckAmmo then wep:CheckAmmo() end
	end)

	--Enable shotgun interruption
	net.Receive("tfaShotgunInterrupt", function(length, client)
		if IsValid(client) and client:IsPlayer() and client:Alive() then
			local ply = client
			local wep = ply:GetActiveWeapon()

			if IsValid(wep) and wep.ShotgunInterrupt then
				wep:ShotgunInterrupt()
			end
		end
	end)

	net.Receive("tfaSDLP",function(length,client)
		local bool = net.ReadBool()
		client.TFASDLP = bool
	end)

	--Enable alternate attacks
	--[[
	net.Receive("tfaAltAttack", function(length, client)
		if IsValid(client) and client:IsPlayer() and client:Alive() then
			local ply = client
			wep = ply:GetActiveWeapon()

			if IsValid(wep) and wep.AltAttack then
				wep:AltAttack()
			end
		end
	end)
	]]--
	--Distribute muzzles from server to clients
	net.Receive("tfa_base_muzzle_mp", function(length, plyv)
		local wep = plyv:GetActiveWeapon()

		if IsValid(wep) and wep.ShootEffectsCustom then
			wep:ShootEffectsCustom()
		end
	end)
end

if CLIENT then
	--Arrow can follow entities clientside too
	net.Receive("tfaArrowFollow",function()
		local ent = net.ReadEntity()
		ent.targent = net.ReadEntity()
		ent.targbone = net.ReadInt( 8 )
		ent.posoff = net.ReadVector(  )
		ent.angoff = net.ReadAngle(  )
		ent:TargetEnt( false )
	end)

	--Receive sound events on client
	net.Receive("tfaSoundEvent", function(length, ply)
		local wep = net.ReadEntity()
		local snd = net.ReadString()

		if IsValid(wep) and snd and snd ~= "" then
			wep:EmitSound(snd)
		end
	end)

	--Receive muzzleflashes on client
	net.Receive("tfa_base_muzzle_mp", function(length, ply)
		local wep = net.ReadEntity()

		if IsValid(wep) and wep.ShootEffectsCustom then
			wep:ShootEffectsCustom(true)
		end
	end)
	net.Receive("tfaBaseShellSV", function(length, ply)
		local wep = net.ReadEntity()

		if IsValid(wep) and wep.MakeShellBridge then
			wep:MakeShellBridge(true)
		end
	end)

	net.Receive( "tfaTracerSP", function( length, ply )
		local part = net.ReadString()
		local startPos = net.ReadVector()
		local endPos = net.ReadVector()
		local woosh = net.ReadBool()
		local vent = net.ReadEntity()
		local att = net.ReadInt( 8 )
		if IsValid( vent ) then
			local aP = vent:GetAttachment( att or 1 )
			if aP then
				startPos = aP.Pos
			end
		end
		TFA.ParticleTracer( part, startPos, endPos, woosh, vent, att )
	end)
end
