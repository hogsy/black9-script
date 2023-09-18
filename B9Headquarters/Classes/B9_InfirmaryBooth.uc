///////////////////////
//
// B9_InfirmaryBooth.uc

class B9_InfirmaryBooth extends B9_BaseKiosk;

//
// This class is DEPRECATED -- DEPRECATED -- DEPRECATED
//

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX
#exec OBJ LOAD FILE=..\textures\B9Menu_Textures.utx PACKAGE=B9Menu_Textures
#exec OBJ LOAD FILE=..\textures\B9MenuHelp_Textures.utx PACKAGE=B9MenuHelp_Textures

var localized string fStrConfirmMsg;
var localized string fStrChamberName;
var localized string fStrInfirmaryMsg;
var localized string fStrCurrent;
var localized string fStrModified;
var localized string fStrCashSpent;

var int fCashOutlay;
var int fPricePerUnit;
var int fCurHealth;
var int fMinHealth;
var int fMaxHealth;
var int fOldHealth;
var int fAvailCash;

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
		DescriptionView = new class'B9_PageBrowser';
		fCache = true;

		DescriptionBody.Length = 1;
		DescriptionBody[0] = fStrInfirmaryMsg;

		fPricePerUnit = 1;
		fOldHealth = RootController.Pawn.Health;
		fCurHealth = RootController.Pawn.Health;
		fMinHealth = fCurHealth;
		fMaxHealth = 110;
		fAvailCash = B9_PlayerPawn(RootController.Pawn).fCharacterCash;
	}
}

function RenderDisplay( canvas Canvas )
{
	local color white, red, green;
	local color textColor, shadowColor, btnColor;
	local font oldFont;
	local int i;
	local vector loc;
	local bool ClearZ;
	local float oldOrgX, oldOrgY;
	local float oldClipX, oldClipY;
	local string msg;
	local int x, y;
	local float sx, sy, tx;

	oldFont = Canvas.Font;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	red.R = 255;
	red.G = 0;
	red.B = 0;

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
	Canvas.TextSize(fStrChamberName, sx, sy);
	Canvas.SetPos( x - sx / 2.0, y - 32 + 20 );
	Canvas.DrawText(fStrChamberName);

	x = 320 - 256;
	y += 42;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopRight, 256, 32, 0, 0, 256, 32 );

	for (i=0;i<5;i++)
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
		RootInteraction.OriginY + y - 6 * 32 + 16); 
	Canvas.SetClip(512 - 64, 6 * 32 - 32); 

	DescriptionView.RenderPage( Canvas, DescriptionBody, 512, fCache );
	fCache = false;

	Canvas.SetOrigin(oldOrgX, oldOrgY); 
	Canvas.SetClip(oldClipX, oldClipY); 

	x = 320 - 256;
	y += 42;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopRight, 256, 32, 0, 0, 256, 32 );

	x = 320 - 256;
	y += 32;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameMiddleLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameMiddleRight, 256, 32, 0, 0, 256, 32 );

	x = 320 - 256;
	y += 32;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameBottomLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameBottomRight, 256, 32, 0, 0, 256, 32 );

	msg = fStrCurrent $ "555";
	Canvas.TextSize(msg, sx, sy);
	tx = x + sx / 2.0;
	Canvas.SetPos( x - sx / 2.0, y - 64 + 16 );
	Canvas.DrawText(fStrCurrent);
	msg = string(fCurHealth);
	Canvas.TextSize(msg, sx, sy);
	Canvas.SetPos( tx - sx, y - 64 + 16 );
	Canvas.DrawText(msg);

	msg = fStrCashSpent $ "$55555";
	Canvas.TextSize(msg, sx, sy);
	tx = x + sx / 2.0;
	Canvas.SetPos( x - sx / 2.0, y - 64 + 38 );
	Canvas.DrawText(fStrCashSpent, false);
	msg = "$" $ string(fCashOutlay);
	Canvas.TextSize(msg, sx, sy);
	Canvas.SetDrawColor(red.R, red.G, red.B);
	Canvas.SetPos( tx - sx, y - 64 + 38 );
	Canvas.DrawText(msg, false);

	Canvas.Font = fMyFont24;
	Canvas.SetDrawColor(green.R, green.G, green.B);
	msg = fStrModified $ "555";
	Canvas.TextSize(msg, sx, sy);
	tx = x + sx / 2.0;
	Canvas.SetPos( x - sx / 2.0, y - 64 + 62 );
	Canvas.DrawText(fStrModified);
	msg = string(fCurHealth);
	Canvas.TextSize(msg, sx, sy);
	Canvas.SetPos( tx - sx, y - 64 + 62 );
	Canvas.DrawText(msg);

	Canvas.Font = fMyFont16;
	Canvas.Style = RootController.ERenderStyle.STY_Normal;
	DrawTextWithShadow( Canvas,
		"$" $ string(B9_PlayerPawn(RootController.Pawn).fCharacterCash),
		20, 20, white, shadowColor, 2 );

	Canvas.Font = oldFont;
}

