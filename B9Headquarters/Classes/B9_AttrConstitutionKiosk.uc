/////////////////////////////////////////////////////////////
// B9_AttrConstitutionKiosk
//

class B9_AttrConstitutionKiosk extends B9_AttrModKiosk;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentInteraction. You don't have to implement MenuInit(),
// but you should call super.MenuInit() if you do.
function Initialized()
{
	log(self@"I'm alive");
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	local B9_PlayerPawn pawn;
	local B9_AttrCalibration cal;

	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
		pawn = B9_PlayerPawn(RootController.Pawn);
		cal = new(None) class'B9_AttrCalibration';
		cal.Type = cal.AttrType.eConstitution;
		SetStatInfo( pawn.fCharacterConstitution, pawn.fCharacterSkillPoints, cal );
	}
}

function CompleteTransaction()
{
	local int points, adjustment;
	local B9_AttrCalibration cal;

	cal = B9_AttrCalibration(GetPointsUsed(points, adjustment));
	if (cal != None)
	{
		cal.SetCalibration(RootController.Pawn.Name, points);

		AddAttrCalibration(cal, adjustment);
	}

	MenuExit();
}

defaultproperties
{
	fStatName="CONSTITUTION"
	fStatDescription="Constitution is a measure of mental and physical endurance. It influences Health as well as some intense nanotech attacks, such as Earthquake and Tsunami."
	TriggerTagName=AttrConstitutionKioskTrigger
}