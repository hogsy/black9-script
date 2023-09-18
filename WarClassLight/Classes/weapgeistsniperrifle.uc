//=============================================================================
// SniperRifle
// A military redesign of the rifle.
//=============================================================================
class WeapGeistSniperRifle extends WarfareWeapon;

#exec MESH  MODELIMPORT MESH=GeistRifle MODELFILE=..\WarClassContent\Models\geistsniper.PSK LODSTYLE=0
#exec MESH  ORIGIN MESH=GeistRifle X=0 Y=0 Z=64 YAW=128 PITCH=00 ROLL=00
#exec ANIM  IMPORT ANIM=GeistRifleAnims ANIMFILE=..\WarClassContent\Models\geistsniper.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP SCALE MESHMAP=GeistRifle X=.012 Y=.012 Z=.012
#exec MESH  DEFAULTANIM MESH=GeistRifle ANIM=GeistRifleAnims

#exec ANIM SEQUENCE ANIM=GeistRifleAnims SEQ=load GROUP=Select

#exec ANIM DIGEST ANIM=GeistRifleAnims USERAWINFO VERBOSE

#exec TEXTURE IMPORT NAME=Rifle2a FILE=..\WarClassContent\MODELS\SG_Geist_Sniper.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=GeistRifle NUM=0 TEXTURE=Rifle2a

#exec TEXTURE IMPORT NAME=JRifle2 FILE=..\WarClassContent\MODELS\Rifle.pcx GROUP=Skins LODSET=2
#exec MESH IMPORT MESH=RifleHand ANIVFILE=..\WarClassContent\MODELS\Riflehand_a.3D DATAFILE=..\WarClassContent\MODELS\Riflehand_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=RifleHand X=15 Y=170 Z=-30 YAW=64 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=RifleHand SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=RifleHand X=0.14 Y=0.14 Z=0.28
#exec MESHMAP SETTEXTURE MESHMAP=RifleHand NUM=2 TEXTURE=JRifle2

#exec TEXTURE IMPORT NAME=MuzzleFlash2 FILE=..\botpack\TEXTURES\NewMuz2.PCX GROUP="Rifle" MIPS=OFF LODSET=2

#exec AUDIO IMPORT FILE="..\botpack\Sounds\SniperRifle\SniperFire.wav" NAME="SniperFire" GROUP="SniperRifle"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\sniperrifle\RPICKUP1.WAV" NAME="RiflePickup" GROUP="Rifle"

#exec MESH IMPORT MESH=muzzsr3 ANIVFILE=..\WarClassContent\MODELS\muzzle2_a.3d DATAFILE=..\WarClassContent\MODELS\Muzzle2_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=muzzsr3 MINVERTS=8 STRENGTH=0.7 ZDISP=800.0
#exec MESH ORIGIN MESH=muzzsr3 X=0 Y=980 Z=-75 YAW=64
#exec MESH SEQUENCE MESH=muzzsr3 SEQ=All                      STARTFRAME=0 NUMFRAMES=3
#exec MESH SEQUENCE MESH=muzzsr3 SEQ=Shoot                   STARTFRAME=0 NUMFRAMES=3
#exec MESHMAP NEW   MESHMAP=muzzsr3 MESH=muzzsr3
#exec MESHMAP SCALE MESHMAP=muzzsr3 X=0.04 Y=0.1 Z=0.08
#exec TEXTURE IMPORT NAME=Muzzy3 FILE=..\WarClassContent\MODELS\Muzzy3.PCX GROUP=Skins

/*

 * Animation sequence load    0  Tracktime: 41.000000 rate: 30.000000 
	  First raw frame  0  total raw frames 41  group: [None]

 * Animation sequence shoot    1  Tracktime: 26.000000 rate: 30.000000 
	  First raw frame  41  total raw frames 26  group: [None]

 * Animation sequence reload    2  Tracktime: 79.000000 rate: 30.000000 
	  First raw frame  67  total raw frames 79  group: [None]

 * Animation sequence holster    3  Tracktime: 16.000000 rate: 30.000000 
	  First raw frame  146  total raw frames 16  group: [None]
*/

#exec OBJ LOAD FILE=..\textures\CogAssaultRifleTex.utx PACKAGE=CogAssaultRifleTex


var int NumFire;
var vector OwnerLocation;
var float StillTime, StillStart;
var bool bZoomed;
var float LastFOV;

simulated function DrawCrossHair( canvas Canvas)
{
	local PlayerController P;

	P = PlayerController(Pawn(Owner).Controller);
	if ( (P == None) || (!bZoomed) ) 
		Super.DrawCrossHair(Canvas);
}

