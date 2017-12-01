if not CLIENT then return end

if not TFA.SleekFontCreated then
	local fontdata = {}
	fontdata.font = "Roboto"
	fontdata.shadow = false
	fontdata.extended = true
	fontdata.size = 36
	surface.CreateFont("TFASleek", fontdata)
	TFASleekFontHeight = draw.GetFontHeight("TFASleek")
	fontdata.size = 30
	surface.CreateFont("TFASleekMedium", fontdata)
	TFASleekFontHeightMedium = draw.GetFontHeight("TFASleekMedium")
	fontdata.size = 24
	surface.CreateFont("TFASleekSmall", fontdata)
	TFASleekFontHeightSmall = draw.GetFontHeight("TFASleekSmall")
	fontdata.size = 18
	surface.CreateFont("TFASleekTiny", fontdata)
	TFASleekFontHeightTiny = draw.GetFontHeight("TFASleekTiny")
	TFA.SleekFontCreated = true
end

if not TFA.InspectionFontsCreated then
	local fontdata = {}
	fontdata.font = "Roboto"
	fontdata.extended = true
	fontdata.weight = 500
	fontdata.size = 64
	surface.CreateFont("TFA_INSPECTION_TITLE", fontdata)
	fontdata.size = 32
	surface.CreateFont("TFA_INSPECTION_DESCR", fontdata)
	fontdata.size = 24
	surface.CreateFont("TFA_INSPECTION_SMALL", fontdata)

	TFA.InspectionFontsCreated = true
end