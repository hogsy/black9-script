//=============================================================================
// damage_FlameThrower.uc
//
// Handles damage inflicted by the Magnum bullet
//
// 
//=============================================================================


class damage_FlameThrower extends DamageType;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	DamageWeaponName="Flamethrower"
	bInstantHit=true
	bFastInstantHit=true
	DamageDesc=15
}