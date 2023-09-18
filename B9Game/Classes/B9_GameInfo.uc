//=============================================================================
// B9_GameInfo.
//=============================================================================
class B9_GameInfo extends GameInfo;

var bool IsHeadquarters;		// true if HQ rules apply
var bool IsDirectPurchase;		// true if purchases items go directly to player


function bool PlayerAlreadyHasThisWeapon( B9_BasicPlayerPawn P, Pickup item )
{
	local Inventory Inv;

	for( Inv = P.Inventory; Inv != None; Inv = Inv.Inventory )
	{
		if( Inv.PickupClass == Item )
		{
			return true;
		}
	}

	return false;
}

function bool PickupQuery( Pawn Other, Pickup item )
{
	local byte bAllowPickup;
	local B9_BasicPlayerPawn BP;
    
	if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, item, bAllowPickup) )
		return (bAllowPickup == 1);

	if ( Other.Inventory == None )
		return true;

    else
	{
		if( !item.IsA( 'WeaponPickup' ) )
		{
			return !Other.Inventory.HandlePickupQuery( Item );
		}
		else
		{
			BP = B9_BasicPlayerPawn ( Other );
			if( BP == None )
			{
				return !Other.Inventory.HandlePickupQuery( Item );
			}
			else
			{
				if( BP.fWeaponCount >= 3 &&
					!Item.IsA( 'GrapplingHook_Pickup' ) &&
					!PlayerAlreadyHasThisWeapon( BP, item ) )
				{
					return false;
				}
				return true;
			}
		}
	}
}


defaultproperties
{
	bDelayedStart=false
	DefaultPlayerClassName="B9Characters.Assassin"
	HUDType="B9HUD.B9_HUD"
	GameName="Black 9"
	PlayerControllerClassName="B9Characters.B9_PlayerController"
}