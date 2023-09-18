// ====================================================================
//  Class:  WarClassLight.CogP9Ammo
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class CogP9Ammo extends RechargingAmmo;

var float ShotCharge;
var bool bNoRecharge;

event tick(float Delta)
{
	if (bNoRecharge)
		return;
		
	Super.Tick(Delta);
}

function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Emitter Hit;

	if (W.Instigator.PlayerReplicationInfo.Team.TeamIndex==0)
	{
		if (ShotCharge > 50)
			Hit = spawn(class 'PclCogP9SecondaryHit',Other,,HitLocation+HitNormal,rotator(HitNormal));
		else
			Hit = spawn(class 'PclCOGP9hit',Other,,HitLocation + HitNormal,rotator(HitNormal));
	}
	else
		Hit = spawn(class 'PclGeistP9hit',Other,,HitLocation + HitNormal,rotator(HitNormal));
	
	ApplyKick();

	if ( Other == None )
		return;

	ShotCharge = clamp(ShotCharge,0,MaxCharge);		
	if ( ( !Other.bWorldGeometry ) && ( Other != W.Instigator ) ) 
	{
		if ( Pawn(Other) == None )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);

		Other.TakeDamage(ShotCharge,  W.Instigator, HitLocation, Vect(0,0,0), MyDamageType);	
	}
}


defaultproperties
{
	bLeadTarget=true
	bInstantHit=true
	MyDamageType=Class'WarDamageP9Primary'
	WarnTargetPct=0.2
	RefireRate=0.99
	ItemName="Pulse Cell"
}