//=============================================================================
// SwarmGunAmmunition
//
// 
//
// 
//=============================================================================

class SwarmGunAmmunition extends Ammunition;

//simulated function bool HasAmmo()
//{
//	return true;
//}

defaultproperties
{
	MaxAmmo=200
	AmmoAmount=100
	bRecommendSplashDamage=true
	bTrySplash=true
	ProjectileClass=Class'SwarmRocket'
	RefireRate=1.5
	PickupClass=Class'SwarmGunAmmo'
	Icon=Texture'SwarmGunAmmoIcon'
	ItemName="Swarmer Rockets"
}