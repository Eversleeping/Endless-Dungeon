function print(s){ $.Msg(s); }

function OnNewBoss(args)
{
	print("OnNewBoss");
	print(args);
	var n = $.CreatePanel( "Panel",$("#boss_list_panel"),"BossListRow" + args.name );
	n.SetAttributeString( "name", args.name );
	n.BLoadLayout( "file://{resources}/layout/custom_game/boss_list_item.xml", false, false );
}



GameEvents.Subscribe( "register_new_boss", OnNewBoss );

GameEvents.Subscribe( "boss_going_to_spawn", function(){
	$("#boss_list_panel").SetHasClass("Hidden", true);
});

if (!($.GetContextPanel().BHasClass("BossUpdated")))
{
	GameEvents.SendCustomGameEventToServer( "client_query_boss_list", {} );
	$("#boss_list_panel").SetHasClass("Hidden", false);
	$.GetContextPanel().SetHasClass( "BossUpdated", true );
}
