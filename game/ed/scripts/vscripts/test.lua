function CEDGameMode:ScriptTest()
	local mt = class({})
	function mt:Start()
		print("good")
	end
	local t = class({},{},mt)
	function t:test()
		self:__getbase__():Start()
	end
	t:test()
end