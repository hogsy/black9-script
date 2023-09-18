/////////////////////////////////////////////////////////////
// B9_MM_NewCareerNameMenu
//

class B9_MM_NewCareerNameMenu extends B9_MMInteraction;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX

var private sound fUpSound;
var private sound fDownSound;
var private sound fClickSound;
var private sound fCancelSound;

var private int fLtWidth;
var private int fLtHeight;
var private int fRtWidth;
var private int fRtHeight;

var private int fKeyW;
var private int fKeyH;
var private int fSpacingW;
var private int fSpacingH;
var private int fLettersX;
var private int fLettersY;
var private int fNumeralsX;
var private int fNumeralsY;
var private int fBackspaceX;
var private int fBackspaceY;
var private int fBackspaceW;
var private int fClearAllX;
var private int fClearAllY;
var private int fClearAllW;
var private int fDoneX;
var private int fDoneY;
var private int fDoneW;

var int fSelItem;
var int fNumItems;
var int fHighlightItem;

var string fCharName;
var int fMaxCharNameLen;

var private EInputKey fKeyDown;
var private float fByeByeTicks;
var private float fRepeatTicksX;
var private float fRepeatTicksY;
var private float fMouseDragX;
var private float fMouseDragY;
var private float fDragRes;
var private float fHighlightTicks;

var private texture fAcceptImage;
var private texture fRejectImage;

var private texture fKeyboard[195];
var private string fKeyList;
var private string fUppercase;
var private string fLowercase;
//var private string fNumerals[10];
var private string fNumbers;

var private bool bShiftDown;

var font fMyFont;

//var() localized string MSA24Font;
var localized font MSA24Font;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentController. You don't have to implement MenuInit(),
// but you should call super.MenuInit().
function Initialized()
{
	fDragRes = 10.0f;

	fMaxCharNameLen = 14;

	fSelItem = 64;
	fNumItems = 65;

	fKeyW = 32;
	fKeyH = 32;
	fSpacingW = 34;
	fSpacingH = 34;
	fLettersX = 64;
	fLettersY = 170;
	fNumeralsX = 64 + 51;
	fNumeralsY = 170 + 4 * 34;
	fBackspaceX = 64;
	fBackspaceY = 170 + 5 * 34;
	fBackspaceW = 136;
	fClearAllX = 64 + 173;
	fClearAllY = fBackspaceY;
	fClearAllW = 136;
	fDoneX = 64 + 346;
	fDoneY = fBackspaceY;
	fDoneW = 96;

	fMyFont = MSA24Font; //LoadFont( MSA24Font );

}

function SetName(string cname)
{
	fCharName = cname;
}

function GetName(out string cname)
{
	cname = fCharName;
}

function Tick(float Delta)
{
	local bool change;
	
	if (fHighlightTicks > 0)
	{
		fHighlightTicks -= Delta;
		if (fHighlightTicks <= 0.0f)
			fHighlightTicks = 0.0f;
	}

	if (fByeByeTicks > 0)
	{
		fByeByeTicks -= Delta;
		if (fByeByeTicks <= 0.0f)
		{
			if (fKeyDown == IK_Enter)
				B9_MMInteraction(ParentInteraction).EndMenu(self, 0);
			else if (fKeyDown == IK_Backspace)
				B9_MMInteraction(ParentInteraction).EndMenu(self, -1);
		}

		return;
	}

	if (fKeyDown == IK_Left || fKeyDown == IK_Right)
	{
		change = false;
		fRepeatTicksX -= Delta;
		if (fRepeatTicksX <= 0.0f)
		{
			change = true;
			fRepeatTicksX = 0.25;
		}

		if (change)
		{
			if (fKeyDown == IK_Left)
			{
				MoveSelection(IK_Left, 0.3f);
				RootController.PlaySound( fDownSound );
			}
			else if (fKeyDown == IK_Right)
			{
				MoveSelection(IK_Right, 0.3f);
				RootController.PlaySound( fUpSound );
			}
		}
	}
	else if (fRepeatTicksX > 0.0f)
	{
		fRepeatTicksX -= Delta;
		if (fRepeatTicksX < 0.0f)
			fRepeatTicksX = 0.0f;
	}

	if (fKeyDown == IK_Up || fKeyDown == IK_Down)
	{
		change = false;
		fRepeatTicksY -= Delta;
		if (fRepeatTicksY <= 0.0f)
		{
			change = true;
			fRepeatTicksY = 0.25;
		}

		if (change)
		{
			if (fKeyDown == IK_Up)
			{
				MoveSelection(IK_Up, 0.3f);
				RootController.PlaySound( fUpSound );
			}
			else if (fKeyDown == IK_Down)
			{
				MoveSelection(IK_Down, 0.3f);
				RootController.PlaySound( fDownSound );
			}
		}
	}
	else if (fRepeatTicksY > 0.0f)
	{
		fRepeatTicksY -= Delta;
		if (fRepeatTicksY < 0.0f)
			fRepeatTicksY = 0.0f;
	}
}

function texture GetKeyTexture(int i)
{
	if (fSelItem == i && fByeByeTicks > 0.0f)
	{
		if (fKeyDown == IK_Enter)
			return fKeyboard[3 * i + 2];
		return fKeyboard[3 * i + 1];
	}

	if (fHighlightTicks > 0.0f && fHighlightItem == i)
	{
		return fKeyboard[3 * i + 2];
	}
	
	if (fSelItem == i)
	{
		return fKeyboard[3 * i + 1];
	}
	
	return fKeyboard[3 * i];
}

