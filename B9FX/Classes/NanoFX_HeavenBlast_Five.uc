class NanoFX_HeavenBlast_Five extends Emitter;

function FireBeam()
{
	Emitters[0].SpawnParticle( 1 );
}

defaultproperties
{
	Emitters=/* Array type was not detected. */
	Physics=10
	bNoDelete=false
	bTrailerSameRotation=true
	AmbientGlow=96
}