class TeamToggle extends actor
	placeable;

function Trigger( actor Other, pawn EventInstigator )
{
	local B9_PlayerController B9PlayerController;
	B9PlayerController = B9_PlayerController(EventInstigator.Controller);

	if( B9PlayerController != None)
	{
		B9PlayerController.SwitchTeam();
	}
}

defaultproperties
{
	bHidden=true
}