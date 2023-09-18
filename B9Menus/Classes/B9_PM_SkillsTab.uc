/////////////////////////////////////////////////////////////
// B9_PM_SkillsTab
//

class B9_PM_SkillsTab extends B9_PM_SharedTop;

var private texture fTabLeftTex;
var private texture fTabMiddleTex;
var private texture fTabMiddleActiveTex;
var private texture fTabRightTex;
 
var private texture fFullFrameMiddleLeftTex;
var private texture fFullFrameBottomLeftTex;

var private texture fSingleLineFrameTex;
var private texture fSingleLineFrameClickTex;
var private texture fSingleLineFrameHiliteTex;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentController. You don't have to implement MenuInit(),
// but you should call super.MenuInit().
function Initialized()
{
	fSelItem = 0;
	fNumItems = 0;
	fKeyDown = IK_None;

	//fDragRes = 10.0f;
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	Super.MenuInit(interaction, controller, parent);
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

function PostRender( canvas Canvas )
{
	local int i;
	local color white;
	local int x, y;
	local font oldFont;
	local float sx, sy;
	local texture theTex;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	oldFont = Canvas.Font;

	Canvas.Style = RootController.ERenderStyle.STY_Normal;
	Canvas.SetDrawColor(white.R, white.G, white.B);


	x = 64;
	y = 20;
	RenderTop( Canvas, x, y );

	// draw bottom area
	y += 4 * 32;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fTabLeftTex, 128, 32, 0, 0, 128, 32 );
	Canvas.TextSize( fFileStr, sx, sy);
	Canvas.SetPos( x + 64 - sx / 2, y + 7 );
	Canvas.DrawText( fFileStr, false );
	Canvas.SetPos( x + 128, y );
	Canvas.DrawTile( fTabMiddleActiveTex, 128, 32, 0, 0, 128, 32 );
	Canvas.TextSize( fSkillsStr, sx, sy);
	Canvas.SetPos( x + 196 - sx / 2, y + 7 );
	Canvas.DrawText( fSkillsStr, false );
	Canvas.SetPos( x + 256, y );
	Canvas.DrawTile( fTabMiddleTex, 128, 32, 0, 0, 128, 32 );
	Canvas.TextSize( fWeaponsStr, sx, sy);
	Canvas.SetPos( x + 320 - sx / 2, y + 7 );
	Canvas.DrawText( fWeaponsStr, false );
	Canvas.SetPos( x + 384, y );
	Canvas.DrawTile( fTabRightTex, 128, 32, 0, 0, 128, 32 );
	Canvas.TextSize( fItemsStr, sx, sy );
	Canvas.SetPos( x + 448 - sx / 2, y + 7 );
	Canvas.DrawText( fItemsStr, false );

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

/*
	y -= 296;
	
	if (fSelItem == 0)
		theTex = fSingleLineFrameHiliteTex;
	else
		theTex = fSingleLineFrameTex;
	Canvas.SetPos( x + 128, y + 124 );
	Canvas.DrawTile( theTex, 256, 32, 0, 0, 256, 32 );
	Canvas.TextSize( fSaveStr, sx, sy );
	Canvas.SetPos( x + 256 - sx / 2, y + 132 );
	Canvas.DrawText( fSaveStr, false );

	if (fSelItem == 1)
		theTex = fSingleLineFrameHiliteTex;
	else
		theTex = fSingleLineFrameTex;
	Canvas.SetPos( x + 128, y + 156 );
	Canvas.DrawTile( theTex, 256, 32, 0, 0, 256, 32 );
	Canvas.TextSize( fLoadStr, sx, sy );
	Canvas.SetPos( x + 256 - sx / 2, y + 164 );
	Canvas.DrawText( fLoadStr, false );
	
	if (fSelItem == 2)
		theTex = fSingleLineFrameHiliteTex;
	else
		theTex = fSingleLineFrameTex;
	Canvas.SetPos( x + 128, y + 188 );
	Canvas.DrawTile( theTex, 256, 32, 0, 0, 256, 32 );
	Canvas.TextSize( fQuitStr, sx, sy );
	Canvas.SetPos( x + 256 - sx / 2, y + 196 );
	Canvas.DrawText( fQuitStr, false );
*/
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
//	fByeByeTicks = 0.5f;
//	fKeyDown = IK_Enter;
//	RootController.PlaySound( fClickSound );
}
	
function ClickBack()
{
	fByeByeTicks = 0.5f;
	fKeyDown = IK_Backspace;
	RootController.PlaySound( fCancelSound );
}

function SelectItem(int delta, float delay)
{
//	fSelItem = (fSelItem + delta + fNumItems) % fNumItems;
//	fRepeatTicks = delay;
//	if (delta > 0)
//		RootController.PlaySound( fDownSound );	
//	else
//		RootController.PlaySound( fUpSound ); 	
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
				ParentInteraction.EndMenu(self, fPauseInteraction.TABMOTION_Left);
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
				ParentInteraction.EndMenu(self, fPauseInteraction.TABMOTION_Right);
			}
		}
	}

	return true;
}

defaultproperties
{
	fTabLeftTex=Texture'B9Menu_textures.Quarter_Size_Panes.tab_left'
	fTabMiddleTex=Texture'B9Menu_textures.Quarter_Size_Panes.tab_middle'
	fTabMiddleActiveTex=Texture'B9Menu_textures.Quarter_Size_Panes.tab_middle_active'
	fTabRightTex=TexScaler'B9Menu_textures.Quarter_Size_Panes.tab_right'
	fFullFrameMiddleLeftTex=Texture'B9Menu_textures.Full_Size_Panes.full_frame_middle_left'
	fFullFrameBottomLeftTex=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_left'
	fSingleLineFrameTex=Texture'B9Menu_textures.Half_Size_Panes.single_line_frame'
	fSingleLineFrameClickTex=Texture'B9Menu_textures.Half_Size_Panes.single_line_frame_click'
	fSingleLineFrameHiliteTex=Texture'B9Menu_textures.Half_Size_Panes.single_line_frame_hilight'
	fMainInfoLeftTex=Texture'B9MenuHelp_Textures.Choices.invstats_main_info_left'
	fMainInfoRightTex=Texture'B9MenuHelp_Textures.Choices.invstats_main_info_right'
}