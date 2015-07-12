if AIBASIC == nil then AIBASIC = class({}) end

require("ai.fsm")
require("ai.hatred")


MAX_ROARM_DISTANCE = 2000

LinkLuaModifier( "lm_take_no_damage", LUA_MODIFIER_MOTION_NONE )

function AIBASIC:init( unit )
	unit.spawnLocation = unit:GetAbsOrigin()

	function unit.OnStartFight()
		print(unit:GetUnitName(), "-> start fight against you ~ ~ ~")
	end

	function unit.OnChangeAttackTarget()
		local maxHatredTarget = unit:GetMaxHatredTarget()
		if not maxHatredTarget then return end

		print("UNIT ",unit:GetUnitName()," CHANGE ATTACK TARGET from ", unit:GetAggroTarget() ,"=>", maxHatredTarget:GetUnitName())
		unit:MoveToTargetToAttack( maxHatredTarget )
	end

	function unit.OnBeginReturn()
		print("Unit begin to return current state", unit.__basicFSM:get())
		unit.__basicFSM:setlock(true)
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
			unit.__basicFSM:setlock(false)
			unit.__basicFSM:fire("on_return_start_pos")
			unit:RemoveModifierByName("modifier_invulnerable")
			unit:SetHealth(unit:GetMaxHealth())
			unit:SetForwardVector(Vector(0,-1,0))

			HATRED:init(unit)

			return nil
		end,0)
	end

	-- init fsm
	unit.__basicFSM = FSM:new(unit, {
		{"waiting","on_get_hurt","state_fighting", unit.OnStartFight},
		{"state_fighting","on_change_aggro_target","state_fighting", unit.OnChangeAttackTarget},
		{"*","on_found_no_enemies","state_return",unit.OnBeginReturn},
		{"*","on_go_too_far","state_return", unit.OnBeginReturn},
		{"state_return","on_return_start_pos","waiting", nil}
	})

	-- init hatred
	HATRED:init(unit)
	unit:SetContextThink(DoUniqueString("basic_ai_think"),
		function()

			if not IsValidEntity(unit) then
				return nil
			end
			if not unit:IsAlive() then 
				return nil 
			end

			if unit.__basicFSM:get() == "waiting" then
				local hp = unit:GetHealth()
				local mhp = unit:GetMaxHealth()	
				if hp < mhp then
					unit.__basicFSM:fire("on_get_hurt")
				end
				return 0.1
			end

			if ( unit:GetAbsOrigin() - unit.spawnLocation ):Length2D() > MAX_ROARM_DISTANCE then
				print("unit has go too far, begin to return to spawn location")
				unit.__basicFSM:fire("on_go_too_far")
				return 2
			end

			local aggroUnit = unit:GetAggroTarget()
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
				unit.__basicFSM:fire("on_change_aggro_target")
				return 2
			end

			if unit:GetAggroTarget() ~= nil then return end -- 只要有人打，那就打，反正都找不到最高仇恨了……，真没人打再往下……

			local enemies = FindUnitsInRadius( unit:GetTeam(), unit:GetOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
			if #enemies == 0 then
				print( "the unit found no enemies...!" )
				unit.__basicFSM:fire("on_found_no_enemies")
				return 0.5
			else
				local e = enemies[1]
				if unit:GetHatred(e) == nil then
					unit:ModifyHatred(, 0)
				end
			end

			return 0.1
		end,
	0)
end
