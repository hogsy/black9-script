//=============================================================================
// ammo_RadFlux
//
// 9mm bullet ammunition
// Used for 9mm Pistol, Assault Rifle, SMG, Silenced Pistol, Suitcase Gun
//
// 
//=============================================================================


class ammo_RadFlux extends B9Ammunition;



//////////////////////////////////
// Functions
//
function ProcessTraceHit( Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z )
{
	if ( Other.bWorldGeometry || (Mover(Other) != None) )
	{
		Spawn(class'B9FX.WallHit_RadFlux',,, HitLocation+HitNormal, Rotator(HitNormal));
	}

	Super.ProcessTraceHit( W, Other, HitLocation, HitNormal, X, Y, Z );
}

//////////////////////////////////
// Initialization
//


defaultproperties
{
	fCustomSurfaceImpactFX=true
	fIniLookupName="RadFlux"
	MaxAmmo=1275
	AmmoAmount=255
	PickupAmmo=255
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_RadFlux'
	PickupClass=Class'ammo_RadFlux_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}