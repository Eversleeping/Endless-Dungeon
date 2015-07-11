"use strict";

function UpdateInventoryItem( itemSlot, item, queryUnit, parentPanel )
{
	var abilityPanel = $.CreatePanel( "Panel", parentPanel, "" );
	abilityPanel.SetAttributeInt( "itemSlot", itemSlot );
	abilityPanel.SetAttributeInt( "item", item );
	abilityPanel.SetAttributeInt( "queryUnit", queryUnit );
	abilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/inventory_item.xml", false, false );
}

function UpdateInventory()
{
	var stashPanel = $( "#stash_row" );
	if ( !stashPanel )
		return;

	var firstRowPanel = $( "#inventory_row_1" );
	if ( !firstRowPanel )
		return;

	var secondRowPanel = $( "#inventory_row_2" );
	if ( !secondRowPanel )
		return;

	// Brute-force recreate the entire inventory UI for now
	stashPanel.RemoveAndDeleteChildren();
	firstRowPanel.RemoveAndDeleteChildren();
	secondRowPanel.RemoveAndDeleteChildren();

	var queryUnit = Players.GetLocalPlayerPortraitUnit();

	// Currently hardcoded: first 6 are inventory, next 6 are stash items
	var DOTA_ITEM_STASH_MIN = 6;
	var DOTA_ITEM_STASH_MAX = 12;
	for ( var i = 0; i < DOTA_ITEM_STASH_MAX; ++i )
	{
		var item = Entities.GetItemInSlot( queryUnit, i );
	
		if ( i >= DOTA_ITEM_STASH_MIN )
		{
			UpdateInventoryItem( i, item, queryUnit, stashPanel );
		}
		else if ( i > 2 )
		{
			UpdateInventoryItem( i, item, queryUnit, secondRowPanel );
		}
		else
		{
			UpdateInventoryItem( i, item, queryUnit, firstRowPanel );
		}
	}
}

(function()
{
	GameEvents.Subscribe( "dota_inventory_changed", UpdateInventory );
	GameEvents.Subscribe( "dota_inventory_item_changed", UpdateInventory );
	GameEvents.Subscribe( "m_event_dota_inventory_changed_query_unit", UpdateInventory );
	GameEvents.Subscribe( "m_event_keybind_changed", UpdateInventory );
	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateInventory );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateInventory );
	
	UpdateInventory(); // initial update
})();
