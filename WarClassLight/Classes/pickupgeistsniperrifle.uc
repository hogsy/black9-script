//=============================================================================
// SniperRifle
// A military redesign of the rifle.
//=============================================================================
class PickupGeistSniperRifle extends WarfareWeaponPickup;

defaultproperties
{
	InventoryType=Class'weapgeistsniperrifle'
	PickupMessage="You got a Sniper Rifle."
	PickupSound=Sound'WarEffects.Pickups.WeaponPickup'
	Mesh=VertMesh'RifleHand'
	CollisionRadius=32
	CollisionHeight=8
}