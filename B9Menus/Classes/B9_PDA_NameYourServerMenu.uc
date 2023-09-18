class B9_PDA_NameYourServerMenu extends B9_MenuPDA_Menu;

var bool fRanOnce;
var B9MP_ServerDescription		fMyServerDescription;
var bool fShiftDown;
var B9MP_Client fClient;
var localized string fBlanksServerLabel;
var localized font MSA24Font;
var localized font MSA16Font;

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

		if ( fMyServerDescription == None )
		{
			ForEach fPDABase.RootController.AllActors( class'B9MP_ServerDescription', fMyServerDescription )
			{
				break;
			}
		}

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
			else
			{
				fMyServerDescription.fInfo.fName = fClient.fClientDescription.fInfo.fNickName $ fBlanksServerLabel;
			}
		}

		//0
		indexpoint = 0;
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.zero1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.zero3';
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 0;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;

		//1
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.one1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.one3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 1;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;						
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;
		//2
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.two1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.two3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 2;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;
		//3
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.three1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.three3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 3;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;				
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;
		//4
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.four1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.four3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 4;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;
		//5
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.five1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.five3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 5;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;
		//6
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.six1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.six3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 6;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;
		//7
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.seven1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.seven3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 7;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;
		//8
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.eight1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.eight3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 8;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;
		//9
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.nine1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.nine3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 9;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;
		//@
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fItemFont = MSA24Font;
//		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.zero1'; //dferrellNF
//		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.zero3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 10;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;
//2nd Row		
		//A
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.AA1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.AA3';		
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 11;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;																						

		//B
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.BB1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.BB3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 12;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//C
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.CC1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.CC3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 13;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//D
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.DD1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.DD3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 14;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//E
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.EE1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.EE3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 15;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//F
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.FF1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.FF3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 16;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//G
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.GG1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.GG3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 17;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//H
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.HH1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.HH3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 18;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//I
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.II1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.II3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 19;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//J
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.JJ1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.JJ3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 20;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//K
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.KK1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.KK3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 21;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
//3rd Row
		//a
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.a1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.a3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 37;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;																						

		//b
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.b1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.b3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 38;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//c
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.c1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.c3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 39;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//d
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.d1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.d3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 40;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//e
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.e1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.e3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 41;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//f
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.f1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.f3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 42;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//g
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.g1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.g3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 43;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//h
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.h1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.h3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 44;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//i
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.i1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.i3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 45;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//j
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.j1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.j3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 46;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//k
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.k1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.k3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 47;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
//4th Row
		//L
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.LL1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.LL3';		
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 22;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		
		
		//M
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.MM1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.MM3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 23;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
	
		//N
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.NN1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.NN3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 24;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//O
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.OO1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.OO3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 25;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//P
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.PP1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.PP3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 26;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//Q
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.QQ1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.QQ3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 27;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//R
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.RR1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.RR3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 28;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//S
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.SS1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.SS3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 29;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//T
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.TT1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.TT3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 30;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//U
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.UU1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.UU3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 31;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//V
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.VV1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.VV3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 32;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
//5th Row
		//l
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.l1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.l3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 48;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;

		//m
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.m1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.m3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 49;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
	
		//n
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.n1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.n3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 50;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//o
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.o1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.o3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 51;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//p
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.p1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.p3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 52;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//q
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.q1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.q3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 53;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//r
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.r1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.r3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 54;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//s
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.s1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.s3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 55;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//t
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.t1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.t3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 56;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//u
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.u1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.u3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 57;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//v
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.v1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.v3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 58;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	

//6th Row
		//W
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.WW1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.WW3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 33;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		//X
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.XX1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.XX3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 34;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		//Y
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.YY1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.YY3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 35;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		//Z
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.ZZ1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.ZZ3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 36;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;
		
		//.
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fItemFont = MSA24Font;
//		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.zero1';
//		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.zero3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 66;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;		

		//w
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.w1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.w3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 59;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		//x
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.x1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.x3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 60;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		//y
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.y1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.y3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 61;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		//z
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.z1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.z3';
		fDisplayItems[indexpoint].fStartX = fDisplayItems[indexpoint].fStartX + 32;			
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 62;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;								

		//Done
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.VKE_done1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.VKE_done3';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 63;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;						
		fDisplayItems[indexpoint].fCanAcceptFocus = true;
		fDisplayItems[indexpoint].fbStartByeByeTImerOnClick = true;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//ClearAll
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.NameClear1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.NameClear3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 64;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;	
		
		//Backspace
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fBaseImage = texture'B9Menu_textures.NameBack1';
		fDisplayItems[indexpoint].fFocusImage = texture'B9Menu_textures.NameBack3';		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 65;		
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		fDisplayItems[indexpoint].fCanAcceptFocus = true;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
		indexpoint = fDisplayItems.length;

		//Display Server Name
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_NameYourServerKeyboard';
		fDisplayItems[indexpoint].fItemFont = MSA16Font;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fKeyToDisplay = 999;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).myDad = self;
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		fDisplayItems[indexpoint].fCanAcceptFocus = false;				
		displayitem_NameYourServerKeyboard(fDisplayItems[indexpoint]).fClient = fClient;
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
	fBlanksServerLabel="s Server"
	MSA24Font=Font'B9_Fonts.MicroscanA24'
	MSA16Font=Font'B9_Fonts.MicroscanA16'
}