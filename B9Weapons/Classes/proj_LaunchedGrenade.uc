//=============================================================================
// proj_LaunchedGrenade.uc
//=============================================================================
class proj_LaunchedGrenade extends B9Explosive_Proj;


defaultproperties
{
	BounceDamping=0.65
	Speed=2100
	MaxSpeed=3000
	DrawType=2
	Mesh=SkeletalMesh'B9Weapons_models.Proj_GrenadeShell_mesh'
}