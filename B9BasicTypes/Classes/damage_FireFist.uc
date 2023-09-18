//=============================================================================
// damage_FireFist.uc
//
// 
//=============================================================================


class damage_FireFist extends DamageType;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	DamageWeaponName="Fire Fist"
	bInstantHit=true
	bFastInstantHit=true
	PawnDamageEffect=Class'HitFX_Flamethrower'
	DamageDesc=10
}