eda_im_frost_bold = class({})
LinkLuaModifier("edm_ice_slow", "modifiers/edm_ice_slow", LUA_MODIFIER_MOTION_NONE)

function eda_im_frost_bold:OnSpellStart()
	print("OnSpellStart")
	self.eda_target = EntIndexToHScript(GameRules.tUnitSelectedTarget[self:GetCaster():entindex()])

	local info = {
			EffectName = "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf",
			Ability = self,
			iMoveSpeed = self:GetSpecialValueFor( "frost_bolt_speed" ),
			Source = self:GetCaster(),
			Target = self.eda_target,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
		}

	ProjectileManager:CreateTrackingProjectile( info )
	EmitSoundOn( "Hero_VengefulSpirit.MagicMissile", self:GetCaster() )
end

function eda_im_frost_bold:OnProjectileHit(hTarget, vLocation)
	print("OnProjectileHit")
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) and ( not hTarget:IsMagicImmune() ) then
		EmitSoundOn( "Hero_VengefulSpirit.MagicMissileImpact", hTarget )
		local frost_bolt_slow = self:GetSpecialValueFor( "frost_bolt_slow_duration" )
		local frost_bolt_damage = self:GetSpecialValueFor( "frost_bolt_damage" )

		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = frost_bolt_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage( damage )

		if (not hTarget:IsEDASlowImmue()) then
			hTarget:AddNewModifier( self:GetCaster(), self, "edm_ice_slow", { duration = frost_bolt_slow } )
		end
	end
end

function eda_im_frost_bold:CastFilterResult()
	print("CastFilterResult")
	self.maxRange = self:GetSpecialValueFor("max_range")
	self.ingoreFacing = false

	local caster = self:GetCaster()
	local this = self

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
	return UF_SUCCESS
end

function eda_im_frost_bold:GetCustomCastError()
	local caster = self:GetCaster()
	local this = self

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

	return ""
end