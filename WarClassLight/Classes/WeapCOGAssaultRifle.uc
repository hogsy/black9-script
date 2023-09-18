//===============================================================================
//  [COG Assault Rifle ]
// Firing modes:
//	single shot (zoomed if have optional zoom)
//  three shoot burst
//  extended burst
//  two clips / different ammo types
//  grenade 
//===============================================================================

class WeapCOGAssaultRifle extends WarfareWeapon;

#exec MESH  MODELIMPORT MESH=CogAssaultRifleMesh MODELFILE=..\WarClassContent\models\CogAssaultRifle.PSK LODSTYLE=10
#exec MESH  ORIGIN MESH=CogAssaultRifleMesh X=0 Y=0 Z=0 YAW=64 PITCH=0 ROLL=0
#exec ANIM  IMPORT ANIM=CogAssaultRifleAnims ANIMFILE=..\WarClassContent\models\CogAssaultRifle.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP   SCALE MESHMAP=CogAssaultRifleMesh X=1.0 Y=1.0 Z=1.0
#exec MESH  DEFAULTANIM MESH=CogAssaultRifleMesh ANIM=CogAssaultRifleAnims

#exec ANIM DIGEST ANIM=CogAssaultRifleAnims VERBOSE USERAWINFO

#exec OBJ LOAD FILE=..\textures\CogAssaultRifleTex.utx PACKAGE=CogAssaultRifleTex
#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax PACKAGE=WeaponSounds
#exec OBJ LOAD FILE=..\StaticMeshes\3pguns_meshes.usx PACKAGE=3pguns_meshes
#exec OBJ LOAD FILE=..\Textures\TempHud.utx PACKAGE=TempHud

#EXEC MESHMAP SETTEXTURE MESHMAP=CogAssaultRifleMesh NUM=0 TEXTURE=CogAssaultRifleTex.SC_COGAssTex
#EXEC MESHMAP SETTEXTURE MESHMAP=CogAssaultRifleMesh NUM=1 TEXTURE=CogAssaultRifleTex.Sc_CogHand
#EXEC MESHMAP SETTEXTURE MESHMAP=CogAssaultRifleMesh NUM=2 TEXTURE=CogAssaultRifleTex.Sc_CogAssLED
#EXEC MESHMAP SETTEXTURE MESHMAP=CogAssaultRifleMesh NUM=3 TEXTURE=CogAssaultRifleTex.SC_Cogmeshing
#EXEC MESHMAP SETTEXTURE MESHMAP=CogAssaultRifleMesh NUM=4 TEXTURE=CogAssaultRifleTex.SC_COGAssTex

#exec MESH  ATTACHNAME MESH=CogAssaultRifleMesh BONE="gun" TAG="Gun"  YAW=00.0 PITCH=00.0 ROLL=0.0  X=0 Y=0 Z=0
#exec MESH  ATTACHNAME MESH=CogAssaultRifleMesh BONE="GrenadePump" TAG="GrenadePump"  YAW=00.0 PITCH=00.0 ROLL=0.0  X=0 Y=0 Z=0

#exec AUDIO IMPORT FILE="..\botpack\Sounds\flak\flachit1.WAV" NAME="Hit1" GROUP="flak"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\flak\flachit3.WAV" NAME="Hit3" GROUP="flak"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\flak\flachit5.WAV" NAME="Hit5" GROUP="flak"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\flak\chunkhit.WAV" NAME="ChunkHit" GROUP="flak"


#exec ANIM NOTIFY ANIM=CogAssaultRifleAnims SEQ=BurstUp TIME=0.33 FUNCTION=AnimShoot
#exec ANIM NOTIFY ANIM=CogAssaultRifleAnims SEQ=BurstUp TIME=0.67 FUNCTION=AnimShoot
//#exec ANIM NOTIFY ANIM=CogAssaultRifleAnims SEQ=BurstDown TIME=0.33 FUNCTION=AnimShootDown
//#exec ANIM NOTIFY ANIM=CogAssaultRifleAnims SEQ=BurstDown TIME=0.67 FUNCTION=AnimShootDown

const MODE_Single  = 0;
const MODE_Burst   = 1;
const MODE_Auto    = 2;	
const MODE_Grenade = 3;		

var() localized string FiringModeStr[4];

var byte FiringMode, OldMode;	
var byte FireCount;
var bool bGrenadeLoaded;
var bool bZoomed;
var byte LoadOut;	// 2=silencer, 4=grenade, 1=scope

var class<AssaultRifleAmmo> ClipTypes[2];			
var AssaultRifleAmmo Clips[2];
var int ClipPickupAmounts[2];					 

var class<GrenadeAmmunition> GrenadeType;
var GrenadeAmmunition GrenadeAmmo;
var int GrenadePickupAmount;

var Ammunition OldAmmo;

var float PickupAmmounts[3];

var float VerticalError;
var name SingleFires[3];
var float LastCleanTime;
var actor Scope, Silencer, GrenadeLauncher;
var sound ReloadGrenadeSound,LensSound;
var texture SilencedMuzzleFlash;
var int BurstCount;
var float LastFireTime;

var vector TracerOffset;
var int TracerCnt;

