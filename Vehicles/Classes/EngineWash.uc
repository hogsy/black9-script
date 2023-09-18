class EngineWash extends Emitter;

function SetStrength(float washdist)
{
	if ( WashDist > 800 )
	{
		Emitters[0].LifeTimeRange.Min = Max(0.2, Emitters[0].Default.LifeTimeRange.Min * (WashDist-800)/1200);
		Emitters[0].LifeTimeRange.Max = Max(0.2, Emitters[0].Default.LifeTimeRange.Max * (WashDist-800)/1200);
	}
	else
	{
		Emitters[0].LifeTimeRange.Min = Emitters[0].Default.LifeTimeRange.Min;
		Emitters[0].LifeTimeRange.Max = Emitters[0].Default.LifeTimeRange.Max;
	}
}


 
defaultproperties
{
	Emitters=/* Array type was not detected. */
	bNoDelete=false
}