class  displayitem_NameYourServerKeyboard extends displayItem;

var int	fKeyToDisplay;

var private string fKeyList;
var private string fUppercase;
var private string fLowercase;
var private string fNumbers;

var int fMaxUserNameLength;
var int fMaxPasswordLength;
var int fMaxNickNameLen;
var int fCursorNumber;
var localized string fNameLabel;
var localized string fPasswordLabel;
var localized string fNickNameLabel;

var B9MP_Client				fClient;
var string fServerGameName;
var	string fServerGameAddress;
var String fSelectedClass;
var Pawn fPawn;

var B9_PDA_NameYourServerMenu myDad;
var B9MP_ServerDescription fCurrentServerDescription;

function AddNumber( Interactions.EInputKey key)
{
	if( Len(fCurrentServerDescription.fInfo.fName) >= fMaxUserNameLength )
	{
		return;
	}

	fCurrentServerDescription.fInfo.fName = fCurrentServerDescription.fInfo.fName $ Mid(fNumbers, Key - IK_0, 1);		
}
function AddUpperCaseLetter( Interactions.EInputKey key)
{

	if( Len(fCurrentServerDescription.fInfo.fName) >= fMaxUserNameLength )
	{
		return;
	}

	fCurrentServerDescription.fInfo.fName = fCurrentServerDescription.fInfo.fName $ Mid(fUppercase, 2 * (Key - IK_A), 1);
				
}
function AddLowerCaseLetter( Interactions.EInputKey key)
{
	if( Len(fCurrentServerDescription.fInfo.fName) >= fMaxUserNameLength )
	{
		return;
	}
			
	fCurrentServerDescription.fInfo.fName = fCurrentServerDescription.fInfo.fName $ Mid(fLowercase, (Key - IK_A), 1);
}
function RemoveLetter()
{
	if( Len(fCurrentServerDescription.fInfo.fName) < 1 )
	{
		return;
	}

	if (Len(fCurrentServerDescription.fInfo.fName) > 0)
	{
		fCurrentServerDescription.fInfo.fName = Left(fCurrentServerDescription.fInfo.fName, Len(fCurrentServerDescription.fInfo.fName) - 1);
	}
}
function bool handleKeyEvent( Interactions.EInputKey KeyIn, out Interactions.EInputAction Action, float Delta)
{
//log("KeyIn: " $ KeyIn $ "Action: " $ Action );

	if( KeyIn == IK_Shift )
	{
		if( Action == IST_Press )
		{
			myDad.fShiftDown = true;
		}
		else if( Action == IST_Release )
		{
			myDad.fShiftDown = false;
		}
		return true;
	}

	if( KeyIn >= IK_A && KeyIn <= IK_Z )
	{
		if( Action == IST_Press )
		{	
			if ( myDad.fShiftDown == true )
			{
				AddUpperCaseLetter(KeyIn);
			}
			else
			{
				AddLowerCaseLetter(KeyIn);
			}
		}
		return true;
	}
	else if(KeyIn >= IK_0 && KeyIn <= IK_9)
	{
		if( Action == IST_Press )
		{	
			AddNumber(KeyIn);
		}
		return true;
	}
	else if( KeyIn == IK_NumPadPeriod || KeyIn == IK_Period )
	{
		if( Action == IST_Press )
		{	
			fClient.fClientDescription.fInfo.fName = fClient.fClientDescription.fInfo.fName  $ ".";
		}
		return true;
	}	
	else if( KeyIn == IK_Backspace)
	{
		if( Action == IST_Press )
		{
			RemoveLetter();
		}

		return true;
	}

// Default handler handles nothing overload this to add functionality
	return false;
}

