/////////////////////////////////////////////////////////////
// B9_MM_NewCareerStatsMenu
//

class B9_MM_NewCareerStatsMenu extends B9_MMInteraction;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX

var private sound fUpSound;
var private sound fDownSound;
var private sound fClickSound;
var private sound fCancelSound;

var private int fLtWidth;
var private int fLtHeight;
var private int fRtWidth;
var private int fRtHeight;

var private int fStatsX;
var private int fStatsY;
var private int fStatsOffY;
var private int fNumOffX;
	
var private int fDistRandomX;
var private int fDistRandomY;

var private int fDoneX;
var private int fDoneY;

var private localized string fStatNameStr;
var private localized string fStatNameAgl;
var private localized string fStatNameDex;
var private localized string fStatNameCon;

var private localized string fStrDistRandomly;
var private localized string fStrDone;
var private localized string fStrYouHave;
var private localized string fStrPoints;

var int fSelItem;
var int fNumItems;

var int fStr;
var int fAgl;
var int fDex;
var int fCon;

var int fBaseStr;
var int fBaseAgl;
var int fBaseDex;
var int fBaseCon;

var int PtsToDistr;
var int BasePtsToDistr;

var string fStatName[4];
var int fStatBase[4];
var int fStatValue[4];

var font fMyFont;

var private EInputKey fKeyDown;
var private float fByeByeTicks;
var private float fRepeatTicksX;
var private float fRepeatTicksY;
var private float fMouseDragX;
var private float fMouseDragY;
var private float fDragRes;

var private texture fAcceptImage;
var private texture fRejectImage;

//var() localized string MSA24Font;
var localized font MSA24Font;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentController. You don't have to implement MenuInit(),
// but you should call super.MenuInit().
function Initialized()
{
	fDragRes = 10.0f;

	fNumItems = 6;
	fSelItem = fNumItems - 1;

	fStatName[0] = fStatNameStr;
	fStatName[1] = fStatNameAgl;
	fStatName[2] = fStatNameDex;
	fStatName[3] = fStatNameCon;

	PtsToDistr = 20;
	BasePtsToDistr = 20;

	fStatsX = 384;
	fStatsY = 203;
	fStatsOffY = 30;
	fNumOffX = 100;
	
	fDistRandomX = 340;
	fDistRandomY = 203 + 120;

	fDoneX = 340;
	fDoneY = 203 + 150;

	fMyFont = MSA24Font; //LoadFont( MSA24Font );

	fAcceptImage = texture'B9MenuHelp_Textures.choice_select';
	fRejectImage = texture'B9MenuHelp_Textures.choice_back';
}

function SetStats(int str, int agl, int dex, int con)
{
	fStatValue[0] = str;
	fStatValue[1] = agl;
	fStatValue[2] = dex;
	fStatValue[3] = con;

	fStatBase[0] = str;
	fStatBase[1] = agl;
	fStatBase[2] = dex;
	fStatBase[3] = con;
}

function GetStats(out int str, out int agl, out int dex, out int con)
{
	str = fStatValue[0];
	agl = fStatValue[1];
	dex = fStatValue[2];
	con = fStatValue[3];
}

