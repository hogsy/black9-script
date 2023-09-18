class B9_PDA_HostOrJoinLanMenu extends B9_MenuPDA_Menu;

var B9MP_ServerBrowser fServerBrowser;
var localized string fHostLabel;
var localized string fJoinLabel;
var bool fRanOnce;

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
function UpdateMenu( float Delta )
{
	local int indexpoint;
	
	Super.UpdateMenu( Delta );
		
	if( fRanOnce == false )
	{
		fRanOnce = true;
		
		//Host
		indexpoint = 0;
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_GenericMenuItem';
		fDisplayItems[indexpoint].fLabel		= fHostLabel;
		displayitem_GenericMenuItem(fDisplayItems[indexpoint]).fMenuClass = class'B9_PDA_HostSkirmishOptionsMenu';
		
		indexpoint = fDisplayItems.length;
		
		//Join
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_GenericMenuItem';
		fDisplayItems[indexpoint].fLabel		= fJoinLabel;				
		displayitem_GenericMenuItem(fDisplayItems[indexpoint]).fMenuClass = class'B9_PDA_VirtualKeyboard';//class'B9_PDA_MultiplayerCreateBrowseList';		
		
		indexpoint = fDisplayItems.length;
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
	fHostLabel="Host"
	fJoinLabel="Join"
}