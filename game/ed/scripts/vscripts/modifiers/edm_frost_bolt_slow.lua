edm_frost_bolt_slow = class({})

function edm_frost_bolt_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
end

function edm_frost_bolt_slow:OnCreated( kv )
	self.movespeed_slow = self:GetAbilty():GetSpecialValueFor("movespeed_slow")
end

function edm_frost_bolt_slow:GetModifierMoveSpeedBonus_Constant()
	return self.movespeed_slow
end