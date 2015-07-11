"use strict";

function UpdateItem()
{
	var item = $.GetContextPanel().GetAttributeInt( "item", -1 );
	var queryUnit = $.GetContextPanel().GetAttributeInt( "queryUnit", -1 );
	var itemName = Abilities.GetAbilityName( item );
	var hotkey = Abilities.GetKeybind( item, queryUnit );
	var chargeCount = 0;
	var hasCharges = false;
	var altChargeCount = 0;
	var hasAltCharges = false;
	
	if ( Items.ShowSecondaryCharges( item ) )
	{
		// Ward stacks display charges differently depending on their toggle state
		hasCharges = true;
		hasAltCharges = true;
		if ( Abilities.GetToggleState( item ) )
		{
			chargeCount = Items.GetCurrentCharges( item );
			altChargeCount = Items.GetSecondaryCharges( item );
		}
		else
		{
			altChargeCount = Items.GetCurrentCharges( item );
			chargeCount = Items.GetSecondaryCharges( item );
		}
	}
	else if ( Items.ShouldDisplayCharges( item ) )
	{
		hasCharges = true;
		chargeCount = Items.GetCurrentCharges( item );
	}

	$.GetContextPanel().SetHasClass( "show_charges", hasCharges );
	$.GetContextPanel().SetHasClass( "show_alt_charges", hasAltCharges );
	
	$( "#HotkeyText" ).text = hotkey;
	$( "#ItemImage" ).itemname = itemName;
	$( "#ItemImage" ).contextEntityIndex = item;
	$( "#ChargeCount" ).text = chargeCount;
	$( "#AltChargeCount" ).text = altChargeCount;
	
	if ( item == -1 || Abilities.IsCooldownReady( item ) )
	{
		$.GetContextPanel().SetHasClass( "cooldown_ready", true );
		$.GetContextPanel().SetHasClass( "in_cooldown", false );
	}
	else
	{
		$.GetContextPanel().SetHasClass( "cooldown_ready", false );
		$.GetContextPanel().SetHasClass( "in_cooldown", true );
		var cooldownLength = Abilities.GetCooldownLength( item );
		var cooldownRemaining = Abilities.GetCooldownTimeRemaining( item );
		var cooldownPercent = Math.ceil( 100 * cooldownRemaining / cooldownLength );
		$( "#CooldownTimer" ).text = Math.ceil( cooldownRemaining );
		$( "#CooldownOverlay" ).style.width = cooldownPercent+"%";
	}
	
	$.Schedule( 0.1, UpdateItem );
}

function ItemShowTooltip()
{
	var item = $.GetContextPanel().GetAttributeInt( "item", -1 );
	var queryUnit = $.GetContextPanel().GetAttributeInt( "queryUnit", -1 );
	if ( item == -1 )
		return;

	var itemName = Abilities.GetAbilityName( item );
	$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", $.GetContextPanel(), itemName, queryUnit );
}

function ItemHideTooltip()
{
	$.DispatchEvent( "DOTAHideAbilityTooltip", $.GetContextPanel() );
}

function ActivateItem()
{
	var item = $.GetContextPanel().GetAttributeInt( "item", -1 );
	var queryUnit = $.GetContextPanel().GetAttributeInt( "queryUnit", -1 );
	if ( item == -1 )
		return;

	// Items are abilities - just execute the ability
	Abilities.ExecuteAbility( item, queryUnit, false );
}

function DoubleClickItem()
{
	var item = $.GetContextPanel().GetAttributeInt( "item", -1 );
	var queryUnit = $.GetContextPanel().GetAttributeInt( "queryUnit", -1 );
	if ( item == -1 )
		return;

	// Items are abilities
	Abilities.CreateDoubleTapCastOrder( item, queryUnit );
}

function RightClickItem()
{
	// Not yet!
	$.Msg( "Context menu not implemented." );
}

