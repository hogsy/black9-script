/////////////////////////////////////////////////////////////
// B9_PM_SharedTop
//

class B9_PM_SharedTop extends B9_MenuInteraction;

#exec OBJ LOAD FILE=..\textures\B9Menu_Textures.utx PACKAGE=B9Menu_Textures
#exec OBJ LOAD FILE=..\textures\B9MenuHelp_Textures.utx PACKAGE=B9MenuHelp_Textures

var sound fUpSound;
var sound fDownSound;
var sound fClickSound;
var sound fCancelSound;

var int fSelItem;
var int fNumItems;
var int fTopItem;

var EInputKey fKeyDown;
var float fByeByeTicks;

var float fRepeatTicks;
/*
var private float fMouseDrag;
var private float fDragRes;
*/

var B9_PauseInteraction fPauseInteraction;

var font fMyFont24;
var font fMyFont16;

var texture fPortraitTex;

var texture fMiniFrameTopLeftTex;
var texture fMiniFrameDividerLeftTex;
var texture fMiniFrameMiddleLeftTex;
var texture fMiniFrameBottomLeftTex;

var texture fFullFrameTopRightTex;
var texture fFullFrameMiddleRightTex;
var texture fFullFrameBottomRightTex;
var texture fFullFrameDividerRightTex;

var texture fMainInfoLeftTex;
var texture fMainInfoRightTex;

var texture fStrIconTex;
var texture fAglIconTex;
var texture fDexIconTex;
var texture fConIconTex;

var texture fHealthIconTex;
var texture fFocusIconTex;

var string fHealthStr;
var string fFocusStr;
var string fCashStr;
var string fFileStr;
var string fSkillsStr;
var string fWeaponsStr;
var string fItemsStr;

var string CharName;
var string CharStr;
var string CharAgl;
var string CharDex;
var string CharCon;
var string CharHealth;
var string CharFocus;
var string CharCash;

//var() localized string MSA24Font;
//var() localized string MSA16Font;
var localized font MSA24Font;
var localized font MSA16Font;

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	local B9_PlayerPawn pp;

	Super.MenuInit(interaction, controller, parent);

	fPauseInteraction = B9_PauseInteraction(interaction);

	fMyFont24 = MSA24Font; //LoadFont( MSA24Font );
	fMyFont16 = MSA16Font; //LoadFont( MSA16Font );

	pp = B9_PlayerPawn(controller.Pawn);

	CharName = pp.fCharacterName;
	CharStr = string(pp.fCharacterStrength);
	CharAgl = string(pp.fCharacterAgility);
	CharDex = string(pp.fCharacterDexterity);
	CharCon = string(pp.fCharacterConstitution);
	CharHealth =  string(pp.Health) $ " / " $ string(pp.fCharacterMaxHealth); 
	CharFocus = string(int(pp.fCharacterFocus)) $ " / " $ string(int(pp.fCharacterMaxFocus)); 
	CharCash = "$" $ string(pp.fCharacterCash);
}

function RenderTop( canvas Canvas, int x, int y )
{
	local float sx, sy;

	// draw portrait
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fPortraitTex, 128, 128, 0, 0, 128, 128 );

	x += 128;
	// draw current stats box
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fMiniFrameTopLeftTex, 128, 32, 0, 0, 128, 32 );
	Canvas.SetPos( x + 128, y );
	Canvas.DrawTile( fFullFrameTopRightTex, 256, 32, 0, 0, 256, 32 );

	y += 32;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fMiniFrameDividerLeftTex, 128, 32, 0, 0, 128, 32 );
	Canvas.SetPos( x + 128, y );
	Canvas.DrawTile( fFullFrameDividerRightTex, 256, 32, 0, 0, 256, 32 );

	y += 32;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fMiniFrameMiddleLeftTex, 128, 32, 0, 0, 128, 32 );
	Canvas.SetPos( x + 128, y );
	Canvas.DrawTile( fFullFrameMiddleRightTex, 256, 32, 0, 0, 256, 32 );

	y += 32;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fMiniFrameBottomLeftTex, 128, 32, 0, 0, 128, 32 );
	Canvas.SetPos( x + 128, y );
	Canvas.DrawTile( fFullFrameBottomRightTex, 256, 32, 0, 0, 256, 32 );
	
	y -= 3 * 32;

	Canvas.Font = fMyFont24;
	Canvas.SetPos( x + 10, y + 10);
	Canvas.DrawText( CharName, false );

	Canvas.Font = fMyFont16;
	Canvas.SetPos( x + 16, y + 68 );
	Canvas.DrawTile( fStrIconTex, 32, 16, 0, 0, 32, 16 );
	Canvas.SetPos( x + 54, y + 68 );
	Canvas.DrawText( CharStr, false );
	Canvas.SetPos( x + 116, y + 68 );
	Canvas.DrawTile( fAglIconTex, 32, 16, 0, 0, 32, 16 );
	Canvas.SetPos( x + 150, y + 68 );
	Canvas.DrawText( CharAgl, false );
	Canvas.SetPos( x + 16, y + 98 );
	Canvas.DrawTile( fDexIconTex, 32, 16, 0, 0, 32, 16 );
	Canvas.SetPos( x + 54, y + 98 );
	Canvas.DrawText( CharDex, false );
	Canvas.SetPos( x + 116, y + 98 );
	Canvas.DrawTile( fConIconTex, 32, 16, 0, 0, 32, 16 );
	Canvas.SetPos( x + 150, y + 98 );
	Canvas.DrawText( CharCon, false );
	Canvas.SetPos( x + 198, y + 63 );
	Canvas.DrawText( fHealthStr, false );
	Canvas.TextSize( CharHealth, sx, sy);
	Canvas.SetPos( x + 368 - sx, y + 63 );
	Canvas.DrawText( CharHealth, false );
	Canvas.SetPos( x + 198, y + 82 );
	Canvas.DrawText( fFocusStr, false );
	Canvas.TextSize( CharFocus, sx, sy);
	Canvas.SetPos( x + 368 - sx, y + 82 );
	Canvas.DrawText( CharFocus, false );
	Canvas.SetPos( x + 198, y + 101 );
	Canvas.DrawText( fCashStr, false );
	Canvas.TextSize( CharCash, sx, sy);
	Canvas.SetPos( x + 368 - sx, y + 101 );
	Canvas.DrawText( CharCash, false );
}	

