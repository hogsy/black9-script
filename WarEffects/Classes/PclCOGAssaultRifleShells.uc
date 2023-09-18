class PclCOGAssaultRifleShells extends Emitter;

function TriggerParticle()
{
	Emitters[0].RotationOffset = Owner.Rotation;
	Emitters[0].SpawnParticle(1);
}

defaultproperties
{
	Emitters=/* Array type was not detected. */
	Physics=10
	bNoDelete=false
	bTrailerSameRotation=true
	Mass=4
}