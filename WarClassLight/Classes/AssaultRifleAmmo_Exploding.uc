class AssaultRifleAmmo_Exploding extends AssaultRifleAmmo;

simulated function int FirstFireMode()
{
	return 0;
}

simulated function int LastFireMode()
{
	return 0;
} 
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	AmmoAmount -= 1;
	ApplyKick();

	if ( Other == None )
		return;
		
	if ( Other.bWorldGeometry || (Mover(Other) != None) )
	{
		if (MyDamageType.default.PawnDamageEmitter!=None)
			spawn(MyDamageType.default.PawnDamageEmitter,,,HitLocation+HitNormal*9, Rotator(HitNormal));
			
		HurtRadius(50,128, class'WarDamageExplosionRadius', 10000.0, HitLocation);					 
	}
	else if ( Other != W.Instigator ) 
	{
		if ( ( Pawn(Other)==None ) && (MyDamageType.default.PawnDamageEmitter!=None) )
			spawn(MyDamageType.default.PawnDamageEmitter,,,HitLocation+HitNormal*9, Rotator(HitNormal));		 

		Other.TakeDamage(30,  W.Instigator, HitLocation, 30000*X, MyDamageType);
		HurtRadius(20,128, class'WarDamageExplosionRadius', 10000.0, HitLocation);
	}
	else
		HurtRadius(50,128, class'WarDamageExplosionRadius', 10000.0, HitLocation);
	
}


defaultproperties
{
	ReloadCount=5
	WeaponKick=(X=0,Y=0,Z=1024)
	MaxAmmo=20
	AmmoAmount=10
	MyDamageType=Class'WarDamageA9Explosive'
	FireSound=Sound'WeaponSounds.AssaultRifle.COGassaultExplosiveShot'
	ItemName="Explosive Rounds"
}