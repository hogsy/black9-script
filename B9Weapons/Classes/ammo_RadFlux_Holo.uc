// ammo_RadFlux_Holo.uc

class ammo_RadFlux_Holo extends B9_HoloItem;

defaultproperties
{
	Description="Power source for the Rad Flux Rifle. Each cell contains 100 units of power. A maximum of 10 cells can be carried in inventory."
	DisplayName="Rad Flux energy cells"
	InventoryName="B9Weapons.ammo_RadFlux"
	CanAggregate=true
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_EnergyCell_kiosk_mesh'
}