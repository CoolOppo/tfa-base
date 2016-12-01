if CLIENT then

	surface.CreateFont( "TFA_ForeheadEngraver", {--RTJ
		font = "Segoe UI",
		extended = false,
		size = 288,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )

	local TFAMods = {
		["76561198161775645"] = "TFA-Main",
		["76561198326378778"] = "TFA-Workshop"
	}

	local eastereggcvar = CreateClientConVar("cl_tfa_verify", 0, true, true)
	local localplayer
	local plytbl
	local drawicon
	local lmang = nil
	local lastvisible
	local lply
	local tpos
	local tracedata = {}
	local traceres
	local minsvec = Vector(-5, -5, -5)
	local maxsvec = Vector(5, 5, 5)
	local nekpos
	local pos,ang
	local head
	local nek
	local epos
	local view
	local tbl

	local tang

	local function LocalPlayerCanSee(ent1)
		if not IsValid(lply) then
			lply = LocalPlayer()

			return
		end

		tpos = ent1.GetShootPos and ent1:GetShootPos() or ent1:GetPos()
		tpos = (tpos + ent1:GetPos()) / 2
		tracedata.start = EyePos()
		tracedata.endpos = tpos
		tracedata.mins = minsvec
		tracedata.maxs = maxsvec

		if ent1 ~= lply then
			tracedata.filter = {lply, lply:GetActiveWeapon(), ent1.GetActiveWeapon and ent1:GetActiveWeapon()}
		elseif GetViewEntity() ~= lply then
			tracedata.filter = {GetViewEntity(), lply:GetActiveWeapon(), ent1.GetActiveWeapon and ent1:GetActiveWeapon()}
		end

		traceres = util.TraceHull(tracedata)

		if traceres.Entity == ent1 or ( ent1 == lply and not IsValid(traceres.Entity) ) then
			return true
		else
			return false
		end
	end

	hook.Add("PostDrawTranslucentRenderables", "VerifyTFA", function()
		if eastereggcvar and not eastereggcvar:GetBool() then return end

		if not IsValid(localplayer) then
			localplayer = LocalPlayer()
		end

		if not IsValid(localplayer) then return end

		if not lmang then
			lmang = Material("sprites/grip")
		end

		plytbl = player.GetAll()

		for k, v in pairs(plytbl) do
			drawicon = false

			if TFAMods[v:SteamID64()] then
				drawicon = true

				if v == localplayer and not v:ShouldDrawLocalPlayer() then
					drawicon = false
				end

				if not LocalPlayerCanSee(v) then
					drawicon = false
				end
			end

			if drawicon then
				nekpos = v:GetShootPos()
				pos = v:GetShootPos()
				head = v:LookupBone("ValveBiped.Bip01_Head1")

				if head then
					pos,ang = v:GetBonePosition(head)
				end

				--[[
				nek = v:LookupBone("ValveBiped.Bip01_Neck1")

				if nek then
					nekpos = v:GetBonePosition(nek)
				end
				]]--

				epos = EyePos()
				view = GetViewEntity()
				tbl = {v:GetActiveWeapon()}

				if view ~= v then
					table.insert(tbl, view)
				end

				tang = ang
				tang:RotateAroundAxis(tang:Forward(),90)
				tang:RotateAroundAxis(tang:Up(),-90)
				--tang:RotateAroundAxis(tang:Right(),-90)

				if not lastvisible or CurTime() - lastvisible < 0.1 then
					render.PushFilterMin( TEXFILTER.ANISOTROPIC )
					render.PushFilterMag( TEXFILTER.ANISOTROPIC )
					cam.IgnoreZ(true)
					cam.Start3D2D( pos + ang:Up()*3+ ang:Right()*-4, tang, 0.03 )
					draw.SimpleText("TFA","TFA_ForeheadEngraver",0,0,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					cam.End3D2D()
					cam.IgnoreZ(false)
					render.PopFilterMin( )
					render.PopFilterMag( )

					--render.SetMaterial(lmang)
					--cam.IgnoreZ(true)
					--render.DrawSprite(pos, 16, 16, color_white)
					--cam.IgnoreZ(false)
				end
			end
		end
	end)
end