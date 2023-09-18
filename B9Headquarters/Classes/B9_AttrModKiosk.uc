/////////////////////////////////////////////////////////////
// B9_AttrModKiosk
//

class B9_AttrModKiosk extends B9_BaseKiosk;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX
#exec OBJ LOAD FILE=..\textures\B9Menu_Textures.utx PACKAGE=B9Menu_Textures
#exec OBJ LOAD FILE=..\textures\B9MenuHelp_Textures.utx PACKAGE=B9MenuHelp_Textures

//var private bool bOverApply;

var localized string fStatName;
var int fStatCurValue;
var int fStatModValue;
var int fStatAvailPts;
var int fStatBasePts;
var localized string fStatDescription;
var B9_Calibration fCalibration;
var B9_Calibration fPendingCalibration;
var int fPendingPts;

var localized string fStrApply;
var localized string fStrNoChange;
var localized string fStrCurrent;
var localized string fStrModified;
var localized string fStrPtsAvail;
var localized string fStrConfirmMsg;

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

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
//	local B9_PlayerController pc;

	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
		DescriptionView = new(None) class'B9_PageBrowser';
		DescriptionBody.Length = 1;
		DescriptionBody[0] = fStatDescription;
		fCache = true;
	}
}

function SetDescription(string desc)
{
	fStatDescription = desc;
	DescriptionBody[0] = desc;
}

function SetStatInfo(int value, int points, B9_Calibration cal)
{
	fStatCurValue = value;
	fStatModValue = value;
	fStatAvailPts = points;
	fStatBasePts = points;
	fCalibration = cal;

	// see if there is a pending calibration of same kind
	fPendingCalibration = Listener.FindCalibrationKind(B9_AdvancedPawn(RootController.Pawn), fCalibration);
	if (fPendingCalibration != None)
	{
		if (B9_AttrCalibration(fPendingCalibration) != None)
			fPendingPts = B9_AttrCalibration(fPendingCalibration).Points;
		else if (B9_NanoCalibration(fPendingCalibration) != None)
			fPendingPts = B9_NanoCalibration(fPendingCalibration).Points;
		fStatModValue += fPendingPts;
		fStatBasePts += fPendingPts;
	}
}

function B9_Calibration GetPointsUsed(out int points, out int adjustment)
{
	points = fStatModValue - fStatCurValue;
	adjustment = points - fPendingPts;
	if (adjustment == 0)
		return None;
	if (fPendingCalibration != None)
		return fPendingCalibration;
	return fCalibration;
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
	local float sx, sy;
	local float tx;

	oldFont = Canvas.Font;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	red.R = 255;
	red.G = 64;
	red.B = 64;

	green.R = 128;
	green.G = 255;
	green.B = 128;

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
	Canvas.TextSize(fStatName, sx, sy);
	Canvas.SetPos( x - sx / 2.0, y - 32 + 20 );
	Canvas.DrawText(fStatName);

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

	msg = fStrCurrent $ "55";
	Canvas.TextSize(msg, sx, sy);
	tx = x + sx / 2.0;
	Canvas.SetPos( x - sx / 2.0, y - 64 + 16 );
	Canvas.DrawText(fStrCurrent);
	msg = string(fStatCurValue);
	Canvas.TextSize(msg, sx, sy);
	Canvas.SetPos( tx - sx, y - 64 + 16 );
	Canvas.DrawText(msg);

	msg = fStrPtsAvail $ "55 / 55";
	Canvas.TextSize(msg, sx, sy);
	tx = x + sx / 2.0;
	Canvas.SetPos( x - sx / 2.0, y - 64 + 38 );
	Canvas.DrawText(fStrPtsAvail, false);
	msg = string(fStatAvailPts) $ " / " $ string(fStatBasePts);
	Canvas.TextSize(msg, sx, sy);
	Canvas.SetDrawColor(red.R, red.G, red.B);
	Canvas.SetPos( tx - sx, y - 64 + 38 );
	Canvas.DrawText(string(fStatAvailPts), false);
	Canvas.SetDrawColor(white.R, white.G, white.B);
	Canvas.SetPos( Canvas.CurX, y - 64 + 38 );
	Canvas.DrawText(" / " $ string(fStatBasePts));

	Canvas.Font = fMyFont24;
	Canvas.SetDrawColor(green.R, green.G, green.B);
	msg = fStrModified $ "55";
	Canvas.TextSize(msg, sx, sy);
	tx = x + sx / 2.0;
	Canvas.SetPos( x - sx / 2.0, y - 64 + 62 );
	Canvas.DrawText(fStrModified);
	msg = string(fStatModValue);
	Canvas.TextSize(msg, sx, sy);
	Canvas.SetPos( tx - sx, y - 64 + 62 );
	Canvas.DrawText(msg);

/*
	if (bDrawMouse)
	{
		Canvas.TextSize(fStrApply, sx, sy);

		if (fKeyDown == IK_None)
		{
			bOverApply = (ChildInteraction == None &&
				MouseX >= 50 && MouseX < 50 + sx && MouseY >= 300 && MouseY < 300 + sy);
		}
		
		if (bOverApply) btnColor = white;
		else btnColor = cyan;
		if (fStatCurValue == fStatModValue) msg = fStrNoChange;
		else msg = fStrApply;
		DrawTextWithShadow( Canvas, msg, 50, 300, btnColor, shadowColor, 2 );
	}
*/

	Canvas.Font = oldFont;
}

