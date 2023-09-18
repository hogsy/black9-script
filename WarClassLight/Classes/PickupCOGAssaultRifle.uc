class PickupCOGAssaultRifle extends WarfareWeaponPickup;

var int ClipAmounts[2];
var int GrenadeAmount;

defaultproperties
{
	InventoryType=Class'WeapCOGAssaultRifle'
	PickupMessage="You picked up a COG Assault Rifle."
	PickupSound=Sound'WarEffects.Pickups.WeaponPickup'
	DrawType=8
	StaticMesh=StaticMesh'3pguns_meshes.Cog_Guns.Grunt_Gun'
	DrawScale=0.1
	Skins=/* Array type was not detected. */
	CollisionRadius=34
	CollisionHeight=8
}