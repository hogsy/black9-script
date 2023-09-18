// ====================================================================
//  Class:  WarEffects.PclBigExplosion
//  Parent: Engine.Emitter
//
//  <Enter a description here>
// ====================================================================

class PclBigExplosion extends Emitter;

#exec OBJ LOAD FILE=..\Sounds\WarfareExplosion.uax PACKAGE=WarfareExplosion

var() Range NoTrails;
var() Sound EffectSound;

simulated event Tick(float delta)
{
	super.Tick(Delta);
	LightBrightness -= 1500 * Delta;
}	

function MakeSound()
{
	PlaySound(EffectSound,,2.0,,1024);
}


simulated event PostBeginPlay()
{
	local int cnt,i;
	local rotator R;
	local vector Norm,RVect;
	local PclBigExplosionTrail T;

	Super.PostBeginPlay();

	Norm = vector(Rotation);
	
	MakeSound();
	
	cnt = rand(NoTrails.Max - NoTrails.Min);
	cnt += NoTrails.Min;
	
	for (i=0;i<cnt;i++)
	{
		RVect = VRand();
		
		if ( (RVect dot Norm) <0 )
			R = rotator(RVect*-1);
		else
			R = rotator(RVect);
		
		T = Spawn(class 'PCLBigExplosionTrail',,,location,r);
		T.Velocity = Vector(r) * (Rand(1000)+300);
	}
}

defaultproperties
{
	NoTrails=(Min=6,Max=20)
	EffectSound=Sound'WarfareExplosion.Explode.explosion_large1'
	Emitters=/* Array type was not detected. */
	AutoDestroy=true
	LightType=1
	LightEffect=13
	LightBrightness=1024
	LightRadius=8
	LightHue=13
	LightSaturation=16
	bNoDelete=false
	bDynamicLight=true
	RemoteRole=2
	Mass=4
}