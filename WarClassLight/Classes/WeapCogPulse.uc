// ====================================================================
//  Class:  WarClassLight.WeapCogPulse
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WeapCogPulse extends WarfareRechargeWeapons;

#exec MESH  MODELIMPORT MESH=COG_PulseGunMesh MODELFILE=..\WarClassContent\models\COG_PulseGun.PSK LODSTYLE=10
#exec MESH  ORIGIN MESH=COG_PulseGunMesh X=0 Y=0 Z=0 YAW=62 PITCH=0 ROLL=1
#exec ANIM  IMPORT ANIM=COG_PulseGunAnims ANIMFILE=..\WarClassContent\models\COG_PulseGun.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP   SCALE MESHMAP=COG_PulseGunMesh X=1.0 Y=1.0 Z=1.0
#exec MESH  DEFAULTANIM MESH=COG_PulseGunMesh ANIM=COG_PulseGunAnims

// Digest and compress the animation data. Must come after the sequence declarations.
// 'VERBOSE' gives more debugging info in UCC.log 

#exec ANIM DIGEST ANIM=COG_PulseGunAnims VERBOSE USERAWINFO

#exec OBJ LOAD FILE=..\textures\CogAssaultRifleTex.utx PACKAGE=CogAssaultRifleTex
#exec OBJ LOAD FILE=..\textures\Cog_FirstPersonGuns.utx PACKAGE=Cog_FirstPersonGuns

#EXEC MESHMAP SETTEXTURE MESHMAP=COG_PulseGunMesh NUM=0 TEXTURE=Cog_FirstPersonGuns.PulseGun.PulseGunShader
#EXEC MESHMAP SETTEXTURE MESHMAP=COG_PulseGunMesh NUM=1 TEXTURE=CogAssaultRifleTex.Sc_CogHand
#EXEC MESHMAP SETTEXTURE MESHMAP=COG_PulseGunMesh NUM=2 TEXTURE=Cog_FirstPersonGuns.PulseGun.PulseGunScreenShader

// Original material [0] is [Skin0] SkinIndex: 0 Bitmap: COG_PulseGun.tga  Path: M:\Work\Warfare\Guns\COG Pulse Rifle\Cog Pulserifle from SteveG\Final 
// Original material [1] is [Skin1] SkinIndex: 1 Bitmap: Sc_CogHand.tga  Path: C:\Work\Warfare\Guns\COG Assault Rifle\For Eric 
// Original material [2] is [Skin2unlit] SkinIndex: 2 Bitmap: COG_PulseGunScreen.tga  Path: M:\Work\Warfare\Guns\COG Pulse Rifle\Cog Pulserifle from SteveG\Final 

#exec OBJ LOAD FILE=..\Textures\MuzzleFlashes.utx PACKAGE=MuzzleFlashes

var int which;
var float ShotCharge;
var float AutoShootTime;
var() sound AltFireSound;
replication
{
	reliable if (ROLE<ROLE_Authority)
		ServerShootIt, ShotCharge;
		
	reliable if (ROLE==ROLE_Authority)
		ClientReset;		
}

simulated function ClientReset()
{
	GotoState('Idle');
}

	
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

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
		AttachmentCOGPulse(ThirdPersonActor).HitLoc=HitLocation;
}


function ServerFire()
{
	if ( AmmoType == None )
	{
		// ammocheck
		log("WARNING "$self$" HAS NO AMMO!!!");
		GiveAmmo(Pawn(Owner));
	}
	if ( COGP9Ammo(AmmoType).Charge > 10 )
	{
		COGP9Ammo(AmmoType).ShotCharge = 10;
		COGP9Ammo(AmmoType).UseCharge(10);
		GotoState('NormalFire');
		TraceFire(TraceAccuracy,0,0);
	
		if  (ThirdPersonActor!=None)
		{
			AttachmentCOGPulse(ThirdPersonActor).Mode=0;
			AttachmentCOGPulse(ThirdPersonActor).bAutoFire = true;
			AttachmentCOGPulse(ThirdPersonActor).FlashCount++;
		}
		
		LocalFire();
		
	}
	else
		PlaySound(FireSound, SLOT_None, 1.0);

	ClientReset();
	GotoState('Idle');
}

simulated function TweenDown()
{
	PlayOwnedSound(sound'C_PulseGunFail2_X_AW');
	Super.TweenDown();
}


simulated function AltFire( float Value )
{
	ServerAltFire();
	if ( Role < ROLE_Authority )
	{
		GotoState('ClientAltFiring');
	}
}


function ServerAltFire()
{
	Instigator.Controller.bAltFire=1;
	GotoState('AltFiring');
}
simulated function PlayFiring()
{
	local float rnd;
	local name n;
	
	rnd = frand();
	
	bMuzzleFlash = true;
	
	if (rnd<0.33)
		n = 'Shoot1';
	else if (rnd<0.66)
		n = 'Shoot2';
	else
		n = 'Shoot3';

	PlayAnim(n,1);
	PlayOwnedSound(FireSound, SLOT_None, 1.0);
	
	if ( Instigator.IsLocallyControlled() )
		FakeTrace();
}

simulated function PlayAltFiring()
{
	local float rnd;
	local name n;
	
	rnd = frand();
	
	n = 'ShootAlt';
	
	bMuzzleFlash = true;
	
	PlayAnim(n,1.0);
	PlayOwnedSound(AltFireSound, SLOT_None, 1.0);
	
	if ( Instigator.IsLocallyControlled() )
	{
		AttachmentCOGPulse(ThirdPersonActor).Mode=1;
		FakeTrace();
		AttachmentCOGPulse(ThirdPersonActor).Mode=0;
	}
}

