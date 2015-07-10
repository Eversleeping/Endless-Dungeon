require("utility_functions")

AI_BASIC = {}

AI_BASIC.Init = function( self, ent )

    ent.aiStates = {
        stateAggro = 0,
        stateIdle = 1
    }

    ent.aiParams = {
        hCurrentTarget = nil,
        nCurrentState = ent.aiStates.stateIdle,
        flShoutRange = 300,
        nWalkingSpeed = 140,
        nAggroMoveSpeed = 280,
        flAcquisitionRange = 900,
        vTargetWaypoint = nil
    }

    ent.aggroTable = {}

    ent:SetContextThink("ai_basic_think", function()
        ent.AIThink = AIThink
        ent.SetAIState = SetAIState
        ent.CheckIfHasAggro = CheckIfHasAggro
        ent.ShoutInRadius = ShoutInRadius
        ent.ModifyAggro = ModifyAggro
        ent.SetTarget = SetTarget
        ent.SetAcquisitionRange(ent.aiParams.flAcquisitionRange) -- 进入这个范围的目标将会被主动攻击
        if ent.isBoss then
            ent:SetContextThink( "ai_basic.BossAI", Dynamic_Wrap(ent, "BossAIThink"), 0)
        end
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
    if ent:CheckIfHasAggro() then -- 检查仇恨状态
        return RandomFloat(0.5, 1.5)
    end
    return 0.1
end

function CheckIfHasAggro(ent)
    if ent:GetAggroTarget() ~= nil then -- 正在战斗中
        ent.aiParams.nCurrentState = ent.aiStates.stateAggro
        local mat = ent:GetMaxAggroTarget()
        if  mat and mat ~= ent:GetAggroTarget() then -- 如果最大仇恨目标发生了变化，那么转换目标
            ent.aiParams.currentTarget = mat
            if not ent:IsChanneling() then
                ent:MoveToTargetToAttack( mat )
            end
        end
        ent:ShoutInRadius() -- 只要是在战斗中，旁边的只要没加入战斗，一概叫过来加入战斗
        return true
    else
        return false
    end
end

-- 叫上一切没有攻击的小伙伴打第一仇恨
function ShoutInRadius( ent )
    local tNearbyCreatures = Entities:FindAllByClassnameWithin( "npc_dota_creature", self:GetOrigin(), self.aiParams.flShoutRange )
    for k, hCreature in pairs( tNearbyCreatures ) do
        if hCreature:GetAggroTarget() == nil then
            hCreature:MoveToTargetToAttack( ent:GetMaxAggroTarget() )
        end
    end
end

-- 修正某个单位的仇恨值，初始为0
function ModifyAggro( ent, source, amount )
    -- ent.aggroTable = ent.aggroTable or {}
    if ent.aggroTable.source == nil then ent.aggroTable.source = 0 end
    ent.aggroTable.source = ent.aggroTable.source + amount
end

-- 获取当前最大仇恨值目标
function GetMaxAggroTarget( ent )
    local aggroTable = shallowcopy( ent.aggroTable )
    if #aggroTable <= 0 then
        return nil
    end
    local a = {}
    for _, v in pairs( aggroTable ) do
        table.insert(a,v)
    end
    table.sort( a, function(a1, a2) return a1 > a2 end )
    local maxAggroVal = a[1]
    return TableFindKey( aggroTable, maxAggroVal )
end
