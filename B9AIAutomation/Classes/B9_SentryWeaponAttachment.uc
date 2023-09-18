//=============================================================================
// B9_SentryWeaponAttachment
//
// Specifically for Sentry Gun weapons
// 
//=============================================================================



class B9_SentryWeaponAttachment extends B9_WeaponAttachment
	abstract;


var Actor	fReferenceActor;
var name	fAttachmentBone;

function SetReferenceActor( Actor A, name N )
{
	fReferenceActor = A;
	fAttachmentBone	= N;
}

event PostBeginPlay()
{
	local Pawn P;
	
	Super.PostBeginPlay();

	P = Pawn(Owner);
	
	if( P!=None ) 
	{
		// Set up muzzle flash
		//
		if( fMuzzleClass != None )
		{
			fMuzzleFlash = spawn(fMuzzleClass,Owner);
			fMuzzleFlash.SetLocation(Location);
			fMuzzleFlash.SetBase(P);
		}
		else
		{
			log( "-------- NO muzzle class" );
		}
			
		// Set up lighting FX
		//
		if( fLightFXClass != None )
		{
			fLightFX = spawn( fLightFXClass, Owner );
			fLightFX.SetLocation(Location);
			fLightFX.SetBase(P);
		}


		// Set up ejected cartridge FX
		//
		if( fCartridgeFXClass != None )
		{
			fCartridgeFX = Spawn( fCartridgeFXClass, self );
			fCartridgeFX.SetOwner( self );
			fCartridgeFX.Emitters[0].StartLocationOffset = fCartridgeFXOffset;
		}
	}
}

event Destroyed()
{
	if (fMuzzleFlash!=None)
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
	
	Super.Destroyed();
}

// Determines the fx origin point
//
simulated function GetEffectStart(out vector Start, out rotator Rot)
{
	Start	= Location;
	Rot		= Rotation;
}


simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();
}



