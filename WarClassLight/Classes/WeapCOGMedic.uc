// ====================================================================
//  Class:  WarClassLight.WeapCOGMedic
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WeapCOGMedic extends WarfareRechargeWeapons;

#exec MESH  MODELIMPORT MESH=COG_MedicGunMesh MODELFILE=..\WarClassContent\models\COG_MedicGun.PSK LODSTYLE=10
#exec MESH  ORIGIN MESH=COG_MedicGunMesh X=0 Y=0 Z=0 YAW=60 PITCH=0 ROLL=6
#exec ANIM  IMPORT ANIM=COG_MedicGunAnims ANIMFILE=..\WarClassContent\models\COG_MedicGun.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP   SCALE MESHMAP=COG_MedicGunMesh X=1.0 Y=1.0 Z=1.0
#exec MESH  DEFAULTANIM MESH=COG_MedicGunMesh ANIM=COG_MedicGunAnims

// Digest and compress the animation data. Must come after the sequence declarations.
// 'VERBOSE' gives more debugging info in UCC.log 

#exec ANIM DIGEST  ANIM=COG_MedicGunAnims VERBOSE USERAWINFO

#exec OBJ LOAD FILE=..\textures\CogAssaultRifleTex.utx PACKAGE=CogAssaultRifleTex
#exec OBJ LOAD FILE=..\textures\Cog_FirstPersonGuns.utx PACKAGE=Cog_FirstPersonGuns
#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax PACKAGE=WeaponSounds

#EXEC MESHMAP SETTEXTURE MESHMAP=COG_MedicGunMesh NUM=0 TEXTURE=Cog_FirstPersonGuns.MedicGun.MedicGunShader
#EXEC MESHMAP SETTEXTURE MESHMAP=COG_MedicGunMesh NUM=1 TEXTURE=CogAssaultRifleTex.Sc_CogHand
#EXEC MESHMAP SETTEXTURE MESHMAP=COG_MedicGunMesh NUM=2 TEXTURE=Cog_FirstPersonGuns.MedicGun.MedicGunScreen


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

	if (Other==None)
		HitLocation = EndTrace;
	
	if (ThirdPersonActor!=None)
	{
		AttachmentCOGMedicGun(ThirdPersonActor).HitLoc=HitLocation;
	}
}

simulated function PlayFiring()
{
	PlayAnim('Shoot1',1.0);
	
	if ( Instigator.IsLocallyControlled() )
		FakeTrace();
}

function ServerFire()
{
	if ( AmmoType == None )
	{
		// ammocheck
		log("WARNING "$self$" HAS NO AMMO!!!");
		GiveAmmo(Pawn(Owner));
	}
	if ( COGMedicAmmo(AmmoType).Charge > 10 )
	{
		COGMedicAmmo(AmmoType).UseCharge(5);
		GotoState('NormalFire');
		TraceFire(TraceAccuracy,0,0);
		LocalFire();

		if  (ThirdPersonActor!=None)
		{
			AttachmentCOGMedicGun(ThirdPersonActor).bAutoFire = true;
			AttachmentCOGMedicGun(ThirdPersonActor).FlashCount++;
		}
	}
	else
	{
		AttachmentCOGMedicGun(ThirdPersonActor).bAutoFire = false;
		if ( (Role==ROLE_Authority) && (Instigator.IsLocallyControlled() ) )
			AttachmentCOGMedicGun(ThirdPersonActor).ThirdPersonEffects();

		Instigator.Controller.SwitchToBestWeapon();
		if ( bChangeWeapon )
		{		
			ClientForceWeaponSwitch();
			GotoState('DownWeapon');
		}
		else
			GotoState('Idle');
	}
}

function Finish()
{

	if (!Instigator.PressingFire())
	{
		if (ThirdPersonActor!=None)
		{
			AttachmentCOGMedicGun(ThirdPersonActor).bAutoFire = false;
			if ( (Role==ROLE_Authority) && (Instigator.IsLocallyControlled() ) )
			{
				AttachmentCOGMedicGun(ThirdPersonActor).ThirdPersonEffects();
			}
		}
	}
	
	Super.Finish();		
}



simulated function ClientFinish()
{

	if (!Instigator.PressingFire())
	{
		if (ThirdPersonActor!=None)
		{
			AttachmentCOGMedicGun(ThirdPersonActor).bAutoFire = false;
			AttachmentCOGMedicGun(ThirdPersonActor).ThirdPersonEffects();
		}
	}

	Super.ClientFinish();		
}

state ClientFiring
{
	simulated function BeginState()
	{
		AttachmentCOGMedicGun(ThirdPersonActor).bAutoFire = true;
		AttachmentCOGMedicGun(ThirdPersonActor).FlashCount++;
	}
}		

function ServerAltFire()
{
	if (WarfarePawn(Instigator).SelectedConstruction != None)
		WarfarePawn(Instigator).SelectedConstruction.AltFire();
}


defaultproperties
{
	AmmoName=Class'CogMedicAmmo'
	AutoSwitchPriority=255
	FireOffset=(X=20,Y=4,Z=-5)
	ShakeMag=350
	shaketime=0.2
	ShakeVert=(X=0,Y=0,Z=4)
	AIRating=0.41
	TraceDist=2048
	FireSound=Sound'WeaponSounds.CogMedicGun.medgun_shoot'
	SelectSound=Sound'WeaponSounds.CogMedicGun.medgun_bringup'
	DisplayFOV=45
	PickupClass=Class'PickupCOGPistol'
	PlayerViewOffset=(X=25,Y=5.5,Z=-6)
	BobDamping=0.975
	AttachmentClass=Class'AttachmentCOGMedicGun'
	ItemName="COG Magic Medic Weapon"
	Mesh=SkeletalMesh'COG_MedicGunMesh'
	DrawScale=0.04
}