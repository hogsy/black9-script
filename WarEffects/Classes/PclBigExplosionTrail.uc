// ====================================================================
//  Class:  WarEffects.PclBigExplosionTrail
//  Parent: Engine.Emitter
//
//  <Enter a description here>
// ====================================================================

class PclBigExplosionTrail extends Emitter;

function Timer()
{
	Emitters[0].RespawnDeadParticles=false;
	Emitters[1].RespawnDeadParticles=false;
	Emitters[2].RespawnDeadParticles=false;
}

function HitWall( vector HitNormal, actor Wall )
{
	local float Speed;

	Velocity = 0.5*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping

	speed = VSize(Velocity);

	if ( Velocity.Z > 400 )
		Velocity.Z = 0.5 * (400 + Velocity.Z);	

	else if ( Speed < 20 ) 
	{
		bBounce = False;
		SetPhysics(PHYS_None);
		SetTimer(frand()+1,false);
	}
}

defaultproperties
{
	Emitters=/* Array type was not detected. */
	AutoDestroy=true
	Physics=2
	bNoDelete=false
	RemoteRole=1
	LifeSpan=15
	CollisionRadius=0
	CollisionHeight=0
	bCollideActors=true
	bCollideWorld=true
	bBounce=true
}