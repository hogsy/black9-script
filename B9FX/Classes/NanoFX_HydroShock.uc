//=============================================================================
// NanoFX_HydroShock.uc
//
//	Hydro Shock actor object
//
//=============================================================================


class NanoFX_HydroShock extends Actor;


//////////////////////////////////
// Resource imports
//

//////////////////////////////////
// Definitions
//

//////////////////////////////////
// Variables
//

var private array <Actor> fActorsAlreadyHit;

//////////////////////////////////
// Functions
//
simulated function ProcessTouch( actor Other, vector HitLocation )
{
	local Projectile proj;

	if ( Other != Owner && !Other.bWorldGeometry )
	{
		if( CheckActorAlreadyHit( Other ) )
		{
			return;
		}

		AddToHitList( Other );

		// Other.TakeDamage( );
	}
}

simulated function Tick( float DeltaTime )
{
	SetDrawScale( DrawScale + DeltaTime );
}


function bool CheckActorAlreadyHit( Actor A )
{
	local int i;
	
	for( i = 0; i < fActorsAlreadyHit.Length; i++ )
	{
		if( fActorsAlreadyHit[i] != None && fActorsAlreadyHit[i] == A )
		{
			return true;
		}
	}
	return false;
}

function AddToHitList( Actor A )
{
	fActorsAlreadyHit.Length = fActorsAlreadyHit.Length + 1;
	fActorsAlreadyHit[fActorsAlreadyHit.Length - 1] = A;
}

//////////////////////////////////
// States
//


//////////////////////////////////
// Initialization
//


defaultproperties
{
	DrawType=2
	RemoteRole=2
	Mesh=SkeletalMesh'B9Effects_models.EnergyBubble_mesh'
}