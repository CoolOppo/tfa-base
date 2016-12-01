--[[
To any non-skids reading this: ignore this and move on.
This blocks access to the URL cheater.team, which is used by idiots to "hack" kids.
If the special folks in question are reading this, I have two words to spare for you:
Just stop.
]]--

if not ( game.SinglePlayer() or CLIENT ) then return end

--Because [TFA]'s an idiot and has overwritten and detoured functions.
--Actually, a clean vararg detour isn't causing any bugs;  SE breaks because it's paranoid.
http.FetchOld = http.FetchOld or http.Fetch

http.Fetch = function(url, ...)
	if not string.find(url, "cheater.team") then
		return http.FetchOld(url, ...)
	else
		print("skid blocked, check your addons")
	end
end

http.PostOld = http.PostOld or http.Post

http.Post = function(url, ...)
	if not string.find(url, "cheater.team") then
		http.PostOld(url, ...)
	else
		print("skid blocked, check your addons")
	end
end