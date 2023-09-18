/////////////////////////////////////////////////////////////
// B9_MM_NewCareerPickMenu
//

class B9_MM_NewCareerPickMenu extends B9_MMInteraction;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX

var private sound fUpSound;
var private sound fDownSound;
var private sound fClickSound;
var private sound fCancelSound;

var private int fLtWidth;
var private int fLtHeight;
var private int fRtWidth;
var private int fRtHeight;

var private localized string fStatNameStr;
var private localized string fStatNameAgl;
var private localized string fStatNameDex;
var private localized string fStatNameCon;

var private int fStatValueStr0;
var private int fStatValueAgl0;
var private int fStatValueDex0;
var private int fStatValueCon0;
var private localized string fCharName0;
var private class<Pawn> fCharClass0;

var private int fStatValueStr1;
var private int fStatValueAgl1;
var private int fStatValueDex1;
var private int fStatValueCon1;
var private localized string fCharName1;
var private class<Pawn> fCharClass1;

var private int fStatValueStr2;
var private int fStatValueAgl2;
var private int fStatValueDex2;
var private int fStatValueCon2;
var private localized string fCharName2;
var private class<Pawn> fCharClass2;

var private int fStatValueStr3;
var private int fStatValueAgl3;
var private int fStatValueDex3;
var private int fStatValueCon3;
var private localized string fCharName3;
var private class<Pawn> fCharClass3;

var private int fStatValueStr4;
var private int fStatValueAgl4;
var private int fStatValueDex4;
var private int fStatValueCon4;
var private localized string fCharName4;
var private class<Pawn> fCharClass4;

var private localized string fStrDone;

var int fSelItem;
var int fNumItems;
var bool bHilightDone;

var string fStatName[5];
var int fStatValue[20];
var string fCharName[5];
var class<Pawn> fCharClass[5];
var name fLookAtName[5];
var name fLocationName[5];

var font fMyFont;

var private EInputKey fKeyDown;
var private float fByeByeTicks;
var private float fRepeatTicksX;
//var private float fRepeatTicksY;
var private float fMouseDragX;
//var private float fMouseDragY;
var private float fDragRes;
var private float fPreLookTicks;

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

	fSelItem = 0;
	fNumItems = 3;  //DP - set to 4 after E3 - only Sahara and Jake should be playable at E3, re-enabling Gruber for testing

	fStatName[0] = fStatNameStr;
	fStatName[1] = fStatNameAgl;
	fStatName[2] = fStatNameDex;
	fStatName[3] = fStatNameCon;

	fStatValue[0] = fStatValueStr0;
	fStatValue[1] = fStatValueAgl0;
	fStatValue[2] = fStatValueDex0;
	fStatValue[3] = fStatValueCon0;
	fCharName[0] = fCharName0;
	fCharClass[0] = fCharClass0;
	fLookAtName[0] = 'LookTarget0';
	fLocationName[0] = 'LookTarget5';

	fStatValue[4] = fStatValueStr1;
	fStatValue[5] = fStatValueAgl1;
	fStatValue[6] = fStatValueDex1;
	fStatValue[7] = fStatValueCon1;
	fCharName[1] = fCharName1;
	fCharClass[1] = fCharClass1;
	fLookAtName[1] = 'LookTarget3';
	fLocationName[1] = 'LookTarget7';

	fStatValue[8] = fStatValueStr2;
	fStatValue[9] = fStatValueAgl2;
	fStatValue[10] = fStatValueDex2;
	fStatValue[11] = fStatValueCon2;
	fCharName[2] = fCharName2;
	fCharClass[2] = fCharClass2;
	fLookAtName[2] = 'LookTarget2';
	fLocationName[2] = 'LookTarget6';

	fStatValue[12] = fStatValueStr3;
	fStatValue[13] = fStatValueAgl3;
	fStatValue[14] = fStatValueDex3;
	fStatValue[15] = fStatValueCon3;
	fCharName[3] = fCharName3;
	fCharClass[3] = fCharClass3;
	fLookAtName[3] = 'LookTarget1';
	fLocationName[3] = 'LookTarget4';

	fStatValue[16] = fStatValueStr4;
	fStatValue[17] = fStatValueAgl4;
	fStatValue[18] = fStatValueDex4;
	fStatValue[19] = fStatValueCon4;
	fCharName[4] = fCharName4;
	fCharClass[4] = fCharClass4;
	fLookAtName[4] = 'LookTarget0';
	fLocationName[4] = 'LookTarget5';

	fMyFont = MSA24Font; //LoadFont( MSA24Font );

	fAcceptImage = texture'B9MenuHelp_Textures.choice_select';

	fRejectImage = texture'B9MenuHelp_Textures.choice_back';
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	Super.MenuInit(interaction, controller, parent);

	SwitchToMatinee('');
	fPreLookTicks = 0.25f;
}

