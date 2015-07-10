AI_BASIC = {}

AI_BASIC.Init = function( self, ent )
    ent.aiState = {
        stateAggro = 0,
        stateIdle = 1
    }
    ent.aiParams = {
        hAggroTarget = nil,
        flShoutRange = 300,
        nWalkingSpeed = 140,
        nAggroMoveSpeed = 280,
        flAcquisitionRange = 900,
        vTargetWaypoint = nil
    }

    ent:SetContextThink("ai_basic_think", function()
        ent.AIThink = AIThink
        ent.SetAIState = SetAIState
        ent.CheckIfHasAggro = CheckIfHasAggro
        ent.ShoutInRadius = ShoutInRadius
        ent.SetAcquisitionRange(ent.aiParams.flAcquisitionRange)
        ent:SetContextThink("ai_basic.AIThink", Dynamic_Wrap(ent, "AIThink"), 0)
    end, 0)
end

function AIThink( ent )
    if not IsValidEntity(ent) then
        return nil
    end
    if not ent:IsAlive() then
        return nil
    end
    if GameRules:IsGamePaused() then
        return 0.1
    end
    if ent:CheckIfHasAggro() then
        return RandomFloat(0.5, 1.5)
    end
    return 0.1
end

function CheckIfHasAggro(ent)
    if ent:mmoGetAggroTarget() ~= nil then
        ent:SetBaseMoveSpeed(ent.nAggroMoveSpeed)
        if ent:mmoGetAggroTarget() ~= ent.aiParams.hAggroTarget then
            ent.aiParams.hAggroTarget = ent:mmoGetAggroTarget()
            ent:ShoutInRadius()
        end
        return true
    end

end
