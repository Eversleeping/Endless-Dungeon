require("utility_functions")

local API = {}
setmetatable(API, API)
API.__index = API

function API:IsCasterHasTalent(hCaster, talent)
	local entindex = hCaster:entindex()
	GameRules.tTalents = GameRules.tTalents or {}
	local tTalent = GameRules.tTalents[entindex]
	return TableContains(tTalent, talent)
end

return API