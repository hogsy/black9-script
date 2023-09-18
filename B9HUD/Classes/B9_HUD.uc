//=============================================================================
// B9_HUD
//
// 
//
// 
//=============================================================================

class B9_HUD extends HUD
//	noexport
	native;


// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

//#exec TEXTURE IMPORT NAME=TargetReticleArrow1 FILE=textures\TargetReticleArrowA8.bmp FLAGS=0 MIPS=OFF
//#exec TEXTURE IMPORT NAME=TargetReticleArrow2 FILE=textures\TargetReticleArrowB8.bmp FLAGS=0 MIPS=OFF
#exec OBJ LOAD FILE=..\textures\Black9_Skins.utx PACKAGE=Black9_Skins


var protected transient CanvasUtility fCanvasUtility;
var public transient bool fHideHUD;
var() localized string MSA20Font;
var() localized string MSA24Font;

var class<B9_MenuInteraction>	MyFactoryClass;

// targeting
struct tTargetItem
{
	var Actor	fActor;
	var float	fRange;
	var float	fBearing;
	var Vector	fHitLocation;
	var bool	fLocked;
	var float	fTimeLocked;
};

var tTargetItem				fTargetItem;
var array< tTargetItem >	fTargets;

const	kHUDActionIconWidth		= 16;
const	kHUDActionIconHeight	= 16;
var material	fHUDPickupTex;
var material	fHUDUseTex;
var material	fHUDHackTex;
var material	fHUDTalkTex;
var material	fHUDAttackTex;

var int				fInfoCounter;
var B9_AdvancedPawn	fPlayerPawn;

// Various stats displays
var public B9_OverheadMap				fOverheadMap;
var public B9_HealthPanel				fHealthPanel;
var public AttributesPanel				fAttributesPanel;
var public B9_TargetingReticule			fTargetingReticule;
var public B9_InventoryPanel			fInventoryPanel;
var public NightScopeOverlay			fNightScopeOverlay;
var public TEMP_PDA_panel				fTempPDAPanel;
var public ConversationPanel			fConversationPanel;
var public B9_DepotPanel				fDepotPanel;


var public transient B9_ActionMeter	B9Meter;

var public transient Interaction fPauseMenu;


var string fLocationMessageA;
var string fLocationMessageB;
var float fLocationTicks;
var font fLargeFont;
var font fMediumFont;
var string fNewline;
var private bool	fShowMeter;
var private bool	fShowNightscopeOverlay;
var private bool	fDrawConversationPanel;
var private bool	fShowDepotPanel;

var private B9_HUDConsoleMemoryUsage fMemoryUsage;
var public B9_HUDDebugMenu fDebugMenu;

// Debug only
var box BSPLeafColBndsExt;

var string DefaultFontName;
var localized string SmallFontName;
var localized string MedFontName;
var localized string BigFontName;
var localized string HugeFontName;

var private bool fShowTempPDA;


var class<B9_MenuInteraction>	fPDAClass;
var class<B9_MenuPDA_Menu>	fPDAMenuClass;

native(2310) static final function DrawOverheadMap( Canvas canvas, int x1, int y1, int x2, int y2, bool ellipse );
native(2311) static final function CalcOverheadMap();

event PostLoadGame()
{
	Super.PostLoadGame();

	// Recreate any transient variables when game reloaded.
	fCanvasUtility = new(none) class'CanvasUtility';
	AddInteractions();
}

function Think( float DeltaTime )
{
	if( fShowMeter == true  && B9Meter != None )
	{
		B9Meter.Think(DeltaTime);
	}
}

function Tick(float Delta)
{
	Super.Tick( Delta );

	if (fLocationTicks >= 0.0f)
	{
		fLocationTicks -= Delta;
		if (fLocationTicks < 0.0f)
			fLocationTicks = 0.0f;
	}

	// Kludge code: PlayerOwner.Player is still None in PostBeginPlay
	// so do it from here for now
	if(B9Meter == None)
	{
		if(PlayerOwner != None)
		{
			if(PlayerOwner.Player != None)
			{	
				if(PlayerOwner.Player.InteractionMaster != None)
				{
					AddInteractions();
				}
			}
		}
	}
}

function B9_AdvancedPawn GetAdvancedPawn()
{
	if ( fPlayerPawn == None )
	{
		if ( PlayerOwner != None )
		{
			if ( B9_PlayerControllerBase( PlayerOwner ) != None )
			{
				fPlayerPawn	= B9_PlayerControllerBase( PlayerOwner ).GetAdvancedPawn();
			}
		}
	}
	else
	{
		--fInfoCounter;

		// Check every once in a while anyway
		if ( fInfoCounter < 0 )
		{
			fInfoCounter	= 50;
			fPlayerPawn		= None;

			return GetAdvancedPawn();
		}
	}

	return fPlayerPawn;
}

