function CEDGameMode:ScriptTest()
	nPlayerID = 1
	CustomGameEventManager:Send_ServerToAllClients("player_hero_first_spawn", {
		PlayerID = nPlayerID
	})
end