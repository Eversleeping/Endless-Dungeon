function foo()
	print("good")
end

local test = foo

foo = function()
	test()
	if TalentSystem:PlayerHasTalent(self:GetCaster():entindex(), "talent_linfengchongji") then
		print("excellent")
	end
end

foo()