function Pawn GetVehiclePawn()
{
	if ( PlayerOwner != None )
	{
		if ( B9_PlayerControllerBase( PlayerOwner ) != None )
		{
			return B9_PlayerControllerBase( PlayerOwner ).GetVehiclePawn();
		}
	}

	return None;
}

function ShowMeter(bool show)
{
	fShowMeter = show;
}

function PreBeginPlay()
{
	Super.PreBeginPlay();

	CalcOverheadMap();

	fCanvasUtility = new(none) class'CanvasUtility';

	fOverheadMap		= Spawn( class'B9_OverheadMap', self );
	fHealthPanel		= Spawn( class'B9_HealthPanel', self );
	fTargetingReticule	= Spawn( class'B9_TargetingReticule', self );
	fInventoryPanel		= Spawn( class'B9_InventoryPanel', self );
	fNightScopeOverlay	= Spawn( class'NightScopeOverlay', self );
	fMemoryUsage		= Spawn( class'B9_HUDConsoleMemoryUsage', self );
	fDebugMenu			= Spawn( class'B9_HUDDebugMenu', self );
	fConversationPanel	= Spawn( class'ConversationPanel', self );
	fTempPDAPanel		= Spawn( class'TEMP_PDA_panel', self );
	fDepotPanel			= Spawn( class'B9_DepotPanel', self );

	fLargeFont			= Font( DynamicLoadObject( MSA24Font, class'Font' ) );
	fMediumFont			= Font( DynamicLoadObject( MSA20Font, class'Font' ) );

	if(SmallFontName != DefaultFontName)
	{
		SmallFont=font( DynamicLoadObject(SmallFontName, class'Font' ) );
		//Log( "XTTemp/B9NanoSkills.skill_hacking::PreBeginPlay(): SmallFontName="$ SmallFontName  );
	}
	//else
	//{
	//	Log( "XTTemp/B9NanoSkills.skill_hacking::PreBeginPlay() Failed: SmallFontName="$ SmallFontName  );
	//}

	if(MedFontName != DefaultFontName)
	{
		MedFont=font( DynamicLoadObject(MedFontName, class'Font' ) );
	}

	if(BigFontName != DefaultFontName)
	{
		BigFont=font( DynamicLoadObject(BigFontName, class'Font' ) );
	}

	if(HugeFontName != DefaultFontName)
	{
		LargeFont=font( DynamicLoadObject(HugeFontName, class'Font' ) );
	}
															          
	fPDAMenuClass = class<B9_MenuPDA_Menu>(DynamicLoadObject("B9Menus.B9_PDA_Pause_InitialMenu", class'Class'));
}

function PostBeginPlay()
{
	super.PostBeginPlay();

	// PlayerOwner.Player is still None at this point
	// do this from tick instead
	//AddInteractions();
}

event Destroyed()
{
	if (B9Meter != None)
	{
		PlayerOwner.Player.InteractionMaster.RemoveInteraction(B9Meter);
		B9Meter = None;
	}
}

function AddInteractions()
{
	local Interaction meter;

	meter = PlayerOwner.Player.InteractionMaster.AddInteraction("B9Hud.B9_ActionMeter", PlayerOwner.Player);
	B9Meter = B9_ActionMeter(meter);

	Log( "B9Hud - adding crosshair" );
	PlayerOwner.Player.InteractionMaster.AddInteraction( "B9Hud.B9_Crosshair", PlayerOwner.Player );
}

exec function ToggleHUD()
{
	// Panels
	fOverheadMap.ToggleInView();
	fHealthPanel.ToggleInView();
	//fAttributesPanel.ToggleInView();

	fInventoryPanel.ToggleInView();

	fHideHUD = !fHideHUD;	
}

exec function ToggleMemory()
{
	fMemoryUsage.fVisible = !fMemoryUsage.fVisible;
}

exec function ToggleDebugMenu()
{
	fDebugMenu.fVisible = !fDebugMenu.fVisible;
}

