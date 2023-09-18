//=============================================================================
// RocketPack.
//=============================================================================
class SeekingRocketAmmo extends GrenadeAmmunition;

function float RateSelf(Pawn Shooter, out name RecommendedFiringMode)
{
	local float dist;

	if ( AmmoAmount <= 0 )
		return 0;

	if ( (Shooter == None)
		|| (Shooter.Controller == None)
		|| (Shooter.Controller.Enemy == None) )
		return 0.1;

	dist = VSize(Shooter.Location - Shooter.Controller.Enemy.Location);
	if ( dist > 4000 )
		return 0.2;
	if ( dist < 400 )
		return 0.1;
	return 0.8;
}


defaultproperties
{
	EventName=SeekingRockets
	MaxAmmo=48
	AmmoAmount=12
	ProjectileClass=Class'SeekingRocket'
	PickupClass=Class'RocketPack'
}