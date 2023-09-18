//=============================================================================
// proj_TracerRound_TypeTwo.uc
//=============================================================================
class proj_TracerRound_TypeTwo extends B9ProjectileBase;

var bool	fStartedSound;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode == NM_Client )
	{
		LifeSpan = 1.0;
	}
	else
	{
		Velocity = Speed * vector(Rotation);
		OrientProjectile(Instigator);
	}

	if ( Level.bDropDetail )
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
}

simulated function Tick( float deltaTime )
{
	if( !fStartedSound && LifeSpan <= 4.95 )
	{
		fStartedSound = true;
		if( fRand() < 0.5 )
		{
			AmbientSound=sound'BulletSounds.Flyby.bullet_whizzing1';
		}
		else
		{
			AmbientSound=sound'BulletSounds.Flyby.bullet_whizzing2';
		}
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Destroy();
}


simulated function Explode(vector HitLocation, vector HitNormal)
{	
 	Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if( Other == Instigator || Other.IsA( 'Emitter' ) )
	{
		return;
	}

	Destroy();
}


defaultproperties
{
	Speed=12000
	MaxSpeed=12000
	MomentumTransfer=10000
	DrawType=0
	LifeSpan=5
	SoundRadius=80
	SoundVolume=200
	CollisionRadius=1
	CollisionHeight=1
	bFixedRotationDir=true
}