function bool Draw(canvas Canvas, int focus, int beginPoint_X, int beginPoint_Y,int endPoint_X, int endPoint_Y, out B9_PDABase PDA)
{
	switch( fKeyToDisplay )
	{
		case 10:
			Canvas.SetPos( Canvas.CurX + 32, Canvas.CurY );		
			fLabel = "@";
		break;
		case 66:
			Canvas.SetPos( Canvas.CurX + 32, Canvas.CurY );		
			fLabel = "DOT";
		break;
		case 999:
			Canvas.SetPos( Canvas.CurX , Canvas.CurY + 40 );
			
			fLabel = fNameLabel;	

			fLabel = fLabel $ fCurrentServerDescription.fInfo.fName;
		break;
		default:
		break;
	}
	
	++fCursorNumber;

	if( fCursorNumber > 9 )
	{
		fCursorNumber = 0;
	}

	return Super.Draw(Canvas, focus, beginPoint_X, beginPoint_Y,endPoint_X, endPoint_Y, PDA);	
}

function ClickItem(optional B9_MenuPDA_Menu menu)
{
	local Interactions.EInputKey bob;

	switch( fKeyToDisplay )
	{
	case 0:
		AddNumber( IK_0 );
	break;
	case 1:
		AddNumber( IK_1 );
	break;
	case 2:
		AddNumber( IK_2 );
	break;
	case 3:
		AddNumber( IK_3 );
	break;
	case 4:
		AddNumber( IK_4 );
	break;
	case 5:
		AddNumber( IK_5 );
	break;
	case 6:
		AddNumber( IK_6 );
	break;
	case 7:
		AddNumber( IK_7 );
	break;
	case 8:
		AddNumber( IK_8 );
	break;
	case 9:
		AddNumber( IK_9 );
	break;
	case 10:
/*		if( myDad.fItemWeAreChanging == 0 )
		{
			fClient.fClientDescription.fInfo.fName = fClient.fClientDescription.fInfo.fName  $ "@";
		}
*/	break;
	case 11:
		AddUpperCaseLetter( IK_A );
	break;
	case 12:
		AddUpperCaseLetter( IK_B );
	break;
	case 13:
		AddUpperCaseLetter( IK_C );
	break;
	case 14:
		AddUpperCaseLetter( IK_D );
	break;
	case 15:
		AddUpperCaseLetter( IK_E );
	break;
	case 16:
		AddUpperCaseLetter( IK_F );
	break;
	case 17:
		AddUpperCaseLetter( IK_G );
	break;
	case 18:
		AddUpperCaseLetter( IK_H );
	break;
	case 19:
		AddUpperCaseLetter( IK_I );
	break;
	case 20:
		AddUpperCaseLetter( IK_J );
	break;
	case 21:
		AddUpperCaseLetter( IK_K );
	break;
	case 22:
		AddUpperCaseLetter( IK_L );
	break;
	case 23:
		AddUpperCaseLetter( IK_M );
	break;
	case 24:
		AddUpperCaseLetter( IK_N );
	break;
	case 25:
		AddUpperCaseLetter( IK_O );
	break;
	case 26:
		AddUpperCaseLetter( IK_P );
	break;
	case 27:
		AddUpperCaseLetter( IK_Q );
	break;
	case 28:
		AddUpperCaseLetter( IK_R );
	break;
	case 29:
		AddUpperCaseLetter( IK_S );
	break;
	case 30:
		AddUpperCaseLetter( IK_T );
	break;
	case 31:
		AddUpperCaseLetter( IK_U );
	break;
	case 32:
		AddUpperCaseLetter( IK_V );
	break;
	case 33:
		AddUpperCaseLetter( IK_W );
	break;
	case 34:
		AddUpperCaseLetter( IK_X );
	break;
	case 35:
		AddUpperCaseLetter( IK_Y );
	break;
	case 36:
		AddLowerCaseLetter( IK_Z );
	break;
	case 37:
		AddLowerCaseLetter( IK_A );
	break;
	case 38:
		AddLowerCaseLetter( IK_B );
	break;
	case 39:
		AddLowerCaseLetter( IK_C );
	break;
	case 40:
		AddLowerCaseLetter( IK_D );
	break;
	case 41:
		AddLowerCaseLetter( IK_E );
	break;
	case 42:
		AddLowerCaseLetter( IK_F );
	break;
	case 43:
		AddLowerCaseLetter( IK_G );
	break;
	case 44:
		AddLowerCaseLetter( IK_H );
	break;
	case 45:
		AddLowerCaseLetter( IK_I );
	break;
	case 46:
		AddLowerCaseLetter( IK_J );
	break;
	case 47:
		AddLowerCaseLetter( IK_K );
	break;
	case 48:
		AddLowerCaseLetter( IK_L );
	break;
	case 49:
		AddLowerCaseLetter( IK_M );
	break;
	case 50:
		AddLowerCaseLetter( IK_N );
	break;
	case 51:
		AddLowerCaseLetter( IK_O );
	break;
	case 52:
		AddLowerCaseLetter( IK_P );
	break;
	case 53:
		AddLowerCaseLetter( IK_Q );
	break;
	case 54:
		AddLowerCaseLetter( IK_R );
	break;
	case 55:
		AddLowerCaseLetter( IK_S );
	break;
	case 56:
		AddLowerCaseLetter( IK_T );
	break;
	case 57:
		AddLowerCaseLetter( IK_U );
	break;
	case 58:
		AddLowerCaseLetter( IK_V );
	break;
	case 59:
		AddLowerCaseLetter( IK_W );
	break;
	case 60:
		AddLowerCaseLetter( IK_X );
	break;
	case 61:
		AddLowerCaseLetter( IK_Y );
	break;
	case 62:
		AddLowerCaseLetter( IK_Z );
	break;
	case 63:

	case 64:
		fCurrentServerDescription.fInfo.fName = "";
	break;
	case 65:
		RemoveLetter();
	break;
	case 66:
		fCurrentServerDescription.fInfo.fName = fCurrentServerDescription.fInfo.fName  $ ".";
	break;
	}

	Super.ClickItem( menu );
}

