class  displayitem_VirtualKeyboard extends displayItem;

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

var B9_PDA_VirtualKeyboard myDad;

/*
**	Key to fItemWeAreChanging
**
**	0 User Name
**	1 Password
**	2 NickName
**
*/
function AddNumber( Interactions.EInputKey key)
{
	if( myDad.fItemWeAreChanging == 0 && (Len(fClient.fClientDescription.fInfo.fName) >= fMaxUserNameLength) )
	{
		return;
	}
	if( myDad.fItemWeAreChanging == 1 && (Len(fClient.fClientDescription.fInfo.fPassword) >= fMaxPasswordLength) )
	{
		return;
	}
	if( myDad.fItemWeAreChanging == 2 && (Len(fClient.fClientDescription.fInfo.fNickName) >= fMaxNickNameLen) )
	{
		return;
	}

	if( myDad.fItemWeAreChanging == 0 )
	{			
		fClient.fClientDescription.fInfo.fName = fClient.fClientDescription.fInfo.fName $ Mid(fNumbers, Key - IK_0, 1);
	}
	else if( myDad.fItemWeAreChanging == 1 )
	{
		fClient.fClientDescription.fInfo.fPassword = fClient.fClientDescription.fInfo.fPassword $ Mid(fNumbers, Key - IK_0, 1);
	}
	else if( myDad.fItemWeAreChanging == 2 )
	{
		fClient.fClientDescription.fInfo.fNickName = fClient.fClientDescription.fInfo.fNickName $ Mid(fNumbers, Key - IK_0, 1);		
	}
	else
	{
		log("We are trying to change a PDA item that is out of bounds");
	}		
}
function AddUpperCaseLetter( Interactions.EInputKey key)
{

	if( myDad.fItemWeAreChanging == 0 && (Len(fClient.fClientDescription.fInfo.fName) >= fMaxUserNameLength) )
	{
		return;
	}
	if( myDad.fItemWeAreChanging == 1 && (Len(fClient.fClientDescription.fInfo.fPassword) >= fMaxPasswordLength) )
	{
		return;
	}
	if( myDad.fItemWeAreChanging == 2 && (Len(fClient.fClientDescription.fInfo.fNickName) >= fMaxNickNameLen) )
	{
		return;
	}

	if( myDad.fItemWeAreChanging == 0 )
	{
		fClient.fClientDescription.fInfo.fName = fClient.fClientDescription.fInfo.fName $ Mid(fUppercase, 2 * (Key - IK_A), 1);
	}
	else if( myDad.fItemWeAreChanging == 1 )
	{
		fClient.fClientDescription.fInfo.fPassword = fClient.fClientDescription.fInfo.fPassword $ Mid(fUppercase, 2 * (Key - IK_A), 1);
	}
	else if( myDad.fItemWeAreChanging == 2 )
	{
		fClient.fClientDescription.fInfo.fNickName = fClient.fClientDescription.fInfo.fNickName $ Mid(fUppercase, 2 * (Key - IK_A), 1);
	}
	else
	{
		log("We are trying to change a PDA item that is out of bounds");
	}				
								
}
function AddLowerCaseLetter( Interactions.EInputKey key)
{

	if( myDad.fItemWeAreChanging == 0 && (Len(fClient.fClientDescription.fInfo.fName) >= fMaxUserNameLength) )
	{
		return;
	}
	if( myDad.fItemWeAreChanging == 1 && (Len(fClient.fClientDescription.fInfo.fPassword) >= fMaxPasswordLength) )
	{
		return;
	}
	if( myDad.fItemWeAreChanging == 2 && (Len(fClient.fClientDescription.fInfo.fNickName) >= fMaxNickNameLen) )
	{
		return;
	}
	
	if( myDad.fItemWeAreChanging == 0 )
	{			
		fClient.fClientDescription.fInfo.fName = fClient.fClientDescription.fInfo.fName $ Mid(fLowercase, (Key - IK_A), 1);
	}
	else if( myDad.fItemWeAreChanging == 1 )
	{
		fClient.fClientDescription.fInfo.fPassword = fClient.fClientDescription.fInfo.fPassword $ Mid(fLowercase, (Key - IK_A), 1);
	}
	else if( myDad.fItemWeAreChanging == 2 )
	{
		fClient.fClientDescription.fInfo.fNickName = fClient.fClientDescription.fInfo.fNickName $ Mid(fLowercase, (Key - IK_A), 1);
	}
	else
	{
		log("We are trying to change a PDA item that is out of bounds");
	}										
}
function RemoveLetter()
{
	if( myDad.fItemWeAreChanging == 0 && (Len(fClient.fClientDescription.fInfo.fName) < 1 ) )
	{
		return;
	}
	if( myDad.fItemWeAreChanging == 1 && (Len(fClient.fClientDescription.fInfo.fPassword) < 1 ) )
	{
		return;
	}
	if( myDad.fItemWeAreChanging == 2 && (Len(fClient.fClientDescription.fInfo.fNickName) < 1 ) )
	{
		return;
	}


	if (Len(fClient.fClientDescription.fInfo.fNickName) > 0)
	{
		if( myDad.fItemWeAreChanging == 0 )
		{	
			fClient.fClientDescription.fInfo.fName = Left(fClient.fClientDescription.fInfo.fName, Len(fClient.fClientDescription.fInfo.fName) - 1);
		}
		else if( myDad.fItemWeAreChanging == 1 )
		{
			fClient.fClientDescription.fInfo.fPassword = Left(fClient.fClientDescription.fInfo.fPassword, Len(fClient.fClientDescription.fInfo.fPassword) - 1);
		}
		else if( myDad.fItemWeAreChanging == 2 )
		{
			fClient.fClientDescription.fInfo.fNickName = Left(fClient.fClientDescription.fInfo.fNickName, Len(fClient.fClientDescription.fInfo.fNickName) - 1);
		}
		else
		{
			log("We are trying to change a PDA item that is out of bounds");
		}			
/*
		fHighlightTicks = 0.5f;
		fHighlightItem = 62;
*/
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

	if( KeyIn == IK_Ctrl )
	{
		if( Action == IST_Press )
		{
			myDad.fCtrlKeyDown = true;
		}
		else if( Action == IST_Release )
		{
			myDad.fCtrlKeyDown = false;
		}

		return true;
	}
	
	if( myDad.fItemWeAreChanging == 0 && myDad.fShiftDown == true && KeyIn == IK_2)
	{
		if( Action == IST_Press )
		{		
			fClient.fClientDescription.fInfo.fName = fClient.fClientDescription.fInfo.fName  $ "@";
		}
		return true;	
	}
	else if( KeyIn >= IK_A && KeyIn <= IK_Z )
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
	else if( myDad.fItemWeAreChanging == 0 && ( KeyIn == IK_NumPadPeriod || KeyIn == IK_Period ) )
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
	if( KeyIn == IK_Tilde )
	{
		if( Action == IST_Press )
		{
			if( myDad.fCtrlKeyDown == false )
			{
				if( myDad.fItemWeAreChanging == 0 || myDad.fItemWeAreChanging == 1 )
				{
					++myDad.fItemWeAreChanging;
				}
				else if( myDad.fItemWeAreChanging == 2 )
				{
					myDad.fItemWeAreChanging = 0;
				}		
			}
			else
			{
				if( myDad.fItemWeAreChanging == 1 || myDad.fItemWeAreChanging == 2 )
				{
					--myDad.fItemWeAreChanging;
				}
				else if( myDad.fItemWeAreChanging == 0 )
				{
					myDad.fItemWeAreChanging = 2;
				}			
			}
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
		case 1001:
log( "fClient.fClientDescription.fInfo.fName" $ fClient.fClientDescription.fInfo.fName );
			Canvas.SetPos( Canvas.CurX , Canvas.CurY + 40 );
			
			if( fClient == None )
			{		
				fLabel = "fClient == None";
			}
			else
			{		
				fLabel = fNameLabel;	

				fLabel = fLabel $ fClient.fClientDescription.fInfo.fName;

				if( myDad.fItemWeAreChanging == 0 )
				{
					fLabel = fLabel $ ""$fCursorNumber;
				}
			}
		break;
		case 1002:
log( "fClient.fClientDescription.fInfo.fPassword" $ fClient.fClientDescription.fInfo.fPassword );
			if( fClient == None )
			{		
				fLabel = "fClient == None";
			}
			else
			{		
				fLabel = fPasswordLabel;	
				
				fLabel = fLabel $ fClient.fClientDescription.fInfo.fPassword;

				if( myDad.fItemWeAreChanging == 1 )
				{
					fLabel = fLabel $ ""$fCursorNumber;
				}
			}
		break;						
		case 1003:
log( "fClient.fClientDescription.fInfo.fNickName" $ fClient.fClientDescription.fInfo.fNickName );
			if( fClient == None )
			{		
				fLabel = "fClient == None";
			}
			else
			{		
				fLabel = fNickNameLabel;	
				
				fLabel = fLabel $ fClient.fClientDescription.fInfo.fNickName;

				if( myDad.fItemWeAreChanging == 2 )
				{
					fLabel = fLabel $ ""$fCursorNumber;
				}
			}
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
		AddNumber( IK_1 );
	break;
	case 1:
		AddNumber( IK_2 );
	break;
	case 2:
		AddNumber( IK_3 );
	break;
	case 3:
		AddNumber( IK_4 );
	break;
	case 4:
		AddNumber( IK_5 );
	break;
	case 5:
		AddNumber( IK_6 );
	break;
	case 6:
		AddNumber( IK_7 );
	break;
	case 7:
		AddNumber( IK_8 );
	break;
	case 8:
		AddNumber( IK_9 );
	break;
	case 9:
		AddNumber( IK_0 );
	break;
	case 10:
		if( myDad.fItemWeAreChanging == 0 )
		{
			fClient.fClientDescription.fInfo.fName = fClient.fClientDescription.fInfo.fName  $ "@";
		}
	break;
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
		AddLowerCaseLetter( IK_A );
	break;
	case 23:
		AddLowerCaseLetter( IK_B );
	break;
	case 24:
		AddLowerCaseLetter( IK_C );
	break;
	case 25:
		AddLowerCaseLetter( IK_D );
	break;
	case 26:
		AddLowerCaseLetter( IK_E );
	break;
	case 27:
		AddLowerCaseLetter( IK_F );
	break;
	case 28:
		AddLowerCaseLetter( IK_G );
	break;
	case 29:
		AddLowerCaseLetter( IK_H );
	break;
	case 30:
		AddLowerCaseLetter( IK_I );
	break;
	case 31:
		AddLowerCaseLetter( IK_J );
	break;
	case 32:
		AddLowerCaseLetter( IK_K );
	break;
	case 33:
		AddUpperCaseLetter( IK_L );
	break;
	case 34:
		AddUpperCaseLetter( IK_M );
	break;
	case 35:
		AddUpperCaseLetter( IK_N );
	break;
	case 36:
		AddUpperCaseLetter( IK_O );
	break;
	case 37:
		AddUpperCaseLetter( IK_P );
	break;
	case 38:
		AddUpperCaseLetter( IK_Q );
	break;
	case 39:
		AddUpperCaseLetter( IK_R );
	break;
	case 40:
		AddUpperCaseLetter( IK_S );
	break;
	case 41:
		AddUpperCaseLetter( IK_T );
	break;
	case 42:
		AddUpperCaseLetter( IK_U );
	break;
	case 43:
		AddUpperCaseLetter( IK_V );
	break;
	case 44:
		AddLowerCaseLetter( IK_L );
	break;
	case 45:
		AddLowerCaseLetter( IK_M );
	break;
	case 46:
		AddLowerCaseLetter( IK_N );
	break;
	case 47:
		AddLowerCaseLetter( IK_O );
	break;
	case 48:
		AddLowerCaseLetter( IK_P );
	break;
	case 49:
		AddLowerCaseLetter( IK_Q );
	break;
	case 50:
		AddLowerCaseLetter( IK_R );
	break;
	case 51:
		AddLowerCaseLetter( IK_S );
	break;
	case 52:
		AddLowerCaseLetter( IK_T );
	break;
	case 53:
		AddLowerCaseLetter( IK_U );
	break;
	case 54:
		AddLowerCaseLetter( IK_V );
	break;
	case 55:
		AddUpperCaseLetter( IK_W );
	break;
	case 56:
		AddUpperCaseLetter( IK_X );
	break;
	case 57:
		AddUpperCaseLetter( IK_Y );
	break;
	case 58:
		AddUpperCaseLetter( IK_Z );
	break;
	case 59:
		if( myDad.fItemWeAreChanging == 0 )
		{
		 if(Len(fClient.fClientDescription.fInfo.fName) < fMaxUserNameLength)
			
			fClient.fClientDescription.fInfo.fName = fClient.fClientDescription.fInfo.fName $ ".";
		}
	break;
	case 60:
		AddLowerCaseLetter( IK_W );
	break;
	case 61:
		AddLowerCaseLetter( IK_X );
	break;
	case 62:
		AddLowerCaseLetter( IK_Y );
	break;
	case 62:
		AddLowerCaseLetter( IK_Z );
	break;
	case 65:
		if( myDad.fItemWeAreChanging == 0 || myDad.fItemWeAreChanging == 1 )
		{
			++myDad.fItemWeAreChanging;
		}
		else if( myDad.fItemWeAreChanging == 2 )
		{
			myDad.fItemWeAreChanging = 0;
		}
	break;
	case 66:
		if( myDad.fItemWeAreChanging == 0 )
		{
			fClient.fClientDescription.fInfo.fName = "";
		}
		else if( myDad.fItemWeAreChanging == 1 )
		{
			fClient.fClientDescription.fInfo.fPassword = "";
		}
		else if( myDad.fItemWeAreChanging == 2 )
		{
			fClient.fClientDescription.fInfo.fNickName = "";
		}
	break;
	case 67:
		RemoveLetter();
	break;
	case 1001:
		myDad.fItemWeAreChanging = 0;
	break;
	case 1002:
		myDad.fItemWeAreChanging = 1;
	break;
	case 1003:
		myDad.fItemWeAreChanging = 2;
	break;
	}

	Super.ClickItem( menu );
}

// This is the function that is called when the displayitem is selected
function ActOnClick(out B9_PDABase PDA,optional class<B9_MenuPDA_Menu> returnMenuClass)
{

}
defaultproperties
{
	fKeyList="1234567890@ABCDEFGHIJKabcdefghijkLMNOPQRSTUVlmnopqrstuvWXYZ.wxyz"
	fUppercase="AABBCCDDEEFFGGHHIIJJKKLLMMNNOOPPQQRRSSTTUUVVWWXXYYZZ"
	fLowercase="abcdefghijklmnopqrstuvwxyz"
	fNumbers="0123456789"
	fMaxUserNameLength=22
	fMaxPasswordLength=22
	fMaxNickNameLen=22
	fNameLabel="Email Addr: "
	fPasswordLabel="Password: "
	fNickNameLabel="Nick Name: "
	fTextColor=(B=0,G=0,R=0,A=255)
	fBaseImage=Texture'B9Menu_textures.VirtualKeyboardEnglish.key_static'
	fFocusImage=Texture'B9Menu_textures.VirtualKeyboardEnglish.key_hover'
	fDrawNextItemTotheRight=true
	fbStartByeByeTImerOnClick=false
}