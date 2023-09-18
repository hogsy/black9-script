/////////////////////////////////////////////////////////////
// B9_ConferenceComPanel
//

class B9_ConferenceComPanel extends B9_BaseKiosk;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX
#exec OBJ LOAD FILE=..\textures\B9Menu_Textures.utx PACKAGE=B9Menu_Textures
#exec OBJ LOAD FILE=..\textures\B9MenuHelp_Textures.utx PACKAGE=B9MenuHelp_Textures

var array<string> fThisPage;
var bool fCache;
var string fMaps[10];

var B9_PageBrowser Browser;

var localized string fStrCommChannelActive;

var texture fFullFrameTopLeft;
var texture fFullFrameTopRight;
var texture fFullFrameMiddleLeft;
var texture fFullFrameMiddleRight;
var texture fFullFrameBottomLeft;
var texture fFullFrameBottomRight;
var texture fChoicesLeft;
var texture fChoicesRight;

var localized string fMission1Comment1;
var localized string fMission1Comment2;
var localized string fRepeatMissionBriefing;

var int fLastMission;
var string fCommMessage;
var bool fGotoMission;

var() localized string MSA24Font;
var() localized string MSA16Font;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentInteraction. You don't have to implement MenuInit(),
// but you should call super.MenuInit() if you do.
function Initialized()
{
	log(self@"I'm alive");

	fThisPage.Length = 3;
	fThisPage[0] = "Normally, using this door will send you to your next mission.<br/>However, we are using a debug menu here for now, to provide direct access to missions.<br/>";
	fThisPage[1] = "<br/>Press a number key to go to a mission:<br/><br/>1. Escape from the Moon<br/>2. Bombs of Logic";
	fThisPage[2] = "<br/>3. Crater Ball Run<br/>4. Hot Cognition<br/>5. Break the Cable<br/>6. The Undead<br/>7. Human Soldiers";

	fCache = true;

	fMaps[1] = "M06A01";
	fMaps[2] = "M09A01";
	fMaps[3] = "M14A01";
	fMaps[4] = "M02A02";
	fMaps[5] = "M11A03";
	fMaps[6] = "M12A02";
	fMaps[7] = "M13A01";
	

	Browser = new(None) class'B9_PageBrowser';
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
		fLastMission = B9_PlayerPawn(controller.Pawn).fCharacterConcludedMission;

		if (fLastMission == 1)
		{
			if (Listener.fComPanelUseCount == 1)
			{
				fCommMessage = fMission1Comment1;
				fChoicesLeft = texture'B9MenuHelp_Textures.choice_done';
			}
			else if (Listener.fComPanelUseCount == 2)
			{
				fCommMessage = fMission1Comment2;
				fChoicesLeft = texture'B9MenuHelp_Textures.choice_done';
			}
			else
			{
				fCommMessage = fRepeatMissionBriefing;
				fGotoMission = true;
				fChoicesLeft = texture'B9MenuHelp_Textures.yes_no_left';
				fChoicesRight = texture'B9MenuHelp_Textures.yes_no_right';
			}
		}
		else if (fLastMission > 1)
		{
			fCommMessage = fRepeatMissionBriefing;
			fGotoMission = true;
			fChoicesLeft = texture'B9MenuHelp_Textures.yes_no_left';
			fChoicesRight = texture'B9MenuHelp_Textures.yes_no_right';
		}
	}
}

function Tick(float Delta)
{
	Super.Tick( Delta );
}

function DebugDisplay( canvas Canvas )
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
	Canvas.TextSize(fStrCommChannelActive, sx, sy);
	Canvas.SetPos( x - sx / 2.0, y - 32 + 20 );
	Canvas.DrawText(fStrCommChannelActive);

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

	Browser.RenderPage(Canvas, fThisPage, 10000, fCache);
	fCache = false;
}

function CommDisplay( canvas Canvas )
{
	local color white;
	local int x, y;
	local int i;
	local float sx, sy;
	local int need;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	Canvas.SetDrawColor(white.R, white.G, white.B);
	Canvas.Style = RootController.ERenderStyle.STY_Normal;

	if (fChoicesRight != None)
	{
		x = 320 - 256;
		y = 480 - 52;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fChoicesLeft, 256, 32, 0, 0, 256, 32 );

		x += 256;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fChoicesRight, 256, 32, 0, 0, 256, 32 );
	}
	else
	{
		x = 320 - 128;
		y = 480 - 52;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fChoicesLeft, 256, 32, 0, 0, 256, 32 );
	}

	Canvas.Font = fMyFont16;

	Canvas.SetClip(512 - 64, 480); 
	Canvas.StrLen(fCommMessage, sx, sy);
	Canvas.SetClip(oldClipX, oldClipY);

	// 96 is minimum border height, lets say 64 for text height (16 pixel border)

	need = (int(sy) + 31) / 32 - 1;
	if (need == 0) need = 1;

	x = 320 - 256;
	y = 20;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopRight, 256, 32, 0, 0, 256, 32 );

	for (i=0;i<need;i++)
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
	y = 20;
	Canvas.SetOrigin(RootInteraction.OriginX + x + 32, 
		RootInteraction.OriginY + y + 32 + 16 * need - sy / 2); 
	Canvas.SetClip(512 - 64, 480); 
	Canvas.SetPos(0, 0);
	Canvas.DrawText(fCommMessage);
}

function RenderDisplay( canvas Canvas )
{
	//HACK Sean C. Dumas Broke Joes code to fix a bug SCD$$$
	fLastMission = 0;
	if (fLastMission == 0)
		DebugDisplay( Canvas );
	else
		CommDisplay( Canvas );
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local B9_PlayerController pc;
//	local bool result;
	local string mapname;

	if (Super.KeyEvent( Key, Action, Delta ))
		return true;

	Key = ConvertJoystick(Key);
	
	if( Action == IST_Press && (Key == IK_Enter || Key == IK_Space ||
		Key == IK_LeftMouse || Key == IK_Joy1) )
	{
		MenuExit();
		if (fLastMission > 0 && fGotoMission)
		{
			Listener.MissionBriefing(B9_PlayerController(RootController));
		}
	}
	else if ( Action == IST_Press && (Key == IK_Backspace || Key == IK_Escape ||
		Key == IK_RightMouse || Key == IK_Joy2) )
	{
		MenuExit();
	}
	else if( Action == IST_Press && Key >= IK_0 && Key <= IK_9)
	{
		mapname = fMaps[Key - IK_0];
		if (mapname != "")
		{
			pc = B9_PlayerController(RootController);

			ViewportOwner.bShowWindowsMouse = false;
			PopInteraction(pc, pc.Player);

			RootController.ClientTravel( mapname, TRAVEL_Absolute, true );
		}
	}

	return true;
}

defaultproperties
{
	fStrCommChannelActive="SELECT A MISSION"
	fFullFrameTopLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_top_left'
	fFullFrameTopRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_top_right'
	fFullFrameMiddleLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_middle_left'
	fFullFrameMiddleRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_middle_right'
	fFullFrameBottomLeft=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_left'
	fFullFrameBottomRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_right'
	fMission1Comment1="Mission 1 comment 1 goes here."
	fMission1Comment2="Mission 1 comment 2 goes here."
	fRepeatMissionBriefing="Do you want to repeat the mission briefing?"
	TriggerTagName=ConferenceComPanelTrigger
}