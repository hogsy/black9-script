// ammo_Tazer_Holo.uc

class ammo_Tazer_Holo extends B9_HoloItem;

defaultproperties
{
	Description="Power source for the Stun Gun. One cell contains 10 units of power. A maximum of 5 cells can be carried in inventory."
	DisplayName="Stun Gun energy cells"
	InventoryName="B9Weapons.ammo_Tazer"
	CanAggregate=true
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_EnergyCell_kiosk_mesh'
}