function GetPick(out int str, out int agl, out int dex, out int con, out string cname, out class<Pawn> ccname)
{
	str = fStatValue[0 + 4 * fSelItem];
	agl = fStatValue[1 + 4 * fSelItem];
	dex = fStatValue[2 + 4 * fSelItem];
	con = fStatValue[3 + 4 * fSelItem];
	cname = fCharName[fSelItem];
	ccname = fCharClass[fSelItem];
}

function Tick(float Delta)
{
	local bool change;
	
	if (fPreLookTicks > 0f)
	{
		fPreLookTicks -= Delta;
		if (fPreLookTicks <= 0f)
		{
			fPreLookTicks = 0;
			ViewActor('LookTarget0', 'LookTarget5');
		}
	}

	if (fByeByeTicks > 0f)
	{
		fByeByeTicks -= Delta;
		if (fByeByeTicks <= 0.0f)
		{
			if (fKeyDown == IK_Enter)
			{
				B9_MMInteraction(ParentInteraction).EndMenu(self, 0);
			}
			else if (fKeyDown == IK_Backspace)
			{
				RootController.SetViewTarget(B9_MMInteraction(RootInteraction).startingViewTarget);
				B9_MMInteraction(ParentInteraction).EndMenu(self, -1);
			}
		}

		return;
	}

	if (fKeyDown == IK_LeftMouse)
	{
		fRepeatTicksX -= Delta;
		if (fRepeatTicksX <= 0.0f)
		{
			change = true;
			fRepeatTicksX = 0.25;
		}

		if (change)
		{
			if (MouseX < 320)
				ChangePick(-1, 1.0f);
			else
				ChangePick(1, 1.0f);
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
				ChangePick(-1, 0.5f);
				RootController.PlaySound( fUpSound );
			}
			else if (fKeyDown == IK_Right)
			{
				ChangePick(1, 0.5f);
				RootController.PlaySound( fDownSound );
			}
		}
	}
	else if (fRepeatTicksX > 0.0f)
	{
		fRepeatTicksX -= Delta;
		if (fRepeatTicksX < 0.0f)
			fRepeatTicksX = 0.0f;
	}
}

function DrawStat( canvas Canvas, int X, int Y, string name, int value )
{
	Canvas.Style = RootController.ERenderStyle.STY_Normal;

	Canvas.SetPos( X, Y );
	Canvas.DrawText( name, false );

	Canvas.SetPos( X + 80, Y );
	Canvas.DrawText( string(value), false );
}

function PostRender( canvas Canvas )
{
	local int i, j, x, y;
	local color white, cyan, ltgreen;
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

	ltgreen.R = 64;
	ltgreen.G = 255;
	ltgreen.B = 64;

	x = 384;
	y = 203;
	j = 4 * fSelItem;
	for (i=0;i<4;i++)
	{
		Canvas.SetDrawColor(cyan.R, cyan.G, cyan.B);

		DrawStat( Canvas, x, y + 30 * i, fStatName[i], fStatValue[i + j]);
	}

	Canvas.SetDrawColor(ltgreen.R, ltgreen.G, ltgreen.B);

	Canvas.TextSize( fCharName[fSelItem], sx, sy );
	Canvas.SetPos( 340.0f - sx / 2.0f, y + 5 * 30 );
	Canvas.DrawText( fCharName[fSelItem], false );

	if (bDrawMouse)
	{
		if (bHilightDone)
			Canvas.SetDrawColor(white.R, white.G, white.B);
		else
			Canvas.SetDrawColor(cyan.R, cyan.G, cyan.B);

		Canvas.TextSize( fStrDone, sx, sy );
		Canvas.SetPos( 340.0f - sx / 2.0f, y + 6 * 30 );
		Canvas.DrawText( fStrDone, false );
	}

	Canvas.Font = oldFont;


	Canvas.SetDrawColor(white.R, white.G, white.B);

	Canvas.SetPos( 64, 416 );
	Canvas.DrawTile( fAcceptImage, fLtWidth, fLtHeight, 0, 0, fLtWidth, fLtHeight );

	Canvas.SetPos( 320, 416 );
	Canvas.DrawTile( fRejectImage, fLtWidth, fLtHeight, 0, 0, fLtWidth, fLtHeight );
}

