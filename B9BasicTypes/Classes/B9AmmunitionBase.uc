//=============================================================================
// B9BaseAmmunition
//
// Base class for all "simple" Black 9 ammunition
//
// 
//=============================================================================


class B9AmmunitionBase extends Ammunition
	native;

//////////////////////////////////
// Variables
//

var int		fDamage;
var float	fImpactForce;
var bool	fCustomSurfaceImpactFX;


var string	fIniLookupName;


//////////////////////////////////
// Functions
//

native(2021) final function		InitIniStats();

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	InitIniStats();
}

simulated function bool HasAmmo()
{
	return ( AmmoAmount > 0 );
}

function SpawnProjectile(vector Start, rotator Dir)
{
	local B9WeaponBase weap;
	
	weap = B9WeaponBase( Pawn( Owner ).Weapon );
	
	if( weap != None && weap.fUsesAmmo )
	{
		AmmoAmount -= weap.fAmmoExpendedPerShot;
	}
	else if( weap == None )
	{
		log( "--- no weapon" );
	}
	else if( weap != None )
	{
		log( "--- don't use ammo" );
	}

	Spawn( ProjectileClass,,, Start,Dir );
}


function ProcessTraceHit( Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z )
{}

function ProcessShotgunTraceHit( Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z, bool bTakeAmmo )
{}



defaultproperties
{
	fDamage=1
	fImpactForce=10000
}