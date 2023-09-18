class Explosive_Gren_Flashbang_Proj extends B9Explosive_Proj;

var float	FuseTime;

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local pawn P;
	local PlayerController C;

	
	// Explode
	//
	if ( Level.NetMode != NM_DedicatedServer )
	{
		spawn(ExplosionDecal,,,,rot(16384,0,0));
  		spawn(class'FlashBangExplosion',,,HitLocation,rot(16384,0,0));
	}


	// Now the visual/audio flashbang effects
	//
	foreach RadiusActors( class 'Pawn', P, 500 )
	{
		if( P != none )
		{
			C = PlayerController( P.Controller );
			if( C != none )
			{
				C.CreateCameraEffect( class'FlashBangFX' );
			}
		}
	}

	// And in here we want to do something to the character's aiming, moving, etc
	//
	/* DO STUFF!! */

	Destroy();
}


defaultproperties
{
	FuseTime=2.5
	BounceDamping=0.65
	DrawType=2
	Mesh=SkeletalMesh'B9Weapons_models.Flashbang_mesh'
}