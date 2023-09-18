// ammo_SMG_Holo.uc

class ammo_SMG_Holo extends B9_HoloItem;

defaultproperties
{
	Description="Ammo magazine for the SMG. One magazine holds 30 rounds. A maximum of 15 magazines can be carried in inventory."
	DisplayName="Sub-Machine Gun ammo"
	InventoryName="B9Weapons.ammo_SMG"
	CanAggregate=true
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_9mmClip_kiosk_mesh'
}