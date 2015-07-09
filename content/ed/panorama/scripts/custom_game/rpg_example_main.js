"use strict";

function Msg(msg)
{
	$.Msg(msg);
}

// Tracks the left-button held when attacking a target
function BeginAttackState( targetEntIndex )
{
	var order = {
		OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex : targetEntIndex,
		AbilityIndex : Entities.GetAbility( Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ), 0 ),
		Queue : false,
		ShowEffects : false
	};
	(function tic()
	{
		if ( GameUI.IsMouseDown( 0 ) )
		{
			$.Schedule( 1.0/30.0, tic );
			if ( Entities.IsAlive( order.TargetIndex) &&Abilities.IsCooldownReady( order.AbilityIndex ) && !Abilities.IsInAbilityPhase( order.AbilityIndex ) )
			{
				Game.PrepareUnitOrders( order );
			}
		}	
	})();
}

// Tracks the left-button held state when moving.
function BeginMoveState()
{
	var order = {
		OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position : [0, 0, 0],
		Queue : false,
		ShowEffects : false
	};
	(function tic()
	{
		if ( GameUI.IsMouseDown( 0 ) )
		{
			$.Schedule( 1.0/30.0, tic );
			var mouseWorldPos = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition() );
			if ( mouseWorldPos !== null )
			{
				order.Position = mouseWorldPos;
				Game.PrepareUnitOrders( order );
			}
		}
	})();
}

// Handle Left Button events
function OnLeftButtonPressed()
{
	var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	var mouseEntities = GameUI.FindScreenEntities( GameUI.GetCursorPosition() );
	Msg("MouseEntities Length" + mouseEntities.length);
	// mouseEntities = mouseEntities.filter( function(e) { return e.entityIndex != localHeroIndex; } );
	var mouseTarget = null;

	if ( mouseEntities.length > 0)
	{
		for ( var e of mouseEntities )
		{
			if ( !e.accurateCollision )
				continue;
			mouseTarget = e.entityIndex;
		}
	}

	
		Msg("mouseTarget found! "+ mouseTarget);

	if (GameUI.IsShiftDown())
	{
		Msg("Shift is down! ");
		Msg(GameUI.GetCursorPosition());
	}
	if (GameUI.IsControlDown())
	{
		Msg("Control is down! ");
		Msg(GameUI.GetCursorPosition());
	}
}

// Handle Right Button events
function OnRightButtonPressed()
{
	
}



// Main mouse event callback
GameUI.SetMouseCallback( function( eventName, arg ) {
	var CONSUME_EVENT = true;
	var CONTINUE_PROCESSING_EVENT = false;
	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE)
		return CONTINUE_PROCESSING_EVENT;

	if ( eventName === "pressed" )
	{
		// Left-click is move to position or attack
		if ( arg === 0 )
		{
			OnLeftButtonPressed();
			return CONSUME_EVENT;
		}

		// Right-click is use ability #2
		if ( arg === 1 )
		{
			return CONTINUE_PROCESSING_EVENT;
		}
	}
	return CONTINUE_PROCESSING_EVENT;
} );


