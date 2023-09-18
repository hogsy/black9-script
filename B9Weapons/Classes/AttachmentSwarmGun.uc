class AttachmentSwarmGun extends B9_WeaponAttachment;

#exec OBJ LOAD FILE=..\animations\B9Weapons_models.ukx PACKAGE=B9Weapons_models

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}

defaultproperties
{
	FiringMode=MODE_Grenade
	Mesh=SkeletalMesh'B9Weapons_models.bazooka'
}