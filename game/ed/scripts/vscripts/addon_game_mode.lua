--[[ ed_game_mode game mode ]]

print( "Entering ed_game_mode's addon_game_mode.lua file." )


------------------------------------------------------------------------------------------------------------------------------------------------------
-- RPGExample class
------------------------------------------------------------------------------------------------------------------------------------------------------
if CEDGameMode == nil then
	_G.CEDGameMode = class({})
end

require("filters")

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Precache files and folders
------------------------------------------------------------------------------------------------------------------------------------------------------
function Precache( context )
    GameRules.ed_game_mode = CEDGameMode()
    -- GameRules.ed_game_mode:PrecacheSpawners( context )

	-- Particle systems to precache for onKill effects.
	-- PrecacheResource( "particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", context )
	-- PrecacheResource( "particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_mechanical.vpcf", context )
	-- PrecacheResource( "particle", "particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", context )
end

--------------------------------------------------------------------------------
-- Activate RPGExample mode
--------------------------------------------------------------------------------
function Activate()
    GameRules.ed_game_mode:InitGameMode()
end

--------------------------------------------------------------------------------
-- Init
--------------------------------------------------------------------------------
function CEDGameMode:InitGameMode()
	print( "Entering CEDGameMode:InitGameMode" )
	self._GameMode = GameRules:GetGameModeEntity()

	self._GameMode:SetAnnouncerDisabled( true )
	self._GameMode:SetContextThink( "CEDGameMode:GameThink", Dynamic_Wrap(CEDGameMode,"GameThink"), 0 )
	self._GameMode:SetDamageFilter(Dynamic_Wrap(CEDGameMode, "DamageFilter"), self)

	GameRules:SetGoldPerTick( 0 )
	GameRules:SetPreGameTime( 0 )
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetCustomGameSetupTimeout( 0 ) -- skip the custom team UI with 0, or do indefinite duration with -1
	GameRules:SetStashPurchasingDisabled(true) -- 禁用储藏处
	
	SendToServerConsole( "dota_camera_pitch_max 55" )
	SendToServerConsole( "dota_camera_distance 1234" )

	self._tPlayerHeroInitialized = {}
	for i = 0, DOTA_MAX_PLAYERS do
		PlayerResource:SetCustomTeamAssignment( i, 2 ) -- put each player on Radiant team
		self._tPlayerHeroInitialized[ i ] = false
	end
end


--------------------------------------------------------------------------------
-- Main Think
--------------------------------------------------------------------------------
function CEDGameMode:GameThink()
	local flThinkTick = 0.2
	return flThinkTick
end
