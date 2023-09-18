class WarfareKeyPickup extends KeyPickup
	placeable;

function float PlaySpawnEffect()
{
	spawn( class 'EnhancedReSpawn',self,, Location );
	return 0.3;
}

defaultproperties
{
	PickupSound=Sound'WarEffects.Pickups.WeaponPickup'
	Mesh=VertMesh'pflag'
}