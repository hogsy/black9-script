/////////////////////////////////////////////////////////////
// B9_MM_NewCareerReadyMenu
//

class B9_MM_NewCareerReadyMenu extends B9_MMInteraction;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX

//var private sound fUpSound;
//var private sound fDownSound;
var private sound fClickSound;
var private sound fCancelSound;

var private int fLtWidth;
var private int fLtHeight;
var private int fRtWidth;
var private int fRtHeight;

var private localized string fStrReadyToGo;

var font fMyFont;

var private EInputKey fKeyDown;
var private float fByeByeTicks;

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
	fMyFont = MSA24Font; //LoadFont( MSA24Font );

	fAcceptImage = texture'B9MenuHelp_Textures.choice_select';

	fRejectImage = texture'B9MenuHelp_Textures.choice_back';
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
}

function PostRender( canvas Canvas )
{
	local int i, j, x, y;
	local color white;
	local font oldFont;
	local float sx, sy;

	oldFont = Canvas.Font;
	Canvas.Font = fMyFont;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	Canvas.SetDrawColor(white.R, white.G, white.B);

	Canvas.TextSize( fStrReadyToGo, sx, sy );
	Canvas.SetPos( 320.0f - sx / 2.0f, 200 );
	Canvas.DrawText( fStrReadyToGo, false );

	Canvas.Font = oldFont;

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
	fByeByeTicks = 0.5f;
	fKeyDown = IK_Enter;
	RootController.PlaySound( fClickSound );
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	Key = ConvertJoystick(Key);

	if (fByeByeTicks == 0.0f)
	{
		if( Action == IST_Press && (Key == IK_Enter || Key == IK_Space ||
			Key == IK_LeftMouse || Key == IK_Joy1) )
		{
			ClickItem();
		}
		else if( Action == IST_Press && (Key == IK_Backspace || Key == IK_Escape ||
			Key == IK_RightMouse || Key == IK_Joy2) )
		{
			BackButton();
		}
	}

	return true;
}

defaultproperties
{
	fClickSound=Sound'B9SoundFX.Menu.ok_1'
	fCancelSound=Sound'B9SoundFX.Menu.cancel_2'
	fLtWidth=256
	fLtHeight=32
	fRtWidth=256
	fRtHeight=32
	fStrReadyToGo="READY TO GO?"
	MSA24Font=Font'B9_Fonts.MicroscanA24'
}