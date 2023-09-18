/////////////////////////////////////////////////////////////
// B9_AttrAgilityKiosk
//

class B9_AttrAgilityKiosk extends B9_AttrModKiosk;

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
		cal.Type = cal.AttrType.eAgility;
		SetStatInfo( pawn.fCharacterAgility, pawn.fCharacterSkillPoints, cal );
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
	fStatName="AGILITY"
	fStatDescription="Agility measures quickness of movement and reaction time.  It influences skills that benefit from fast actions, such as Jumping and Fireball, and directly influences the derived attribute Speed."
	TriggerTagName=AttrAgilityKioskTrigger
}