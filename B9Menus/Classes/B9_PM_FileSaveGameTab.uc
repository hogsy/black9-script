/////////////////////////////////////////////////////////////
// B9_PM_FileSaveGameTab
//

class B9_PM_FileSaveGameTab extends B9_PM_SharedTop;

#exec OBJ LOAD FILE=..\textures\B9HUD_textures.utx PACKAGE=B9HUD_textures

var private texture fTabLeftActiveTex;
var private texture fTabMiddleTex;
var private texture fTabRightTex;
 
var private texture fFullFrameMiddleLeftTex;
var private texture fFullFrameBottomLeftTex;

struct MyTexSet
{
	var texture uns, sel, clk;
};

var private MyTexSet fInsetTopLeftTexSet;
var private MyTexSet f16thBorderUpperTexSet;
var private MyTexSet f8thBorderUpperTexSet;
var private MyTexSet fFullFrameTopMiddleTexSet;
var private MyTexSet fCornerTopRightTexSet;
var private MyTexSet fInsetMiddleLeftTexSet;
var private MyTexSet f16thBlankTexSet;
var private MyTexSet f8thBlankTexSet;
var private MyTexSet fFullBlankTexSet;
var private MyTexSet fCornerMiddleRightTexSet;
var private MyTexSet fInsetBottomLeftTexSet;
var private MyTexSet f16thBorderLowerTexSet;
var private MyTexSet f8thBorderLowerTexSet;
var private MyTexSet fFullFrameBottomMiddleTexSet;
var private MyTexSet fCornerBottomRightTexSet;

var private texture fArrowUpTex;
var private texture fArrowDownTex;

var private bool fHasEmptySlot;
var private string fEmptySlotStr;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentController. You don't have to implement MenuInit(),
// but you should call super.MenuInit().
function Initialized()
{
	fSelItem = 0;
	fTopItem = 0;
	fKeyDown = IK_None;

	//fDragRes = 10.0f;
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	local SavedGameInfo info;
	local int stamp;
	local int i;

	Super.MenuInit(interaction, controller, parent);

	fPauseInteraction.CollectStorageInfo();

	fNumItems = fPauseInteraction.SGI.Length;
	fHasEmptySlot = (fPauseInteraction.GSS.GetAvailableCapacity() > 0);
	if (fHasEmptySlot)
		++fNumItems;

	for (i=0;i<fPauseInteraction.SGI.Length;i++)
	{
		info = fPauseInteraction.SGI[i];
		if (info.TimeStamp > stamp)
		{
			fSelItem = i;
			stamp = info.TimeStamp;
		}
	}

	if (fSelItem > 1) 
		fTopItem = fSelItem - 1;
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
				ParentInteraction.EndMenu(self, fSelItem);
			else if (fKeyDown == IK_Backspace)
				ParentInteraction.EndMenu(self, -1);
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
				SelectItem(-1, 0.5f);
			}
			else if (fKeyDown == IK_Down)
			{
				SelectItem(1, 0.5f);
			}
		}
	}
/*
	else if (fRepeatTicks > 0.0f)
	{
		fRepeatTicks -= Delta;
		if (fRepeatTicks < 0.0f)
			fRepeatTicks = 0.0f;
	}
*/
}

function DrawTileFrom(Canvas Canvas, int i, MyTexSet set, int w, int h)
{
	local texture tex;

	if (i == fSelItem && fByeByeTicks > 0.0f)
		tex = set.clk;
	else if (i == fSelItem)
		tex = set.sel;
	else
		tex = set.uns;

	Canvas.DrawTile( tex, w, h, 0, 0, w, h );
}

