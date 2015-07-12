var root = $.GetContextPanel();

function print(s){ $.Msg(s); }

function OnUpdateScreenTimer(args)
{
	var time = args.time;
	print("updating screen timer ", time);
	var p = $("#screen_center_timer");
	p.SetHasClass( "Hidden", false );
	p.text = time;
}

function OnDestroyScreenTimer()
{
	print("on order destroy screen timer");
	var p = $("#screen_center_timer");
	p.SetHasClass( "Hidden", true );
}

function OnFightEnd()
{
	$("#top_tooltip").text = $.Localize( "fight_is_over" );
	$("#top_tooltip").SetHasClass( "Hidden", false );
	$.Schedule( 2,function(){
		$("#top_tooltip").SetHasClass( "Hidden", true );
	})
}

GameEvents.Subscribe( "update_screen_timer", OnUpdateScreenTimer );
GameEvents.Subscribe( "destroy_screen_timer", OnDestroyScreenTimer );
GameEvents.Subscribe( "fight_end", OnFightEnd );
