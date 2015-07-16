eda_test_target_selection = class({})

function eda_test_target_selection:OnAbilityPhaseStart()
end

function eda_test_target_selection:CastFilterResult()

	local ci = self:GetCaster():entindex()
	self.__target = GameRules.tUnitSelectedTarget[ci]
	local test = require("abilities.eda_api")
	print(test.IsPlayerHasTalent(self:GetCaster(),"test"))

	if self.__target == nil then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end

function eda_test_target_selection:GetCustomCastError()
	if self.__target == nil then
		return "#eda_hud_error_target_required"
	end
	return ""
end


function eda_test_target_selection:OnSpellStart()
end