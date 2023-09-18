/////////////////////////////////////////////////////////////
// B9_AttrStrengthKiosk
//

class B9_AttrStrengthKiosk extends B9_AttrModKiosk;

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
		cal.Type = cal.AttrType.eStrength;
		SetStatInfo( pawn.fCharacterStrength, pawn.fCharacterSkillPoints, cal );
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
	fStatName="STRENGTH"
	fStatDescription="Strength is a measure of brute power.  Certain Heavy Weapons require high Strength to wield, and Strength is a primary influence on the M?l?e Combat skill and close combat nanotech skills such as FireFist and IceFist."
	TriggerTagName=AttrStrengthKioskTrigger
}