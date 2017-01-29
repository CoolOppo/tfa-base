if SERVER then
	local wep,ply
	--Pool netstrings
	util.AddNetworkString("tfaSoundEvent")
	util.AddNetworkString("tfa_base_muzzle_mp")
	util.AddNetworkString("tfaInspect")
	util.AddNetworkString("tfaShotgunInterrupt")
	util.AddNetworkString("tfaRequestFidget")
	util.AddNetworkString("tfaSDLP")
	util.AddNetworkString("tfaArrowFollow")
	--util.AddNetworkString("tfaAltAttack")

	--Enable inspection
	net.Receive("tfaInspect", function(length, client)
		local mybool = net.ReadBool()
		mybool = mybool and 1 or 0

		if IsValid(client) and client:IsPlayer() and client:Alive() then
			ply = client
			wep = ply:GetActiveWeapon()

			if IsValid(wep) and wep.ToggleInspect then
				wep:ToggleInspect()
			end
		end
	end)
	--Enable CKey Inspection

	net.Receive("tfaRequestFidget",function(length,client)
		wep = client:GetActiveWeapon()
		if IsValid(wep) and wep.CheckAmmo then wep:CheckAmmo() end
	end)

	--Enable shotgun interruption
	net.Receive("tfaShotgunInterrupt", function(length, client)
		if IsValid(client) and client:IsPlayer() and client:Alive() then
			ply = client
			wep = ply:GetActiveWeapon()

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
			ply = client
			wep = ply:GetActiveWeapon()

			if IsValid(wep) and wep.AltAttack then
				wep:AltAttack()
			end
		end
	end)
	]]--
	--Distribute muzzles from server to clients
	net.Receive("tfa_base_muzzle_mp", function(length, plyv)
		wep = plyv:GetActiveWeapon()

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
		wep = net.ReadEntity()
		snd = net.ReadString()

		if IsValid(wep) and snd and snd ~= "" then
			wep:EmitSound(snd)
		end
	end)

	--Receive muzzleflashes on client
	net.Receive("tfa_base_muzzle_mp", function(length, ply)
		wep = net.ReadEntity()

		if IsValid(wep) and wep.ShootEffectsCustom then
			wep:ShootEffectsCustom(true)
		end
	end)
end