function Tick(float Delta)
{
	local bool change;
	
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

	if (fKeyDown == IK_LeftMouse)
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
			if (MouseX < fStatsX + fNumOffX + 24)
			{
				if (ChangeStat(-1, 0.5f))
					RootController.PlaySound( fDownSound );
			}
			else
			{
				if (ChangeStat(1, 0.5f))
					RootController.PlaySound( fUpSound );
			}
		}
	}
	else if (fKeyDown == IK_Left || fKeyDown == IK_Right)
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
				if (ChangeStat(-1, 0.5f))
					RootController.PlaySound( fDownSound );
			}
			else if (fKeyDown == IK_Right)
			{
				if (ChangeStat(1, 0.5f))
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
				SelectItem((fSelItem - 1 + fNumItems) % fNumItems, 0.5f);
				RootController.PlaySound( fUpSound );
			}
			else if (fKeyDown == IK_Down)
			{
				SelectItem((fSelItem + 1) % fNumItems, 0.5f);
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

function DrawStat( canvas Canvas, int X, int Y, string name, int value )
{
	local float sx, sy;
	local string val;

	val = string(value);

	Canvas.Style = RootController.ERenderStyle.STY_Normal;

	Canvas.SetPos( X, Y );
	Canvas.DrawText( name, false );

	Canvas.TextSize( val, sx, sy );

	Canvas.SetPos( X + fNumOffX + 24 - sx / 2, Y );
	Canvas.DrawText( val, false );

	if (bDrawMouse)
	{
		Canvas.TextSize( "<", sx, sy );
		Canvas.SetPos( X + fNumOffX - sx, Y );
		Canvas.DrawText( "<", false );

		Canvas.SetPos( X + fNumOffX + 48, Y );
		Canvas.DrawText( ">", false );
	}
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

	x = fStatsX;
	y = fStatsY;
	for (i=0;i<fNumItems-2;i++)
	{
		if (fSelItem == i)
			Canvas.SetDrawColor(white.R, white.G, white.B);
		else
			Canvas.SetDrawColor(cyan.R, cyan.G, cyan.B);

		DrawStat( Canvas, x, y + fStatsOffY * i, fStatName[i], fStatValue[i]);
	}

	if (fSelItem == fNumItems - 2)
		Canvas.SetDrawColor(white.R, white.G, white.B);
	else
		Canvas.SetDrawColor(cyan.R, cyan.G, cyan.B);

	Canvas.TextSize( fStrDistRandomly, sx, sy );
	Canvas.SetPos( float(fDistRandomX) - sx / 2.0f, fDistRandomY );
	Canvas.DrawText( fStrDistRandomly, false );

	if (fSelItem == fNumItems - 1)
		Canvas.SetDrawColor(white.R, white.G, white.B);
	else
		Canvas.SetDrawColor(cyan.R, cyan.G, cyan.B);

	Canvas.TextSize( fStrDone, sx, sy );
	Canvas.SetPos( float(fDoneX) - sx / 2.0f, fDoneY );
	Canvas.DrawText( fStrDone, false );

	Canvas.Style = RootController.ERenderStyle.STY_Normal;
	Canvas.SetDrawColor(white.R, white.G, white.B);

	Canvas.TextSize( fStrYouHave, sx, sy );
	Canvas.SetPos( 242.0f - sx / 2.0f, 203 );
	Canvas.DrawText( fStrYouHave, false );

	Canvas.TextSize( string(PtsToDistr), sx, sy );
	Canvas.SetPos( 242.0f - sx / 2.0f, 233 );
	Canvas.DrawText( string(PtsToDistr), false );

	Canvas.TextSize( fStrPoints, sx, sy );
	Canvas.SetPos( 242.0f - sx / 2.0f, 263 );
	Canvas.DrawText( fStrPoints, false );

	Canvas.Font = oldFont;

	Canvas.SetDrawColor(white.R, white.G, white.B);

	Canvas.SetPos( 64, 416 );
	Canvas.DrawTile( fAcceptImage, fLtWidth, fLtHeight, 0, 0, fLtWidth, fLtHeight );

	Canvas.SetPos( 320, 416 );
	Canvas.DrawTile( fRejectImage, fLtWidth, fLtHeight, 0, 0, fLtWidth, fLtHeight );
}

function SelectItem( int n, float ticks )
{
	fSelItem = n;
	fRepeatTicksY = ticks;
}

function BackButton()
{
	fByeByeTicks = 0.5f;
	fKeyDown = IK_Backspace;
	RootController.PlaySound( fCancelSound );
}

function ClickItem()
{
	if (fSelItem == fNumItems - 1)
	{
		// DONE
		fByeByeTicks = 0.5f;
		fKeyDown = IK_Enter;
		RootController.PlaySound( fClickSound );
	}
	else if (fSelItem == fNumItems - 2)
	{
		// RANDOMIZE
		fStatValue[0] = fStatBase[0];
		fStatValue[1] = fStatBase[1];
		fStatValue[2] = fStatBase[2];
		fStatValue[3] = fStatBase[3];
		PtsToDistr = BasePtsToDistr;
		while (PtsToDistr > 0)
		{
			fStatValue[Rand(4)] += 1;
			PtsToDistr -= 1;
		}
		RootController.PlaySound( fClickSound );
	}
	else if (bDrawMouse)
	{
		if (MouseX < fStatsX + fNumOffX + 24)
		{
			ChangeStat(-1, 1.0f);
			fKeyDown = IK_LeftMouse;
		}
		else
		{
			ChangeStat(1, 1.0f);
			fKeyDown = IK_LeftMouse;
		}
	}
	else
	{
		fKeyDown = IK_LeftMouse;
		RootController.PlaySound( fClickSound );
	}
}

function bool ChangeStat(int d, float ticks)
{
	if (fSelItem >= 4)
		return false;

	if (d == -1)
	{
		if (fStatValue[fSelItem] == fStatBase[fSelItem])
			return false;
		fStatValue[fSelItem] -= 1;
		PtsToDistr += 1;
	}
	else if (d == 1)
	{
		if (PtsToDistr == 0)
			return false;
		fStatValue[fSelItem] += 1;
		PtsToDistr -= 1;
	}
	fRepeatTicksX = ticks;
	return true;
}

function HighlightByMouse()
{
	local int i, x, y;

	if (fKeyDown == IK_None)
	{
		if (fDistRandomX - 256 <= MouseX && MouseX < fDistRandomX + 256 &&
			fDistRandomY <= MouseY && MouseY < fDistRandomY + 24)
		{
			fSelItem = fNumItems - 2;
			return;
		}

		if (fDoneX - 256 <= MouseX && MouseX < fDoneX + 256 &&
			fDoneY <= MouseY && MouseY < fDoneY + 24)
		{
			fSelItem = fNumItems - 1;
			return;
		}

		x = fStatsX;
		y = fStatsY;
		for (i=0;i<fNumItems-2;i++)
		{
			if (x <= MouseX && MouseX < x + fNumOffX + 75 && y <= MouseY && MouseY < y + 24)
			{
				fSelItem = i;
				return;
			}

			y += fStatsOffY;
		}
	}
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local Pawn pawn, oldPawn;

	Key = ConvertJoystick(Key);

	if (fByeByeTicks == 0.0f)
	{
		if( Action == IST_Press && (Key == IK_Enter || Key == IK_Space ||
			Key == IK_LeftMouse || Key == IK_Joy1) )
		{
			ClickItem();
		}
		else if( Action == IST_Release && (Key == IK_Enter || Key == IK_Space ||
			Key == IK_LeftMouse || Key == IK_Joy1) )
		{
			if (fKeyDown == IK_LeftMouse)
				fKeyDown = IK_None;
		}
		else if( Action == IST_Press && (Key == IK_Backspace || Key == IK_Escape ||
			Key == IK_RightMouse || Key == IK_Joy2) )
		{
			BackButton();
		}
		else if (bDrawMouse && (Key == IK_MouseX || Key == IK_MouseY))
		{
			HighlightByMouse();
		}
		else if( fKeyDown == IK_LeftMouse && Action == IST_Axis && Key == IK_MouseX )
		{
			if (Delta > 0)
			{
				if (fMouseDragX < 0)
					fMouseDragX = 0.0f;
				fMouseDragX += Delta;
				if (fRepeatTicksX == 0.0f && fMouseDragX >= fDragRes)
				{
					if (ChangeStat(1, 0.3f))
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
					if (ChangeStat(-1, 0.3f))
						RootController.PlaySound( fDownSound ); 	
					fMouseDragX = 0.0f;
				}
			}
		}
		else if( fKeyDown == IK_None && Action == IST_Axis && Key == IK_MouseY )
		{
			if (Delta > 0)
			{
				if (fMouseDragY < 0)
					fMouseDragY = 0.0f;
				fMouseDragY += Delta;
				if (fRepeatTicksY == 0.0f && fMouseDragY >= fDragRes)
				{
					SelectItem((fSelItem - 1 + fNumItems) % fNumItems, 0.25f);
					RootController.PlaySound( fUpSound ); 	
					fMouseDragX = 0.0f;
				}
			}
			else if (Delta < 0)
			{
				if (fMouseDragY > 0)
					fMouseDragY = 0.0f;
				fMouseDragY += Delta;
				if (fRepeatTicksY == 0.0f && fMouseDragY <= -fDragRes)
				{
					SelectItem((fSelItem + 1) % fNumItems, 0.25f);
					RootController.PlaySound( fDownSound ); 	
					fMouseDragY = 0.0f;
				}
			}
		}
		else if( Action == IST_Press && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
		{
			if (fKeyDown == IK_None)
			{
				SelectItem((fSelItem - 1 + fNumItems) % fNumItems, 0.5f);
				fKeyDown = IK_Up;
				RootController.PlaySound( fUpSound ); 	
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
				SelectItem((fSelItem + 1) % fNumItems, 0.5f);
				fKeyDown = IK_Down;
				RootController.PlaySound( fDownSound );	
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
				if (ChangeStat(-1, 0.5f))
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
				if (ChangeStat(1, 0.5f))
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
	fStatNameStr="STR: "
	fStatNameAgl="AGL: "
	fStatNameDex="DEX: "
	fStatNameCon="CON: "
	fStrDistRandomly="DISTRIBUTE RANDOMLY"
	fStrDone="DONE"
	fStrYouHave="YOU HAVE"
	fStrPoints="POINTS"
	MSA24Font=Font'B9_Fonts.MicroscanA24'
}