function DrawActions( Canvas canvas )
{
	local float		HUDIconScale;
	local float		HUDActionIconWidth;
	local float		HUDActionIconHeight;
	local int		HUDActions;
	local int		i;
	local Vector	position;


	HUDIconScale		= 1;
	HUDActionIconWidth	= kHUDActionIconWidth * HUDIconScale;
	HUDActionIconHeight	= kHUDActionIconHeight * HUDIconScale;

	for ( i = 0; i < fTargets.Length; ++i )
	{
		position	= fCanvasUtility.Project( canvas, fTargets[ i ].fActor.GetHUDActionLocation() );
		HUDActions	= fTargets[ i ].fActor.GetHUDActions( GetAdvancedPawn() );

		canvas.SetDrawColor( 255, 255, 255 );
		canvas.Style = ERenderStyle.STY_Translucent;

		position.x	= position.x - HUDActionIconWidth / 2;
		position.y	= position.y - HUDActionIconHeight / 2;

		if ( position.z >= 0 )
		{
			if ( ( HUDActions & kHUDAction_PickUp ) != 0 )
			{
				canvas.SetPos( position.x, position.y );
				canvas.DrawTile( fHUDPickupTex, HUDActionIconWidth, HUDActionIconHeight, 0, 0, kHUDActionIconWidth - 1, kHUDActionIconHeight - 1 );
			}
			if ( ( HUDActions & kHUDAction_Use ) != 0 )
			{
				canvas.SetPos( position.x, position.y );
				canvas.DrawTile( fHUDUseTex, HUDActionIconWidth, HUDActionIconHeight, 0, 0, kHUDActionIconWidth - 1, kHUDActionIconHeight - 1 );
			}
			if ( ( HUDActions & kHUDAction_Hack ) != 0 )
			{
				canvas.SetPos( position.x, position.y );
				canvas.DrawTile( fHUDHackTex, HUDActionIconWidth, HUDActionIconHeight, 0, 0, kHUDActionIconWidth - 1, kHUDActionIconHeight - 1 );
			}
			if ( ( HUDActions & kHUDAction_Talk ) != 0 )
			{
				canvas.SetPos( position.x, position.y );
				canvas.DrawTile( fHUDTalkTex, HUDActionIconWidth, HUDActionIconHeight, 0, 0, kHUDActionIconWidth - 1, kHUDActionIconHeight - 1 );
			}
			if ( ( HUDActions & kHUDAction_Attack ) != 0 )
			{
				canvas.SetPos( position.x, position.y );
				canvas.DrawTile( fHUDAttackTex, HUDActionIconWidth, HUDActionIconHeight, 0, 0, kHUDActionIconWidth - 1, kHUDActionIconHeight - 1 );
			}
		}
	}
}

/* DrawHUD() Draw HUD elements on canvas.
*/
function DrawHUD(canvas Canvas)
{
	local B9_Pawn b9Pawn;
	
	if( fShowNightscopeOverlay ) // Draw this first, and regardless of fHideHUD
	{
		fNightScopeOverlay.Draw( Canvas );
	}
/*
	if ( !fHideHUD )
	{
		DrawActions( canvas );
	}
*/
	
	if ( fTargetingReticule != None  && !fHideHUD )
	{
		fTargetingReticule.Draw(canvas);
	}
	

	// Draw the stats display panel overlays
	if ( !fHideHUD )
	{
		fOverheadMap.Draw(Canvas);
		fHealthPanel.Draw(Canvas);
		fInventoryPanel.Draw(Canvas);
//		DrawOverheadMap( Canvas, 0, 0, 640, 480, true );
	}

	if( fShowTempPDA )
	{
		fTempPDAPanel.Draw( Canvas );
	}

	if( fDrawConversationPanel )
	{
		fConversationPanel.Draw( Canvas );
	}

	if( fShowDepotPanel )
	{
		fDepotPanel.Draw( Canvas );
	}

	fMemoryUsage.Draw(Canvas);
	fDebugMenu.Draw(Canvas);

	if (fLocationTicks > 0.0f)
	{
		DrawLocationMessage(Canvas);
	}	

	b9Pawn = B9_Pawn(PlayerOwner.Pawn);
}

simulated event PostRender( canvas Canvas )
{
	local B9_Pawn b9Pawn;
	Super.PostRender( Canvas );
	b9Pawn = B9_Pawn(PlayerOwner.ViewTarget);
	if ( b9Pawn != None )
			b9Pawn.RenderOverlays(Canvas);
}

/* Draw the Level Action
*/
function bool DrawLevelAction( canvas C )
{
	if (Level.LevelAction == LEVACT_None )
	{
		if (Level.Pauser != None && fPauseMenu != None)
		{
			return false;
		}
	}

	return Super.DrawLevelAction( C );
}

function AddPauseMenu( PlayerController pc, optional String menuToShow )
{
	local B9_MenuInteraction mi;
	local class<B9_MenuPDA_Menu> menuClass;
	
	mi = new(None) MyFactoryClass;
	if( menuToshow == "" )
		menuClass = fPDAMenuClass;
	else
	{
		menuClass = class<B9_MenuPDA_Menu>(DynamicLoadObject( menuToShow, class'Class'));
	}
		
	log("MenuCLass"$menuClass);
	fPauseMenu = mi.PushInteraction(class'B9_PDABase', pc, pc.Player,menuClass);

	if (fPauseMenu != None)
		Log("Created Pause Menu");
	else
		Log("Failed to create Pause Menu: ");
}

/*
 * Code to support "location messages" in a headquaters.
 *
 */

