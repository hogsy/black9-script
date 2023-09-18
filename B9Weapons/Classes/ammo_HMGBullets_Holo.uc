// ammo_HMGBullets_Holo.uc

class ammo_HMGBullets_Holo extends B9_HoloItem;

defaultproperties
{
	Description="Ammo magazine for the Heavy Machine Gun. One magazine holds 100 rounds. A maximum of 10 magazines can be carried in inventory."
	DisplayName="Heavy Machinegun Magazine"
	InventoryName="B9Weapons.ammo_HMGBullets"
	CanAggregate=true
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_9mmClip_kiosk_mesh'
}