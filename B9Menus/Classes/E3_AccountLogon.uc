/////////////////////////////////////////////////////////////
// B9_MM_MultiPlayer_AccountListMenu
//
// Player must choose which user account they wish to use in Multiplayer.
// They can also create/delete these user accounts here.
// This is CURRENTLY a debug menu.

class E3_AccountLogon extends B9_MenuPDA_Menu;

var localized string fLogonFailedLabel;
var localized string fWaitForLogonToFinish;

var B9MP_Client fClient;
var B9MP_ClientDescription fClientDesc;
var B9MP_ClientManager fClientManager;

var localized font fMSA24Font;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentController. You don't have to implement MenuInit(),
// but you should call super.MenuInit().
function Init()
{
	local class<B9MP_ClientManager> fClientManagerClass;
	local class<B9MP_Client> fClientClass;
	local String onlinePkgNameSuffix;
	local int fRandomName;
	local Controller C;
	local LinkedListElement element;

	if ( IsPlatformXBox() )
	{
		onlinePkgNameSuffix = "XBox";
	}
	else
	{
		onlinePkgNameSuffix = "GameSpy";
	}

	// Create a B9MP_Client class if necessary
	if ( fClient == None )
	{
		ForEach fPDABase.RootController.AllActors( class'B9MP_Client', fClient )
		{
			break;
		}
		
		if ( fClient == None )
		{
			fClientClass = class<B9MP_Client>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_Client_" $ onlinePkgNameSuffix, class'Class'));
			if(fClientClass == None)
			{
				Log( "Failed to create fClientClass" );
			}
			fClient = fPDABase.RootController.Spawn( fClientClass );
			if( fClient == None )
			{
				Log( "Failed to spawn fClientClass" );		
			}
		}
	}

	// If this is PC, go to next menu immediately,
	// and so we don't need to read account list
	if ( ! IsPlatformXBox() )
	{
		fRandomName = RandRange(0, 25000);
		fClient.fClientDescription.fInfo.fName = ""$ fRandomName;//KYMF;

		// Set the actual player's name
		for ( C = fPDABase.RootController.Level.ControllerList; C != None; C = C.NextController )
			if ( C.IsA( 'PlayerController' ) && (Viewport( PlayerController( C ).Player ) != None ) )
			{
				PlayerController( C ).PlayerReplicationInfo.SetPlayerName( fClient.fClientDescription.fInfo.fName );
				break;
			}

		return;
	}

	// For XBox, read account names 
	if ( fClientManager == None )
	{
		ForEach fPDABase.RootController.AllActors( class'B9MP_ClientManager', fClientManager )
		{
			break;
		}
		
		if ( fClientManager == None )
		{
			fClientManagerClass = class<B9MP_ClientManager>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_ClientManager_" $ onlinePkgNameSuffix, class'Class'));

			if(fClientManagerClass == None)
			{
				Log( "Failed to create fClientManagerClass" );
			}
			fClientManager = fPDABase.RootController.Spawn( fClientManagerClass );			
			if(fClientManager == None)
			{
				Log( "Failed to create fClientManager" );
			}
		}
	}

	// Initialize description and start login process
	element = fClientManager.fClients.GetTop();
	if ( element != None )
	{
		fClientDesc = B9MP_ClientDescription(element.fObject);
	}
	else
	{
		fClientDesc = None;
	}

	if ( fClientDesc != None )
	{
		fClient.fClientDescription.fInfo.fName	   = fClientDesc.fInfo.fName;
		fClient.fClientDescription.fInfo.fNickName = fClientDesc.fInfo.fNickName;
		fClient.fClientDescription.fInfo.fPassword = fClientDesc.fInfo.fPassword;

		fClient.Login();
	}

	// Show the wait message
	Log("XT: Adding wait message to menu...");
	fDisplayItems.Insert(0,1);
	fDisplayItems[0] = new(None)class'displayitem_GenericMenuItem';
	fDisplayItems[0].fLabel		= fWaitForLogonToFinish;
	fDisplayItems[0].fCanAcceptFocus = false;
	fDisplayItems[0].fItemFont = fMSA24Font;
	displayitem_GenericMenuItem(fDisplayItems[0]).fMenuClass = class'E3_PDA_MultiplayerCharacterSelect';
	Log("XT: Menu displayitem list size: " $ fDisplayItems.length );
}

function UpdateMenu( float Delta )
{
	// This sets up the server browser when the fuction is first run.
	if ( fClient == None )
	{
		Init();
	}

	// If this is PC, go to next menu immediately
	if ( ! IsPlatformXBox() )
	{
		// Go to next menu
		fPDABase.AddMenu( class'E3_PDA_MultiplayerCharacterSelect', class'B9_PDA_TopLevelMenu' );
		return;
	}

	// If fClient is still None after "Init",
	// something is wrong. Try again later
	if ( fClient == None )
	{
		return;
	}

	if ( fClient.fLoggedIn )
	{
		Log("Login completed.");
		fPDABase.AddMenu( class'E3_PDA_MultiplayerCharacterSelect', class'B9_PDA_TopLevelMenu' );
		return;
	}
	
	if ( fClient.fLoginResult == kFailure )
	{
		fDisplayItems[0].fLabel		= fLogonFailedLabel;
	}
}

function bool handleKeyEvent(Interactions.EInputKey KeyIn,out Interactions.EInputAction Action, float Delta)
{
	local Interaction.EInputKey Key;
	Key = fPDABase.ConvertJoystick(KeyIn);

	if (fByeByeTicks == 0.0f)
	{
		if ( Key == IK_Joy3 )
		{
			// Must be filled out in the custom menu
		}else if (Key == IK_Joy4 )
		{
			// Must be filled out in the custom menu
		}else if( (Key == IK_Enter || Key == IK_Space || Key == IK_LeftMouse ||
			Key == IK_Joy1) )
		{
			// Absorb this key stroke
		}else
		{
			return Super.handleKeyEvent( KeyIn , Action , Delta );
		}
	}
	return false;

}

defaultproperties
{
	fLogonFailedLabel="Logon Failed"
	fWaitForLogonToFinish="Logging on to server..."
	fMSA24Font=Font'B9_Fonts.MicroscanA24'
}