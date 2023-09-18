//=============================================================================
// BulletBox.
//=============================================================================
class BulletAmmo extends WarfareAmmo;

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
		
		if (Pawn(Other) != None)				
			Other.TakeDamage(65,  W.Instigator, HitLocation, 30000.0*X, class'WarDamageSniper');
							
//		if ( (Pawn(Other) != None) && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight) ) 
//			Other.TakeDamage(120, W.Instigator, HitLocation, 35000 * X, class'WarDamageSniperHeadshot');
//		else
//			Other.TakeDamage(65,  W.Instigator, HitLocation, 30000.0*X, class'WarDamageSniper');	
	}
}

defaultproperties
{
	MaxAmmo=50
	AmmoAmount=10
	bInstantHit=true
	RefireRate=0.6
	PickupClass=Class'BulletBox'
	ItemName="Box of Rifle Rounds"
}