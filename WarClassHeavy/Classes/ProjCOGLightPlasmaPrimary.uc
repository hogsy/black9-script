//=============================================================================
// ProjCOGLightPlasmaPrimary.uc
//=============================================================================
class ProjCOGLightPlasmaPrimary extends Projectile;

//#exec OBJ LOAD FILE=..\textures\johnparticles.utx PACKAGE=JohnParticles
 
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pulsegun\DFly1.WAV" NAME="PulseFly" GROUP="PulseGun"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pulsegun\PulseExp.WAV" NAME="PulseExp" GROUP="PulseGun"

var bool bAutoDestroy;
var() Sound EffectSound1;
var PclCOGLightPlasmaPrimary ParticleFX;

simulated function Destroyed()
{
	if ( (ParticleFX != None) && !bAutoDestroy )
		ParticleFX.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.8, true);
	if ( Level.NetMode == NM_Client )
		LifeSpan = 2.0;
	else
		Velocity = Speed * vector(Rotation);
	if ( Level.bDropDetail )
	{
		LightType = LT_None;
		bDynamicLight = false;
	}

	if ( Level.NetMode != NM_DedicatedServer )
		ParticleFX = Spawn(class'PclCOGLightPlasmaPrimary',self);
	bAutoDestroy = false;
}

simulated function Timer()
{
	if ( Level.bDropDetail )
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
	if ( (Physics == PHYS_None) && (LifeSpan > 0.5) )
		LifeSpan = 0.5;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if ( !bAutoDestroy )
	{
		if ( Role == ROLE_Authority )
			PlaySound(EffectSound1,,1.0);
		
		bAutoDestroy = true;

		if ( ParticleFX != None )
		{
			// Disable projectile emitters.
			ParticleFX.Emitters[0].Disabled = true;
			ParticleFX.Emitters[1].Disabled = true;
			ParticleFX.Emitters[2].Disabled = true;

			// Set position.
			ParticleFX.Emitters[3].StartLocationOffset += HitLocation;

			// Enable explosion emitter.
			ParticleFX.Emitters[3].Disabled = false;

			// Destroy independently.
			ParticleFX.AutoDestroy = true;

			ParticleFX.bDynamicLight = true;
			ParticleFX.LightType = LT_Steady;
			ParticleFX.LightRadius = 5;
		}

		SetCollision(false,false,false);
		LifeSpan = 0.5;

		if ( PhysicsVolume.bMoveProjectiles && (PhysicsVolume.ZoneVelocity != vect(0,0,0)) )
		{
			bBounce = true;
			Velocity = PhysicsVolume.ZoneVelocity;
		}
		else
			SetPhysics(PHYS_None);
	}
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	If ( Other!=Instigator )
	{
		if ( Role == ROLE_Authority )
			Other.TakeDamage( Damage, instigator, HitLocation, MomentumTransfer*Vector(Rotation), MyDamageType);	
		Explode(HitLocation, vect(0,0,1));
	}
}

auto State Flying
{
Begin:
	LifeSpan = 2.0;
}

defaultproperties
{
	EffectSound1=Sound'PulseGun.PulseExp'
	Speed=3000
	Damage=30
	MomentumTransfer=10000
	MyDamageType=Class'WarClassLight.WarDamageEnergy'
	ExplosionDecal=Class'WarClassLight.BoltScorch'
	ExploWallOut=10
	LifeSpan=0.5
	SoundRadius=10
	SoundVolume=218
	bFixedRotationDir=true
	ForceType=1
	ForceRadius=100
	ForceScale=0.6
}