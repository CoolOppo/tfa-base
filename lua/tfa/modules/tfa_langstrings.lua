local langstrings = {
	["en"] = {
		["nag_1"] = "Dear ",
		["nag_2"] = ", please take a moment to join TFA Mod News.  We'd be honored to have you as the ",
		["nag_3"] = "th member.  As soon as you join, you'll stop seeing this message.  You will see this a maximum of 5 times; this is #",
		["thank_1"] = "Thank you, ",
		["thank_2"] = ", for joining TFA Mod News!  You are member #"
	},
	["fr"] = {
		["nag_1"] = "Chère ",
		["nag_2"] = ", S'il vous plaît prendre un moment pour rejoindre TFA Mod Nouvelles. Nous serions honorés de vous avoir comme",
		["nag_3"] = "th membre. Dès que vous vous inscrivez, vous arrêtez de voir ce message. Vous verrez cela un maximum de 5 fois; c'est #",
		["thank_1"] = "Merci, ",
		["thank_2"] = ", pour rejoindre TFA Mod Nouvelles! Vous êtes membre #"
	},
    ["ru"] = {
        ["nag_1"] = "Уважаемый (ая) ",
        ["nag_2"] = ", пожалуйста, найдите время, чтобы присоединиться к группе TFA Mod News. Мы будем очень рады видеть вас в качестве ",
        ["nag_3"] = "-го участника группы. Как только вы присоединитесь к нам, вы перестанете видеть это сообщение. Вы увидите это максимум 5 раз, это ",
        ["thank_1"] = "Спасибо, ",
        ["thank_2"] = ", за присоединение к TFA Mod News! Вы участник под номером "
    },
	["ge"] = {
		["nag_1"] = "Herr/Frau ",
		["nag_2"] = ", bitte nehmen sie ein Moment sich TFA Mod News anschließen.  Wir würden uns geehrt um haben Sie als unser ",
		["nag_3"] = ". Mitglied.  Wenn Sie anschließen, Sie sehen dies nie wieder werden.  Sie werden dies nur fünfmal sehen; das war #",
		["thank_1"] = "Danken Sie, ",
		["thank_2"] = ", für TFA Mod News anschließen!  Sie sind Mitgleid #"
	}
}

local languages = {
	["be"] = "fr",
	["de"] = "ge",
	["at"] = "ge",
	["fr"] = "fr",
	["ru"] = "ru",
}

function TFA.GetLangString( str, country )
	local cc = country or system.GetCountry()
	local lang = languages[cc] or "en"
	local res = langstrings[lang][str] or langstrings["en"][str]
	return res
end
