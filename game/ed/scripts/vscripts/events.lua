--[[ Events ]]

--------------------------------------------------------------------------------
-- GameEvent: OnNPCSpawned
--------------------------------------------------------------------------------
function CEDGameMode:OnNPCSpawned( event )

	print("CEDGameMode:OnNPCSpawned( event )")

	hSpawnedUnit = EntIndexToHScript( event.entindex )

	if hSpawnedUnit:IsOwnedByAnyPlayer() and hSpawnedUnit:IsRealHero() then
		local hPlayerHero = hSpawnedUnit
		self._GameMode:SetContextThink( "self:Think_InitializePlayerHero", function() return self:Think_InitializePlayerHero( hPlayerHero ) end, 0 )
	end
end

--------------------------------------------------------------------------------
-- Think_InitializePlayerHero
--------------------------------------------------------------------------------
function CEDGameMode:Think_InitializePlayerHero( hPlayerHero )
	if not hPlayerHero or hPlayerHero.bInitialized then
		return
	end

	hPlayerHero.bInitialized = true
	
	local nPlayerID = hPlayerHero:GetPlayerOwnerID()
	-- PlayerResource:SetCameraTarget( nPlayerID, hPlayerHero )
	PlayerResource:SetOverrideSelectionEntity( nPlayerID, hPlayerHero )
	PlayerResource:SetGold( nPlayerID, 0, true )
	PlayerResource:SetGold( nPlayerID, 0, false )
	
	hPlayerHero:SetIdleAcquire( false )
	hPlayerHero:SetAbilityPoints(0)

	for i = 0, 15 do
		local a = hPlayerHero:GetAbilityByIndex(i)
		if a then
			a:SetLevel(a:GetMaxLevel())
		end
	end

	if self._tPlayerHeroInitialized[ nPlayerID ] == false then
		hPlayerHero:AddItem( CreateItem( "item_flask", nil, nil ) )
		hPlayerHero:AddItem( CreateItem( "item_blink", nil, nil ) )
		hPlayerHero:AddItem( CreateItem( "item_blink", nil, nil ) )
		hPlayerHero:AddItem( CreateItem( "item_blink", nil, nil ) )
		hPlayerHero:AddItem( CreateItem( "item_blink", nil, nil ) )
		hPlayerHero:AddItem( CreateItem( "item_blink", nil, nil ) )
		self._tPlayerHeroInitialized[ nPlayerID ] = true
	end

	local l = hPlayerHero:GetLevel()
	while l < 25 do
		hPlayerHero:HeroLevelUp(false)
		l = hPlayerHero:GetLevel()
	end

	CustomGameEventManager:Send_ServerToAllClients("player_hero_first_spawn", {
		PlayerID = nPlayerID
	})
end


function CEDGameMode:OnPlayerUpdateSelectedEntindex(args)
	print("OnPlayerUpdateSelectedEntindex")
	local hPlayer = PlayerResource:GetPlayer(args.PlayerID)
	CustomGameEventManager:Send_ServerToPlayer(hPlayer, "player_update_selected_entindex", {entindex = args.entindex})
end