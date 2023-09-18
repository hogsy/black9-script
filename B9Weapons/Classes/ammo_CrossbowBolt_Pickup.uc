//=============================================================================
// ammo_CrossbowBolt_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_CrossbowBolt_Pickup extends B9_Ammo;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=SwarmGunAmmoIcon FILE=Textures\SwarmGunAmmoIcon.bmp



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="Crossbow"
	AmmoAmount=8
	InventoryType=Class'ammo_CrossbowBolt'
	PickupMessage="Crossbow Bolt"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_CrossbowQuiver_mesh'
}