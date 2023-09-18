//===============================================================================
//  [B9_Genesis_Med_statue] 
//===============================================================================

class B9_Genesis_Med_statue extends B9_Decoration;

#exec OBJ LOAD FILE=..\animations\B9_Genesis_characters.ukx PACKAGE=B9_Genesis_characters

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('idle_surveillance1');
}

defaultproperties
{
	bStatic=false
	Mesh=SkeletalMesh'B9_Genesis_characters.Genesis_medium_mesh'
}