replication
{
	// Relationships.
	reliable if( bNetOwner && (Role==ROLE_Authority) )
		LoadOut, GrenadeAmmo, FiringMode, Clips;

	// functions
	reliable if( bNetOwner && (Role==ROLE_Authority) )
		ClientSetLoadOut; 
	reliable if( bNetOwner && (Role<ROLE_Authority) )
		ServerSetClip, SetLoadout;
}

function ServerFire()
{
	Super.ServerFire();
	IncrementFlashCount();
}


function bool HandlePickupQuery( Pickup Item )
{
	local Pawn P;
	local WeapCOGAssaultRifle AR;

	if (Item.InventoryType == Class)
	{
		if ( WeaponPickup(item).bWeaponStay && ((item.inventory == None) || item.inventory.bTossedOut) )
			return true;
		P = Pawn(Owner);
		
		AR = WeapCOGAssaultRifle(Item.Inventory);
		if ( AR != None )
		{
			if (Clips[0]!=None)
				Clips[0].AddAmmo(AR.PickupAmmounts[0]);
				
			if (Clips[1]!=None)
				Clips[1].AddAmmo(AR.PickupAmmounts[1]);

			if (GrenadeAmmo!=None)
				GrenadeAmmo.AddAmmo(AR.PickupAmmounts[2]);
		}
		
		Item.AnnouncePickup(Pawn(Owner));
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	// FIXME TEMP
	if ( Instigator.bIgnorePlayFiring )
		return;
	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);	
	EndTrace = StartTrace + (YOffset + Accuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (ZOffset + Accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (TraceDist * X); 
	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);

	AmmoType.ProcessTraceHit(self, Other, HitLocation, HitNormal, X,Y,Z);

	if (ThirdPersonActor!=None)
		AttachmentCOGAssaultRifle(ThirdPersonActor).HitLoc = HitLocation;

}

simulated function IncrementFlashCount()
{
	if (FiringMode!=MODE_Burst)
		Super.IncrementFlashCount();
	else if (BurstCount==0)
	{
		FlashCount++;
		if ( WeaponAttachment(ThirdPersonActor) != None )
		{
			WeaponAttachment(ThirdPersonActor).FlashCount = FlashCount;
			WeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
		}
	}
}

simulated function LocalFire()
{
	bPointing = true;
	if ( Affector != None )
		Affector.FireEffect();
	PlayFiring();
}		


simulated function AssaultRifleAmmo OtherClip()
{
	if (AmmoType==Clips[0])
		return Clips[1];
	else 
		return Clips[0];
}

// FindClip - returns a clip containing ammo

function function AssaultRifleAmmo FindClip()
{
	local int i;
	
	for (i=0;i<2;i++)
	{
		if ( Clips[i].HasAmmo() )
			return Clips[i];
	}
	
	return None;
}

simulated function AttachToPawn(Pawn P)
{
	Super.AttachToPawn(P);

	if ( FiringMode == MODE_Grenade )
		WeaponAttachment(ThirdPersonActor).FiringMode = 'MODE_Grenade';
	else if (FiringMode == MODE_Auto)
		WeaponAttachment(ThirdPersonActor).FiringMode = 'MODE_Auto';
	else
		WeaponAttachment(ThirdPersonActor).FiringMode = 'MODE_Normal';

}


// FIXME Temp hack
exec function RifleLoadOut(int N)
{
	SetLoadOut(N);
}

//===================================================================
// AI functions

function float GetRating()
{
	local name TempName;
	
	CurrentRating = AmmoType.RateSelf(Instigator, TempName);
	return CurrentRating;
}

function float AmmoStatus()
{
	return 0.5 * (Clips[0].AmmoAmount / Clips[0].MaxAmmo) + (Clips[1].AmmoAmount / Clips[1].MaxAmmo);
}

/* BotFire()
called by NPC firing weapon.  Weapon chooses appropriate firing mode to use (typically no change)
bFinished should only be true if called from the Finished() function
FiringMode can be passed in to specify a firing mode (used by scripted sequences)
*/
function bool BotFire(bool bFinished, optional name FiringMode)
{
	local Ammunition NewClip;

	if ( (FiringMode != 'None') && (FiringMode != '') )
	{
		if ( Clips[0].HasAmmo() )
			NewClip = Clips[0];
		else
			NewClip = Clips[1];

		if ( FiringMode == 'auto' )
			ServerSetClip(NewClip,MODE_Auto);
		else if ( FiringMode == 'single' )
			ServerSetClip(NewClip,MODE_Single);
		else if ( FiringMode == 'grenade' )
			ServerSetClip(GrenadeAmmo,MODE_Grenade);
	}

	return Super.BotFire(bFinished,FiringMode);
}

function float GetAIRating()
{
	local byte NewMode;
	local float GrenadeRating, Clip1Rating, Clip2Rating, BestRating;
	local name RecommendedFiringMode1, RecommendedFiringMode2;
	local Ammunition NewClip;

	// rate grenade
	if ( GrenadeAmmo != None )
		GrenadeRating = GrenadeAmmo.RateSelf(instigator, RecommendedFiringMode1);
	if ( Clips[0] != None )
		Clip1Rating = Clips[0].RateSelf(instigator, RecommendedFiringMode1);
	if ( Clips[1] != None )
		Clip2Rating = Clips[1].RateSelf(instigator, RecommendedFiringMode2);

	if ( (GrenadeRating > Clip1Rating) && (GrenadeRating > Clip2Rating) )
	{
		NewMode = MODE_Grenade;
		BestRating = GrenadeRating * FRand();
		NewClip = GrenadeAmmo; 
	}
	if ( Clip1Rating >= Clip2Rating )
	{
		NewClip = Clips[0];
		if ( RecommendedFiringMode1 == 'burst' )
			NewMode = MODE_Burst;
		else if ( RecommendedFiringMode1 == 'auto' )
			NewMode = MODE_Auto;
		else	
			NewMode = MODE_Single;

		BestRating = Clip1Rating;
	}
	else
	{
		NewClip = Clips[1];
		if ( RecommendedFiringMode2 == 'burst' )
			NewMode = MODE_Burst;
		else if ( RecommendedFiringMode2 == 'auto' )
			NewMode = MODE_Auto;
		else	
			NewMode = MODE_Single;
			
		BestRating = Clip2Rating;
	}

	ServerSetClip(NewClip,NewMode);

	if ( NeedsToReload() && AmmoType.HasAmmo() )
		GotoState('Reloading');

	CurrentRating = BestRating;
	return BestRating;
}


//===================================================================

simulated function Destroyed()
{
	Super.Destroyed();

	if ( Scope != None )
		Scope.Destroy();
		
	if ( Silencer != None )
		Silencer.Destroy();
		
	if ( GrenadeLauncher != None )
		GrenadeLauncher.Destroy();
		
	if (Clips[0] != None)
		Clips[0].Destroy();
	
	if (Clips[1] != None)
		Clips[1].Destroy();
		
	if (GrenadeAmmo != None)
		GrenadeAmmo.Destroy();		
		
}

simulated function PostNetBeginPlay()
{
	LastCleanTime = Level.TimeSeconds + 60 * FRand();
	ClientSetLoadOut(LoadOut);
}

function OwnerEvent(name EventName)
{
	if ( EventName == 'LoadOut' )
	{
		LoadOut = WarfarePawn(Owner).LoadOut;
		SetLoadOut(LoadOut);
	}
	if( Inventory != None )
		Inventory.OwnerEvent(EventName);
}

function SetLoadOut(byte NewLoadOut)
{
	ClientSetLoadOut(NewLoadOut);
	LoadOut = NewLoadOut;
}

simulated function bool HasScope()
{
	return ( (LoadOut & 1) != 0 );
}

simulated function bool HasSilencer()
{
	return ( (LoadOut & 2) != 0 );
}

simulated function bool HasGrenadeLauncher()
{
	return ( (LoadOut & 4) != 0 );
}

simulated function ClientSetLoadOut(byte NewLoadOut)
{
	LoadOut = NewLoadOut;

	// Fixme - only spawn attachments if being drawn

	if ( HasScope() )
	{
		if ( Scope == None )
		{
			Scope = spawn(class'COGAssaultScope',self);
			AttachToBone(Scope,'gun');
		}
	}
	else if ( Scope != None )
	{
		Detach(Scope);
		Scope.Destroy();
		Scope = None;
	}

	if ( HasSilencer()  )
	{
		MFTexture = SilencedMuzzleFlash;
		if ( Silencer == None )
		{
			Silencer = spawn(class'COGAssaultSilencer',self);
			AttachToBone(Silencer,'gun');
		}
	}
	else if ( Silencer != None )
	{
		MFTexture= Default.MFTexture;
		Detach(Silencer);
		Silencer.Destroy();
		Silencer = None;
	}

	if ( HasGrenadeLauncher() )
	{
		if ( GrenadeLauncher == None )
		{
			GrenadeLauncher = spawn(class'COGAssaultGrenadeBarrel', self);
			AttachToBone(GrenadeLauncher,'grenadepump');
			
			// Add Grenade Ammo
		
			if (GrenadeAmmo == None)
			{
				GrenadeAmmo = Spawn(GrenadeType);	// Create ammo type required		
				Instigator.AddInventory(GrenadeAmmo);		// and add to player's inventory
			}
						
			
		}
		// FIXME - need grenade brace
	}
	else if ( GrenadeLauncher != None )
	{
		Detach(GrenadeLauncher);
		GrenadeLauncher.Destroy();
		GrenadeLauncher = None;
		
		// Remove any Grenade Ammo
		
		if (GrenadeAmmo != None)
			GrenadeAmmo.Destroy();
		
	}
}

function GiveAmmo( Pawn Other )
{

	local int i;

	// Give default clips
	
	for (i=0;i<2;i++)
	{

		Clips[i] = AssaultRifleAmmo(Other.FindInventoryType(ClipTypes[i]));
		if ( Clips[i] != None )
			Clips[i].AddAmmo(ClipPickupAmounts[i]);
		else
		{
			Clips[i] = spawn(ClipTypes[i]);
			Other.AddInventory(Clips[i]);
		}
	}

	if (AmmoType==None)
	{
		AmmoType = Clips[0];
		FiringMode = Clips[0].FirstFireMode();
	}

	// add grenade ammo
	
	if ( !HasGrenadeLauncher() || GrenadeType == None )
		return;
		
	GrenadeAmmo = GrenadeAmmunition(Other.FindInventoryType(GrenadeType));

	if ( GrenadeAmmo != None )
		GrenadeAmmo.AddAmmo(GrenadePickupAmount);
	else
	{
		GrenadeAmmo = Spawn(GrenadeType);	// Create ammo type required		
		Other.AddInventory(GrenadeAmmo);		// and add to player's inventory
	}
}	

simulated function DrawHud(canvas Canvas, WarfareHud Hud, FontInfo Fonts, float Scale)
{
	local float X,Y,tScale;
	local Ammunition Ammo;
	local byte Mode;
	local int Team,i;
	
	if (Hud==None)
		return;
		
	if ( ( Instigator == None ) || (Instigator.PlayerReplicationInfo == None) || (Instigator.PlayerReplicationInfo.Team==None) )
		return;

	tScale = Scale;
	if (Scale<1)
		Scale=1;
		
	// Draw the Clip Ammo Display
	
	if (FiringMode==MODE_Grenade)
	{
		
		Ammo = OldAmmo;
		Mode = OldMode;
	}
	else
	{
		Ammo = AmmoType;
		Mode = FiringMode;
	}
	
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetDrawColor(255,255,255);
	Team = Instigator.PlayerReplicationInfo.Team.TeamIndex; 
	Canvas.SetPos(0,0);
	Canvas.DrawTile(Hud.LeftHud[Team],191*Scale,98*Scale,0,0,191,98);

	Canvas.SetDrawColor(255,255,0);
	
	Canvas.Font = Fonts.GetHugeFont(Canvas.ClipX);
	Canvas.SetPos(73*Scale,10*Scale);
	Canvas.DrawText(Ammo.AmmoAmount, false);

	Canvas.SetDrawColor(255,255,255);

	Canvas.SetPos(15*Scale, 54*Scale);
	Canvas.Font = Fonts.GetSmallestFont(Canvas.ClipX);
	Canvas.DrawText(Ammo.ItemName,false);	

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetDrawColor(0,0,0);
	Canvas.SetPos(15*Scale,25*Scale);
	Canvas.Font = Fonts.GetStaticMediumFont(Canvas.ClipX);
	Canvas.DrawText(FiringModeStr[Mode]);

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetDrawColor(255,255,0);
	Canvas.SetPos(14*Scale,24*Scale);
	Canvas.Font = Fonts.GetStaticMediumFont(Canvas.ClipX);
	Canvas.DrawText(FiringModeStr[Mode]);

	if (GrenadeAmmo !=None)
	{
		x = 14*Scale;
		y = 72*Scale;

		Scale = Scale * 0.25;
		for (i=0;i<GrenadeAmmo.MaxAmmo;i++)
		{
			Canvas.SetPos(x,y);
			if ((i+1)>GrenadeAmmo.AmmoAmount)
				Canvas.SetDrawColor(0,127,0);
			else
				Canvas.SetDrawColor(0,255,0);
			
			Canvas.DrawTile(texture 'TempHud.TickMark1',32*Scale, 32*Scale,0,0,32,32);
			x+=(34*Scale);
		}
	}

	Scale=tScale;
	
}

simulated event RenderOverlays( canvas Canvas )
{
	local texture ScopeTexture;
	local Float CX,CY,Scale;
	
	if ( Instigator == None )
		return;

	Scale = Canvas.ClipX/1024;		
		
	if ( (!bZoomed) || (IsInState('Zooming')) )
		DrawWeapon(Canvas);
	
	if ( IsZoomed() )
	{
	
		CX = Canvas.ClipX/2;
		CY = Canvas.ClipY/2;
		
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.SetDrawColor(0,0,0);
		ScopeTexture = texture'COGAssaultRifleTex.COGAssaultZoomedCrosshair';
		
		// Draw the crosshair
		
		Canvas.SetPos(CX-169*Scale,CY-155*Scale);
		Canvas.DrawTile(ScopeTexture,169*Scale,310*Scale, 164,35, 169,310);
		Canvas.SetPos(CX,CY-155*Scale);
		Canvas.DrawTile(ScopeTexture,169*Scale,310*Scale, 332,345, -169,-310);
		
		// Draw Cornerbars
		
		Canvas.SetPos(160*Scale,160*Scale);
		Canvas.DrawTile(ScopeTexture, 111*Scale, 111*Scale , 0 , 0, 111, 111);

		Canvas.SetPos(Canvas.ClipX-271*Scale,160*Scale);
		Canvas.DrawTile(ScopeTexture, 111*Scale, 111*Scale , 111 , 0, -111, 111);

		Canvas.SetPos(160*Scale,Canvas.ClipY-271*Scale);
		Canvas.DrawTile(ScopeTexture, 111*Scale, 111*Scale, 0 , 111, 111, -111);

		Canvas.SetPos(Canvas.ClipX-271*Scale,Canvas.ClipY-271*Scale);
		Canvas.DrawTile(ScopeTexture, 111*Scale, 111*Scale , 111 , 111, -111, -111);
		
				
		// Draw the 4 corners
		
		ScopeTexture = texture'COGAssaultRifleTex.COGAssaultZoomedBorder1';

		Canvas.SetPos(0,0);
		Canvas.DrawTile(ScopeTexture,160*Scale,160*Scale, 0, 160, 160, -160);
		
		Canvas.SetPos(Canvas.ClipX-160*Scale,0);
		Canvas.DrawTile(ScopeTexture,160*Scale,160*Scale, 160,160, -160, -160);

		Canvas.SetPos(0,Canvas.ClipY-160*Scale);
		Canvas.DrawTile(ScopeTexture,160*Scale,160*Scale, 0,0, 160, 160);
				
		Canvas.SetPos(Canvas.ClipX-160*Scale,Canvas.ClipY-160*Scale);
		Canvas.DrawTile(ScopeTexture,160*Scale,160*Scale, 160, 0, -160, 160);
		
		
		// Draw the Horz Borders
		
		ScopeTexture = texture'COGAssaultRifleTex.COGAssaultZoomedBorder3';
		
		Canvas.SetPos(160*Scale,0);
		Canvas.DrawTile(ScopeTexture, Canvas.ClipX-320*Scale, 160*Scale, 0, 160, 64, -160);
			
		Canvas.SetPos(160*Scale,Canvas.ClipY-160*Scale);
		Canvas.DrawTile(ScopeTexture, Canvas.ClipX-320*Scale, 160*Scale, 0, 0, 64, 160);

		// Draw the Vert Borders
		
		ScopeTexture = texture'COGAssaultRifleTex.COGAssaultZoomedBorder2';

		Canvas.SetPos(0,160*Scale);
		Canvas.DrawTile(ScopeTexture, 160*Scale, Canvas.ClipY-320*Scale, 0,0, 160,64);
				
		Canvas.SetPos(Canvas.ClipX-160*Scale,160*Scale);
		Canvas.DrawTile(ScopeTexture, 160*Scale, Canvas.ClipY-320*Scale, 160,0, -160,64);
	}
}

// Bascially, this is the original DrawWeapon with some minor adjusts to handle the full auto

simulated function DrawWeapon(canvas Canvas)
{
	local rotator NewRot;
	local bool bPlayerOwner;
	local int Hand;
	local  PlayerController PlayerOwner;
	local float ScaledFlash;
	
	DrawCrosshair(Canvas);

	if ( Instigator == None )
		return;

	PlayerOwner = PlayerController(Instigator.Controller);

	if ( PlayerOwner != None )
	{
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;
		if (  Hand == 2 )
			return;
	}

	
	if ( bMuzzleFlash && bDrawMuzzleFlash && (MFTexture != None) )
	{
		if ( !bSetFlashTime )
		{
			bSetFlashTime = true;
			FlashTime = Level.TimeSeconds + FlashLength;
		}
		else if ( FlashTime < Level.TimeSeconds )
			bMuzzleFlash = false;
		if ( bMuzzleFlash )
		{
			ScaledFlash = 0.5 * MuzzleFlashSize * MuzzleScale * Canvas.ClipX/640.0;
			Canvas.SetPos(0.5*Canvas.ClipX - ScaledFlash + Canvas.ClipX * Hand * FlashOffsetX, 0.5*Canvas.ClipY - ScaledFlash + Canvas.ClipY * FlashOffsetY);
			DrawMuzzleFlash(Canvas);
		}
	}
	else
		bSetFlashTime = false;

	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self));
	NewRot = Instigator.GetViewRotation();

	if ( Hand == 0 )
		newRot.Roll = 2 * Default.Rotation.Roll;
		
	else
		newRot.Roll = Default.Rotation.Roll * Hand;

	setRotation(newRot);
	Canvas.DrawActor(self, false, false, DisplayFOV);
}

