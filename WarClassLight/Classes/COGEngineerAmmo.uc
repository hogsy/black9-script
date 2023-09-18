// ====================================================================
//  Class:  WarClassLight.COGEngineerAmmo
//  Parent: WarfareGame.RechargingAmmo
//
//  <Enter a description here>
// ====================================================================

class COGEngineerAmmo extends RechargingAmmo;

function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Pawn P;
	local WarfareStationaryWeapon SW;
	local inventory I;
	local WarfareArmor A;

	ApplyKick();

	if ( Other == None )
		return;

	if ( (!Other.bWorldGeometry) && (Other != W.Instigator) ) 
	{
		P = Pawn(Other);
		SW = WarfareStationaryWeapon(Other);
	
		if ( P!= None && P.PlayerReplicationInfo.Team == W.Instigator.PlayerReplicationInfo.Team )
		{
			// Spawn the effect for rebuilding

			// Fix armor in the inventory
			
			for (i=P.Inventory;i!=none;i=I.Inventory)
			{
				A = WarfareArmor(i);
				if (A!=None)
				{
					A.Charge = clamp(A.Charge+15,0,A.Default.Charge);
					P.PlaySound(sound 'MedicMinorHeal');
				}
			}														
		}
		else if (SW!= None)
		{
			if (SW.TeamIndex == W.Instigator.PlayerReplicationInfo.Team.TeamIndex)
			{
				SW.Repair(15);
				SW.PlaySound(sound 'MedicMinorHeal');
			}
			else
				Other.TakeDamage(15,W.Instigator, HitLocation, 30000*X, MyDamageType);
		}
		else
			Other.TakeDamage(1,  W.Instigator, HitLocation, 30000*X, MyDamageType);
	}

	spawn(class'PclCOGEngineerArmorSpark',,,HitLocation,Rotator(HitNormal));

}

defaultproperties
{
	bLeadTarget=true
	bInstantHit=true
	MyDamageType=Class'WarDamageEngineerRay'
	WarnTargetPct=0.2
	RefireRate=0.99
	ItemName="Energon Cube"
}