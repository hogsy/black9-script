//===============================================================================
//  [B9_mgun_muzzle_flash] 
//===============================================================================

class B9_mgun_muzzle_flash extends Actor;

#exec OBJ LOAD FILE=..\animations\B9Weapons_models.ukx PACKAGE=B9Weapons_models

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('Spin');
}

defaultproperties
{
	DrawType=2
	Mesh=SkeletalMesh'B9Weapons_models.mgun_muzzle_flash'
	Style=3
	bUnlit=true
}