simulated function bool IsZoomed()
{
	return bZoomed;
}

function ServerSetClip(ammunition NewClip, byte NewMode)
{

	// Play Sound Effect/Animation here
	if (NewClip!=None)
	{
		AmmoType = NewClip;
		if ( AssaultRifleAmmo(AmmoType) != None )
			AssaultRifleAmmo(AmmoType).ReloadCount = ReloadCount;
			
		if ( Instigator.IsHumanControlled() )
			PlaySound(sound 'WeaponSounds.AssaultRifle.COGassault_clickgrenade',SLOT_MISC,1.0);			

		FiringMode = NewMode;
		if ( ThirdPersonActor != None )
		{
			if ( FiringMode == MODE_Grenade )
				WeaponAttachment(ThirdPersonActor).FiringMode = 'MODE_Grenade';
			else if (FiringMode == MODE_Auto)
				WeaponAttachment(ThirdPersonActor).FiringMode = 'MODE_Auto';
			else
				WeaponAttachment(ThirdPersonActor).FiringMode = 'MODE_Normal';
		}
		
	}
}

simulated function bool HasAmmo()
{
	if ( AmmoType.HasAmmo() || Clips[0].HasAmmo() || Clips[1].HasAmmo() || (GrenadeAmmo != None && GrenadeAmmo.HasAmmo()) )
		return true;
				
	return false;
}

