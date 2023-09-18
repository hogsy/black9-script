//=============================================================================
// B9_HealthDepotTrigger
//=============================================================================
class B9_HealthDepotTrigger extends B9_DepotTrigger;

var Sound fHealthDepotSound;
var float fHealthDepotSoundVolume;

function UsedBy( Pawn user )
{
	local int amount;
	local B9_BasicPlayerPawn APawn;

	Log( "B9_HealthDepotTrigger.UsedBy"$user );

	APawn = B9_BasicPlayerPawn(user);
	if (APawn != None)
	{
		amount = APawn.fCharacterMaxHealth - APawn.Health;
		if (amount > 0)
		{
			PlaySound(fHealthDepotSound, SLOT_None, fHealthDepotSoundVolume,,100);

			if (amount > CurrentAmount)
				amount = CurrentAmount;
			APawn.Health += amount;
			CurrentAmount -= amount;

			User.Trigger(self, User.Instigator); // change depot info in HUD
		}
	}
}

defaultproperties
{
	fHealthDepotSound=Sound'B9Misc_Sounds.ItemPickup.pickup_item01'
	fHealthDepotSoundVolume=0.7
	Basis=10
}