simulated function LocalAltFire()
{
	local PlayerController P;

	bPointing = true;

	if ( (Instigator != None) && Instigator.IsLocallyControlled() )
	{
		P = PlayerController(Instigator.Controller);
	}
	if ( Affector != None )
		Affector.FireEffect();
	PlayAltFiring();
}		


function ServerShootit()
{
	local WarfarePawn P;
	
	P = WarfarePawn(Instigator);

	if (ShotCharge>0)
	{
		COGP9Ammo(AmmoType).ShotCharge = ShotCharge;

		if  (ThirdPersonActor!=None)
		{
			AttachmentCOGPulse(ThirdPersonActor).Mode=1;
			AttachmentCOGPulse(ThirdPersonActor).ShotCharge = ShotCharge;
			AttachmentCOGPulse(ThirdPersonActor).bAutoFire = true;
			AttachmentCOGPulse(ThirdPersonActor).FlashCount++;
		}
		
		TraceFire(TraceAccuracy,0,0);
		LocalAltFire();
	
		COGP9Ammo(AmmoType).bNoRecharge=false;
	}

	Instigator.Controller.bAltFire=0;
	ClientReset();	
	GotoState('Idle');
}

simulated function PlayCharging()
{
	local name n;
	
	if (ShotCharge<10)
		n = 'ChargeUp1';
	else if (ShotCharge<50)
		n = 'ChargeUp2';
	else
		n = 'Chargeup3';

	PlayAnim(n,1.0);
}

state AltFiring
{
	function ServerFire();
	function ServerAltFire();
	function Fire(float F) {}
	function AltFire(float F) {} 

	event Tick(float delta)
	{
		local WarfarePawn P;
		local float e;
		local RechargingAmmo A;

		P = WarfarePawn(Instigator);
		A = RechargingAmmo(AmmoType);

		if (!A.HasAmmo())
			AutoShootTime -= Delta;			
		
		if ( (!P.PressingAltFire()) || (AutoShootTime<=0) )
		{
			log("#### Server Shooting: "$AutoShootTime);
			
			ServerShootIt();
			LocalAltFire();
			return;
		}

		if ( A.HasAmmo() )
		{
			e = 33*Delta;
			ShotCharge += A.UseCharge(e);
		}
	
	}		
	
	function AnimEnd(int Channel)
	{
		PlayCharging();
	}

	function EndState()
	{
		StopFiringTime = Level.TimeSeconds;
	}
	
	function BeginState()
	{
		PlayCharging();
		ShotCharge=0;
		COGP9Ammo(AmmoType).bNoRecharge=true;
		AutoShootTime = 2.0;
	}

Begin:
	Sleep(0.0);
}


state ClientAltFiring
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	simulated function ClientReset()
	{
		PlayAltFiring();
		GotoState('Idle');
	}
	
	
	simulated event Tick(float delta)
	{
		if (!Instigator.PressingAltFire() )
		{
			PlayAltFiring();
			ServerShootIt();
			GotoState('Idle');
		}
	}		
	
	simulated function AnimEnd(int Channel)
	{

		if ( Instigator.PressingAltFire() )
			PlayCharging();
	}

	simulated function EndState()
	{
		AmbientSound = None;
	}
	
	simulated function BeginState()
	{
		PlayCharging();
	}
	
}

state Idle
{
	simulated function ForceReload()
	{
	}

	function ServerForceReload()
	{
	}	
	
	simulated function AnimEnd(int Channel)
	{
		PlayIdleAnim();
	}

	simulated function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	bPointing=False;
	PlayIdleAnim();
}
simulated function DrawMuzzleFlash(Canvas Canvas)
{
	local float Scale, ULength, VLength, UStart, VStart;

	Scale = MuzzleScale * Canvas.ClipX/640.0;
	Canvas.Style = ERenderStyle.STY_Alpha;
	ULength = MFTexture.USize;
	if ( FRand() < 0.5 )
	{
		UStart = ULength;
		ULength = -1 * ULength;
	}
	VLength = MFTexture.VSize;
	if ( FRand() < 0.5 )
	{
		VStart = VLength;
		VLength = -1 * VLength;
	}

	Canvas.DrawTile(MFTexture, Scale * MFTexture.USize, Scale * MFTexture.VSize, UStart, VStart, ULength, VLength);
	Canvas.Style = ERenderStyle.STY_Normal;
}

defaultproperties
{
	AltFireSound=Sound'WeaponSounds.AutoPulse.pulsegun_charged_shoot'
	AmmoName=Class'CogP9Ammo'
	FireOffset=(X=20,Y=4,Z=-5)
	ShakeMag=350
	shaketime=0.2
	ShakeVert=(X=0,Y=0,Z=4)
	AIRating=0.41
	FireSound=Sound'WeaponSounds.AutoPulse.pulsegun_shoot'
	SelectSound=Sound'WeaponSounds.AutoPulse.pulsegun_comeup'
	DisplayFOV=45
	FlashOffsetY=0.13
	FlashOffsetX=0.13
	MuzzleFlashSize=256
	MFTexture=Texture'MuzzleFlashes.2D.C_Muzzle2DPulse_T_SC'
	bDrawMuzzleFlash=true
	PickupClass=Class'PickupCOGPistol'
	PlayerViewOffset=(X=25,Y=6.5,Z=-5)
	BobDamping=0.975
	AttachmentClass=Class'AttachmentCOGPulse'
	ItemName="COG Pulse Rifle"
	Mesh=SkeletalMesh'COG_PulseGunMesh'
	DrawScale=0.04
}