function OnDragEnter( a, draggedPanel )
{
	var item = $.GetContextPanel().GetAttributeInt( "item", -1 );
	var draggedItem = draggedPanel.GetAttributeInt( "drag_item", -1 );

	// only care about dragged items other than us
	if ( draggedItem == -1 || draggedItem == item )
		return true;

	// highlight this panel as a drop target
	$.GetContextPanel().AddClass( "potential_drop_target" );
	return true;
}

function OnDragDrop( panelId, draggedPanel )
{
	var item = $.GetContextPanel().GetAttributeInt( "item", -1 );
	var thisSlot = $.GetContextPanel().GetAttributeInt( "itemSlot", -1 );
	var draggedItem = draggedPanel.GetAttributeInt( "drag_item", -1 );
	
	// only care about dragged items other than us
	if ( draggedItem == -1 || ( draggedItem == item ) )
		return true;

	// executing a slot swap - don't drop on the world
	draggedPanel.SetAttributeInt( "drag_completed", 1 );

	// create the order
	var moveItemOrder =
	{
		OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_ITEM,
		TargetIndex: thisSlot,
		AbilityIndex: draggedItem
	};
	Game.PrepareUnitOrders( moveItemOrder );
	return true;
}

function OnDragLeave( panelId, draggedPanel )
{
	var item = $.GetContextPanel().GetAttributeInt( "item", -1 );
	var draggedItem = draggedPanel.GetAttributeInt( "drag_item", -1 );
	if ( draggedItem == -1 || draggedItem == item )
		return false;

	// un-highlight this panel
	$.GetContextPanel().RemoveClass( "potential_drop_target" );
	return true;
}

function OnDragStart( panelId, dragCallbacks )
{
	var item = $.GetContextPanel().GetAttributeInt( "item", -1 );
	var itemName = Abilities.GetAbilityName( item );

	ItemHideTooltip(); // tooltip gets in the way

	// create a temp panel that will be dragged around
	var displayPanel = $.CreatePanel( "DOTAItemImage", $.GetContextPanel(), "dragImage" );
	displayPanel.itemname = itemName;
	displayPanel.contextEntityIndex = item;
	displayPanel.SetAttributeInt( "drag_item", item );
	displayPanel.SetAttributeInt( "drag_completed", 0 ); // determines whether the drag was successful

	// hook up the display panel, and specify the panel offset from the cursor
	dragCallbacks.displayPanel = displayPanel;
	dragCallbacks.offsetX = 0;
	dragCallbacks.offsetY = 0;
	
	// grey out the source panel while dragging
	$.GetContextPanel().AddClass( "dragging_from" );
	return true;
}

function OnDragEnd( panelId, draggedPanel )
{
	var item = $.GetContextPanel().GetAttributeInt( "item", -1 );
	var queryUnit = $.GetContextPanel().GetAttributeInt( "queryUnit", -1 );

	// if the drag didn't already complete, then try dropping in the world
	if ( !draggedPanel.GetAttributeInt( "drag_completed", 0 ) )
	{
		Game.DropItemAtCursor( queryUnit, item );
	}

	// kill the display panel
	draggedPanel.DeleteAsync( 0 );

	// restore our look
	$.GetContextPanel().RemoveClass( "dragging_from" );
	return true;
}

(function()
{
	// Drag and drop handlers ( also requires 'draggable="true"' in your XML, or calling panel.SetDraggable(true) )
	$.RegisterEventHandler( 'DragEnter', $.GetContextPanel(), OnDragEnter );
	$.RegisterEventHandler( 'DragDrop', $.GetContextPanel(), OnDragDrop );
	$.RegisterEventHandler( 'DragLeave', $.GetContextPanel(), OnDragLeave );
	$.RegisterEventHandler( 'DragStart', $.GetContextPanel(), OnDragStart );
	$.RegisterEventHandler( 'DragEnd', $.GetContextPanel(), OnDragEnd );

	UpdateItem(); // initial update of dynamic state
})();
