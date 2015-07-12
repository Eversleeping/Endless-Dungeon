--[[
	仇恨系统
	XavierCHN
	2015.07.12
]]

require("utility_functions")

LinkLuaModifier( "lm_damage_tracker", LUA_MODIFIER_MOTION_NONE )

if _G.HATRED == nil then _G.HATRED = {} end

function HATRED:init(unit)

	print("initing hatred for unit", unit:GetUnitName())
	
	unit.hatred = {}

	if not unit:HasModifier("lm_damage_tracker") then
		unit:AddNewModifier(unit, nil, "lm_damage_tracker", {})
	end

	function unit:ModifyHatred(target, amount)
		if unit == target then return end
		if unit:GetTeam() == target:GetTeam() then return end

		if unit.hatred[target] == nil then
			unit.hatred[target] = 0
		end
		local r = unit.hatred[target] + amount
		-- print("modify hatred " .. target:GetUnitName() .. " -to-->"..unit:GetUnitName() .. ", from ", unit.hatred[target], "==>", r)
		unit.hatred[target] = r
	end

	function unit:GetHatred(target)
		return unit.hatred[target]
	end

	function unit:ForceHatred(target, duration)
		-- 禁止永久强制嘲讽
		if not duration or type(duration) ~= "number" then return end

		unit.forceHatredTarget = target

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
				unit.hatred[k] = nil
			elseif (not m or m < v) then
				m = v
			end
		end
		return TableFindKey(unit.hatred, m)
	end

end