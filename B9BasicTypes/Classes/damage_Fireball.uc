//=============================================================================
// damage_Fireball.uc
//
// 
//=============================================================================


class damage_Fireball extends DamageType;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	DamageWeaponName="Fireball"
	PawnDamageEffect=Class'HitFX_Flamethrower'
	DamageDesc=10
}