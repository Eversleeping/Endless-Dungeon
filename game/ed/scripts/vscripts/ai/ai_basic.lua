if AIBASIC == nil then AIBASIC = class({}) end

require("ai.fsm")
require("ai.hatred")

MAX_ROARM_DISTANCE = 2000
LinkLuaModifier( "lm_take_no_damage", LUA_MODIFIER_MOTION_NONE )

function AIBASIC:init( unit )
	unit.spawnLocation = unit:GetAbsOrigin()

	--=================================================================
	-- 当单位开始进入战斗
	--=================================================================
	function unit.OnStartFight()
		print(unit:GetUnitName(), "-> start fight against you ~ ~ ~")
	end

	--=================================================================
	-- 切换攻击目标
	--=================================================================
	function unit.OnChangeAttackTarget()
		local maxHatredTarget = unit:GetMaxHatredTarget()
		if not maxHatredTarget then return end

		print("UNIT ",unit:GetUnitName()," CHANGE ATTACK TARGET from ", unit:GetAggroTarget() ,"=>", maxHatredTarget:GetUnitName())
		unit:MoveToTargetToAttack( maxHatredTarget )
	end

	--=================================================================
	-- 单位返回初始点
	--=================================================================
	function unit.OnBeginReturn()
		print("Unit begin to return current state", unit.__fsm__:get())
		unit.__fsm__:setlock(true)
		unit:AddNewModifier(unit, nil, "modifier_invulnerable", {})
		unit:Stop()

		unit:SetContextThink(DoUniqueString("return_checker"),function()
			if ( unit:GetAbsOrigin() - unit.spawnLocation ):Length2D() >= 50 then
				unit:MoveToPosition(unit.spawnLocation)
				return 0.1
			end

			local ar = unit:GetAcquisitionRange()
			unit:SetAcquisitionRange(0)
			unit:Stop()
			unit.__fsm__:setlock(false)
			unit.__fsm__:fire("on_return_start_pos")
			unit:RemoveModifierByName("modifier_invulnerable")
			unit:SetHealth(unit:GetMaxHealth())
			for i = 0, 15 do
				local ab = unit:GetAbilityByIndex(i)
				if ab then
					ab:EndCooldown()
				end
			end
			for i = 1,unit:GetModifierCount() do
				local modifier = unit:GetModifierNameByIndex(i)
				if modifier then
					print("MODIFIER FOUND!, IT'S ->",modifier)
					unit:RemoveModifierByName(modifier)
				end
			end
			HATRED:init(unit)

			return nil
		end,0)
	end

	--=================================================================
	-- FSM AI循环
	--=================================================================
	function unit:FSMThink( f, e )
		if not (IsValidEntity(unit) and unit:IsAlive())then
			return nil
		end

		local aggroUnit = unit:GetAggroTarget()

		if not unit:HasModifier("lm_damage_tracker") then -- ensure the damage tracker
			unit:AddNewModifier(unit, nil, "lm_damage_tracker", {})
		end

		if unit.__fsm__:get() == "waiting" then
			GameRules.ed_game_mode.__enemiesInFight[unit] = nil
			local hp = unit:GetHealth()
			local mhp = unit:GetMaxHealth()
			if hp < mhp or aggroUnit ~= nil then
				unit.__fsm__:fire("on_hurt")
				if aggroUnit and unit:GetHatred(aggroUnit) == nil then
					unit:ModifyHatred(aggroUnit, 0)
				end
				GameRules.ed_game_mode.__enemiesInFight[unit] = true
			end
			return 0.1
		end

		if ( unit:GetAbsOrigin() - unit.spawnLocation ):Length2D() > MAX_ROARM_DISTANCE then
			unit.__fsm__:fire("on_go_too_far")
			return 2
		end

		if unit:GetMaxHatredTarget() and aggroUnit ~= unit:GetMaxHatredTarget() then
			local isChanneling = false
			for i = 0, 15 do
				local ab = unit:GetAbilityByIndex(i)
				if ab then
					if ab:IsChanneling() then isChanneling = true end
				end
			end
			if isChanneling then
				return 0.1
			end
			unit.__fsm__:fire("on_change_aggro_target")
			return 2
		end

		if aggroUnit ~= nil then
			return 0.1
		end

		local enemies = FindUnitsInRadius( unit:GetTeam(), unit:GetOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
		if #enemies == 0 then
			print( "the unit found no enemies...!" )
			unit.__fsm__:fire("on_found_no_enemies")
			return 0.5
		else
			for _, v in pairs(enemies) do
				if unit:GetHatred(v) == nil then
					unit:ModifyHatred(v, 0)
				end
			end
			return 0.1
		end
		return 0.1
	end

	-- init fsm
	unit.__fsm__ = FSM:new(unit, {
		{"waiting","on_hurt","state_fighting", unit.OnStartFight},
		{"*","on_change_aggro_target","state_fighting", unit.OnChangeAttackTarget},
		{"*","on_found_no_enemies","state_return",unit.OnBeginReturn},
		{"*","on_go_too_far","state_return", unit.OnBeginReturn},
		{"state_return","on_return_start_pos","waiting", nil}
	})

	-- init hatred
	HATRED:init(unit)

end

-- 入口改为从KV入口，因为有的单位并不需要这个AI
function Spawn( entityKeyValues, thisEntity )
	AIBASIC:init( thisEntity )
end

-- 如果单位在自身AI之外，还需要其他AI，那么在他的SpawnAI中调用AIBASIC_InternalSpawn( thisEntity )
function InternalSpawn(e)
	AIBASIC:init( thisEntity )
end
