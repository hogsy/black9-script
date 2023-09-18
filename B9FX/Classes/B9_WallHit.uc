//=============================================================================
// B9_WallHit.
//=============================================================================
class B9_WallHit extends B9_BulletImpact;


var int MaxChips, MaxSparks;
var float ChipOdds;
var rotator RealRotation;

const BulletSounds = 6;
var Sound BulletRic[BulletSounds];

var float fSoundVolume;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		RealRotation;
}

simulated function SpawnSound()
{
	local int ndx;
	
	ndx = FRand() * ( BulletSounds + 5 );
	if ( ndx >= BulletSounds )
	{
		return;
	}
	else
	{
		PlaySound(BulletRic[ndx],, fSoundVolume,,50,,true);
	}
}

simulated function SpawnEffects()
{
	local Actor A;
	local int j;
	local int NumSparks;

	SpawnSound();

	NumSparks = rand(MaxSparks);
	if ( !Level.bDropDetail )
		for ( j=0; j<MaxChips; j++ )
			if ( FRand() < ChipOdds ) 
			{
				NumSparks--;
				A = spawn(class'B9_Chip');
				if ( A != None )
					A.RemoteRole = ROLE_None;
			}

//	if ( !Level.bHighDetailMode )
//		return;

	Spawn(class'Pock');
	if ( Level.bDropDetail )
		return;

	A = Spawn(class'B9_SpriteSmokePuff');
	A.RemoteRole = ROLE_None;
	if ( !PhysicsVolume.bWaterVolume && (NumSparks > 0) ) 
		for (j=0; j<NumSparks; j++) 
			spawn(class'B9_Spark',,,Location + 8 * Vector(Rotation));
}

Auto State StartUp
{
	simulated function Tick(float DeltaTime)
	{
		if ( Instigator != None )
			MakeNoise(0.3);
		if ( Role == ROLE_Authority )
			RealRotation = Rotation;
		else
			SetRotation(RealRotation);
		
		if ( Level.NetMode != NM_DedicatedServer )
			SpawnEffects();
		Disable('Tick');
	}
}

defaultproperties
{
	MaxChips=2
	MaxSparks=3
	ChipOdds=0.2
	BulletRic[0]=Sound'B9Weapons_sounds.Firearms.bullet_ric_metal01'
	BulletRic[1]=Sound'B9Weapons_sounds.Firearms.bullet_ric_metal02'
	BulletRic[2]=Sound'B9Weapons_sounds.Firearms.bullet_ric_metal03'
	BulletRic[3]=Sound'B9Weapons_sounds.Firearms.bullet_ric_metal04'
	BulletRic[4]=Sound'B9Weapons_sounds.Firearms.bullet_ric_metal05'
	BulletRic[5]=Sound'B9Weapons_sounds.Firearms.bullet_ric05'
	fSoundVolume=1
	RemoteRole=2
}