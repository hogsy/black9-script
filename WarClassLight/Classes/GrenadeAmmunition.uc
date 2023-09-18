class GrenadeAmmunition extends WarfareAmmo;

var Name EventName;

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
	if ( (dist > 1200) || (dist < 400) )
		return 0.1;
	return 0.8;
}

/*
inform any grenade launcher about my presence
*/
function PickupFunction(Pawn Other)
{
	local WeapGeistGrenadeLauncher L;

	L = WeapGeistGrenadeLauncher(Other.FindInventoryType(class'WeapGeistGrenadeLauncher'));

	if ( L != None )
		L.AddAmmoType(self);
}

defaultproperties
{
	WeaponKick=(X=0,Y=0,Z=2048)
	bLeadTarget=true
	bSplashDamage=true
	WarnTargetPct=1
}