//=============================================================================
// B9_AutomationSentryGun
//
// 
//	Base class for sentry guns
// 
//=============================================================================

class B9_AutomationSentryGun extends B9_Automation
	abstract
	notplaceable;


//////////////////////////////////////////////////
// Variables
//

var FX_Dummy_Position				fBarrelDummyA;
var FX_Dummy_Position				fBarrelDummyB;

var bool							fExploded;

var class<B9SentryGunWeapon>		fWeaponClass;
var	B9SentryGunWeapon				fWeaponA;
var	B9SentryGunWeapon				fWeaponB;

var(Turret)	float					fMaxRange;
var(Turret)	int						fStartingHealth;
var(Turret)	float					fFiringInterval;

//////////////////////////////////////////////////
// Creation
//

function name GetWeaponBoneFor(Inventory I)
{
	return '';
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	if( instigatedBy == Self )
	{
		return;
	}

	Health -= Damage;
	if( Health <= 0 )
	{
		Explode(HitLocation, Normal(HitLocation-instigatedBy.Location));
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	spawn(class'ExplosionFX_One',,,HitLocation,rot(16384,0,0));

	HurtRadius( 20, 500, class'Impact', 0, Location );
	Destroy();
}

simulated function PostBeginPlay()
{
	local vector StartPos, X, Y, Z;
	local vector startPosOffset;
	
    Super.PostBeginPlay();

	// Add weapons to turret.
	//
	
	// Create the dummy actor objects
	// We use these as a reference for where the gun is pointing to
	// 
	if( fBarrelDummyA == None )
	{
		fBarrelDummyA = Spawn( class'FX_Dummy_Position', Self );
		fGunPart.AttachToBone(fBarrelDummyA, 'Barrel0');		
	}

	if( fBarrelDummyB == None )
	{
		fBarrelDummyB = Spawn( class'FX_Dummy_Position', Self );
		fGunPart.AttachToBone(fBarrelDummyB, 'Barrel1');		
	}
	
	// Spawn the weapons and attach to the correct points
	//
	if( fWeaponClass != None )
	{
		fWeaponA = Spawn( fWeaponClass, Self );
		if( fWeaponA == None )
		{
			log( "Failed to spawn Weapon A" );
		}
		B9_AutomationPartGun(fGunPart).fAttachBoneName = 'Barrel0';
		fWeaponA.AttachToPawn( fGunPart );
		//fGunPart.AttachToBone( fWeaponA, 'Barrel0' );
		fWeaponA.SetReferenceActor( fBarrelDummyA );
		//fGunPart.AttachToBone( fWeaponA.ThirdPersonActor, 'Barrel0' );
		B9_SentryWeaponAttachment( fWeaponA.ThirdPersonActor ).SetReferenceActor( fGunPart, 'Barrel0' );

		fWeaponB = Spawn( fWeaponClass, Self );
		if( fWeaponA == None )
		{
			log( "Failed to spawn Weapon B" );
		}
		B9_AutomationPartGun(fGunPart).fAttachBoneName = 'Barrel1';
		fWeaponB.AttachToPawn( fGunPart );
		//fGunPart.AttachToBone( fWeaponB, 'Barrel1' );
		fWeaponB.SetReferenceActor( fBarrelDummyB );
		//fGunPart.AttachToBone( fWeaponB.ThirdPersonActor, 'Barrel1' );
		B9_SentryWeaponAttachment( fWeaponB.ThirdPersonActor ).SetReferenceActor( fGunPart, 'Barrel1' );

		B9_AutomationPartGun(fGunPart).fAttachBoneName = '';
	}
	else
	{
		log( "No weapon class" );
	}
}


simulated function Fire( float value ) {} // class-specific


//////////////////////////////////
// Initialization
//









defaultproperties
{
	fShaftPartClass=Class'B9_AutomationPartShaft'
	fGunPartClass=Class'B9_AutomationPartGun'
	ControllerClass=Class'B9_AutomationSentryTurretController'
	Mesh=SkeletalMesh'B9Vehicles_models.sentrygun_base_mesh'
	CollisionRadius=30
	CollisionHeight=20
	bCollideWorld=false
}