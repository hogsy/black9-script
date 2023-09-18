//=============================================================================
// damage_ShotgunShell.uc
//
// Handles damage inflicted by the 9mm bullet
//
// 
//=============================================================================


class damage_ShotgunShell extends DamageType;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	bInstantHit=true
	bFastInstantHit=true
	DamageDesc=15
}