// This is the function that is called when the displayitem is selected
function ActOnClick(out B9_PDABase PDA,optional class<B9_MenuPDA_Menu> returnMenuClass)
{
	if( fKeyToDisplay == 63 )
	{
//		PDA.AddMenu( None );
		
		CreateGame( PDA );
	}
}
function CreateGame( B9_PDABase PDA )
{
	local Pawn pawn;
	local Pawn oldPawn;
	local Actor A;
	local vector loc;
	local String URL;


	ForEach PDA.RootController.AllActors(class'Actor', A)
	{
		if ( A.Name == 'LookTarget8' )
		{
			loc = A.location;
			break;
		}
	}

	URL = "MPHQ?Listen" $ "?Class=" $ fSelectedClass;
	URL = URL $ "?NAME=" $ fClient.fClientDescription.fInfo.fName;

	pawn = PDA.RootController.spawn( class<Pawn>(DynamicLoadObject( fSelectedClass, class'Class' ) ), , , loc );
	if ( pawn != None )
	{
		if ( PDA.RootController.pawn != None )
		{
			oldPawn = PDA.RootController.pawn;
			PDA.RootController.UnPossess();
			oldPawn.Destroy();
		}

		PDA.RootController.Possess(pawn);
	}

	// Load player settings
	B9_PlayerPawn(fPawn).SetMultiplayer();

	Log( "MP: SERVER OPEN [[" $ URL $ "]]" );

	PDA.RootController.ClientTravel( URL, TRAVEL_Absolute, true );
}
defaultproperties
{
	fKeyList="ABCDEFGHIJKLMabcdefghijklmNOPQRSTUVWXYZnopqrstuvwxyz1234567890"
	fUppercase="AABBCCDDEEFFGGHHIIJJKKLLMMNNOOPPQQRRSSTTUUVVWWXXYYZZ"
	fLowercase="abcdefghijklmnopqrstuvwxyz"
	fNumbers="0123456789"
	fMaxUserNameLength=22
	fNameLabel="Server Name: "
	fbStartByeByeTImerOnClick=false
}