//=============================================================================
// PDA.uc
//
// PDA device. View mission objectives, other data
//
//=============================================================================



class PDA extends B9_Powerups;


var public transient B9_MenuInteraction fPDAScreen;

function Activate()
{
	local B9_BasicPlayerPawn	P;
	local PlayerController		pc;
 //   local B9_MenuInteraction	mi;

	P = B9_BasicPlayerPawn( Owner );
	if( P == None )
	{
		return;
	}

	P.TogglePDA();

	/*
	P = Pawn( Owner );
	pc = PlayerController( P.Controller );

	
	mi = new(None) class'B9_MenuInteraction';
	fPDAScreen = B9_MenuInteraction(mi.PushInteraction("B9Gear.PDAInteraction", pc, pc.Player));

	if( fPDAScreen != None )
	{
		Log("Created fPDAScreen");
	}
	else
	{
		Log("Failed to create fPDAScreen");
	}
	*/

	
}


defaultproperties
{
	fUniqueID=14
	bActivatable=true
	bDisplayableInv=true
	Icon=Texture'B9HUD_textures.Browser_items.gen_electrokit_bricon'
	ItemName="PDA"
	RemoteRole=0
}