/////////////////////////////////////////////////////////////
// B9_MM_MultiPlayer_MatchOrCreateMenu
//
// 
// 
// This is CURRENTLY a debug menu.

class B9_MM_MultiPlayer_MatchOrCreateMenu extends B9_MM_SimpleListMenu;

var B9MP_Client fClient;

var localized string fQuickMatchLabel;
var localized string fOptiMatchLabel;
var localized string fOptiMatchLANLabel;
var localized string fCreateGameLabel;


// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentController. You don't have to implement MenuInit(),
// but you should call super.MenuInit().
function Initialized()
{
	fHasGoBack = true;

}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	Super.MenuInit( interaction, controller, parent );

	if(fClient == None)
	{
		ForEach controller.AllActors( class'B9MP_Client', fClient )
		{
			break;
		}
	}

	RefreshMenus();

	Super.Initialized();
}

function ClickItem()
{
	if ( fKeyDown == IK_Backspace)
	{
		fClient.Logout();

		Super.ClickItem();
		return;
	}

	switch(fSelItem)
	{
	case 0:
		// KMYNF: Need to have a QuickMatch menu
		Super.ClickItem();
		break;

	case 1:
		// KMYNF: Need to have a Server Browser menu
		Super.ClickItem();
		break;

	case 2:
		if ( IsPlatformXBox() )
		{
			if ( CreateGame() == 1 )
				fKeyDown = IK_None;
			else
			{
				//TODO : KMY: Note this doesn't work, since we're mixed with PDA, but immaterial, since this stuff is going away...
				fSelItem = -1;
				fKeyDown = IK_Backspace;
				fClient.Logout();
				Super.ClickItem();
			}
		}
		else
		{
			Super.ClickItem();
		}
		break;

	case 3:
		if ( ! IsPlatformXBox() )
		{
			if ( CreateGame() == 1 )
				fKeyDown = IK_None;
			else
			{
				//TODO : KMY: Note this doesn't work, since we're mixed with PDA, but immaterial, since this stuff is going away...
				fSelItem = -1;
				fKeyDown = IK_Backspace;
				fClient.Logout();
				Super.ClickItem();
			}
		}
		break;
		
	default:					
		Super.ClickItem();
	}
}

function int CreateGame( )
{
	local Pawn pawn;
	local Pawn oldPawn;
	local Actor A;
	local vector loc;
	local String URL;
	local String playerClass;
	local int i;
	i = 0;

	PopInteraction( RootController, RootController.Player );

	ForEach RootController.AllActors(class'Actor', A)
	{
		if ( A.Name == 'LookTarget8' )
		{
			loc = A.location;
			break;
		}
	}

	playerClass = fCharacterManager.GetSelectedClass();
	URL = "MPHQ?Listen" $ "?Class=" $ playerClass;
	URL = URL $ "?NAME=" $ MapSpecialChars(fClient.fClientDescription.fInfo.fName);

	pawn = RootController.spawn( class<Pawn>(DynamicLoadObject( playerClass, class'Class' ) ), , , loc );
	if ( pawn == None )
	{
		Log( "Cannot spawn player pawn [" $ playerClass $ "]" );
		return 0;
	}

	if ( RootController.pawn != None )
	{
		oldPawn = RootController.pawn;
		RootController.UnPossess();
		oldPawn.Destroy();
	}

	RootController.Possess(pawn);

	// Load player settings
	fCharacterManager.GetSelectedCharacter( RootController.Player );
	pawn = RootController.Player.Actor.Pawn;

	B9_PlayerPawn(pawn).SetMultiplayer();

	Log( "MP: SERVER OPEN [[" $ URL $ "]]" );

	RootController.ClientTravel( URL, TRAVEL_Absolute, true );
	return 1;
}

function RefreshMenus()
{
	local SimpleItemInfo info;
	local SimpleImageInfo img;
	local int x;
	local int y;
	local int yOffset;
	local int yImageOffset;
	local int i;

	x = 43;
	y = 281;
	yOffset = 40;
	yImageOffset = 60;

	if ( IsPlatformXBox() )
		fItemArray.Length = 3;
	else
		fItemArray.Length = 4;

	fItemArray[ 0 ].X = x;
	fItemArray[ 0 ].Y = y;
	fItemArray[ 0 ].Label = fQuickMatchLabel;
	y += yOffset;

	fItemArray[ 1 ].X = x;
	fItemArray[ 1 ].Y = y;
	fItemArray[ 1 ].Label = fOptiMatchLabel;
	y += yOffset;

	if ( IsPlatformXBox() )
	{
		fItemArray[ 2 ].X = x;
		fItemArray[ 2 ].Y = y;
		fItemArray[ 2 ].Label = fCreateGameLabel;
		y += yOffset;
	}
	else
	{
		fItemArray[ 2 ].X = x;
		fItemArray[ 2 ].Y = y;
		fItemArray[ 2 ].Label = fOptiMatchLANLabel;
		y += yOffset;

		fItemArray[ 3 ].X = x;
		fItemArray[ 3 ].Y = y;
		fItemArray[ 3 ].Label = fCreateGameLabel;
		y += yOffset;
	}

	y += yImageOffset;


	fImageArray.Length = 4;

	img.X = 64;
	img.Y = 203;
	img.Image = texture'B9Menu_Tex_std.mp_title_left';
	fImageArray[0] = img;

	img.X = 320;
	img.Y = 203;
	img.Image = texture'B9Menu_Tex_std.mp_title_right';
	fImageArray[1] = img;

	img.X = 64;
	img.Y = y;
	img.Image = texture'B9MenuHelp_Textures.choice_select';
	fImageArray[2] = img;

	img.X = 320;
	img.Y = y;
	img.Image = texture'B9MenuHelp_Textures.choice_back';
	fImageArray[3] = img;
}


defaultproperties
{
	fQuickMatchLabel="QuickMatch"
	fOptiMatchLabel="OptiMatch"
	fOptiMatchLANLabel="OptiMatch LAN"
	fCreateGameLabel="Create Game"
}