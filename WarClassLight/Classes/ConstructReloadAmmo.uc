// ====================================================================
//  Class:  WarClassLight.ConstructReloadAmmo
//  Parent: WarfareGame.Constructions
//
//  <Enter a description here>
// ====================================================================

class ConstructReloadAmmo extends Constructions;

function Use( float Value )
{
	local vector HitLocation, HitNormal;
	local actor Other;
	local Inventory Inv;

	Other = Tracehit(HitLocation, HitNormal,128);
	if (WarfarePawn(Other)!=None)
	{
		for (Inv = WarfarePawn(Other).Inventory;Inv!=None;Inv=Inv.Inventory)
		{
			if ( Inv.IsA('Ammunition') )
			{
				Ammunition(Inv).AddAmmo(Ammunition(Inv).PickupAmmo);			
			}
		}			
	}

}

function AltFire()	// Throw out an ammo
{
	local AmmoDepot D;
	local vector Start,X,Y,Z;

	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	Start = Instigator.Location + 2 * Instigator.CollisionRadius * X + - 0.5 * Instigator.CollisionRadius * Y;
	
	if (Instigator.PlayerReplicationInfo.Team.TeamIndex==0)
		D = spawn(class'COGAmmoDepot',Instigator,,Start);
	else
		D = spawn(class'GeistAmmoDepot',Instigator,,Start);
	
	if (D!=None)
	{
		D.Velocity = Instigator.Velocity * 100;
		D.Velocity = X * 2500 + Y + (Z*250);
			
	}
}


defaultproperties
{
	ConstructionMessage="Press [USE] to..."
	StatusIcon=Texture'COG_Hud.Icons.C_ReloadTemp_T_JW'
	ItemName="Resupply Ammo"
}