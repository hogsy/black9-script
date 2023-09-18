class HoldSpot extends UnrealScriptedSequence
	notplaceable;

function FreeScript()
{
	Destroy();
}

defaultproperties
{
	bStatic=false
	bCollideWhenPlacing=false
}