--[[Bow Ammo]]
--
game.AddAmmoType({
	name = "tfbow_arrow",
	dmgtype = DMG_CLUB,
	tracer = 0,
	minsplash = 5,
	maxsplash = 5
})

if CLIENT then
	language.Add("tfbow_arrow_ammo", "Arrows")
end
