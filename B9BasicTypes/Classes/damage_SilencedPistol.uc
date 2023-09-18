//=============================================================================
// damage_SilencedPistol.uc
//
// Handles damage inflicted by the 9mm bullet
//
// 
//=============================================================================


class damage_SilencedPistol extends DamageType;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	bInstantHit=true
	bFastInstantHit=true
	DamageDesc=5
}