function PostRender( canvas Canvas )
{
	local int i, j, k;
	local color white, grey;
	local int x, y;
	local font oldFont;
	local float sx, sy;
	local texture theTex;
	local string label;
	local SavedGameInfo info;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	grey.R = 128;
	grey.G = 128;
	grey.B = 128;

	oldFont = Canvas.Font;

	Canvas.Style = RootController.ERenderStyle.STY_Normal;
	Canvas.SetDrawColor(white.R, white.G, white.B);


	x = 64;
	y = 20;
	RenderTop( Canvas, x, y );

	// draw bottom area
	y += 4 * 32;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fTabLeftActiveTex, 128, 32, 0, 0, 128, 32 );
	Canvas.TextSize( fFileStr, sx, sy);
	Canvas.SetPos( x + 64 - sx / 2, y + 7 );
	Canvas.DrawText( fFileStr, false );
	Canvas.SetPos( x + 128, y );
	Canvas.DrawTile( fTabMiddleTex, 128, 32, 0, 0, 128, 32 );
	Canvas.TextSize( fSkillsStr, sx, sy);
	Canvas.SetPos( x + 196 - sx / 2, y + 7 );
	Canvas.SetDrawColor(grey.R, grey.G, grey.B);
	Canvas.DrawText( fSkillsStr, false );
	Canvas.SetDrawColor(white.R, white.G, white.B);
	Canvas.SetPos( x + 256, y );
	Canvas.DrawTile( fTabMiddleTex, 128, 32, 0, 0, 128, 32 );
	Canvas.TextSize( fWeaponsStr, sx, sy);
	Canvas.SetPos( x + 320 - sx / 2, y + 7 );
	Canvas.SetDrawColor(grey.R, grey.G, grey.B);
	Canvas.DrawText( fWeaponsStr, false );
	Canvas.SetDrawColor(white.R, white.G, white.B);
	Canvas.SetPos( x + 384, y );
	Canvas.DrawTile( fTabRightTex, 128, 32, 0, 0, 128, 32 );
	Canvas.TextSize( fItemsStr, sx, sy );
	Canvas.SetPos( x + 448 - sx / 2, y + 7 );
	Canvas.SetDrawColor(grey.R, grey.G, grey.B);
	Canvas.DrawText( fItemsStr, false );
	Canvas.SetDrawColor(white.R, white.G, white.B);

	for (i=0;i<6;i++)
	{
		y += 32;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fFullFrameMiddleLeftTex, 256, 32, 0, 0, 256, 32 );
		Canvas.SetPos( x + 256, y );
		Canvas.DrawTile( fFullFrameMiddleRightTex, 256, 32, 0, 0, 256, 32 );
	}

	y += 32;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameBottomLeftTex, 256, 32, 0, 0, 256, 32 );
	Canvas.SetPos( x + 256, y );
	Canvas.DrawTile( fFullFrameBottomRightTex, 256, 32, 0, 0, 256, 32 );

	y += 40;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fMainInfoLeftTex, 256, 32, 0, 0, 256, 32 );
	Canvas.SetPos( x + 256, y );
	Canvas.DrawTile( fMainInfoRightTex, 256, 32, 0, 0, 256, 32 );

	y -= 232;
	
	k = 0;
	for (i=fTopItem;i<fNumItems && i<fTopItem+2;i++)
	{
		Canvas.SetPos( x, y + k );
		DrawTileFrom( Canvas, i, fInsetTopLeftTexSet, 32, 32 );
		Canvas.SetPos( x + 32, y + k );
		DrawTileFrom( Canvas, i, f16thBorderUpperTexSet, 32, 32 );
		Canvas.SetPos( x + 64, y + k );
		DrawTileFrom( Canvas, i, f8thBorderUpperTexSet, 64, 32 );
		Canvas.SetPos( x + 128, y + k );
		DrawTileFrom( Canvas, i, fFullFrameTopMiddleTexSet, 256, 32 );
		Canvas.SetPos( x + 384, y + k );
		DrawTileFrom( Canvas, i, f8thBorderUpperTexSet, 64, 32 );
		Canvas.SetPos( x + 448, y + k );
		DrawTileFrom( Canvas, i, fCornerTopRightTexSet, 32, 32 );

		k += 32;
		Canvas.SetPos( x, y + k );
		DrawTileFrom( Canvas, i, fInsetMiddleLeftTexSet, 32, 32 );
		Canvas.SetPos( x + 32, y + k );
		DrawTileFrom( Canvas, i, f16thBlankTexSet, 32, 32 );
		Canvas.SetPos( x + 64, y + k );
		DrawTileFrom( Canvas, i, f8thBlankTexSet, 64, 32 );
		Canvas.SetPos( x + 128, y + k );
		DrawTileFrom( Canvas, i, fFullBlankTexSet, 256, 32 );
		Canvas.SetPos( x + 384, y + k );
		DrawTileFrom( Canvas, i, f8thBlankTexSet, 64, 32 );
		Canvas.SetPos( x + 448, y + k );
		DrawTileFrom( Canvas, i, fCornerMiddleRightTexSet, 32, 32 );

		k += 32;
		Canvas.SetPos( x, y + k );
		DrawTileFrom( Canvas, i, fInsetBottomLeftTexSet, 32, 32 );
		Canvas.SetPos( x + 32, y + k );
		DrawTileFrom( Canvas, i, f16thBorderLowerTexSet, 32, 32 );
		Canvas.SetPos( x + 64, y + k );
		DrawTileFrom( Canvas, i, f8thBorderLowerTexSet, 64, 32 );
		Canvas.SetPos( x + 128, y + k );
		DrawTileFrom( Canvas, i, fFullFrameBottomMiddleTexSet, 256, 32 );
		Canvas.SetPos( x + 384, y + k );
		DrawTileFrom( Canvas, i, f8thBorderLowerTexSet, 64, 32 );
		Canvas.SetPos( x + 448, y + k );
		DrawTileFrom( Canvas, i, fCornerBottomRightTexSet, 32, 32 );

		k -= 64;
		if (i == fNumItems - 1 && fHasEmptySlot)
		{
			Canvas.Font = fMyFont24;
			Canvas.TextSize( fEmptySlotStr, sx, sy );
			Canvas.SetPos( x + 240 - sx / 2, y + k + 48 - sy / 2 );
			Canvas.DrawText( fEmptySlotStr, false );
			Canvas.Font = fMyFont16;
		}
		else
		{
			RenderSavedGameInfo( Canvas, x, y + k, fPauseInteraction.SGI[i]);
		}

		k += 96;
	}

	if (fTopItem > 0)
	{
		Canvas.SetPos( x + 480 + 8, y + 8);
		Canvas.DrawTile( fArrowUpTex, 16, 16, 0, 0, 16, 16 );
	}
	if (fTopItem + 2 < fNumItems)
	{
		Canvas.SetPos( x + 480 + 8, y + 5 * 32 + 8);
		Canvas.DrawTile( fArrowDownTex, 16, 16, 0, 0, 16, 16 );
	}
	
	Canvas.Font = oldFont;
}

