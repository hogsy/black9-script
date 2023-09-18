//=============================================================================
// B9_DepotPanel
//
// 
//	HUD object, display for depots
// 
//=============================================================================


class B9_DepotPanel extends B9_HUDPanel;

var int Kind;
var int CurrentAmount;
var int ResourceAmount;

var private material			fClipIconTex;
var private float				fFlashCounter;
var private	int					fMaxClipDisplay;

const	kPanelLeft		= 35;
const	kPanelBottom	= -32;
const	kPanelGunIcon	= 35;	// subtract from bottom
const	kPanelHealthIcon = 35;	// subtract from bottom
const	kPanelUseIcon	= 35;	// subtract from (bottom - gun icon)

const	kWeapon_Width  = 64;
const	kWeapon_Height = 32;

const	ClipSizeX = 11;
const	ClipSizeY = 27;

function Tick(float Delta)
{
	Super.Tick( Delta );
	fFlashCounter += Delta;
}

function Draw( Canvas canvas )
{
	local B9_HUD				myHUD;
	local B9_BasicPlayerPawn	basicPlayerPawn;
	local B9WeaponBase			gun;
	local Inventory				inv;
	local class<Inventory>		findClass;
	local int					top;

	Super.Draw(Canvas);

	myHUD	= B9_HUD( Owner );
	if (myHUD != None)
	{
		basicPlayerPawn	= B9_BasicPlayerPawn( myHUD.GetAdvancedPawn() );
		if (basicPlayerPawn != None)
		{
			if (Kind >= class'B9_AmmoDepotTrigger'.Default.Basis &&
				Kind <= class'B9_AmmoDepotTrigger'.Default.Basis + 1 &&
				basicPlayerPawn.Weapon != None)
			{
				gun = B9WeaponBase( basicPlayerPawn.Weapon );
				if (gun == None)
					return;

				if (Kind == 1)
					findClass = class'B9HeavyWeapon';
				else
					findClass = class'B9LightWeapon';

				if (!ClassIsChildOf(gun.Class, findClass) || ClassIsChildOf(gun.Class, class'GrapplingHook'))
					return;

				top = Canvas.SizeY + kPanelBottom - kPanelGunIcon;
				DrawAmmoInfo( Canvas, gun, kPanelLeft, top );

				top -= kPanelUseIcon;
				DrawUseIcon( Canvas, kPanelLeft, top );
				return;
			}

			if (Kind == class'B9_HealthDepotTrigger'.Default.Basis)
			{
				top = Canvas.SizeY + kPanelBottom - kPanelHealthIcon;
				DrawHealthInfo( Canvas, basicPlayerPawn, kPanelLeft, top );

				top -= kPanelUseIcon;
				DrawUseIcon( Canvas, kPanelLeft, top );
				return;
			}
		}
	}
}

function DrawAmmoInfo( Canvas canvas, B9WeaponBase gun, int left, int top )
{
	local material	itemTex;
	local int		sizeX, sizeY;
	local int		numClips;
	local int		loop;
	local int		height;

	sizeX	= kWeapon_Width;
	sizeY	= kWeapon_Height;

	itemTex = gun.Icon;
	if( itemTex != none )
	{
		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;

		Canvas.SetPos( left, top );
		Canvas.DrawTile( itemTex, sizeX, sizeY, 0, 0, sizeX, sizeY );

		numClips = CurrentAmount;
		if (numClips > fMaxClipDisplay)
			numClips = fMaxClipDisplay;

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;

		left += sizeX + 3;
		for ( loop=0; loop<numClips ; loop++ )
		{
			Canvas.SetPos( left + ( ClipSizeX + 1 ) * loop, top );
			Canvas.DrawTile( fClipIconTex, ClipSizeX, ClipSizeY, 0, 0, ClipSizeX, ClipSizeY );
		}
	}
}

function DrawHealthInfo( Canvas canvas, B9_BasicPlayerPawn APawn, int left, int top )
{
	local int n;

	Canvas.Style = ERenderStyle.STY_Translucent;

	Canvas.SetDrawColor( 0, 128, 255 );
	Canvas.SetPos( left, top );
	Canvas.DrawTile( material'B9HUD_textures.Browser.Healing_BrIcon_tex', 32, 32, 0, 0, 32, 32 );

	Canvas.SetPos( left + 35, top + 6 );
	Canvas.DrawBox(Canvas, 126, 18);

	n = (124 * CurrentAmount) / ResourceAmount;

	if (n > 0)
	{
		Canvas.SetDrawColor( 255, 0, 0 );
		Canvas.SetPos( left + 37, top + 8 );
		Canvas.DrawRect( Texture'engine.WhiteSquareTexture', n, 16 );
	}
	if (n < 124)
	{
		Canvas.SetDrawColor( 32, 32, 32 );
		Canvas.SetPos( left + 37 + n, top + 8 );
		Canvas.DrawRect( Texture'engine.WhiteSquareTexture', 124 - n, 16 );
	}
}

function DrawUseIcon( Canvas canvas, int left, int top )
{
	// Put real Use icon drawing code here!!!!

/*
	local float fc;
	local int bright;

	fc = fFlashCounter % 2.0f;
	if (fc < 1.0f) bright = float(255) * fc;
	else bright = float(255) * (2.0f - fc);
	Canvas.SetDrawColor( bright, bright, bright );

	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.SetPos( left + 2, top + 2 );
    Canvas.DrawRect(Texture'engine.WhiteSquareTexture', 28, 28);
*/
}

defaultproperties
{
	fClipIconTex=Texture'B9HUD_textures.Browser.ammo_clip_tex'
	fMaxClipDisplay=20
}