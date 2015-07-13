if _G.CBossManager == nil then
	_G.CBossManager = class({})
end

function CBossManager:init()
	self.p = Entities:FindByName(nil, "boss_spawn_loc"):GetAbsOrigin()
end

function CBossManager:RegisterBoss(name, isPlayable)
	if self._Bosses == nil then self._Bosses = {} end
	self._Bosses[name] = isPlayable
end

function CBossManager:SpawnBoss(name, difficulty)
	local boss = CreateUnitByNameAsync(name, self.p, true, nil, nil, DOTA_TEAM_BADGUYS,
		function(unit)
			print("boss created finished!", unit:GetUnitName())
			unit.difficulty = difficulty
			unit.isBoss = true
			unit:SetForwardVector(Vector(0,-1,0))
		end
	)
end

function CBossManager:OnClientQueryBossList(args)
	print("CBossManager:OnClientQueryBossList",args)
	---[[
	local nPlayerID = args.PlayerID
	for name in pairs(CBossManager._Bosses) do
		print("sending boss list to client index ",nPlayerID, "now sending ->",name)
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID), "register_new_boss", {name = name})
	end
	--]]
end

function CBossManager:OnPlayerVoteNextBoss(args)
	print("PLAYER VOTED NEXT BOSS")

	local self = CBossManager

	if self.firstPlayerVoteTime == nil then self.firstPlayerVoteTime = GameRules:GetGameTime() end
	if self.vote == nil then self.vote = {} end

	self.vote[args.PlayerID] = {
		name = args.name,
		difficulty = args.difficulty
	}

	local apc = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)

	if (TableCount(self.vote) == apc or GameRules:GetGameTime() - self.firstPlayerVoteTime > 30) then
		self.firstPlayerVoteTime = nil
		CBossManager:OnPlayerVoteNextBossFinished(self.vote)
		self.vote = nil
	end
end

function CBossManager:OnPlayerVoteNextBossFinished(vote)
	local result_name = {}
	local result_difficulty = {}
	for k,v in pairs(vote) do
		result_name[v.name] = result_name[v.name] or 0
		result_name[v.name] = result_name[v.name] + 1
		result_difficulty[v.name] = result_difficulty[v.name] or {}
		result_difficulty[v.name][v.difficulty] = result_difficulty[v.name][v.difficulty] or 0
		result_difficulty[v.name][v.difficulty] = result_difficulty[v.name][v.difficulty] + 1
	end

	local n = nil
	local x = 0
	for k,v in pairs(result_name) do
		if v > x then
			n = k
			x = v
		end
	end

	local d = nil
	local m = 0
	for k,v in pairs(result_difficulty[n]) do
		if v >= m then
			d = k
			m = v
		end
	end

	CustomGameEventManager:Send_ServerToAllClients("boss_going_to_spawn", {})

	local spawn_delay = 10
	Timers:CreateTimer( spawn_delay, function()
		CBossManager:SpawnBoss(n,d)
	end)
	Timers:CreateTimer(1.0, function()
		spawn_delay = spawn_delay - 1
      	if spawn_delay > 0 then
      		CustomGameEventManager:Send_ServerToAllClients("update_screen_timer", {time = spawn_delay})
      		return 1.0
      	else
      		CustomGameEventManager:Send_ServerToAllClients("destroy_screen_timer", {})
      		return nil
      	end
      	return 1.0
    end
  )
end

return CBossManager
