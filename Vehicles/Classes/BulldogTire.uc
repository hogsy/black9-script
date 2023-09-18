#exec OBJ LOAD FILE=..\staticmeshes\ATV_Meshes.usx

class BulldogTire extends KTire;

defaultproperties
{
	StaticMesh=StaticMesh'ATV_Meshes.Bulldog.Bulldog_R_Tyre'
	DrawScale=0.4
	CollisionRadius=34
	CollisionHeight=34
	begin object name=KParams0 class=KarmaParamsRBFull
	// Object Offset:0x00072B0D
	KInertiaTensor[0]=1.8
	KInertiaTensor[3]=1.8
	KInertiaTensor[5]=1.8
	KLinearDamping=0
	KAngularDamping=0
	bHighDetailOnly=false
	bClientOnly=false
	bKDoubleTickRate=true
object end
// Reference: KarmaParamsRBFull'BulldogTire.KParams0'
KParams=KParams0
}