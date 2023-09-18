//=============================================================================
// B9_SPGameInfo.
//=============================================================================
class B9_SPGameInfo extends GameInfo;

var bool IsHeadquarters;		// true if HQ rules apply
var bool IsDirectPurchase;		// true if purchases items go directly to player

/* Called when pawn has a chance to pick Item up (i.e. when 
   the pawn touches a weapon pickup). Should return true if 
   he wants to pick it up, false if he does not want it.
*/
/* // Re-enable when the code is no longer the same as the base class.
function bool PickupQuery( Pawn Other, Pickup item )
{
	local Mutator M;
	local byte bAllowPickup;
	local B9_PlayerPawn b9Player;
	local B9_PlayerController b9PlayerController;
	local int panel5HUDOn;

	//
	//	Bring the health HUD into view for a short time if it was originally off.
	//
	if ( item.IsA( 'WeaponPickup' ) )
	{
		b9Player = B9_PlayerPawn( Other );
		b9PlayerController = B9_PlayerController( b9Player.Controller );
//		b9PlayerController.GetHUD().BlinkHUDPanel( 5 );	
	}


	if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, item, bAllowPickup) )
//	if ( BaseGameRules.HandlePickupQuery(Other, item, bAllowPickup) )
		return (bAllowPickup == 1);

	if ( Other.Inventory == None )
		return true;
	else
		return !Other.Inventory.HandlePickupQuery(Item);
}
*/

function bool ShouldRespawn( Pickup Other )
{
	return (Other.SavepointAwareness != SA_Existence);
}

defaultproperties
{
	DefaultPlayerClassName="B9Characters.B9_Player_norm_female"
	HUDType="B9HUD.B9_HUD"
	GameName="Black 9"
	PlayerControllerClassName="B9Characters.B9_PlayerController"
	bCollectSavepoint=true
}