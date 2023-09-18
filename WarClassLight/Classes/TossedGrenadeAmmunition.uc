//=============================================================================
// TossedGrenadeAmmunition.
//=============================================================================
class TossedGrenadeAmmunition extends GrenadeAmmunition;

#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax PACKAGE=WeaponSounds

defaultproperties
{
	EventName=Grenades
	MaxAmmo=5
	AmmoAmount=5
	bTossed=true
	ProjectileClass=Class'TossedGrenade'
	FireSound=Sound'WeaponSounds.AssaultRifle.COGassault_shootgrenade'
	PickupClass=Class'RocketPack'
}