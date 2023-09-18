class B9_PDA_MultiplayerCreateBrowseList extends B9_MenuPDA_Menu;

var B9MP_ServerBrowser fServerBrowser;
var localized string fPleaseWaitLabel;
var localized string fCreateGameLabel;
var bool fRanOnce;
var bool fReallyRanOnlyOnce;
var B9_CharacterManager fCharacterManager;


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
		}else
		{
			return Super.handleKeyEvent( KeyIn , Action , Delta );
		}
	}
	return false;

}

function Init()
{
	local class<B9MP_ServerBrowser> fServerBrowserClass;
	local String onlinePkgNameSuffix;
	
	if ( IsPlatformXBox() )
	{
		onlinePkgNameSuffix = "XBox";
	}
	else
	{
		onlinePkgNameSuffix = "GameSpy";
	}

log("inside ranonce == false");
	// Beacon for LAN games
	if ( fServerBrowser == None )
	{
			ForEach fPDABase.RootController.AllActors( class'B9MP_ServerBrowser', fServerBrowser )
		{
			break;
		}

		if ( fServerBrowser != None )
		{
			fServerBrowser.Destroy();
			fServerBrowser = None;
		}

		fServerBrowserClass = class<B9MP_ServerBrowser>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_ServerBrowser_" $ onlinePkgNameSuffix, class'Class'));

		fServerBrowser = fPDABase.RootController.Spawn( fServerBrowserClass );
	}


Log( "serverbrowser=" $ fServerBrowser $ " and serverbrowser dirty = " $ fServerBrowser.fServersDirty );

	if ( fServerBrowser == None )
	{
		// KMYNF: What?
	}
	else
	{
		fServerBrowser.fLAN = true;//B9_MMInteraction( parent ).fLAN;

		if ( fServerBrowser.fLAN )
			Log( "KMY PDA: Wait Menu asking for LAN servers" );
		else
			Log( "KMY: Wait Menu asking for Internet servers" );

		fServerBrowser.Refresh();
	}

	// Characters
	if ( fCharacterManager == None )
	{
		ForEach fPDABase.RootController.AllActors( class'B9_CharacterManager', fCharacterManager )
		{
			break;
		}

		if ( fCharacterManager == None )
		{
			fCharacterManager = fPDABase.RootController.Spawn( class'B9_CharacterManager' );
		}
	}	

	AddSimpleDisplayItem(fPleaseWaitLabel);
}


function UpdateMenu( float Delta )
{
	local displayitem_GenericMenuItem Item;
	local int indexpoint;

	Super.UpdateMenu( Delta );

	// This sets up the server browser when the fuction is first run.
	if ( ! fRanOnce )
	{
		fRanOnce = true;
		Init();
	}

	if( fReallyRanOnlyOnce == false )
	{
		fReallyRanOnlyOnce = true;
		//Host Option
		indexpoint = 0;
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_HostSkirmish';	
		fDisplayItems[indexpoint].fLabel		= fCreateGameLabel;	
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fCharacterManager = fCharacterManager;
	}

	if ( fServerBrowser != none )
	{
		fServerBrowser.Tick( Delta );

		if ( fServerBrowser.fBrowseResult == kFailure )
		{
			//TODO : Should clear list of the "please wait" msg
			AddSimpleDisplayItem( fServerBrowser.fErrorMessage ); 
			fServerBrowser.fServersDirty = false;
			fServerBrowser.fBrowseResult = kSuccess;
		}

		if ( fServerBrowser.fServersDirty )
		{
			fPDABase.AddMenu( class'B9_PDA_MultiplayerGamesMenu', fReturnMenu ); //dferrellNF
		}
	}	
}

function Initialize()
{
	//Don't do anything requiring controllers here!
	// Initialized() must be implemented in any subclass, but it can do nothing.
	// It is called before MenuInit() and can't refer to RootInteraction,
	// RootController or ParentInteraction. You don't have to implement MenuInit(),
	// but you should call super.MenuInit() if you do.	
}


defaultproperties
{
	fPleaseWaitLabel="Or please wait..."
	fCreateGameLabel="Host Game"
}