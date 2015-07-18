require("utility_functions")

local EDA = {}
setmetatable(EDA, EDA)
EDA.__index = EDA

-- 技能目标类型
EDA.ABILITY_TARGET_NONE = 0 -- 空
EDA.ABILITY_TARGET_NO_TARGET = 1 -- 无目标
EDA.ABILITY_TARGET_SINGLE_TARGET = 2 -- 单体目标
EDA.ABILITY_TARGET_AOE = 4 -- 群体目标
-- 技能队伍类型

function EDA:IsCasterHasTalent(hCaster, talent)
	local entindex = hCaster:entindex()
	GameRules.tTalents = GameRules.tTalents or {}
	local tTalent = GameRules.tTalents[entindex]
	return TableContains(tTalent, talent)
end

function EDA:GetSelectTarget(caster)
	return EntIndexToHScript(GameRules.tUnitSelectedTarget[caster:entindex()])
end

function EDA:GetSingleTargetFilterResult(caster, this)
	print("tryin to get single target filter result")
	local pst = EntIndexToHScript(GameRules.tUnitSelectedTarget[caster:entindex()])
	print("player selected target ->", pst)
	-- 必须选定一个目标
	if pst == nil then 
		print("ability fail -> target invalid")
		return UF_FAIL_CUSTOM
	end
	
	local tt = pst:GetTeamNumber()
	local ct = caster:GetTeamNumber()
	local abilityTargetTeam = this:GetAbilityTargetTeam()
	-- 无法对敌人释放
	if tt == ct and abilityTargetTeam ~= DOTA_UNIT_TARGET_TEAM_ENEMY then
		print("ability fail -> target is enemy")
		return UF_FAIL_CUSTOM
	end
	-- 无法对队友释放
	if tt ~= ct and abilityTargetTeam == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
		print("ability fail -> target is friend")
		return UF_FAIL_CUSTOM
	end
	-- 必须面向目标
	if not this.ingoreFacing then
		if not IsFacing(caster, pst) then
		print("ability fail -> target is not in vos")
			return UF_FAIL_CUSTOM
		end
	end
	-- 超出距离
	local range = GameRules.tRoleRangeSettings[caster:GetUnitName()]
	if this.maxRange then
		range = this.maxRange
	end
	if (caster:GetAbsOrigin() - pst:GetAbsOrigin()):Length2D() > range then
		print("ability fail -> target is out of range")
		return UF_FAIL_CUSTOM
	end

	return nil
end

function EDA:GetSingleTargetCustomError(caster, this)
	local pst = EntIndexToHScript(GameRules.tUnitSelectedTarget[caster:entindex()])

	-- 必须选定一个目标
	if pst == nil then 
		return "EDA_AE_TARGET_REQUIRED"
	end

	local tt = pst:GetTeamNumber()
	local ct = caster:GetTeamNumber()
	local abilityTargetTeam = this:GetAbilityTargetTeam()
	-- 无法对敌人释放
	if tt == ct and abilityTargetTeam ~= DOTA_UNIT_TARGET_TEAM_ENEMY then
		return "EDA_AE_CANT_CAST_ON_ENEMY"
	end
	-- 无法对队友释放
	if tt ~= ct and abilityTargetTeam == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
		return "EDA_AE_CANT_CAST_ON_ALLY"
	end
	-- 必须面向目标
	if not this.ingoreFacing then
		if not IsFacing(caster, pst) then
			return "EDA_AE_SHOULD_FACE_TARGET"
		end
	end
	-- 超出距离
	local range = GameRules.tRoleRangeSettings[caster:GetUnitName()]
	if this.maxRange then
		range = this.maxRange
	end
	if (caster:GetAbsOrigin() - pst:GetAbsOrigin()):Length2D() > range then
		return "EDA_AE_OUT_OF_RANGE"
	end

	return nil
end

return EDA
