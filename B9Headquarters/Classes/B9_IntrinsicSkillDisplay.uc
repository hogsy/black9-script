/////////////////////////////////////////////////////////////
// B9_IntrinsicSkillDisplay
//

class B9_IntrinsicSkillDisplay extends B9_BaseKiosk;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX
#exec OBJ LOAD FILE=..\textures\B9Menu_Textures.utx PACKAGE=B9Menu_Textures
#exec OBJ LOAD FILE=..\textures\B9MenuHelp_Textures.utx PACKAGE=B9MenuHelp_Textures

struct SkillInfo
{
	var string Label;
	var string Desc;
	var bool Str;
	var bool Agl;
	var bool Dex;
	var bool Con;
};

var B9_PageBrowser DescriptionView;
var array<string> DescriptionBody;
var bool fCache;

var texture fSingleLineLeft;
var texture fSingleLineRight;
var texture fFullFrameTopLeft;
var texture fFullFrameTopRight;
var texture fFullFrameMiddleLeft;
var texture fFullFrameMiddleRight;
var texture fFullFrameBottomLeft;
var texture fFullFrameBottomRight;
var texture fBackImage;
var texture fStrIcon;
var texture fAglIcon;
var texture fDexIcon;
var texture fConIcon;

var string fStrTitleLine;
var string fStrValueLine;
var string fStrPawnStr;
var string fStrPawnAgl;
var string fStrPawnDex;
var string fStrPawnCon;

var localized string fStrNA;
var localized string fStrValue;

var SkillInfo fInfo;

var localized SkillInfo fClimbingInfo;
var localized SkillInfo fSpeedInfo;
var localized SkillInfo fFirearmTargetingInfo;
var localized SkillInfo fHeavyWpnTargetingInfo;
var localized SkillInfo fMeleeCombatInfo;
var localized SkillInfo fWpnThrowingInfo;
var localized SkillInfo fJumpingInfo;
var localized SkillInfo fDodgingInfo;
var localized SkillInfo fFallRecoveryInfo;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentInteraction. You don't have to implement MenuInit(),
// but you should call super.MenuInit() if you do.
function Initialized()
{
	log(self@"I'm alive");

	fCache = true;

	DescriptionView = new(None) class'B9_PageBrowser';
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
	}
}

function string ServerTriggerTagName(name TriggerTag)
{
	return "" $ TriggerTag $ "Trigger";
}

function SetGenericString(int id, string s)
{
	SetSkillByName(s);
}

function SetSkillByName(string skillName)
{
	local B9_AdvancedPawn ap;
	local int value;

	ap = B9_AdvancedPawn(RootController.Pawn);


	if (skillName == "Speed")
	{
		fInfo = fSpeedInfo;
		value = ap.fCharacterSpeed;
	}
	else if (skillName == "FirearmTargeting")
	{
		fInfo = fFirearmTargetingInfo;
		value = ap.fCharacterTargetingFireArms;
	}
	else if (skillName == "HeavyWpnTargeting")
	{
		fInfo = fHeavyWpnTargetingInfo;
		value = ap.fCharacterTargetingHeavyWeapons;
	}
	else if (skillName == "MeleeCombat")
	{
		fInfo = fMeleeCombatInfo;
		value = ap.fCharacterMeleeCombat;
	}
	else if (skillName == "Jumping")
	{
		fInfo = fJumpingInfo;
		value = ap.fCharacterJumping;
	}


	fStrValueLine = fStrValue $ string(value) $ " / 100";
	fStrTitleLine = fInfo.Label;
	DescriptionBody[0] = fInfo.Desc;

	if (fInfo.Str) fStrPawnStr = string(ap.fCharacterStrength);
	else fStrPawnStr = fStrNA;
	if (fInfo.Agl) fStrPawnAgl = string(ap.fCharacterAgility);
	else fStrPawnAgl = fStrNA;
	if (fInfo.Dex) fStrPawnDex = string(ap.fCharacterDexterity);
	else fStrPawnDex = fStrNA;
	if (fInfo.Con) fStrPawnCon = string(ap.fCharacterConstitution);
	else fStrPawnCon = fStrNA;
}