/*
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
*/

function ClickSelect()
{
	fByeByeTicks = 0.5f;
	fKeyDown = IK_Enter;
	RootController.PlaySound( fClickSound );
}
	
function ClickBack()
{
	fByeByeTicks = 0.5f;
	fKeyDown = IK_Backspace;
	RootController.PlaySound( fCancelSound );
}

function SelectItem(int delta, float delay)
{
	fSelItem = (fSelItem + delta + fNumItems) % fNumItems;
	if (fSelItem < fTopItem)
		fTopItem = fSelItem;
	if (fSelItem >= fTopItem + 2)
		fTopItem = fSelItem - 1;
	fRepeatTicks = delay;
	if (delta > 0)
		RootController.PlaySound( fDownSound );	
	else
		RootController.PlaySound( fUpSound ); 	
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
			ClickSelect();
		}
		else if( Action == IST_Press && (Key == IK_Backspace || Key == IK_Escape ||
			Key == IK_RightMouse || Key == IK_Joy2) )
		{
			ClickBack();
		}
/*
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
*/
		else if( Action == IST_Press && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
		{
			if (fKeyDown == IK_None)
			{
				SelectItem(-1, 0.5f);
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
				SelectItem(1, 0.5f);
				fKeyDown = IK_Down;
			}
		}
		else if( Action == IST_Release && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
		{
			if (fKeyDown == IK_Down)
				fKeyDown = IK_None;
		}
/*
		else if( Action == IST_Press && (Key == IK_Left || Key == IK_Joy11) )
		{
			if (fKeyDown == IK_None)
				fKeyDown = IK_Left;
		}
		else if( Action == IST_Release && (Key == IK_Left || Key == IK_Joy11) )
		{
			if (fKeyDown == IK_Left)
			{
				RootController.PlaySound( fUpSound );
				fKeyDown = IK_None;
				ParentInteraction.EndMenu(self, fPauseInteration.TABMOTION_Left);
			}
		}
		else if( Action == IST_Press && (Key == IK_Right || Key == IK_Joy12) )
		{
			if (fKeyDown == IK_None)
				fKeyDown = IK_Right;
		}
		else if( Action == IST_Release && (Key == IK_Right || Key == IK_Joy12) )
		{
			if (fKeyDown == IK_Right)
			{
				RootController.PlaySound( fDownSound );
				fKeyDown = IK_None;
				ParentInteraction.EndMenu(self, fPauseInteration.TABMOTION_Right);
			}
		}
*/
	}

	return true;
}

