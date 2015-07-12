function print(s){ $.Msg(s); }

function OnNewBoss(args)
{
	print("OnNewBoss");
	print(args);
	var n = $.CreatePanel( "Panel",$("#boss_list_panel"),"BossListRow" + args.name );
	n.SetAttributeString( "name", args.name );
	n.BLoadLayout( "file://{resources}/layout/custom_game/boss_list_item.xml", false, false );
}

function StartCountDown(time)
{
	print("Counting down "+ time);
	time = time - 1;
	if (time <= 0) {
		$("#boss_spawn_count_down_text").text="GO!";
		$.Schedule( 0.5, function() {$("#boss_spawn_count_down").SetHasClass( "Hidden", true ); })
		return;
	}
	if( $("#boss_spawn_count_down").BHasClass( "Hidden" )){
		$("#boss_spawn_count_down").SetHasClass( "Hidden", false );
	}
	$("#boss_spawn_count_down_text").text= time ;
	$.Schedule( 1, function(){ StartCountDown(time) });
}

GameEvents.Subscribe( "register_new_boss", OnNewBoss );
GameEvents.Subscribe( "boss_going_to_spawn", function(){
	$("#boss_list_panel").SetHasClass("Hidden", true);
	StartCountDown(10);
});

if (!($.GetContextPanel().BHasClass("BossUpdated")))
{
	GameEvents.SendCustomGameEventToServer( "client_query_boss_list", {} );
	$("#boss_list_panel").SetHasClass("Hidden", false);
	$.GetContextPanel().SetHasClass( "BossUpdated", true );
}
