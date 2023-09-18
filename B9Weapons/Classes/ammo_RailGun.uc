//=============================================================================
// ammo_RailGun
//
// Rail Gun slugs
//
// 
//=============================================================================


class ammo_RailGun extends B9Ammunition;



//////////////////////////////////
// Functions
//
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Emitter fx;

	if ( Other.bWorldGeometry || (Mover(Other) != None) )
	{
		spawn(class'WeaponFX_Railgun_Hit_Emitter',,,HitLocation+HitNormal*9);
	}
	
	else if ( Other != W.Instigator ) 
	{
		if ( Pawn(Other) != None )
		{
			fx = spawn( class'WeaponFX_Railgun_Hit_Emitter',,,Other.Location );
			fx.SetBase( Other );
		}
	}
	
	Super.ProcessTraceHit( W, Other, HitLocation, HitNormal, X, Y, Z );
}

//////////////////////////////////
// Initialization
//


defaultproperties
{
	fDamage=60
	fCustomSurfaceImpactFX=true
	fIniLookupName="RailGun"
	MaxAmmo=200
	AmmoAmount=10
	PickupAmmo=10
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_RailGun'
	PickupClass=Class'ammo_RailGun_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}