function PostRender( canvas Canvas )
{
	local int i, x, y;
	local color white, cyan;
	local font oldFont;
	local float sx, sy;

	oldFont = Canvas.Font;
	Canvas.Font = fMyFont;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	cyan.R = 0;
	cyan.G = 255;
	cyan.B = 255;

	Canvas.SetDrawColor(white.R, white.G, white.B);
	Canvas.Style = RootController.ERenderStyle.STY_alpha;

	x = fLettersX;
	y = fLettersY;
	for (i=0;i<13;i++)
	{
		Canvas.SetPos( x + 34 * i, y );
		Canvas.DrawTile( GetKeyTexture(i), 32, 32, 0, 0, 32, 32 );

		Canvas.SetPos( x + 34 * i, y + 34);
		Canvas.DrawTile( GetKeyTexture(i + 13), 32, 32, 0, 0, 32, 32 );

		Canvas.SetPos( x + 34 * i, y + 2 * 34);
		Canvas.DrawTile( GetKeyTexture(i + 26), 32, 32, 0, 0, 32, 32 );

		Canvas.SetPos( x + 34 * i, y + 3 * 34);
		Canvas.DrawTile( GetKeyTexture(i + 39), 32, 32, 0, 0, 32, 32 );
	}

	x = fNumeralsX;
	y = fNumeralsY;
	for (i=0;i<10;i++)
	{
		Canvas.SetPos( x + 34 * i, y );
		Canvas.DrawTile( GetKeyTexture(i + 52), 32, 32, 0, 0, 32, 32 );
	}

	x = fBackspaceX;
	y = fBackspaceY;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( GetKeyTexture(62), 256, 32, 0, 0, 256, 32 );

	x = fClearAllX;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( GetKeyTexture(63), 256, 32, 0, 0, 256, 32 );

	x = fDoneX;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( GetKeyTexture(64), 128, 32, 0, 0, 128, 32 );


	Canvas.SetDrawColor(white.R, white.G, white.B);
	Canvas.Style = RootController.ERenderStyle.STY_Normal;

	Canvas.SetPos( 64, 416 );
	Canvas.DrawTile( fAcceptImage, fLtWidth, fLtHeight, 0, 0, fLtWidth, fLtHeight );

	Canvas.SetPos( 320, 416 );
	Canvas.DrawTile( fRejectImage, fLtWidth, fLtHeight, 0, 0, fLtWidth, fLtHeight );

	Canvas.SetDrawColor(cyan.R, cyan.G, cyan.B);

	x = 64 + (13 * 34) / 2 - 1;
	y = 170 + 6 * 34 + 10;
	Canvas.TextSize( fCharName, sx, sy );
	Canvas.SetPos( float(x) - sx / 2.0f, y );
	Canvas.DrawText( fCharName, false );

	Canvas.Font = oldFont;
}

function MoveSelection(EInputKey key, float ticks )
{
	local int i;

	if (key == IK_Left)
	{
		if (fSelItem < 4 * 13)
		{
			i = fSelItem % 13;
			fSelItem = (fSelItem - i) + (i + 12) % 13;
		}
		else if (fSelItem < 4 * 13 + 10)
		{
			i = (fSelItem - 4 * 13) % 10;
			fSelItem = (fSelItem - i) + (i + 9) % 10;
		}
		else
		{
			i = (fSelItem - 4 * 13 - 10) % 3;
			fSelItem = (fSelItem - i) + (i + 2) % 3;
		}
	
		fRepeatTicksX = ticks;
	}
	else if (key == IK_Right)
	{
		if (fSelItem < 4 * 13)
		{
			i = fSelItem % 13;
			fSelItem = (fSelItem - i) + (i + 1) % 13;
		}
		else if (fSelItem < 4 * 13 + 10)
		{
			i = (fSelItem - 4 * 13) % 10;
			fSelItem = (fSelItem - i) + (i + 1) % 10;
		}
		else
		{
			i = (fSelItem - 4 * 13 - 10) % 3;
			fSelItem = (fSelItem - i) + (i + 1) % 3;
		}

		fRepeatTicksX = ticks;
	}
	else if (key == IK_Up)
	{
		if (fSelItem >= 13 && fSelItem < 4 * 13)
		{
			fSelItem -= 13;
		}
		else if (fSelItem < 5)
		{
			fSelItem = 62;
		}
		else if (fSelItem < 10)
		{
			fSelItem = 63;
		}
		else if (fSelItem < 13)
		{
			fSelItem = 64;
		}
		else if (fSelItem < 4 * 13 + 10)
		{
			fSelItem -= 12;
		}
		else if (fSelItem == 62)
		{
			fSelItem = 4 * 13;
		}
		else if (fSelItem == 63)
		{
			fSelItem = 4 * 13 + 3;
		}
		else
		{
			fSelItem = 4 * 13 + 8;
		}

		fRepeatTicksY = ticks;
	}
	else if (key == IK_Down)
	{
		if (fSelItem < 3 * 13)
		{
			fSelItem += 13;
		}
		else if (fSelItem == 3 * 13)
		{
			fSelItem = 4 * 13;
		}
		else if (fSelItem == 4 * 13 - 2 || fSelItem == 4 * 13 - 1)
		{
			fSelItem = 4 * 13 + 9;
		}
		else if (fSelItem < 4 * 13 - 2)
		{
			fSelItem += 12;
		}
		else if (fSelItem < 4 * 13 + 3 )
		{
			fSelItem = 62;
		}
		else if (fSelItem < 4 * 13 + 8 )
		{
			fSelItem = 63;
		}
		else if (fSelItem < 4 * 13 + 10 )
		{
			fSelItem = 64;
		}
		else
		{
			fSelItem = 4 * (fSelItem - 62);
		}

		fRepeatTicksY = ticks;
	}
}

