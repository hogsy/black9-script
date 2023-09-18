// Abstracting this out in case we need to change functionality from Warefare
class B9_Pickup extends Pickup
	abstract;

// possible interactions
function int GetHUDActions( Pawn other )
{
	local int	HUDActions;


	HUDActions	= HUDActions | kHUDAction_PickUp;

	return HUDActions;
}

function float PlaySpawnEffect()
{
	spawn( class 'EnhancedReSpawn',self,, Location );
	return 0.3;
}

function inventory SpawnCopy(Pawn Other)
{
	local Controller P;
	local Inventory Copy;

	Copy = Super.SpawnCopy(Other);

	// FIXME - MOVE THIS TO ANNOUNCE PICKUP
	if ( Copy.Instigator.IsA('Bot') || Level.Game.bTeamGame || (Level.Game.NumBots > 4) )
		return Copy;

	// let high skill bots hear pickup if close enough
	for ( P=Level.ControllerList; P!=None; P=P.NextController )
	{
		if ( P.IsA('AIController') && (P.Pawn != None)
			&& (VSize(P.Pawn.Location - Location) < 1000) )
		{
			AIController(P).HearPickup(Copy.Instigator);
			return Copy;
		}
	}
	return Copy;
}

defaultproperties
{
	PickupSound=Sound'B9Misc_Sounds.ItemPickup.pickup_item03'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}