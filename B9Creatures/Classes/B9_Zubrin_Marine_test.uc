//===============================================================================
//  [B9_Zubrin_Marine_test] 
//===============================================================================

class B9_Zubrin_Marine_test extends WarfarePawn;

//#exec OBJ LOAD FILE=..\animations\B9_Zubrin_characters.ukx PACKAGE=B9_Zubrin_characters

/*
var protected B9_mgun_muzzle_flash fMuzzleFlash;
*/

/*
// Animation Notifiers

function muzzleStart()
{
	fMuzzleFlash = spawn( class'B9_mgun_muzzle_flash', self );
	AttachToBone( fMuzzleFlash, 'Gun' );
}

function muzzleEnd()
{
	if ( fMuzzleFlash != None )
	{
		DetachFromBone( fMuzzleFlash );
		fMuzzleFlash.Destroy();
		fMuzzleFlash = None;
	}
}

*/

defaultproperties
{
	Helmet=none
	HelmetBone=Bip 01 Head
	GroundSpeed=500
	WalkingPct=0.415
	Mesh=SkeletalMesh'B9_Zubrin_characters.Zubrin_Marine_mesh'
}