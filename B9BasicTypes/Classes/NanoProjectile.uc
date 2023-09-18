
class NanoProjectile extends Projectile
	abstract;


var Emitter			fFX;
var class <Emitter>	fFxClass;

var Emitter		fTrailFX;
var class <Emitter>	fTrailFxClass;

var Emitter		fImpactFX;
var class <Emitter>	fImpactFxClass;

var float		fNoiseLevel;


simulated function SetDamageLevels( int dmg, int radius )
{
	Damage			= dmg;
	DamageRadius	= radius;

	log( "Damage:"$Damage$" DamageRadius:"$DamageRadius );
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode == NM_Client )
	{
		LifeSpan = 10.0;
	}
	else
	{
		Velocity = Speed * vector(Rotation);
	}

	if ( Level.bDropDetail )
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if( fFxClass != None )
	{
		fFX = Spawn( fFxClass, self, ,Location ,Rotation);

	}
	if( fTrailFxClass != None )
	{
		fTrailFX = Spawn( fTrailFxClass, self );
	}
}


simulated function Destroyed()
{
	if( fFX != None )
	{
		fFX.Destroy();
		fFX = None;
	}
	if( fTrailFX != None )
	{
		fTrailFX.Destroy();
		fTrailFX = None;
	}
	
	Super.Destroyed();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if ( Role == ROLE_Authority )
	{
		HurtRadius( Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
		MakeNoise( fNoiseLevel );
	}
	
	if ( Level.NetMode != NM_DedicatedServer && fImpactFxClass != None )
	{
  		spawn( fImpactFxClass,,, HitLocation, rot( 16384, 0, 0 ) );
	}

 	Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if( Other != Owner )
	{
		Explode( HitLocation, vect( 0, 0, 1 ) );
	}
}












defaultproperties
{
	DrawType=0
}