class ExplosionDebris extends Emitter;

var int numBounces;

function PostBeginPlay()
{
	Velocity = vect(0,0,400) + 1000 * VRand();
	Velocity = 400 * Normal(Velocity);
	//EMStartVelocity = 0.3 * Velocity;
	SetTimer(3.0,false);
	Super.PostBeginPlay();		
}

function Timer()
{
	Velocity = Velocity.Z * vect(0,0,1);
	numBounces = 5;
}

function HitWall( vector HitNormal, actor Wall )
{
	numBounces++;
	if ( numBounces > 4 )
	{
		//EMRespawnDeadParticles = false;
		if ( HitNormal.Z > 0 )
		{
			SetPhysics(PHYS_None);
			Velocity = vect(0,0,0);
		}
		return;
	}
	Velocity = (( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	if ( VSize(Velocity) > 300 )
		Velocity -= 0.2 * (HitNormal dot Velocity) * HitNormal;
	//EMStartVelocity = 0.3 * Velocity;
}

defaultproperties
{
	LightType=8
	LightEffect=13
	LightBrightness=192
	LightRadius=3
	LightHue=27
	LightSaturation=71
	Physics=2
	bNoDelete=false
	bDynamicLight=true
	bCollideWorld=true
	bBounce=true
}