/* NeedsToReload()
Change to next ammotype if no ammo
*/
simulated function bool NeedsToReload()
{

	if ( bForceReload )
		return true;

	if ( FiringMode == MODE_Grenade )
		return !bGrenadeLoaded;

	return ( ReloadCount == 0 );
}

simulated function SetupMuzzleFlash()
{
	IncrementFlashCount();
	bMuzzleFlash = true;
	bSetFlashTime = false;
	FlashOffsetY = Default.FlashOffsetY - VerticalError * 0.05;
	FlashOffsetX = Default.FlashOffsetX * (0.975 + 0.05 * FRand());
}
	
simulated function PlayFiring()
{
	local name FireAnim;
	local float AnimRate;
	local sound FireSound;
	
	if ( FiringMode != MODE_Grenade && HasSilencer() )
		FireSound = sound'WeaponSounds.COGassault_silencesingle';
	else
	{
		FireSound = AmmoType.FireSound;
	}

	PlayOwnedSound(FireSound, SLOT_None, 1.0); 

	Switch(FiringMode)
	{
		case MODE_Single:
			VerticalError = 0;
			AnimRate = 0.3;
			TraceAccuracy = 0;
			FireAnim = SingleFires[Rand(3)];
			SetupMuzzleFlash();
			break;
		
		case MODE_Burst:
		case MODE_Auto:
			VerticalError = 0;
			AnimRate = 6.0;
			if ( (LastFireTime==0) || (Level.TimeSeconds-LastFireTime >0.5 ) )
				TraceAccuracy =  0;
			else
				TraceAccuracy += 0.075;

			if (TraceAccuracy>3)
				TraceAccuracy = 3;				

			LastFireTime = Level.TimeSeconds;				
				
			FireAnim = SingleFires[Rand(3)];
			SetupMuzzleFlash();
			break;

		case MODE_Grenade:
			FireAnim = 'ShootGrenade';
			AnimRate = 1.0;;
			bGrenadeLoaded = false;
			IncrementFlashCount();
			break;
	}
	PlayAnim(FireAnim,AnimRate * (0.5 + 0.5 * FireAdjust), 0.1);
	LastCleanTime = Level.TimeSeconds;

}

