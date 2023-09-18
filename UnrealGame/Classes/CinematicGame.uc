// ====================================================================
//  Class:  UnrealGame.CinematicGame
//  Parent: Engine.GameInfo
//
//  <Enter a description here>
// ====================================================================

class CinematicGame extends GameInfo;

event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local PlayerController NewPlayer;
	
	NewPlayer = Super.Login(Portal,Options,Error);
	
	if ( (NewPlayer.StartSpot != None) && (NewPlayer.StartSpot.Event != '') )
		TriggerEvent( NewPlayer.StartSpot.Event, NewPlayer.StartSpot, NewPlayer.Pawn);

	return NewPlayer;
}

defaultproperties
{
	HUDType="UnrealGame.CinematicHud"
}