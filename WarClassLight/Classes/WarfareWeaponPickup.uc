class WarfareWeaponPickup extends WeaponPickup
	abstract;

function float PlaySpawnEffect()
{
	spawn( class 'EnhancedReSpawn',self,, Location );
	return 0.3;
}

defaultproperties
{
	Physics=5
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}