function RenderSavedGameInfo( Canvas Canvas, int x, int y, SavedGameInfo info )
{
	local float sx, sy;

	Canvas.SetPos( x + 18, y + 10);
	Canvas.DrawText( info.CharacterName, false );

	Canvas.TextSize( info.SaveDate, sx, sy );
	Canvas.SetPos( x + 370 - sx, y + 10 );
	Canvas.DrawText( info.SaveDate, false );

	Canvas.SetPos( x + 18, y + 31 );
	Canvas.DrawTile( fStrIconTex, 32, 16, 0, 0, 32, 16 );
	Canvas.SetPos( x + 56, y + 32 );
	Canvas.DrawText( info.CharacterStrength, false );

	Canvas.SetPos( x + 118, y + 31 );
	Canvas.DrawTile( fAglIconTex, 32, 16, 0, 0, 32, 16 );
	Canvas.SetPos( x + 156, y + 31 );
	Canvas.DrawText( info.CharacterAgility, false );

	Canvas.SetPos( x + 218, y + 31 );
	Canvas.DrawTile( fDexIconTex, 32, 16, 0, 0, 32, 16 );
	Canvas.SetPos( x + 256, y + 31 );
	Canvas.DrawText( info.CharacterDexterity, false );

	Canvas.SetPos( x + 318, y + 31 );
	Canvas.DrawTile( fConIconTex, 32, 16, 0, 0, 32, 16 );
	Canvas.SetPos( x + 356, y + 31 );
	Canvas.DrawText( info.CharacterConstitution, false );

	Canvas.SetPos( x + 18, y + 52 );
	Canvas.DrawTile( fHealthIconTex, 16, 16, 0, 0, 16, 16 );
	Canvas.SetPos( x + 36, y + 52 );
	Canvas.DrawText( info.CharacterCurHealth $ " / " $ info.CharacterFullHealth, false );

	Canvas.SetPos( x + 114, y + 52 );
	Canvas.DrawTile( fFocusIconTex, 16, 16, 0, 0, 16, 16 );
	Canvas.SetPos( x + 132, y + 52 );
	Canvas.DrawText( info.CharacterCurFocus $ " / " $ info.CharacterFullFocus, false );

	Canvas.TextSize( "$" $ info.CharacterCash, sx, sy );
	Canvas.SetPos( x + 370 - sx, y + 52 );
	Canvas.DrawText( "$" $ info.CharacterCash, false );

	Canvas.SetPos( x + 18, y + 73 );
	Canvas.DrawText( info.MissionDescription, false );

	Canvas.SetPos( x + 388, y + 14 );
	//Canvas.DrawTile( info.ScreenShot, 64, 64, 0, 0, 64, 64 );
	Canvas.DrawBox(Canvas, 64, 64);
}

defaultproperties
{
	fUpSound=Sound'B9SoundFX.Menu.up_1'
	fDownSound=Sound'B9SoundFX.Menu.down_1'
	fClickSound=Sound'B9SoundFX.Menu.ok_1'
	fCancelSound=Sound'B9SoundFX.Menu.cancel_2'
	fPortraitTex=Texture'B9Menu_tex_std.Portraits.norm_fem_portrait'
	fMiniFrameTopLeftTex=Texture'B9Menu_textures.Quarter_Size_Panes.mini_frame_top_left'
	fMiniFrameDividerLeftTex=Texture'B9Menu_textures.Quarter_Size_Panes.mini_frame_divider_left'
	fMiniFrameMiddleLeftTex=Texture'B9Menu_textures.Quarter_Size_Panes.mini_frame_left'
	fMiniFrameBottomLeftTex=TexScaler'B9Menu_textures.Quarter_Size_Panes.mini_frame_bottom_left'
	fFullFrameTopRightTex=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_top_right'
	fFullFrameMiddleRightTex=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_middle_right'
	fFullFrameBottomRightTex=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_right'
	fFullFrameDividerRightTex=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_divider_right'
	fStrIconTex=Texture'B9Menu_textures.Icons.str_icon'
	fAglIconTex=Texture'B9Menu_textures.Icons.agl_icon'
	fDexIconTex=Texture'B9Menu_textures.Icons.dex_icon'
	fConIconTex=Texture'B9Menu_textures.Icons.con_icon'
	fHealthStr="HEALTH:"
	fFocusStr="CHI:"
	fCashStr="CASH:"
	fFileStr="GAME"
	fSkillsStr="SKILLS"
	fWeaponsStr="WEAPONS"
	fItemsStr="ITEMS"
	MSA24Font=Font'B9_Fonts.MicroscanA24'
	MSA16Font=Font'B9_Fonts.MicroscanA16'
}