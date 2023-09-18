class EngineFlame extends Emitter;

function SetOffset(vector NewOffset)
{
	Emitters[0].StartLocationOffset = NewOffset;
	Emitters[1].StartLocationOffset = NewOffset;
}
// afterburner effect
function afterburner(bool bEnabled)
{
	if ( bEnabled )
	{
//	    EMStartVelocity=vect(0,0,-1200);
	}
	else
	{
//	    EMStartVelocity=vect(0,0,-600);
	}
}

 
defaultproperties
{
	Emitters=/* Array type was not detected. */
	bNoDelete=false
}