function Apply()
{
	B9_PlayerPawn(RootController.Pawn).fCharacterCash -= fCashOutlay;
	RootController.Pawn.Health = fCurHealth;

	// !!!! For now just call MenuExit()
	MenuExit();
}


function AdjustStat(int delta)
{
	if (delta > 0 && delta * fPricePerUnit <= fAvailCash - fCashOutlay && 
		fCurHealth + delta <= fMaxHealth)
	{
		fCurHealth += delta;
		fCashOutlay += delta * fPricePerUnit;
	}
	else if (delta < 0 && fCurHealth + delta >= fMinHealth)
	{
		fCurHealth += delta;
		fCashOutlay += delta * fPricePerUnit;
	}
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
			if (fCurHealth > fOldHealth)
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
//	else if( Action == IST_Press && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
	else if( Action == IST_Press &&
		(Key == IK_Right || Key == IK_Joy12 || Key == IK_GreyPlus || Key == IK_Equals) )
	{
		if (fKeyDown == IK_None)
		{
			AdjustStat(1);
//			fKeyDown = IK_Up;
			fKeyDown = IK_Right;
		}
	}
//	else if( Action == IST_Release && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
	else if( Action == IST_Release &&
		(Key == IK_Right || Key == IK_Joy12 || Key == IK_GreyPlus || Key == IK_Equals) )
	{
//		if (fKeyDown == IK_Up)
		if (fKeyDown == IK_Right)
			fKeyDown = IK_None;
	}
//	else if( Action == IST_Press && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
	else if( Action == IST_Press && 
		(Key == IK_Left || Key == IK_Joy11 || Key == IK_GreyMinus || Key == IK_Minus) )
	{
		if (fKeyDown == IK_None)
		{
			AdjustStat(-1);
//			fKeyDown = IK_Down;
			fKeyDown = IK_Left;
		}
	}
//	else if( Action == IST_Release && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
	else if( Action == IST_Release && 
		(Key == IK_Left || Key == IK_Joy11 || Key == IK_GreyMinus || Key == IK_Minus) )
	{
//		if (fKeyDown == IK_Down)
		if (fKeyDown == IK_Left)
			fKeyDown = IK_None;
	}

	return true;
}

defaultproperties
{
	fStrConfirmMsg="Are you sure you want to purchase the extra healing?"
	fStrChamberName="INFIRMARY BOOTH"
	fStrInfirmaryMsg="Message goes here."
	fStrCurrent="Current Health: "
	fStrModified="New Health: "
	fStrCashSpent="Cash Spent: "
	fFullFrameTopLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_top_left'
	fFullFrameTopRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_top_right'
	fFullFrameMiddleLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_middle_left'
	fFullFrameMiddleRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_middle_right'
	fFullFrameBottomLeft=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_left'
	fFullFrameBottomRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_right'
	fKioskInfoLeft=Texture'B9MenuHelp_Textures.Choices.tweak_info_left'
	fKioskInfoRight=Texture'B9MenuHelp_Textures.Choices.tweak_info_right'
	TriggerTagName=InfirmaryBoothTrigger
	fUpSound=Sound'B9SoundFX.Menu.up_1'
	fDownSound=Sound'B9SoundFX.Menu.down_1'
	fClickSound=Sound'B9SoundFX.Menu.ok_1'
	fCancelSound=Sound'B9SoundFX.Menu.cancel_2'
}