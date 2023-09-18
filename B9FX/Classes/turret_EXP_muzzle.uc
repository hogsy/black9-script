
class turret_EXP_muzzle extends Emitter;


function Fire( float value )
{
	if( Emitters[0].Disabled )
	{
		Emitters[0].Disabled = false;
	}
	Emitters[0].SpawnParticle(5);
}


defaultproperties
{
	Emitters=/* Array type was not detected. */
	Physics=10
	bNoDelete=false
	bTrailerSameRotation=true
	RemoteRole=2
}