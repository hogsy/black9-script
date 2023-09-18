// ammo_RailGun_Holo.uc

class ammo_RailGun_Holo extends B9_HoloItem;

defaultproperties
{
	Description="Ammo magazine for the Rail Gun. One magazine holds 5 rounds. A maximum of 5 magazines can be carried in inventory."
	DisplayName="Rail Gun magazine"
	InventoryName="B9Weapons.ammo_RailGun"
	CanAggregate=true
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_RailGunClip_kiosk_mesh'
}