simulated function PlayIdleAnim()
{
	if ( Instigator == None )
		return;
/*		
	if ( !bZoomed && (FRand() < 0.01) && HasScope()
		&& (Instigator.Acceleration == vect(0,0,0))
		&& (Level.TimeSeconds - LastCleanTime > 20) )
	{
		LastCleanTime = Level.TimeSeconds;
		PlayAnim('wipelense',1.0,0.3);
		PlayOwnedSound(LensSound);
	}
	else
*/	
		TweenAnim('shoot1', 0.3);
}

simulated function PlaySelect()
{
	Super.PlaySelect();
	LastCleanTime = Level.TimeSeconds;
}

simulated function PlayReloading()
{
	local name LoadAnim;
	local float AnimSpeed;

	if (AmmoType==Clips[1])
	{
		LoadAnim = 'ReloadClip2';
		PlayOwnedSound(ReloadSound);
		AnimSpeed = 1.25;
	}
	else if (AmmoType==GrenadeAmmo)
	{
		LoadAnim = 'ReloadGrenade';
		PlayOwnedSound(ReloadGrenadeSound);
		AnimSpeed = 1.75; 
	}	
	else
	{
		LoadAnim = 'ReloadClip1';
		PlayOwnedSound(ReloadSound);
		AnimSpeed = 1.25;
	}
	PlayAnim(LoadAnim,AnimSpeed, 0.05);
}

