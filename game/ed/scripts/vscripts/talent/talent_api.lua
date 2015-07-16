require("utility_functions")

function IsCasterHasTalent(hCaster, talent)
	local entindex = hCaster:entindex()
	local tTalent = GameRules.tTalents[entindex]
	return TableContains(tTalent, talent)
end