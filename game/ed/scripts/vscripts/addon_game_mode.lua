--[[ ed_game_mode game mode ]]

print( "Entering ed_game_mode's addon_game_mode.lua file." )

_G.DEBUG = true
------------------------------------------------------------------------------------------------------------------------------------------------------
-- RPGExample class
------------------------------------------------------------------------------------------------------------------------------------------------------
if CEDGameMode == nil then
	_G.CEDGameMode = class({})
end

require("utility_functions")
require("events")
require("test")
require("boss")

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Precache files and folders
------------------------------------------------------------------------------------------------------------------------------------------------------
function Precache( context )
    GameRules.ed_game_mode = CEDGameMode()
    GameRules.boss_manager = CBossManager()
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
	self._GameMode:SetStashPurchasingDisabled(true) -- 禁用储藏处
	self._GameMode:SetFogOfWarDisabled(true)

	GameRules:SetGoldPerTick( 0 )
	GameRules:SetPreGameTime( 0 )
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetCustomGameSetupTimeout( 0 ) -- skip the custom team UI with 0, or do indefinite duration with -1
	
	-- SendToServerConsole( "dota_camera_pitch_max 55" )
	-- SendToServerConsole( "dota_camera_distance 1234" )

	ListenToGameEvent("npc_spawned", Dynamic_Wrap(CEDGameMode, "OnNPCSpawned"), self)
	
	CustomGameEventManager:RegisterListener("player_update_selected_target", Dynamic_Wrap(CEDGameMode, "OnPlayerUpdateSelectedEntindex"))

	Convars:RegisterCommand("script_test", Dynamic_Wrap(CEDGameMode, "ScriptTest"), "string helpText", 0)

	self._tPlayerHeroInitialized = {}

	for i = 0, DOTA_MAX_PLAYERS do
		PlayerResource:SetCustomTeamAssignment( i, 2 ) -- put each player on Radiant team
		self._tPlayerHeroInitialized[ i ] = false
	end
	CBossManager:init()
	CustomGameEventManager:RegisterListener("player_vote_next_boss", Dynamic_Wrap(CBossManager, "OnPlayerVoteNextBoss"))
	CustomGameEventManager:RegisterListener("client_query_boss_list", Dynamic_Wrap(CBossManager, "OnClientQueryBossList"))

	print("BEGIN TO LOAD BOSS")
	require("bosses.arthas")
end