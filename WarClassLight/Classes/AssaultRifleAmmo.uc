//=============================================================================
// AssaultRifleAmmo.
// base class of bullet ammunition used by assault rifles
// has information about clip sizes, and damage
//=============================================================================
class AssaultRifleAmmo extends WarfareAmmo;

var byte ReloadCount;

simulated function int FirstFireMode()
{
	return 2;
}

simulated function int LastFireMode()
{
	return 2;
} 

function float RateSelf(Pawn Shooter, out name RecommendedFiringMode)
{
	if ( AmmoAmount <= 0 )
		return 0;

	if ( Shooter.Controller.Enemy == None ) // fixme - shouldn't depend on if enemy, but on what target
		return 1;

	if ( VSize(Shooter.Location - Shooter.Controller.Enemy.Location) > 2500 )
		RecommendedFiringMode = 'auto';
	else
		RecommendedFiringMode = 'single';
	return 0.5;
}

function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	AmmoAmount -= 1;
	ApplyKick();

	if ( Other == None )
		return;
		
	if ( Other.bWorldGeometry || (Mover(Other) != None) )
	{
		Spawn(class'WarBulletHitsWall',,, HitLocation+HitNormal*3, Rotator(HitNormal));
		spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
//		Spawn(class'UT_HeavyWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	}

	else if ( Other != W.Instigator ) 
	{
		if ( Pawn(Other) == None )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);

		Other.TakeDamage(20,  W.Instigator, HitLocation, 30000.0*X, MyDamageType);	
	}
}

defaultproperties
{
	ReloadCount=50
	WeaponKick=(X=0,Y=0,Z=384)
	MaxAmmo=199
	AmmoAmount=199
	bInstantHit=true
	MyDamageType=Class'WarDamageA9b'
	RefireRate=0.8
	FireSound=Sound'WeaponSounds.AssaultRifle.COGassault_shoot'
	PickupClass=Class'Miniammo'
	ItemName="Standard Rounds"
}