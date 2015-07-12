if _G.CBossManager == nil then
	_G.CBossManager = class({})
end

function CBossManager:init()
	self.p = Entities:FindByName(nil, "boss_spawn_loc"):GetAbsOrigin()
end

function CBossManager:RegisterBoss(name, args )
	if self._Bosses == nil then self._Bosses = {} end
	self._Bosses[name] = args
end

function CBossManager:SpawnBoss(name, difficulty)
	print("on order spawn boss")
	local boss = CreateUnitByNameAsync(name, self.p, true, nil, nil, DOTA_TEAM_BADGUYS, 
		function(unit)
			print("boss created finished!", unit:GetUnitName())
			unit.difficulty = difficulty
			unit.isBoss = true
			unit:SetForwardVector(Vector(0,-1,0))
			self._Bosses[name].init(unit, difficulty) -- init boss data
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
	for k,v in pairs(args) do
		print("OPVB =>"..k.."<=>"..v)
	end
	local self = CBossManager

	if self.firstPlayerVoteTime == nil then self.firstPlayerVoteTime = GameRules:GetGameTime() end
	if self.vote == nil then self.vote = {} end

	self.vote[args.PlayerID] = {
		name = args.name,
		difficulty = args.difficulty
	}

	local apc = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
	print("voted player count", TableCount(self.vote), "apc", apc)

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

	print("sort result -> ", n)

	local d = nil
	local m = 0
	for k,v in pairs(result_difficulty[n]) do
		if v >= m then
			d = k
			m = v
		end
	end
	print("difficulty selection result -> ", d)

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("boss_going_to_spawn"), function()
		print("spawning boss")
		CBossManager:SpawnBoss(n, d)
	end, 1) --TODO

	print("boss is going to spawn")

	CustomGameEventManager:Send_ServerToAllClients("boss_going_to_spawn", {})
end

return CBossManager