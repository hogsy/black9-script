class E3_PDA_MultiplayerCharacterSelect extends B9_MenuPDA_Menu;
var localized string		fCharacterSelect;
var localized string 		fJakeLabel;
var localized string 		fSaharaLabel;
var localized string 		fBobLabel;
var localized string 		fAlice;
var localized string 		fTed;
var localized string 		fAnnie;
var localized font			fMSA24Font;
var localized font			fMSA20Font;

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

		//Character Select
		indexpoint = 0;
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'E3_displayitem_MultiplayerCharacterSelect';
		fDisplayItems[indexpoint].fLabel		= fCharacterSelect;
		fDisplayItems[indexpoint].fCanAcceptFocus = false;
		fDisplayItems[indexpoint].fItemFont=fMSA24Font;
		E3_displayitem_MultiplayerCharacterSelect(fDisplayItems[indexpoint]).fItemToChange = -1;
		indexpoint = fDisplayItems.length;

		//Sahara
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'E3_displayitem_MultiplayerCharacterSelect';
		fDisplayItems[indexpoint].fLabel		= fSaharaLabel;
//		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;
		fDisplayItems[indexpoint].fItemFont=fMSA20Font;
		E3_displayitem_MultiplayerCharacterSelect(fDisplayItems[indexpoint]).fItemToChange = 0;
		indexpoint = fDisplayItems.length;

		//Jake
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'E3_displayitem_MultiplayerCharacterSelect';
		fDisplayItems[indexpoint].fLabel		= fJakeLabel;
//		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;
		fDisplayItems[indexpoint].fItemFont=fMSA20Font;
		E3_displayitem_MultiplayerCharacterSelect(fDisplayItems[indexpoint]).fItemToChange = 1;
		indexpoint = fDisplayItems.length;

		//Alice
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'E3_displayitem_MultiplayerCharacterSelect';
		fDisplayItems[indexpoint].fLabel		= fAlice;
//		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;
		fDisplayItems[indexpoint].fItemFont=fMSA20Font;
		E3_displayitem_MultiplayerCharacterSelect(fDisplayItems[indexpoint]).fItemToChange = 2;
		indexpoint = fDisplayItems.length;

		//Bob
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'E3_displayitem_MultiplayerCharacterSelect';
		fDisplayItems[indexpoint].fLabel		= fBobLabel;
//		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;
		fDisplayItems[indexpoint].fItemFont=fMSA20Font;
		E3_displayitem_MultiplayerCharacterSelect(fDisplayItems[indexpoint]).fItemToChange = 3;
		indexpoint = fDisplayItems.length;

		//Annie
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'E3_displayitem_MultiplayerCharacterSelect';
		fDisplayItems[indexpoint].fLabel		= fAnnie;
//		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;
		fDisplayItems[indexpoint].fItemFont=fMSA20Font;
		E3_displayitem_MultiplayerCharacterSelect(fDisplayItems[indexpoint]).fItemToChange = 4;
		indexpoint = fDisplayItems.length;

		//Ted
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'E3_displayitem_MultiplayerCharacterSelect';
		fDisplayItems[indexpoint].fLabel		= fTed;
//		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;
		fDisplayItems[indexpoint].fItemFont=fMSA20Font;
		E3_displayitem_MultiplayerCharacterSelect(fDisplayItems[indexpoint]).fItemToChange = 5;
		indexpoint = fDisplayItems.length;

		/*
		//CREATE
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'E3_displayitem_MultiplayerCharacterSelect';
		fDisplayItems[indexpoint].fLabel		= "CREATE";
//		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;
		fDisplayItems[indexpoint].fItemFont=fMSA20Font;
		E3_displayitem_MultiplayerCharacterSelect(fDisplayItems[indexpoint]).fItemToChange = 6;
		indexpoint = fDisplayItems.length;
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
	fCharacterSelect="Character Select"
	fJakeLabel="Jake - assault rifle"
	fSaharaLabel="Sahara - 9mm"
	fBobLabel="Buck - shotgun"
	fAlice="Amanda - flame thrower"
	fTed="Slate - 9mm"
	fAnnie="Clare - magnum"
	fMSA24Font=Font'B9_Fonts.MicroscanA24'
	fMSA20Font=Font'B9_Fonts.MicroscanA20'
	fReturnMenu=Class'B9BasicTypes.B9_MenuPDA_Menu'
}