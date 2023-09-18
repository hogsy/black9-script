//===============================================================================
//  COG light plasma gun
//===============================================================================

class WeapCOGlightplasma extends WarfareWeapon;
#exec MESH  MODELIMPORT MESH=coglightplasmaMesh MODELFILE=..\WarClassContent\Models\coglightplasma.PSK LODSTYLE=0
#exec MESH  ORIGIN MESH=coglightplasmaMesh X=0 Y=0 Z=64 YAW=128 PITCH=00 ROLL=00
#exec ANIM  IMPORT ANIM=coglightplasmaAnims ANIMFILE=..\WarClassContent\Models\coglightplasma.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP SCALE MESHMAP=coglightplasmaMesh X=.06 Y=.06 Z=.06
#exec MESH  DEFAULTANIM MESH=coglightplasmaMesh ANIM=coglightplasmaAnims

#exec ANIM SEQUENCE ANIM=coglightplasmaAnims SEQ=load GROUP=Select

#exec ANIM DIGEST ANIM=coglightplasmaAnims USERAWINFO VERBOSE

#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pulsegun\PulseBolt.WAV" NAME="PulseBolt" GROUP="PulseGun"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pulsegun\PulseFire.WAV" NAME="PulseFire" GROUP="PulseGun"

#EXEC TEXTURE IMPORT NAME=cf-coglightplasmaTex0 FILE=..\warclasscontent\textures\pulseskin.bmp GROUP=Skins

#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax

/*
 * Animation sequence load    0  Tracktime: 44.000000 rate: 30.000000 
	  First raw frame  0  total raw frames 44  group: [None]

 * Animation sequence shoot1    1  Tracktime: 29.000000 rate: 30.000000 
	  First raw frame  44  total raw frames 29  group: [None]

 * Animation sequence shoot2    2  Tracktime: 31.000000 rate: 30.000000 
	  First raw frame  73  total raw frames 31  group: [None]

 * Animation sequence shoot3    3  Tracktime: 31.000000 rate: 30.000000 
	  First raw frame  104  total raw frames 31  group: [None]

 * Animation sequence reload    4  Tracktime: 89.000000 rate: 30.000000 
	  First raw frame  135  total raw frames 89  group: [None]

 * Animation sequence holster    5  Tracktime: 16.000000 rate: 30.000000 
	  First raw frame  224  total raw frames 16  group: [None]


*/

// 3rd person view
#exec MESH  MODELIMPORT MESH=coglightplasma3rd MODELFILE=..\WarClassContent\Models\gun.PSK LODSTYLE=0
#exec MESH  ORIGIN MESH=coglightplasma3rd X=0 Y=0 Z=64 YAW=128 PITCH=00 ROLL=00
#exec MESHMAP SCALE MESHMAP=coglightplasma3rd X=.6 Y=.6 Z=.6
//#exec MESHMAP SETTEXTURE MESHMAP=coglightplasma3rd NUM=0 TEXTURE=CogSoldiers.temp_rifle

var float Angle, Count;
var() sound DownSound;

///////////////////////////////////////////////////////
state NormalFire
{
	ignores AnimEnd;

	function ProjectileFire()
	{
		local Vector Start, X,Y,Z;
		Owner.MakeNoise(1.0);
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		Start = GetFireStart(X,Y,Z); 
		AdjustedAim = Instigator.AdjustAim(AmmoType, Start, AimError);	
		Start = Start - Sin(Angle)*Y*4 + (Cos(Angle)*4 - 10.78)*Z;
		Angle += 1.8;
		AmmoType.SpawnProjectile(Start,AdjustedAim);	
	}

	function Tick( float DeltaTime )
	{
		if (Owner==None) 
			GotoState('');
	}

	function BeginState()
	{
		Super.BeginState();
		Angle = 0;
		AmbientGlow = 200;
		Instigator.bSteadyFiring = true;
	}

	function EndState()
	{
		AmbientSound = None;
		AmbientGlow = 0;	
		TweenAnim('Shoot1', 0.2);
		if ( Instigator != None )
			Instigator.StopPlayFiring();
		Super.EndState();
	}

Begin:
	Sleep(0.18);
	Finish();
}

state ClientFiring
{
	simulated function Tick( float DeltaTime )
	{
		if ( (Instigator != None) && Instigator.PressingFire() )
			AmbientSound = FireSound;
		else
			AmbientSound = None;
	}
}

simulated function PlayFiring()
{
	LoopAnim('Shoot1',0.7 + 0.5 * FireAdjust, 0.05);
	IncrementFlashCount();
	AmbientSound = FireSound;
	SoundVolume = Pawn(Owner).SoundDampening*255;
}

defaultproperties
{
	AmmoName=Class'PulseAmmo'
	PickupAmmoCount=60
	ReloadCount=30
	bRapidFire=true
	AutoSwitchPriority=5
	FireOffset=(X=20,Y=4,Z=-5)
	ShakeMag=135
	ShakeVert=(X=0,Y=0,Z=8)
	TraceAccuracy=0.8
	aimerror=700
	AIRating=0.7
	FireSound=Sound'PulseGun.PulseFire'
	SelectSound=Sound'WarClassLight.Rifle.RiflePickup'
	MessageNoAmmo=" has no Plasma."
	WeaponDescription="Classification: Plasma Rifle\\n\\nPrimary Fire: Medium sized, fast moving plasma balls are fired at a fast rate of fire.\\n\\nSecondary Fire: A bolt of green lightning is expelled for 100 meters, which will shock all opponents.\\n\\nTechniques: Firing and keeping the secondary fire's lightning on an opponent will melt them in seconds."
	NameColor=(B=128,G=255,R=128,A=255)
	DisplayFOV=50
	FlashOffsetY=0.18
	FlashOffsetX=0.06
	FlashLength=0.02
	MFTexture=Texture'COGGatGun.SC_GatMuz4'
	bDrawMuzzleFlash=true
	bMuzzleFlashParticles=true
	MuzzleFlashScale=0.4
	MuzzleFlashStyle=3
	InventoryGroup=5
	PickupClass=Class'PickupCOGLightPlasma'
	PlayerViewOffset=(X=8,Y=4,Z=-3)
	BobDamping=0.975
	AttachmentClass=Class'WarClassLight.AttachmentCOGAssaultRifle'
	ItemName="Pulse Gun"
	Mesh=SkeletalMesh'COGGatGun'
	DrawScale=0.06
	Skins=/* Array type was not detected. */
	SoundVolume=255
}