require("abilities.eda_base")
eda_test_target_selection = class({},{},eda_base)

-- @override target validation
-- 假装把无目标技能伪装成有目标技能，向UI选择的目标释放
function eda_test_target_selection:CastFilterResult()

	print(Convars.__player__selected__entindex__)
	print(CDOTAGamerules.__player__selected__entindex__)
	do
		return UF_FAIL_CUSTOM
	end

	print("validating target")
	local an = self:GetAbilityName()
	if TableContains(EDAbilities_target_required, an) then
		local nsei = self:GetCaster().__selectedEntityIndex

		print("nsei", nsei)
		if not nsei then 
			return UF_FAIL_CUSTOM
		end
		

		--  目标非法
		if not IsValidEntity( eSelectedEntityIndex) then
			return UF_FAIL_CUSTOM
		end

		-- 目标已经死亡
		if not eSelectedEntityIndex:IsAlive() then -- 不能对已经死亡的目标释放，如果要加复活技能，那么需要重写这个区块
			return UF_FAIL_CUSTOM
		end

		print("an eda target required ability is casted, trying to validate it! ")
		
		local at = self:GetAbilityTargetTeam()
		print("Ability target team type -> ", at)

		-- 目标队伍类型不正确
		if (self:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY and self:GetCaster():GetTeamNumber() == eSelectedEntityIndex:GetTeamNumber() or
			self:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY and self:GetCaster():GetTeamNumber() ~= eSelectedEntityIndex:GetTeamNumber()) then
			print("team mismatch, ability cant cast on selected target")
			return UF_FAIL_CUSTOM
		end

		-- 面向不正确
		if not self:GetCaster():IsFacing(eSelectedEntityIndex) then
			print("not facing target, ability canceled")
			return UF_FAIL_CUSTOM
		end
	end
	print("target is valid! the aiblity name is -> ", an)
	return UF_SUCCESS
end

function eda_test_target_selection:GetAbilityName()
	return "eda_test_target_selection"
end