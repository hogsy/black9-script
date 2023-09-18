// ====================================================================
//  Class:  WarfareGame.WarBulletHitsWall
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WarBulletHitsWall extends Emitter;

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
	NumSparks = rand(5);
	for ( j=0; j<NumSparks; j++ )
		if ( FRand() < 0.5 ) 
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
}

simulated event PostNetBeginPlay()
{
	SpawnSound();
	SpawnEffects();
}

defaultproperties
{
	Emitters=/* Array type was not detected. */
	AutoDestroy=true
	Physics=10
	bNoDelete=false
	bTrailerSameRotation=true
	RemoteRole=1
	DrawScale=0.1
	Mass=4
}