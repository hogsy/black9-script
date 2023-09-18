/////////////////////////////////////////////////////////////
// B9_YesNoInteraction
//

class B9_YesNoInteraction extends B9_MenuInteraction;

var private sound fClickSound;
var private sound fCancelSound;

var font fMyFont;

var array<string> Message;
var B9_HQListener Listener;
var B9_PlayerPawn PlayerPawn;
//var B9_HQZoneInfo ZoneInfo;
var vector Location;
var int Lines;

var texture fFullFrameTopLeft;
var texture fFullFrameTopRight;
var texture fFullFrameMiddleLeft;
var texture fFullFrameMiddleRight;
var texture fFullFrameBottomLeft;
var texture fFullFrameBottomRight;
var texture fYesNoLeft;
var texture fYesNoRight;

//var() localized string MSA24Font;
var localized font MSA24Font;

function Initialized()
{
	fMyFont = MSA24Font; //LoadFont( MSA24Font );
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	Super.MenuInit(interaction, controller, parent);
	PlayerPawn = B9_PlayerPawn(controller.Pawn);

	ForEach controller.AllActors(class'B9_HQListener', Listener)
	{
		break;
	}
}

function SetGenericVector(int id, vector v)
{
	Location = v;
}

function SetGenericString(int id, string M)
{
	local string s;
	local int i, j;

	Lines = 1;

	s = M;
	i = InStr(s, "~");
	while (i != -1)
	{
		Lines++;
		s = Mid(s, i + 1);
		i = InStr(s, "~");
	}

	Message.Length = Lines;

	j = 0;
	s = M;
	i = InStr(s, "~");
	while (i != -1)
	{
		Message[j++] = Left(s, i);
		s = Mid(s, i + 1);
		i = InStr(s, "~");
	}
	if (Len(s) > 0) Message[j++] = s;
}

function PostRender( canvas Canvas )
{
	local color white;
	local font oldFont;
	local float oldOrgX, oldOrgY;
	local float oldClipX, oldClipY;
	local float sx, sy;
	local int x, y;
	local int i;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	oldFont = Canvas.Font;
	Canvas.Font = fMyFont;

	SetOrigin((Canvas.ClipX - 640) / 2, (Canvas.ClipY - 480) / 2);

	Canvas.SetOrigin(RootInteraction.OriginX, RootInteraction.OriginY); 

	oldOrgX = Canvas.OrgX;
	oldOrgY = Canvas.OrgY;
	oldClipX = Canvas.ClipX;
	oldClipY = Canvas.ClipY;

	Canvas.SetDrawColor(white.R, white.G, white.B);
	Canvas.Style = RootController.ERenderStyle.STY_Normal;

	y = 240 - 32;
	if (Lines > 1) y -= 16 * (Lines - 1);

	x = 320 - 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopRight, 256, 32, 0, 0, 256, 32 );

	for (i=0;i<Lines-1;i++)
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
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fYesNoLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fYesNoRight, 256, 32, 0, 0, 256, 32 );

	x = 320 - 256;
	y = 240 - 32;
	if (Lines > 1) y -= 16 * (Lines - 1);

	Canvas.SetOrigin(RootInteraction.OriginX + x + 24, RootInteraction.OriginY + y + 8);
	Canvas.SetClip(512 - 48, 32 * (Lines + 1));

	for (i=0;i<Lines;i++)
	{
		Canvas.TextSize( Message[i], sx, sy );
		Canvas.SetPos( (Canvas.ClipX - sx) / 2.0f, 28 * i );
		Canvas.DrawText( Message[i] );
	}

	Canvas.SetOrigin(oldOrgX, oldOrgY); 
	Canvas.SetClip(oldClipX, oldClipY); 
	
	Canvas.Font = oldFont;
}

function MenuExit(bool result)
{
	PopInteraction(RootController, RootController.Player);
	Listener.QueryResultWithLocation(RootController.Pawn, Location, result);
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	Key = ConvertJoystick(Key);

	if( Action == IST_Release && (Key == IK_Enter || Key == IK_Space || Key == IK_LeftMouse ||
		Key == IK_Joy1) )
	{
		RootController.PlaySound( fClickSound );
		MenuExit(true);
	}
	else if( Action == IST_Release && (Key == IK_Backspace || Key == IK_Escape ||
		Key == IK_RightMouse || Key == IK_Joy2) )
	{
		RootController.PlaySound( fCancelSound );
		MenuExit(false);
	}

	return true;
}

defaultproperties
{
	fClickSound=Sound'B9SoundFX.Menu.ok_1'
	fCancelSound=Sound'B9SoundFX.Menu.cancel_2'
	fFullFrameTopLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_top_left'
	fFullFrameTopRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_top_right'
	fFullFrameMiddleLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_middle_left'
	fFullFrameMiddleRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_middle_right'
	fFullFrameBottomLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_subtitle_left'
	fFullFrameBottomRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_subtitle_right'
	fYesNoLeft=Texture'B9MenuHelp_Textures.Choices.yes_no_left'
	fYesNoRight=Texture'B9MenuHelp_Textures.Choices.yes_no_right'
	MSA24Font=Font'B9_Fonts.MicroscanA24'
}