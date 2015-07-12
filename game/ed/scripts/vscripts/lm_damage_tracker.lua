lm_damage_tracker = class({})

function lm_damage_tracker:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function lm_damage_tracker:OnTakeDamage(args)
	local victim = self:GetParent()
	local attacker = args.attacker
	local damage = args.damage
	
	if victim ~= attacker and victim.ModifyHatred then
		victim:ModifyHatred(attacker, damage) -- 增加与伤害等值仇恨
	end
end

function lm_damage_tracker:IsHidden() return false end

function lm_damage_tracker:IsPurgable() return false end