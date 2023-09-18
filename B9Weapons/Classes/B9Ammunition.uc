//=============================================================================
// B9Ammunition
//
// 
//=============================================================================


class B9Ammunition extends B9AmmunitionBase;

//////////////////////////////////
// Functions
//

simulated function class<Actor> GetHitFXForSurfaceType( ESurfaceTypes surfType )
{
	switch( surfType )
	{
	case EST_Default:
		return class'WallHit_Default';
		break;

	case EST_Rock:
		return class'WallHit_Rock';
		break;

	case EST_Dirt:
		return class'WallHit_Dirt';
		break;

	case EST_Metal:
		return class'WallHit_Metal';
		break;

	case EST_Wood:
		return class'WallHit_Wood';
		break;

	case EST_Plant:
		return class'WallHit_Plant';
		break;

	case EST_Flesh:
		return class'WallHit_Flesh';
		break;

	case EST_Ice:
		return class'WallHit_Ice';
		break;

	case EST_Snow:
		return class'WallHit_Snow';
		break;

	case EST_Water:
		return class'WallHit_Water';
		break;

	case EST_Glass:
		return class'WallHit_Glass';
		break;

	case EST_Moon:
		return class'WallHit_Moon';
		break;

	default:
		log( "B9Ammunition::GetHitFXForSurfaceType() -- Unknown surface type, defaulting" );
		return class'WallHit_Default';
	}
}

function ProcessTraceHit( Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z )
{
	local B9WeaponBase		weap;
	
	weap = B9WeaponBase( W );

	if( weap != None && weap.fUsesAmmo )
	{
		AmmoAmount -= weap.fAmmoExpendedPerShot;
	}

	if( Other != None && Other != W.Instigator )
	{
		if( !Other.bWorldGeometry )
		{
			Other.TakeDamage( fDamage, W.Instigator, HitLocation, X*fImpactForce, MyDamageType );
		}

		Spawn( GetHitFXForSurfaceType( Other.GuessSurfaceType() ),,, HitLocation+HitNormal, Rotator( HitNormal ) );
	}
}

function ProcessShotgunTraceHit( Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z, bool bTakeAmmo )
{
	local B9WeaponBase		weap;
	
	weap = B9WeaponBase( W );

	if( weap != None && weap.fUsesAmmo && bTakeAmmo )
	{
		AmmoAmount -= weap.fAmmoExpendedPerShot;
	}

	if( Other != None && Other != W.Instigator )
	{
		if( !Other.bWorldGeometry )
		{
			Other.TakeDamage( fDamage, W.Instigator, HitLocation, X*fImpactForce, MyDamageType );
		}

		Spawn( GetHitFXForSurfaceType( Other.GuessSurfaceType() ),,, HitLocation+HitNormal, Rotator( HitNormal ) );
	}
}




