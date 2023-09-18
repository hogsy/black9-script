//=============================================================================
// damage_RockFist.uc
//
// 
//=============================================================================


class damage_RockFist extends DamageType;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	DamageWeaponName="Rock Fist"
	bInstantHit=true
	bFastInstantHit=true
	PawnDamageEmitter=Class'HitFX_Rockfist_Rocks'
	DamageDesc=10
}