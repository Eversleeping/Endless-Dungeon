"use strict";

/* Action-RPG style input handling.

Left click moves or trigger ability 1.
Right click triggers ability 2.
*/

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
			if ( Entities.IsAlive( order.TargetIndex) && Abilities.IsCooldownReady( order.AbilityIndex ) && !Abilities.IsInAbilityPhase( order.AbilityIndex ) )
			{
				Game.PrepareUnitOrders( order );
			}
		}	
	})();
}

// Tracks the left-button helf when picking up an item.
function BeginPickUpState( targetEntIndex )
{
	var order = {
		OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_PICKUP_ITEM,
		TargetIndex : targetEntIndex,
		Queue : false,
		ShowEffects : false
	};
	(function tic()
	{
		if ( GameUI.IsMouseDown( 0 ) )
		{
			$.Schedule( 1.0/30.0, tic );
			if ( Entities.IsValidEntity( order.TargetIndex) )
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
	mouseEntities = mouseEntities.filter( function(e) { return e.entityIndex != localHeroIndex; } );

	var accurateEntities = mouseEntities.filter( function( e ) { return e.accurateCollision; } );
	if ( accurateEntities.length > 0 )
	{
		for ( var e of accurateEntities )
		{
			if ( Entities.IsItemPhysical( e.entityIndex ) )
			{
				BeginPickUpState( e.entityIndex )
			}
			else
			{
				BeginAttackState( e.entityIndex );
			}
			return;
		}
	}

	if ( mouseEntities.length > 0 )
	{
		var e = mouseEntities[0];
		if ( Entities.IsItemPhysical( e.entityIndex ) )
		{
			BeginPickUpState( e.entityIndex );
		}
		else
		{
			BeginAttackState( e.entityIndex );
		}
		return;
	}

	BeginMoveState();
}

// Handle Right Button events
function OnRightButtonPressed()
{
	var order = {
		OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex : Entities.GetAbility( Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ), 1 ),
		Queue : false,
		ShowEffects : false
	};
	Game.PrepareUnitOrders( order );
}

// Main mouse event callback
GameUI.SetMouseCallback( function( eventName, arg ) {
	var CONSUME_EVENT = true;
	var CONTINUE_PROCESSING_EVENT = false;
	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
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
			OnRightButtonPressed();
			return CONSUME_EVENT;
		}
	}
	if ( eventName === "doublepressed" )
	{
		return CONSUME_EVENT;
	}
	return CONTINUE_PROCESSING_EVENT;
} );

GameUI.SetCameraPitchMax( 55 );
GameUI.SetCameraDistance( 1234 );
