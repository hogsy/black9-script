//=============================================================================
// SwarmGunAmmo
//
// 
//
// 
//=============================================================================

class SwarmGunAmmo extends Ammo;

#exec OBJ LOAD FILE=..\animations\B9Weapons_models.ukx PACKAGE=B9Weapons_models

#exec TEXTURE IMPORT NAME=SwarmGunAmmoIcon FILE=Textures\SwarmGunAmmoIcon.bmp

defaultproperties
{
	AmmoAmount=3
	InventoryType=Class'SwarmGunAmmunition'
	PickupMessage="You picked up some drunk missiles."
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_DrunkMissile_mesh'
	CollisionHeight=11
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}