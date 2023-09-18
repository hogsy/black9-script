/////////////////////////////////////////////////////////////
// B9_ConfirmInteraction
//

class B9_ConfirmInteraction extends B9_MenuInteraction;

var private sound fClickSound;
var private sound fCancelSound;

var font fMyFont;

var string message;

//var() localized string MSA24Font;
var localized font MSA24Font;

function Initialized()
{
	fMyFont = MSA24Font; //LoadFont( MSA24Font );
}

function SetMessage( string msg )
{
	message = msg;
}

function PostRender( canvas Canvas )
{
	local color yellow, black;
	local font oldFont;
	local float sx, sy;

	oldFont = Canvas.Font;
	Canvas.Font = fMyFont;

	yellow.R = 255;
	yellow.G = 255;
	yellow.B = 0;

	black.R = 0;
	black.G = 0;
	black.B = 0;

	Canvas.TextSize( message, sx, sy );
	DrawTextWithShadow( Canvas, message, 320 - sx / 2.0f, 160, yellow, black, 2 );

	Canvas.Font = oldFont;
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	Key = ConvertJoystick(Key);

	if( Action == IST_Release && (Key == IK_Enter || Key == IK_Space || Key == IK_LeftMouse ||
		Key == IK_Joy1) )
	{
		RootController.PlaySound( fClickSound );
		ParentInteraction.EndMenu(self, 0);
	}
	else if( Action == IST_Release && (Key == IK_Backspace || Key == IK_Escape ||
		Key == IK_RightMouse || Key == IK_Joy2) )
	{
		RootController.PlaySound( fCancelSound );
		ParentInteraction.EndMenu(self, -1);
	}

	return true;
}

defaultproperties
{
	fClickSound=Sound'B9SoundFX.Menu.ok_1'
	fCancelSound=Sound'B9SoundFX.Menu.cancel_2'
	MSA24Font=Font'B9_Fonts.MicroscanA24'
}