defaultproperties
{
	fTabLeftActiveTex=Texture'B9Menu_textures.Quarter_Size_Panes.tab_left_active'
	fTabMiddleTex=Texture'B9Menu_textures.Quarter_Size_Panes.tab_middle'
	fTabRightTex=TexScaler'B9Menu_textures.Quarter_Size_Panes.tab_right'
	fFullFrameMiddleLeftTex=Texture'B9Menu_textures.Full_Size_Panes.full_frame_middle_left'
	fFullFrameBottomLeftTex=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_left'
	fInsetTopLeftTexSet=(uns=Texture'B9Menu_textures.Corners.inset_corner_upper_left',sel=Texture'B9Menu_textures.Corners.inset_corner_upper_left_hilight',clk=Texture'B9Menu_textures.Corners.inset_corner_upper_left_click')
	f16thBorderUpperTexSet=(uns=Texture'B9Menu_textures.Smallest_Panes.sixteenth_border_upper',sel=Texture'B9Menu_textures.Smallest_Panes.sixteenth_border_upper_hilight',clk=Texture'B9Menu_textures.Smallest_Panes.sixteenth_border_upper_click')
	f8thBorderUpperTexSet=(uns=Texture'B9Menu_textures.Smallest_Panes.eighth_border_upper',sel=Texture'B9Menu_textures.Smallest_Panes.eighth_border_upper_hilight',clk=Texture'B9Menu_textures.Smallest_Panes.eighth_border_upper_click')
	fFullFrameTopMiddleTexSet=(uns=Texture'B9Menu_textures.Full_Size_Panes.full_frame_top_middle',sel=Texture'B9Menu_textures.Full_Size_Panes.full_frame_top_middle_hilight',clk=Texture'B9Menu_textures.Full_Size_Panes.full_frame_top_middle_click')
	fCornerTopRightTexSet=(uns=TexScaler'B9Menu_textures.Corners.corner_upper_right',sel=TexScaler'B9Menu_textures.Corners.corner_upper_right_hilight',clk=TexScaler'B9Menu_textures.Corners.corner_upper_right_click')
	fInsetMiddleLeftTexSet=(uns=Texture'B9Menu_textures.Smallest_Panes.inset_border_left',sel=Texture'B9Menu_textures.Smallest_Panes.inset_border_left_hilight',clk=Texture'B9Menu_textures.Smallest_Panes.inset_border_left_click')
	f16thBlankTexSet=(uns=Texture'B9Menu_textures.Blank_Panes.sixteenth_blank',sel=Texture'B9Menu_textures.Blank_Panes.sixteenth_blank_hilight',clk=Texture'B9Menu_textures.Blank_Panes.sixteenth_blank_hilight')
	f8thBlankTexSet=(uns=Texture'B9Menu_textures.Blank_Panes.eighth_blank',sel=Texture'B9Menu_textures.Blank_Panes.eighth_blank_highlight_and_active',clk=Texture'B9Menu_textures.Blank_Panes.eighth_blank_highlight_and_active')
	fFullBlankTexSet=(uns=Texture'B9Menu_textures.Blank_Panes.full_blank',sel=Texture'B9Menu_textures.Blank_Panes.full_blank_highlight_and_active',clk=Texture'B9Menu_textures.Blank_Panes.full_blank_highlight_and_active')
	fCornerMiddleRightTexSet=(uns=TexScaler'B9Menu_textures.Smallest_Panes.border_right',sel=TexScaler'B9Menu_textures.Smallest_Panes.border_right_hilight',clk=TexScaler'B9Menu_textures.Smallest_Panes.border_right_click')
	fInsetBottomLeftTexSet=(uns=TexScaler'B9Menu_textures.Corners.inset_corner_lower_left',sel=TexScaler'B9Menu_textures.Corners.inset_corner_lower_left_hilight',clk=TexScaler'B9Menu_textures.Corners.inset_corner_lower_left_click')
	f16thBorderLowerTexSet=(uns=TexScaler'B9Menu_textures.Smallest_Panes.sixteenth_border_lower',sel=TexScaler'B9Menu_textures.Smallest_Panes.sixteenth_border_lower_hilight',clk=TexScaler'B9Menu_textures.Smallest_Panes.sixteenth_border_lower_click')
	f8thBorderLowerTexSet=(uns=TexScaler'B9Menu_textures.Smallest_Panes.eighth_border_lower',sel=TexScaler'B9Menu_textures.Smallest_Panes.eighth_border_lower_hilight',clk=TexScaler'B9Menu_textures.Smallest_Panes.eighth_border_lower_click')
	fFullFrameBottomMiddleTexSet=(uns=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_middle',sel=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_middle_hilight',clk=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_middle_click')
	fCornerBottomRightTexSet=(uns=TexScaler'B9Menu_textures.Corners.corner_lower_right',sel=TexScaler'B9Menu_textures.Corners.corner_lower_right_hilight',clk=TexScaler'B9Menu_textures.Corners.corner_lower_right_click')
	fArrowUpTex=Texture'B9Menu_textures.Misc.scroll_arrow_up'
	fArrowDownTex=Texture'B9Menu_textures.Misc.scroll_arrow_down'
	fEmptySlotStr="EMPTY SLOT"
	fHealthIconTex=FinalBlend'B9HUD_textures.health_and_focus.health_icon_tl'
	fFocusIconTex=FinalBlend'B9HUD_textures.health_and_focus.focus_icon_tl'
}