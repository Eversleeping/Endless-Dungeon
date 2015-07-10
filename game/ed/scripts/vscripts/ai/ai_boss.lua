require("utility_functions")

AI_BOSS = {}

AI_BOSS.Init( self, ent)
    ent.isBoss = true
    ent.BossAIThink = BossAIThink
end

function BossAIThink()
    return
end
