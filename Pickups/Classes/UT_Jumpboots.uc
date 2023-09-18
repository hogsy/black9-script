//=============================================================================
// UT_jumpBoots
//=============================================================================
class UT_JumpBoots extends WarfarePickup;



defaultproperties
{
	MaxDesireability=0.5
	InventoryType=Class'JumpBoots'
	RespawnTime=30
	PickupMessage="You picked up the AntiGrav boots."
	PickupSound=Sound'WarEffects.Pickups.GenPickSnd'
	Mesh=VertMesh'jboot'
	AmbientGlow=64
	CollisionHeight=14
}