function print(s)
{
	$.Msg(s);
}

function CreateHealthPanelItem( id, idx )
{
	print("Create Health Panel for Player -> " + id + " <, The Hero Entity Index -> " + idx );

	var count = $.GetContextPanel().GetAttributeInt( "item_count", -1 );
	var parentPanel = $("#RaidFrameRow1");
	
	/* show me the panel*/
	if ($("#RaidFrameRow1").BHasClass( "Hidden" ))
	{
		print("show me the panel 1");
		$("#RaidFrameRow1").SetHasClass( "Hidden", false );
	}
	var count = $("#RaidFrameRow1").GetChildCount();
	if (count >= 5 )
	{
		parentPanel = $("#RaidFrameRow2"); 
		print("show me the panel 2");
		$("#RaidFrameRow2").SetHasClass( "Hidden", false ); 
	}

	/* gimme the item */
	print("creating item");
	var itemPanel = $.CreatePanel("Panel", parentPanel, "");
	itemPanel.SetAttributeInt("nPlayerID", id);
	itemPanel.SetAttributeInt( "nIndex", count );
	itemPanel.BLoadLayout( "file://{resources}/layout/custom_game/health_panel_item.xml", false, false );
}

function OnHeroSpawn(args)
{
	print("OnHeroSpawn == > ");
	print(args);
	
	if ($.GetContextPanel(  ).BHasClass( "Hidden" )){
		$.GetContextPanel(  ).SetHasClass( "Hidden", false );
	}

	var nPlayerID = args.PlayerID;
	var hPlayerHero = Players.GetPlayerHeroEntityIndex( nPlayerID );

	var count = $("#RaidFrameRow1").GetChildCount();

	CreateHealthPanelItem( nPlayerID, hPlayerHero );
}

(	function()
	{
		GameEvents.Subscribe( "player_hero_first_spawn", OnHeroSpawn );
	}
)();
