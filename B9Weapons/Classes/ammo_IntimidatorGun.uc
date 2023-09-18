//=============================================================================
// ammo_IntimidatorGun
//
// 
//=============================================================================


class ammo_IntimidatorGun extends B9Ammunition;
var float DamageRadius;
var float MomentumTransfer;
//////////////////////////////////
// Initialization
//
//////////////////////////////////
// Functions
//
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Emitter fx;
	
	
	if ( Role == ROLE_Authority )
	{
		HurtRadius( fDamage/2.0, DamageRadius, MyDamageType, MomentumTransfer*2, HitLocation );
	}
	
	if ( Level.NetMode != NM_DedicatedServer  )
	{
  		spawn(class'ExplosionFX_Two_Emitter',,,HitLocation,rot(16384,0,0));
	}		
	Super.ProcessTraceHit( W, Other, HitLocation, HitNormal, X, Y, Z );
}

function float GetDamageRadius()
{
	return DamageRadius;
}

defaultproperties
{
	DamageRadius=200
	MomentumTransfer=10000
	fDamage=18
	MaxAmmo=120
	AmmoAmount=15
	PickupAmmo=15
	bInstantHit=true
	bSplashDamage=true
	MyDamageType=Class'B9BasicTypes.damage_IntimidatorGun'
	PickupClass=Class'ammo_IntimidatorGun_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}