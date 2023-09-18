//=============================================================================
// damage_IceFist.uc
//
// 
//=============================================================================


class damage_IceFist extends DamageType;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	DamageWeaponName="Ice Fist"
	bInstantHit=true
	bFastInstantHit=true
	PawnDamageEmitter=Class'HitFX_Icefist_Dust'
	DamageDesc=10
}