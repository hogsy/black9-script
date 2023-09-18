//=============================================================================
// turret_EXP
//
// 
//	Experimental manned turret weapon/vehicle thingy
// 
//=============================================================================



class turret_EXP extends B9_Emplacement;


//////////////////////////////////
// Definitions
//



//////////////////////////////////
// Variables
//
var FX_Dummy_Position	fBarrelDummyA;
var FX_Dummy_Position	fBarrelDummyB;
var FX_Dummy_Position	fGunnerSeatDummy;
var sound				fFireSound;
var	turret_EXP_muzzle	fBarrel1MuzzleFlash;
var	turret_EXP_muzzle	fBarrel2MuzzleFlash;

//////////////////////////////////
// Functions
//

simulated function PostBeginPlay()
{
	local vector StartPos, X, Y, Z;

	Super.PostBeginPlay();
	GetAxes( Rotation, X, Y, Z );

	
	fOperatorTrigger	= Spawn( class'B9_VehicleTrigger', Self, , Location );
	fOperatorTrigger.SetBase( self );
	fOperatorTrigger.SetCollision( true, false, false );
	fOperatorTrigger.Set( 'nowpn_turret_enter', 'nowpn_turret_use', 'nowpn_turret_exit', fOperatorTriggerOffset );

	if( fBarrelDummyA == None )
	{
		fBarrelDummyA = Spawn( class'FX_Dummy_Position', Self, , Location, Rotation );
		fGunPart.AttachToBone(fBarrelDummyA, 'Barrel0');		
	}

	if( fBarrelDummyB == None )
	{
		fBarrelDummyB = Spawn( class'FX_Dummy_Position', Self, , Location, Rotation );
		fGunPart.AttachToBone(fBarrelDummyB, 'Barrel1');
	}

	if( fGunnerSeatDummy == None )
	{
		fGunnerSeatDummy = Spawn( class'FX_Dummy_Position', Self, , Location, Rotation );
		fSeatPart.AttachToBone(fGunnerSeatDummy, 'GunnerSeat');		
	}

	if( fBarrel1MuzzleFlash == None )
	{
		fBarrel1MuzzleFlash = Spawn( class'turret_EXP_muzzle', Self, , Location, Rotation );
		fGunPart.AttachToBone(fBarrel1MuzzleFlash, 'Barrel0');
	}

	if( fBarrel2MuzzleFlash == None )
	{
		fBarrel2MuzzleFlash = Spawn( class'turret_EXP_muzzle', Self, , Location, Rotation );
		fGunPart.AttachToBone(fBarrel2MuzzleFlash, 'Barrel1');
	}
}

simulated function GetCameraPosition( out vector CamPos )
{
	local vector	X, Y, Z;

	GetAxes( fSeatPart.Rotation, X, Y, Z );
	CamPos	= fGunnerSeatDummy.Location + (X*fCameraOffset.X) + (Y*fCameraOffset.Y) + (Z*fCameraOffset.Z);
}


simulated function LocalFire()
{
	PlayOwnedSound( fFireSound, SLOT_None, 1.0f);
} 

function SpawnFire()
{
	if( fBarrelToUse == 0 )
	{
		Spawn(class'turret_EXP_projectile', Self, , fBarrelDummyA.Location, fBarrelDummyA.Rotation );
		fBarrel1MuzzleFlash.Fire(1);
		fBarrelToUse = 1;
	}
	else
	{
		Spawn(class'turret_EXP_projectile', Self, , fBarrelDummyB.Location, fBarrelDummyB.Rotation );
		fBarrel2MuzzleFlash.Fire(1);
		fBarrelToUse = 0;
	}
} 

event Destroyed()
{
	if( fBarrelDummyA != none )
	{
		fBarrelDummyA.Destroy();
	}

	if( fBarrelDummyB != none )
	{
		fBarrelDummyB.Destroy();
	}

	if( fBarrel1MuzzleFlash != none )
	{
		fBarrel1MuzzleFlash.Destroy();
	}

	if( fBarrel2MuzzleFlash != none )
	{
		fBarrel2MuzzleFlash.Destroy();
	}


	Super.Destroyed();
}

//////////////////////////////////
// States
//



//////////////////////////////////
// Initialization
//
defaultproperties
{
	FFireSound=Sound'B9SoundFX.Explosions.explosion_3'
	fSeatPartClass=Class'turret_EXP_SeatPart'
	fGunPartClass=Class'turret_EXP_GunPart'
	fGunPartOffset=(X=0,Y=0,Z=100)
	fFireStart[0]=(X=-5,Y=0,Z=5)
	fFireStart[1]=(X=-5,Y=0,Z=5)
	fCameraOffset=(X=-275,Y=0,Z=180)
	fRateOfFire=0.4
	fNumberOfBarrels=2
	fOperatorTriggerOffset=(X=-96.699,Y=-103.42,Z=0)
	Mesh=SkeletalMesh'B9Vehicles_models.luna_turret_base_mesh'
}