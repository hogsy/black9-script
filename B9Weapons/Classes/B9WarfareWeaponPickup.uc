class B9WarfareWeaponPickup extends WeaponPickup
	abstract;

auto state Pickup
{	
	function Touch( actor Other )
	{
		local Pawn P;
			
		if( ValidTouch( Other ) ) 
		{	
			P = Pawn( Other );	
			AnnouncePickup( P );
		}
	}
}

defaultproperties
{
	Physics=5
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}