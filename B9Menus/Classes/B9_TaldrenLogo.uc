//===============================================================================
//  [B9_TaldrenLogo] 
//===============================================================================

class B9_TaldrenLogo extends B9_Decoration;

#exec OBJ LOAD FILE=..\animations\B9Assets_models.ukx PACKAGE=B9Assets_models

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('Spin');
}

defaultproperties
{
	bStatic=false
	Mesh=SkeletalMesh'B9Assets_models.taldren_logo'
	bUnlit=true
}