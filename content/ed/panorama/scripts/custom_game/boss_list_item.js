function print(s){ $.Msg(s); }

var votedDifficulty = null;

function OnSelectDifficultyNormal(){
	if (votedDifficulty == "n"){
		$.DispatchEvent( "DOTAShowTextTooltip",$.Localize( "dont_click_too_fast" ) );
		$.Schedule(1, function() { $.DispatchEvent( "DOTAHideTextTooltip" )} );
		return;
	}
	votedDifficulty = "n";
	GameEvents.SendCustomGameEventToServer( "player_vote_next_boss", {
		name:$.GetContextPanel().GetAttributeString( "name", "unknown" ),
		difficulty:"n"
	})
}

function OnSelectDifficultyHero(){

	if (votedDifficulty == "h") {
		$.DispatchEvent( "DOTAShowTextTooltip",$.Localize( "dont_click_too_fast" ) );
		$.Schedule(1, function() { $.DispatchEvent( "DOTAHideTextTooltip" )} );
		return;
	}
	votedDifficulty = "h";
	GameEvents.SendCustomGameEventToServer( "player_vote_next_boss", {
		name:$.GetContextPanel().GetAttributeString( "name", "unknown" ),
		difficulty:"h"
	})
}

// player_vote_next_boss
(function(){
	var name = $.GetContextPanel().GetAttributeString( "name", "unknown" );
	print(name);
	$("#background_image").SetImage( "file://{resources}/images/custom_game/" + name + ".png" );
	$("#boss_name_label").text = $.Localize( name );


})();