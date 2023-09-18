//=============================================================================
// Sentry_Machinegun_Weapon.uc
//
// Chaingun-like weapon for the sentry gun
//
// 
//=============================================================================


class Sentry_Machinegun_Weapon extends B9SentryGunWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=850
	fIniLookupName="SentryMachinegun"
	AmmoName=Class'ammo_SentryMachinegun'
	PickupAmmoCount=30
	ReloadCount=30
	TraceDist=6144
	MaxRange=6144
	FireSound=Sound'B9Fixtures_sounds.SentryTurret.turret_shot03'
	AttachmentClass=Class'Sentry_Machinegun_Weapon_Attachment'
	ItemName="Sentry Machinegun"
	DrawType=0
}