simulated function NextWeaponFunction()
{
	if (!bZoomed)
		Super.NextWeaponFunction();
}

function ServerNextWeaponFunction()
{

	if (FiringMode==MODE_Grenade)
		return;

	if ( FiringMode==AssaultRifleAmmo(AmmoType).LastFireMode() )
		ServerSetClip(OtherClip(),OtherClip().FirstFireMode() );
	else
		ServerSetClip(None,FiringMode+1);
}

simulated function PrevWeaponFunction()
{
	if (!bZoomed) 
		Super.PrevWeaponFunction();
}

function ServerPrevWeaponFunction()
{
    if (FiringMode==MODE_Grenade)
		return;
	
	if ( FiringMode==AssaultRifleAmmo(AmmoType).FirstFireMode() )
		ServerSetClip(OtherClip(),OtherClip().LastFireMode() );
	else
		ServerSetClip(None,FiringMode-1);
}

function Finish()
{
	if ( (FiringMode==MODE_Grenade) && !Instigator.IsHumanControlled() )
	{
		ServerSetClip(OldAmmo, OldMode);
		GotoState('Idle');
		return;
	}
	Super.Finish();
}
	
function SwitchToWeaponWithAmmo()
{
	if (OtherClip().HasAmmo())
	{
		log("#### otherClip: "$OtherClip()$" OtherClip.FirstFiringMode: "$OtherClip().FirstFireMode());
		ServerSetClip(OtherClip(),OtherClip().FirstFireMode());
		GotoState('Reloading');
		return;
	}

	// if local player, switch weapon
	Instigator.Controller.SwitchToBestWeapon();
	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}
	else
		GotoState('Idle');
}
	
simulated function ClientFinish()
{

	if ( (Instigator == None) || (Instigator.Controller == None) )
	{
		GotoState('');
		return;
	}
	if ( NeedsToReload() && AmmoType.HasAmmo() )
	{
		GotoState('Reloading');
		return;
	}

	if (FiringMode==MODE_Grenade)
	{
		FiringMode=OldMode;
		AmmoType=OldAmmo;
	}
	
	if ( !AmmoType.HasAmmo() )
	{
	
	
		if ( OtherClip().HasAmmo() )
		{
			ServerSetClip(OtherClip(),OtherClip().FirstFireMode());
			GotoState('Reloading');
			return;
		}
	
		Instigator.Controller.SwitchToBestWeapon();
		if ( !bChangeWeapon )
		{
			PlayIdleAnim();
			GotoState('Idle');
			return;
		}
	}
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( Instigator.PressingFire() )
		Global.Fire(0);
	else
	{
		if ( Instigator.PressingAltFire() )
			Global.AltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('Idle');
		}
	}
}

