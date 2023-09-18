//=============================================================================
// B9_MainMenu.
//=============================================================================
class B9_MainMenu extends GameInfo;


/* Called when pawn has a chance to pick Item up (i.e. when 
   the pawn touches a weapon pickup). Should return true if 
   he wants to pick it up, false if he does not want it.
*/
/*
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

defaultproperties
{
	DefaultPlayerClassName="B9Characters.B9_dummy_player"
	GameName="Black 9"
	PlayerControllerClassName="B9Menus.B9_MainMenuController"
}