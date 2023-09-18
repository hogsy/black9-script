// ====================================================================
//  Class:  WarfareGame.WarfareAmmo
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WarfareAmmo extends Ammunition
		Abstract;


var vector WeaponKick;			// How much Pitch (Z) and Yaw (X) get applied when a shot is fired.  Negative Values apply

// Tell the Client to add some kick for the weapon

function ApplyKick()
{
	if ( WarfarePawn(Instigator) != None )
	{
		WarfarePawn(Instigator).ClientKickView(WeaponKick);
	}
}

function SpawnProjectile(vector Start, rotator Dir)
{
	Super.SpawnProjectile(Start, Dir);
	ApplyKick();
}

function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	super.ProcessTracehit(W,Other,HitLocation, HitNormal, X, Y, Z);
	ApplyKick();
}

