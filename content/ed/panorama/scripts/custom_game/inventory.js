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
	var panelRoot = $( "#inventory_items" );
	
	// Brute-force recreate the entire inventory UI for now
	panelRoot.RemoveAndDeleteChildren();

	var hero = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );

	// Currently hardcoded: first 6 are inventory, next 6 are stash items
	for ( var i = 0; i < 6; ++i )
	{
		var item = Entities.GetItemInSlot( hero, i );

		UpdateInventoryItem( i, item, hero, panelRoot );
	}
}

(function()
{
	GameEvents.Subscribe( "dota_inventory_changed", UpdateInventory );
	GameEvents.Subscribe( "dota_inventory_item_changed", UpdateInventory );
	GameEvents.Subscribe( "m_event_dota_inventory_changed_query_unit", UpdateInventory );
	GameEvents.Subscribe( "m_event_keybind_changed", UpdateInventory );
	GameEvents.Subscribe( "player_hero_first_spawn", UpdateInventory );
	
	UpdateInventory(); // initial update
})();