function BackButton()
{
	fByeByeTicks = 0.5f;
	fKeyDown = IK_Backspace;
	RootController.PlaySound( fCancelSound );
}

function ClickItem()
{
	local int n;
	
	n = Len(fCharName);

	if (fSelItem == 64)
	{
		if (n > 0)
		{
			// DONE
			fByeByeTicks = 0.5f;
			fKeyDown = IK_Enter;
			RootController.PlaySound( fClickSound );
		}
	}
	else if (fSelItem == 63)
	{
		fCharName = "";
		RootController.PlaySound( fClickSound );
		fHighlightTicks = 0.5f;
		fHighlightItem = 63;
	}
	else if (fSelItem == 62)
	{
		if (n > 0)
		{
			fCharName = Left(fCharName, n - 1);
			RootController.PlaySound( fClickSound );
			fHighlightTicks = 0.5f;
			fHighlightItem = 62;
		}
	}
	else
	{
		if (n < fMaxCharNameLen)
		{
			fCharName = fCharName $ Mid(fKeyList, fSelItem, 1);
			RootController.PlaySound( fClickSound );
			fHighlightTicks = 0.5f;
			fHighlightItem = fSelItem;
		}
	}
}

function AddLetter(EInputKey key)
{
	if (Len(fCharName) < fMaxCharNameLen)
	{
		if (Key >= IK_A && Key <= IK_Z)
		{
			if (bShiftDown)
			{
				fCharName = fCharName $ Mid(fUppercase, 2 * (Key - IK_A), 1);
				if (Key >= IK_N)
					fHighlightItem = 2 * 13 + (Key - IK_N);
				else
					fHighlightItem = (Key - IK_A);
			}
			else
			{
				fCharName = fCharName $ Mid(fLowercase, (Key - IK_A), 1);
				if (Key >= IK_N)
					fHighlightItem = 3 * 13 + (Key - IK_N);
				else
					fHighlightItem = 1 * 13 + (Key - IK_A);
			}
			RootController.PlaySound( fClickSound );
			fHighlightTicks = 0.5f;
		}
		else if(Key >= IK_0 && Key <= IK_9)
		{
			fCharName = fCharName $ Mid(fNumbers, Key - IK_0, 1);
			RootController.PlaySound( fClickSound );
			fHighlightTicks = 0.5f;
			if (Key == IK_0)
				fHighlightItem = 4 * 13 + 9;
			else
				fHighlightItem = 4 * 13 + (Key - IK_0) - 1;
		}
	}
}

function RemoveLetter()
{
	if (Len(fCharName) > 0)
	{
		fCharName = Left(fCharName, Len(fCharName) - 1);
		RootController.PlaySound( fClickSound );
		fHighlightTicks = 0.5f;
		fHighlightItem = 62;
	}
}

