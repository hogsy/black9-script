// B9_ItemGiver.uc

class B9_ItemGiver extends Actor
	placeable;
	
var (ItemGiver) int SkillPoints;
var (ItemGiver) int Credits;
var (ItemGiver) int fMissionNumberCompleted;

function Trigger( actor Other, pawn EventInstigator )
{
	local B9_BasicPlayerPawn PlayerPawn;
	local B9_PlayerControllerBase Controller;

	Controller = B9_PlayerControllerBase(EventInstigator.Controller);
	if (Controller != None)
	{
		PlayerPawn = B9_BasicPlayerPawn(Controller.GetAdvancedPawn());
		if (PlayerPawn != None)
		{
			PlayerPawn.fCharacterSkillPoints += SkillPoints;
			PlayerPawn.fAcquiredSkillPoints += SkillPoints;
			PlayerPawn.fCharacterCash += Credits;
			PlayerPawn.fAcquiredCash += Credits;

			if(fMissionNumberCompleted != 0)
			{
				PlayerPawn.fCharacterConcludedMission = fMissionNumberCompleted;
			}
		}
	}

	Destroy();
}

defaultproperties
{
	SavepointAwareness=2
}