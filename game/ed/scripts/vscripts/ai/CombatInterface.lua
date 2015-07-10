AiState = {}
AiState.STANDING = 0
AiState.MOVING = 1
AiState.FIGHTING = 2
AiState.BACK = 3

AiSetting.DEFAULT_MAX_DISTANCE = 2000

CombatInterface = {}

local m_CombatInterface = {}

setmetatable(m_CombatInterface, CombatInterface)

CombatInterface:Init( entity )
    function entity:BasicThink()
        if not entity:bBattleStarted() then return end
        if entity:CheckSpawnRange() > ( entity.nMaxDistance or AiSetting.DEFAULT_MAX_DISTANCE) then
            entity:ReturnToSpawnLocation()
        end
        local target = entity:GetNextTarget()
        if target == nil then
            entity.bAttacking = false
            entity:ReturnToSpawnLocation()
        else
            entity.eAiState = AiState.FIGHTING
            entity:DealWithFight()
        end
    end

    function entity:bIsFightint()
        return entity.eAiState == AiState.FIGHTING
    end
end


return m_CombatInterface
