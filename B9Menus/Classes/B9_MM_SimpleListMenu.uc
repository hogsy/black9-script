/////////////////////////////////////////////////////////////
// B9_MM_SimpleListMenu
//

class B9_MM_SimpleListMenu extends B9_MMInteraction;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX

struct SimpleItemInfo
{
	var int X;
	var int Y;

//	var texture UnselLt;
//	var texture UnselRt;
//	var texture SelLt;
//	var texture SelRt;
//	var texture ClickLt;
//	var texture ClickRt;

	var string Label;
};

struct SimpleImageInfo
{
	var int X;
	var int Y;
	var texture Image;
};

var private sound fUpSound;
var private sound fDownSound;
var private sound fClickSound;
var private sound fCancelSound;

var private int fLtWidth;
var private int fLtHeight;
var private int fRtWidth;
var private int fRtHeight;

var bool fHasGoBack;

var int fSelItem;
var int fNumItems;

var int fNumImages;

var EInputKey fKeyDown;
var private float fRepeatTicks;
var private float fByeByeTicks;
var private float fMouseDrag;
var private float fDragRes;

var array<SimpleItemInfo> fItemArray;
var array<SimpleImageInfo> fImageArray;

var font fMenuFont;

//var() localized string MSA28Font;
var localized font MSA28Font;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentController. You don't have to implement MenuInit(),
// but you should call super.MenuInit().
function Initialized()
{
	fSelItem = 0;
	fNumItems = fItemArray.Length;
	fKeyDown = IK_None;
	fNumImages = fImageArray.Length;
	fDragRes = 10.0f;

	fMenuFont = MSA28Font; //LoadFont( MSA28Font );
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
				B9_MMInteraction(ParentInteraction).EndMenu(self, fSelItem);
			else if (fKeyDown == IK_Backspace)
				B9_MMInteraction(ParentInteraction).EndMenu(self, -1);
		}

		return;
	}

	change = false;

	if (fKeyDown != IK_None)
	{
		fRepeatTicks -= Delta;
		if (fRepeatTicks <= 0.0f)
		{
			change = true;
			fRepeatTicks = 0.25;
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
	else if (fRepeatTicks > 0.0f)
	{
		fRepeatTicks -= Delta;
		if (fRepeatTicks < 0.0f)
			fRepeatTicks = 0.0f;
	}
}

function DrawSelector( canvas Canvas, int ltX, int ltY, string label )
{
	local float sx, sy;

	Canvas.TextSize(label, sx, sy);
	Canvas.SetPos( ltX + 256 - sx / 2, ltY );
	Canvas.DrawText( label, false );
}

function PostRender( canvas Canvas )
{
	local int i;
	local texture lt;
	local texture rt;
	local SimpleItemInfo info;
	local font oldFont;

	oldFont = Canvas.Font;
	Canvas.Font = fMenuFont;

	for (i=0;i<fItemArray.Length;i++)
	{
		info = fItemArray[i];
		if (i == fSelItem && fByeByeTicks > 0 && fKeyDown == IK_Enter)
		{
			Canvas.SetDrawColor(255, 165, 0);
		}
		else if (i == fSelItem)
		{
			Canvas.SetDrawColor(255, 255, 255);
		}
		else
		{
			Canvas.SetDrawColor(0, 255, 255);
		}
		DrawSelector( Canvas, info.X, info.Y, info.Label );
	}

	Canvas.Font = oldFont;
	Canvas.SetDrawColor(255, 255, 255);

	for (i=0;i<fImageArray.Length;i++)
	{
		Canvas.SetPos( fImageArray[i].X, fImageArray[i].Y );
		Canvas.DrawTile( fImageArray[i].Image, fLtWidth, fLtHeight, 0, 0, fLtWidth, fLtHeight );
	}
}

function HighlightByMouse()
{
	local SimpleItemInfo info;
	local int i;

	for (i=0;i<fItemArray.Length;i++)
	{
		info = fItemArray[i];
		if (info.X <= MouseX && MouseX < info.X + 512 && info.Y <= MouseY && MouseY < info.Y + 32)
		{
			fSelItem = i;
			return;
		}
	}
}

function SelectItem( int n, float ticks )
{
	fSelItem = n;
	fRepeatTicks = ticks;
}
	
function ClickItem()
{
	fByeByeTicks = 0.5f;
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local Pawn pawn, oldPawn;

	Key = ConvertJoystick(Key);

	if (fByeByeTicks == 0.0f)
	{
		if( Action == IST_Press && (Key == IK_Enter || Key == IK_Space || Key == IK_LeftMouse ||
			Key == IK_Joy1) )
		{
			fKeyDown = IK_Enter;
			ClickItem();
			RootController.PlaySound( fClickSound );
		}
		else if( fHasGoBack && Action == IST_Press && (Key == IK_Backspace || Key == IK_Escape ||
			Key == IK_RightMouse || Key == IK_Joy2) )
		{
			fKeyDown = IK_Backspace;
			ClickItem();
			RootController.PlaySound( fCancelSound );
		}
		else if (bDrawMouse && (Key == IK_MouseX || Key == IK_MouseY))
		{
			HighlightByMouse();
		}
		else if( Action == IST_Axis && Key == IK_MouseY )
		{
			if (Delta > 0)
			{
				if (fMouseDrag < 0)
					fMouseDrag = 0.0f;
				fMouseDrag += Delta;
				if (fRepeatTicks == 0.0f && fMouseDrag >= fDragRes)
				{
					SelectItem((fSelItem - 1 + fNumItems) % fNumItems, 0.25f);
					RootController.PlaySound( fUpSound ); 	
					fMouseDrag = 0.0f;
				}
			}
			else if (Delta < 0)
			{
				if (fMouseDrag > 0)
					fMouseDrag = 0.0f;
				fMouseDrag += Delta;
				if (fRepeatTicks == 0.0f && fMouseDrag <= -fDragRes)
				{
					SelectItem((fSelItem + 1) % fNumItems, 0.25f);
					RootController.PlaySound( fDownSound ); 	
					fMouseDrag = 0.0f;
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
}