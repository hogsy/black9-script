class B9_PDA_VirtualKeyboard extends B9_MenuPDA_Menu;

var localized string fDoneLabel;
var localized string fClearAllLabel;
var localized string fBackspaceLabel;
var bool fRanOnce;
var B9MP_Client fClient;
var int	fItemWeAreChanging;
var bool fShiftDown;
var bool fCtrlKeyDown;
//var B9_CharacterManager fCharacterManager;
var int kTotalKeyCount;
var string fKeyLabelName;
var private string fKeyList;
var localized font fMSA16Font;

/*
**	Note about Gamespy Character Nick Names: Names must be 20 characters or less
**  and start with a letter 
**  and only contain characters and numbers.
*/
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
	local int keyCount;

	Super.UpdateMenu( Delta );
		
	if( fRanOnce == false )
	{
		fRanOnce = true;
		
		if ( fClient == None )
		{
			ForEach fPDABase.RootController.AllActors( class'B9MP_Client', fClient )
			{
				break;
			}
			
			if ( fClient == None )
			{
				Log( "Failed to find fClient" );
			}
		}
		
		for( keyCount = 0; keyCount < kTotalKeyCount; ++keyCount )
		{
			fKeyLabelName = Mid(fKeyList, keyCount, 1);
			indexpoint = keyCount;
			fDisplayItems.Insert(indexpoint,1);
			fDisplayItems[indexpoint]				= new(None)class'displayitem_VirtualKeyboard';
			fDisplayItems[indexpoint].fLabel = fKeyLabelName;
			displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = keyCount;
			displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
			displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).myDad = self;

			if( ( keyCount + 1 ) % 11 == 0 && keyCount != 0 || ( keyCount == (kTotalKeyCount - 1) ) )
					fDisplayItems[indexpoint].fDrawNextItemTotheRight = false;

			indexpoint = fDisplayItems.length;
		}


		//Done
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_VirtualKeyboard';
		fDisplayItems[indexpoint].fLabel = fDoneLabel;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.key2_static';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.key2_static';
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 65;		
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).myDad = self;						
		
		indexpoint = fDisplayItems.length;	
		
		//ClearAll
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_VirtualKeyboard';
		fDisplayItems[indexpoint].fLabel = fClearAllLabel;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.key2_static';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.key2_static';
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 66;		
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fClient = fClient;				
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).myDad = self;
			
		indexpoint = fDisplayItems.length;	
		
		//Backspace
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_VirtualKeyboard';
		fDisplayItems[indexpoint].fLabel = fBackspaceLabel;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.key2_static';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.key2_static';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = false;
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 67;		
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fClient = fClient;				
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).myDad = self;
			
		indexpoint = fDisplayItems.length;

		
		//Display Email Address	
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_VirtualKeyboard';
		fDisplayItems[indexpoint].fItemFont = fMSA16Font;
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		fDisplayItems[indexpoint].fBaseImage = None;
		fDisplayItems[indexpoint].fFocusImage = None;
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = false;
		fDisplayItems[indexpoint].fTextColor.R=185;
		fDisplayItems[indexpoint].fTextColor.G=169;
		fDisplayItems[indexpoint].fTextColor.B=93;
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 1001;		
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).myDad = self;
		indexpoint = fDisplayItems.length;		

		//Password Name	
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_VirtualKeyboard';
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		fDisplayItems[indexpoint].fBaseImage = None;
		fDisplayItems[indexpoint].fFocusImage = None;
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = false;
		fDisplayItems[indexpoint].fTextColor.R=185;
		fDisplayItems[indexpoint].fTextColor.G=169;
		fDisplayItems[indexpoint].fTextColor.B=93;
		fDisplayItems[indexpoint].fItemFont = fMSA16Font;
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 1002;		
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).myDad = self;
		indexpoint = fDisplayItems.length;	
		
		//Nick Name	
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_VirtualKeyboard';
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		fDisplayItems[indexpoint].fBaseImage = None;
		fDisplayItems[indexpoint].fFocusImage = None;
		fDisplayItems[indexpoint].fTextColor.R=185;
		fDisplayItems[indexpoint].fTextColor.G=169;
		fDisplayItems[indexpoint].fTextColor.B=93;
		fDisplayItems[indexpoint].fItemFont = fMSA16Font;
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 1003;		
		displayitem_VirtualKeyboard(fDisplayItems[indexpoint]).myDad = self;
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
	fDoneLabel="Done"
	fClearAllLabel="Clear All"
	fBackspaceLabel="Backspace"
	kTotalKeyCount=64
	fKeyList="1234567890@ABCDEFGHIJKabcdefghijkLMNOPQRSTUVlmnopqrstuvWXYZ.wxyz"
	fMSA16Font=Font'B9_Fonts.MicroscanA16'
}