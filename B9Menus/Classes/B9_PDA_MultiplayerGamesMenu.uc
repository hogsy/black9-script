class B9_PDA_MultiplayerGamesMenu extends B9_MenuPDA_Menu;

var localized string fCreateGameLabel;
var localized string fRefreshListLabel;
var int fCreateItem;
var B9MP_ServerBrowser fServerBrowser;
var B9MP_Client		   fClient;
var B9_CharacterManager fCharacterManager;
var bool	fRanOnce;

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

	Log("After Ranonce");
	fRanOnce = true;

	if ( IsPlatformXBox() )
	{
		onlinePkgNameSuffix = "XBox";
	}
	else
	{
		onlinePkgNameSuffix = "GameSpy";
	}
		 
	// Beacon for LAN games
	if ( fServerBrowser == None )
	{
		ForEach fPDABase.RootController.AllActors( class'B9MP_ServerBrowser', fServerBrowser )
		{
			break;
		}

		if ( fServerBrowser == None )
		{
			fServerBrowserClass = class<B9MP_ServerBrowser>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_ServerBrowser_" $ onlinePkgNameSuffix, class'Class'));

			fServerBrowser = fPDABase.RootController.Spawn( fServerBrowserClass );
		}
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

	if(fClient == None)
	{
		ForEach fPDABase.RootController.AllActors( class'B9MP_Client', fClient )
		{
			break;
		}
	} 

	//Host Option
	fDisplayItems.Insert(0,1);
	fDisplayItems[0]				= new(None)class'displayitem_HostSkirmish';	
	fDisplayItems[0].fLabel		= fCreateGameLabel;
	displayitem_HostSkirmish(fDisplayItems[0]).fCharacterManager = fCharacterManager;
}


function UpdateMenu( float Delta )
{
	local B9MP_ServerDescription ServerDesc;
	local LinkedListElement element;
	local displayitem_GenericMenuItem Item;
	local int indexpoint;

	Super.UpdateMenu( Delta );
	
	// Add or Maniuplate Dynanic Items
	
	// This sets up the server browser when the fuction is first run.
	if ( ! fRanOnce )
	{
		fRanOnce = true;
		Init();
	}

	if ( fServerBrowser.fServersDirty )
	{
		element = fServerBrowser.fServers.GetTop();


		while( element != None )
		{
			ServerDesc = B9MP_ServerDescription(element.fObject);

			indexpoint = fDisplayItems.length;

			fDisplayItems.Insert(indexpoint,1);
			fDisplayItems[indexpoint]				= new(None)class'displayitem_ServerMenuItem';
			log("fDisplayItems[indexpoint] ="$fDisplayItems[indexpoint]);
			
				
			//Add Server to list
			fDisplayItems[indexpoint].fLabel		= ServerDesc.fInfo.fName;
			displayitem_ServerMenuItem(fDisplayItems[indexpoint]).fServerDescription = ServerDesc;
			displayitem_ServerMenuItem(fDisplayItems[indexpoint]).fCharacterManager	 = fCharacterManager;
			displayitem_ServerMenuItem(fDisplayItems[indexpoint]).fClient = fClient;		
									
			element = element.fNext;
			ServerDesc = None;
		}

			//Refresh List Option
			fDisplayItems.Insert(indexpoint,1);
			fDisplayItems[indexpoint]				= new(None)class'displayitem_RefreshServerListItem';	
			fDisplayItems[indexpoint].fLabel		= fRefreshListLabel;
			
			//Clear the lists dirty status
			fServerBrowser.fServersDirty = false;
			fServerBrowser.fServers.Clear();
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
	fCreateGameLabel="Host Game"
	fRefreshListLabel="Refresh Server List"
}