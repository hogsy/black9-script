//=============================================================================
// B9_HQGameInfo.
//=============================================================================
class B9_HQGameInfo extends B9_GameInfo;

var bool IsMultiplayer;

//
// Return whether an item should respawn.
//
function bool ShouldRespawn( Pickup Other )
{
	return false;
}

/* Called when pawn has a chance to pick Item up (i.e. when 
   the pawn touches a weapon pickup). Should return true if 
   he wants to pick it up, false if he does not want it.
*/
function bool PickupQuery( Pawn Other, Pickup item )
{
	local B9_PlayerPawn PP;

	PP = B9_PlayerPawn(Other);
	Log("IT="$item.Tag$" IC="$item.Class.Name$" SN="$PP.fServerName);
	if (PP != None && item.Tag != item.Class.Name && item.Tag != PP.fServerName)
		return false;
	return Super.PickupQuery( Other, item );
}