function float GetAIRating()
{
	local float dist;

	if ( !HasAmmo() )
		CurrentRating = -2;
	else if ( Bot(Instigator.Controller) == None )
		CurrentRating = AIRating;
	if ( Bot(Instigator.Controller).IsSniping() )
		CurrentRating = AIRating + 1.15;
	if (  AIController(Instigator.Controller).Enemy != None )
	{
		dist = VSize(AIController(Instigator.Controller).Enemy.Location - Owner.Location);
		if ( dist > 1200 )
		{
			if ( dist > 2000 )
				CurrentRating = AIRating + 0.75;
			else
				CurrentRating = AIRating + FMin(0.0001 * dist, 0.45); 
		}
	}
	return CurrentRating;
}

simulated function PlayFiring()
{
	PlayOwnedSound(FireSound, SLOT_None, 3.0);
	PlayAnim('shoot',0.5 + 0.5 * FireAdjust, 0.05);
	IncrementFlashCount();

	if ( (PlayerController(Instigator.Controller) != None) 
		&& (PlayerController(Instigator.Controller).DesiredFOV == PlayerController(Instigator.Controller).DefaultFOV) )
		bMuzzleFlash = true;
}

simulated function Zoom()
{
	GotoState('Zooming');
}

simulated function AltFire( float Value )
{
	GotoState('Zooming');
}

///////////////////////////////////////////////////////

function Timer()
{
	local actor targ;
	local float bestAim, bestDist;
	local vector FireDir;

	bestAim = 0.95;
	if ( (Instigator == None) || (Instigator.Controller == None) )
	{
		GotoState('');
		return;
	}
	if ( VSize(Instigator.Location - OwnerLocation) < 6 )
		StillTime += FMin(2.0, Level.TimeSeconds - StillStart);

	else
		StillTime = 0;
	StillStart = Level.TimeSeconds;
	OwnerLocation = Instigator.Location;
	FireDir = vector(Instigator.GetViewRotation());
	targ = Instigator.Controller.PickTarget(bestAim, bestDist, FireDir, Instigator.Location,10000);
	if ( Pawn(targ) != None )
	{
		SetTimer(1 + 4 * FRand(), false);
		bPointing = true;
		Pawn(targ).Controller.ReceiveWarning(Instigator, 200, FireDir);
	}
	else 
	{
		SetTimer(0.4 + 1.6 * FRand(), false);
		if ( !Instigator.PressingFire() && !Instigator.PressingAltFire() )
			bPointing = false;
	}
}	

function Finish()
{
	if ( Instigator.PressingFire() && (FRand() < 0.6) )
		Timer();
	Super.Finish();
}

function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = Instigator.Location + Instigator.EyePosition(); 
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);	
	X = vector(AdjustedAim);
	EndTrace = StartTrace + TraceDist * X; 
	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	AmmoType.ProcessTraceHit(self, Other, HitLocation, HitNormal, X,Y,Z);
}

