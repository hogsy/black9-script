class SkillStik extends InfoStik;

var string SkillClass;
var class<B9_Skill> Skill;
var travel int Points;

function PerformReadAction()
{
	local B9_Skill SkillInv;
	local int SkillPoints;

	SkillPoints = GetSkillPoints();
	if (SkillPoints > 0)
	{
		SkillInv = B9_Skill(Pawn(Owner).FindInventoryType(GetSkillClass()));
		if (SkillInv != None)
		{
			//Log("Adding "$SkillPoints$" to Healing");
			SkillInv.fStrength += SkillPoints;
			B9_AdvancedPawn(Owner).ApplyModifications();
		}
	}

	if (GetOnceOnly())
		Destroy();
	else
		UsedUp();
}

function class<B9_Skill> GetSkillClass()
{
	if (SkillClass == "")
	{
		SkillClass = Localize( InfoEntry, "SkillClass", InfoIni$"Info" );
		if (SkillClass != "")
			Skill = class<B9_Skill>(DynamicLoadObject(SkillClass, class'Class'));
	}

	return Skill;
}

function int GetSkillPoints()
{
	local string pts;

	if (Points == -1)
		return 0;

	if (Points == 0)
	{
		pts = Localize( InfoEntry, "SkillPoints", InfoIni$"Info" );
		if (pts != "")
			Points = int(pts);
	}

	return Points;
}

function UsedUp()
{
	Points = -1;
}

defaultproperties
{
	PickupClass=Class'SkillStik_Pickup'
	ItemName="SkillStik"
}