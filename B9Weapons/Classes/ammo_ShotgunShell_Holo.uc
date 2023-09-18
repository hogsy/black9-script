//=============================================================================
// ammo_ShotgunShell_Holo
//
// 
//
// 
//=============================================================================

class ammo_ShotgunShell_Holo extends B9_HoloItem;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	Description="Box of 10 shotgun shells. A maximum of 20 shells can be carried in inventory."
	DisplayName="Shotgun Shells"
	InventoryName="B9Weapons.ammo_ShotgunShell"
	CanAggregate=true
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_ShotgunShellBox_kiosk_mesh'
}