//=============================================================================
// B9_AmmoDepotTrigger
//=============================================================================
class B9_AmmoDepotTrigger extends B9_DepotTrigger;

// The ResourceCount for this subclass is in units of 9mm pistol ammo clips.

var Sound ReloadSound;
var float ReloadSoundVolume;

enum AmmoDepotType
{
	ADT_LightWeaponAmmo,
	ADT_HeavyWeaponAmmo
};

var(DepotTrigger) AmmoDepotType AmmoDepotKind;

function int GetKind()
{
	return int(AmmoDepotKind) + Basis;
}

function UsedBy( Pawn user )
{
	local int clips;
	local Ammunition ammo;
	local class<Inventory> findClass;

	//Log( "B9_AmmoDepotTrigger.UsedBy: "$user );
	if ( IsRelevant( user ) && user.Weapon != None && B9WeaponBase(user.Weapon).fUsesAmmo)
	{
		if (AmmoDepotKind == ADT_HeavyWeaponAmmo)
			findClass = class'B9HeavyWeapon';
		else
			findClass = class'B9LightWeapon';

		if (!ClassIsChildOf(user.Weapon.Class, findClass))
			return;

		ammo = user.Weapon.AmmoType;
		clips = (ammo.MaxAmmo - ammo.AmmoAmount) / user.Weapon.Default.ReloadCount;

		if (clips > CurrentAmount)
			clips = CurrentAmount;
		
		if (clips > 0)
		{
			PlaySound(ReloadSound, SLOT_None, ReloadSoundVolume,,100);

			ammo.AmmoAmount += clips * user.Weapon.Default.ReloadCount;
			CurrentAmount -= clips;
		}	

		User.Trigger(self, User.Instigator); // change depot info in HUD
	}
}

defaultproperties
{
	ReloadSound=Sound'B9Misc_Sounds.ItemPickup.pickup_item03'
	ReloadSoundVolume=0.7
}