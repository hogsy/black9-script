// ====================================================================
//  Class:  WarfareGame.WarfareRechargeWeapons
//  Parent: WarfareGame.WarfareWeapon
//
//  <Enter a description here>
// ====================================================================

class WarfareRechargeWeapons extends WarfareWeapon;

replication
{
	reliable if (ROLE==ROLE_Authority)
		ClientForceWeaponSwitch;
}

simulated function DrawHud(canvas Canvas, WarfareHud Hud, FontInfo Fonts, float Scale)
{
	local float tScale;
	local int team;
	
	if ( Instigator == None )
		return;

	tScale = Scale;
	if (Scale<1)
		Scale=1;
		
	// Draw the Clip Ammo Display
	
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetDrawColor(255,255,255);
	Team = Instigator.PlayerReplicationInfo.Team.TeamIndex; 
	Canvas.SetPos(0,0);
	Canvas.DrawTile(Hud.LeftHud[Team],191*Scale,98*Scale,0,0,191,98);

	Canvas.SetDrawColor(255,255,0);
	
	Canvas.Font = Fonts.GetHugeFont(Canvas.ClipX);
	Canvas.SetPos(73*Scale,10*Scale);
	Canvas.DrawText(int(RechargingAmmo(AmmoType).Charge), false);
	
	Canvas.SetDrawColor(255,255,255);
	
	Canvas.SetPos(15*Scale, 54*Scale);
	Canvas.Font = Fonts.GetSmallestFont(Canvas.ClipX);
	Canvas.DrawText(AmmoType.ItemName,false);	

	Scale=tScale;

}


function float AmmoStatus()
{
	return RechargingAmmo(AmmoType).Charge/RechargingAmmo(AmmoType).MaxCharge;
}

function bool HandlePickupQuery( Pickup Item )
{
	local float NewAmmo;
	local Pawn P;

	if (Item.InventoryType == Class)
	{
		if ( WeaponPickup(item).bWeaponStay && ((item.inventory == None) || item.inventory.bTossedOut) )
			return true;
		P = Pawn(Owner);
		if ( AmmoType != None )
		{
			NewAmmo = RechargingAmmo(AmmoType).MaxCharge;
			AmmoType.AddAmmo(NewAmmo);
			ClientWeaponSet(true);
		}
		Item.AnnouncePickup(Pawn(Owner));
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

function GiveAmmo( Pawn Other )
{
	local float MaxCharge;
	if ( AmmoName == None )
		return;
		
	AmmoType = Ammunition(Other.FindInventoryType(AmmoName));
	if ( AmmoType != None )
	{
		MaxCharge = RechargingAmmo(AmmoType).MaxCharge;
		AmmoType.AddAmmo(MaxCharge);
	}
	else
	{
		AmmoType = Spawn(AmmoName);	// Create ammo type required		
		Other.AddInventory(AmmoType);		// and add to player's inventory
	}
}	


simulated function ClientForceWeaponSwitch()
{
	Instigator.Controller.SwitchToBestWeapon();
	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
	}
	else
		GotoState('Idle');
}

defaultproperties
{
	AmmoName=Class'RechargingAmmo'
}