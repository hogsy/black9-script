///////////////////////
//
// B9_ModApplyBooth.uc

class B9_ModApplyBooth extends B9_BaseKiosk;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX
#exec OBJ LOAD FILE=..\textures\B9Menu_Textures.utx PACKAGE=B9Menu_Textures
#exec OBJ LOAD FILE=..\textures\B9MenuHelp_Textures.utx PACKAGE=B9MenuHelp_Textures

var bool fAnyChanges;

var localized string fStrConfirmMsg;
var localized string fStrBoothName;
var localized string fStrNoModsPurchased;
var localized string fStrRequestMods;

var B9_PageBrowser DescriptionView;
var array<string> DescriptionBody;
var bool fCache;

var texture fFullFrameTopLeft;
var texture fFullFrameTopRight;
var texture fFullFrameMiddleLeft;
var texture fFullFrameMiddleRight;
var texture fFullFrameBottomLeft;
var texture fFullFrameBottomRight;
var texture fKioskInfoLeft;
var texture fKioskInfoRight;

var() localized string MSA24Font;
var() localized string MSA16Font;

function Initialized()
{
	log(self@"I'm alive");
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	local int i;

	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
		fStrRequestMods = "<font size=\"24\">" $ fStrRequestMods $ "<br/></font><font color=\"lightgreen\">";
		fStrNoModsPurchased = "<font size=\"24\">" $ fStrNoModsPurchased $ "</font><br/>";

		DescriptionView = new(None) class'B9_PageBrowser';

		DescriptionBody.Length = 1;
		DescriptionBody[0] = fStrRequestMods;

		Listener.ListCalibrations(B9_AdvancedPawn(RootController.Pawn), DescriptionBody);

		fCache = true;

		if (DescriptionBody.Length == 1)
		{
			DescriptionBody[0] = fStrNoModsPurchased;
		}
		else
		{
			for (i=1;i<DescriptionBody.Length;i++)
			{
				DescriptionBody[i] = DescriptionBody[i] $ "<br/>";
			}

			fAnyChanges = true;
		}
	}
}

function RenderDisplay( canvas Canvas )
{
	local color white, cyan, green;
	local color textColor, shadowColor, btnColor;
	local font oldFont;
	local int i;
	local vector loc;
	local bool ClearZ;
	local float oldOrgX, oldOrgY;
	local float oldClipX, oldClipY;
	local string msg;
	local int x, y;
	local float sx, sy;

	oldFont = Canvas.Font;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	cyan.R = 0;
	cyan.G = 255;
	cyan.B = 255;

	green.R = 0;
	green.G = 255;
	green.B = 0;

	textColor.R = 255;
	textColor.G = 255;
	textColor.B = 255;

	shadowColor.R = 0;
	shadowColor.G = 0;
	shadowColor.B = 0;

	ClearZ = true;

	oldOrgX = Canvas.OrgX;
	oldOrgY = Canvas.OrgY;
	oldClipX = Canvas.ClipX;
	oldClipY = Canvas.ClipY;

	Canvas.SetDrawColor(white.R, white.G, white.B);
	Canvas.Style = RootController.ERenderStyle.STY_Normal;

	x = 320 - 256;
	y = 480 - 52;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fKioskInfoLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fKioskInfoRight, 256, 32, 0, 0, 256, 32 );

	x = 320 - 256;
	y = 20;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopRight, 256, 32, 0, 0, 256, 32 );

	x = 320 - 256;
	y += 32;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameBottomLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameBottomRight, 256, 32, 0, 0, 256, 32 );

	Canvas.Font = fMyFont24;
	Canvas.TextSize(fStrBoothName, sx, sy);
	Canvas.SetPos( x - sx / 2.0, y - 32 + 20 );
	Canvas.DrawText(fStrBoothName);

	x = 320 - 256;
	y += 42;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopRight, 256, 32, 0, 0, 256, 32 );

	for (i=0;i<8;i++)
	{
		x = 320 - 256;
		y += 32;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fFullFrameMiddleLeft, 256, 32, 0, 0, 256, 32 );

		x += 256;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fFullFrameMiddleRight, 256, 32, 0, 0, 256, 32 );
	}

	x = 320 - 256;
	y += 32;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameBottomLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameBottomRight, 256, 32, 0, 0, 256, 32 );

	x = 320 - 256;
	Canvas.Font = fMyFont16;
	Canvas.SetOrigin(RootInteraction.OriginX + x + 32, 
		RootInteraction.OriginY + y - 9 * 32 + 16); 
	Canvas.SetClip(512 - 64, 9 * 32 - 32); 

	DescriptionView.RenderPage( Canvas, DescriptionBody, 512, fCache );
	fCache = false;

	Canvas.SetOrigin(oldOrgX, oldOrgY); 
	Canvas.SetClip(oldClipX, oldClipY); 

	Canvas.Font = oldFont;
}