function HighlightByMouse()
{
	local int i, x, y;

	if (fKeyDown == IK_None)
	{
		x = fLettersX;
		y = fLettersY;
		for (i=0;i<13;i++)
		{
			if (x + 34 * i <= MouseX && MouseX < x + 34 * i + 32 && y <= MouseY && MouseY < y + 32)
			{
				fSelItem = i;
				return;
			}

			if (x + 34 * i <= MouseX && MouseX < x + 34 * i + 32 && y + 34 <= MouseY && MouseY < y + 34 + 32)
			{
				fSelItem = i + 13;
				return;
			}

			if (x + 34 * i <= MouseX && MouseX < x + 34 * i + 32 && y + 68 <= MouseY && MouseY < y + 68 + 32)
			{
				fSelItem = i + 26;
				return;
			}


			if (x + 34 * i <= MouseX && MouseX < x + 34 * i + 32 && y + 102 <= MouseY && MouseY < y + 102 + 32)
			{
				fSelItem = i + 39;
				return;
			}
		}

		x = fNumeralsX;
		y = fNumeralsY;
		for (i=0;i<10;i++)
		{
			if (x + 34 * i <= MouseX && MouseX < x + 34 * i + 32 && y <= MouseY && MouseY < y + 32)
			{
				fSelItem = i + 52;
				return;
			}
		}

		if (fBackspaceX <= MouseX && MouseX < fBackspaceX + fBackspaceW &&
			fBackspaceY <= MouseY && MouseY < fBackspaceY + 32)
		{
			fSelItem = 62;
			return;
		}

		if (fClearAllX <= MouseX && MouseX < fClearAllX + fClearAllW &&
			fClearAllY <= MouseY && MouseY < fClearAllY + 32)
		{
			fSelItem = 63;
			return;
		}

		if (fDoneX <= MouseX && MouseX < fDoneX + fDoneW &&
			fDoneY <= MouseY && MouseY < fDoneY + 32)
		{
			fSelItem = 64;
			return;
		}
	}
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local Pawn pawn, oldPawn;

	Key = ConvertJoystick(Key);

	if (fByeByeTicks == 0.0f)
	{
		if( Action == IST_Press && (Key == IK_Enter ||
			Key == IK_LeftMouse || Key == IK_Joy1) )
		{
			ClickItem();
		}
		else if( Action == IST_Release && (Key == IK_Enter ||
			Key == IK_LeftMouse || Key == IK_Joy1) )
		{
			if (fKeyDown == IK_LeftMouse)
				fKeyDown = IK_None;
		}
		else if( Action == IST_Press && (Key == IK_Escape ||
			Key == IK_RightMouse || Key == IK_Joy2) )
		{
			BackButton();
		}
		else if (bDrawMouse && (Key == IK_MouseX || Key == IK_MouseY))
		{
			HighlightByMouse();
		}
		else if( Action == IST_Axis && Key == IK_MouseX )
		{
			if (Delta > 0)
			{
				if (fMouseDragX < 0)
					fMouseDragX = 0.0f;
				fMouseDragX += Delta;
				if (fRepeatTicksX == 0.0f && fMouseDragX >= fDragRes)
				{
					MoveSelection(IK_Right, 0.3f);
					RootController.PlaySound( fUpSound ); 	
					fMouseDragX = 0.0f;
				}
			}
			else if (Delta < 0)
			{
				if (fMouseDragX > 0)
					fMouseDragX = 0.0f;
				fMouseDragX += Delta;
				if (fRepeatTicksX == 0.0f && fMouseDragX <= -fDragRes)
				{
					MoveSelection(IK_Left, 0.3f);
					RootController.PlaySound( fDownSound ); 	
					fMouseDragX = 0.0f;
				}
			}
		}
		else if( Action == IST_Axis && Key == IK_MouseY )
		{
			if (Delta > 0)
			{
				if (fMouseDragY < 0)
					fMouseDragY = 0.0f;
				fMouseDragY += Delta;
				if (fRepeatTicksY == 0.0f && fMouseDragY >= fDragRes)
				{
					MoveSelection(IK_Up, 0.3f);
					RootController.PlaySound( fUpSound ); 	
					fMouseDragX = 0.0f;
				}
			}
			else if (Delta < 0)
			{
				if (fMouseDragY > 0)
					fMouseDragY = 0.0f;
				fMouseDragY += Delta;
				if (fRepeatTicksY == 0.0f && fMouseDragY <= fDragRes)
				{
					MoveSelection(IK_Down, 0.3f);
					RootController.PlaySound( fDownSound ); 	
					fMouseDragY = 0.0f;
				}
			}
		}
		else if( Action == IST_Press && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
		{
			if (fKeyDown == IK_None)
			{
				MoveSelection(IK_Up, 0.5f);
				RootController.PlaySound( fUpSound ); 	
				fKeyDown = IK_Up;
			}
		}
		else if( Action == IST_Release && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
		{
			if (fKeyDown == IK_Up)
				fKeyDown = IK_None;
		}
		else if( Action == IST_Press && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
		{
			if (fKeyDown == IK_None)
			{
				MoveSelection(IK_Down, 0.5f);
				RootController.PlaySound( fDownSound );	
				fKeyDown = IK_Down;
			}
		}
		else if( Action == IST_Release && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
		{
			if (fKeyDown == IK_Down)
				fKeyDown = IK_None;
		}
		else if( Action == IST_Press && 
			(Key == IK_Left || Key == IK_Joy11 || Key == IK_GreyMinus || Key == IK_Minus) )
		{
			if (fKeyDown == IK_None)
			{
				MoveSelection(IK_Left, 0.5f);
				RootController.PlaySound( fDownSound ); 	
				fKeyDown = IK_Left;
			}
		}
		else if( Action == IST_Release &&
			(Key == IK_Left || Key == IK_Joy11 || Key == IK_GreyMinus || Key == IK_Minus) )
		{
			if (fKeyDown == IK_Left)
				fKeyDown = IK_None;
		}
		else if( Action == IST_Press &&
			(Key == IK_Right || Key == IK_Joy12 || Key == IK_GreyPlus || Key == IK_Equals) )
		{
			if (fKeyDown == IK_None)
			{
				MoveSelection(IK_Right, 0.5f);
				RootController.PlaySound( fUpSound );	
				fKeyDown = IK_Right;
			}
		}
		else if( Action == IST_Release && 
			(Key == IK_Right || Key == IK_Joy12 || Key == IK_GreyPlus || Key == IK_Equals) )
		{
			if (fKeyDown == IK_Right)
				fKeyDown = IK_None;
		}
		else if( Action == IST_Press && Key == IK_Shift)
		{
			bShiftDown = true;
		}
		else if( Action == IST_Release && Key == IK_Shift)
		{
			bShiftDown = false;
		}
		else if( Action == IST_Press && ((Key >= IK_A && Key <= IK_Z) || (Key >= IK_0 && Key <= IK_9)))
		{
			AddLetter(Key);
		}
		else if( Action == IST_Press && Key == IK_Backspace)
		{
			RemoveLetter();
		}

	}

	return true;
}

defaultproperties
{
	fUpSound=Sound'B9SoundFX.Menu.up_1'
	fDownSound=Sound'B9SoundFX.Menu.down_1'
	fClickSound=Sound'B9SoundFX.Menu.ok_1'
	fCancelSound=Sound'B9SoundFX.Menu.cancel_2'
	fLtWidth=256
	fLtHeight=32
	fRtWidth=256
	fRtHeight=32
	fAcceptImage=Texture'B9MenuHelp_Textures.Choices.choice_select'
	fRejectImage=Texture'B9MenuHelp_Textures.Choices.choice_back'
	fKeyboard[0]=Texture'B9Menu_textures.VirtualKeyboardEnglish.AA1'
	fKeyboard[1]=Texture'B9Menu_textures.VirtualKeyboardEnglish.AA2'
	fKeyboard[2]=Texture'B9Menu_textures.VirtualKeyboardEnglish.AA3'
	fKeyboard[3]=Texture'B9Menu_textures.VirtualKeyboardEnglish.BB1'
	fKeyboard[4]=Texture'B9Menu_textures.VirtualKeyboardEnglish.BB2'
	fKeyboard[5]=Texture'B9Menu_textures.VirtualKeyboardEnglish.BB3'
	fKeyboard[6]=Texture'B9Menu_textures.VirtualKeyboardEnglish.CC1'
	fKeyboard[7]=Texture'B9Menu_textures.VirtualKeyboardEnglish.CC2'
	fKeyboard[8]=Texture'B9Menu_textures.VirtualKeyboardEnglish.CC3'
	fKeyboard[9]=Texture'B9Menu_textures.VirtualKeyboardEnglish.DD1'
	fKeyboard[10]=Texture'B9Menu_textures.VirtualKeyboardEnglish.DD2'
	fKeyboard[11]=Texture'B9Menu_textures.VirtualKeyboardEnglish.DD3'
	fKeyboard[12]=Texture'B9Menu_textures.VirtualKeyboardEnglish.EE1'
	fKeyboard[13]=Texture'B9Menu_textures.VirtualKeyboardEnglish.EE2'
	fKeyboard[14]=Texture'B9Menu_textures.VirtualKeyboardEnglish.EE3'
	fKeyboard[15]=Texture'B9Menu_textures.VirtualKeyboardEnglish.FF1'
	fKeyboard[16]=Texture'B9Menu_textures.VirtualKeyboardEnglish.FF2'
	fKeyboard[17]=Texture'B9Menu_textures.VirtualKeyboardEnglish.FF3'
	fKeyboard[18]=Texture'B9Menu_textures.VirtualKeyboardEnglish.GG1'
	fKeyboard[19]=Texture'B9Menu_textures.VirtualKeyboardEnglish.GG2'
	fKeyboard[20]=Texture'B9Menu_textures.VirtualKeyboardEnglish.GG3'
	fKeyboard[21]=Texture'B9Menu_textures.VirtualKeyboardEnglish.HH1'
	fKeyboard[22]=Texture'B9Menu_textures.VirtualKeyboardEnglish.HH2'
	fKeyboard[23]=Texture'B9Menu_textures.VirtualKeyboardEnglish.HH3'
	fKeyboard[24]=Texture'B9Menu_textures.VirtualKeyboardEnglish.II1'
	fKeyboard[25]=Texture'B9Menu_textures.VirtualKeyboardEnglish.II2'
	fKeyboard[26]=Texture'B9Menu_textures.VirtualKeyboardEnglish.II3'
	fKeyboard[27]=Texture'B9Menu_textures.VirtualKeyboardEnglish.JJ1'
	fKeyboard[28]=Texture'B9Menu_textures.VirtualKeyboardEnglish.JJ2'
	fKeyboard[29]=Texture'B9Menu_textures.VirtualKeyboardEnglish.JJ3'
	fKeyboard[30]=Texture'B9Menu_textures.VirtualKeyboardEnglish.KK1'
	fKeyboard[31]=Texture'B9Menu_textures.VirtualKeyboardEnglish.KK2'
	fKeyboard[32]=Texture'B9Menu_textures.VirtualKeyboardEnglish.KK3'
	fKeyboard[33]=Texture'B9Menu_textures.VirtualKeyboardEnglish.LL1'
	fKeyboard[34]=Texture'B9Menu_textures.VirtualKeyboardEnglish.LL2'
	fKeyboard[35]=Texture'B9Menu_textures.VirtualKeyboardEnglish.LL3'
	fKeyboard[36]=Texture'B9Menu_textures.VirtualKeyboardEnglish.MM1'
	fKeyboard[37]=Texture'B9Menu_textures.VirtualKeyboardEnglish.MM2'
	fKeyboard[38]=Texture'B9Menu_textures.VirtualKeyboardEnglish.MM3'
	fKeyboard[39]=Texture'B9Menu_textures.VirtualKeyboardEnglish.a1'
	fKeyboard[40]=Texture'B9Menu_textures.VirtualKeyboardEnglish.a2'
	fKeyboard[41]=Texture'B9Menu_textures.VirtualKeyboardEnglish.a3'
	fKeyboard[42]=Texture'B9Menu_textures.VirtualKeyboardEnglish.b1'
	fKeyboard[43]=Texture'B9Menu_textures.VirtualKeyboardEnglish.b2'
	fKeyboard[44]=Texture'B9Menu_textures.VirtualKeyboardEnglish.b3'
	fKeyboard[45]=Texture'B9Menu_textures.VirtualKeyboardEnglish.C1'
	fKeyboard[46]=Texture'B9Menu_textures.VirtualKeyboardEnglish.C2'
	fKeyboard[47]=Texture'B9Menu_textures.VirtualKeyboardEnglish.C3'
	fKeyboard[48]=Texture'B9Menu_textures.VirtualKeyboardEnglish.D1'
	fKeyboard[49]=Texture'B9Menu_textures.VirtualKeyboardEnglish.D2'
	fKeyboard[50]=Texture'B9Menu_textures.VirtualKeyboardEnglish.D3'
	fKeyboard[51]=Texture'B9Menu_textures.VirtualKeyboardEnglish.E1'
	fKeyboard[52]=Texture'B9Menu_textures.VirtualKeyboardEnglish.E2'
	fKeyboard[53]=Texture'B9Menu_textures.VirtualKeyboardEnglish.E3'
	fKeyboard[54]=Texture'B9Menu_textures.VirtualKeyboardEnglish.F1'
	fKeyboard[55]=Texture'B9Menu_textures.VirtualKeyboardEnglish.F2'
	fKeyboard[56]=Texture'B9Menu_textures.VirtualKeyboardEnglish.F3'
	fKeyboard[57]=Texture'B9Menu_textures.VirtualKeyboardEnglish.G1'
	fKeyboard[58]=Texture'B9Menu_textures.VirtualKeyboardEnglish.G2'
	fKeyboard[59]=Texture'B9Menu_textures.VirtualKeyboardEnglish.G3'
	fKeyboard[60]=Texture'B9Menu_textures.VirtualKeyboardEnglish.H1'
	fKeyboard[61]=Texture'B9Menu_textures.VirtualKeyboardEnglish.H2'
	fKeyboard[62]=Texture'B9Menu_textures.VirtualKeyboardEnglish.H3'
	fKeyboard[63]=Texture'B9Menu_textures.VirtualKeyboardEnglish.i1'
	fKeyboard[64]=Texture'B9Menu_textures.VirtualKeyboardEnglish.i2'
	fKeyboard[65]=Texture'B9Menu_textures.VirtualKeyboardEnglish.i3'
	fKeyboard[66]=Texture'B9Menu_textures.VirtualKeyboardEnglish.J1'
	fKeyboard[67]=Texture'B9Menu_textures.VirtualKeyboardEnglish.J2'
	fKeyboard[68]=Texture'B9Menu_textures.VirtualKeyboardEnglish.J3'
	fKeyboard[69]=Texture'B9Menu_textures.VirtualKeyboardEnglish.K1'
	fKeyboard[70]=Texture'B9Menu_textures.VirtualKeyboardEnglish.K2'
	fKeyboard[71]=Texture'B9Menu_textures.VirtualKeyboardEnglish.K3'
	fKeyboard[72]=Texture'B9Menu_textures.VirtualKeyboardEnglish.L1'
	fKeyboard[73]=Texture'B9Menu_textures.VirtualKeyboardEnglish.L2'
	fKeyboard[74]=Texture'B9Menu_textures.VirtualKeyboardEnglish.L3'
	fKeyboard[75]=Texture'B9Menu_textures.VirtualKeyboardEnglish.M1'
	fKeyboard[76]=Texture'B9Menu_textures.VirtualKeyboardEnglish.M2'
	fKeyboard[77]=Texture'B9Menu_textures.VirtualKeyboardEnglish.m3'
	fKeyboard[78]=Texture'B9Menu_textures.VirtualKeyboardEnglish.NN1'
	fKeyboard[79]=Texture'B9Menu_textures.VirtualKeyboardEnglish.NN2'
	fKeyboard[80]=Texture'B9Menu_textures.VirtualKeyboardEnglish.NN3'
	fKeyboard[81]=Texture'B9Menu_textures.VirtualKeyboardEnglish.OO1'
	fKeyboard[82]=Texture'B9Menu_textures.VirtualKeyboardEnglish.OO2'
	fKeyboard[83]=Texture'B9Menu_textures.VirtualKeyboardEnglish.OO3'
	fKeyboard[84]=Texture'B9Menu_textures.VirtualKeyboardEnglish.PP1'
	fKeyboard[85]=Texture'B9Menu_textures.VirtualKeyboardEnglish.PP2'
	fKeyboard[86]=Texture'B9Menu_textures.VirtualKeyboardEnglish.PP3'
	fKeyboard[87]=Texture'B9Menu_textures.VirtualKeyboardEnglish.QQ1'
	fKeyboard[88]=Texture'B9Menu_textures.VirtualKeyboardEnglish.QQ2'
	fKeyboard[89]=Texture'B9Menu_textures.VirtualKeyboardEnglish.QQ3'
	fKeyboard[90]=Texture'B9Menu_textures.VirtualKeyboardEnglish.RR1'
	fKeyboard[91]=Texture'B9Menu_textures.VirtualKeyboardEnglish.RR2'
	fKeyboard[92]=Texture'B9Menu_textures.VirtualKeyboardEnglish.RR3'
	fKeyboard[93]=Texture'B9Menu_textures.VirtualKeyboardEnglish.SS1'
	fKeyboard[94]=Texture'B9Menu_textures.VirtualKeyboardEnglish.SS2'
	fKeyboard[95]=Texture'B9Menu_textures.VirtualKeyboardEnglish.SS3'
	fKeyboard[96]=Texture'B9Menu_textures.VirtualKeyboardEnglish.TT1'
	fKeyboard[97]=Texture'B9Menu_textures.VirtualKeyboardEnglish.TT2'
	fKeyboard[98]=Texture'B9Menu_textures.VirtualKeyboardEnglish.TT3'
	fKeyboard[99]=Texture'B9Menu_textures.VirtualKeyboardEnglish.UU1'
	fKeyboard[100]=Texture'B9Menu_textures.VirtualKeyboardEnglish.UU2'
	fKeyboard[101]=Texture'B9Menu_textures.VirtualKeyboardEnglish.UU3'
	fKeyboard[102]=Texture'B9Menu_textures.VirtualKeyboardEnglish.VV1'
	fKeyboard[103]=Texture'B9Menu_textures.VirtualKeyboardEnglish.VV2'
	fKeyboard[104]=Texture'B9Menu_textures.VirtualKeyboardEnglish.VV3'
	fKeyboard[105]=Texture'B9Menu_textures.VirtualKeyboardEnglish.WW1'
	fKeyboard[106]=Texture'B9Menu_textures.VirtualKeyboardEnglish.WW2'
	fKeyboard[107]=Texture'B9Menu_textures.VirtualKeyboardEnglish.WW3'
	fKeyboard[108]=Texture'B9Menu_textures.VirtualKeyboardEnglish.XX1'
	fKeyboard[109]=Texture'B9Menu_textures.VirtualKeyboardEnglish.XX2'
	fKeyboard[110]=Texture'B9Menu_textures.VirtualKeyboardEnglish.XX3'
	fKeyboard[111]=Texture'B9Menu_textures.VirtualKeyboardEnglish.YY1'
	fKeyboard[112]=Texture'B9Menu_textures.VirtualKeyboardEnglish.YY2'
	fKeyboard[113]=Texture'B9Menu_textures.VirtualKeyboardEnglish.YY3'
	fKeyboard[114]=Texture'B9Menu_textures.VirtualKeyboardEnglish.ZZ1'
	fKeyboard[115]=Texture'B9Menu_textures.VirtualKeyboardEnglish.ZZ2'
	fKeyboard[116]=Texture'B9Menu_textures.VirtualKeyboardEnglish.ZZ3'
	fKeyboard[117]=Texture'B9Menu_textures.VirtualKeyboardEnglish.N1'
	fKeyboard[118]=Texture'B9Menu_textures.VirtualKeyboardEnglish.N2'
	fKeyboard[119]=Texture'B9Menu_textures.VirtualKeyboardEnglish.N3'
	fKeyboard[120]=Texture'B9Menu_textures.VirtualKeyboardEnglish.o1'
	fKeyboard[121]=Texture'B9Menu_textures.VirtualKeyboardEnglish.o2'
	fKeyboard[122]=Texture'B9Menu_textures.VirtualKeyboardEnglish.o3'
	fKeyboard[123]=Texture'B9Menu_textures.VirtualKeyboardEnglish.P1'
	fKeyboard[124]=Texture'B9Menu_textures.VirtualKeyboardEnglish.P2'
	fKeyboard[125]=Texture'B9Menu_textures.VirtualKeyboardEnglish.p3'
	fKeyboard[126]=Texture'B9Menu_textures.VirtualKeyboardEnglish.Q1'
	fKeyboard[127]=Texture'B9Menu_textures.VirtualKeyboardEnglish.Q2'
	fKeyboard[128]=Texture'B9Menu_textures.VirtualKeyboardEnglish.Q3'
	fKeyboard[129]=Texture'B9Menu_textures.VirtualKeyboardEnglish.R1'
	fKeyboard[130]=Texture'B9Menu_textures.VirtualKeyboardEnglish.R2'
	fKeyboard[131]=Texture'B9Menu_textures.VirtualKeyboardEnglish.R3'
	fKeyboard[132]=Texture'B9Menu_textures.VirtualKeyboardEnglish.S1'
	fKeyboard[133]=Texture'B9Menu_textures.VirtualKeyboardEnglish.S2'
	fKeyboard[134]=Texture'B9Menu_textures.VirtualKeyboardEnglish.S3'
	fKeyboard[135]=Texture'B9Menu_textures.VirtualKeyboardEnglish.T1'
	fKeyboard[136]=Texture'B9Menu_textures.VirtualKeyboardEnglish.T2'
	fKeyboard[137]=Texture'B9Menu_textures.VirtualKeyboardEnglish.T3'
	fKeyboard[138]=Texture'B9Menu_textures.VirtualKeyboardEnglish.U1'
	fKeyboard[139]=Texture'B9Menu_textures.VirtualKeyboardEnglish.U2'
	fKeyboard[140]=Texture'B9Menu_textures.VirtualKeyboardEnglish.U3'
	fKeyboard[141]=Texture'B9Menu_textures.VirtualKeyboardEnglish.v1'
	fKeyboard[142]=Texture'B9Menu_textures.VirtualKeyboardEnglish.v2'
	fKeyboard[143]=Texture'B9Menu_textures.VirtualKeyboardEnglish.V3'
	fKeyboard[144]=Texture'B9Menu_textures.VirtualKeyboardEnglish.W1'
	fKeyboard[145]=Texture'B9Menu_textures.VirtualKeyboardEnglish.W2'
	fKeyboard[146]=Texture'B9Menu_textures.VirtualKeyboardEnglish.W3'
	fKeyboard[147]=Texture'B9Menu_textures.VirtualKeyboardEnglish.x1'
	fKeyboard[148]=Texture'B9Menu_textures.VirtualKeyboardEnglish.x2'
	fKeyboard[149]=Texture'B9Menu_textures.VirtualKeyboardEnglish.X3'
	fKeyboard[150]=Texture'B9Menu_textures.VirtualKeyboardEnglish.y1'
	fKeyboard[151]=Texture'B9Menu_textures.VirtualKeyboardEnglish.y2'
	fKeyboard[152]=Texture'B9Menu_textures.VirtualKeyboardEnglish.Y3'
	fKeyboard[153]=Texture'B9Menu_textures.VirtualKeyboardEnglish.Z1'
	fKeyboard[154]=Texture'B9Menu_textures.VirtualKeyboardEnglish.Z2'
	fKeyboard[155]=Texture'B9Menu_textures.VirtualKeyboardEnglish.Z3'
	fKeyboard[156]=Texture'B9Menu_textures.VirtualKeyboardEnglish.one1'
	fKeyboard[157]=Texture'B9Menu_textures.VirtualKeyboardEnglish.one2'
	fKeyboard[158]=Texture'B9Menu_textures.VirtualKeyboardEnglish.one3'
	fKeyboard[159]=Texture'B9Menu_textures.VirtualKeyboardEnglish.two1'
	fKeyboard[160]=Texture'B9Menu_textures.VirtualKeyboardEnglish.two2'
	fKeyboard[161]=Texture'B9Menu_textures.VirtualKeyboardEnglish.two3'
	fKeyboard[162]=Texture'B9Menu_textures.VirtualKeyboardEnglish.three1'
	fKeyboard[163]=Texture'B9Menu_textures.VirtualKeyboardEnglish.three2'
	fKeyboard[164]=Texture'B9Menu_textures.VirtualKeyboardEnglish.three3'
	fKeyboard[165]=Texture'B9Menu_textures.VirtualKeyboardEnglish.four1'
	fKeyboard[166]=Texture'B9Menu_textures.VirtualKeyboardEnglish.four2'
	fKeyboard[167]=Texture'B9Menu_textures.VirtualKeyboardEnglish.four3'
	fKeyboard[168]=Texture'B9Menu_textures.VirtualKeyboardEnglish.five1'
	fKeyboard[169]=Texture'B9Menu_textures.VirtualKeyboardEnglish.five2'
	fKeyboard[170]=Texture'B9Menu_textures.VirtualKeyboardEnglish.five3'
	fKeyboard[171]=Texture'B9Menu_textures.VirtualKeyboardEnglish.six1'
	fKeyboard[172]=Texture'B9Menu_textures.VirtualKeyboardEnglish.six2'
	fKeyboard[173]=Texture'B9Menu_textures.VirtualKeyboardEnglish.six3'
	fKeyboard[174]=Texture'B9Menu_textures.VirtualKeyboardEnglish.seven1'
	fKeyboard[175]=Texture'B9Menu_textures.VirtualKeyboardEnglish.seven2'
	fKeyboard[176]=Texture'B9Menu_textures.VirtualKeyboardEnglish.seven3'
	fKeyboard[177]=Texture'B9Menu_textures.VirtualKeyboardEnglish.eight1'
	fKeyboard[178]=Texture'B9Menu_textures.VirtualKeyboardEnglish.eight2'
	fKeyboard[179]=Texture'B9Menu_textures.VirtualKeyboardEnglish.eight3'
	fKeyboard[180]=Texture'B9Menu_textures.VirtualKeyboardEnglish.nine1'
	fKeyboard[181]=Texture'B9Menu_textures.VirtualKeyboardEnglish.nine2'
	fKeyboard[182]=Texture'B9Menu_textures.VirtualKeyboardEnglish.nine3'
	fKeyboard[183]=Texture'B9Menu_textures.VirtualKeyboardEnglish.zero1'
	fKeyboard[184]=Texture'B9Menu_textures.VirtualKeyboardEnglish.zero2'
	fKeyboard[185]=Texture'B9Menu_textures.VirtualKeyboardEnglish.zero3'
	fKeyboard[186]=Texture'B9Menu_textures.VirtualKeyboardEnglish.NameBack1'
	fKeyboard[187]=Texture'B9Menu_textures.VirtualKeyboardEnglish.NameBack2'
	fKeyboard[188]=Texture'B9Menu_textures.VirtualKeyboardEnglish.NameBack3'
	fKeyboard[189]=Texture'B9Menu_textures.VirtualKeyboardEnglish.NameClear1'
	fKeyboard[190]=Texture'B9Menu_textures.VirtualKeyboardEnglish.NameClear2'
	fKeyboard[191]=Texture'B9Menu_textures.VirtualKeyboardEnglish.NameClear3'
	fKeyboard[192]=Texture'B9Menu_textures.VirtualKeyboardEnglish.VKE_done1'
	fKeyboard[193]=Texture'B9Menu_textures.VirtualKeyboardEnglish.VKE_done2'
	fKeyboard[194]=Texture'B9Menu_textures.VirtualKeyboardEnglish.VKE_done3'
	fKeyList="ABCDEFGHIJKLMabcdefghijklmNOPQRSTUVWXYZnopqrstuvwxyz1234567890"
	fUppercase="AABBCCDDEEFFGGHHIIJJKKLLMMNNOOPPQQRRSSTTUUVVWWXXYYZZ"
	fLowercase="abcdefghijklmnopqrstuvwxyz"
	fNumbers="0123456789"
	MSA24Font=Font'B9_Fonts.MicroscanA24'
}