//=============================================================================
// B9_LightWallHitEffect.
//=============================================================================
class B9_LightWallHitEffect extends B9_WallHit;

simulated function SpawnEffects()
{
	local Actor A;

	if ( !Level.bDropDetail )
		SpawnSound();

//	if ( !Level.bHighDetailMode )
//		return;

	if ( Level.bDropDetail )
	{
		if ( FRand() > 0.4 )
			Spawn(class'Pock');
		return;
	}
	Spawn(class'Pock');

	A = Spawn(class'B9_SpriteSmokePuff',,,Location + 8 * Vector(Rotation));
	A.RemoteRole = ROLE_None;
	if ( PhysicsVolume.bWaterVolume )
		return;
	if ( FRand() < 0.5 )
		spawn(class'B9_Spark',,,Location + 8 * Vector(Rotation));
}

defaultproperties
{
	MaxChips=0
	MaxSparks=1
}