// AI Combatant game rules

class B9_AI_CombatantGameRules extends GameRules;

/* OverridePickupQuery()
when pawn wants to pickup something, gamerules given a chance to modify it.  If this function 
returns true, bAllowPickup will determine if the object can be picked up.
*/
function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup)
{
	// !!!! This is too specific -- just for milestone...
	if (B9_ArchetypePawnCombatant(Other) != None &&
		B9_AI_OldControllerCombatant(Other.Controller) != None)
	{
		if (SwarmGun2_Pickup(item) != None)
			bAllowPickup = 1;
		return true;
	}

	if ( (NextGameRules != None) &&  NextGameRules.OverridePickupQuery(Other, item, bAllowPickup) )
		return true;
	return false;
}
