class WarfareArmorPickup extends ArmorPickup
	abstract;

function float PlaySpawnEffect()
{
	spawn( class 'EnhancedReSpawn',self,, Location );
	return 0.3;
}

defaultproperties
{
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}