function Apply()
{
	// !!!! This call will cause some animation sequences to play
	//		and MenuExit() should only be called after the sequences
	//		complete. I'm not sure how this will work yet.

	//Listener.MakePermanent(B9_AdvancedPawn(RootController.Pawn));
	//RootController.Trigger(Listener, RootController.Pawn);

	B9_PlayerPawn(RootController.Pawn).HQApplyMods();
	Listener.DeleteCalibrations(B9_AdvancedPawn(RootController.Pawn));

	// !!!! For now just call MenuExit()
	MenuExit();
}

function EndMenu(B9_MenuInteraction interaction, int result)
{
	if (interaction == ChildInteraction)
	{
		ChildInteraction = None;
		bIgnoreEvent = true;
		fKeyDown = IK_None;

		if (result == 0) // apply it!
		{
			Apply();
		}
	}
}

/*
function ConfirmTransaction()
{
	local B9_ConfirmInteraction confirm;

	MakeChildInteraction("B9Headquarters.B9_ConfirmInteraction");

	confirm = B9_ConfirmInteraction(ChildInteraction);
	if (confirm != None)
	{
		confirm.SetMessage(	fStrConfirmMsg );
	}
}
*/

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local B9_PlayerController pc;
	local bool result;

	if (Super.KeyEvent( Key, Action, Delta ) || bIgnoreEvent || ChildInteraction != None)
	{
		bIgnoreEvent = false;
		return true;
	}

	Key = ConvertJoystick(Key);

	if( Action == IST_Press && (Key == IK_Enter || Key == IK_Space ||
		Key == IK_LeftMouse || Key == IK_Joy1) )
	{
		if (fKeyDown == IK_None)
		{
			fKeyDown = IK_LeftMouse;
		}
	}
	else if( Action == IST_Release && (Key == IK_Enter || Key == IK_Space ||
		Key == IK_LeftMouse || Key == IK_Joy1) )
	{
		if (fKeyDown == IK_LeftMouse)
		{
			if (fAnyChanges)
			{
				RootController.PlaySound( fClickSound );
				//ConfirmTransaction(); // !!!! enable later
				Apply(); // !!!! for now
			}
			fKeyDown = IK_None;
		}
	}
	else if ( Action == IST_Press && (Key == IK_Backspace || Key == IK_Escape ||
		Key == IK_RightMouse || Key == IK_Joy2) )
	{
		if (fKeyDown == IK_None)
			fKeyDown = IK_RightMouse;
	}
	else if ( Action == IST_Release && (Key == IK_Backspace || Key == IK_Escape ||
		Key == IK_RightMouse || Key == IK_Joy2) )
	{
		if (fKeyDown == IK_RightMouse)
		{
			RootController.PlaySound( fCancelSound );
			MenuExit();
			fKeyDown = IK_None;
		}
	}
/*
	else if( Action == IST_Press && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
	{
		if (fKeyDown == IK_None)
		{
			AdjustStat(1);
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
			AdjustStat(-1);
			fKeyDown = IK_Down;
		}
	}
	else if( Action == IST_Release && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
	{
		if (fKeyDown == IK_Down)
			fKeyDown = IK_None;
	}
*/

	return true;
}

defaultproperties
{
	fStrConfirmMsg="Are you sure you want to apply these modifications?"
	fStrBoothName="BODY MOD BOOTH"
	fStrNoModsPurchased="No modifications have been purchased."
	fStrRequestMods="Requested Modifications:"
	fFullFrameTopLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_top_left'
	fFullFrameTopRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_top_right'
	fFullFrameMiddleLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_middle_left'
	fFullFrameMiddleRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_middle_right'
	fFullFrameBottomLeft=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_left'
	fFullFrameBottomRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_right'
	fKioskInfoLeft=Texture'B9MenuHelp_Textures.Choices.choice_select'
	fKioskInfoRight=Texture'B9MenuHelp_Textures.Choices.choice_back'
	TriggerTagName=ModApplyBoothTrigger
	fUpSound=Sound'B9SoundFX.Menu.up_1'
	fDownSound=Sound'B9SoundFX.Menu.down_1'
	fClickSound=Sound'B9SoundFX.Menu.ok_1'
	fCancelSound=Sound'B9SoundFX.Menu.cancel_2'
}