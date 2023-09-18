//=============================================================================
// UT_HeavyWallHitEffect.
//=============================================================================
class UT_HeavyWallHitEffect extends UT_WallHit;


simulated function SpawnSound()
{
	local float decision;

	decision = FRand();
	if ( decision < 0.5 ) 
		PlaySound(sound'ricochet',, 4,,50, 0.5+FRand(),true);		
	else if ( decision < 0.75 )
		PlaySound(sound'Impact1',, 4,,50,,true);
	else
		PlaySound(sound'Impact2',, 4,,50,,true);
}

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
			A = spawn(class'Chip');
			if ( A != None )
				A.RemoteRole = ROLE_None;
		}

	Dir = Vector(Rotation);
	if ( Level.DetailMode == DM_Low )
		return;
	Spawn(class'Pock',,,Location,Rotator(-Vector(Rotation)));
	A = Spawn(class'UT_SpriteSmokePuff',,,Location + 8 * Vector(Rotation));
	A.RemoteRole = ROLE_None;
	if ( PhysicsVolume.bWaterVolume || Level.bDropDetail )
		return;
	if ( NumSparks > 0 ) 
		for (j=0; j<NumSparks; j++) 
			spawn(class'UT_Spark',,,Location + 8 * Vector(Rotation));
}

defaultproperties
{
	MaxSparks=4
	ChipOdds=0.5
}