state Idle
{
	simulated function AltFire( float Value )
	{

		ServerAltFire();

		// Hack for clients
	
		if ( HasGrenadeLauncher() && GrenadeAmmo.HasAmmo() )
		{
			if ( Role<ROLE_Authority )	// Clients do this
			{
				
			
				OldMode = FiringMode;
				OldAmmo = AmmoType;
				FiringMode = MODE_Grenade;
				AmmoType = GrenadeAmmo;
				LocalFire();
				GotoState('ClientFiring');
			}
			return;
		}

		if ( HasScope() )
			GotoState('Zooming');
	}

	function ServerAltFire()
	{
	
		local WarfarePlayer P;
	
		if ( HasGrenadeLauncher() )
		{
		
			if ( !GrenadeAmmo.HasAmmo() )
			{
				PlaySound(sound 'WeaponSounds.AssaultRifle.COGassault_clickgrenade',SLOT_MISC,1.0);
				return;
			}			
		
			if (AmmoType == GrenadeAmmo)
			{
				log("Alt-Fire call with Ammo=Grenade.. should never happen");
				return;
			}
			else
			{
				OldAmmo = AmmoType;
				OldMode = FiringMode;
				ServerSetClip(GrenadeAmmo,MODE_Grenade);
				
				
				P = WarfarePlayer(Instigator.Controller);
					
				ProjectileFire();
				LocalFire();

				if ( AmmoType.HasAmmo() )
					GotoState('Reloading');
				else
					ServerSetClip(OldAmmo,OldMode);
				
				return;
			}
		}
				
		else if ( HasScope() )
		{
			GotoState('Zooming');
		}
	}
	
}
	
state Zooming
{
	simulated function Fire( float Value );
	simulated function AltFire( float Value );
	simulated function ForceReload();
	simulated function NextWeaponFunction();
	simulated function PrevWeaponFunction(); 

	simulated function bool IsZoomed()
	{
		return false;
	}

	simulated function bool PutDown()
	{
		bChangeWeapon = true;
		return True;
	}

	simulated function AnimEnd(int Channel)
	{
		// switch to close up FOV
		if ( bZoomed )
		{
			PlayerController(Instigator.Controller).SetFOV(25);
			PlayerController(Instigator.Controller).ClientAdjustGlow(0.5,vect(0,255,0));
		}
		
		if ( Role == ROLE_Authority )
			Finish();
		else
			ClientFinish();
	}

	simulated function BeginState()
	{
		if ( bZoomed )
		{
			PlayerController(Instigator.Controller).ClientAdjustGlow(0,vect(0,0,0));
			PlayAnim('scopedown2');
			PlayOwnedSound(sound'WeaponSounds.COGassault_scopezoomout');
			bZoomed = false;
			PlayerController(Instigator.Controller).ResetFOV();
			AttachmentCOGAssaultRifle(ThirdPersonActor).bSnipe = false;
		}
		else
		{
			PlayAnim('scopeup2');	
			PlayOwnedSound(sound'WeaponSounds.COGassault_scopezoomin');
			bZoomed = true;
			AttachmentCOGAssaultRifle(ThirdPersonActor).bSnipe = false;
		}
	}
}

state Reloading
{
	simulated function Fire( float Value );
	simulated function AltFire( float Value );
	simulated function ForceReload();
	simulated function NextWeaponFunction();
	simulated function PrevWeaponFunction(); 

	simulated function ClientFinish()
	{
		if (FiringMode==MODE_Grenade)
		{
			bGrenadeLoaded = true;
			FiringMode = OldMode;
			AmmoType = OldAmmo;
		}
		
		Global.ClientFinish();
	}

	function Finish()
	{
		if (FiringMode==MODE_Grenade)
		{	
			bGrenadeLoaded = true;
			ServerSetClip(OldAmmo,OldMode);
		}

		Global.Finish();
	}
	
	simulated function AnimEnd(int Channel)
	{
		ReloadCount = Default.ReloadCount;
		if ( Role < ROLE_Authority )
			ClientFinish();
		else
			Finish();
	}
	
	simulated function BeginState()
	{
		Super.BeginState();

		if ( bZoomed )
		{
			PlayerController(Instigator.Controller).ClientAdjustGlow(0,vect(0,0,0));
			bZoomed = false;
			PlayerController(Instigator.Controller).ResetFOV();
		}
	}


}

State DownWeapon
{
	simulated function BeginState()
	{
		Super.BeginState();
		bZoomed = false;
		if ( PlayerController(Instigator.Controller) != None )
			PlayerController(Instigator.Controller).ResetFOV();
	}
}

state NormalFire
{
	function EndState()
	{
		Super.EndState();

		if ( Instigator != None )
			Instigator.StopPlayFiring();
		FireCount = 0;
	}
}

state ClientFiring
{
	simulated function EndState()
	{
		Super.EndState();
		FireCount = 0;
		if ( Instigator != None )
			Instigator.StopPlayFiring();
	}
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas, YL, YPOS);
	
	Canvas.SetDrawColor(0,255,0);
	Canvas.SetDrawColor(0,255,0);
	Canvas.DrawText("Clip0="$Clips[0]$" Clip1="$Clips[1]$" CurrentClip: "$AmmoType);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("     Fire Mode:" $FiringMode);
	YPos += YL;
}	




