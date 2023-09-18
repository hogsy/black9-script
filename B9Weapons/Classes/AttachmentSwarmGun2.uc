class AttachmentSwarmGun2 extends B9_WeaponAttachment;

#exec OBJ LOAD FILE=..\StaticMeshes\B9_Weapons_meshes.usx PACKAGE=B9_Weapons_meshes

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}

defaultproperties
{
	FiringMode=MODE_Grenade
	Mesh=SkeletalMesh'B9Weapons_models.bazooka'
}