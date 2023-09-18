class HitFX_Flamethrower_Emitter extends Emitter;

simulated function Tick( float Delta )
{
	if( Pawn(Owner) != none && Pawn(Owner).Health <= 0 )
	{
		Destroy();
	}
}

defaultproperties
{
	Emitters=/* Array type was not detected. */
	AutoDestroy=true
	bNoDelete=false
	LifeSpan=2
}