//=============================================================================
// MinigunAmmo.
//=============================================================================
class MinigunAmmo extends WarfareAmmo;

function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{

	AmmoAmount -= 1;

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
		
		// FIXME HACK
		if ( (ScriptedController(W.Instigator.Controller) == None)
			|| !ScriptedController(W.Instigator.Controller).bFakeShot )		
			Other.TakeDamage(20,  W.Instigator, HitLocation, Vect(0,0,0), MyDamageType);	
	}
}

defaultproperties
{
	MaxAmmo=500
	AmmoAmount=50
	bInstantHit=true
	MyDamageType=Class'WarDamageMinigun'
	RefireRate=0.99
	PickupClass=Class'Miniammo'
	ItemName="Large Bullets"
}