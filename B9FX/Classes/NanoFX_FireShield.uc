//=============================================================================
// NanoFX_FireShield.uc
//
//	Fire Shield actor object
//
//=============================================================================


class NanoFX_FireShield extends Actor;


//////////////////////////////////
// Resource imports
//

//////////////////////////////////
// Definitions
//

//////////////////////////////////
// Variables
//

//////////////////////////////////
// Functions
//
simulated function ProcessTouch( actor Other, vector HitLocation )
{
	local Projectile proj;

	if ( Other != Owner && !Other.bWorldGeometry )
	{
		proj = Projectile( Other );
		if( Other != None )
		{

		}
	}
}


//////////////////////////////////
// States
//


//////////////////////////////////
// Initialization
//


defaultproperties
{
	DrawType=8
	StaticMesh=StaticMesh'B9_Effects_meshes.nanoShield.shieldSphere'
	RemoteRole=2
}