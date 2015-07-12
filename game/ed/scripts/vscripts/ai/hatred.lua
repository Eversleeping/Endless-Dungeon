--[[
	仇恨系统
	XavierCHN
	2015.07.12
]]

require("utility_functions")

if _G.HATRED == nil then _G.HATRED = {} end

function HATRED:init(unit)

	print("initing hatred for unit", unit:GetUnitName())
	
	unit.hatred = {}

	function unit:ModifyHatred(target, amount)
		if unit.hatred[target] == nil then
			unit.hatred[target] = 0
		end

		unit.hatred[target] = unit.hatred[target] + amount
	end

	function unit:ForceHatred(target, duration)
		unit.forceHatredTarget = target

		if not duration or type(duration) ~= "number" then return end

		unit.forceHatredStartTime = GameRules:GetGameTime()
		unit:SetContextThink(DoUniqueString("hatred_remove"), function() 
			if GameRules:GetGameTime() - unit.forceHatredStartTime >= duration then
				unit.forceHatredTarget = nil
				return nil
			end
			return 0.1
		end, 0.1)
	end

	function unit:GetMaxHatredTarget()
		return unit.forceHatredTarget or
			unit:GetMaxHatredTargetWithoutForce()
	end 

	function unit:GetMaxHatredTargetWithoutForce()
		local m = nil
		for k, v in pairs(unit.hatred) do
			if ( (not IsValidEntity(k)) or (not  k:IsAlive() ) ) then
				unit.hatred(k) = nil
			elseif (not m or m < v) then
				m = v
			end
		end
		return TableFindKey(unit.hatred, m)
	end

end