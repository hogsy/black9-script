// ====================================================================
//  Class:  WarClassLight.CogMedicAmmo
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class CogMedicAmmo extends RechargingAmmo;

function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Pawn P;

	ApplyKick();

	if ( Other == None )
		return;

	if ( (!Other.bWorldGeometry) && (Other != W.Instigator) ) 
	{
		P = Pawn(Other);
	
		if ( P!= None && P.PlayerReplicationInfo.Team == W.Instigator.PlayerReplicationInfo.Team )
		{
			// Spawn the effect for healing

			P.Health = clamp(P.Health+5,0,P.Default.Health);
			
			if (PlayerController(P.Controller) != None)
			{
//				PlayerController(P.Controller).ClientSetFlash(vect(0.15,0,0),vect(0,0,64));
				P.PlaySound(sound 'MedicMinorHeal');
			}
			
		}
		else
			Other.TakeDamage(5,  W.Instigator, HitLocation, 30000*X, MyDamageType);
	}
}

defaultproperties
{
	bLeadTarget=true
	bInstantHit=true
	MyDamageType=Class'WarDamageMedic'
	WarnTargetPct=0.2
	RefireRate=0.99
	ItemName="Health Cell"
}