//=============================================================================
// B9_MainMenuController
//
// PlayerControllers are used by human players to control pawns.
//
// 
//=============================================================================

class B9_MainMenuController extends PlayerController;

var public B9_MMInteraction		B9MM;
var bool						interactionSetup;
var string						fPackageName;
var class<B9_MenuInteraction>	MyMenuClass;
var class<B9_MenuInteraction>	MyFactoryClass;

event PostBeginPlay()
{
	super.PostBeginPlay();
}

event NotifyLevelChange()
{
	local B9_MenuInteraction mi;
	local MenuUtility utils;

	mi = new(None) MyFactoryClass;
	mi.PopAllB9MenuInteractions(self, Player);
	//delete mi;

	utils = new(None) class'MenuUtility';
	utils.DirectAxisEnable(self, true);
}

function AddMMInteraction()
{
	local B9_MenuInteraction mi;

	interactionSetup = true;

	mi = new(None) MyFactoryClass;
	B9MM = B9_MMInteraction(mi.PushInteraction(MyMenuClass, self, Player));
	//delete mi;
	if (B9MM != None)
		Log( "B9_MainMenuController - adding interaction" );
	else
		Log( "B9_MainMenuController - bad interaction" );
}

event PlayerTick(float Delta)
{
	local bool inSetup;

	inSetup = false;
	if (!interactionSetup)
	{
		inSetup = true;
		AddMMInteraction();
	}

	Super.PlayerTick(Delta);

	if (inSetup)
	{
		//SetDummyPlayer();
		B9MM.startingViewTarget = ViewTarget;
	}

	BehindView( false );
}


function SetDummyPlayer()
{
	local Pawn newPawn, oldPawn;
	local vector loc;
	local Actor A;

	Log( "B9_MainMenuController.SetDummyPlayer - changing the pawn" );

	ForEach AllActors(class'Actor', A)
	{
		if ( A.Name == 'LookTarget8' )
		{
			loc = A.location;
			loc.Y += 80.f;
			break;
		}
	}

	newPawn = spawn(class<Pawn>(DynamicLoadObject("B9Characters.B9_dummy_player", class'Class')), , , loc);
	if ( newPawn != None )
	{
		if ( pawn != None )
		{
			Log( "B9_MainMenuController.SetDummyPlayer - doing unpossess" );

			oldPawn = pawn;
			UnPossess();
			oldPawn.Destroy();
		}

		Log( "B9_MainMenuController.SetDummyPlayer - doing possess" );

		Possess(newPawn);
	}
}

defaultproperties
{
	MyMenuClass=Class'B9_MMInteraction'
	MyFactoryClass=Class'B9BasicTypes.B9_MenuInteraction'
}