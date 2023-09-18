class AttachmentGeistGrenadeLauncher extends WarfareWeaponAttachment;

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}

defaultproperties
{
	FiringMode=MODE_Grenade
	Mesh=SkeletalMesh'GeistGL3'
	RelativeRotation=(Pitch=0,Yaw=16384,Roll=0)
}