function RenderDisplay( canvas Canvas )
{
	local color white;
	local font oldFont;
	local float oldOrgX, oldOrgY;
	local float oldClipX, oldClipY;
	local int x, y;
	local float sx, sy, tx;
	local int i;

	oldFont = Canvas.Font;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	oldOrgX = Canvas.OrgX;
	oldOrgY = Canvas.OrgY;
	oldClipX = Canvas.ClipX;
	oldClipY = Canvas.ClipY;

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
	Canvas.TextSize(fStrTitleLine, sx, sy);
	Canvas.SetPos( x - sx / 2.0, y - 32 + 20 );
	Canvas.DrawText(fStrTitleLine);

	x = 320 - 256;
	y += 42;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fSingleLineLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fSingleLineRight, 256, 32, 0, 0, 256, 32 );

	Canvas.Font = fMyFont16;

	x = 320 - 256 + 24;
	y += 8;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fStrIcon, 32, 16, 0, 0, 32, 16 );

	x += 38;
	Canvas.SetPos( x, y );
	Canvas.DrawText(fStrPawnStr);

	x += 97;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fAglIcon, 32, 16, 0, 0, 32, 16 );

	x += 38;
	Canvas.SetPos( x, y );
	Canvas.DrawText(fStrPawnAgl);

	x += 97;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fDexIcon, 32, 16, 0, 0, 32, 16 );

	x += 38;
	Canvas.SetPos( x, y );
	Canvas.DrawText(fStrPawnDex);

	x += 97;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fConIcon, 32, 16, 0, 0, 32, 16 );

	x += 38;
	Canvas.SetPos( x, y );
	Canvas.DrawText(fStrPawnCon);

	x = 320 - 256;
	y += 42 - 8;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopRight, 256, 32, 0, 0, 256, 32 );

	for (i=0;i<4;i++)
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
		RootInteraction.OriginY + y - 5 * 32 + 16); 
	Canvas.SetClip(512 - 64, 5 * 32 - 32); 

	DescriptionView.RenderPage(Canvas, DescriptionBody, 10000, fCache);
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
	Canvas.DrawTile( fFullFrameBottomLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameBottomRight, 256, 32, 0, 0, 256, 32 );

	Canvas.Font = fMyFont24;
	Canvas.TextSize(fStrValueLine, sx, sy);
	Canvas.SetPos( x - sx / 2.0, y - 32 + 20 );
	Canvas.DrawText(fStrValueLine);

	x = 320 - 128;
	y = 480 - 52;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fBackImage, 256, 32, 0, 0, 256, 32 );

	Canvas.Font = oldFont;
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
	fSingleLineLeft=Texture'B9Menu_textures.Full_Size_Panes.single_line_full_frame_left'
	fSingleLineRight=TexScaler'B9Menu_textures.Full_Size_Panes.single_line_full_frame_right'
	fFullFrameTopLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_top_left'
	fFullFrameTopRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_top_right'
	fFullFrameMiddleLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_middle_left'
	fFullFrameMiddleRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_middle_right'
	fFullFrameBottomLeft=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_left'
	fFullFrameBottomRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_right'
	fBackImage=Texture'B9MenuHelp_Textures.Choices.choice_back'
	fStrIcon=Texture'B9Menu_textures.Icons.str_icon'
	fAglIcon=Texture'B9Menu_textures.Icons.agl_icon'
	fDexIcon=Texture'B9Menu_textures.Icons.dex_icon'
	fConIcon=Texture'B9Menu_textures.Icons.con_icon'
	fStrNA="N/A"
	fStrValue="Value: "
	fClimbingInfo=(Label="CLIMBING",Desc="Increase your Climbing skill to move faster on ladders.",Str=true,agl=true,dex=false,con=false)
	fSpeedInfo=(Label="SPEED",Desc="Increase your Speed skill to accelerate and run more quickly.",Str=false,agl=true,dex=false,con=false)
	fFirearmTargetingInfo=(Label="FIREARMS TARGETING",Desc="Increase your Firearms Targeting skill to lock onto enemies more quickly when using light armaments.",Str=false,agl=true,dex=true,con=false)
	fHeavyWpnTargetingInfo=(Label="HEAVY WEAPONS TARGETING",Desc="Increase your Heavy Weapons Targeting skill to lock onto enemies more quickly when using the most powerful weapons.",Str=true,agl=true,dex=true,con=false)
	fMeleeCombatInfo=(Label="M?L?E COMBAT",Desc="Increase your M?l?e Combat skill to do more damage with m?l?e weapons, such as swords.",Str=true,agl=true,dex=false,con=false)
	fWpnThrowingInfo=(Label="WEAPON THROWING",Desc="Increase your Weapon Throwing skill to increase the distance you can hit targets with weapons like throwing knives and shuriken.",Str=false,agl=true,dex=false,con=false)
	fJumpingInfo=(Label="JUMPING/DODGING",Desc="Increase your Jumping skill to jump higher, evade locked targets faster, and also fall farther without being hurt.",Str=false,agl=true,dex=false,con=false)
	fDodgingInfo=(Label="DODGING",Desc="Increase your Dodging skill to evade faster when jumping away from a locked target.",Str=false,agl=true,dex=false,con=false)
	fFallRecoveryInfo=(Label="FALL RECOVERY",Desc="Increase your Fall Recovery skill to increase the distance you can fall without being hurt.",Str=false,agl=true,dex=false,con=true)
	fBackOffPawn=60
	fFOV=105
}