function EndMenu(B9_MenuInteraction interaction, int result)
{
	if (interaction == ChildInteraction)
	{
		ChildInteraction = None;
		bIgnoreEvent = true;
		fKeyDown = IK_None;

		if (result == 0) // get it!
			CompleteTransaction();
	}
}

function AdjustStat(int delta)
{
	if (delta > 0 && fStatAvailPts > 0)
	{
		fStatModValue++;
		fStatAvailPts--;
		RootController.PlaySound( fUpSound );
	}
	else if (delta < 0 && fStatAvailPts < fStatBasePts)
	{
		fStatModValue--;
		fStatAvailPts++;
		RootController.PlaySound( fDownSound );
	}
}

function AddAttrCalibration(B9_AttrCalibration cal, int adjustment)
{
	local B9_PlayerPawn Pawn;
	
	Pawn = B9_PlayerPawn(RootController.Pawn);

	// add or remove locally
	if (cal.points != 0) Listener.AddCalibration(cal);
	else Listener.RemoveCalibration(cal);

	if (Pawn.Role < ROLE_Authority)
		Pawn.HQAddAttrCalibration(cal.Type, cal.points, adjustment);
	else
		Pawn.fCharacterSkillPoints -= adjustment;
}

function CompleteTransaction()
{
	// abstract

	// !!!! NOTE: If the player make two calibrations on the same stat,
	//			  should the game be smart enough to detect that?
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
			//if (!bOverApply) { if (MouseY < 240) AdjustStat(1); else AdjustStat(-1); }
		}
	}
	else if( Action == IST_Release && (Key == IK_Enter || Key == IK_Space ||
		Key == IK_LeftMouse || Key == IK_Joy1) )
	{
		if (fKeyDown == IK_LeftMouse)
		{
			//if (bOverApply)
			//{
			//if (fStatModValue != fStatCurValue + fPendingPts)
			//{
				RootController.PlaySound( fClickSound );
				// ConfirmTransaction(); // !!!! enable later
				CompleteTransaction(); // !!!! for now
			//}
			//}
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
	fStrApply="Apply"
	fStrNoChange="No Change"
	fStrCurrent="Current Value: "
	fStrModified="New Value: "
	fStrPtsAvail="Points Available: "
	fStrConfirmMsg="Are you sure you want to request this calibration?"
	fFullFrameTopLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_top_left'
	fFullFrameTopRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_top_right'
	fFullFrameMiddleLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_middle_left'
	fFullFrameMiddleRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_middle_right'
	fFullFrameBottomLeft=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_left'
	fFullFrameBottomRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_right'
	fKioskInfoLeft=Texture'B9MenuHelp_Textures.Choices.tweak_info_left'
	fKioskInfoRight=Texture'B9MenuHelp_Textures.Choices.tweak_info_right'
	fBackOffPawn=60
	fFOV=105
	fUpSound=Sound'B9SoundFX.Menu.up_1'
	fDownSound=Sound'B9SoundFX.Menu.down_1'
	fClickSound=Sound'B9SoundFX.Menu.ok_1'
	fCancelSound=Sound'B9SoundFX.Menu.cancel_2'
}