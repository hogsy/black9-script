/////////////////////////////////////////////////////////////
// B9_MediaCenterSystem
//

class B9_MediaCenterSystem extends B9_BaseKiosk;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX
#exec OBJ LOAD FILE=..\textures\B9Menu_Textures.utx PACKAGE=B9Menu_Textures
#exec OBJ LOAD FILE=..\textures\B9MenuHelp_Textures.utx PACKAGE=B9MenuHelp_Textures

var float fNextLetterTicks;
var string fTestString;
var int fLetterIndex;
var int fArrayIndex;
var bool bPageComplete;

var localized string fStrMediaCenter;

var array<string> fAllPages;
var array<string> fThisPage;

var B9_PageBrowser Browser;

var texture fFullFrameTopLeft;
var texture fFullFrameTopRight;
var texture fFullFrameMiddleLeft;
var texture fFullFrameMiddleRight;
var texture fFullFrameBottomLeft;
var texture fFullFrameBottomRight;

var() localized string MSA24Font;
var() localized string MSA16Font;

/*	tags:
	<font size="24" color="white"></font>
	<br/>
	<img src="name" align="left" u="0" v="0" w="256" h="256"> 
*/

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentInteraction. You don't have to implement MenuInit(),
// but you should call super.MenuInit() if you do.
function Initialized()
{
	log(self@"I'm alive");

	fAllPages.Length = 1;
	fAllPages[0] = "Dummy text.";
	MakePage(fAllPages);

	Browser = new(None) class'B9_PageBrowser';
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
		fAllPages = Listener.intermission.MediaCenterPages;
		fArrayIndex = 0;
		MakePage(fAllPages);
	}
}

function Tick(float Delta)
{
	Super.Tick( Delta );

	if (fNextLetterTicks > 0f)
	{
		fNextLetterTicks -= Delta;
		if (fNextLetterTicks <= 0f)
			fNextLetterTicks = 0;
	}
}

function MakePage(array<string> pages)
{
	local int i;

	if (fArrayIndex >= pages.Length)
	{
		fArrayIndex = 0;
	}

	i = 0;
	while (fArrayIndex + i < pages.Length)
	{
		if (Len(pages[fArrayIndex + i]) <= 1) break;
		i += 1;
	}

	fThisPage.Length = i;
	for (i=0;i<fThisPage.Length;i++)
		fThisPage[i] = pages[fArrayIndex++];

	fLetterIndex = 0;
	bPageComplete = false;
}

function RenderDisplay( canvas Canvas )
{
	local color white;
	local int x, y;
	local float sx, sy;
	local int i;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	Canvas.SetDrawColor(white.R, white.G, white.B);
	Canvas.Style = RootController.ERenderStyle.STY_Normal;

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
	Canvas.TextSize(fStrMediaCenter, sx, sy);
	Canvas.SetPos( x - sx / 2.0, y - 32 + 20 );
	Canvas.DrawText(fStrMediaCenter);

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

	bPageComplete = Browser.RenderPage(Canvas, fThisPage, fLetterIndex, false);
	if (!bPageComplete)
	{
		if (fNextLetterTicks == 0f)
		{
			fNextLetterTicks = 0.25f;
			fLetterIndex += 1;
		}
	}
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local B9_PlayerController pc;
	local bool result;

	if (Super.KeyEvent( Key, Action, Delta ))
		return true;

	Key = ConvertJoystick(Key);

	if( Action == IST_Press && (Key == IK_Enter || Key == IK_Space ||
		Key == IK_LeftMouse || Key == IK_Joy1) )
	{
		if (bPageComplete)
		{
			fArrayIndex++;
			MakePage(fAllPages);
		}
		else
		{
			fNextLetterTicks = 0f;
			fLetterIndex = 10000;
		}
	}
	else if ( Action == IST_Press && (Key == IK_Backspace || Key == IK_Escape ||
		Key == IK_RightMouse || Key == IK_Joy2) )
	{
		MenuExit();
	}

	return true;
}

defaultproperties
{
	fStrMediaCenter="MEDIA CENTER"
	fFullFrameTopLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_top_left'
	fFullFrameTopRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_top_right'
	fFullFrameMiddleLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_middle_left'
	fFullFrameMiddleRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_middle_right'
	fFullFrameBottomLeft=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_left'
	fFullFrameBottomRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_right'
	MSA24Font="MicroscanA24"
	MSA16Font="MicroscanA16"
	TriggerTagName=MediaCenterSystemTrigger
}