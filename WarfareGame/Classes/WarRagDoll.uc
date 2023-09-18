class WarRagDoll extends KActor
	abstract
	placeable;

var	() array<sound>		PainSounds;

var () float			TimeBetweenPainSounds;
var () float			PainVolume;
var () float			PainRadius;

var transient float		LastSound;


event KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	local int numSounds;
	numSounds = PainSounds.Length;

	//log("ouch! ns:"$numSounds);

	if(numSounds > 0 && Level.TimeSeconds > LastSound + TimeBetweenPainSounds)
	{
		PlaySound(PainSounds[Rand(numSounds)], SLOT_Pain, PainVolume,,PainRadius);
		LastSound = Level.TimeSeconds;
	}
}

defaultproperties
{
	TimeBetweenPainSounds=0.5
	PainVolume=16
	PainRadius=10000
	Physics=14
	DrawType=2
	CollisionRadius=85
	CollisionHeight=85
	bBlockActors=false
	bBlockPlayers=false
	bBlockKarma=false
}