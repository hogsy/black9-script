class B9_PDA_TopLevelMenu extends B9_MenuPDA_Menu;

var localized string 		fCampaignLabel;
var localized string 		fSkirmishLabel;
var localized string 		fOptionsLabel;
var localized string 		fQuitLabel;
var bool fRanOnce;

// Can be "SP" for single player, and "MP" for multiplayer. Will Jump there directly
var globalconfig string E3PlayMode;

var B9_CharacterManager fCharacterManager;
var localized font fMSA24Font;

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
		log( "E3PlayMode = " $ E3PlayMode );
		fReturnMenu = class'B9_PDA_TopLevelMenu';
		if( E3PlayMode == "SP" )
		{
			fPDABase.AddMenu( class'B9_PDA_SinglePlayerCharacterSelectSahara', None );
			return;
		}
		else if( E3PlayMode == "MP" )
		{
			fPDABase.AddMenu( class'E3_AccountLogon', None );
			return;
		}
		
		fRanOnce = true;
		
		//Blac
		indexpoint = 0;
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_TopLevelMenu';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = material'B9Menu_tex_std.title_left';
		fDisplayItems[indexpoint].fFocusImage = material'B9Menu_tex_std.title_left';
		fDisplayItems[indexpoint].fPercentTextureSizeX = 0.750f;
		fDisplayItems[indexpoint].fPercentTextureSizeY = 0.750f;
		fDisplayItems[indexpoint].fDrawPartialInfo=true;
		fDisplayItems[indexpoint].fCanAcceptFocus = false;
		fDisplayItems[indexpoint].fStartX = 100;
		displayitem_TopLevelMenu(fDisplayItems[indexpoint]).fItemToChange = 0;
		indexpoint = fDisplayItems.length;

		//k9
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_TopLevelMenu';
		fDisplayItems[indexpoint].fBaseImage = material'B9Menu_tex_std.title_right';
		fDisplayItems[indexpoint].fPercentTextureSizeX = 0.750f;
		fDisplayItems[indexpoint].fPercentTextureSizeY = 0.750f;
		fDisplayItems[indexpoint].fDrawPartialInfo=true;
		fDisplayItems[indexpoint].fCanAcceptFocus = false;
		//fDisplayItems[indexpoint].fStartX = 100;
		displayitem_TopLevelMenu(fDisplayItems[indexpoint]).fItemToChange = 1;
		indexpoint = fDisplayItems.length;

		//Campaign
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_TopLevelMenu';
		fDisplayItems[indexpoint].fLabel		= fCampaignLabel;
		fDisplayItems[indexpoint].fItemFont= fMSA24Font;
		fDisplayItems[indexpoint].fStartX = 160;
		displayitem_TopLevelMenu(fDisplayItems[indexpoint]).fNextMenuName = class'B9_PDA_SinglePlayerCharacterSelectSahara';
		displayitem_TopLevelMenu(fDisplayItems[indexpoint]).fItemToChange = 2;
		indexpoint = fDisplayItems.length;
		
		//Skrimish
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_TopLevelMenu';
		fDisplayItems[indexpoint].fLabel		= fSkirmishLabel;
		fDisplayItems[indexpoint].fItemFont		= fMSA24Font;
		fDisplayItems[indexpoint].fStartX = 160;
		displayitem_TopLevelMenu(fDisplayItems[indexpoint]).fNextMenuName = class'E3_AccountLogon';
		displayitem_TopLevelMenu(fDisplayItems[indexpoint]).fItemToChange = 3;
		indexpoint = fDisplayItems.length;

/*	dferrellNF Remove comment after E3!
		//Options
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_TopLevelMenu';
		fDisplayItems[indexpoint].fLabel		= fOptionsLabel;
		fDisplayItems[indexpoint].fItemFont		= fMSA24Font;
		displayitem_TopLevelMenu(fDisplayItems[indexpoint]).fNextMenuName = class'B9_PDA_VirtualKeyboard';
		displayitem_TopLevelMenu(fDisplayItems[indexpoint]).fItemToChange = 4;
		indexpoint = fDisplayItems.length;

		//Quit 
		if( IsPlatformPC() == true )//Quit is only available for PC!
		{
			fDisplayItems.Insert(indexpoint,1);
			fDisplayItems[indexpoint]				= new(None)class'displayitem_TopLevelMenu';
			fDisplayItems[indexpoint].fLabel		= fQuitLabel;
			fDisplayItems[indexpoint].fItemFont		= fMSA24Font;
			displayitem_TopLevelMenu(fDisplayItems[indexpoint]).fNextMenuName = None;
			fDisplayItems[indexpoint].fLabel		= fQuitLabel;				
			displayitem_TopLevelMenu(fDisplayItems[indexpoint]).fItemToChange = 5;
			indexpoint = fDisplayItems.length;
		}
*/
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
	fCampaignLabel="       Campaign"
	fSkirmishLabel="      Multiplayer"
	fOptionsLabel="       Options"
	fQuitLabel="         Quit"
	fMSA24Font=Font'B9_Fonts.MicroscanA24'
	fReturnMenu=Class'B9BasicTypes.B9_MenuPDA_Menu'
}