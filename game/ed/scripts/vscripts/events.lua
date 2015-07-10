--[[ Events ]]

--------------------------------------------------------------------------------
-- GameEvent:OnGameRulesStateChange
--------------------------------------------------------------------------------
function CEDGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()

	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		self:SpawnCreatures()
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		print( "OnGameRulesStateChange: Pre Game Selection" )

	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print( "OnGameRulesStateChange: Game In Progress" )

	end
end

--------------------------------------------------------------------------------
-- GameEvent: OnNPCSpawned
--------------------------------------------------------------------------------
function CEDGameMode:OnNPCSpawned( event )
	hSpawnedUnit = EntIndexToHScript( event.entindex )

	if hSpawnedUnit:IsOwnedByAnyPlayer() and hSpawnedUnit:IsRealHero() then
		local hPlayerHero = hSpawnedUnit
		self._GameMode:SetContextThink( "self:Think_InitializePlayerHero", function() return self:Think_InitializePlayerHero( hPlayerHero ) end, 0 )
	end
end

--------------------------------------------------------------------------------
-- GameEvent: OnEntityKilled
--------------------------------------------------------------------------------
function CEDGameMode:OnEntityKilled( event )
	hDeadUnit = EntIndexToHScript( event.entindex_killed )
	hAttackerUnit = EntIndexToHScript( event.entindex_attacker )
end


--------------------------------------------------------------------------------
-- GrantItemDrop
--------------------------------------------------------------------------------
function CEDGameMode:GrantItemDrop( vPos )
	local nRandInt = RandomInt( 1, 10 )
	if nRandInt == 10 then
		self:CreateWorldItemOnPosition( "item_flask", vPos )
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
	hPlayerHero.PlayKillEffect = Juggernaut_PlayKillEffect
	local nPlayerID = hPlayerHero:GetPlayerOwnerID()
	PlayerResource:SetCameraTarget( nPlayerID, hPlayerHero )
	PlayerResource:SetOverrideSelectionEntity( nPlayerID, hPlayerHero )
	PlayerResource:SetGold( nPlayerID, 0, true )
	PlayerResource:SetGold( nPlayerID, 0, false )
	hPlayerHero:UpgradeAbility( hPlayerHero:GetAbilityByIndex( 0 ) )
	hPlayerHero:SetIdleAcquire( false )

	if self._tPlayerHeroInitialized[ nPlayerID ] == false then
		for i = 1, 2 do
			local hSalve = CreateItem( "item_flask", nil, nil )
			hPlayerHero:AddItem( hSalve )
		end
		self._tPlayerHeroInitialized[ nPlayerID ] = true
	end
end

--------------------------------------------------------------------------------
-- GameEvent: OnPlayerGainedLevel
--------------------------------------------------------------------------------
function CEDGameMode:OnPlayerGainedLevel( event )
	local hPlayer = EntIndexToHScript( event.player )
	local hPlayerHero = hPlayer:GetAssignedHero()

	hPlayerHero:SetHealth( hPlayerHero:GetMaxHealth() )
	hPlayerHero:SetMana( hPlayerHero:GetMaxMana() )
end