function BackButton()
{
	fByeByeTicks = 0.5f;
	fKeyDown = IK_Backspace;
	RootController.PlaySound( fCancelSound );
}

function ClickItem()
{
	// DONE
	if (bDrawMouse)
	{
		if (bHilightDone)
		{
			fByeByeTicks = 0.5f;
			fKeyDown = IK_Enter;
			RootController.PlaySound( fClickSound );
		}
		else if (MouseX < 320)
		{
			ChangePick(-1, 1.0f);
			fKeyDown = IK_LeftMouse;
		}
		else
		{
			ChangePick(1, 1.0f);
			fKeyDown = IK_LeftMouse;
		}
	}
	else
	{
		fByeByeTicks = 0.5f;
		fKeyDown = IK_Enter;
		RootController.PlaySound( fClickSound );
	}
}

function ChangePick(int d, float ticks)
{
	fSelItem = (fSelItem + fNumItems + d) % fNumItems;
	fRepeatTicksX = ticks;
	ViewActor(fLookAtName[fSelItem], fLocationName[fSelItem]);
}

function HighlightByMouse()
{
	local int x, y;

	if (fKeyDown == IK_None)
	{
		x = 340;
		y = 203 + 6 * 30;
		bHilightDone = (x - 48 <= MouseX && MouseX < x + 48 && y <= MouseY && MouseY < y + 24);
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
		else if( Action == IST_Axis && Key == IK_MouseX )
		{
			if (Delta > 0)
			{
				if (fMouseDragX < 0)
					fMouseDragX = 0.0f;
				fMouseDragX += Delta;
				if (fRepeatTicksX == 0.0f && fMouseDragX >= fDragRes)
				{
					ChangePick(1, 0.3f);
					RootController.PlaySound( fDownSound );
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
					ChangePick(-1, 0.3f);
					RootController.PlaySound( fUpSound ); 	
					fMouseDragX = 0.0f;
				}
			}
		}
		else if( Action == IST_Press && 
			(Key == IK_Left || Key == IK_Joy11 || Key == IK_GreyMinus || Key == IK_Minus) )
		{
			if (fKeyDown == IK_None)
			{
				ChangePick(-1, 0.5f);
				RootController.PlaySound( fUpSound ); 	
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
				ChangePick(1, 0.5f);
				RootController.PlaySound( fDownSound );	
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
	fStatValueStr0=15
	fStatValueAgl0=35
	fStatValueDex0=35
	fStatValueCon0=15
	fCharName0="Sahara"
	fCharClass0=Class'B9Characters.B9_player_norm_female'
	fStatValueStr1=15
	fStatValueAgl1=30
	fStatValueDex1=35
	fStatValueCon1=20
	fCharName1="Jake"
	fCharClass1=Class'B9Characters.B9_player_norm_male'
	fStatValueStr2=50
	fStatValueAgl2=20
	fStatValueDex2=20
	fStatValueCon2=50
	fCharName2="Gruber"
	fCharClass2=Class'B9Characters.B9_player_mutant_male'
	fStatValueStr3=25
	fStatValueAgl3=50
	fStatValueDex3=45
	fStatValueCon3=25
	fCharName3="Ylsa"
	fCharClass3=Class'B9Characters.B9_player_norm_female'
	fStatValueStr4=15
	fStatValueAgl4=35
	fStatValueDex4=35
	fStatValueCon4=15
	fCharName4="DemoGirl (DEBUG)"
	fCharClass4=Class'B9Characters.assassin'
	fStrDone="DONE"
	MSA24Font=Font'B9_Fonts.MicroscanA24'
}