simulated function ShowLocationMessage(string message)
{
	local int n;

	fLocationMessageA = message;
	ReplaceText(fLocationMessageA, "<br>", fNewline);
	n = InStr(fLocationMessageA, fNewline);
	if (n == -1)
	{
		fLocationMessageB = "";
	}
	else
	{
		fLocationMessageB = Mid(fLocationMessageA, n + 1);
		fLocationMessageA = Left(fLocationMessageA, n);
	}

	fLocationTicks = 4.0f;			// 3 seconds display, 1 second fade
}

function DrawLocationMessage( canvas Canvas )
{
	local int x, y;
	local float oldClipX, oldClipY, oldOrgX, oldOrgY;
	local float sy, ax, ay, bx, by;
	local bool oldCenter;
	local int w;
	
	w = 512;

	oldClipX = Canvas.ClipX;
	oldClipY = Canvas.ClipY;
	oldOrgX = Canvas.OrgX;
	oldOrgY = Canvas.OrgY;
	oldCenter = Canvas.bCenter;

	Canvas.SetClip(w, 480);
	Canvas.Font = fLargeFont;
	Canvas.StrLen(fLocationMessageA, ax, ay);
	sy = ay;
	if (Len(fLocationMessageB) != 0)
	{
		Canvas.Font = fMediumFont;
		Canvas.StrLen(fLocationMessageB, bx, by);
		sy += by + 2 * Canvas.SpaceY;
	}
	Canvas.SetClip(oldClipX, oldClipY);

	//Canvas.SetOrigin((oldClipX - w) / 2, (oldClipY - sy) / 2);
	Canvas.SetOrigin((oldClipX - w) / 2, (oldClipY - sy) - 20 );
	Canvas.SetClip(w, 480);

	Canvas.Style = ERenderStyle.STY_Normal;
	if (fLocationTicks >= 1.0f)
	{
		Canvas.SetDrawColor(255, 255, 255);
	}
	else
	{
		x = 160.0f * fLocationTicks + 95.0f;
		if (x <= 0) x = 1;
		Canvas.SetDrawColor(x, x, x);
	}

	Canvas.bCenter = true;
	Canvas.Font = fLargeFont;
	Canvas.SetPos(0, 0);
	Canvas.DrawText(fLocationMessageA);
	if (Len(fLocationMessageB) != 0)
	{
		Canvas.Font = fMediumFont;
		Canvas.SetPos(0, ay + 2 * Canvas.SpaceY);
		Canvas.DrawText(fLocationMessageB);
	}

	Canvas.SetOrigin(oldOrgX, oldOrgY); 
	Canvas.SetClip(oldClipX, oldClipY);
	Canvas.bCenter = oldCenter;
}

function DrawNightscopeOverlay( bool DrawScope )
{
	fShowNightscopeOverlay = DrawScope;
}

function ShowDepotPanel( int Kind, optional int Current, optional int Full )
{
	fShowDepotPanel = (Kind != -1);
	fDepotPanel.Kind = Kind;
	fDepotPanel.CurrentAmount = Current;
	fDepotPanel.ResourceAmount = Full;
}

function ShowCountdownTimer(bool running, int currentSeconds, int alertSeconds, sound normalTick, sound alertTick)
{
	fOverheadMap.ShowCountdownTimer(running, currentSeconds, alertSeconds, normalTick, alertTick);
}

function ToggleTempPDA()
{
	fShowTempPDA = !fShowTempPDA;
}

function ShowConversationPanel( bool show )
{
	fDrawConversationPanel = show;

	if( !fDrawConversationPanel )
	{
		fConversationPanel.ClearAll();
	}
}

function bool IsConversationPanelVisible()
{
	return fDrawConversationPanel;
}

function AddStringToConversation( string s )
{
	fConversationPanel.AddString( s );
}



defaultproperties
{
	MSA20Font="B9_Fonts.MicroscanA20"
	MSA24Font="B9_Fonts.MicroscanA24"
	MyFactoryClass=Class'B9BasicTypes.B9_MenuInteraction'
	fHUDPickupTex=Texture'B9HUD_textures.HUDActions.pickup_tex'
	fHUDUseTex=Texture'B9HUD_textures.HUDActions.action_U_small_tex'
	fHUDHackTex=Texture'B9HUD_textures.HUDActions.action_H_small_tex'
	fHUDTalkTex=Texture'B9HUD_textures.HUDActions.action_T_small_tex'
	fHUDAttackTex=Texture'B9HUD_textures.HUDActions.action_A_small_tex'
	fNewline="
"
	DefaultFontName="DefaultFont"
	SmallFontName="DefaultFont"
	MedFontName="DefaultFont"
	BigFontName="DefaultFont"
	HugeFontName="DefaultFont"
	fPDAClass=Class'B9BasicTypes.B9_PDABase'
}