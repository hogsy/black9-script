//=============================================================================
// WarCogGrunt - Ragdoll edition
//=============================================================================
class WarCogGrunt_Rag extends CogLightInfantry
	placeable;

var () float DeathVelMag;

State Dying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
	{
		if ( bInvulnerableBody )
			return;
		Damage *= DamageType.Default.GibModifier;
		Health -=Damage;
		if ( (Damage > 40) && (Health < -60) )
		{
			ChunkUp(Rotation, DamageType);
			return;
		}

		if ( (Level.NetMode != NM_DedicatedServer) && (KarmaParamsSkel(KParams) != None) && Physics == PHYS_KarmaRagDoll)
		{
			KAddImpulse(momentum, hitlocation);
		}
	}
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local vector shotDir, hitLocation, hitNormal;
	local actor tmpActor;
	local float maxDim;

	bPlayedDeath = true;
	if ( bPhysicsAnimUpdate )
	{
		bTearOff = true;
		bReplicateMovement = false;
		HitDamageType = DamageType;
		TakeHitLocation = HitLoc;
		if ( (HitDamageType != None) && (HitDamageType.default.GibModifier >= 100) )
			ChunkUp(Rotation, DamageType);
	}

	if ( (Level.NetMode != NM_DedicatedServer) && (KarmaParamsSkel(KParams) != None) )
	{
		bPhysicsAnimUpdate = false;
		SetPhysics(PHYS_KarmaRagDoll);

		// Bit of a hack!
		// Now we have turned on Karma, do the trace again to figure out which actual bone to hit.
		maxDim = Max(CollisionRadius, CollisionHeight);
		shotDir = Normal(TearOffMomentum);
		tmpActor = Level.Trace(hitLocation, hitNormal, TakeHitLocation + (2*maxDim*shotDir), TakeHitLocation - (1 * shotDir), true);

		// Set the guy moving in direction he was shot in general
		KSetSkelVel( DeathVelMag * Normal(TearOffMomentum) );

		// Then kick the actual bone 
		KAddImpulse(TearOffMomentum*Mass, hitLocation);
	}

	if ( Physics != PHYS_KarmaRagDoll )
	{
		AnimBlendToAlpha(FIRINGCHANNEL,0,0.1);
		AnimBlendToAlpha(TAKEHITCHANNEL,0,0.1);
		AnimBlendToAlpha(FALLINGCHANNEL,0,0.1);
		PlayDyingAnim(DamageType,HitLoc);
	}
	else
	{
		AnimBlendToAlpha(FIRINGCHANNEL,0,0.1);
		AnimBlendToAlpha(TAKEHITCHANNEL,0,0.1);
		AnimBlendToAlpha(FALLINGCHANNEL,0,0.1);
		StopAnimating();
	}
	GotoState('Dying');
}

defaultproperties
{
	DeathVelMag=200
	LandGrunt=Sound'MaleSounds.(All).land10'
	AirSpeed=1000
	MenuName="Soldier"
	begin object name=Squibble0 class=KarmaParamsSkel
	// Object Offset:0x00477FD5
	KSkeleton="soldier2"
	KStartEnabled=true
	KFriction=0.4
object end
// Reference: KarmaParamsSkel'WarCOGGrunt_Rag.Squibble0'
KParams=Squibble0
}