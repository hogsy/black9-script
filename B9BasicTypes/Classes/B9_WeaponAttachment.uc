//=============================================================================
// B9_WeaponAttachment
//
//	Replacement for WeaponAttachment
// 
//=============================================================================



class B9_WeaponAttachment extends WeaponAttachment
	abstract;

enum eWeaponPose
{
	kRiflePose,
	kHandGunPose,
	kMeleeWeaponPose,
	kOverShoulderPose,
	kRelaxedPose
};

var	public eWeaponPose	fWeaponPose;			// replicated to identify how the Pawn should carry the weapon...

var vector			HitLoc;
var vector			fCartridgeFXOffset;
var vector			fMuzzleOffset;
var rotator			fMuzzleRotationOffset;

// R64 V190
var sound			fIdleAmbientSound;			// AmbientSound when not firing
var float			fIdleAmbientSoundRadius;	// Radius of fIdleAmbientSound
var byte			fIdleAmbientSoundVolume;	// Volume of fIdleAmbientSound

var sound			fFiringAmbientSound;		// AmbienstSound when firing
var float			fFiringAmbientSoundRadius;	// Radius of fFiringAmbientSound
var byte			fFiringAmbientSoundVolume;	// Volume of fFiringAmbientSound

var bool			bLastTickFiring;


var B9_MuzzleFlashAttachment		fMuzzleFlash;
var class<B9_MuzzleFlashAttachment>	fMuzzleClass;

var B9WeaponLightFX					fLightFX;
var class<B9WeaponLightFX>			fLightFXClass;

var B9EjectedCartridgeFX			fCartridgeFX;
var class<B9EjectedCartridgeFX>		fCartridgeFXClass;

var FX_Dummy_Position				fMuzzleDummy;

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && !bNetOwner && (Role==ROLE_Authority) )
		fWeaponPose,
		fCartridgeFXOffset,fMuzzleOffset,fMuzzleRotationOffset,
		HitLoc;
}


simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Spawn the dummy object in the muzzle
	//
	if( fMuzzleDummy == None )
	{
		fMuzzleDummy = spawn( class'FX_Dummy_Position', self );
		AttachToBone( fMuzzleDummy, 'muzzle' );		
	}

	// Set up muzzle flash
	//
	if( fMuzzleClass != None )
	{
		fMuzzleFlash = spawn( fMuzzleClass, Self );
		AttachToBone( fMuzzleFlash, 'muzzle' );
		fMuzzleFlash.SetRotation( fMuzzleDummy.Rotation );
	}

	// Set up lighting FX
	//
	if( fLightFXClass != None )
	{
		fLightFX = spawn( fLightFXClass, Self );
		fLightFX.SetLocation( Location );
	}


	// Set up ejected cartridge FX
	//
	if( fCartridgeFXClass != None )
	{
		fCartridgeFX = Spawn( fCartridgeFXClass, self );
		fCartridgeFX.SetOwner( self );
		fCartridgeFX.Emitters[0].StartLocationOffset = fCartridgeFXOffset;
	}

	// Set up idle sound FX, if so equipped
	if( fIdleAmbientSound != None )
	{
		AmbientSound	= fIdleAmbientSound;
		SoundRadius		= fIdleAmbientSoundRadius;
		SoundVolume		= fIdleAmbientSoundVolume;
	}
}

simulated function Tick( float DeltaTime )
{
	if( bLastTickFiring != bAutoFire )
	{
		if( bAutoFire )
		{
			if( fFiringAmbientSound != None )
			{
				AmbientSound	= fFiringAmbientSound;
				SoundRadius		= fFiringAmbientSoundRadius;
				SoundVolume		= fFiringAmbientSoundVolume;
			}
			else if( fIdleAmbientSound != None )
			{
				AmbientSound	= None;
				SoundRadius		= 0;
				SoundVolume		= 0;
			}
		}
		else
		{
			if( fIdleAmbientSound != None )
			{
				AmbientSound	= fIdleAmbientSound;
				SoundRadius		= fIdleAmbientSoundRadius;
				SoundVolume		= fIdleAmbientSoundVolume;
			}
			else if( fFiringAmbientSound != None )
			{
				AmbientSound	= None;
				SoundRadius		= 0;
				SoundVolume		= 0;
			}
		}
	}

	bLastTickFiring = bAutoFire;
}

simulated event Destroyed()
{
	if( fMuzzleFlash != None )
	{
		fMuzzleFlash.Destroy();
	}

	if( fLightFX != None )
	{
		fLightFX.Destroy();
	}

	if( fCartridgeFX != None )
	{
		fCartridgeFX.Destroy();
	}

	if( fMuzzleDummy != None )
	{
		fMuzzleDummy.Destroy();
	}
	
	Super.Destroyed();
}

// Determines the fx origin point
//
simulated function GetEffectStart(out vector Start, out rotator Rot)
{
	Start		= fMuzzleDummy.Location;
	//Rot		= Instigator.GetViewRotation();
	Rot			= Instigator.AdjustAim( None, Start, 1.0 );
}	


simulated function SpawnEffect()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		// Muzzle flash
		//
		if( fMuzzleFlash != None )
		{
			fMuzzleFlash.SetRotation( fMuzzleDummy.Rotation );
			fMuzzleFlash.Flash();
		}
		
		// Lighting
		//
		if( fLightFX != None )
		{
			fLightFX.SetLocation( Location );
			fLightFX.Flash();
		}
		
		
		// Ejected cartridge casings
		//
		if( fCartridgeFX != None )
		{
			fCartridgeFX.EjectOneRound();
		}		
	}
}


simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();
}


