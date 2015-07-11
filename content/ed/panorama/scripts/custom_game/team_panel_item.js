
function print(s){ $.Msg(s); }
function OnClickTeammate()
{
	var id = $.GetContextPanel().GetAttributeInt("nPlayerID", -1);
	var idx = Players.GetPlayerHeroEntityIndex( id );

	if ($.GetContextPanel().GetAttributeInt( "selected_index", -1 ) != idx )
		GameEvents.SendCustomGameEventToServer( "player_update_selected_target", {entindex:idx} );
	$.GetContextPanel().SetAttributeInt( "selected_index", idx );
}

var printed = false
function UpdateItem()
{
	var root = $.GetContextPanel();
	var id = root.GetAttributeInt( "nPlayerID", -1 );
	var idx = Players.GetPlayerHeroEntityIndex( id );

	var name = Entities.GetUnitName( idx );
	$("#HeroImage").heroname=name;

	var h = Entities.GetHealth( idx );
	var mh = Entities.GetMaxHealth( idx );
	var m = Entities.GetMana( idx );
	var mm = Entities.GetMaxMana( idx );

	var ht = h + "/" + mh;
	var mt = m + "/" + mm;

	$("#HealthLabel").text = ht;
	$("#ManaLabel").text = mt;
	$("#Health").style.width = h/mh * 100 + "%";
	$("#Mana").style.width = m/mm * 100 + "%";

	$.Schedule( 0.1, UpdateItem );
}

function SetPlayerName()
{
	var root = $.GetContextPanel();
	var id = root.GetAttributeInt( "nPlayerID", -1 );
	var pi = Game.GetPlayerInfo( id );
	if (pi == undefined ) { return; }
	$("#SteamID").steamid = pi.player_steamid;
}

(function()
{
	SetPlayerName();
	UpdateItem();
})();