simulated event RenderOverlays( canvas Canvas )
{
	local  PlayerController P;
	local float Scale;
	local texture ScopeTexture;
	local float CX,CY;

	if ( Instigator == None )
		return;

	P = PlayerController(Pawn(Owner).Controller);
	
	if ( (P != None) && (bZoomed) ) 
	{
		Scale = Canvas.ClipX / 1024;
	
		CX = Canvas.ClipX/2;
		CY = Canvas.ClipY/2;
			
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.SetDrawColor(128,0,0);
		ScopeTexture = texture'COGAssaultRifleTex.COGAssaultZoomedCrosshair';
		
		// Draw the crosshair
		
		Canvas.SetPos(CX-169*Scale,CY-155*Scale);
		Canvas.DrawTile(ScopeTexture,169*Scale,310*Scale, 164,35, 169,310);
		Canvas.SetPos(CX,CY-155*Scale);
		Canvas.DrawTile(ScopeTexture,169*Scale,310*Scale, 332,345, -169,-310);
	
		// Draw Cornerbars

		Canvas.SetDrawColor(255,0,0);
	
		Canvas.SetPos(160*Scale,160*Scale);
		Canvas.DrawTile(ScopeTexture, 111*Scale, 111*Scale , 0 , 0, 111, 111);
	
		Canvas.SetPos(Canvas.ClipX-271*Scale,160*Scale);
		Canvas.DrawTile(ScopeTexture, 111*Scale, 111*Scale , 111 , 0, -111, 111);
	
		Canvas.SetPos(160*Scale,Canvas.ClipY-271*Scale);
		Canvas.DrawTile(ScopeTexture, 111*Scale, 111*Scale, 0 , 111, 111, -111);

		Canvas.SetPos(Canvas.ClipX-271*Scale,Canvas.ClipY-271*Scale);
		Canvas.DrawTile(ScopeTexture, 111*Scale, 111*Scale , 111 , 111, -111, -111);
	
			
		// Draw the 4 corners

		Canvas.SetDrawColor(128,0,0);
	
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
	else
		Super.RenderOverlays(Canvas);
		
}

simulated function NextWeaponFunction()
{
	local PlayerController PC;
	local float FOV;
	
	PC = PlayerController(Pawn(Owner).Controller);
	
	if (PC==None)
		return;

	if (bZoomed)
	{
		FOV = PC.FOVAngle-10;
		if (FOV<20)
		{
			FOV=20;
		}
		
		PC.SetFOV(FOV);
	}
	else
	  Super.NextWeaponFunction();
	
}	
	
simulated function PrevWeaponFunction()
{
	local PlayerController PC;
	local float FOV;
	
	PC = PlayerController(Pawn(Owner).Controller);
	
	if (PC==None)
		return;

	if (bZoomed)
	{
		FOV = PC.FOVAngle+10;
		if (FOV>80)
		{
			FOV=80;
		}
		
		PC.SetFOV(FOV);
	}
	else
	  Super.PrevWeaponFunction();
	
}	
	
state Idle
{
	simulated function ServerFire()
	{
		if ( Bot(Instigator.Controller) != None )
		{
			// simulate bot using zoom
			if ( Bot(Instigator.Controller).IsSniping() && (FRand() < 0.65) )
				AimError = AimError/FClamp(StillTime, 1.0, 8.0);
			else if ( VSize(Owner.Location - OwnerLocation) < 6 )
				AimError = AimError/FClamp(0.5 * StillTime, 1.0, 3.0);
			else
				StillTime = 0;
		}
		Super.ServerFire();
	}


	function BeginState()
	{
		bPointing = false;
		SetTimer(0.4 + 1.6 * FRand(), false);
		Super.BeginState();
	}

	function EndState()
	{	
		SetTimer(0.0, false);
		Super.EndState();
	}
	
Begin:
	bPointing=False;
	if ( Instigator.PressingFire() ) Fire(0.0);
	Disable('AnimEnd');
	PlayIdleAnim();
}

///////////////////////////////////////////////////////
state Zooming
{

	simulated function Fire( float Value );
	simulated function AltFire( float Value );
	simulated function ForceReload();
	simulated function NextWeaponFunction();
	simulated function PrevWeaponFunction(); 

	// Dummy state right now.. needs animation.  For now we just exit

	simulated function BeginState()
	{
		local PlayerController PC;
		PC = PlayerController(Instigator.Controller);
		
		if ( PC!= None)
		{
			if (!bZoomed)
			{
				if (LastFOV>0)
					PC.SetFOV(LastFOV);
				else
					PC.SetFOV(50);
	
				bZoomed = true;
			}
			else
			{
				LastFOV = PC.FOVAngle;
				PC.SetFOV(PC.DefaultFOV);
				bZoomed = false;
			}
			GotoState('Idle');
		}
		else
		{
			log("BOT SHOULD NEVER ALTFIRE SNIPERRIFLE!!!");
			Instigator.Controller.bFire = 1;
			Global.Fire(0);
		}
	}
}

defaultproperties
{
	AmmoName=Class'BulletAmmo'
	PickupAmmoCount=24
	AutoSwitchPriority=3
	FireOffset=(X=0,Y=5,Z=-2)
	ShakeMag=400
	shaketime=0.15
	ShakeVert=(X=0,Y=0,Z=8)
	bSniping=true
	AIRating=0.75
	TraceDist=15000
	FireSound=Sound'sniperrifle.SniperFire'
	SelectSound=Sound'Rifle.RiflePickup'
	WeaponDescription="Classification: Long Range Ballistic\\n\\nRegular Fire: Fires a high powered bullet. Can kill instantly when applied to the cranium of opposing forces. \\n\\nSecondary Fire: Zooms the rifle in, up to eight times normal vision. Allows for extreme precision from hundreds of yards away.\\n\\nTechniques: Great for long distance headshots!"
	NameColor=(B=255,G=0,R=0,A=255)
	DisplayFOV=30
	FlashOffsetY=0.11
	FlashOffsetX=0.07
	FlashLength=0.013
	MuzzleFlashSize=256
	MFTexture=Texture'Rifle.MuzzleFlash2'
	bDrawMuzzleFlash=true
	bMuzzleFlashParticles=true
	MuzzleFlashMesh=VertMesh'muzzsr3'
	MuzzleFlashScale=0.1
	MuzzleFlashStyle=3
	MuzzleFlashTexture=Texture'Skins.Muzzy3'
	InventoryGroup=10
	PickupClass=Class'pickupgeistsniperrifle'
	PlayerViewOffset=(X=24,Y=5.5,Z=-4.3)
	BobDamping=0.975
	AttachmentClass=Class'AttachmentGeistSniperRifle'
	ItemName="Sniper Rifle"
	Mesh=SkeletalMesh'GeistRifle'
	DrawScale=0.55
	Skins=/* Array type was not detected. */
}