/*
* Animation sequence load    0  Tracktime: 31.000000 rate: 30.000000 
	  First raw frame  0  total raw frames 31  group: [None]

 * Animation sequence Shoot1    1  Tracktime: 6.000000 rate: 30.000000 
	  First raw frame  31  total raw frames 6  group: [None]

 * Animation sequence Shoot2    2  Tracktime: 6.000000 rate: 30.000000 
	  First raw frame  37  total raw frames 6  group: [None]

 * Animation sequence Shoot3    3  Tracktime: 6.000000 rate: 30.000000 
	  First raw frame  43  total raw frames 6  group: [None]

 * Animation sequence BurstUp    4  Tracktime: 16.000000 rate: 30.000000 
	  First raw frame  49  total raw frames 16  group: [None]

 * Animation sequence BurstDown    5  Tracktime: 15.000000 rate: 30.000000 
	  First raw frame  65  total raw frames 15  group: [None]

 * Animation sequence ReloadClip1    6  Tracktime: 81.000000 rate: 30.000000 
	  First raw frame  80  total raw frames 81  group: [None]

 * Animation sequence ReloadClip2    7  Tracktime: 81.000000 rate: 30.000000 
	  First raw frame  161  total raw frames 81  group: [None]

 * Animation sequence ShootGrenade    8  Tracktime: 17.000000 rate: 30.000000 
	  First raw frame  242  total raw frames 17  group: [None]

 * Animation sequence ReloadGrenade    9  Tracktime: 109.000000 rate: 30.000000 
	  First raw frame  259  total raw frames 109  group: [None]

 * Animation sequence WipeLense   10  Tracktime: 166.000000 rate: 30.000000 
	  First raw frame  368  total raw frames 166  group: [None]

 * Animation sequence ScopeUp   11  Tracktime: 21.000000 rate: 30.000000 
	  First raw frame  534  total raw frames 21  group: [None]

 * Animation sequence ScopeDown   12  Tracktime: 21.000000 rate: 30.000000 
	  First raw frame  555  total raw frames 21  group: [None]

 * Animation sequence Holster   13  Tracktime: 31.000000 rate: 30.000000 
	  First raw frame  576  total raw frames 31  group: [None]

 * Animation sequence ScopeUp2   14  Tracktime: 36.000000 rate: 30.000000 
	  First raw frame  607  total raw frames 36  group: [None]

 * Animation sequence ScopeDown2   15  Tracktime: 36.000000 rate: 30.000000 
	  First raw frame  643  total raw frames 36  group: [None]

 * Animation sequence ShootGrenadeLast   16  Tracktime: 21.000000 rate: 30.000000 
	  First raw frame  679  total raw frames 21  group: [None]

*/
defaultproperties
{
	FiringModeStr[0]="Single"
	FiringModeStr[1]="Burst"
	FiringModeStr[2]="Auto"
	FiringModeStr[3]="Grenade"
	bGrenadeLoaded=true
	LoadOut=1
	ClipTypes[0]=Class'AssaultRifleAmmo'
	ClipTypes[1]=Class'AssaultRifleAmmo_Exploding'
	ClipPickupAmounts[0]=199
	ClipPickupAmounts[1]=199
	GrenadeType=Class'TossedGrenadeAmmunition'
	GrenadePickupAmount=12
	SingleFires[0]=Shoot1
	SingleFires[1]=shoot2
	SingleFires[2]=shoot3
	ReloadGrenadeSound=Sound'WeaponSounds.AssaultRifle.COGassault_reloadgrenade'
	LensSound=Sound'WeaponSounds.AssaultRifle.COGassault_wipelense'
	SilencedMuzzleFlash=Texture'MuzzleFlashes.AssMuzz2'
	TracerOffset=(X=60,Y=20,Z=55)
	HolsterSound=Sound'WeaponSounds.AssaultRifle.COGassault_holster'
	ReloadSound=Sound'WeaponSounds.AssaultRifle.COGassault_reloadclip1'
	PickupAmmoCount=199
	ReloadCount=50
	AutoSwitchPriority=7
	FireOffset=(X=20,Y=4,Z=-5)
	ShakeMag=350
	shaketime=1.2
	ShakeVert=(X=0,Y=0,Z=6)
	TraceAccuracy=0.4
	bSniping=true
	AIRating=0.7
	FireSound=Sound'WeaponSounds.AssaultRifle.COGassault_shoot'
	SelectSound=Sound'WeaponSounds.AssaultRifle.COGassault_load'
	DisplayFOV=50
	FlashOffsetY=0.13
	FlashOffsetX=0.17
	MuzzleFlashSize=256
	MFTexture=Texture'MuzzleFlashes.AssMuzz2'
	bDrawMuzzleFlash=true
	InventoryGroup=2
	PickupClass=Class'PickupCOGAssaultRifle'
	PlayerViewOffset=(X=16.5,Y=4.5,Z=-4)
	BobDamping=0.975
	AttachmentClass=Class'AttachmentCOGAssaultRifle'
	ItemName="COG Assault Rifle"
	Mesh=SkeletalMesh'CogAssaultRifleMesh'
	DrawScale=0.03
}