/////////////////////////////////////////////////////////////
// B9_MM_MultiPlayer_Wait4LoginMenu
//
// 
// 
// This is CURRENTLY a debug menu.

class B9_MM_MultiPlayer_Wait4LoginMenu extends B9_MM_SimpleListMenu;

var B9MP_Client fClient;

var localized string fPleaseWaitLabel;
var localized string fLoginFailureLabel;


var bool fFinished;


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
	local class<B9MP_Client> fClientClass;
	local String onlinePkgNameSuffix;
	
	if ( IsPlatformXBox() )
	{
		onlinePkgNameSuffix = "XBox";
	}
	else
	{
		onlinePkgNameSuffix = "GameSpy";
	}

	fFinished = false;

	Super.MenuInit( interaction, controller, parent );

	if ( fClient == None )
	{
		ForEach controller.AllActors( class'B9MP_Client', fClient )
		{
			break;
		}

		if ( fClient == None )
		{
			fClientClass = class<B9MP_Client>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_Client_" $ onlinePkgNameSuffix, class'Class'));
			fClient = Controller.Spawn( fClientClass );
		}
	}

	RefreshMenus();

	Super.Initialized();
}

function ClickItem()
{
	if ( ( fSelItem == 0 ) && fFinished )
	{
		fSelItem = -1;
	}

	Super.ClickItem();
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

	fItemArray.Length = 1;

	fItemArray[ 0 ].X = x;
	fItemArray[ 0 ].Y = y;

	if ( ! fClient.fLoggedIn )
	{
		if ( fClient.fLoginResult == kFailure )
		{
			fItemArray[ 0 ].Label = fLoginFailureLabel;		// fClient.fErrorMessage
		}
		else
		{
			fItemArray[ 0 ].Label = fPleaseWaitLabel;
		}
	}

	y += yOffset;
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

function Tick(float Delta)
{
	if ( fClient.fLoggedIn )
	{
		fFinished = true;
		Log( " *******************Logged in**************** ");
		B9_MMInteraction(ParentInteraction).EndMenu(self, 0);
		return;
	}
	
	if ( fClient.fLoginResult == kFailure )
	{
		fFinished = true;
		Log( "KMY: Error logging in: " $ fClient.fErrorMessage );
		fClient.fLoginResult = kSuccess;
		return;
	}

	Super.Tick( Delta );
}

defaultproperties
{
	fPleaseWaitLabel="Please wait..."
	fLoginFailureLabel="Login failed"
}