/*
	WallHit_Base
*/


class WallHit_Base	extends Effects
	abstract;


var  class<Emitter>		fEmitterClass;
var  float				fSoundVolume;
var  float				fSoundRadius;
var  float				fAiNoiseLevel;
var	 rotator			fRealRotation;

const BulletSounds = 6;
var Sound BulletRic[BulletSounds];

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		fRealRotation;
}


simulated function SetSoundLevels( float volume, float radius, float aiNoise )
{
	fSoundVolume	= volume;
	fSoundRadius	= radius;
	fAiNoiseLevel	= aiNoise;
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
	if( fEmitterClass != None )
	{
		Spawn( fEmitterClass,,, Location, Rotation );
	}

	SpawnSound();
	Destroy();
}

auto state Startup
{
	simulated function Tick(float DeltaTime)
	{
		if ( Instigator != None )
		{
			MakeNoise( fAiNoiseLevel );
		}
		if ( Role == ROLE_Authority )
		{
			fRealRotation = Rotation;
		}
		else
		{
			SetRotation( fRealRotation );
		}
		
		if ( Level.NetMode != NM_DedicatedServer )
		{
			SpawnEffects();
		}

		Disable('Tick');
	}
}





defaultproperties
{
	fSoundVolume=1
	fSoundRadius=600
	fAiNoiseLevel=0.2
	BulletRic[0]=Sound'B9Weapons_sounds.Firearms.bullet_ric_metal01'
	BulletRic[1]=Sound'B9Weapons_sounds.Firearms.bullet_ric_metal02'
	BulletRic[2]=Sound'B9Weapons_sounds.Firearms.bullet_ric_metal03'
	BulletRic[3]=Sound'B9Weapons_sounds.Firearms.bullet_ric_metal04'
	BulletRic[4]=Sound'B9Weapons_sounds.Firearms.bullet_ric_metal05'
	BulletRic[5]=Sound'B9Weapons_sounds.Firearms.bullet_ric05'
	DrawType=0
}