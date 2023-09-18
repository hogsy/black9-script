//=============================================================================
// Bird.
//=============================================================================
class SmallBird extends Bird;

function PlayCall()
{
	PlaySound(sound'call1m',,0.5 + 0.5 * FRand(),,, 1 + 0.7 * FRand());
}

defaultproperties
{
	DrawScale=0.5
	CollisionRadius=14
	CollisionHeight=8
}