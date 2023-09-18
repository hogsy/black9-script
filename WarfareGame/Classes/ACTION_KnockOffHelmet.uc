class ACTION_KnockOffHelmet extends ScriptedAction;

var(Action) vector HelmetVelocity;

function bool InitActionFor(ScriptedController C)
{
	local HelmetAttachment H;

	if ( (WarfarePawn(C.Pawn) == None) || (WarfarePawn(C.Pawn).HelmetActor == None) )
		return false;

	H = WarfarePawn(C.Pawn).HelmetActor;
	WarfarePawn(C.Pawn).KnockOffHelmet();
	H.LifeSpan = 100;
	if ( HelmetVelocity != vect(0,0,0) )
		H.Velocity = HelmetVelocity;
	return false;	
}

defaultproperties
{
	ActionString="knock off helmet"
}