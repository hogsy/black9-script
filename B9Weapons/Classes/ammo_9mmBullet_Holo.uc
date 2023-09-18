// ammo_9mmBullet_Holo.uc

class ammo_9mmBullet_Holo extends B9_HoloItem;

defaultproperties
{
	Description="Ammo clip for the standard 9mm pistol.  One clip holds 15 rounds. A maximum of 8 clips can be carried in inventory."
	DisplayName="9mm ammo"
	InventoryName="B9Weapons.ammo_9mmBullet"
	CanAggregate=true
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_9mmClip_kiosk_mesh'
}