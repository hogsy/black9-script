class Explosive_DetPack_Pickup extends B9_AccumulativeItemPickup
	placeable;

#exec OBJ LOAD FILE=..\Sounds\B9SoundFX.uax PACKAGE=B9SoundFX

event Landed(Vector HitNormal)
{
	//Log ("TossedCan Landed");

	Instigator = None;
	GotoState('Pickup');
}

// When touched by an actor and not landed
function Touch( actor Other )
{
	local vector HitNormal;

	if (Other == None)
		return;

	HitNormal = Normal(Velocity);
	if (Instigator != None)
	{
		PlaySound(sound'B9SoundFX.bullet_hitting_metal');
		Other.TakeDamage(10, Instigator, Location, Normal(Velocity), class'Impact');
		Instigator = None;
	}

	// Reflect off w/damping
	Velocity = 0.5 * (( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);
}

defaultproperties
{
	Amount=5
	fIniLookupName="DetPack"
	InventoryType=Class'Explosive_DetPack'
	PickupMessage="Acquired Satchel Charge."
	PickupSound=Sound'B9Misc_Sounds.ItemPickup.pickup_item05'
	Mesh=SkeletalMesh'B9Weapons_models.DetPack_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}