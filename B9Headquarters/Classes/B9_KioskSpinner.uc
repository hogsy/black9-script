//===============================================================================
//  [B9_KioskSpinner] 
//	Animated icon on 6 polys to float over kiosks.
//	Texture must be changed from defaults in map file to make other icons.
//	- DP
//===============================================================================

class B9_KioskSpinner extends B9_Decoration;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('spin');
}

defaultproperties
{
	bStatic=false
	Mesh=SkeletalMesh'B9HQmodels_DP.kiosk_spinner_mesh'
	bUnlit=true
}