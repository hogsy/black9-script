//=============================================================================
// WaterImpact.
//=============================================================================
class WaterImpact extends Effects;

var bool bSpawnOnce;

simulated function Timer()
{
	if ( Level.NetMode != NM_DedicatedServer )
		Spawn(class'WaterRing',,,,rot(16384,0,0));
	else 
		Destroy();
	if (bSpawnOnce) Destroy();
	bSpawnOnce=True;
}


simulated function PostBeginPlay()
{
	SetTimer(0.3,True);
}

defaultproperties
{
	DrawType=2
	RemoteRole=2
	AmbientGlow=79
}