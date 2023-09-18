//=============================================================================
// B9_HeavyWallHitEffect.
//=============================================================================
class B9_HeavyWallHitEffect extends B9_WallHit;

simulated function SpawnEffects()
{
	local Actor A;
	local int j;
	local int NumSparks;
	local vector Dir;

	SpawnSound();
	NumSparks = rand(MaxSparks);
	for ( j=0; j<MaxChips; j++ )
		if ( FRand() < ChipOdds ) 
		{
			NumSparks--;
			//A = spawn(class'B9_Chip');
			//if ( A != None )
			//	A.RemoteRole = ROLE_None;
		}

	Dir = Vector(Rotation);
//	if ( !Level.bHighDetailMode )
//		return;
	Spawn(class'Pock',,,Location,Rotator(-Vector(Rotation)));
	A = Spawn(class'B9_SpriteSmokePuff',,,Location + 8 * Vector(Rotation));
	A.RemoteRole = ROLE_None;
	if ( PhysicsVolume.bWaterVolume || Level.bDropDetail )
		return;
	if ( NumSparks > 0 ) 
		for (j=0; j<NumSparks; j++) 
			spawn(class'B9_Spark',,,Location + 8 * Vector(Rotation));
}

defaultproperties
{
	MaxSparks=4
	ChipOdds=0.5
}