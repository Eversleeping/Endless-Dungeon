function print(s){ $.Msg(s); }

function UpdateTargetInfo()
{
	var idx = $.GetContextPanel().GetAttributeInt( "entindex", -1 );

	var h = Entities.GetHealth( idx );
	var mh = Entities.GetMaxHealth( idx );
	var m = Entities.GetMana( idx );
	var mm = Entities.GetMaxMana( idx );

	var sh = h;var smh = mh;
	if(h>100000){ sh = Math.floor(h/100)/10 + "k"; }
	if(h>100000000){ sh = Math.floor(h/100000)/10 + "m";}
	if(mh>100000){ smh = Math.floor(mh/100) / 10 + "k";}
	if(mh>100000000){ smh = Math.floor(mh/100000) / 10 + "m";}

	var ht = sh + " / " + smh;
	var mt = m + " / " + mm;

	$("#TargetHealthLabel").text = ht;
	$("#TargetManaLabel").text = mt;
	$("#TargetHealth").style.width = h/mh * 100 + "%";
	$("#TargetMana").style.width = m/mm * 100 + "%";

	$.Schedule( 0.1, UpdateTargetInfo );
}

function OnPlayerUpdateSelectedEntindex(a)
{
	print("OnPlayerUpdateSelectedEntindex");

	var root = $.GetContextPanel();
	if(root.BHasClass( "Hidden" ))
	{
		root.SetHasClass( "Hidden", false );
	}

	var idx = a.entindex;

	$("#TargetName").text=$.Localize( Entities.GetUnitName( idx ) );

	$.GetContextPanel().SetAttributeInt( "entindex", idx );
	
	UpdateTargetInfo();
}

GameEvents.Subscribe( "player_update_selected_entindex", OnPlayerUpdateSelectedEntindex );
UpdateTargetInfo();