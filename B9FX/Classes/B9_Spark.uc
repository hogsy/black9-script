//=============================================================================
// B9_spark.
//=============================================================================
class B9_Spark extends Effects;


function PostBeginPlay()
{
	Velocity = (Vector(Rotation) + VRand()) * 200 * FRand();
}

auto state Explode
{
	simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if( NewVolume.bWaterVolume )
			Destroy();
	}

	simulated function Landed( vector HitNormal )
	{
		Destroy();
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Destroy();
	}
}

defaultproperties
{
	Physics=2
	NetPriority=2
	LifeSpan=1
	Texture=Texture'Effects.Sparky'
	DrawScale=0.1
	Style=3
	bCollideWorld=true
	bBounce=true
}